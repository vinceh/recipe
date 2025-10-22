# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

puts "🌱 Seeding database..."

# =============================================================================
# DIETARY TAGS (42 tags)
# =============================================================================
puts "\n📋 Seeding dietary tags..."

DIETARY_TAGS = {
  'vegetarian' => 'Vegetarian',
  'vegan' => 'Vegan',
  'pescatarian' => 'Pescatarian',
  'pork-free' => 'Pork-Free',
  'red-meat-free' => 'Red Meat-Free',
  'kosher' => 'Kosher',
  'halal' => 'Halal',
  'gluten-free' => 'Gluten-Free',
  'wheat-free' => 'Wheat-Free',
  'dairy-free' => 'Dairy-Free',
  'egg-free' => 'Egg-Free',
  'soy-free' => 'Soy-Free',
  'fish-free' => 'Fish-Free',
  'shellfish-free' => 'Shellfish-Free',
  'tree-nut-free' => 'Tree Nut-Free',
  'peanut-free' => 'Peanut-Free',
  'crustacean-free' => 'Crustacean-Free',
  'mollusk-free' => 'Mollusk-Free',
  'celery-free' => 'Celery-Free',
  'mustard-free' => 'Mustard-Free',
  'sesame-free' => 'Sesame-Free',
  'lupine-free' => 'Lupine-Free',
  'sulfite-free' => 'Sulfite-Free',
  'keto-friendly' => 'Keto-Friendly',
  'paleo' => 'Paleo',
  'mediterranean' => 'Mediterranean',
  'dash' => 'DASH',
  'low-fat-abs' => 'Low Fat',
  'low-sugar' => 'Low Sugar',
  'sugar-conscious' => 'Sugar Conscious',
  'low-carb' => 'Low Carb',
  'low-sodium' => 'Low Sodium',
  'kidney-friendly' => 'Kidney Friendly',
  'immuno-supportive' => 'Immuno-Supportive',
  'alcohol-free' => 'Alcohol-Free',
  'alcohol-cocktail' => 'Contains Alcohol',
  'no-oil-added' => 'No Oil Added',
  'fodmap-free' => 'FODMAP-Free',
  'whole30' => 'Whole30',
  'raw' => 'Raw Food'
}

