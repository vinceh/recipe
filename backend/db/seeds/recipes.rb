# Comprehensive Seed Data for Normalized Recipe Schema
# Tests ALL fields to ensure every field works correctly

puts "🍳 Seeding recipes with comprehensive field coverage..."

# Helper function to find or create equipment
def find_or_create_equipment(name)
  Equipment.find_or_create_by!(canonical_name: name)
end

# ============================================================================
# RECIPE 1: Oyakodon (Fixed Servings, Multiple Groups)
# ============================================================================
oyakodon = Recipe.create!(
  name: "Oyakodon (Chicken and Egg Rice Bowl)",
  source_language: "en",
  source_url: "https://www.justonecookbook.com/oyakodon/",
  servings_original: 2,
  servings_min: 2,
  servings_max: 2,
  prep_minutes: 10,
  cook_minutes: 15,
  total_minutes: 25,
  admin_notes: "Classic Japanese comfort food. Tests fixed servings.",
  requires_precision: false
)

# Ingredient groups
ig1 = oyakodon.ingredient_groups.create!(name: "Main Ingredients", position: 1)
ig1.recipe_ingredients.create!(name: "chicken thigh", amount: 300, unit: "g", preparation_notes: "boneless, cut into bite-size pieces", position: 1)
ig1.recipe_ingredients.create!(name: "eggs", amount: 4, unit: "whole", preparation_notes: "beaten", position: 2)
ig1.recipe_ingredients.create!(name: "onion", amount: 1, unit: "whole", preparation_notes: "thinly sliced", position: 3)
ig1.recipe_ingredients.create!(name: "steamed rice", amount: 2, unit: "cups", preparation_notes: "freshly cooked", position: 4)

ig2 = oyakodon.ingredient_groups.create!(name: "Sauce", position: 2)
ig2.recipe_ingredients.create!(name: "dashi stock", amount: 200, unit: "ml", preparation_notes: nil, position: 1)
ig2.recipe_ingredients.create!(name: "soy sauce", amount: 2, unit: "tbsp", preparation_notes: nil, position: 2)
ig2.recipe_ingredients.create!(name: "mirin", amount: 2, unit: "tbsp", preparation_notes: nil, position: 3)

# Steps
(1..7).each { |i| oyakodon.recipe_steps.create!(step_number: i, timing_minutes: [5, 2, 3, 5, 2, 2, 1][i-1]) }

# Equipment
frying_pan = find_or_create_equipment("Frying Pan")
small_bowl = find_or_create_equipment("Small Bowl")
spatula = find_or_create_equipment("Spatula")
oyakodon.recipe_equipment.create!(equipment: frying_pan, optional: false)
oyakodon.recipe_equipment.create!(equipment: small_bowl, optional: false)
oyakodon.recipe_equipment.create!(equipment: spatula, optional: false)

# Nutrition
oyakodon.create_recipe_nutrition!(calories: 450, protein_g: 35, carbs_g: 45, fat_g: 12, fiber_g: 2, sodium_mg: 800, sugar_g: 8)

# References
dietary_tag = DataReference.find_or_create_by(reference_type: "dietary_tag", key: "high-protein") do |ref|
  ref.display_name = "High-Protein"
end
oyakodon.recipe_dietary_tags.create!(data_reference: dietary_tag)

dish_type = DataReference.find_or_create_by(reference_type: "dish_type", key: "main-course") do |ref|
  ref.display_name = "Main Course"
end
oyakodon.recipe_dish_types.create!(data_reference: dish_type)

cuisine = DataReference.find_or_create_by(reference_type: "cuisine", key: "japanese") do |ref|
  ref.display_name = "Japanese"
end
oyakodon.recipe_cuisines.create!(data_reference: cuisine)

# Aliases
oyakodon.recipe_aliases.create!(alias_name: "Oyako-don", language: "en")
oyakodon.recipe_aliases.create!(alias_name: "親子丼", language: "ja")

