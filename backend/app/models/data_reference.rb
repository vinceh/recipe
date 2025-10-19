class DataReference < ApplicationRecord
  validates :reference_type, presence: true, inclusion: { in: %w[dietary_tag recipe_type cuisine unit dish_type] }
  validates :key, presence: true, uniqueness: { scope: :reference_type }
  validates :display_name, presence: true

  scope :dietary_tags, -> { where(reference_type: 'dietary_tag') }
  scope :recipe_types, -> { where(reference_type: 'recipe_type') }
  scope :cuisines, -> { where(reference_type: 'cuisine') }
  scope :dish_types, -> { where(reference_type: 'dish_type') }
  scope :active, -> { where(active: true) }
end
