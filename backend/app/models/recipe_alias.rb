class RecipeAlias < ApplicationRecord
  belongs_to :recipe

  validates :alias_name, presence: true
  validates :recipe_id, presence: true
  validates :recipe_id, uniqueness: { scope: [:alias_name, :language] }
end
