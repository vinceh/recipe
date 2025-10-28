class AddDifficultyLevelToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :difficulty_level, :integer, null: false, default: 1
    add_index :recipes, :difficulty_level
  end
end
