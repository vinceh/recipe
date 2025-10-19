class CreateUserRecipeNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_recipe_notes, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :recipe_id, null: false
      t.string :note_type, null: false # 'recipe', 'step', 'ingredient'
      t.string :note_target_id # 'step-001', 'ing-005', null for recipe-level
      t.text :note_text

      t.timestamps
    end

    add_foreign_key :user_recipe_notes, :users
    add_foreign_key :user_recipe_notes, :recipes
    add_index :user_recipe_notes, [:user_id, :recipe_id]
  end
end
