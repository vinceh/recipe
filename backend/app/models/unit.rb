class Unit < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

  enum :category, {
    unit_volume: 0,
    unit_weight: 1,
    unit_quantity: 2,
    unit_length: 3,
    unit_other: 4
  }

  has_many :recipe_ingredients, dependent: :nullify
  has_many :ingredient_unit_conversions, dependent: :destroy

  validates :canonical_name, presence: true, uniqueness: true
  validates :category, presence: true

  scope :by_category, ->(cat) { where(category: cat) }
  scope :alphabetical, -> { order(:canonical_name) }
end
