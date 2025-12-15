class RemoveUnitFromRecipeIngredientTranslations < ActiveRecord::Migration[8.0]
  def change
    remove_column :recipe_ingredient_translations, :unit, :string, if_exists: true
    remove_column :recipe_ingredients, :unit, :string, if_exists: true
  end
end
