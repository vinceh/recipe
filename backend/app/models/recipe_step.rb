class RecipeStep < ApplicationRecord
  extend Mobility
  translates :instruction_original, backend: :table

  belongs_to :recipe

  validates :recipe_id, presence: true
  validates :step_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :step_number, uniqueness: { scope: :recipe_id }

  default_scope { order(:step_number) }
end
