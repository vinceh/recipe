class MakeRecipeIngredientNameNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :recipe_ingredients, :ingredient_name, true
  end
end
