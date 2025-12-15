class Ingredient < ApplicationRecord
  CATEGORIES = %w[
    vegetable protein grain spice dairy other
    fruit legume nut_seed oil_fat condiment sweetener beverage seafood herb
  ].freeze

  has_one :nutrition, class_name: 'IngredientNutrition', dependent: :destroy
  has_many :aliases, class_name: 'IngredientAlias', dependent: :destroy
  has_many :unit_conversions, class_name: 'IngredientUnitConversion', dependent: :destroy
  has_many :recipe_ingredients, dependent: :nullify

  validates :canonical_name, presence: true, uniqueness: { case_sensitive: false }
  validates :category, inclusion: { in: CATEGORIES, allow_nil: true }
end
