require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'validations' do
    describe 'canonical_name presence' do
      it 'requires canonical_name to be present (AC-MODEL-INGREDIENT-001)' do
        ingredient = build(:ingredient, canonical_name: nil)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:canonical_name]).to include("can't be blank")
      end

      it 'rejects whitespace-only canonical_name (AC-MODEL-INGREDIENT-002)' do
        ingredient = build(:ingredient, canonical_name: '   ')
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:canonical_name]).to include("can't be blank")
      end
    end

    describe 'canonical_name uniqueness' do
      it 'enforces canonical_name uniqueness (AC-MODEL-INGREDIENT-003)' do
        create(:ingredient, canonical_name: 'Salt')
        duplicate = build(:ingredient, canonical_name: 'Salt')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:canonical_name]).to include('has already been taken')
      end

      it 'enforces case-insensitive canonical_name uniqueness (AC-MODEL-INGREDIENT-004)' do
        create(:ingredient, canonical_name: 'Salt')
        duplicate = build(:ingredient, canonical_name: 'SALT')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:canonical_name]).to include('has already been taken')
      end
    end
  end

  describe 'associations' do
    it 'has many ingredient aliases' do
      ingredient = create(:ingredient)
      expect(ingredient).to respond_to(:ingredient_aliases)
    end

    it 'has many recipe ingredients' do
      ingredient = create(:ingredient)
      expect(ingredient).to respond_to(:recipe_ingredients)
    end
  end

  describe 'cascade deletion' do
    it 'cascades delete ingredient aliases when ingredient is deleted (AC-MODEL-INGREDIENT-005)' do
      ingredient = create(:ingredient)
      alias1 = ingredient.ingredient_aliases.create!(alias_name: 'Rock Salt', language: 'en')
      alias2 = ingredient.ingredient_aliases.create!(alias_name: 'Sea Salt', language: 'en')
      alias1_id = alias1.id
      alias2_id = alias2.id

      ingredient.destroy
      expect(IngredientAlias.find_by(id: alias1_id)).to be_nil
      expect(IngredientAlias.find_by(id: alias2_id)).to be_nil
    end
  end
end
