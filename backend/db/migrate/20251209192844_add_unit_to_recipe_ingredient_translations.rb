class AddUnitToRecipeIngredientTranslations < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_ingredient_translations, :unit, :string
  end
end
