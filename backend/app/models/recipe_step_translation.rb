class RecipeStepTranslation < ApplicationRecord
  belongs_to :recipe_step

  validates :recipe_step_id, presence: true
  validates :locale, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }
  validates :recipe_step_id, uniqueness: { scope: :locale }
  validates :instruction_original, presence: true
end
