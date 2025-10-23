class RecipeIngredient < ApplicationRecord
  belongs_to :ingredient_group
  belongs_to :ingredient, optional: true

  default_scope { order(:position) }
end
