class RecipeStep < ApplicationRecord
  belongs_to :recipe

  default_scope { order(:step_number) }
end
