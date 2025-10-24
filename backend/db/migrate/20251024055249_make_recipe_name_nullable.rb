class MakeRecipeNameNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :recipes, :name, true
  end
end
