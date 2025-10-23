class RecipeNutrition < ApplicationRecord
  belongs_to :recipe

  validates :recipe_id, presence: true, uniqueness: true
  validates :calories, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :protein_g, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :carbs_g, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :fat_g, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :fiber_g, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :sodium_mg, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :sugar_g, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
