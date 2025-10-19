class UserRecipeNote < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :note_type, presence: true, inclusion: { in: %w[recipe step ingredient] }
  validates :user_id, presence: true
  validates :recipe_id, presence: true
end
