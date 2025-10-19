require 'rails_helper'

RSpec.describe RecipeSearchService, type: :service do
  let!(:pad_thai) do
    Recipe.create!(
      name: 'Pad Thai',
      language: 'en',
      servings: { 'original' => 4, 'min' => 2, 'max' => 8 },
      timing: { 'prep_minutes' => 15, 'cook_minutes' => 10, 'total_minutes' => 25 },
      dietary_tags: ['vegetarian', 'gluten-free'],
      cuisines: ['thai'],
      dish_types: ['main-course'],
      recipe_types: ['quick-weeknight'],
      aliases: ['Thai noodles', 'Phad Thai'],
      ingredient_groups: [
        {
          'name' => 'Main',
          'items' => [
            { 'name' => 'rice noodles', 'amount' => '200', 'unit' => 'g' },
            { 'name' => 'peanuts', 'amount' => '50', 'unit' => 'g' },
            { 'name' => 'egg', 'amount' => '2', 'unit' => 'whole' }
          ]
        }
      ],
      steps: [],
      nutrition: {
        'per_serving' => {
          'calories' => 450,
          'protein_g' => 12,
          'carbs_g' => 60,
          'fat_g' => 18,
          'fiber_g' => 3
        }
      }
    )
  end

  let!(:chicken_curry) do
    Recipe.create!(
      name: 'Chicken Curry',
      language: 'en',
      servings: { 'original' => 6, 'min' => 4, 'max' => 8 },
      timing: { 'prep_minutes' => 20, 'cook_minutes' => 30, 'total_minutes' => 50 },
      dietary_tags: ['gluten-free'],
      cuisines: ['indian'],
      dish_types: ['main-course'],
      ingredient_groups: [
        {
          'name' => 'Main',
          'items' => [
            { 'name' => 'chicken breast', 'amount' => '500', 'unit' => 'g' },
            { 'name' => 'coconut milk', 'amount' => '400', 'unit' => 'ml' }
          ]
        }
      ],
      steps: [],
      nutrition: {
        'per_serving' => {
          'calories' => 320,
          'protein_g' => 25,
          'carbs_g' => 15,
          'fat_g' => 20,
          'fiber_g' => 2
        }
      }
    )
  end

  let!(:greek_salad) do
    Recipe.create!(
      name: 'Greek Salad',
      language: 'en',
      servings: { 'original' => 2, 'min' => 1, 'max' => 4 },
      timing: { 'prep_minutes' => 10, 'cook_minutes' => 0, 'total_minutes' => 10 },
      dietary_tags: ['vegetarian', 'gluten-free'],
      cuisines: ['greek'],
      dish_types: ['appetizer', 'side-dish'],
      ingredient_groups: [
        {
          'name' => 'Vegetables',
          'items' => [
            { 'name' => 'tomato', 'amount' => '2', 'unit' => 'whole' },
            { 'name' => 'cucumber', 'amount' => '1', 'unit' => 'whole' },
            { 'name' => 'feta cheese', 'amount' => '100', 'unit' => 'g' }
          ]
        }
      ],
      steps: [],
      nutrition: {
        'per_serving' => {
          'calories' => 180,
          'protein_g' => 8,
          'carbs_g' => 12,
          'fat_g' => 12,
          'fiber_g' => 4
        }
      }
    )
  end

  describe '.fuzzy_search' do
    context 'AC-SEARCH-001: Fuzzy search with typo tolerance' do
      it 'finds recipe with exact match' do
        results = described_class.fuzzy_search('Pad Thai')
        expect(results).to include(pad_thai)
      end

      it 'finds recipe with case insensitive match' do
        results = described_class.fuzzy_search('pad thai')
        expect(results).to include(pad_thai)
      end

      it 'finds recipe with partial match' do
        results = described_class.fuzzy_search('Thai')
        expect(results).to include(pad_thai)
      end

      it 'returns empty for blank query' do
        results = described_class.fuzzy_search('')
        expect(results).to be_empty
      end
    end
  end

  describe '.search_by_alias' do
    context 'AC-SEARCH-002: Recipe alias search' do
      it 'finds recipe by alias' do
        results = described_class.search_by_alias('Thai noodles')
        expect(results).to include(pad_thai)
      end

      it 'finds recipe by partial alias match' do
        results = described_class.search_by_alias('noodles')
        expect(results).to include(pad_thai)
      end

      it 'is case insensitive' do
        results = described_class.search_by_alias('PHAD THAI')
        expect(results).to include(pad_thai)
      end

      it 'returns empty for recipes without matching aliases' do
        results = described_class.search_by_alias('pasta')
        expect(results).not_to include(chicken_curry)
      end
    end
  end

  describe '.search_by_ingredient' do
    context 'AC-SEARCH-003: Ingredient-based search' do
      it 'finds recipe containing specific ingredient' do
        results = described_class.search_by_ingredient('peanuts')
        expect(results).to include(pad_thai)
      end

      it 'finds recipe with partial ingredient name' do
        results = described_class.search_by_ingredient('chicken')
        expect(results).to include(chicken_curry)
      end

      it 'is case insensitive' do
        results = described_class.search_by_ingredient('PEANUTS')
        expect(results).to include(pad_thai)
      end

      it 'returns multiple recipes with same ingredient' do
        results = described_class.search_by_ingredient('tomato')
        expect(results).to include(greek_salad)
      end
    end
  end

  describe '.filter_by_calorie_range' do
    context 'AC-SEARCH-004: Calorie range filter' do
      it 'filters by minimum calories' do
        results = described_class.filter_by_calorie_range(Recipe.all, min_calories: 300)
        expect(results).to include(pad_thai, chicken_curry)
        expect(results).not_to include(greek_salad)
      end

      it 'filters by maximum calories' do
        results = described_class.filter_by_calorie_range(Recipe.all, max_calories: 350)
        expect(results).to include(chicken_curry, greek_salad)
        expect(results).not_to include(pad_thai)
      end

      it 'filters by calorie range' do
        results = described_class.filter_by_calorie_range(
          Recipe.all,
          min_calories: 300,
          max_calories: 400
        )
        expect(results).to eq([chicken_curry])
      end
    end
  end

  describe '.filter_by_protein' do
    context 'AC-SEARCH-005: Protein minimum filter' do
      it 'filters by minimum protein' do
        results = described_class.filter_by_protein(Recipe.all, min_protein: 20)
        expect(results).to eq([chicken_curry])
      end

      it 'returns all when no minimum specified' do
        results = described_class.filter_by_protein(Recipe.all, min_protein: nil)
        expect(results.count).to eq(3)
      end
    end
  end

  describe '.filter_by_carbs' do
    context 'AC-SEARCH-006: Maximum carbs filter' do
      it 'filters by maximum carbs' do
        results = described_class.filter_by_carbs(Recipe.all, max_carbs: 20)
        expect(results).to include(chicken_curry, greek_salad)
        expect(results).not_to include(pad_thai)
      end
    end
  end

  describe '.filter_by_fat' do
    context 'AC-SEARCH-007: Maximum fat filter' do
      it 'filters by maximum fat' do
        results = described_class.filter_by_fat(Recipe.all, max_fat: 15)
        expect(results).to eq([greek_salad])
      end
    end
  end

  describe '.filter_by_dietary_tags_all' do
    context 'AC-SEARCH-008: Multiple dietary tags (AND logic)' do
      it 'filters recipes with all specified tags' do
        results = described_class.filter_by_dietary_tags_all(
          Recipe.all,
          'vegetarian,gluten-free'
        )
        expect(results).to include(pad_thai, greek_salad)
        expect(results).not_to include(chicken_curry)
      end

      it 'requires all tags to match (AND logic)' do
        results = described_class.filter_by_dietary_tags_all(
          Recipe.all,
          'vegetarian'
        )
        expect(results).to include(pad_thai, greek_salad)
      end
    end
  end

  describe '.filter_by_cuisines' do
    context 'AC-SEARCH-009: Cuisine filter (OR logic)' do
      it 'filters by single cuisine' do
        results = described_class.filter_by_cuisines(Recipe.all, 'thai')
        expect(results).to eq([pad_thai])
      end

      it 'filters by multiple cuisines with OR logic' do
        results = described_class.filter_by_cuisines(Recipe.all, 'thai,indian')
        expect(results).to include(pad_thai, chicken_curry)
        expect(results).not_to include(greek_salad)
      end
    end
  end

  describe '.filter_by_dish_types' do
    context 'AC-SEARCH-010: Dish type filter' do
      it 'filters by dish type' do
        results = described_class.filter_by_dish_types(Recipe.all, 'main-course')
        expect(results).to include(pad_thai, chicken_curry)
        expect(results).not_to include(greek_salad)
      end

      it 'filters by multiple dish types' do
        results = described_class.filter_by_dish_types(Recipe.all, 'appetizer,side-dish')
        expect(results).to include(greek_salad)
      end
    end
  end

  describe '.filter_by_prep_time' do
    context 'AC-SEARCH-012: Prep time filter' do
      it 'filters by maximum prep time' do
        results = described_class.filter_by_prep_time(Recipe.all, max_prep: 15)
        expect(results).to include(pad_thai, greek_salad)
        expect(results).not_to include(chicken_curry)
      end
    end
  end

  describe '.filter_by_total_time' do
    context 'AC-SEARCH-014: Total time filter' do
      it 'filters by maximum total time' do
        results = described_class.filter_by_total_time(Recipe.all, max_total: 30)
        expect(results).to include(pad_thai, greek_salad)
        expect(results).not_to include(chicken_curry)
      end
    end
  end

  describe '.filter_by_servings' do
    context 'AC-SEARCH-015: Servings range filter' do
      it 'filters by minimum servings' do
        results = described_class.filter_by_servings(Recipe.all, min_servings: 4)
        expect(results).to include(pad_thai, chicken_curry)
        expect(results).not_to include(greek_salad)
      end

      it 'filters by maximum servings' do
        results = described_class.filter_by_servings(Recipe.all, max_servings: 4)
        expect(results).to include(pad_thai, greek_salad)
        expect(results).not_to include(chicken_curry)
      end

      it 'filters by servings range' do
        results = described_class.filter_by_servings(
          Recipe.all,
          min_servings: 3,
          max_servings: 5
        )
        expect(results).to eq([pad_thai])
      end
    end
  end

  describe '.exclude_ingredients' do
    context 'AC-SEARCH-016: Allergen filtering' do
      it 'excludes recipes with specified ingredient' do
        results = described_class.exclude_ingredients(Recipe.all, 'peanuts')
        expect(results).to include(chicken_curry, greek_salad)
        expect(results).not_to include(pad_thai)
      end

      it 'excludes multiple ingredients' do
        results = described_class.exclude_ingredients(
          Recipe.all,
          'peanuts,chicken'
        )
        expect(results).to eq([greek_salad])
      end

      it 'is case insensitive' do
        results = described_class.exclude_ingredients(Recipe.all, 'PEANUTS')
        expect(results).not_to include(pad_thai)
      end
    end
  end

  describe '.advanced_search' do
    it 'combines multiple filters' do
      results = described_class.advanced_search(
        cuisines: 'thai,indian',
        max_calories: 400,
        dietary_tags: 'gluten-free'
      )

      expect(results).to include(chicken_curry)
      expect(results).not_to include(pad_thai) # Over 400 calories
      expect(results).not_to include(greek_salad) # Not thai or indian
    end

    it 'searches by ingredient and excludes allergens' do
      results = described_class.advanced_search(
        ingredient: 'noodles',
        exclude_ingredients: 'peanuts'
      )

      # Should be empty since pad_thai has both noodles and peanuts
      expect(results).to be_empty
    end

    it 'filters by nutrition and timing' do
      results = described_class.advanced_search(
        min_protein: 10,
        max_total_time: 30
      )

      expect(results).to eq([pad_thai])
    end
  end

  describe '.comprehensive_search' do
    it 'searches by name first' do
      results = described_class.comprehensive_search('Pad Thai')
      expect(results).to include(pad_thai)
    end

    it 'falls back to alias search' do
      results = described_class.comprehensive_search('Thai noodles')
      expect(results).to include(pad_thai)
    end

    it 'falls back to ingredient search' do
      results = described_class.comprehensive_search('peanuts')
      expect(results).to include(pad_thai)
    end
  end
end
