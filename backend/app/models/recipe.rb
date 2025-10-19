class Recipe < ApplicationRecord
  # Associations
  has_many :user_recipe_notes, dependent: :destroy
  has_many :user_favorites, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :language, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }
  validates :precision_reason, inclusion: { in: %w[baking confectionery fermentation molecular], allow_nil: true }

  # JSONB validations
  validate :validate_servings_structure
  validate :validate_timing_structure
  validate :validate_nutrition_structure
  validate :validate_ingredient_groups_structure
  validate :validate_steps_structure

  private

  def validate_servings_structure
    return unless servings.present?

    unless servings.is_a?(Hash)
      errors.add(:servings, 'must be a hash')
      return
    end

    required_keys = %w[original min max]
    required_keys.each do |key|
      unless servings[key].present?
        errors.add(:servings, "must include #{key}")
      end
    end
  end

  def validate_timing_structure
    return unless timing.present?

    unless timing.is_a?(Hash)
      errors.add(:timing, 'must be a hash')
      return
    end

    required_keys = %w[prep_minutes cook_minutes total_minutes]
    required_keys.each do |key|
      unless timing[key].present?
        errors.add(:timing, "must include #{key}")
      end
    end
  end

  def validate_nutrition_structure
    return unless nutrition.present?

    unless nutrition.is_a?(Hash)
      errors.add(:nutrition, 'must be a hash')
      return
    end

    if nutrition['per_serving'].present?
      per_serving = nutrition['per_serving']
      required_keys = %w[calories protein_g carbs_g fat_g fiber_g]
      required_keys.each do |key|
        unless per_serving[key].present?
          errors.add(:nutrition, "per_serving must include #{key}")
        end
      end
    end
  end

  def validate_ingredient_groups_structure
    return unless ingredient_groups.present?

    unless ingredient_groups.is_a?(Array)
      errors.add(:ingredient_groups, 'must be an array')
      return
    end

    ingredient_groups.each_with_index do |group, index|
      unless group.is_a?(Hash) && group['name'].present? && group['items'].is_a?(Array)
        errors.add(:ingredient_groups, "group at index #{index} must have 'name' and 'items' array")
      end
    end
  end

  def validate_steps_structure
    return unless steps.present?

    unless steps.is_a?(Array)
      errors.add(:steps, 'must be an array')
      return
    end

    steps.each_with_index do |step, index|
      unless step.is_a?(Hash) && step['id'].present? && step['instructions'].is_a?(Hash)
        errors.add(:steps, "step at index #{index} must have 'id' and 'instructions' hash")
      end
    end
  end
end
