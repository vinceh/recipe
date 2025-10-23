class RecipeCuisine < ApplicationRecord
  belongs_to :recipe
  belongs_to :data_reference
end
