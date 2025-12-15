class AddImageAiGeneratedToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :image_ai_generated, :boolean, default: true, null: false
  end
end
