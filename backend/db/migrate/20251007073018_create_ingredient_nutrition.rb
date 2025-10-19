class CreateIngredientNutrition < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredient_nutrition, id: :uuid do |t|
      t.uuid :ingredient_id, null: false

      # Per 100g values
      t.decimal :calories, precision: 8, scale: 2
      t.decimal :protein_g, precision: 6, scale: 2
      t.decimal :carbs_g, precision: 6, scale: 2
      t.decimal :fat_g, precision: 6, scale: 2
      t.decimal :fiber_g, precision: 6, scale: 2

      # Metadata
      t.string :data_source # 'nutritionix', 'usda', 'ai'
      t.decimal :confidence_score, precision: 3, scale: 2 # 0.0-1.0

      t.timestamps
    end

    add_foreign_key :ingredient_nutrition, :ingredients
    add_index :ingredient_nutrition, :ingredient_id
  end
end