puts "   ✅ Recipe 1: Oyakodon"

# ============================================================================
# RECIPE 2: Vegetable Stir Fry (Optional Ingredients, Variable Servings)
# ============================================================================
stir_fry = Recipe.create!(
  name: "Simple Vegetable Stir Fry",
  source_language: "en",
  source_url: "https://example.com/stir-fry",
  servings_original: 4,
  servings_min: 2,
  servings_max: 6,
  prep_minutes: 15,
  cook_minutes: 10,
  total_minutes: 25,
  admin_notes: "Tests optional ingredients and variable servings.",
  requires_precision: false
)

ig1 = stir_fry.ingredient_groups.create!(name: "Vegetables", position: 1)
ig1.recipe_ingredients.create!(name: "bell pepper", amount: 2, unit: "whole", preparation_notes: "sliced", position: 1)
ig1.recipe_ingredients.create!(name: "broccoli", amount: 2, unit: "cups", preparation_notes: "florets", position: 2)
ig1.recipe_ingredients.create!(name: "mushrooms", amount: 1, unit: "cup", preparation_notes: "sliced", optional: true, position: 3)

ig2 = stir_fry.ingredient_groups.create!(name: "Sauce", position: 2)
ig2.recipe_ingredients.create!(name: "soy sauce", amount: 3, unit: "tbsp", preparation_notes: nil, position: 1)
ig2.recipe_ingredients.create!(name: "sesame oil", amount: 1, unit: "tbsp", preparation_notes: nil, position: 2)

(1..5).each { |i| stir_fry.recipe_steps.create!(step_number: i, timing_minutes: i * 2) }

wok = find_or_create_equipment("Wok")
wooden_spoon = find_or_create_equipment("Wooden Spoon")
stir_fry.recipe_equipment.create!(equipment: wok, optional: false)
stir_fry.recipe_equipment.create!(equipment: wooden_spoon, optional: false)

dietary_tag = DataReference.find_or_create_by(reference_type: "dietary_tag", key: "vegan") do |ref|
  ref.display_name = "Vegan"
end
stir_fry.recipe_dietary_tags.create!(data_reference: dietary_tag)

stir_fry.recipe_aliases.create!(alias_name: "Quick Veggies", language: "en")
stir_fry.recipe_aliases.create!(alias_name: "ผัดไทย", language: "th")

puts "   ✅ Recipe 2: Vegetable Stir Fry"

# ============================================================================
# RECIPES 3-12: Additional Recipes (Simplified)
# ============================================================================

# Recipe 3: Spaghetti Aglio e Olio
pasta = Recipe.create!(
  name: "Spaghetti Aglio e Olio",
  source_language: "en",
  servings_original: 2,
  servings_min: 2,
  servings_max: 4,
  prep_minutes: 5,
  cook_minutes: 15,
  total_minutes: 20
)
ig = pasta.ingredient_groups.create!(name: "Ingredients", position: 1)
ig.recipe_ingredients.create!(name: "spaghetti", amount: 400, unit: "g", position: 1)
ig.recipe_ingredients.create!(name: "garlic", amount: 6, unit: "cloves", preparation_notes: "thinly sliced", position: 2)
(1..5).each { |i| pasta.recipe_steps.create!(step_number: i, timing_minutes: 5) }
pasta.recipe_equipment.create!(equipment: find_or_create_equipment("Large Pot"))
pasta.recipe_aliases.create!(alias_name: "Aglio e Olio", language: "en")
puts "   ✅ Recipe 3: Spaghetti Aglio e Olio"

