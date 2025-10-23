require 'rails_helper'

RSpec.describe UserRecipeNote, type: :model do
  describe 'validations' do
    describe 'user association required' do
      it 'requires user association (AC-MODEL-NOTE-001)' do
        note = build(:user_recipe_note, user: nil)
        expect(note).not_to be_valid
        expect(note.errors[:user]).to include("can't be blank")
      end
    end

    describe 'recipe association required' do
      it 'requires recipe association (AC-MODEL-NOTE-002)' do
        note = build(:user_recipe_note, recipe: nil)
        expect(note).not_to be_valid
        expect(note.errors[:recipe]).to include("can't be blank")
      end
    end

    describe 'user-recipe uniqueness' do
      it 'enforces uniqueness of user-recipe combination (AC-MODEL-NOTE-003)' do
        user = create(:user)
        recipe = create(:recipe)
        user.user_recipe_notes.create!(recipe_id: recipe.id, notes: 'Test note')

        duplicate = build(:user_recipe_note, user_id: user.id, recipe_id: recipe.id)
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      note = create(:user_recipe_note)
      expect(note).to respond_to(:user)
    end

    it 'belongs to recipe' do
      note = create(:user_recipe_note)
      expect(note).to respond_to(:recipe)
    end
  end
end
