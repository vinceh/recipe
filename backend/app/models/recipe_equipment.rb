class RecipeEquipment < ApplicationRecord
  belongs_to :recipe
  belongs_to :equipment

  validates :recipe_id, uniqueness: { scope: :equipment_id }
end
