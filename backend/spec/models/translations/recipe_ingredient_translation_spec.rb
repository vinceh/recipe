require 'rails_helper'

describe 'RecipeIngredient Translations (AC-PHASE4-MODEL-003)', type: :model do
  let(:recipe) { create(:recipe) }
  let(:ingredient_group) { create(:ingredient_group, recipe: recipe) }
  let(:recipe_ingredient) do
    create(:recipe_ingredient,
           ingredient_group: ingredient_group,
           ingredient_name: 'Chicken Breast',
           preparation_notes: 'Diced')
  end

  describe 'Translation Declaration' do
    it 'translates :ingredient_name field (AC-PHASE4-MODEL-003)' do
      expect(recipe_ingredient).to respond_to(:ingredient_name=)
      expect(recipe_ingredient).to respond_to(:ingredient_name)
    end

    it 'translates :preparation_notes field (AC-PHASE4-MODEL-003)' do
      expect(recipe_ingredient).to respond_to(:preparation_notes=)
      expect(recipe_ingredient).to respond_to(:preparation_notes)
    end

    it 'uses Table backend for both fields' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(
          ingredient_name: '鶏胸肉',
          preparation_notes: 'さいの目切り'
        )
      end

      translation = RecipeIngredientTranslation.find_by(
        recipe_ingredient_id: recipe_ingredient.id,
        locale: 'ja'
      )
      expect(translation).to be_present
      expect(translation.ingredient_name).to eq('鶏胸肉')
      expect(translation.preparation_notes).to eq('さいの目切り')
    end
  end

  describe 'Independent Field Translation' do
    it 'stores and reads ingredient_name independently' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(ingredient_name: '鶏胸肉')
      end

      I18n.with_locale(:ja) do
        expect(recipe_ingredient.ingredient_name).to eq('鶏胸肉')
      end
    end

    it 'stores and reads preparation_notes independently' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(preparation_notes: 'さいの目切り')
      end

      I18n.with_locale(:ja) do
        expect(recipe_ingredient.preparation_notes).to eq('さいの目切り')
      end
    end

    it 'each field has different values across locales' do
      I18n.with_locale(:en) do
        recipe_ingredient.update(ingredient_name: 'Chicken')
      end

      I18n.with_locale(:ja) do
        recipe_ingredient.update(ingredient_name: '鶏肉')
      end

      I18n.with_locale(:en) do
        expect(recipe_ingredient.ingredient_name).to eq('Chicken')
      end

      I18n.with_locale(:ja) do
        expect(recipe_ingredient.ingredient_name).to eq('鶏肉')
      end
    end

    it 'allows partial field translation' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(ingredient_name: '鶏胸肉')
        # preparation_notes stays in English
      end

      I18n.with_locale(:ja) do
        expect(recipe_ingredient.ingredient_name).to eq('鶏胸肉')
        # Falls back to en
        expect(recipe_ingredient.preparation_notes).to eq('Diced')
      end
    end
  end

  describe 'Reading and Writing Both Fields' do
    it 'writes multiple fields in different locales' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(
          ingredient_name: '鶏胸肉',
          preparation_notes: 'さいの目切り'
        )
      end

      translation = RecipeIngredientTranslation.find_by(
        recipe_ingredient_id: recipe_ingredient.id,
        locale: 'ja'
      )
      expect(translation.ingredient_name).to eq('鶏胸肉')
      expect(translation.preparation_notes).to eq('さいの目切り')
    end

    it 'reads both fields in current locale' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(
          ingredient_name: '鶏胸肉',
          preparation_notes: 'さいの目切り'
        )
      end

      I18n.with_locale(:ja) do
        expect(recipe_ingredient.ingredient_name).to eq('鶏胸肉')
        expect(recipe_ingredient.preparation_notes).to eq('さいの目切り')
      end
    end

    it 'falls back independently for each field' do
      I18n.with_locale(:en) do
        recipe_ingredient.update(
          ingredient_name: 'Chicken',
          preparation_notes: 'Diced'
        )
      end

      I18n.with_locale(:ja) do
        recipe_ingredient.update(ingredient_name: '鶏肉')
        # preparation_notes not translated to ja
      end

      I18n.with_locale(:ja) do
        expect(recipe_ingredient.ingredient_name).to eq('鶏肉')
        expect(recipe_ingredient.preparation_notes).to eq('Diced') # Falls back to en
      end
    end
  end

  describe 'Cascade Delete' do
    it 'deletes translations when ingredient deleted' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(ingredient_name: '鶏肉')
      end

      trans_count = RecipeIngredientTranslation.where(
        recipe_ingredient_id: recipe_ingredient.id
      ).count
      expect(trans_count).to be > 0

      recipe_ingredient.destroy

      expect(RecipeIngredientTranslation.where(
        recipe_ingredient_id: recipe_ingredient.id
      ).count).to eq(0)
    end
  end

  describe 'Null and Empty Values' do
    it 'handles nil for individual fields' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(
          ingredient_name: '鶏肉',
          preparation_notes: nil
        )
      end

      translation = RecipeIngredientTranslation.find_by(
        recipe_ingredient_id: recipe_ingredient.id,
        locale: 'ja'
      )
      expect(translation.ingredient_name).to eq('鶏肉')
      expect(translation.preparation_notes).to be_nil
    end

    it 'handles empty string' do
      I18n.with_locale(:ja) do
        recipe_ingredient.update(preparation_notes: '')
      end

      translation = RecipeIngredientTranslation.find_by(
        recipe_ingredient_id: recipe_ingredient.id,
        locale: 'ja'
      )
      # Mobility presence plugin converts empty strings to nil
      expect(translation.preparation_notes).to be_nil
    end
  end

  describe 'Uniqueness Constraint' do
    it 'enforces uniqueness per ingredient in same locale' do
      I18n.with_locale(:en) do
        recipe_ingredient.update(ingredient_name: 'Chicken')
      end

      duplicate = RecipeIngredientTranslation.build(
        recipe_ingredient_id: recipe_ingredient.id,
        locale: 'en',
        ingredient_name: 'Different Chicken'
      )
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
