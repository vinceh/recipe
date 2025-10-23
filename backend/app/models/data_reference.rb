class DataReference < ApplicationRecord
  # Associations
  has_many :recipe_dietary_tags, dependent: :destroy
  has_many :recipe_dish_types, dependent: :destroy
  has_many :recipe_cuisines, dependent: :destroy
  has_many :recipe_recipe_types, dependent: :destroy

  has_many :recipes_as_dietary_tag, class_name: 'Recipe', through: :recipe_dietary_tags, source: :recipe
  has_many :recipes_as_dish_type, class_name: 'Recipe', through: :recipe_dish_types, source: :recipe
  has_many :recipes_as_cuisine, class_name: 'Recipe', through: :recipe_cuisines, source: :recipe
  has_many :recipes_as_recipe_type, class_name: 'Recipe', through: :recipe_recipe_types, source: :recipe

  # Validations
  validates :reference_type, presence: true, inclusion: { in: %w[dietary_tag recipe_type cuisine unit dish_type] }
  validates :key, presence: true, uniqueness: { scope: :reference_type }
  validates :display_name, presence: true

  # Scopes
  scope :dietary_tags, -> { where(reference_type: 'dietary_tag') }
  scope :recipe_types, -> { where(reference_type: 'recipe_type') }
  scope :cuisines, -> { where(reference_type: 'cuisine') }
  scope :dish_types, -> { where(reference_type: 'dish_type') }
  scope :active, -> { where(active: true) }
end
