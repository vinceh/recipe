class CreateDataReferences < ActiveRecord::Migration[8.0]
  def change
    create_table :data_references, id: :uuid do |t|
      t.string :reference_type, null: false # 'dietary_tag', 'recipe_type', 'cuisine', 'unit'
      t.string :key, null: false # 'vegetarian', 'main_course', 'japanese', 'cup'
      t.string :display_name, null: false
      t.jsonb :metadata, default: {} # Additional data (conversion rates for units, etc.)
      t.integer :sort_order, default: 0
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :data_references, [:reference_type, :key], unique: true
    add_index :data_references, :reference_type
  end
end
