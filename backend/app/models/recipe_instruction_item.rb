class RecipeInstructionItem < ApplicationRecord
  extend Mobility
  translates :content, backend: :table

  belongs_to :recipe
  has_one_attached :image

  enum :item_type, { heading: 'heading', text: 'text', image: 'image' }

  validates :item_type, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :content, presence: true, if: -> { heading? || text? }

  default_scope { order(:position) }
end
