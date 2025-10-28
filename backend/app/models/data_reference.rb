class DataReference < ApplicationRecord
  extend Mobility
  translates :display_name, backend: :table

  # Associations
  has_many :recipe_dietary_tags, dependent: :destroy
  has_many :recipe_cuisines, dependent: :destroy

  has_many :recipes_as_dietary_tag, class_name: 'Recipe', through: :recipe_dietary_tags, source: :recipe
  has_many :recipes_as_cuisine, class_name: 'Recipe', through: :recipe_cuisines, source: :recipe

  # Validations
  validates :reference_type, presence: true, inclusion: { in: %w[dietary_tag cuisine unit] }
  validates :key, presence: true, uniqueness: { scope: :reference_type }
  validates :display_name, presence: true, uniqueness: { scope: :reference_type, message: 'must be unique within the same reference type' }

  # Scopes
  scope :dietary_tags, -> { where(reference_type: 'dietary_tag') }
  scope :cuisines, -> { where(reference_type: 'cuisine') }
  scope :active, -> { where(active: true) }
end
