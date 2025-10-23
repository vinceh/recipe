require 'rails_helper'

RSpec.describe IngredientAlias, type: :model do
  describe 'validations' do
    describe 'alias presence' do
      it 'requires alias to be present (AC-MODEL-ALIAS-001)' do
        alias_record = build(:ingredient_alias, alias: nil)
        expect(alias_record).not_to be_valid
        expect(alias_record.errors[:alias]).to include("can't be blank")
      end
    end

    describe 'ingredient association' do
      it 'requires ingredient association to be present (AC-MODEL-ALIAS-002)' do
        alias_record = build(:ingredient_alias, ingredient: nil)
        expect(alias_record).not_to be_valid
        expect(alias_record.errors[:ingredient]).to include("can't be blank")
      end
    end

    describe 'uniqueness scoped to ingredient and language' do
      it 'allows same alias with different language (AC-MODEL-ALIAS-003)' do
        ingredient = create(:ingredient)
        alias1 = ingredient.aliases.create!(alias: 'Kosher Salt', language: 'en')
        alias2 = build(:ingredient_alias, ingredient: ingredient, alias: 'Kosher Salt', language: 'ja')
        expect(alias2).to be_valid
      end

      it 'rejects duplicate alias with same language (AC-MODEL-ALIAS-004)' do
        ingredient = create(:ingredient)
        ingredient.aliases.create!(alias: 'Kosher Salt', language: 'en')
        duplicate = build(:ingredient_alias, ingredient: ingredient, alias: 'Kosher Salt', language: 'en')
        expect(duplicate).not_to be_valid
      end

      it 'allows same alias for different ingredients in same language' do
        ingredient1 = create(:ingredient, canonical_name: 'Salt')
        ingredient2 = create(:ingredient, canonical_name: 'Pepper')
        ingredient1.aliases.create!(alias: 'Seasoning', language: 'en')
        alias2 = build(:ingredient_alias, ingredient: ingredient2, alias: 'Seasoning', language: 'en')
        expect(alias2).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to ingredient' do
      alias_record = create(:ingredient_alias)
      expect(alias_record).to respond_to(:ingredient)
    end
  end
end
