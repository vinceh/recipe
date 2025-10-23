class Equipment < ApplicationRecord
  has_many :recipe_equipment, dependent: :destroy
  has_many :recipes, through: :recipe_equipment
end
