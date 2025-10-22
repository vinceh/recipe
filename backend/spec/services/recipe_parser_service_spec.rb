require 'rails_helper'

RSpec.describe RecipeParserService, type: :service do
  let(:service) { described_class.new }

  before do
    # Seed prompts for testing
    create(:ai_prompt,
      prompt_key: 'recipe_parse_text_system',
      prompt_type: 'system',
      feature_area: 'recipe_parsing',
      prompt_text: 'You are a recipe parser.',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_text_user',
      prompt_type: 'user',
      feature_area: 'recipe_parsing',
      prompt_text: 'Parse: {{text_content}}',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_url_system',
      prompt_type: 'system',
      feature_area: 'recipe_parsing',
      prompt_text: 'You are a recipe parser.',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_url_user',
      prompt_type: 'user',
      feature_area: 'recipe_parsing',
      prompt_text: 'Parse URL {{url}}: {{content}}',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_url_direct_system',
      prompt_type: 'system',
      feature_area: 'recipe_parsing',
      prompt_text: 'You are a recipe parser with direct URL access.',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_url_direct_user',
      prompt_type: 'user',
      feature_area: 'recipe_parsing',
      prompt_text: 'Fetch and parse {{url}}',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_image_system',
      prompt_type: 'system',
      feature_area: 'recipe_parsing',
      prompt_text: 'You are a recipe parser with vision.',
      active: true
    )
    create(:ai_prompt,
      prompt_key: 'recipe_parse_image_user',
      prompt_type: 'user',
      feature_area: 'recipe_parsing',
      prompt_text: 'Extract recipe from image.',
      active: true
    )

    # Stub ENV
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test_api_key')
  end

  describe '#parse_text_block' do
    context 'AC-ADMIN-002: Text block import - parse recipe' do
      it 'extracts structured recipe data from text' do
        text_content = <<~TEXT
          Pasta Carbonara

          Ingredients:
          - 400g spaghetti
          - 4 eggs
          - 100g parmesan
          - 200g pancetta

          Instructions:
          1. Boil pasta
          2. Cook pancetta
          3. Mix eggs and cheese
          4. Combine everything
        TEXT

        ai_response = {
          'name' => 'Pasta Carbonara',
          'language' => 'en',
          'servings' => { 'original' => 4 },
          'ingredient_groups' => [
            {
              'name' => 'Ingredients',
              'items' => [
                { 'name' => 'spaghetti', 'amount' => '400', 'unit' => 'g' }
              ]
            }
          ],
          'steps' => [
            {
              'id' => 'step-001',
              'order' => 1,
              'instructions' => { 'original' => 'Boil pasta' }
            }
          ]
        }.to_json

        # Mock Claude API response
        allow(service).to receive(:call_claude).and_return("```json\n#{ai_response}\n```")

        result = service.parse_text_block(text_content)

        expect(result).to be_present
        expect(result['name']).to eq('Pasta Carbonara')
        expect(result['language']).to eq('en')
        expect(result['ingredient_groups']).to be_an(Array)
        expect(result['steps']).to be_an(Array)
      end

      it 'handles malformed text gracefully' do
        text_content = "This is not a recipe, just random text."

        # Mock empty/invalid response
        allow(service).to receive(:call_claude).and_return("No recipe found")

        result = service.parse_text_block(text_content)

        expect(result).to be_nil
      end
    end
  end

  describe '#parse_url' do
    let(:url) { 'https://example.com/recipe/carbonara' }
    let(:ai_recipe_response) do
      {
        'name' => 'Pasta Carbonara',
        'language' => 'en',
        'servings' => { 'original' => 4 },
        'ingredient_groups' => [
          {
            'name' => 'Ingredients',
            'items' => [{ 'name' => 'spaghetti', 'amount' => '400', 'unit' => 'g' }]
          }
        ],
        'steps' => [
          {
            'id' => 'step-001',
            'order' => 1,
            'instructions' => { 'original' => 'Boil pasta' }
          }
        ]
      }.to_json
    end

    context 'AC-ADMIN-003: URL import - AI direct access (primary)' do
      it 'successfully parses recipe using AI direct access' do
        # Mock AI direct access success
        allow(service).to receive(:parse_url_direct).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result).to be_present
        expect(result['name']).to eq('Pasta Carbonara')
        expect(result['source_url']).to eq(url)
      end

      it 'includes source_url in result' do
        allow(service).to receive(:parse_url_direct).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result['source_url']).to eq(url)
      end

      it 'logs successful AI direct access' do
        allow(service).to receive(:parse_url_direct).and_return(JSON.parse(ai_recipe_response))
        allow(Rails.logger).to receive(:info)

        service.parse_url(url)

        expect(Rails.logger).to have_received(:info).with(/Successfully parsed URL using AI direct access/)
      end
    end

    context 'AC-ADMIN-003-A: URL import - web scraping fallback' do
      it 'falls back to web scraping when AI cannot access URL' do
        # Mock AI direct access failure
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("Cannot access URL"))

        # Mock web scraping success
        allow(service).to receive(:parse_url_with_scraping).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result).to be_present
        expect(result['name']).to eq('Pasta Carbonara')
        expect(result['source_url']).to eq(url)
      end

      it 'logs fallback attempt' do
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("403 Forbidden"))
        allow(service).to receive(:parse_url_with_scraping).and_return(JSON.parse(ai_recipe_response))
        allow(Rails.logger).to receive(:warn)
        allow(Rails.logger).to receive(:info)

        service.parse_url(url)

        expect(Rails.logger).to have_received(:warn).with(/AI direct access failed/)
        expect(Rails.logger).to have_received(:info).with(/Attempting web scraping fallback/)
      end

      it 'successfully parses with scraped content' do
        allow(service).to receive(:parse_url_direct).and_return(nil)
        allow(service).to receive(:parse_url_with_scraping).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result).to be_present
        expect(result['source_url']).to eq(url)
      end
    end

    context 'AC-ADMIN-003-B: URL import - complete failure' do
      it 'raises error when both methods fail' do
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("Cannot access"))
        allow(service).to receive(:parse_url_with_scraping).and_return(nil)

        expect {
          service.parse_url(url)
        }.to raise_error(/Failed to parse recipe from URL/)
      end

      it 'raises error when AI direct returns nil and scraping fails' do
        allow(service).to receive(:parse_url_direct).and_return(nil)
        allow(service).to receive(:parse_url_with_scraping).and_raise(StandardError.new("Scraping failed"))

        expect {
          service.parse_url(url)
        }.to raise_error(/Scraping failed/)
      end
    end

    context 'URL validation' do
      it 'raises error for empty URL' do
        expect {
          service.parse_url('')
        }.to raise_error(/URL is required/)
      end

      it 'raises error for nil URL' do
        expect {
          service.parse_url(nil)
        }.to raise_error(/URL is required/)
      end

      it 'raises error for invalid URL format' do
        expect {
          service.parse_url('not-a-valid-url')
        }.to raise_error(/Invalid URL format/)
      end

      it 'accepts valid HTTP URL' do
        allow(service).to receive(:parse_url_direct).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url('http://example.com/recipe')

        expect(result).to be_present
      end

      it 'accepts valid HTTPS URL' do
        allow(service).to receive(:parse_url_direct).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url('https://example.com/recipe')

        expect(result).to be_present
      end
    end

    context 'error scenarios' do
      it 'handles 403 Forbidden from target site' do
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("403 Forbidden"))
        allow(service).to receive(:parse_url_with_scraping).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result).to be_present
      end

      it 'handles 404 Not Found from target site' do
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("404 Not Found"))
        allow(service).to receive(:parse_url_with_scraping).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result).to be_present
      end

      it 'handles SSL certificate errors' do
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("SSL verification failed"))
        allow(service).to receive(:parse_url_with_scraping).and_return(JSON.parse(ai_recipe_response))

        result = service.parse_url(url)

        expect(result).to be_present
      end

      it 'handles timeout errors' do
        allow(service).to receive(:parse_url_direct).and_raise(StandardError.new("Connection timeout"))
        allow(service).to receive(:parse_url_with_scraping).and_raise(StandardError.new("Connection timeout"))

        expect {
          service.parse_url(url)
        }.to raise_error(/Connection timeout/)
      end
    end
  end

  describe '#parse_image' do
    context 'AC-ADMIN-004: Image import - vision extraction' do
      it 'extracts recipe from image using Vision API' do
        image_path = '/path/to/recipe_image.jpg'

        # Mock image preparation
        allow(service).to receive(:prepare_image).with(image_path).and_return({
          type: 'base64',
          media_type: 'image/jpeg',
          data: 'base64encodeddata'
        })

        ai_response = {
          'name' => 'Handwritten Pancakes',
          'language' => 'en',
          'servings' => { 'original' => 4 },
          'ingredient_groups' => [
            {
              'name' => 'Ingredients',
              'items' => [
                { 'name' => 'flour', 'amount' => '2', 'unit' => 'cup' },
                { 'name' => 'eggs', 'amount' => '2', 'unit' => 'whole' }
              ]
            }
          ],
          'steps' => [
            {
              'id' => 'step-001',
              'order' => 1,
              'instructions' => { 'original' => 'Mix flour and eggs' }
            }
          ]
        }.to_json

        allow(service).to receive(:call_claude_vision).and_return("```json\n#{ai_response}\n```")

        result = service.parse_image(image_path)

        expect(result).to be_present
        expect(result['name']).to eq('Handwritten Pancakes')
        expect(result['ingredient_groups']).to be_an(Array)
        expect(result['steps']).to be_an(Array)
      end

      it 'handles cookbook photo images' do
        image_url = 'https://example.com/cookbook_page.jpg'

        allow(service).to receive(:prepare_image).with(image_url).and_return({
          type: 'url',
          url: image_url
        })

        ai_response = {
          'name' => 'Cookbook Recipe',
          'language' => 'en',
          'servings' => { 'original' => 6 },
          'ingredient_groups' => [{ 'name' => 'Ingredients', 'items' => [] }],
          'steps' => [{ 'id' => 'step-001', 'order' => 1, 'instructions' => { 'original' => 'Follow steps' } }]
        }.to_json

        allow(service).to receive(:call_claude_vision).and_return(ai_response)

        result = service.parse_image(image_url)

        expect(result).to be_present
        expect(result['name']).to eq('Cookbook Recipe')
      end

      it 'handles handwritten recipe notes' do
        image_path = '/path/to/grandmas_recipe.png'

        allow(service).to receive(:prepare_image).and_return({
          type: 'base64',
          media_type: 'image/png',
          data: 'encodeddata'
        })

        ai_response = {
          'name' => 'Grandmas Cookies',
          'language' => 'en',
          'servings' => { 'original' => 24 },
          'ingredient_groups' => [{ 'name' => 'Ingredients', 'items' => [] }],
          'steps' => [{ 'id' => 'step-001', 'order' => 1, 'instructions' => { 'original' => 'Mix ingredients' } }]
        }.to_json

        allow(service).to receive(:call_claude_vision).and_return(ai_response)

        result = service.parse_image(image_path)

        expect(result).to be_present
        expect(result['name']).to eq('Grandmas Cookies')
      end
    end
  end

  describe 'private methods' do
    describe '#parse_response' do
      it 'extracts JSON from markdown code block' do
        response = <<~RESPONSE
          Here's the recipe:
          ```json
          {
            "name": "Test Recipe",
            "language": "en",
            "servings": {"original": 4},
            "ingredient_groups": [{"name": "Ingredients", "items": []}],
            "steps": [{"id": "step-001", "order": 1, "instructions": {"original": "Cook"}}]
          }
          ```
        RESPONSE

        result = service.send(:parse_response, response)

        expect(result).to be_present
        expect(result['name']).to eq('Test Recipe')
      end

      it 'extracts raw JSON without markdown' do
        response = '{"name": "Test", "language": "en", "servings": {"original": 2}, "ingredient_groups": [{"name": "Ingredients", "items": []}], "steps": [{"id": "step-001", "order": 1, "instructions": {"original": "Mix"}}]}'

        result = service.send(:parse_response, response)

        expect(result).to be_present
        expect(result['name']).to eq('Test')
      end

      it 'returns nil for invalid JSON' do
        response = "This is not valid JSON at all"

        result = service.send(:parse_response, response)

        expect(result).to be_nil
      end
    end

    describe '#validate_recipe_structure' do
      it 'validates required fields are present' do
        valid_recipe = {
          'name' => 'Test',
          'language' => 'en',
          'ingredient_groups' => [{ 'name' => 'Main', 'items' => [] }],
          'steps' => [{ 'id' => 'step-001', 'instructions' => { 'original' => 'Cook' } }]
        }

        expect {
          service.send(:validate_recipe_structure, valid_recipe)
        }.not_to raise_error
      end

      it 'raises error if name is missing' do
        invalid_recipe = {
          'language' => 'en',
          'ingredient_groups' => [],
          'steps' => []
        }

        expect {
          service.send(:validate_recipe_structure, invalid_recipe)
        }.to raise_error(/Missing fields: name/)
      end

      it 'raises error if ingredient_groups is not an array' do
        invalid_recipe = {
          'name' => 'Test',
          'language' => 'en',
          'ingredient_groups' => 'not an array',
          'steps' => []
        }

        expect {
          service.send(:validate_recipe_structure, invalid_recipe)
        }.to raise_error(/ingredient_groups must be an array/)
      end

      it 'raises error if steps is not an array' do
        invalid_recipe = {
          'name' => 'Test',
          'language' => 'en',
          'ingredient_groups' => [],
          'steps' => 'not an array'
        }

        expect {
          service.send(:validate_recipe_structure, invalid_recipe)
        }.to raise_error(/steps must be an array/)
      end
    end
  end
end
