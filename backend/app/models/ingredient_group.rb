class IngredientGroup < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

  belongs_to :recipe
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy

  accepts_nested_attributes_for :recipe_ingredients,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['ingredient_name'].blank? }

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :recipe_id, presence: true
  validates :position, uniqueness: { scope: :recipe_id }
end
