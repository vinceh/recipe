class IngredientGroup < ApplicationRecord
  belongs_to :recipe
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy

  default_scope { order(:position) }
end
