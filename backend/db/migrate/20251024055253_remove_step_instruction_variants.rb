class RemoveStepInstructionVariants < ActiveRecord::Migration[7.0]
  def change
    remove_column :recipe_steps, :instruction_easier, :text
    remove_column :recipe_steps, :instruction_no_equipment, :text
    remove_column :recipes, :variants_generated, :boolean
    remove_column :recipes, :variants_generated_at, :datetime
  end
end
