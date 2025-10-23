class RecipeStep < ApplicationRecord
  belongs_to :recipe
  has_many :recipe_step_translations, dependent: :destroy

  default_scope { order(:step_number) }
end
