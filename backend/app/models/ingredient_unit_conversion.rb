class IngredientUnitConversion < ApplicationRecord
  belongs_to :ingredient
  belongs_to :unit

  validates :grams, presence: true, numericality: { greater_than: 0 }
  validates :unit_id, uniqueness: { scope: :ingredient_id, message: "already exists for this ingredient" }
end
