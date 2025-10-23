require 'rails_helper'

RSpec.describe UserFavorite, type: :model do
  describe 'validations' do
    describe 'user association required' do
      it 'requires user association (AC-MODEL-FAVORITE-001)' do
        favorite = build(:user_favorite, user: nil)
        expect(favorite).not_to be_valid
        expect(favorite.errors[:user]).to include("can't be blank")
      end
    end

    describe 'recipe association required' do
      it 'requires recipe association (AC-MODEL-FAVORITE-002)' do
        favorite = build(:user_favorite, recipe: nil)
        expect(favorite).not_to be_valid
        expect(favorite.errors[:recipe]).to include("can't be blank")
      end
    end

    describe 'user-recipe uniqueness' do
      it 'enforces uniqueness of user-recipe combination (AC-MODEL-FAVORITE-003)' do
        user = create(:user)
        recipe = create(:recipe)
        user.user_favorites.create!(recipe_id: recipe.id)

        duplicate = build(:user_favorite, user_id: user.id, recipe_id: recipe.id)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('has already favorited this recipe')
      end
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      favorite = create(:user_favorite)
      expect(favorite).to respond_to(:user)
    end

    it 'belongs to recipe' do
      favorite = create(:user_favorite)
      expect(favorite).to respond_to(:recipe)
    end
  end
end
