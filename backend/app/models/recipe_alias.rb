class RecipeAlias < ApplicationRecord
  belongs_to :recipe

  validates :alias_name, presence: true
  validates :recipe, presence: true
  validates :recipe_id, uniqueness: { scope: [:alias_name, :language] }
end
