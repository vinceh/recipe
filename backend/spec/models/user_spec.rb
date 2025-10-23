require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    describe 'email presence' do
      it 'requires email to be present (AC-MODEL-USER-001)' do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it 'rejects whitespace-only email (AC-MODEL-USER-002)' do
        user = build(:user, email: '   ')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end
    end

    describe 'email format' do
      it 'validates email format (AC-MODEL-USER-003)' do
        user = build(:user, email: 'not-an-email')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it 'accepts valid email formats' do
        %w[user@example.com john.doe@example.co.uk test+tag@example.org].each do |email|
          user = build(:user, email: email)
          expect(user).to be_valid, "Expected #{email} to be valid"
        end
      end
    end

    describe 'email uniqueness' do
      it 'enforces email uniqueness (AC-MODEL-USER-004)' do
        create(:user, email: 'john@example.com')
        duplicate = build(:user, email: 'john@example.com')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:email]).to include('has already been taken')
      end

      it 'enforces case-insensitive email uniqueness (AC-MODEL-USER-005)' do
        create(:user, email: 'John@Example.com')
        duplicate = build(:user, email: 'john@example.com')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:email]).to include('has already been taken')
      end
    end

    describe 'password presence' do
      it 'requires password to be present (AC-MODEL-USER-006)' do
        user = build(:user, password: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end
    end

    describe 'password length' do
      it 'enforces minimum password length (AC-MODEL-USER-007)' do
        user = build(:user, password: 'short')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
      end

      it 'accepts valid password lengths' do
        user = build(:user, password: 'ValidPassword123', password_confirmation: 'ValidPassword123')
        expect(user).to be_valid
      end
    end

    describe 'role enum' do
      it 'assigns default role (AC-MODEL-USER-008)' do
        user = User.new(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
        expect(user.role).to eq('user')
      end

      it 'accepts valid role values (AC-MODEL-USER-009)' do
        %w[user admin].each do |role|
          user = build(:user, role: role)
          expect(user).to be_valid, "Expected role '#{role}' to be valid"
        end
      end

      it 'rejects invalid role values (AC-MODEL-USER-010)' do
        expect { build(:user, role: 'superuser') }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'associations' do
    it 'has many user recipe notes' do
      user = create(:user)
      expect(user).to respond_to(:user_recipe_notes)
    end

    it 'has many user favorites' do
      user = create(:user)
      expect(user).to respond_to(:user_favorites)
    end
  end

  describe 'cascade deletion' do
    it 'cascades delete user_recipe_notes when user is deleted (AC-MODEL-USER-011)' do
      user = create(:user)
      recipe = create(:recipe)
      note = user.user_recipe_notes.create!(recipe_id: recipe.id, notes: 'Test note')
      note_id = note.id

      user.destroy
      expect(UserRecipeNote.find_by(id: note_id)).to be_nil
    end

    it 'cascades delete user_favorites when user is deleted (AC-MODEL-USER-011)' do
      user = create(:user)
      recipe = create(:recipe)
      favorite = user.user_favorites.create!(recipe_id: recipe.id)
      favorite_id = favorite.id

      user.destroy
      expect(UserFavorite.find_by(id: favorite_id)).to be_nil
    end
  end
end
