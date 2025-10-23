class Recipe < ApplicationRecord
  # Existing associations
  has_many :user_recipe_notes, dependent: :destroy
  has_many :user_favorites, dependent: :destroy

  # Normalized schema associations
  has_many :ingredient_groups, dependent: :destroy
  has_many :recipe_ingredients, through: :ingredient_groups
  has_many :recipe_steps, dependent: :destroy
  has_one :recipe_nutrition, dependent: :destroy
  has_many :recipe_equipment, dependent: :destroy
  has_many :equipment, through: :recipe_equipment
  has_many :recipe_dietary_tags, dependent: :destroy
  has_many :dietary_tags, through: :recipe_dietary_tags, source: :data_reference
  has_many :recipe_dish_types, dependent: :destroy
  has_many :dish_types, through: :recipe_dish_types, source: :data_reference
  has_many :recipe_cuisines, dependent: :destroy
  has_many :cuisines, through: :recipe_cuisines, source: :data_reference
  has_many :recipe_recipe_types, dependent: :destroy
  has_many :recipe_types, through: :recipe_recipe_types, source: :data_reference
  has_many :recipe_aliases, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :source_language, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }
  validates :precision_reason, inclusion: { in: %w[baking confectionery fermentation molecular], allow_nil: true }
end