DIETARY_TAGS.each_with_index do |(key, display_name), index|
  DataReference.find_or_create_by!(
    reference_type: 'dietary_tag',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.sort_order = index
    ref.active = true
  end
end

puts "   ✅ Created #{DIETARY_TAGS.count} dietary tags"

# =============================================================================
# DISH TYPES (16 types)
# =============================================================================
puts "\n🍽️  Seeding dish types..."

DISH_TYPES = {
  'biscuits-and-cookies' => 'Biscuits & Cookies',
  'bread' => 'Bread',
  'cereals' => 'Cereals',
  'condiments-and-sauces' => 'Condiments & Sauces',
  'desserts' => 'Desserts',
  'drinks' => 'Drinks',
  'main-course' => 'Main Course',
  'pancake' => 'Pancakes & Waffles',
  'preps' => 'Meal Prep',
  'preserve' => 'Preserves',
  'salad' => 'Salad',
  'sandwiches' => 'Sandwiches',
  'side-dish' => 'Side Dish',
  'soup' => 'Soup',
  'starter' => 'Starter',
  'sweets' => 'Sweets'
}

DISH_TYPES.each_with_index do |(key, display_name), index|
  DataReference.find_or_create_by!(
    reference_type: 'dish_type',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.sort_order = index
    ref.active = true
  end
end

puts "   ✅ Created #{DISH_TYPES.count} dish types"

# =============================================================================
# CUISINES (100+ cuisines)
# =============================================================================
puts "\n🌍 Seeding cuisines..."

CUISINES = {
  # Asian
  'japanese' => 'Japanese',
  'korean' => 'Korean',
  'chinese' => 'Chinese',
  'cantonese' => 'Cantonese',
  'sichuan' => 'Sichuan',
  'taiwanese' => 'Taiwanese',
  'thai' => 'Thai',
  'vietnamese' => 'Vietnamese',
  'filipino' => 'Filipino',
  'indonesian' => 'Indonesian',
  'malaysian' => 'Malaysian',
  'singaporean' => 'Singaporean',
  'indian' => 'Indian',
  'north-indian' => 'North Indian',
  'south-indian' => 'South Indian',
  'pakistani' => 'Pakistani',
  'bangladeshi' => 'Bangladeshi',
  'nepalese' => 'Nepalese',
  'sri-lankan' => 'Sri Lankan',
  'burmese' => 'Burmese',
  'cambodian' => 'Cambodian',
  'laotian' => 'Laotian',
  'mongolian' => 'Mongolian',
  # European
  'italian' => 'Italian',
  'french' => 'French',
  'spanish' => 'Spanish',
  'greek' => 'Greek',
  'portuguese' => 'Portuguese',
  'german' => 'German',
  'austrian' => 'Austrian',
  'swiss' => 'Swiss',
  'polish' => 'Polish',
  'russian' => 'Russian',
  'ukrainian' => 'Ukrainian',
  'hungarian' => 'Hungarian',
  'czech' => 'Czech',
  'scandinavian' => 'Scandinavian',
  'swedish' => 'Swedish',
  'norwegian' => 'Norwegian',
  'danish' => 'Danish',
  'finnish' => 'Finnish',
  'dutch' => 'Dutch',
  'belgian' => 'Belgian',
  'irish' => 'Irish',
  'scottish' => 'Scottish',
  'welsh' => 'Welsh',
  'british' => 'British',
  'turkish' => 'Turkish',
  'georgian' => 'Georgian',
  'armenian' => 'Armenian',
  # Middle Eastern & African
  'lebanese' => 'Lebanese',
  'syrian' => 'Syrian',
  'israeli' => 'Israeli',
  'persian' => 'Persian',
  'iraqi' => 'Iraqi',
  'moroccan' => 'Moroccan',
  'egyptian' => 'Egyptian',
  'tunisian' => 'Tunisian',
  'ethiopian' => 'Ethiopian',
  'south-african' => 'South African',
  'nigerian' => 'Nigerian',
  'kenyan' => 'Kenyan',
  # Latin American
  'mexican' => 'Mexican',
  'tex-mex' => 'Tex-Mex',
  'guatemalan' => 'Guatemalan',
  'salvadoran' => 'Salvadoran',
  'honduran' => 'Honduran',
  'nicaraguan' => 'Nicaraguan',
  'costa-rican' => 'Costa Rican',
  'panamanian' => 'Panamanian',
  'cuban' => 'Cuban',
  'puerto-rican' => 'Puerto Rican',
  'dominican' => 'Dominican',
  'colombian' => 'Colombian',
  'venezuelan' => 'Venezuelan',
  'ecuadorian' => 'Ecuadorian',
  'peruvian' => 'Peruvian',
  'bolivian' => 'Bolivian',
  'chilean' => 'Chilean',
  'argentinian' => 'Argentinian',
  'uruguayan' => 'Uruguayan',
  'paraguayan' => 'Paraguayan',
  'brazilian' => 'Brazilian',
  # North American & Caribbean
  'american' => 'American',
  'southern' => 'Southern (US)',
  'cajun' => 'Cajun',
  'creole' => 'Creole',
  'soul-food' => 'Soul Food',
  'caribbean' => 'Caribbean',
  'jamaican' => 'Jamaican',
  'haitian' => 'Haitian',
  'trinidadian' => 'Trinidadian',
  'barbadian' => 'Barbadian',
  # Fusion & Modern
  'fusion' => 'Fusion',
  'asian-fusion' => 'Asian Fusion',
  'mediterranean-fusion' => 'Mediterranean Fusion',
  'modern' => 'Modern',
  'nouvelle' => 'Nouvelle',
  'molecular' => 'Molecular Gastronomy'
}

CUISINES.each_with_index do |(key, display_name), index|
  DataReference.find_or_create_by!(
    reference_type: 'cuisine',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.sort_order = index
    ref.active = true
  end
end

puts "   ✅ Created #{CUISINES.count} cuisines"

# =============================================================================
# RECIPE TYPES (70+ types)
# =============================================================================
puts "\n👨‍🍳 Seeding recipe types..."

RECIPE_TYPES = {
  # Meal Categories
  'appetizer' => 'Appetizer',
  'breakfast' => 'Breakfast',
  'brunch' => 'Brunch',
  'lunch' => 'Lunch',
  'dinner' => 'Dinner',
  'snack' => 'Snack',
  'dessert' => 'Dessert',
  'beverage' => 'Beverage',
  # Cooking Methods
  'baking' => 'Baking',
  'grilled' => 'Grilled',
  'fried' => 'Fried',
  'roasted' => 'Roasted',
  'steamed' => 'Steamed',
  'raw' => 'Raw',
  'slow-cooked' => 'Slow Cooked',
  'instant-pot' => 'Instant Pot',
  'air-fried' => 'Air Fried',
  'sous-vide' => 'Sous Vide',
  'fermented' => 'Fermented',
  'stir-fry' => 'Stir Fry',
  'braised' => 'Braised',
  'sauteed' => 'Sautéed',
  'blanched' => 'Blanched',
  'poached' => 'Poached',
  # Dish Types
  'casserole' => 'Casserole',
  'stew' => 'Stew',
  'curry' => 'Curry',
  'pasta' => 'Pasta',
  'rice-bowl' => 'Rice Bowl',
  'noodles' => 'Noodles',
  'pizza' => 'Pizza',
  'sandwich' => 'Sandwich',
  'taco' => 'Taco',
  'burrito' => 'Burrito',
  'pie' => 'Pie',
  'tart' => 'Tart',
  'cake' => 'Cake',
  'cookies' => 'Cookies',
  'pastry' => 'Pastry',
  'pudding' => 'Pudding',
  'ice-cream' => 'Ice Cream',
  'candy' => 'Candy',
  # Protein Types
  'chicken' => 'Chicken',
  'beef' => 'Beef',
  'pork' => 'Pork',
  'lamb' => 'Lamb',
  'seafood' => 'Seafood',
  'fish' => 'Fish',
  'shellfish' => 'Shellfish',
  'vegetable-focused' => 'Vegetable-Focused',
  'legume-based' => 'Legume-Based',
  'tofu' => 'Tofu',
  'tempeh' => 'Tempeh',
  # Preparation Styles
  'one-pot' => 'One-Pot',
  'sheet-pan' => 'Sheet Pan',
  'meal-prep' => 'Meal Prep',
  'make-ahead' => 'Make-Ahead',
  'freezer-friendly' => 'Freezer-Friendly',
  'no-cook' => 'No Cook',
  'pressure-cooker' => 'Pressure Cooker',
  # Speed & Difficulty
  'quick-weeknight' => 'Quick Weeknight',
  'under-30-min' => 'Under 30 Minutes',
  'under-15-min' => 'Under 15 Minutes',
  'weekend-project' => 'Weekend Project',
  'beginner-friendly' => 'Beginner-Friendly',
  'intermediate' => 'Intermediate',
  'advanced' => 'Advanced',
  # Occasion
  'comfort-food' => 'Comfort Food',
  'holiday' => 'Holiday',
  'party' => 'Party',
  'date-night' => 'Date Night',
  'family-friendly' => 'Family-Friendly',
  'kid-friendly' => 'Kid-Friendly',
  'batch-cooking' => 'Batch Cooking'
}

RECIPE_TYPES.each_with_index do |(key, display_name), index|
  DataReference.find_or_create_by!(
    reference_type: 'recipe_type',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.sort_order = index
    ref.active = true
  end
end

puts "   ✅ Created #{RECIPE_TYPES.count} recipe types"

# =============================================================================
# ADMIN USER
# =============================================================================
puts "\n👤 Creating admin user..."

admin = User.find_or_create_by!(email: 'admin@ember.app') do |user|
  user.password = '123456'
  user.password_confirmation = '123456'
  user.role = :admin
  user.preferred_language = 'en'
end

puts "   ✅ Admin user created: #{admin.email} (password: 123456)"

# =============================================================================
# AI PROMPTS
# =============================================================================
puts "\n🤖 Seeding AI prompts..."

# Step Variant Prompts
AiPrompt.find_or_create_by!(prompt_key: 'step_variant_easier_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'step_variants'
  p.description = 'System prompt for generating easier step variants'
  p.variables = []
  p.active = true
  p.prompt_text = <<~PROMPT
    You are a professional cooking instructor specializing in making recipes accessible to all skill levels.
    Your goal is to rewrite cooking instructions to be easier while maintaining the same end result.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'step_variant_easier_user') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'step_variants'
  p.description = 'User prompt for generating easier step variants'
  p.variables = ['recipe_name', 'cuisines', 'recipe_types', 'step_order', 'step_title',
                 'original_instruction', 'equipment', 'ingredients']
  p.active = true
  p.prompt_text = <<~PROMPT
    Recipe Name: {{recipe_name}}
    Cuisine: {{cuisines}}
    Recipe Type: {{recipe_types}}

    Step {{step_order}}: {{step_title}}

    Original Instruction:
    {{original_instruction}}

    Equipment Required: {{equipment}}
    Ingredients Used in This Step: {{ingredients}}

    ---

    Rewrite this instruction to be EASIER for:
    - Someone with limited cooking experience
    - Someone with physical limitations (shaky hands, weak grip, poor vision)
    - Someone who needs more guidance and reassurance

    Guidelines:
    1. Break down complex actions into smaller, sequential parts
    2. Replace technical terms with everyday language
    3. Add time estimates ("about 2 minutes", "30 seconds")
    4. Include visual/sensory cues ("when you see bubbles", "feels like soft butter")
    5. Add reassuring language ("It's okay if...", "Don't worry about...")
    6. Keep the same end goal - result should be identical
    7. Maintain food safety

    Output Format (JSON):
    {
      "text": "The rewritten easier instruction"
    }
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'step_variant_no_equipment_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'step_variants'
  p.description = 'System prompt for generating no-equipment step variants'
  p.variables = []
  p.active = true
  p.prompt_text = <<~PROMPT
    You are a creative cooking expert who helps people cook without specialized equipment.
    Your goal is to suggest alternative methods using common household items.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'step_variant_no_equipment_user') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'step_variants'
  p.description = 'User prompt for generating no-equipment step variants'
  p.variables = ['recipe_name', 'step_order', 'step_title', 'original_instruction', 'equipment']
  p.active = true
  p.prompt_text = <<~PROMPT
    Recipe Name: {{recipe_name}}
    Step {{step_order}}: {{step_title}}

    Original Instruction:
    {{original_instruction}}

    Equipment Required: {{equipment}}

    ---

    Suggest alternatives using COMMON HOUSEHOLD ITEMS for any specialized equipment.

    Guidelines:
    1. Chopsticks → fork → knife → hands (in order of preference)
    2. Whisk → fork vigorously
    3. Food processor → knife and cutting board
    4. Stand mixer → hand whisk or wooden spoon
    5. Rice cooker → pot on stove
    6. Be honest about tradeoffs ("takes longer", "requires more effort")
    7. If no equipment alternative exists, explain the workaround clearly

    Output Format (JSON):
    {
      "text": "The instruction with household item alternatives"
    }
  PROMPT
end

puts "   ✅ Created #{AiPrompt.where(feature_area: 'step_variants').count} step variant prompts"

# Translation Prompts
AiPrompt.find_or_create_by!(prompt_key: 'recipe_translation_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'translation'
  p.description = 'System prompt for recipe translation'
  p.variables = []
  p.active = true
  p.prompt_text = <<~PROMPT
    You are a professional translator specializing in recipe translation with deep cultural knowledge of food terminology across languages.
    Your goal is to translate recipes accurately while respecting cultural context and culinary authenticity.

    Key principles:
    1. For ingredients native to the target language's culture, use the authentic native term without explanation
    2. For foreign ingredients, provide transliteration plus a brief explanation in the target language
    3. Translate cooking techniques using culturally appropriate terminology
    4. Preserve the exact JSON structure - only translate text values
    5. Keep all IDs, amounts, units, and timing values unchanged
    6. Maintain food safety and cooking accuracy
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_translation_user') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'translation'
  p.description = 'User prompt for recipe translation'
  p.variables = ['target_language', 'recipe_json']
  p.active = true
  p.prompt_text = <<~PROMPT
    Translate this recipe to {{target_language}}.

    Original Recipe (JSON):
    {{recipe_json}}

    Requirements:
    1. Translate all text fields: name, ingredient names, step instructions, equipment names
    2. Keep ALL numeric values, IDs, and units UNCHANGED
    3. Preserve the exact JSON structure
    4. Apply cultural sensitivity:
       - Native ingredients → use native term only
       - Foreign ingredients → transliteration + explanation
    5. Use proper culinary terminology for the target language

    Output Format:
    Return ONLY the translated JSON with the same structure as the input.

    ```json
    {
      "name": "translated name",
      "ingredient_groups": [...],
      "steps": [...]
    }
    ```
  PROMPT
end

puts "   ✅ Created #{AiPrompt.where(feature_area: 'translation').count} translation prompts"

# =============================================================================
# SUMMARY
# =============================================================================
# =============================================================================
# RECIPES
# =============================================================================
puts "\n🍽️  Seeding recipes..."
load Rails.root.join('db/seeds/recipes.rb')

puts "\n" + "="*60
puts "✨ Database seeding complete!"
puts "="*60
puts "📊 Summary:"
puts "   • Dietary Tags: #{DataReference.dietary_tags.count}"
puts "   • Dish Types: #{DataReference.dish_types.count}"
puts "   • Cuisines: #{DataReference.cuisines.count}"
puts "   • Recipe Types: #{DataReference.recipe_types.count}"
puts "   • Recipes: #{Recipe.count}"
puts "   • AI Prompts: #{AiPrompt.count}"
puts "   • Admin Users: #{User.admin.count}"
puts "="*60
