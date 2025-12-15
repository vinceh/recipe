class CreateIngredientUnitConversions < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredient_unit_conversions do |t|
      t.references :ingredient, null: false, foreign_key: true
      t.string :unit, null: false
      t.decimal :grams, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :ingredient_unit_conversions, [:ingredient_id, :unit], unique: true
  end
end
