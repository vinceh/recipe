# AI Prompts for Recipe Parser Service

# Text Block Parsing Prompts
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_text_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe from text block'
  prompt.prompt_text = <<~PROMPT
    You are a recipe data extraction expert. Your task is to parse unstructured recipe text into a structured JSON format.

    Extract all available information and structure it according to the schema below. If information is missing, use reasonable defaults or omit optional fields.

    **Output Format:**
    Return ONLY valid JSON in the following structure (no additional text or explanation):

    ```json
    {
      "name": "Recipe Name",
      "language": "en",
      "servings": {
        "original": 4,
        "min": 2,
        "max": 8
      },
      "timing": {
        "prep_minutes": 15,
        "cook_minutes": 30,
        "total_minutes": 45
      },
      "dietary_tags": ["vegetarian", "gluten-free"],
      "dish_types": ["main-course"],
      "recipe_types": ["quick-weeknight"],
      "cuisines": ["japanese"],
      "ingredient_groups": [
        {
          "name": "Main Ingredients",
          "items": [
            {
              "name": "chicken breast",
              "amount": "500",
              "unit": "g",
              "preparation": "diced"
            }
          ]
        }
      ],
      "steps": [
        {
          "id": "step-001",
          "order": 1,
          "instructions": {
            "original": "Heat oil in a large pan over medium heat."
          },
          "timing_minutes": 2
        }
      ],
      "equipment": ["large pan", "knife", "cutting board"]
    }
    ```

    **Guidelines:**
    - Use lowercase, kebab-case for tags (e.g., "gluten-free" not "Gluten Free")
    - Ingredient amounts should be numeric strings
    - Step IDs should be "step-001", "step-002", etc.
    - Only include "original" instruction variant (AI will generate easier/no-equipment later)
    - Language: detect from content or default to "en"
  PROMPT
  prompt.variables = []
  prompt.active = true
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_text_user') do |prompt|
  prompt.prompt_type = 'user'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'User prompt for parsing recipe from text block'
  prompt.prompt_text = <<~PROMPT
    Extract the recipe from the following text and return it as structured JSON:

    ---
    {{text_content}}
    ---

    Return ONLY the JSON object with no additional text.
  PROMPT
  prompt.variables = ['text_content']
  prompt.active = true
end

# URL Parsing Prompts - Direct AI Access (Primary Method)
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_url_direct_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe directly from URL (AI fetches)'
  prompt.prompt_text = <<~PROMPT
    You are a recipe data extraction expert. Your task is to fetch a recipe from a URL and parse it into structured JSON format.

    You will fetch the URL yourself and extract the recipe information from the page content.

    **Output Format:**
    Return ONLY valid JSON in the following structure (no additional text or explanation):

    ```json
    {
      "name": "Recipe Name",
      "language": "en",
      "servings": {
        "original": 4,
        "min": 2,
        "max": 8
      },
      "timing": {
        "prep_minutes": 15,
        "cook_minutes": 30,
        "total_minutes": 45
      },
      "dietary_tags": ["vegetarian"],
      "dish_types": ["main-course"],
      "recipe_types": ["quick-weeknight"],
      "cuisines": ["italian"],
      "ingredient_groups": [
        {
          "name": "Main Ingredients",
          "items": [
            {
              "name": "pasta",
              "amount": "400",
              "unit": "g",
              "preparation": ""
            }
          ]
        }
      ],
      "steps": [
        {
          "id": "step-001",
          "order": 1,
          "instructions": {
            "original": "Boil water in a large pot."
          },
          "timing_minutes": 5
        }
      ],
      "equipment": ["large pot", "colander"]
    }
    ```

    **Guidelines:**
    - Fetch the URL and extract the recipe
    - Ignore ads, navigation, comments, and non-recipe content
    - Use lowercase, kebab-case for tags
    - Ingredient amounts should be numeric strings
    - Step IDs should be "step-001", "step-002", etc.
    - Only include "original" instruction variant
    - If you cannot access the URL, respond with: "ERROR: Cannot access URL"
  PROMPT
  prompt.variables = []
  prompt.active = true
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_url_direct_user') do |prompt|
  prompt.prompt_type = 'user'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'User prompt for direct URL parsing (AI fetches)'
  prompt.prompt_text = <<~PROMPT
    Please fetch and extract the recipe from the following URL and return it as structured JSON:

    **URL:** {{url}}

    Return ONLY the JSON object with no additional text. If you cannot access the URL, respond with "ERROR: Cannot access URL".
  PROMPT
  prompt.variables = ['url']
  prompt.active = true
