class IngredientNutrition < ApplicationRecord
  self.table_name = 'ingredient_nutrition'

  belongs_to :ingredient

  validates :ingredient_id, presence: true
  validates :data_source, inclusion: { in: %w[nutritionix usda ai], allow_nil: true }
end
