require 'rails_helper'

describe 'IngredientGroup Translations (AC-PHASE4-MODEL-002)', type: :model do
  let(:recipe) { create(:recipe) }
  let(:ingredient_group) { create(:ingredient_group, recipe: recipe, name: 'Main Ingredients') }

  describe 'Translation Declaration' do
    it 'translates :name field (AC-PHASE4-MODEL-002)' do
      expect(ingredient_group).to respond_to(:name=)
      expect(ingredient_group).to respond_to(:name)
    end

    it 'uses Table backend for translations' do
      I18n.with_locale(:ja) do
        ingredient_group.update(name: 'メイン材料')
      end

      translation = IngredientGroupTranslation.find_by(
        ingredient_group_id: ingredient_group.id,
        locale: 'ja'
      )
      expect(translation).to be_present
      expect(translation.name).to eq('メイン材料')
    end

    it 'is scoped to ingredient_group and locale' do
      I18n.with_locale(:ja) { ingredient_group.update(name: 'メイン材料') }

      other_group = create(:ingredient_group, recipe: recipe, name: 'Side')
      I18n.with_locale(:ja) { other_group.update(name: '副材料') }

      ja_trans = IngredientGroupTranslation.find_by(
        ingredient_group_id: ingredient_group.id,
        locale: 'ja'
      )
      expect(ja_trans.name).to eq('メイン材料')

      other_trans = IngredientGroupTranslation.find_by(
        ingredient_group_id: other_group.id,
        locale: 'ja'
      )
      expect(other_trans.name).to eq('副材料')
    end
  end

  describe 'Reading and Writing' do
    it 'reads translation in current locale' do
      I18n.with_locale(:ja) { ingredient_group.update(name: 'メイン材料') }

      I18n.with_locale(:ja) do
        expect(ingredient_group.name).to eq('メイン材料')
      end
    end

    it 'writes translation to current locale' do
      I18n.with_locale(:en) do
        ingredient_group.update(name: 'Updated Group')
      end

      translation = IngredientGroupTranslation.find_by(
        ingredient_group_id: ingredient_group.id,
        locale: 'en'
      )
      expect(translation.name).to eq('Updated Group')
    end

    it 'falls back to fallback locale when missing' do
      I18n.with_locale(:en) { ingredient_group.update(name: 'English Group') }

      I18n.with_locale(:ja) do
        # No ja translation, should fallback to en
        expect(ingredient_group.name).to eq('English Group')
      end
    end
  end

  describe 'Cascade Delete' do
    it 'deletes translations when ingredient_group deleted' do
      I18n.with_locale(:ja) { ingredient_group.update(name: 'メイン材料') }

      trans_count = IngredientGroupTranslation.where(
        ingredient_group_id: ingredient_group.id
      ).count
      expect(trans_count).to be > 0

      ingredient_group.destroy

      expect(IngredientGroupTranslation.where(
        ingredient_group_id: ingredient_group.id
      ).count).to eq(0)
    end
  end

  describe 'Querying' do
    before do
      create(:ingredient_group, recipe: recipe, name: 'Main')
      create(:ingredient_group, recipe: recipe, name: 'Sides')
    end

    it 'queries by translated field' do
      I18n.with_locale(:en) do
        results = IngredientGroup.i18n.where(name: 'Main')
        expect(results).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe 'Uniqueness Validation' do
    it 'enforces uniqueness in same locale' do
      create(:ingredient_group, recipe: recipe, name: 'Unique')

      duplicate = build(:ingredient_group, recipe: recipe, name: 'Unique')
      expect(duplicate).not_to be_valid
    end

    it 'allows same value in different locales' do
      I18n.with_locale(:en) { ingredient_group.update(name: 'Shared') }

      I18n.with_locale(:ja) do
        ingredient_group.name = 'Shared'
        expect(ingredient_group).to be_valid
      end
    end
  end
end
