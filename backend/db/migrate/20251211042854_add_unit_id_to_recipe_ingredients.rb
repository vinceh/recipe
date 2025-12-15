class AddUnitIdToRecipeIngredients < ActiveRecord::Migration[8.0]
  def change
    add_reference :recipe_ingredients, :unit, null: true, foreign_key: true
  end
end
