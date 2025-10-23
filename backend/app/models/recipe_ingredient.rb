class RecipeIngredient < ApplicationRecord
  belongs_to :ingredient_group
  belongs_to :ingredient, optional: true

  validates :ingredient_name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :ingredient_group_id, presence: true
  validates :amount, numericality: { greater_than: 0, allow_nil: true }
end
