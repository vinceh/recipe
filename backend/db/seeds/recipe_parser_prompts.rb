# AI Prompts for Recipe Parser Service

# Shared JSON schema used across all parser prompts
RECIPE_JSON_SCHEMA = <<~JSON.freeze
  ```json
  {
    "name": "Recipe Name",
    "description": "A brief 1-2 sentence overview of the recipe",
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
      }
    ],
    "equipment": ["large pan", "knife", "cutting board"]
  }
  ```
JSON

# Core guidelines shared across all parser prompts
CORE_GUIDELINES = [
  "Extract or generate a concise description (1-2 sentences) summarizing what the dish is",
  "Use lowercase, kebab-case for tags (e.g., \"gluten-free\" not \"Gluten Free\")",
  "Ingredient amounts should be numeric strings",
  "Step IDs should be \"step-001\", \"step-002\", etc.",
  "Only include \"original\" instruction variant (AI will generate easier/no-equipment later)"
].freeze

# Helper to build system prompts with consistent structure
def build_system_prompt(intro:, source_specific_guidelines: [])
  all_guidelines = source_specific_guidelines + CORE_GUIDELINES
  guidelines_text = all_guidelines.map { |g| "- #{g}" }.join("\n    ")

  <<~PROMPT
    #{intro}

    **Output Format:**
    Return ONLY valid JSON in the following structure (no additional text or explanation):

    #{RECIPE_JSON_SCHEMA}

    **Guidelines:**
    #{guidelines_text}
  PROMPT
end

# Text Block Parsing Prompts
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_text_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe from text block'
  prompt.prompt_text = build_system_prompt(
    intro: "You are a recipe data extraction expert. Your task is to parse unstructured recipe text into a structured JSON format.\n\nExtract all available information and structure it according to the schema below. If information is missing, use reasonable defaults or omit optional fields.",
    source_specific_guidelines: [
      "Language: detect from content or default to \"en\""
    ]
  )
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
  prompt.prompt_text = build_system_prompt(
    intro: "You are a recipe data extraction expert. Your task is to fetch a recipe from a URL and parse it into structured JSON format.\n\nYou will fetch the URL yourself and extract the recipe information from the page content.",
    source_specific_guidelines: [
      "Fetch the URL and extract the recipe",
      "Ignore ads, navigation, comments, and non-recipe content",
      "If you cannot access the URL, respond with: \"ERROR: Cannot access URL\""
    ]
  )
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

# URL Parsing Prompts - Using Claude's Native Web Search
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_url_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe from URL using Claude web search'
  prompt.prompt_text = build_system_prompt(
    intro: "You are a recipe data extraction expert. Your task is to fetch a recipe from a URL using web search and parse it into structured JSON format.\n\nUse your web search capability to access the URL and extract the recipe information from the page content. The page may include website navigation, ads, and other non-recipe text. Focus on extracting only the recipe information.",
    source_specific_guidelines: [
      "Use web search to fetch and read the page content",
      "Ignore ads, navigation, comments, and non-recipe content"
    ]
  )
  prompt.variables = []
  prompt.active = true
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_url_user') do |prompt|
  prompt.prompt_type = 'user'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'User prompt for parsing recipe from URL using web search'
  prompt.prompt_text = <<~PROMPT
    Please use web search to fetch and extract the recipe from the following URL, then return it as structured JSON:

    **URL:** {{url}}

    Return ONLY the JSON object with no additional text.
  PROMPT
  prompt.variables = ['url']
  prompt.active = true
end

# Image Parsing Prompts (Vision API)
AiPrompt.find_or_create_by!(prompt_key: 'recipe_parse_image_system') do |prompt|
  prompt.prompt_type = 'system'
  prompt.feature_area = 'recipe_parsing'
  prompt.description = 'System prompt for parsing recipe from image using Vision API'
  prompt.prompt_text = build_system_prompt(
    intro: "You are a recipe data extraction expert with vision capabilities. Your task is to extract recipe information from images (cookbook photos, screenshots, handwritten notes) and structure it as JSON.\n\nAnalyze the image carefully and extract all visible recipe information including:\n- Recipe name/title\n- Ingredients with amounts and units\n- Step-by-step instructions\n- Timing information if visible\n- Any dietary tags or cuisine information",
    source_specific_guidelines: [
      "If handwritten, do your best to interpret the text accurately",
      "If units are unclear or using abbreviations (tbsp, tsp, oz), expand them",
      "If information is missing or unclear, use reasonable defaults or omit"
    ]
  )
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
