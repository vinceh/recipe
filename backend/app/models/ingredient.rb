class Ingredient < ApplicationRecord
  has_one :nutrition, class_name: 'IngredientNutrition', dependent: :destroy
  has_many :aliases, class_name: 'IngredientAlias', dependent: :destroy
  has_many :recipe_ingredients, dependent: :nullify

  validates :canonical_name, presence: true, uniqueness: { case_sensitive: false }
  validates :category, inclusion: { in: %w[vegetable protein grain spice dairy other], allow_nil: true }
end
