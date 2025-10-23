class IngredientAlias < ApplicationRecord
  belongs_to :ingredient

  validates :ingredient, presence: true
  validates :alias, presence: true, uniqueness: { scope: :language }
  validates :language, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr], allow_nil: true }
  validates :alias_type, inclusion: { in: %w[synonym translation misspelling], allow_nil: true }
end
