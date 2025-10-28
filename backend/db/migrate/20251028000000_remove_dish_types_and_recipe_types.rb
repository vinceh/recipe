class RemoveDishTypesAndRecipeTypes < ActiveRecord::Migration[7.0]
  def up
    # Remove foreign keys
    remove_foreign_key :recipe_dish_types, :recipes
    remove_foreign_key :recipe_dish_types, :data_references
    remove_foreign_key :recipe_recipe_types, :recipes
    remove_foreign_key :recipe_recipe_types, :data_references

    # Drop the join tables
    drop_table :recipe_dish_types
    drop_table :recipe_recipe_types

    # Delete DataReference records for dish_type and recipe_type
    DataReference.where(reference_type: ['dish_type', 'recipe_type']).delete_all
  end

  def down
    # Recreate the join tables
    create_table :recipe_dish_types, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    add_index :recipe_dish_types, :recipe_id
    add_index :recipe_dish_types, :data_reference_id
    add_index :recipe_dish_types, [:recipe_id, :data_reference_id], unique: true
    add_foreign_key :recipe_dish_types, :recipes, on_delete: :cascade
    add_foreign_key :recipe_dish_types, :data_references, on_delete: :cascade

    create_table :recipe_recipe_types, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
    add_index :recipe_recipe_types, :recipe_id
    add_index :recipe_recipe_types, :data_reference_id
    add_index :recipe_recipe_types, [:recipe_id, :data_reference_id], unique: true
    add_foreign_key :recipe_recipe_types, :recipes, on_delete: :cascade
    add_foreign_key :recipe_recipe_types, :data_references, on_delete: :cascade
  end
end
