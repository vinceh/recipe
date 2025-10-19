class CreateIngredientAliases < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredient_aliases, id: :uuid do |t|
      t.uuid :ingredient_id, null: false
      t.string :alias, null: false
      t.string :language # 'en', 'ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr'
      t.string :alias_type # 'synonym', 'translation', 'misspelling'

      t.timestamps
    end

    add_foreign_key :ingredient_aliases, :ingredients
    add_index :ingredient_aliases, [:alias, :language], unique: true
    add_index :ingredient_aliases, :ingredient_id
  end
end
