class RecipeCuisine < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :data_reference

  validates :data_reference_id, presence: true
  validates :recipe_id, uniqueness: { scope: :data_reference_id }, allow_nil: true
end
