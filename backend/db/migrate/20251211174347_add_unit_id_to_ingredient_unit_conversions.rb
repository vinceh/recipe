class AddUnitIdToIngredientUnitConversions < ActiveRecord::Migration[8.0]
  def change
    add_reference :ingredient_unit_conversions, :unit, null: true, foreign_key: true
  end
end
