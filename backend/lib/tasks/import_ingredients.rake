namespace :ingredients do
  desc "Consolidate batch files from data/tmp/ into ingredients.json"
  task :consolidate_batch, [:batch_num] => :environment do |_t, args|
    batch_num = args[:batch_num]&.to_i
    unless batch_num
      puts "Usage: rake ingredients:consolidate_batch[1]"
      exit 1
    end

    tmp_dir = Rails.root.join('data', 'tmp')
    main_json = Rails.root.join('data', 'ingredients.json')

    batch_files = Dir.glob(tmp_dir.join("batch_#{batch_num.to_s.rjust(2, '0')}_*.json"))
    if batch_files.empty?
      puts "No files found for batch #{batch_num} in #{tmp_dir}"
      exit 1
    end

    puts "Found #{batch_files.size} files for batch #{batch_num}:"
    batch_files.each { |f| puts "  - #{File.basename(f)}" }

    main_data = if File.exist?(main_json)
                  JSON.parse(File.read(main_json))
                else
                  { 'ingredients' => [] }
                end

    existing_names = main_data['ingredients'].map { |i| i['canonical_name'].downcase }.to_set
    existing_aliases = main_data['ingredients'].flat_map { |i| (i['aliases'] || []).map { |a| a['alias'].downcase } }.to_set

    added = 0
    skipped = 0
    warnings = []

    batch_files.each do |file|
      puts "\nProcessing #{File.basename(file)}..."
      data = JSON.parse(File.read(file))
      ingredients = data.is_a?(Array) ? data : (data['ingredients'] || [])

      ingredients.each do |item|
        name = item['canonical_name']
        unless name.is_a?(String) && name.strip.present?
          warnings << "SKIPPED: item missing canonical_name"
          skipped += 1
          next
        end
        normalized_name = name.downcase.strip

        if existing_names.include?(normalized_name)
          skipped += 1
          warnings << "DUPLICATE: '#{name}' already exists"
          next
        end

        nutrition = item['per_100g'] || {}
        cal = nutrition['calories'].to_f
        prot = nutrition['protein_g'].to_f
        carb = nutrition['carbs_g'].to_f
        fat = nutrition['fat_g'].to_f

        if cal < 0 || cal > 900
          warnings << "SUSPICIOUS: '#{name}' has calories=#{cal}"
        end
        if prot < 0 || prot > 100 || carb < 0 || carb > 100 || fat < 0 || fat > 100
          warnings << "SUSPICIOUS: '#{name}' has unusual macros (p=#{prot}, c=#{carb}, f=#{fat})"
        end

        valid_aliases = (item['aliases'] || []).select { |a| a['alias'].is_a?(String) && a['alias'].strip.present? }
        item['aliases'] = valid_aliases

        alias_conflicts = valid_aliases.select { |a| existing_aliases.include?(a['alias'].downcase) }
        if alias_conflicts.any?
          warnings << "ALIAS CONFLICT: '#{name}' has aliases that already exist: #{alias_conflicts.map { |a| a['alias'] }.join(', ')}"
          item['aliases'] = valid_aliases.reject { |a| existing_aliases.include?(a['alias'].downcase) }
        end

        main_data['ingredients'] << item
        existing_names << normalized_name
        item['aliases'].each { |a| existing_aliases << a['alias'].downcase }
        added += 1
        print "."
      end
    end

    File.write(main_json, JSON.pretty_generate(main_data))

    puts "\n\nConsolidation complete!"
    puts "  Added: #{added}"
    puts "  Skipped (duplicates): #{skipped}"
    puts "  Total in ingredients.json: #{main_data['ingredients'].size}"

    if warnings.any?
      puts "\nWarnings (#{warnings.size}):"
      warnings.first(20).each { |w| puts "  - #{w}" }
      puts "  ... and #{warnings.size - 20} more" if warnings.size > 20
    end
  end

  def build_unit_mapping
    {
      'cup' => 'cup', 'tablespoon' => 'tbsp', 'tbsp' => 'tbsp', 'teaspoon' => 'tsp', 'tsp' => 'tsp',
      'ml' => 'ml', 'pinch' => 'pinch', 'gram' => 'g', 'g' => 'g', 'ounce' => 'oz', 'oz' => 'oz',
      'lb' => 'lb', 'pound' => 'lb', 'inch' => 'inch', 'clove' => 'clove', 'head' => 'head',
      'bunch' => 'bunch', 'sprig' => 'sprig', 'stalk' => 'stalk', 'leaf' => 'leaf', 'slice' => 'slice',
      'wedge' => 'wedge', 'handful' => 'handful', 'can' => 'can', 'package' => 'package',
      'serving' => 'serving', 'fillet' => 'fillet', 'strip' => 'strip', 'whole' => 'whole', 'piece' => 'piece',
      'breast' => 'piece', 'thigh' => 'piece', 'drumstick' => 'piece', 'wing' => 'piece', 'leg' => 'piece',
      'chop' => 'piece', 'steak' => 'piece', 'cutlet' => 'piece', 'fillet' => 'piece', 'patty' => 'piece',
      'ball' => 'piece', 'block' => 'piece', 'cube' => 'piece', 'stick' => 'piece', 'egg' => 'piece',
      'large' => 'piece', 'medium' => 'piece', 'small' => 'piece', 'fruit' => 'piece', 'root' => 'piece',
    }
  end

  def map_unit_to_standard(unit_str, mapping)
    return mapping[unit_str] if mapping[unit_str]
    return 'cup' if unit_str.start_with?('cup')
    return 'tbsp' if unit_str.include?('tablespoon')
    return 'tsp' if unit_str.include?('teaspoon')
    return 'piece' if %w[back bird bone bud bulb cheek chile chili cob cone duck ear floret foot fowl goose gourd half heart hen hock kidney lime link mat medallion neck nut pad pepper pod quail rabbit rack radish ramp rib roast roll sac sachet saddle shank sheet shoulder spear spleen star tail tenderloin tentacle tomatillo tongue tuber turkey].include?(unit_str)
    return 'leaf' if unit_str.include?('leaf')
    return 'head' if unit_str.include?('head')
    return 'stalk' if unit_str.include?('stalk')
    'piece'
  end

  desc "Import ingredients from JSON file (data/ingredients.json)"
  task import: :environment do
    json_path = Rails.root.join('data', 'ingredients.json')

    unless File.exist?(json_path)
      puts "Error: #{json_path} not found"
      puts "Create the file first, then run this task."
      exit 1
    end

    category_map = {
      'fat' => 'oil_fat',
      'oil' => 'oil_fat',
      'starch' => 'grain',
      'noodle' => 'grain',
      'sauce' => 'condiment',
      'seasoning' => 'condiment',
      'fermented' => 'condiment',
      'produce' => 'vegetable',
      'meat' => 'protein',
      'poultry' => 'protein',
      'fish' => 'seafood',
      'shellfish' => 'seafood',
      'nut' => 'nut_seed',
      'seed' => 'nut_seed',
      'flour' => 'grain',
      'rice' => 'grain',
      'bean' => 'legume',
      'lentil' => 'legume',
      'sugar' => 'sweetener',
      'honey' => 'sweetener',
      'aromatic' => 'herb',
      'dried' => 'other',
      'preserved' => 'other',
      'stock' => 'other',
      'broth' => 'other',
      'paste' => 'condiment',
      'powder' => 'spice'
    }

    def normalize_category(cat, category_map)
      return nil if cat.nil?
      cat = cat.to_s.downcase.strip
      return cat if Ingredient::CATEGORIES.include?(cat)
      category_map.each do |pattern, mapped|
        return mapped if cat.include?(pattern)
      end
      'other'
    end

    unit_mapping = build_unit_mapping
    unit_cache = Unit.all.index_by(&:canonical_name)

    data = JSON.parse(File.read(json_path))
    ingredients = data['ingredients'] || data

    total = ingredients.size
    imported = 0
    skipped = 0
    errors = []

    puts "Importing #{total} ingredients..."

    ingredients.each_with_index do |item, index|
      canonical_name = item['canonical_name']

      existing = Ingredient.find_by("LOWER(canonical_name) = ?", canonical_name.downcase)
      if existing
        skipped += 1
        print "S"
        next
      end

      normalized_cat = normalize_category(item['category'], category_map)

      ActiveRecord::Base.transaction do
        ingredient = Ingredient.create!(
          canonical_name: canonical_name,
          category: normalized_cat
        )

        if item['per_100g']
          IngredientNutrition.create!(
            ingredient: ingredient,
            calories: item['per_100g']['calories'],
            protein_g: item['per_100g']['protein_g'],
            carbs_g: item['per_100g']['carbs_g'],
            fat_g: item['per_100g']['fat_g'],
            fiber_g: item['per_100g']['fiber_g'],
            data_source: 'ai',
            confidence_score: 0.8
          )
        end

        valid_languages = %w[en ja ko zh-tw zh-cn es fr]
        language_map = {
          'zh' => 'zh-cn', 'chinese' => 'zh-cn', 'mandarin' => 'zh-cn',
          'japanese' => 'ja', 'korean' => 'ko', 'spanish' => 'es', 'french' => 'fr',
          'th' => 'en', 'vi' => 'en', 'id' => 'en', 'ms' => 'en', 'tl' => 'en',
          'hi' => 'en', 'ar' => 'en', 'pt' => 'en', 'de' => 'en', 'it' => 'en'
        }

        aliases_data = item['aliases']
        aliases_data = [] if aliases_data.nil? || aliases_data.is_a?(Hash)
        aliases_data.each do |alias_data|
          next unless alias_data.is_a?(Hash) && alias_data['alias'].present?
          lang = (alias_data['language'] || 'en').to_s.downcase
          lang = language_map[lang] || lang
          lang = 'en' unless valid_languages.include?(lang)
          valid_types = %w[synonym translation misspelling]
          alias_type = (alias_data['type'] || 'synonym').to_s.downcase
          alias_type = 'synonym' unless valid_types.include?(alias_type)
          IngredientAlias.create!(
            ingredient: ingredient,
            alias: alias_data['alias'],
            language: lang,
            alias_type: alias_type
          )
        end

        units_data = item['common_units']
        units_data = [] if units_data.nil?
        if units_data.is_a?(Hash)
          units_data = units_data.map { |unit, grams| { 'unit' => unit, 'grams' => grams } }
        end
        created_unit_ids = Set.new
        units_data.each do |unit_data|
          next unless unit_data.is_a?(Hash)
          next unless unit_data['unit'].present? && unit_data['grams'].present?
          unit_str = unit_data['unit'].to_s.downcase.strip
          next if %w[egg\ white egg\ yolk large\ egg\ white large\ egg\ yolk].include?(unit_str)
          standard_unit_name = map_unit_to_standard(unit_str, unit_mapping)
          unit = unit_cache[standard_unit_name]
          next unless unit
          next if created_unit_ids.include?(unit.id)
          IngredientUnitConversion.create!(
            ingredient: ingredient,
            unit: unit,
            grams: unit_data['grams']
          )
          created_unit_ids << unit.id
        end

        imported += 1
        print "."
      end
    rescue StandardError => e
      errors << { name: canonical_name, error: e.message }
      print "E"
    end

    puts "\n\nImport complete!"
    puts "  Imported: #{imported}"
    puts "  Skipped (already exist): #{skipped}"
    puts "  Errors: #{errors.size}"

    if errors.any?
      puts "\nErrors:"
      errors.first(10).each { |e| puts "  - #{e[:name]}: #{e[:error]}" }
      puts "  ... and #{errors.size - 10} more" if errors.size > 10
    end
  end

  desc "Import aliases from generated JSON files in tmp/generated_aliases/"
  task import_aliases: :environment do
    generated_dir = Rails.root.join('tmp', 'generated_aliases')
    unless File.directory?(generated_dir)
      puts "No generated_aliases directory found at #{generated_dir}"
      exit 1
    end

    json_files = Dir.glob(generated_dir.join('*.json'))
    puts "Found #{json_files.size} alias files to import"

    valid_languages = %w[en ja ko zh-tw zh-cn es fr]
    valid_types = %w[synonym translation misspelling]
    ingredient_cache = Ingredient.all.index_by(&:id)
    existing_aliases = IngredientAlias.pluck(:ingredient_id, :alias, :language)
                                      .map { |id, a, l| "#{id}:#{a.downcase}:#{l}" }
                                      .to_set

    imported = 0
    skipped = 0
    errors = []

    json_files.each do |file|
      puts "\nProcessing #{File.basename(file)}..."
      data = JSON.parse(File.read(file))

      # Handle different formats: "ingredients" or "aliases" at top level
      items = data['ingredients'] || data['aliases'] || []

      items.each do |item|
        # Handle different ID field names
        ing_id = item['id'] || item['ingredient_id']
        ingredient = ingredient_cache[ing_id]
        unless ingredient
          errors << "Ingredient ID #{ing_id} not found"
          next
        end

        aliases = item['aliases'] || []
        aliases.each do |alias_data|
          # Handle different alias field names: "alias" or "value"
          alias_str = (alias_data['alias'] || alias_data['value'])&.strip
          next if alias_str.blank?

          lang = (alias_data['language'] || 'en').to_s.downcase
          lang = 'en' unless valid_languages.include?(lang)
          alias_type = (alias_data['type'] || 'synonym').to_s.downcase
          alias_type = 'synonym' unless valid_types.include?(alias_type)

          key = "#{ingredient.id}:#{alias_str.downcase}:#{lang}"
          if existing_aliases.include?(key)
            skipped += 1
            next
          end

          begin
            IngredientAlias.create!(
              ingredient: ingredient,
              alias: alias_str,
              language: lang,
              alias_type: alias_type
            )
            existing_aliases << key
            imported += 1
          rescue => e
            errors << "#{ingredient.canonical_name}: #{e.message}"
          end
        end
      end
      print "."
    end

    puts "\n\nImport complete!"
    puts "  Imported: #{imported}"
    puts "  Skipped (duplicates): #{skipped}"
    puts "  Errors: #{errors.size}"
    errors.first(10).each { |e| puts "    - #{e}" } if errors.any?
  end

  desc "Import nutrition from generated JSON files in tmp/generated_nutrition/"
  task import_nutrition: :environment do
    generated_dir = Rails.root.join('tmp', 'generated_nutrition')
    unless File.directory?(generated_dir)
      puts "No generated_nutrition directory found at #{generated_dir}"
      exit 1
    end

    json_files = Dir.glob(generated_dir.join('*.json'))
    puts "Found #{json_files.size} nutrition files to import"

    ingredient_cache = Ingredient.all.index_by(&:id)
    updated = 0
    errors = []

    json_files.each do |file|
      puts "\nProcessing #{File.basename(file)}..."
      data = JSON.parse(File.read(file))
      ingredients = data['ingredients'] || []

      ingredients.each do |item|
        ingredient = ingredient_cache[item['id']]
        unless ingredient
          errors << "Ingredient ID #{item['id']} not found"
          next
        end

        nutrition = ingredient.nutrition
        unless nutrition
          errors << "#{ingredient.canonical_name}: No nutrition record"
          next
        end

        per100g = item['per_100g'] || {}
        nutrition.update!(
          calories: per100g['calories'] || nutrition.calories,
          protein_g: per100g['protein_g'] || nutrition.protein_g,
          carbs_g: per100g['carbs_g'] || nutrition.carbs_g,
          fat_g: per100g['fat_g'] || nutrition.fat_g,
          fiber_g: per100g['fiber_g'] || nutrition.fiber_g,
          data_source: 'ai',
          confidence_score: 0.7
        )
        updated += 1
      rescue => e
        errors << "#{ingredient.canonical_name}: #{e.message}"
      end
      print "."
    end

    puts "\n\nImport complete!"
    puts "  Updated: #{updated}"
    puts "  Errors: #{errors.size}"
    errors.first(10).each { |e| puts "    - #{e}" } if errors.any?
  end

  desc "Audit imported ingredients for duplicates and data quality"
  task audit: :environment do
    puts "Auditing ingredient database..."
    puts "=" * 50

    puts "\n1. Checking for duplicate canonical names (case-insensitive)..."
    duplicates = Ingredient.select("LOWER(canonical_name) as name, COUNT(*) as count")
                          .group("LOWER(canonical_name)")
                          .having("COUNT(*) > 1")
    if duplicates.any?
      puts "  Found #{duplicates.size} duplicate canonical names:"
      duplicates.each { |d| puts "    - '#{d.name}' (#{d.count} times)" }
    else
      puts "  No duplicate canonical names found."
    end

    puts "\n2. Checking for overlapping aliases..."
    overlapping = IngredientAlias.select("LOWER(alias) as name, COUNT(DISTINCT ingredient_id) as count")
                                 .group("LOWER(alias)")
                                 .having("COUNT(DISTINCT ingredient_id) > 1")
    if overlapping.any?
      puts "  Found #{overlapping.size} aliases pointing to multiple ingredients:"
      overlapping.first(10).each do |a|
        ingredients = IngredientAlias.where("LOWER(alias) = ?", a.name)
                                     .includes(:ingredient)
                                     .map { |ia| ia.ingredient.canonical_name }
        puts "    - '#{a.name}' -> [#{ingredients.join(', ')}]"
      end
    else
      puts "  No overlapping aliases found."
    end

    puts "\n3. Checking for missing nutrition data..."
    missing_nutrition = Ingredient.left_joins(:nutrition)
                                  .where(ingredient_nutritions: { id: nil })
                                  .count
    puts "  #{missing_nutrition} ingredients without nutrition data."

    puts "\n4. Checking nutrition data ranges..."
    suspicious = IngredientNutrition.where("calories > 900 OR calories < 0")
                                    .or(IngredientNutrition.where("protein_g > 100 OR protein_g < 0"))
                                    .or(IngredientNutrition.where("carbs_g > 100 OR carbs_g < 0"))
                                    .or(IngredientNutrition.where("fat_g > 100 OR fat_g < 0"))
                                    .includes(:ingredient)
    if suspicious.any?
      puts "  Found #{suspicious.size} entries with suspicious nutrition values:"
      suspicious.first(5).each do |n|
        puts "    - #{n.ingredient.canonical_name}: cal=#{n.calories}, prot=#{n.protein_g}g, carb=#{n.carbs_g}g, fat=#{n.fat_g}g"
      end
    else
      puts "  All nutrition values in normal ranges."
    end

    puts "\n5. Summary..."
    puts "  Total ingredients: #{Ingredient.count}"
    puts "  Total aliases: #{IngredientAlias.count}"
    puts "  Total unit conversions: #{IngredientUnitConversion.count}"
    puts "  Avg aliases per ingredient: #{(IngredientAlias.count.to_f / [Ingredient.count, 1].max).round(1)}"

    puts "\n" + "=" * 50
    puts "Audit complete!"
  end

  desc "Export all ingredients to data/ingredients.json"
  task export: :environment do
    output_path = Rails.root.join('data', 'ingredients.json')

    puts "Exporting ingredients to #{output_path}..."

    ingredients = Ingredient.includes(:nutrition, :aliases, :unit_conversions => :unit).all

    data = {
      'exported_at' => Time.current.iso8601,
      'count' => ingredients.size,
      'ingredients' => ingredients.map do |ing|
        entry = {
          'canonical_name' => ing.canonical_name,
          'category' => ing.category
        }

        if ing.nutrition
          entry['per_100g'] = {
            'calories' => ing.nutrition.calories,
            'protein_g' => ing.nutrition.protein_g,
            'carbs_g' => ing.nutrition.carbs_g,
            'fat_g' => ing.nutrition.fat_g,
            'fiber_g' => ing.nutrition.fiber_g
          }
        end

        if ing.aliases.any?
          entry['aliases'] = ing.aliases.map do |a|
            { 'alias' => a.alias, 'language' => a.language, 'type' => a.alias_type }
          end
        end

        if ing.unit_conversions.any?
          entry['common_units'] = ing.unit_conversions.map do |uc|
            { 'unit' => uc.unit.canonical_name, 'grams' => uc.grams }
          end
        end

        entry
      end
    }

    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, JSON.pretty_generate(data))

    puts "Exported #{ingredients.size} ingredients"
    puts "  With aliases: #{ingredients.count { |i| i.aliases.any? }}"
    puts "  With nutrition: #{ingredients.count { |i| i.nutrition.present? }}"
    puts "  With unit conversions: #{ingredients.count { |i| i.unit_conversions.any? }}"
    puts "\nFile saved to: #{output_path}"
  end
end
