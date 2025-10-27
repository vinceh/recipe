class AddDescriptionToRecipeTranslations < ActiveRecord::Migration[7.1]
  def change
    add_column :recipe_translations, :description, :text

    reversible do |dir|
      dir.up do
        # Set default empty descriptions for any existing translations
        execute("UPDATE recipe_translations SET description = '' WHERE description IS NULL")
        change_column_null :recipe_translations, :description, false
      end
      dir.down do
        change_column_null :recipe_translations, :description, true
      end
    end
  end
end