# Recipe 4: Tom Yum Soup
tom_yum = Recipe.create!(
  name: "Tom Yum Soup",
  source_language: "en",
  servings_original: 4,
  servings_min: 4,
  servings_max: 6,
  prep_minutes: 15,
  cook_minutes: 20,
  total_minutes: 35
)
ig = tom_yum.ingredient_groups.create!(name: "Broth", position: 1)
ig.recipe_ingredients.create!(name: "chicken stock", amount: 1.5, unit: "liters", position: 1)
(1..5).each { |i| tom_yum.recipe_steps.create!(step_number: i, timing_minutes: 5) }
tom_yum.create_recipe_nutrition!(calories: 220, protein_g: 28, carbs_g: 12, fat_g: 6)
tom_yum.recipe_aliases.create!(alias_name: "Thai Soup", language: "en")
tom_yum.recipe_aliases.create!(alias_name: "ต้มยำ", language: "th")
puts "   ✅ Recipe 4: Tom Yum Soup"

# Recipe 5: Shakshuka
shakshuka = Recipe.create!(
  name: "Shakshuka",
  source_language: "en",
  servings_original: 4,
  servings_min: 2,
  servings_max: 4,
  prep_minutes: 15,
  cook_minutes: 20,
  total_minutes: 35
)
ig = shakshuka.ingredient_groups.create!(name: "Sauce", position: 1)
ig.recipe_ingredients.create!(name: "tomatoes", amount: 800, unit: "g", preparation_notes: "canned", position: 1)
(1..4).each { |i| shakshuka.recipe_steps.create!(step_number: i, timing_minutes: 5) }
lid = find_or_create_equipment("Lid")
shakshuka.recipe_equipment.create!(equipment: find_or_create_equipment("Large Skillet"), optional: false)
shakshuka.recipe_equipment.create!(equipment: lid, optional: true)
shakshuka.create_recipe_nutrition!(calories: 280, protein_g: 14, carbs_g: 15, fat_g: 18)
puts "   ✅ Recipe 5: Shakshuka"

# Recipes 6-12: Quick recipes
[
  { name: "Pad Thai", servings: [2, 2, 4], groups: 3, steps: 5 },
  { name: "Margherita Pizza", servings: [2, 2, 4], groups: 2, steps: 8 },
  { name: "Kimchi Fried Rice", servings: [2, 2, 3], groups: 2, steps: 5 },
  { name: "Greek Salad", servings: [4, 2, 6], groups: 2, steps: 4 },
  { name: "Beef Tacos", servings: [4, 2, 6], groups: 3, steps: 5 },
  { name: "Minestrone Soup", servings: [6, 4, 8], groups: 3, steps: 6 },
  { name: "Chicken Nanban", servings: [4, 2, 6], groups: 2, steps: 6 }
].each_with_index do |data, idx|
  recipe = Recipe.create!(
    name: data[:name],
    source_language: "en",
    servings_original: data[:servings][0],
    servings_min: data[:servings][1],
    servings_max: data[:servings][2],
    prep_minutes: 15,
    cook_minutes: 15,
    total_minutes: 30
  )

  data[:groups].times do |g|
    ig = recipe.ingredient_groups.create!(name: "Group #{g+1}", position: g + 1)
    ig.recipe_ingredients.create!(name: "ingredient 1", amount: 100, unit: "g", position: 1)
  end

  data[:steps].times { |s| recipe.recipe_steps.create!(step_number: s + 1, timing_minutes: 5) }
  recipe.recipe_equipment.create!(equipment: find_or_create_equipment("Pan"))

  puts "   ✅ Recipe #{6+idx}: #{data[:name]}"
end

puts "\n✅ All 12 recipes created with comprehensive field coverage!"
puts "   • Ingredient Groups: 1-3 groups per recipe ✓"
puts "   • Servings: Fixed (Recipe 1) and variable (Recipes 2-12) ✓"
puts "   • Timing: All prep/cook/total minutes ✓"
puts "   • Steps: Multiple steps with timing ✓"
puts "   • Equipment: Required and optional ✓"
puts "   • References: Dietary tags, dish types, cuisines ✓"
puts "   • Aliases: Multiple languages ✓"
puts "   • Nutrition: Full data where created ✓"
puts "   • Optional Fields: Ingredients and equipment ✓"
