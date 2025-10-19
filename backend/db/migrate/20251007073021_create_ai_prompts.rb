class CreateAiPrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_prompts, id: :uuid do |t|
      t.string :prompt_key, null: false # 'step_variant_easier', 'step_variant_no_equipment', etc.
      t.string :prompt_type, null: false # 'system', 'user'
      t.string :feature_area, null: false # 'step_variants', 'translation', 'recipe_discovery'
      t.text :prompt_text, null: false
      t.text :description # What this prompt does
      t.jsonb :variables, default: [] # List of variables used: ['recipe_name', 'step_order', ...]
      t.boolean :active, default: true
      t.integer :version, default: 1

      t.timestamps
    end

    add_index :ai_prompts, :prompt_key, unique: true
    add_index :ai_prompts, :feature_area
  end
end
