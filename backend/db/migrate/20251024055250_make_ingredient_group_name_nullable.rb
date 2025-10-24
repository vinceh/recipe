class MakeIngredientGroupNameNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :ingredient_groups, :name, true
  end
end
