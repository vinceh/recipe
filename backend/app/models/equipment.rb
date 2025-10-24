class Equipment < ApplicationRecord
  extend Mobility
  translates :canonical_name, backend: :table

  has_many :recipe_equipment, dependent: :destroy
  has_many :recipes, through: :recipe_equipment

  validates :canonical_name, presence: true, uniqueness: true
end
