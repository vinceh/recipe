class GenerateStepVariantsJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    generator = StepVariantGenerator.new

    recipe.steps.each do |step|
      # Only generate if original exists
      next unless step.dig('instructions', 'original')

      step['instructions']['easier'] = generator.generate_easier_variant(recipe, step)
      step['instructions']['no_equipment'] = generator.generate_no_equipment_variant(recipe, step)
    end

    recipe.update!(
      steps: recipe.steps,
      variants_generated: true,
      variants_generated_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("Variant generation failed for recipe #{recipe_id}: #{e.message}")
    # Optionally: Set error flag on recipe
  end
end
