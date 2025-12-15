require 'csv'

namespace :ingredients do
  desc "Export ingredients to CSV files for seeding"
  task export: :environment do
    data_dir = Rails.root.join('db', 'seeds', 'data')
    FileUtils.mkdir_p(data_dir)

    puts "Exporting ingredients..."

    CSV.open(data_dir.join('ingredients.csv'), 'w') do |csv|
      csv << %w[canonical_name category]
      Ingredient.order(:canonical_name).each do |ing|
        csv << [ing.canonical_name, ing.category]
      end
    end
    puts "  ingredients.csv: #{Ingredient.count} rows"

    CSV.open(data_dir.join('ingredient_nutrition.csv'), 'w') do |csv|
      csv << %w[ingredient_canonical_name calories protein_g carbs_g fat_g fiber_g data_source confidence_score]
      IngredientNutrition.includes(:ingredient).find_each do |n|
        csv << [
          n.ingredient.canonical_name,
          n.calories,
          n.protein_g,
          n.carbs_g,
          n.fat_g,
          n.fiber_g,
          n.data_source,
          n.confidence_score
        ]
      end
    end
    puts "  ingredient_nutrition.csv: #{IngredientNutrition.count} rows"

    CSV.open(data_dir.join('ingredient_aliases.csv'), 'w') do |csv|
      csv << %w[ingredient_canonical_name alias language alias_type]
      IngredientAlias.includes(:ingredient).find_each do |a|
        csv << [
          a.ingredient.canonical_name,
          a.alias,
          a.language,
          a.alias_type
        ]
      end
    end
    puts "  ingredient_aliases.csv: #{IngredientAlias.count} rows"

    CSV.open(data_dir.join('ingredient_unit_conversions.csv'), 'w') do |csv|
      csv << %w[ingredient_canonical_name unit_canonical_name grams]
      IngredientUnitConversion.includes(:ingredient, :unit).find_each do |c|
        csv << [
          c.ingredient.canonical_name,
          c.unit.canonical_name,
          c.grams
        ]
      end
    end
    puts "  ingredient_unit_conversions.csv: #{IngredientUnitConversion.count} rows"

    puts "\nExport complete! Files saved to #{data_dir}"
  end
end
