class AddStepInstructionsToRecipeSteps < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_steps, :instruction_original, :text
    add_column :recipe_steps, :instruction_easier, :text
    add_column :recipe_steps, :instruction_no_equipment, :text
  end
end
