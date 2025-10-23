class IngredientGroup < ApplicationRecord
  belongs_to :recipe
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :recipe_id, presence: true
end
