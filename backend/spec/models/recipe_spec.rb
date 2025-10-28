require 'rails_helper'

describe Recipe do
  describe 'description field with Mobility' do
    let(:cuisine) do
      DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
    end

    let(:recipe) do
      recipe = Recipe.new(
        name: "Test Recipe",
        description: "A delicious recipe",
        source_language: "en",
        servings_original: 2,
        prep_minutes: 10,
        cook_minutes: 20,
        total_minutes: 30
      )
      recipe.recipe_steps.build(step_number: 1, instruction_original: "Test step")
      ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
      ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
      ig.recipe_ingredients.build(ingredient_id: ingredient.id, ingredient_name: "test ingredient", amount: 1, unit: "cup", position: 1)
      recipe.recipe_cuisines.build(data_reference: cuisine)
      recipe
    end

    it 'is translatable via Mobility' do
      expect(Recipe.mobility_attributes.map(&:to_s)).to include('description')
    end

    it 'stores description in recipe_translations table' do
      recipe.save!

      translation = RecipeTranslation.find_by(recipe_id: recipe.id, locale: 'en')
      expect(translation.description).to eq("A delicious recipe")
    end

    it 'retrieves description for current locale' do
      I18n.with_locale(:en) do
        recipe.save!
      end

      I18n.with_locale(:en) do
        recipe.reload
        expect(recipe.description).to eq("A delicious recipe")
      end
    end


    it 'handles long descriptions (TEXT type)' do
      long_description = "Lorem ipsum dolor sit amet, " * 100 # Over 1000 characters
      recipe.description = long_description
      recipe.save!

      recipe.reload
      expect(recipe.description).to eq(long_description)
    end

    it 'requires description field to be NOT NULL in database' do
      # Verify the column constraint
      column_info = RecipeTranslation.columns.find { |c| c.name == 'description' }
      expect(column_info.null).to be false
    end
  end

  describe 'difficulty_level enum' do
    let(:cuisine) do
      DataReference.find_or_create_by!(reference_type: 'cuisine', key: 'test') { |r| r.display_name = 'Test' }
    end

    let(:recipe) do
      recipe = Recipe.new(
        name: "Test Recipe",
        description: "A delicious recipe",
        source_language: "en",
        servings_original: 2,
        prep_minutes: 10,
        cook_minutes: 20,
        total_minutes: 30
      )
      recipe.recipe_steps.build(step_number: 1, instruction_original: "Test step")
      ig = recipe.ingredient_groups.build(name: "Ingredients", position: 1)
      ingredient = Ingredient.find_or_create_by!(canonical_name: "test ingredient") { |i| i.category = "vegetable" }
      ig.recipe_ingredients.build(ingredient_id: ingredient.id, ingredient_name: "test ingredient", amount: 1, unit: "cup", position: 1)
      recipe.recipe_cuisines.build(data_reference: cuisine)
      recipe
    end

    it 'supports easy, medium, hard values' do
      expect(Recipe.difficulty_levels.keys).to match_array(%w[easy medium hard])
    end

    it 'maps easy to 0, medium to 1, hard to 2' do
      expect(Recipe.difficulty_levels['easy']).to eq(0)
      expect(Recipe.difficulty_levels['medium']).to eq(1)
      expect(Recipe.difficulty_levels['hard']).to eq(2)
    end

    it 'accepts valid difficulty levels' do
      %w[easy medium hard].each do |level|
        recipe.difficulty_level = level
        expect(recipe).to be_valid
      end
    end

    it 'rejects invalid difficulty levels' do
      expect { recipe.difficulty_level = 'impossible' }.to raise_error(ArgumentError)
    end

    it 'requires difficulty_level to be present' do
      recipe.difficulty_level = nil
      expect(recipe).not_to be_valid
      expect(recipe.errors[:difficulty_level]).to include("can't be blank")
    end

    it 'provides query methods for each difficulty level' do
      recipe.difficulty_level = 'easy'
      recipe.save!

      recipe.reload
      expect(recipe.easy?).to be true
      expect(recipe.medium?).to be false
      expect(recipe.hard?).to be false
    end

    it 'allows querying recipes by difficulty_level scope' do
      recipe.difficulty_level = 'hard'
      recipe.save!

      expect(Recipe.hard).to include(recipe)
      expect(Recipe.easy).not_to include(recipe)
    end
  end
end
