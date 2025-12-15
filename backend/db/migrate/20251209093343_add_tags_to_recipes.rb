class AddTagsToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :tags, :text, array: true, default: []
    add_index :recipes, :tags, using: :gin
  end
end
