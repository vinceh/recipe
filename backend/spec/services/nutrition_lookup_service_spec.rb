require 'rails_helper'

RSpec.describe NutritionLookupService, type: :service do
  let(:service) { described_class.new }
  let(:nutritionix_client) { instance_double(NutritionixClient) }

  before do
    allow(NutritionixClient).to receive(:new).and_return(nutritionix_client)
  end

  describe '#lookup_ingredient' do
    context 'AC-NUTR-001: Database-first lookup' do
      it 'returns nutrition from database if ingredient exists' do
        ingredient = create(:ingredient, canonical_name: 'chicken')
        create(:ingredient_nutrition,
          ingredient: ingredient,
          calories: 165,
          protein_g: 31,
          carbs_g: 0,
          fat_g: 3.6,
          fiber_g: 0
        )

        # Stub to ensure it's not called
        allow(nutritionix_client).to receive(:natural_language_search)

        result = service.lookup_ingredient('chicken', 'en')

        expect(result[:calories]).to eq(165)
        expect(result[:protein_g]).to eq(31)
        expect(nutritionix_client).not_to have_received(:natural_language_search)
      end
    end

    context 'AC-NUTR-002: API fallback' do
      it 'fetches from Nutritionix if not in database' do
        api_response = {
          'foods' => [{
            'serving_weight_grams' => 100,
            'nf_calories' => 165,
            'nf_protein' => 31,
            'nf_total_carbohydrate' => 0,
            'nf_total_fat' => 3.6,
            'nf_dietary_fiber' => 0
          }]
        }

        allow(nutritionix_client).to receive(:natural_language_search)
          .with('100g chicken breast')
          .and_return(api_response)

        result = service.lookup_ingredient('chicken breast', 'en')

        expect(result[:calories]).to eq(165)
        expect(result[:protein_g]).to eq(31)
      end

      it 'stores fetched data in database' do
        api_response = {
          'foods' => [{
            'serving_weight_grams' => 100,
            'nf_calories' => 165,
            'nf_protein' => 31,
            'nf_total_carbohydrate' => 0,
            'nf_total_fat' => 3.6,
            'nf_dietary_fiber' => 0
          }]
        }

        allow(nutritionix_client).to receive(:natural_language_search).and_return(api_response)

        service.lookup_ingredient('chicken breast', 'en')

        ingredient = Ingredient.find_by(canonical_name: 'chicken breast')
        expect(ingredient).to be_present
        expect(ingredient.nutrition.calories).to eq(165)
        expect(ingredient.nutrition.data_source).to eq('nutritionix')
      end
    end

    context 'AC-NUTR-003: AI estimation fallback' do
      it 'uses AI estimation when Nutritionix fails' do
        allow(nutritionix_client).to receive(:natural_language_search)
          .and_raise(NutritionixClient::Error, 'API error')

        # Mock AI prompts
        create(:ai_prompt,
          prompt_key: 'nutrition_estimation_system',
          prompt_type: 'system',
          feature_area: 'nutrition_estimation',
          prompt_text: 'You estimate nutrition.',
          active: true
        )
        create(:ai_prompt,
          prompt_key: 'nutrition_estimation',
          prompt_type: 'user',
          feature_area: 'nutrition_estimation',
          prompt_text: 'Estimate: {{ingredient_name}}',
          active: true
        )

        # Mock AI service
        ai_service = instance_double(AiService)
        allow(AiService).to receive(:new).and_return(ai_service)
        allow(ai_service).to receive(:call_claude).and_return(
          '{"calories": 120, "protein_g": 5, "carbs_g": 20, "fat_g": 2, "fiber_g": 3}'
        )

        result = service.lookup_ingredient('rare ingredient', 'en')

        expect(result[:calories]).to eq(120)
        expect(result[:protein_g]).to eq(5)
      end

      it 'marks AI estimates with lower confidence' do
        # Mock Nutritionix returning error (trigger AI fallback)
        allow(nutritionix_client).to receive(:natural_language_search)
          .and_raise(NutritionixClient::Error, 'API error')

        # Mock AI estimation (will use fallback defaults)
        result = service.lookup_ingredient('unknown food', 'en')

        ingredient = Ingredient.find_by(canonical_name: 'unknown food')
        expect(ingredient.nutrition.data_source).to eq('ai')
        expect(ingredient.nutrition.confidence_score).to eq(0.7)
      end
    end

    context 'AC-NUTR-004: Exact match' do
      it 'finds exact canonical name match' do
        ingredient = create(:ingredient, canonical_name: 'tomato')
        create(:ingredient_nutrition, ingredient: ingredient, calories: 18)

        result = service.lookup_ingredient('tomato', 'en')

        expect(result[:calories]).to eq(18)
      end
    end

    context 'AC-NUTR-005: Plural/singular matching' do
      it 'normalizes plural to singular' do
        ingredient = create(:ingredient, canonical_name: 'tomato')
        create(:ingredient_nutrition, ingredient: ingredient, calories: 18)

        result = service.lookup_ingredient('tomatoes', 'en')

        expect(result[:calories]).to eq(18)
      end
    end

    context 'AC-NUTR-006: Alias matching' do
      it 'finds ingredient via alias' do
        ingredient = create(:ingredient, canonical_name: 'eggplant')
        create(:ingredient_nutrition, ingredient: ingredient, calories: 25)
        create(:ingredient_alias,
          ingredient: ingredient,
          alias: 'aubergine',
          language: 'en'
        )

        result = service.lookup_ingredient('aubergine', 'en')

        expect(result[:calories]).to eq(25)
      end
    end

    context 'AC-NUTR-007: Levenshtein fuzzy matching' do
      it 'matches typos with >85% similarity' do
        ingredient = create(:ingredient, canonical_name: 'chicken')
        create(:ingredient_nutrition, ingredient: ingredient, calories: 165)
        create(:ingredient_alias,
          ingredient: ingredient,
          alias: 'chicken',
          language: 'en'
        )

        result = service.lookup_ingredient('chiken', 'en')  # typo

        expect(result[:calories]).to eq(165)
      end
    end
  end

  describe 'private methods' do
    describe '#normalize_ingredient_name' do
      it 'removes punctuation and normalizes whitespace' do
        normalized = service.send(:normalize_ingredient_name, 'chicken,  breast!')
        expect(normalized).to eq('chicken breast')
      end

      it 'converts to singular' do
        normalized = service.send(:normalize_ingredient_name, 'tomatoes')
        expect(normalized).to eq('tomato')
      end
    end

    describe '#guess_category' do
      it 'categorizes vegetables' do
        category = service.send(:guess_category, 'carrot')
        expect(category).to eq('vegetable')
      end

      it 'categorizes proteins' do
        category = service.send(:guess_category, 'chicken breast')
        expect(category).to eq('protein')
      end

      it 'defaults to other' do
        category = service.send(:guess_category, 'unknown food')
        expect(category).to eq('other')
      end
    end

    describe '#calculate_similarity' do
      it 'returns 1.0 for identical strings' do
        similarity = service.send(:calculate_similarity, 'chicken', 'chicken')
        expect(similarity).to eq(1.0)
      end

      it 'returns high score for similar strings' do
        similarity = service.send(:calculate_similarity, 'chicken', 'chiken')
        expect(similarity).to be > 0.85
      end

      it 'returns low score for different strings' do
        similarity = service.send(:calculate_similarity, 'chicken', 'beef')
        expect(similarity).to be < 0.5
      end
    end
  end
end
