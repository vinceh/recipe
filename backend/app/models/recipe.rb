class Recipe < ApplicationRecord
  # Existing associations
  has_many :user_recipe_notes, dependent: :destroy
  has_many :user_favorites, dependent: :destroy

  # Normalized schema associations
  has_many :ingredient_groups, -> { order(:position) }, dependent: :destroy
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

  # Nested attributes for normalized schema
  accepts_nested_attributes_for :ingredient_groups,
    allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :recipe_steps,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['step_number'].blank? && attrs['instruction_original'].blank? }
  accepts_nested_attributes_for :recipe_nutrition,
    allow_destroy: true,
    reject_if: :all_blank
  accepts_nested_attributes_for :recipe_equipment,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['equipment_id'].blank? }
  accepts_nested_attributes_for :recipe_dietary_tags,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_dish_types,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_cuisines,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_recipe_types,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_aliases,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['alias_name'].blank? }

  # Validations
  validates :name, presence: true
  validates :source_language, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }
  validates :precision_reason, inclusion: { in: %w[baking confectionery fermentation molecular], allow_nil: true }

  # Helper method for aliases
  def aliases
    recipe_aliases.pluck(:alias_name)
  end
end
