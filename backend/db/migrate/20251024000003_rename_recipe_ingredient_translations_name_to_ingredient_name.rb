class RenameRecipeIngredientTranslationsNameToIngredientName < ActiveRecord::Migration[8.0]
  def change
    rename_column :recipe_ingredient_translations, :name, :ingredient_name
  end
end