end

# URL Parsing Prompts - Scraped Content (Fallback Method)
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_url_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe from URL content'
  prompt.prompt_text = <<~PROMPT
    You are a recipe data extraction expert. Your task is to parse recipe content scraped from a website into structured JSON format.

    The content may include website navigation, ads, and other non-recipe text. Focus on extracting only the recipe information.

    **Output Format:**
    Return ONLY valid JSON in the following structure (no additional text or explanation):

    ```json
    {
      "name": "Recipe Name",
      "language": "en",
      "servings": {
        "original": 4,
        "min": 2,
        "max": 8
      },
      "timing": {
        "prep_minutes": 15,
        "cook_minutes": 30,
        "total_minutes": 45
      },
      "dietary_tags": ["vegetarian"],
      "dish_types": ["main-course"],
      "recipe_types": ["quick-weeknight"],
      "cuisines": ["italian"],
      "ingredient_groups": [
        {
          "name": "Main Ingredients",
          "items": [
            {
              "name": "pasta",
              "amount": "400",
              "unit": "g",
              "preparation": ""
            }
          ]
        }
      ],
      "steps": [
        {
          "id": "step-001",
          "order": 1,
          "instructions": {
            "original": "Boil water in a large pot."
          },
          "timing_minutes": 5
        }
      ],
      "equipment": ["large pot", "colander"]
    }
    ```

    **Guidelines:**
    - Ignore ads, navigation, comments, and non-recipe content
    - Use lowercase, kebab-case for tags
    - Ingredient amounts should be numeric strings
    - Step IDs should be "step-001", "step-002", etc.
    - Only include "original" instruction variant
  PROMPT
  prompt.variables = []
  prompt.active = true
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_url_user') do |prompt|
  prompt.prompt_type = 'user'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'User prompt for parsing recipe from URL'
  prompt.prompt_text = <<~PROMPT
    Extract the recipe from the following website content and return it as structured JSON.

    **Source URL:** {{url}}

    **Content:**
    ---
    {{content}}
    ---

    Return ONLY the JSON object with no additional text.
  PROMPT
  prompt.variables = ['url', 'content']
  prompt.active = true
end

# Image Parsing Prompts (Vision API)
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_image_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe from image using Vision API'
  prompt.prompt_text = <<~PROMPT
    You are a recipe data extraction expert with vision capabilities. Your task is to extract recipe information from images (cookbook photos, screenshots, handwritten notes) and structure it as JSON.

    Analyze the image carefully and extract all visible recipe information including:
    - Recipe name/title
    - Ingredients with amounts and units
    - Step-by-step instructions
    - Timing information if visible
    - Any dietary tags or cuisine information

    **Output Format:**
    Return ONLY valid JSON in the following structure:

    ```json
    {
      "name": "Recipe Name",
      "language": "en",
      "servings": {
        "original": 4,
        "min": 2,
        "max": 8
      },
      "timing": {
        "prep_minutes": 15,
        "cook_minutes": 30,
        "total_minutes": 45
      },
      "dietary_tags": [],
      "dish_types": [],
      "recipe_types": [],
      "cuisines": [],
      "ingredient_groups": [
        {
          "name": "Ingredients",
          "items": [
            {
              "name": "flour",
              "amount": "2",
              "unit": "cup",
              "preparation": ""
            }
          ]
        }
      ],
      "steps": [
        {
          "id": "step-001",
          "order": 1,
          "instructions": {
            "original": "Mix flour and water."
          },
          "timing_minutes": 5
        }
      ],
      "equipment": []
    }
    ```

    **Guidelines:**
    - If handwritten, do your best to interpret the text accurately
    - If units are unclear or using abbreviations (tbsp, tsp, oz), expand them
    - Use lowercase, kebab-case for tags
    - Step IDs should be "step-001", "step-002", etc.
    - If information is missing or unclear, use reasonable defaults or omit
  PROMPT
  prompt.variables = []
  prompt.active = true
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_image_user') do |prompt|
  prompt.prompt_type = 'user'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'User prompt for parsing recipe from image'
  prompt.prompt_text = <<~PROMPT
    Please extract the recipe from this image and return it as structured JSON.

    The image may be a cookbook photo, screenshot, or handwritten recipe card. Extract all visible recipe information.

    Return ONLY the JSON object with no additional text.
  PROMPT
  prompt.variables = []
  prompt.active = true
end

puts "✅ Recipe parser prompts seeded (8 prompts)"
