class RecipeDishType < ApplicationRecord
  belongs_to :recipe
  belongs_to :data_reference

  validates :recipe_id, uniqueness: { scope: :data_reference_id }
end
