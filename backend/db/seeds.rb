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

# =============================================================================
# DATA REFERENCE TRANSLATIONS
# =============================================================================
puts "\n🌐 Seeding data reference translations..."
load Rails.root.join('db/seeds/02_data_reference_translations_data.rb')
apply_data_reference_translations

puts "\n" + "="*60
puts "✨ Database seeding complete!"
puts "="*60
puts "📊 Summary:"
puts "   • Dietary Tags: #{DataReference.dietary_tags.count}"
puts "   • Cuisines: #{DataReference.cuisines.count}"
puts "   • Recipes: #{Recipe.count}"
puts "   • AI Prompts: #{AiPrompt.count}"
puts "   • Admin Users: #{User.admin.count}"
puts "="*60
