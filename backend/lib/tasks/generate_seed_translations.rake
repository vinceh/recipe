namespace :recipes do
  LANG_KEY_MAP = {
    'ja' => :ja,
    'ko' => :ko,
    'zh-tw' => :zh_tw,
    'zh-cn' => :zh_cn,
    'es' => :es,
    'fr' => :fr
  }.freeze

  desc "Generate full translations for seed recipes using Claude AI"
  task generate_seed_translations: :environment do
    languages = RecipeTranslator::LANGUAGES.keys
    output_file = Rails.root.join('db', 'seeds', '02_recipe_full_translations_data.rb')
    translator = RecipeTranslator.new
    translations = {}

    recipes = Recipe.joins(:translations)
                    .where(recipe_translations: { locale: 'en' })
                    .includes(ingredient_groups: :recipe_ingredients)
                    .includes(:recipe_steps, :equipment)
                    .order(:id)

    puts "Starting translation generation for #{recipes.count} recipes × #{languages.length} languages"
    puts "This will make #{recipes.count * languages.length} API calls..."
    puts

    recipes.each_with_index do |recipe, idx|
      recipe_name = recipe.name
      translations[recipe_name] = {}
      puts "[#{idx + 1}/#{recipes.count}] Translating: #{recipe_name}"

      languages.each do |lang|
        print "  #{lang}... "
        begin
          result = translator.translate_recipe(recipe, lang)
          if result
            lang_sym = LANG_KEY_MAP[lang]
            translations[recipe_name][lang_sym] = {
              name: result['name'],
              description: result['description'],
              ingredient_groups: result['ingredient_groups']&.map do |group|
                {
                  name: group['name'],
                  items: group['items']&.map do |item|
                    { name: item['name'], preparation: item['preparation'] }
                  end
                }
              end,
              steps: result['steps']&.map do |step|
                { instruction: step['instruction'] }
              end,
              equipment: result['equipment']
            }
            puts "✓"
          else
            puts "✗ (nil response)"
          end
        rescue StandardError => e
          puts "✗ (#{e.message})"
        end
      end
      puts
    end

    write_translations_file(output_file, translations)
    puts "Done! Translations written to: #{output_file}"
  end

  desc "Fill in missing translations only"
  task fill_missing_translations: :environment do
    output_file = Rails.root.join('db', 'seeds', '02_recipe_full_translations_data.rb')
    load output_file

    translator = RecipeTranslator.new
    translations = RECIPE_FULL_TRANSLATIONS.deep_dup

    missing = find_missing_translations(translations)

    if missing.empty?
      puts "All translations present!"
      return
    end

    puts "Filling in #{missing.values.flatten.length} missing translations..."
    puts

    missing.each do |recipe_name, langs|
      recipe = Recipe.joins(:translations)
                     .where(recipe_translations: { locale: 'en', name: recipe_name })
                     .includes(ingredient_groups: :recipe_ingredients)
                     .includes(:recipe_steps, :equipment)
                     .first

      unless recipe
        puts "#{recipe_name}: Recipe not found, skipping"
        next
      end

      puts "#{recipe_name}:"
      langs.each do |lang|
        print "  #{lang}... "
        begin
          result = translator.translate_recipe(recipe, lang)
          if result
            lang_sym = LANG_KEY_MAP[lang]
            translations[recipe_name][lang_sym] = {
              name: result['name'],
              description: result['description'],
              ingredient_groups: result['ingredient_groups']&.map do |group|
                {
                  name: group['name'],
                  items: group['items']&.map do |item|
                    { name: item['name'], preparation: item['preparation'] }
                  end
                }
              end,
              steps: result['steps']&.map do |step|
                { instruction: step['instruction'] }
              end,
              equipment: result['equipment']
            }
            puts "✓"
          else
            puts "✗ (nil response)"
          end
        rescue StandardError => e
          puts "✗ (#{e.message})"
        end
      end
    end

    write_translations_file(output_file, translations)
    puts
    puts "Done! Updated translations written to: #{output_file}"
  end

  def find_missing_translations(translations)
    missing = {}
    all_langs = RecipeTranslator::LANGUAGES.keys

    translations.each do |recipe_name, langs|
      missing_langs = all_langs.select do |lang|
        lang_sym = LANG_KEY_MAP[lang]
        !langs[lang_sym] || langs[lang_sym][:name].nil?
      end
      missing[recipe_name] = missing_langs if missing_langs.any?
    end

    missing
  end

  def write_translations_file(file_path, translations)
    File.open(file_path, 'w') do |f|
      f.puts "# Full Recipe Translations - Uses English recipe names as keys"
      f.puts "# Contains ingredient groups, ingredients, steps, and equipment translations"
      f.puts "# Languages: ja, ko, zh_tw, zh_cn, es, fr"
      f.puts "#"
      f.puts "# DO NOT EDIT MANUALLY - Regenerate with: rake recipes:generate_seed_translations"
      f.puts
      f.puts "RECIPE_FULL_TRANSLATIONS = {"

      translations.each_with_index do |(recipe_name, langs), recipe_idx|
        f.puts "  #{recipe_name.inspect} => {"

        langs.each_with_index do |(lang, data), lang_idx|
          f.puts "    #{lang}: {"
          f.puts "      name: #{data[:name].inspect},"
          f.puts "      description: #{data[:description].inspect},"

          if data[:ingredient_groups]&.any?
            f.puts "      ingredient_groups: ["
            data[:ingredient_groups].each_with_index do |group, g_idx|
              f.puts "        {"
              f.puts "          name: #{group[:name].inspect},"
              f.puts "          items: ["
              group[:items]&.each_with_index do |item, i_idx|
                comma = i_idx < (group[:items].length - 1) ? "," : ""
                f.puts "            { name: #{item[:name].inspect}, preparation: #{item[:preparation].inspect} }#{comma}"
              end
              f.puts "          ]"
              comma = g_idx < (data[:ingredient_groups].length - 1) ? "," : ""
              f.puts "        }#{comma}"
            end
            f.puts "      ],"
          end

          if data[:steps]&.any?
            f.puts "      steps: ["
            data[:steps].each_with_index do |step, s_idx|
              comma = s_idx < (data[:steps].length - 1) ? "," : ""
              f.puts "        { instruction: #{step[:instruction].inspect} }#{comma}"
            end
            f.puts "      ],"
          end

          if data[:equipment]&.any?
            f.puts "      equipment: #{data[:equipment].inspect}"
          end

          comma = lang_idx < (langs.length - 1) ? "," : ""
          f.puts "    }#{comma}"
        end

        comma = recipe_idx < (translations.length - 1) ? "," : ""
        f.puts "  }#{comma}"
      end

      f.puts "}.freeze"
    end
  end
end
