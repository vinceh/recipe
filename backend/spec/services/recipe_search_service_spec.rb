require 'rails_helper'

RSpec.describe RecipeSearchService, type: :service do
  def make_recipe(overrides = {})
    create(:recipe, {
      servings_original: 4,
      servings_min: 2,
      servings_max: 8
    }.merge(overrides))
  end

  def find_or_create_data_reference(type, key, display_name = nil)
    DataReference.find_or_create_by(reference_type: type, key: key) do |ref|
      ref.display_name = display_name || key.humanize
    end
  end

  describe 'Alias Search' do
    context 'AC-SEARCH-002: Fuzzy Text Search - Alias Match' do
      it 'finds recipe by alias' do
        recipe = make_recipe
        recipe.name = "Oyakodon"
        recipe.save
        create(:recipe_alias, recipe: recipe, alias_name: "Chicken and Egg Bowl")

        results = RecipeSearchService.search_by_alias("Chicken and Egg Bowl")

        expect(results).to include(recipe)
      end

      it 'finds recipe with partial alias match' do
        recipe = make_recipe
        recipe.name = "Oyakodon"
        recipe.save
        create(:recipe_alias, recipe: recipe, alias_name: "Chicken and Egg Bowl")

        results = RecipeSearchService.search_by_alias("and egg")

        expect(results).to include(recipe)
      end

      it 'is case-insensitive' do
        recipe = make_recipe
        recipe.name = "Oyakodon"
        recipe.save
        create(:recipe_alias, recipe: recipe, alias_name: "Chicken and Egg Bowl")

        results = RecipeSearchService.search_by_alias("CHICKEN AND EGG BOWL")

        expect(results).to include(recipe)
      end

      it 'returns empty results for blank query' do
        recipe = make_recipe
        recipe.save

        results = RecipeSearchService.search_by_alias("")

        expect(results).to be_empty
      end

      it 'returns empty when alias not found' do
        recipe = make_recipe
        recipe.name = "Test"
        recipe.save

        results = RecipeSearchService.search_by_alias("nonexistent")

        expect(results).to be_empty
      end
    end
  end

  describe 'Ingredient Search' do
    context 'AC-SEARCH-003: Ingredient-Based Search' do
      it 'returns empty results for blank query' do
        recipe = make_recipe
        recipe.save
        ingredient_group = create(:ingredient_group, recipe: recipe)
        create(:recipe_ingredient, ingredient_group: ingredient_group, ingredient_name: "salt")

        results = RecipeSearchService.search_by_ingredient("")

        expect(results).to be_empty
      end

    end
  end

  describe 'Nutrition Filters' do
    context 'AC-SEARCH-004: Nutrition Filter - Calorie Range' do
      it 'filters recipes by minimum calories' do
        recipe_low = make_recipe
        recipe_low.name = "Low Cal"
        recipe_low.save
        create(:recipe_nutrition, recipe: recipe_low, calories: 200)

        recipe_high = make_recipe
        recipe_high.name = "High Cal"
        recipe_high.save
        create(:recipe_nutrition, recipe: recipe_high, calories: 600)

        results = RecipeSearchService.filter_by_calorie_range(Recipe.all, min_calories: 300)

        expect(results).to include(recipe_high)
        expect(results).not_to include(recipe_low)
      end

      it 'filters recipes by maximum calories' do
        recipe_low = make_recipe
        recipe_low.name = "Low Cal"
        recipe_low.save
        create(:recipe_nutrition, recipe: recipe_low, calories: 300)

        recipe_high = make_recipe
        recipe_high.name = "High Cal"
        recipe_high.save
        create(:recipe_nutrition, recipe: recipe_high, calories: 600)

        results = RecipeSearchService.filter_by_calorie_range(Recipe.all, max_calories: 500)

        expect(results).to include(recipe_low)
        expect(results).not_to include(recipe_high)
      end

      it 'filters recipes by both min and max calories' do
        recipe_low = make_recipe
        recipe_low.name = "Low"
        recipe_low.save
        create(:recipe_nutrition, recipe: recipe_low, calories: 200)

        recipe_mid = make_recipe
        recipe_mid.name = "Mid"
        recipe_mid.save
        create(:recipe_nutrition, recipe: recipe_mid, calories: 400)

        recipe_high = make_recipe
        recipe_high.name = "High"
        recipe_high.save
        create(:recipe_nutrition, recipe: recipe_high, calories: 700)

        results = RecipeSearchService.filter_by_calorie_range(Recipe.all, min_calories: 300, max_calories: 500)

        expect(results).to include(recipe_mid)
        expect(results).not_to include(recipe_low, recipe_high)
      end

      it 'returns all recipes when no calorie filter provided' do
        recipe1 = make_recipe
        recipe1.name = "R1"
        recipe1.save
        create(:recipe_nutrition, recipe: recipe1, calories: 200)

        recipe2 = make_recipe
        recipe2.name = "R2"
        recipe2.save
        create(:recipe_nutrition, recipe: recipe2, calories: 600)

        results = RecipeSearchService.filter_by_calorie_range(Recipe.all)

        expect(results).to include(recipe1, recipe2)
      end
    end

    context 'AC-SEARCH-005: Nutrition Filter - Protein Minimum' do
      it 'filters recipes by minimum protein' do
        recipe_low_protein = make_recipe
        recipe_low_protein.name = "Low"
        recipe_low_protein.save
        create(:recipe_nutrition, recipe: recipe_low_protein, protein_g: 15)

        recipe_high_protein = make_recipe
        recipe_high_protein.name = "High"
        recipe_high_protein.save
        create(:recipe_nutrition, recipe: recipe_high_protein, protein_g: 35)

        results = RecipeSearchService.filter_by_protein(Recipe.all, min_protein: 30)

        expect(results).to include(recipe_high_protein)
        expect(results).not_to include(recipe_low_protein)
      end

      it 'includes recipes at exact threshold' do
        recipe = make_recipe
        recipe.name = "Exact"
        recipe.save
        create(:recipe_nutrition, recipe: recipe, protein_g: 30)

        results = RecipeSearchService.filter_by_protein(Recipe.all, min_protein: 30)

        expect(results).to include(recipe)
      end

      it 'returns empty when no recipes meet threshold' do
        recipe = make_recipe
        recipe.name = "Low"
        recipe.save
        create(:recipe_nutrition, recipe: recipe, protein_g: 10)

        results = RecipeSearchService.filter_by_protein(Recipe.all, min_protein: 30)

        expect(results).to be_empty
      end

      it 'returns all recipes when no protein filter provided' do
        recipe1 = make_recipe
        recipe1.name = "R1"
        recipe1.save
        create(:recipe_nutrition, recipe: recipe1, protein_g: 15)

        recipe2 = make_recipe
        recipe2.name = "R2"
        recipe2.save
        create(:recipe_nutrition, recipe: recipe2, protein_g: 35)

        results = RecipeSearchService.filter_by_protein(Recipe.all)

        expect(results).to include(recipe1, recipe2)
      end
    end
  end

  describe 'Category Filters' do
    context 'AC-SEARCH-007: Dietary Tag Filter - Single Selection' do
      it 'filters recipes by single dietary tag' do
        veg_tag = find_or_create_data_reference("dietary_tag", "vegetarian")
        meat_tag = find_or_create_data_reference("dietary_tag", "meat")

        recipe_veg = make_recipe
        recipe_veg.name = "Veg"
        recipe_veg.save
        create(:recipe_dietary_tag, recipe: recipe_veg, data_reference: veg_tag)

        recipe_meat = make_recipe
        recipe_meat.name = "Meat"
        recipe_meat.save
        create(:recipe_dietary_tag, recipe: recipe_meat, data_reference: meat_tag)

        results = RecipeSearchService.filter_by_dietary_tags_all(Recipe.all, ["vegetarian"])

        expect(results).to include(recipe_veg)
        expect(results).not_to include(recipe_meat)
      end

      it 'returns multiple matching recipes' do
        veg_tag = find_or_create_data_reference("dietary_tag", "vegetarian")

        recipe1 = make_recipe
        recipe1.name = "Veg1"
        recipe1.save
        create(:recipe_dietary_tag, recipe: recipe1, data_reference: veg_tag)

        recipe2 = make_recipe
        recipe2.name = "Veg2"
        recipe2.save
        create(:recipe_dietary_tag, recipe: recipe2, data_reference: veg_tag)

        results = RecipeSearchService.filter_by_dietary_tags_all(Recipe.all, ["vegetarian"])

        expect(results).to include(recipe1, recipe2)
      end

      it 'returns empty when no recipes have tag' do
        vegan_tag = find_or_create_data_reference("dietary_tag", "vegan")
        make_recipe.name = "Test"
        make_recipe.save

        results = RecipeSearchService.filter_by_dietary_tags_all(Recipe.all, ["vegan"])

        expect(results).to be_empty
      end
    end

    context 'AC-SEARCH-008: Dietary Tag Filter - Multiple Selection (AND Logic)' do
      it 'filters recipes with ALL selected tags (AND logic)' do
        veg_tag = find_or_create_data_reference("dietary_tag", "vegetarian")
        gf_tag = find_or_create_data_reference("dietary_tag", "gluten-free")

        recipe_both = make_recipe
        recipe_both.name = "Both"
        recipe_both.save
        create(:recipe_dietary_tag, recipe: recipe_both, data_reference: veg_tag)
        create(:recipe_dietary_tag, recipe: recipe_both, data_reference: gf_tag)

        recipe_veg_only = make_recipe
        recipe_veg_only.name = "VegOnly"
        recipe_veg_only.save
        create(:recipe_dietary_tag, recipe: recipe_veg_only, data_reference: veg_tag)

        results = RecipeSearchService.filter_by_dietary_tags_all(Recipe.all, ["vegetarian", "gluten-free"])

        expect(results).to include(recipe_both)
        expect(results).not_to include(recipe_veg_only)
      end

      it 'requires all tags (does not use OR logic)' do
        veg_tag = find_or_create_data_reference("dietary_tag", "vegetarian")
        gf_tag = find_or_create_data_reference("dietary_tag", "gluten-free")

        recipe_veg = make_recipe
        recipe_veg.name = "Veg"
        recipe_veg.save
        create(:recipe_dietary_tag, recipe: recipe_veg, data_reference: veg_tag)

        recipe_gf = make_recipe
        recipe_gf.name = "GF"
        recipe_gf.save
        create(:recipe_dietary_tag, recipe: recipe_gf, data_reference: gf_tag)

        results = RecipeSearchService.filter_by_dietary_tags_all(Recipe.all, ["vegetarian", "gluten-free"])

        expect(results).not_to include(recipe_veg, recipe_gf)
      end
    end

    context 'AC-SEARCH-009: Cuisine Filter - Single Cuisine' do
      it 'filters recipes by single cuisine' do
        japanese = find_or_create_data_reference("cuisine", "japanese")
        italian = find_or_create_data_reference("cuisine", "italian")

        recipe_jp = make_recipe
        recipe_jp.name = "JP"
        recipe_jp.save
        create(:recipe_cuisine, recipe: recipe_jp, data_reference: japanese)

        recipe_it = make_recipe
        recipe_it.name = "IT"
        recipe_it.save
        create(:recipe_cuisine, recipe: recipe_it, data_reference: italian)

        results = RecipeSearchService.filter_by_cuisines(Recipe.all, ["japanese"])

        expect(results).to include(recipe_jp)
        expect(results).not_to include(recipe_it)
      end

      it 'handles multiple cuisines with OR logic' do
        japanese = find_or_create_data_reference("cuisine", "japanese")
        italian = find_or_create_data_reference("cuisine", "italian")

        recipe_jp = make_recipe
        recipe_jp.name = "JP"
        recipe_jp.save
        create(:recipe_cuisine, recipe: recipe_jp, data_reference: japanese)

        recipe_it = make_recipe
        recipe_it.name = "IT"
        recipe_it.save
        create(:recipe_cuisine, recipe: recipe_it, data_reference: italian)

        results = RecipeSearchService.filter_by_cuisines(Recipe.all, ["japanese", "italian"])

        expect(results).to include(recipe_jp, recipe_it)
      end
    end
  end

  describe 'Time Filters' do
    context 'AC-SEARCH-012: Cooking Time Filter - Total Time Range' do
      it 'filters recipes by total time' do
        recipe_fast = make_recipe(total_minutes: 15)
        recipe_fast.name = "Fast"
        recipe_fast.save

        recipe_slow = make_recipe(total_minutes: 45)
        recipe_slow.name = "Slow"
        recipe_slow.save

        results = RecipeSearchService.filter_by_total_time(Recipe.all, max_total: 30)

        expect(results).to include(recipe_fast)
        expect(results).not_to include(recipe_slow)
      end

      it 'includes recipes at exact time boundary' do
        recipe = make_recipe(total_minutes: 30)
        recipe.name = "Exact"
        recipe.save

        results = RecipeSearchService.filter_by_total_time(Recipe.all, max_total: 30)

        expect(results).to include(recipe)
      end

      it 'filters recipes by prep time' do
        recipe_quick = make_recipe(prep_minutes: 5)
        recipe_quick.name = "Quick"
        recipe_quick.save

        recipe_long = make_recipe(prep_minutes: 30)
        recipe_long.name = "Long"
        recipe_long.save

        results = RecipeSearchService.filter_by_prep_time(Recipe.all, max_prep: 20)

        expect(results).to include(recipe_quick)
        expect(results).not_to include(recipe_long)
      end

      it 'filters recipes by cook time' do
        recipe_quick = make_recipe(cook_minutes: 10)
        recipe_quick.name = "Quick"
        recipe_quick.save

        recipe_long = make_recipe(cook_minutes: 60)
        recipe_long.name = "Long"
        recipe_long.save

        results = RecipeSearchService.filter_by_cook_time(Recipe.all, max_cook: 30)

        expect(results).to include(recipe_quick)
        expect(results).not_to include(recipe_long)
      end
    end
  end

  describe 'Difficulty Level Filters' do
    context 'AC-SEARCH-014: Difficulty Level Filter' do
      it 'filters recipes by easy difficulty' do
        recipe_easy = make_recipe(difficulty_level: :easy)
        recipe_easy.name = "Easy Recipe"
        recipe_easy.save

        recipe_hard = make_recipe(difficulty_level: :hard)
        recipe_hard.name = "Hard Recipe"
        recipe_hard.save

        results = RecipeSearchService.filter_by_difficulty(Recipe.all, difficulty_level: 'easy')

        expect(results).to include(recipe_easy)
        expect(results).not_to include(recipe_hard)
      end

      it 'filters recipes by medium difficulty' do
        recipe_easy = make_recipe(difficulty_level: :easy)
        recipe_easy.name = "Easy Recipe"
        recipe_easy.save

        recipe_medium = make_recipe(difficulty_level: :medium)
        recipe_medium.name = "Medium Recipe"
        recipe_medium.save

        recipe_hard = make_recipe(difficulty_level: :hard)
        recipe_hard.name = "Hard Recipe"
        recipe_hard.save

        results = RecipeSearchService.filter_by_difficulty(Recipe.all, difficulty_level: 'medium')

        expect(results).to include(recipe_medium)
        expect(results).not_to include(recipe_easy, recipe_hard)
      end

      it 'filters recipes by hard difficulty' do
        recipe_medium = make_recipe(difficulty_level: :medium)
        recipe_medium.name = "Medium Recipe"
        recipe_medium.save

        recipe_hard = make_recipe(difficulty_level: :hard)
        recipe_hard.name = "Hard Recipe"
        recipe_hard.save

        results = RecipeSearchService.filter_by_difficulty(Recipe.all, difficulty_level: 'hard')

        expect(results).to include(recipe_hard)
        expect(results).not_to include(recipe_medium)
      end

      it 'returns all recipes when difficulty_level is blank' do
        recipe_easy = make_recipe(difficulty_level: :easy)
        recipe_easy.name = "Easy"
        recipe_easy.save

        recipe_hard = make_recipe(difficulty_level: :hard)
        recipe_hard.name = "Hard"
        recipe_hard.save

        results = RecipeSearchService.filter_by_difficulty(Recipe.all, difficulty_level: nil)

        expect(results).to include(recipe_easy, recipe_hard)
      end

      it 'returns all recipes when difficulty_level is empty string' do
        recipe_easy = make_recipe(difficulty_level: :easy)
        recipe_easy.name = "Easy"
        recipe_easy.save

        recipe_hard = make_recipe(difficulty_level: :hard)
        recipe_hard.name = "Hard"
        recipe_hard.save

        results = RecipeSearchService.filter_by_difficulty(Recipe.all, difficulty_level: '')

        expect(results).to include(recipe_easy, recipe_hard)
      end
    end

    context 'AC-SEARCH-014: Difficulty Level in Advanced Search' do
      it 'filters by difficulty_level in advanced_search' do
        recipe_easy = make_recipe(difficulty_level: :easy, total_minutes: 20)
        recipe_easy.name = "Easy Fast"
        recipe_easy.save

        recipe_hard = make_recipe(difficulty_level: :hard, total_minutes: 20)
        recipe_hard.name = "Hard Fast"
        recipe_hard.save

        results = RecipeSearchService.advanced_search(difficulty_level: 'easy')

        expect(results).to include(recipe_easy)
        expect(results).not_to include(recipe_hard)
      end

      it 'combines difficulty_level with other filters in advanced_search' do
        japanese = find_or_create_data_reference("cuisine", "japanese")

        recipe_easy_jp = make_recipe(difficulty_level: :easy, total_minutes: 20)
        recipe_easy_jp.name = "Easy JP"
        recipe_easy_jp.save
        create(:recipe_cuisine, recipe: recipe_easy_jp, data_reference: japanese)
        create(:recipe_nutrition, recipe: recipe_easy_jp, calories: 400)

        recipe_hard_jp = make_recipe(difficulty_level: :hard, total_minutes: 20)
        recipe_hard_jp.name = "Hard JP"
        recipe_hard_jp.save
        create(:recipe_cuisine, recipe: recipe_hard_jp, data_reference: japanese)
        create(:recipe_nutrition, recipe: recipe_hard_jp, calories: 400)

        recipe_easy_other = make_recipe(difficulty_level: :easy, total_minutes: 20)
        recipe_easy_other.name = "Easy Other"
        recipe_easy_other.save
        create(:recipe_nutrition, recipe: recipe_easy_other, calories: 400)

        results = RecipeSearchService.advanced_search(
          difficulty_level: 'easy',
          cuisines: 'japanese',
          max_calories: 500
        )

        expect(results).to include(recipe_easy_jp)
        expect(results).not_to include(recipe_hard_jp, recipe_easy_other)
      end
    end
  end

  describe 'Combined Filters' do
    context 'AC-SEARCH-013: Combined Filters - AND Logic' do
      it 'applies multiple filters with AND logic' do
        japanese = find_or_create_data_reference("cuisine", "japanese")

        recipe_match = make_recipe(total_minutes: 20)
        recipe_match.name = "Match"
        recipe_match.save
        create(:recipe_cuisine, recipe: recipe_match, data_reference: japanese)
        create(:recipe_nutrition, recipe: recipe_match, calories: 400)

        recipe_wrong_cuisine = make_recipe(total_minutes: 20)
        recipe_wrong_cuisine.name = "Wrong Cuisine"
        recipe_wrong_cuisine.save
        create(:recipe_nutrition, recipe: recipe_wrong_cuisine, calories: 400)

        recipe_high_cal = make_recipe(total_minutes: 20)
        recipe_high_cal.name = "High Cal"
        recipe_high_cal.save
        create(:recipe_cuisine, recipe: recipe_high_cal, data_reference: japanese)
        create(:recipe_nutrition, recipe: recipe_high_cal, calories: 600)

        results = RecipeSearchService.advanced_search(
          cuisines: "japanese",
          max_calories: 500
        )

        expect(results).to include(recipe_match)
        expect(results).not_to include(recipe_wrong_cuisine, recipe_high_cal)
      end
    end

    context 'Advanced Search - Multiple Parameter Types' do
      it 'combines nutrition and time filters' do
        veg_tag = find_or_create_data_reference("dietary_tag", "vegetarian")

        recipe_match = make_recipe(total_minutes: 20)
        recipe_match.name = "Match"
        recipe_match.save
        create(:recipe_dietary_tag, recipe: recipe_match, data_reference: veg_tag)
        create(:recipe_nutrition, recipe: recipe_match, calories: 400, protein_g: 35)

        recipe_high_cal = make_recipe(total_minutes: 20)
        recipe_high_cal.name = "High Cal"
        recipe_high_cal.save
        create(:recipe_nutrition, recipe: recipe_high_cal, calories: 600, protein_g: 35)

        recipe_low_protein = make_recipe(total_minutes: 20)
        recipe_low_protein.name = "Low Protein"
        recipe_low_protein.save
        create(:recipe_dietary_tag, recipe: recipe_low_protein, data_reference: veg_tag)
        create(:recipe_nutrition, recipe: recipe_low_protein, calories: 400, protein_g: 20)

        results = RecipeSearchService.advanced_search(
          dietary_tags: "vegetarian",
          max_calories: 500,
          min_protein: 30
        )

        expect(results).to include(recipe_match)
        expect(results).not_to include(recipe_high_cal, recipe_low_protein)
      end
    end
  end

  describe 'Empty Results' do
    context 'AC-SEARCH-016: Empty Results Handling' do
      it 'returns empty collection when no recipes match filters' do
        recipe = make_recipe
        recipe.name = "Test"
        recipe.save
        create(:recipe_nutrition, recipe: recipe, calories: 600)

        results = RecipeSearchService.filter_by_calorie_range(Recipe.all, max_calories: 300)

        expect(results).to be_empty
      end

      it 'handles filters that produce no results gracefully' do
        recipe = make_recipe(prep_minutes: 60)
        recipe.name = "Test"
        recipe.save

        results = RecipeSearchService.filter_by_prep_time(Recipe.all, max_prep: 5)

        expect(results).to be_a(ActiveRecord::Relation)
      end

      it 'does not raise error when filtering with blank parameters' do
        recipe = make_recipe
        recipe.name = "Test"
        recipe.save

        expect {
          RecipeSearchService.advanced_search(
            cuisines: "",
            dietary_tags: nil,
            q: ""
          )
        }.not_to raise_error
      end
    end
  end

  describe 'Service Robustness' do
    it 'handles filtering on Recipe.all class' do
      recipe = make_recipe
      recipe.name = "Test"
      recipe.save
      create(:recipe_nutrition, recipe: recipe, calories: 400)

      results = RecipeSearchService.filter_by_calorie_range(Recipe, min_calories: 100)

      expect(results).to be_a(ActiveRecord::Relation)
    end

    it 'accepts string parameters and converts them' do
      japanese = find_or_create_data_reference("cuisine", "japanese")

      recipe = make_recipe
      recipe.name = "JP"
      recipe.save
      create(:recipe_cuisine, recipe: recipe, data_reference: japanese)

      results = RecipeSearchService.filter_by_cuisines(Recipe.all, "japanese")

      expect(results).to include(recipe)
    end

    it 'handles comma-separated string parameters' do
      japanese = find_or_create_data_reference("cuisine", "japanese")
      italian = find_or_create_data_reference("cuisine", "italian")

      recipe_jp = make_recipe
      recipe_jp.name = "JP"
      recipe_jp.save
      create(:recipe_cuisine, recipe: recipe_jp, data_reference: japanese)

      recipe_it = make_recipe
      recipe_it.name = "IT"
      recipe_it.save
      create(:recipe_cuisine, recipe: recipe_it, data_reference: italian)

      results = RecipeSearchService.filter_by_cuisines(Recipe.all, "japanese, italian")

      expect(results).to include(recipe_jp, recipe_it)
    end
  end
end
