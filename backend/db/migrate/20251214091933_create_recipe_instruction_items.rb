class CreateRecipeInstructionItems < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_instruction_items do |t|
      t.references :recipe, null: false, foreign_key: true
      t.string :item_type, null: false
      t.integer :position, null: false
      t.text :content

      t.timestamps
    end

    add_index :recipe_instruction_items, [:recipe_id, :position]

    create_table :recipe_instruction_item_translations do |t|
      t.string :locale, null: false
      t.references :recipe_instruction_item, null: false, foreign_key: true, index: { name: 'index_instruction_item_translations_on_item_id' }
      t.text :content

      t.timestamps
    end

    add_index :recipe_instruction_item_translations, [:recipe_instruction_item_id, :locale],
              unique: true, name: 'index_instruction_item_translations_on_item_id_and_locale'
  end
end
