class FinalizeIngredientUnitConversionsMigration < ActiveRecord::Migration[8.0]
  def change
    remove_index :ingredient_unit_conversions, [:ingredient_id, :unit],
                 name: "index_ingredient_unit_conversions_on_ingredient_id_and_unit"

    remove_column :ingredient_unit_conversions, :unit, :string

    change_column_null :ingredient_unit_conversions, :unit_id, false

    add_index :ingredient_unit_conversions, [:ingredient_id, :unit_id], unique: true
  end
end
