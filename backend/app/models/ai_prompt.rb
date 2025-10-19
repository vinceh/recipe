class AiPrompt < ApplicationRecord
  validates :prompt_key, presence: true, uniqueness: true
  validates :prompt_type, presence: true, inclusion: { in: %w[system user] }
  validates :feature_area, presence: true, inclusion: { in: %w[step_variants translation recipe_discovery recipe_parsing nutrition nutrition_estimation] }
  validates :prompt_text, presence: true

  scope :active, -> { where(active: true) }
  scope :by_feature, ->(area) { where(feature_area: area) }

  # Render prompt with variable substitution
  def render(**variables)
    rendered = prompt_text.dup

    variables.each do |key, value|
      rendered.gsub!("{{#{key}}}", value.to_s)
    end

    rendered
  end
end
