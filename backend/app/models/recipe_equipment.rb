class RecipeEquipment < ApplicationRecord
  belongs_to :recipe
  belongs_to :equipment

  validates :recipe_id, presence: true
  validates :equipment_id, presence: true
  validates :recipe_id, uniqueness: { scope: :equipment_id }
end
