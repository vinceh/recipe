namespace :ingredients do
  desc "Import unit conversions from batch JSON files"
  task import_conversions: :environment do
    require "json"

    # Map AI-generated unit names to canonical unit names in database
    UNIT_MAPPING = {
      "gram" => "g",
      "grams" => "g",
      "g" => "g",
      "kg" => "kg",
      "kilogram" => "kg",
      "liter" => "l",
      "litre" => "l",
      "ml" => "ml",
      "milliliter" => "ml",
      "tsp" => "tsp",
      "teaspoon" => "tsp",
      "tbsp" => "tbsp",
      "tablespoon" => "tbsp",
      "cup" => "cup",
      "cups" => "cup",
      "piece" => "piece",
      "pieces" => "piece",
      "whole" => "whole",
      "slice" => "slice",
      "slices" => "slice",
      "clove" => "clove",
      "cloves" => "clove",
      "can" => "can",
      "jar" => "jar",
      "jars" => "jar",
      "bunch" => "bunch",
      "sprig" => "sprig",
      "sprigs" => "sprig",
      "leaf" => "leaf",
      "leaves" => "leaf",
      "head" => "head",
      "stalk" => "stalk",
      "stalks" => "stalk",
      "packet" => "package",
      "packets" => "package",
      "package" => "package",
      "pinch" => "pinch",
      "dash" => "dash",
      "drop" => "drop",
      "drops" => "drop",
      "stick" => "stick",
      "sticks" => "stick",
      "block" => "block",
      "blocks" => "block",
      "sheet" => "sheet",
      "sheets" => "sheet",
      "strip" => "strip",
      "strips" => "strip",
      "fillet" => "fillet",
      "handful" => "handful",
      "pound" => "lb",
      "lb" => "lb",
      "ounce" => "oz",
      "oz" => "oz",
      "pod" => "pod",
      "pods" => "pod",
      "cube" => "cube",
      "cubes" => "cube",
      "dozen" => "dozen",
      "dozens" => "dozen"
    }.freeze

    conversions_dir = Rails.root.join("tmp/conversions")

    unless Dir.exist?(conversions_dir)
      puts "❌ Conversions directory not found: #{conversions_dir}"
      exit 1
    end

    # Pre-load unit mapping
    units_by_name = Unit.all.index_by(&:canonical_name)
    puts "📦 Loaded #{units_by_name.size} units from database"

    # Track stats
    stats = { created: 0, skipped: 0, errors: 0, unknown_units: Set.new }

    # Process each batch file
    Dir.glob(conversions_dir.join("batch_*.json")).sort_by { |f| f[/batch_(\d+)/, 1].to_i }.each do |file|
      batch_num = File.basename(file, ".json")
      print "Processing #{batch_num}..."

      begin
        data = JSON.parse(File.read(file))
        batch_created = 0

        data.each do |ingredient_data|
          ingredient_id = ingredient_data["ingredient_id"]

          next unless Ingredient.exists?(ingredient_id)

          ingredient_data["conversions"]&.each do |conversion|
            unit_name = conversion["unit"]&.downcase&.strip
            grams = conversion["grams"]

            next unless unit_name && grams && grams > 0

            # Map to canonical unit name
            canonical_name = UNIT_MAPPING[unit_name]

            unless canonical_name
              stats[:unknown_units].add(unit_name)
              next
            end

            unit = units_by_name[canonical_name]

            unless unit
              stats[:unknown_units].add("#{unit_name} (mapped to #{canonical_name})")
              next
            end

            # Create or update conversion
            conversion_record = IngredientUnitConversion.find_or_initialize_by(
              ingredient_id: ingredient_id,
              unit_id: unit.id
            )

            if conversion_record.new_record?
              conversion_record.grams = grams
              conversion_record.save!
              stats[:created] += 1
              batch_created += 1
            else
              stats[:skipped] += 1
            end
          end
        end

        puts " #{batch_created} created"
      rescue => e
        puts " ERROR: #{e.message}"
        stats[:errors] += 1
      end
    end

    puts "\n📊 Import Summary:"
    puts "   Created: #{stats[:created]}"
    puts "   Skipped (existing): #{stats[:skipped]}"
    puts "   Errors: #{stats[:errors]}"

    if stats[:unknown_units].any?
      puts "\n⚠️  Unknown units (not imported):"
      stats[:unknown_units].each { |u| puts "   - #{u}" }
    end

    puts "\n✅ Done! Total conversions in DB: #{IngredientUnitConversion.count}"
  end
end
