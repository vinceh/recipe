class Equipment < ApplicationRecord
  has_many :recipe_equipment
  has_many :recipes, through: :recipe_equipment
end
