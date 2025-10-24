class AddLastTranslatedAtToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :last_translated_at, :datetime
  end
end
