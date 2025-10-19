class UserFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :user_id, presence: true, uniqueness: { scope: :recipe_id }
  validates :recipe_id, presence: true
end
