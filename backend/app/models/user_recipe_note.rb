class UserRecipeNote < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :user, presence: true
  validates :recipe, presence: true
  validates :user_id, uniqueness: { scope: :recipe_id }
end
