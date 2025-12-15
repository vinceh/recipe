class RecipeStepImage < ApplicationRecord
  belongs_to :recipe
  has_one_attached :image

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :image, presence: true

  default_scope { order(:position) }
end
