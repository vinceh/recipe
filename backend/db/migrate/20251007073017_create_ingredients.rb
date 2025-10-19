class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients, id: :uuid do |t|
      t.string :canonical_name, null: false
      t.string :category # 'vegetable', 'protein', 'grain', 'spice', 'dairy'

      t.timestamps
    end

    add_index :ingredients, :canonical_name, unique: true
  end
end
