class RecipeIngredient < ApplicationRecord
  extend Mobility
  translates :ingredient_name, :preparation_notes, backend: :table

  belongs_to :ingredient_group, inverse_of: :recipe_ingredients
  belongs_to :ingredient, optional: true
  belongs_to :unit, optional: true

  validates :ingredient_name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :ingredient_group, presence: true
  validates :amount, numericality: { greater_than: 0, allow_nil: true }

  def unit_name
    unit&.name
  end

  def unit_canonical_name=(value)
    return if value.blank?
    self.unit = Unit.find_by(canonical_name: value.downcase.strip)
  end

  def unit_canonical_name
    unit&.canonical_name
  end
end
