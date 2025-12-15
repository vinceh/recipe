class AddSectionHeadingToRecipeSteps < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_steps, :section_heading, :string
  end
end
