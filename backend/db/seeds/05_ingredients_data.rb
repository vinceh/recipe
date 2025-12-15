require 'csv'

def seed_ingredients
  data_dir = Rails.root.join('db', 'seeds', 'data')

  unless File.exist?(data_dir.join('ingredients.csv'))
    puts "   ⚠️  No ingredient CSV files found in #{data_dir}"
    puts "   Run 'rails ingredients:export' to generate them"
    return
  end

  puts "   Loading ingredients from CSV..."

  ingredient_cache = {}
  unit_cache = Unit.all.index_by(&:canonical_name)

  CSV.foreach(data_dir.join('ingredients.csv'), headers: true) do |row|
    ingredient = Ingredient.find_or_create_by!(canonical_name: row['canonical_name']) do |i|
      i.category = row['category']
    end
    ingredient_cache[row['canonical_name']] = ingredient
  end
  puts "   ✅ Loaded #{ingredient_cache.size} ingredients"

  if File.exist?(data_dir.join('ingredient_nutrition.csv'))
    nutrition_count = 0
    CSV.foreach(data_dir.join('ingredient_nutrition.csv'), headers: true) do |row|
      ingredient = ingredient_cache[row['ingredient_canonical_name']]
      next unless ingredient

      IngredientNutrition.find_or_create_by!(ingredient: ingredient) do |n|
        n.calories = row['calories']
        n.protein_g = row['protein_g']
        n.carbs_g = row['carbs_g']
        n.fat_g = row['fat_g']
        n.fiber_g = row['fiber_g']
        n.data_source = row['data_source']
        n.confidence_score = row['confidence_score']
      end
      nutrition_count += 1
    end
    puts "   ✅ Loaded #{nutrition_count} nutrition records"
  end

  if File.exist?(data_dir.join('ingredient_aliases.csv'))
    alias_count = 0
    CSV.foreach(data_dir.join('ingredient_aliases.csv'), headers: true) do |row|
      ingredient = ingredient_cache[row['ingredient_canonical_name']]
      next unless ingredient

      IngredientAlias.find_or_create_by!(
        ingredient: ingredient,
        alias: row['alias'],
        language: row['language']
      ) do |a|
        a.alias_type = row['alias_type']
      end
      alias_count += 1
    end
    puts "   ✅ Loaded #{alias_count} aliases"
  end

  if File.exist?(data_dir.join('ingredient_unit_conversions.csv'))
    conversion_count = 0
    CSV.foreach(data_dir.join('ingredient_unit_conversions.csv'), headers: true) do |row|
      ingredient = ingredient_cache[row['ingredient_canonical_name']]
      unit = unit_cache[row['unit_canonical_name']]
      next unless ingredient && unit

      IngredientUnitConversion.find_or_create_by!(
        ingredient: ingredient,
        unit: unit
      ) do |c|
        c.grams = row['grams']
      end
      conversion_count += 1
    end
    puts "   ✅ Loaded #{conversion_count} unit conversions"
  end
end
