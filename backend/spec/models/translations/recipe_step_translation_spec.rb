require 'rails_helper'

describe 'RecipeStep Translations (AC-PHASE4-MODEL-005)', type: :model do
  let(:recipe) { create(:recipe) }
  let(:recipe_step) do
    create(:recipe_step,
           recipe: recipe,
           instruction_original: 'Heat oil in pan')
  end

  describe 'Translation Declaration' do
    it 'translates :instruction_original field (AC-PHASE4-MODEL-005)' do
      expect(recipe_step).to respond_to(:instruction_original=)
      expect(recipe_step).to respond_to(:instruction_original)
    end

    it 'uses Table backend for instruction_original field' do
      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: 'パンで油を熱する')
      end

      translation = RecipeStepTranslation.find_by(
        recipe_step_id: recipe_step.id,
        locale: 'ja'
      )
      expect(translation).to be_present
      expect(translation.instruction_original).to eq('パンで油を熱する')
    end
  end

  describe 'Reading and Writing' do
    it 'writes instruction in different locales' do
      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: 'パンで油を熱する')
      end

      translation = RecipeStepTranslation.find_by(
        recipe_step_id: recipe_step.id,
        locale: 'ja'
      )
      expect(translation.instruction_original).to eq('パンで油を熱する')
    end

    it 'reads instruction in current locale' do
      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: 'パンで油を熱する')
      end

      I18n.with_locale(:ja) do
        expect(recipe_step.instruction_original).to eq('パンで油を熱する')
      end
    end

    it 'each locale can have different translation' do
      I18n.with_locale(:en) do
        recipe_step.update(instruction_original: 'English original')
      end

      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: '日本語オリジナル')
      end

      I18n.with_locale(:en) do
        expect(recipe_step.instruction_original).to eq('English original')
      end

      I18n.with_locale(:ja) do
        expect(recipe_step.instruction_original).to eq('日本語オリジナル')
      end
    end
  end

  describe 'Cascade Delete' do
    it 'deletes translations when step deleted' do
      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: 'パンで油を熱する')
      end

      trans_count = RecipeStepTranslation.where(
        recipe_step_id: recipe_step.id
      ).count
      expect(trans_count).to be > 0

      recipe_step.destroy

      expect(RecipeStepTranslation.where(
        recipe_step_id: recipe_step.id
      ).count).to eq(0)
    end
  end

  describe 'Ordering' do
    it 'respects default_scope order by step_number' do
      step1 = create(:recipe_step, recipe: recipe, step_number: 1)
      step3 = create(:recipe_step, recipe: recipe, step_number: 3)
      step2 = create(:recipe_step, recipe: recipe, step_number: 2)

      steps = recipe.recipe_steps
      expect(steps.first.step_number).to eq(1)
      expect(steps.last.step_number).to eq(3)
    end
  end

  describe 'Null and Empty Values' do
    it 'handles nil instruction' do
      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: nil)
      end

      translation = RecipeStepTranslation.find_by(
        recipe_step_id: recipe_step.id,
        locale: 'ja'
      )
      expect(translation.instruction_original).to be_nil
    end

    it 'handles empty string instruction' do
      I18n.with_locale(:ja) do
        recipe_step.update(instruction_original: '')
      end

      I18n.with_locale(:ja) do
        # Mobility presence plugin converts empty strings to nil
        expect(recipe_step.instruction_original).to be_nil
      end
    end
  end

  describe 'Uniqueness Constraint' do
    it 'enforces uniqueness per step in same locale' do
      I18n.with_locale(:en) do
        recipe_step.update(instruction_original: 'Unique')
      end

      duplicate = RecipeStepTranslation.build(
        recipe_step_id: recipe_step.id,
        locale: 'en',
        instruction_original: 'Different'
      )
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
