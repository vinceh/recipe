require 'rails_helper'

RSpec.describe RecipeStep, type: :model do
  let(:recipe) { create(:recipe) }

  describe 'validations' do
    it 'validates presence of recipe_id' do
      step = build(:recipe_step, recipe: nil, step_number: 1)
      expect(step).not_to be_valid
      expect(step.errors[:recipe_id]).to include("can't be blank")
    end

    it 'validates presence of step_number' do
      step = build(:recipe_step, recipe: recipe, step_number: nil)
      expect(step).not_to be_valid
      expect(step.errors[:step_number]).to include("can't be blank")
    end
  end

  describe 'uniqueness constraints' do
    # AC-PHASE2-STEP6-003: Should fail when creating duplicate step_number for same recipe
    it 'fails to create recipe_step with duplicate step_number for same recipe' do
      create(:recipe_step, recipe: recipe, step_number: 1)
      new_step = build(:recipe_step, recipe: recipe, step_number: 1)

      expect(new_step).not_to be_valid
      expect(new_step.errors[:step_number]).to include('has already been taken')
      expect { new_step.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    # AC-PHASE2-STEP6-004: Different recipes can have same step_number
    it 'allows same step_number for different recipes' do
      other_recipe = create(:recipe)
      step1 = create(:recipe_step, recipe: recipe, step_number: 1)
      step2 = create(:recipe_step, recipe: other_recipe, step_number: 1)

      expect(step1).to be_valid
      expect(step2).to be_valid
      expect(step1.step_number).to eq(step2.step_number)
    end

    # AC-PHASE2-STEP6-015: Nil step_number should fail validation
    it 'rejects recipe_step with nil step_number' do
      step = build(:recipe_step, recipe: recipe, step_number: nil)

      expect(step).not_to be_valid
      expect(step.errors[:step_number]).to include("can't be blank")
    end

    # AC-PHASE2-STEP6-015: Zero and negative step_numbers should fail
    it 'rejects recipe_step with step_number 0' do
      step = build(:recipe_step, recipe: recipe, step_number: 0)

      expect(step).not_to be_valid
      expect(step.errors[:step_number]).to include('must be greater than 0')
    end

    it 'rejects recipe_step with negative step_number' do
      step = build(:recipe_step, recipe: recipe, step_number: -1)

      expect(step).not_to be_valid
      expect(step.errors[:step_number]).to include('must be greater than 0')
    end

    # AC-PHASE2-STEP6-023: Update to duplicate step_number should fail
    it 'fails to update step_number to duplicate value' do
      step1 = create(:recipe_step, recipe: recipe, step_number: 1)
      step2 = create(:recipe_step, recipe: recipe, step_number: 2)

      step2.step_number = 1
      expect(step2).not_to be_valid
      expect(step2.errors[:step_number]).to include('has already been taken')
    end
  end

  describe 'ordering' do
    # AC-PHASE2-STEP6-021: RecipeSteps should be ordered by step_number
    it 'returns recipe_steps in step_number order' do
      step3 = create(:recipe_step, recipe: recipe, step_number: 3)
      step1 = create(:recipe_step, recipe: recipe, step_number: 1)
      step2 = create(:recipe_step, recipe: recipe, step_number: 2)

      steps = recipe.recipe_steps

      expect(steps.map(&:step_number)).to eq([1, 2, 3])
    end

    it 'maintains order consistency across multiple queries' do
      step3 = create(:recipe_step, recipe: recipe, step_number: 3)
      step1 = create(:recipe_step, recipe: recipe, step_number: 1)
      step2 = create(:recipe_step, recipe: recipe, step_number: 2)

      first_query = recipe.recipe_steps.map(&:step_number)
      second_query = recipe.recipe_steps.map(&:step_number)

      expect(first_query).to eq([1, 2, 3])
      expect(second_query).to eq([1, 2, 3])
    end
  end

  describe 'instructions' do
    # AC-PHASE2-STEP6-006: Recipe steps store instructions
    it 'stores instruction variants' do
      step = create(:recipe_step,
        recipe: recipe,
        step_number: 1,
        instruction_original: 'Mix flour and water',
        instruction_easier: 'Combine ingredients',
        instruction_no_equipment: 'Mix by hand'
      )

      expect(step.instruction_original).to eq('Mix flour and water')
      expect(step.instruction_easier).to eq('Combine ingredients')
      expect(step.instruction_no_equipment).to eq('Mix by hand')
    end

    it 'allows nil instruction variants' do
      step = create(:recipe_step,
        recipe: recipe,
        step_number: 1,
        instruction_original: 'Mix ingredients',
        instruction_easier: nil,
        instruction_no_equipment: nil
      )

      expect(step.instruction_original).to eq('Mix ingredients')
      expect(step.instruction_easier).to be_nil
      expect(step.instruction_no_equipment).to be_nil
    end
  end

  describe 'cascade deletion' do
    # AC-PHASE2-STEP6-018: Deleting recipe should cascade delete recipe_steps
    it 'deletes recipe_steps when recipe is deleted' do
      step = create(:recipe_step, recipe: recipe, step_number: 1)
      step_id = step.id

      recipe.destroy

      expect(RecipeStep.find_by(id: step_id)).to be_nil
    end
  end

  describe 'position gaps' do
    # AC-PHASE2-STEP6-019: Position gaps are allowed after deletion (applies to step_numbers too)
    it 'allows step_number gaps after deletion' do
      step1 = create(:recipe_step, recipe: recipe, step_number: 1)
      step2 = create(:recipe_step, recipe: recipe, step_number: 2)
      step3 = create(:recipe_step, recipe: recipe, step_number: 3)

      step2.destroy

      remaining = recipe.recipe_steps
      expect(remaining.map(&:step_number)).to eq([1, 3])
    end
  end
end
