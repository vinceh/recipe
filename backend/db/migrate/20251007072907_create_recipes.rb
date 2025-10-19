class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :recipes, id: :uuid do |t|
      t.string :name, null: false
      t.string :language, default: 'en'
      t.boolean :requires_precision, default: false
      t.string :precision_reason # 'baking', 'confectionery', 'fermentation', 'molecular'

      # JSONB fields
      t.jsonb :servings, default: {} # { original: 4, min: 1, max: 12 }
      t.jsonb :timing, default: {} # { prep_minutes: 15, cook_minutes: 30, total_minutes: 45 }
      t.jsonb :nutrition, default: {} # per_serving: { calories, protein_g, carbs_g, fat_g, fiber_g }
      t.jsonb :aliases, default: [] # ['Phad Thai', 'Thai Fried Noodles'] - same language as recipe.language only
      t.jsonb :dietary_tags, default: [] # Edamam health labels: ['vegetarian', 'gluten-free', 'dairy-free']
      t.jsonb :dish_types, default: [] # ['main-course', 'soup', 'desserts', 'side-dish']
      t.jsonb :recipe_types, default: [] # ['baking', 'stir-fry', 'chicken', 'quick-weeknight']
      t.jsonb :cuisines, default: [] # ['japanese'] or ['japanese', 'fusion']
      t.jsonb :ingredient_groups, default: [] # [{ name: 'Main', items: [...] }]
      t.jsonb :steps, default: [] # [{ id, instructions: { original, easier, no_equipment }, ... }]
      t.jsonb :equipment, default: [] # ['wok', 'rice_cooker']
      t.jsonb :translations, default: {} # { ja: {...}, ko: {...}, ... }

      # Generation status
      t.boolean :variants_generated, default: false
      t.datetime :variants_generated_at
      t.boolean :translations_completed, default: false

      # Admin metadata
      t.string :source_url # if imported via AI discovery
      t.text :admin_notes

      t.timestamps
    end

    add_index :recipes, :name
    add_index :recipes, :language
    add_index :recipes, :aliases, using: :gin
    add_index :recipes, :dietary_tags, using: :gin
    add_index :recipes, :dish_types, using: :gin
    add_index :recipes, :recipe_types, using: :gin
    add_index :recipes, :cuisines, using: :gin
  end
end
