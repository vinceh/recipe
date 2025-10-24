class Recipe < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

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
  validates :source_language, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }
  validates :precision_reason, inclusion: { in: %w[baking confectionery fermentation molecular], allow_nil: true }

  # Callbacks for auto-triggered translation workflow
  after_commit :enqueue_translation_on_create, on: :create
  after_commit :enqueue_translation_on_update, on: :update

  # Helper method for aliases
  def aliases
    recipe_aliases.pluck(:alias_name)
  end

  private

  def enqueue_translation_on_create
    TranslateRecipeJob.perform_later(id)
  end

  def enqueue_translation_on_update
    if has_translation_job_with_recipe_id?
      delete_pending_translation_job unless has_running_translation_job?
    end
    schedule_translation_at_next_available_time
  end

  def has_translation_job_with_recipe_id?
    return false unless job_queue_available?

    SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
      .where('arguments->0 = ?', id)
      .exists?
  rescue StandardError
    false
  end

  def has_running_translation_job?
    return false unless job_queue_available?

    SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
      .where('arguments->0 = ?', id)
      .joins("INNER JOIN solid_queue_claimed_executions ON solid_queue_jobs.id = solid_queue_claimed_executions.job_id")
      .where('solid_queue_jobs.finished_at IS NULL')
      .exists?
  rescue StandardError
    false
  end

  def translation_rate_limit_exceeded?
    return false if last_translated_at.nil?

    completed_translations = completed_translation_job_count
    max_allowed = Rails.application.config.recipe[:translation_rate_limit][:max_translations_per_window]
    completed_translations >= max_allowed
  end

  def delete_pending_translation_job
    return unless job_queue_available?

    SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
      .where('arguments->0 = ?', id)
      .where(finished_at: nil)
      .joins("LEFT JOIN solid_queue_claimed_executions ON solid_queue_jobs.id = solid_queue_claimed_executions.job_id")
      .where('solid_queue_claimed_executions.job_id IS NULL')
      .destroy_all
  rescue StandardError
    # Silently continue if job deletion fails
  end

  def schedule_translation_at_next_available_time
    if translation_rate_limit_exceeded?
      oldest_job_in_window = get_oldest_completed_translation_job_in_window
      if oldest_job_in_window
        rate_limit_window = Rails.application.config.recipe[:translation_rate_limit][:rate_limit_window]
        earliest_available = oldest_job_in_window.finished_at + rate_limit_window.seconds + 1.second
        delay = [0, (earliest_available - Time.current)].max
        TranslateRecipeJob.set(wait: delay.seconds).perform_later(id)
      end
    else
      TranslateRecipeJob.perform_later(id)
    end
  end

  def get_oldest_completed_translation_job_in_window
    return nil unless job_queue_available?

    rate_limit_window = Rails.application.config.recipe[:translation_rate_limit][:rate_limit_window]
    cutoff_time = Time.current - rate_limit_window.seconds

    SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
      .where('arguments->0 = ?', id)
      .where('finished_at > ?', cutoff_time)
      .where.not(finished_at: nil)
      .order(finished_at: :asc)
      .first
  rescue StandardError
    nil
  end

  def completed_translation_job_count
    return 0 unless job_queue_available?

    rate_limit_window = Rails.application.config.recipe[:translation_rate_limit][:rate_limit_window]
    cutoff_time = Time.current - rate_limit_window.seconds

    SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
      .where('arguments->0 = ?', id)
      .where('finished_at > ?', cutoff_time)
      .where.not(finished_at: nil)
      .count
  rescue StandardError
    0
  end

  def job_queue_available?
    defined?(SolidQueue::Job) && SolidQueue::Job.table_exists?
  end
end
