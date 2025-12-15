class AddSectionHeadingToRecipeStepTranslations < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_step_translations, :section_heading, :string
  end
end
