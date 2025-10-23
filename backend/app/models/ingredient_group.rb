class IngredientGroup < ApplicationRecord
  belongs_to :recipe
  has_many :recipe_ingredients, dependent: :destroy
end
