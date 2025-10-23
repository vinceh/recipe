require 'rails_helper'

RSpec.describe IngredientGroup, type: :model do
  let(:recipe) { create(:recipe) }

  describe 'validations' do
    it 'validates presence of name' do
      group = build(:ingredient_group, recipe: recipe, name: nil)
      expect(group).not_to be_valid
      expect(group.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of position' do
      group = build(:ingredient_group, recipe: recipe, position: nil)
      expect(group).not_to be_valid
      expect(group.errors[:position]).to include("can't be blank")
    end

    it 'validates presence of recipe_id' do
      group = build(:ingredient_group, recipe: nil, position: 1)
      expect(group).not_to be_valid
      expect(group.errors[:recipe_id]).to include("can't be blank")
    end
  end

  describe 'uniqueness constraints' do
    # AC-PHASE2-STEP6-001: Should fail when creating duplicate position for same recipe
    it 'fails to create ingredient_group with duplicate position for same recipe' do
      create(:ingredient_group, recipe: recipe, position: 1)
      new_group = build(:ingredient_group, recipe: recipe, position: 1)

      expect(new_group).not_to be_valid
      expect(new_group.errors[:position]).to include('has already been taken')
      expect { new_group.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    # AC-PHASE2-STEP6-002: Different recipes can have same position
    it 'allows same position for different recipes' do
      other_recipe = create(:recipe)
      group1 = create(:ingredient_group, recipe: recipe, position: 1)
      group2 = create(:ingredient_group, recipe: other_recipe, position: 1)

      expect(group1).to be_valid
      expect(group2).to be_valid
      expect(group1.position).to eq(group2.position)
    end

    # AC-PHASE2-STEP6-013: Nil position should fail validation
    it 'rejects ingredient_group with nil position' do
      group = build(:ingredient_group, recipe: recipe, position: nil)

      expect(group).not_to be_valid
      expect(group.errors[:position]).to include("can't be blank")
    end

    # AC-PHASE2-STEP6-014: Zero and negative positions should fail
    it 'rejects ingredient_group with position 0' do
      group = build(:ingredient_group, recipe: recipe, position: 0)

      expect(group).not_to be_valid
      expect(group.errors[:position]).to include('must be greater than or equal to 1')
    end

    it 'rejects ingredient_group with negative position' do
      group = build(:ingredient_group, recipe: recipe, position: -1)

      expect(group).not_to be_valid
      expect(group.errors[:position]).to include('must be greater than or equal to 1')
    end

    # AC-PHASE2-STEP6-022: Update to duplicate position should fail
    it 'fails to update position to duplicate value' do
      group1 = create(:ingredient_group, recipe: recipe, position: 1)
      group2 = create(:ingredient_group, recipe: recipe, position: 2)

      group2.position = 1
      expect(group2).not_to be_valid
      expect(group2.errors[:position]).to include('has already been taken')
    end
  end

  describe 'ordering' do
    # AC-PHASE2-STEP6-020: IngredientGroups should be ordered by position
    it 'returns ingredient_groups in position order' do
      group3 = create(:ingredient_group, recipe: recipe, position: 3)
      group1 = create(:ingredient_group, recipe: recipe, position: 1)
      group2 = create(:ingredient_group, recipe: recipe, position: 2)

      groups = recipe.ingredient_groups

      expect(groups.map(&:position)).to eq([1, 2, 3])
    end
  end

  describe 'nested attributes' do
    # AC-PHASE2-STEP6-005: Creating with nested recipe_ingredients
    it 'creates ingredient_group with nested recipe_ingredients' do
      attributes = {
        name: 'Dry Ingredients',
        position: 1,
        recipe_ingredients_attributes: [
          { ingredient_name: 'flour', amount: 2, unit: 'cup', position: 1 },
          { ingredient_name: 'sugar', amount: 0.5, unit: 'cup', position: 2 }
        ]
      }

      group = recipe.ingredient_groups.create!(attributes)

      expect(group).to be_persisted
      expect(group.recipe_ingredients.count).to eq(2)
      expect(group.recipe_ingredients.first.ingredient_name).to eq('flour')
      expect(group.recipe_ingredients.last.ingredient_name).to eq('sugar')
    end

    # AC-PHASE2-STEP6-007: Reject_if prevents empty nested records
    it 'does not create ingredient_group with empty nested attributes' do
      attributes = {
        name: 'Main Ingredients',
        position: 1,
        recipe_ingredients_attributes: [
          {} # Empty hash should be rejected
        ]
      }

      group = recipe.ingredient_groups.create!(attributes)

      expect(group.recipe_ingredients.count).to eq(0)
    end
  end

  describe 'cascade deletion' do
    # AC-PHASE2-STEP6-017: Deleting recipe should cascade delete ingredient_groups
    it 'deletes ingredient_groups when recipe is deleted' do
      group = create(:ingredient_group, recipe: recipe, position: 1)
      group_id = group.id

      recipe.destroy

      expect(IngredientGroup.find_by(id: group_id)).to be_nil
    end

    # AC-PHASE2-STEP6-017: Cascade delete recipe_ingredients when ingredient_group deleted
    it 'deletes recipe_ingredients when ingredient_group is deleted' do
      group = create(:ingredient_group, recipe: recipe, position: 1)
      ingredient = create(:recipe_ingredient, ingredient_group: group, position: 1)
      ingredient_id = ingredient.id

      group.destroy

      expect(RecipeIngredient.find_by(id: ingredient_id)).to be_nil
    end
  end

  describe 'position gaps' do
    # AC-PHASE2-STEP6-019: Position gaps are allowed after deletion
    it 'allows position gaps after deletion' do
      group1 = create(:ingredient_group, recipe: recipe, position: 1)
      group2 = create(:ingredient_group, recipe: recipe, position: 2)
      group3 = create(:ingredient_group, recipe: recipe, position: 3)

      group2.destroy

      remaining = recipe.ingredient_groups
      expect(remaining.map(&:position)).to eq([1, 3])
    end
  end
end
