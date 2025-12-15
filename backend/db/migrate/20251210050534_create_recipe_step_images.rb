class CreateRecipeStepImages < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_step_images do |t|
      t.references :recipe, null: false, foreign_key: true
      t.decimal :position, precision: 10, scale: 2, null: false
      t.text :caption
      t.boolean :ai_generated, default: true, null: false
      t.timestamps
    end

    add_index :recipe_step_images, [:recipe_id, :position]
  end
end
