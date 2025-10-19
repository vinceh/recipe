namespace :nutrition do
  desc "Seed common ingredient nutrition data from Nutritionix API"
  task seed_common_ingredients: :environment do
    puts "🌱 Seeding common ingredient nutrition data..."

    # Most common ingredients across cuisines
    common_ingredients = [
      # Proteins
      "chicken breast", "ground beef", "salmon", "eggs", "tofu",
      "bacon", "pork chop", "shrimp", "tuna", "turkey breast",

      # Vegetables
      "tomato", "onion", "garlic", "carrot", "broccoli",
      "spinach", "bell pepper", "potato", "sweet potato", "lettuce",
      "cucumber", "celery", "mushroom", "zucchini", "cauliflower",
      "green beans", "peas", "corn", "cabbage", "eggplant",

      # Fruits
      "apple", "banana", "lemon", "lime", "orange",
      "strawberry", "blueberry", "avocado", "mango", "pineapple",

      # Grains & Starches
      "white rice", "brown rice", "pasta", "bread", "flour",
      "oats", "quinoa", "couscous", "tortilla", "noodles",

      # Dairy
      "milk", "butter", "cheese", "cream", "yogurt",
      "mozzarella", "parmesan", "cheddar cheese", "sour cream", "cream cheese",

      # Oils & Fats
      "olive oil", "vegetable oil", "coconut oil", "sesame oil", "canola oil",

      # Condiments & Sauces
      "soy sauce", "salt", "pepper", "sugar", "honey",
      "vinegar", "mayonnaise", "ketchup", "mustard", "hot sauce",

      # Spices & Herbs
      "basil", "oregano", "thyme", "rosemary", "cilantro",
      "parsley", "cumin", "paprika", "cinnamon", "ginger",

      # Legumes & Nuts
      "black beans", "chickpeas", "lentils", "kidney beans", "peanut butter",
      "almonds", "walnuts", "cashews", "peanuts", "pecans",

      # Asian Ingredients
      "soy sauce", "fish sauce", "oyster sauce", "sesame seeds", "miso paste",
      "rice vinegar", "seaweed", "kimchi", "gochujang", "sriracha",

      # Baking
      "baking powder", "baking soda", "vanilla extract", "cocoa powder", "chocolate chips",
      "yeast", "powdered sugar", "brown sugar", "cornstarch", "gelatin"
    ]

    service = NutritionLookupService.new
    successful = 0
    failed = []
    skipped = 0

    common_ingredients.each_with_index do |ingredient_name, index|
      print "\r[#{index + 1}/#{common_ingredients.length}] Processing: #{ingredient_name.ljust(30)}"

      # Check if already exists
      normalized = service.send(:normalize_ingredient_name, ingredient_name)
      if Ingredient.find_by(canonical_name: normalized)
        skipped += 1
        next
      end

      begin
        # This will fetch from Nutritionix and store in database
        service.lookup_ingredient(ingredient_name, 'en')
        successful += 1

        # Rate limiting - Nutritionix allows 10 requests/second on paid tier
        # Being conservative with 5/second to avoid hitting limits
        sleep 0.2
      rescue StandardError => e
        failed << { ingredient: ingredient_name, error: e.message }
      end
    end

    puts "\n\n✅ Seeding complete!"
    puts "   Successful: #{successful}"
    puts "   Skipped (already exist): #{skipped}"
    puts "   Failed: #{failed.length}"

    if failed.any?
      puts "\n❌ Failed ingredients:"
      failed.each do |f|
        puts "   - #{f[:ingredient]}: #{f[:error]}"
      end
    end

    # Summary stats
    total_ingredients = Ingredient.count
    with_nutrition = Ingredient.joins(:nutrition).count
    coverage = total_ingredients > 0 ? (with_nutrition.to_f / total_ingredients * 100).round(1) : 0

    puts "\n📊 Database Statistics:"
    puts "   Total ingredients: #{total_ingredients}"
    puts "   With nutrition data: #{with_nutrition}"
    puts "   Coverage: #{coverage}%"
  end

  desc "Show nutrition database statistics"
  task stats: :environment do
    puts "📊 Nutrition Database Statistics\n\n"

    total = Ingredient.count
    with_nutrition = Ingredient.joins(:nutrition).count
    coverage = total > 0 ? (with_nutrition.to_f / total * 100).round(1) : 0

    puts "Total Ingredients: #{total}"
    puts "With Nutrition Data: #{with_nutrition}"
    puts "Coverage: #{coverage}%\n\n"

    # Data sources breakdown
    if with_nutrition > 0
      sources = IngredientNutrition.group(:data_source).count
      puts "Data Sources:"
      sources.each do |source, count|
        percentage = (count.to_f / with_nutrition * 100).round(1)
        puts "  #{source&.capitalize || 'Unknown'}: #{count} (#{percentage}%)"
      end
      puts "\n"
    end

    # Confidence scores
    avg_confidence = IngredientNutrition.average(:confidence_score)
    puts "Average Confidence Score: #{avg_confidence&.round(2) || 'N/A'}\n\n"

    # Recent additions
    recent = Ingredient.includes(:nutrition).order(created_at: :desc).limit(5)
    if recent.any?
      puts "Recently Added (last 5):"
      recent.each do |ing|
        source = ing.nutrition&.data_source || 'no data'
        puts "  - #{ing.canonical_name} (#{source})"
      end
    end
  end
end
