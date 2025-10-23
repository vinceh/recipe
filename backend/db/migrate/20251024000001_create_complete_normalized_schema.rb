class CreateCompleteNormalizedSchema < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    # ============================================================================
    # USERS & AUTH
    # ============================================================================
    create_table :users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.string :role, default: "user"
      t.string :preferred_language, default: "en"
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :jwt_denylists do |t|
      t.string :jti
      t.datetime :exp
      t.timestamps
    end
    add_index :jwt_denylists, :jti

    # ============================================================================
    # RECIPES (NORMALIZED)
    # ============================================================================
    create_table :recipes, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :source_language, default: "en", null: false

      t.integer :servings_original
      t.integer :servings_min
      t.integer :servings_max

      t.integer :prep_minutes
      t.integer :cook_minutes
      t.integer :total_minutes

      t.boolean :requires_precision, default: false
      t.string :precision_reason
      t.string :source_url
      t.text :admin_notes

      t.boolean :variants_generated, default: false
      t.datetime :variants_generated_at
      t.boolean :translations_completed, default: false

      t.timestamps
    end
    add_index :recipes, :name
    add_index :recipes, :source_language

    # ============================================================================
    # INGREDIENT GROUPS & INGREDIENTS
    # ============================================================================
    create_table :ingredient_groups, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.string :name, null: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :ingredient_groups, :recipe_id
    add_index :ingredient_groups, [:recipe_id, :position], unique: true

    create_table :ingredients, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :canonical_name, null: false
      t.string :category
      t.timestamps
    end
    add_index :ingredients, :canonical_name, unique: true

    create_table :recipe_ingredients, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :ingredient_group_id, null: false
      t.uuid :ingredient_id
      t.string :ingredient_name, null: false
      t.decimal :amount, precision: 10, scale: 2
      t.string :unit
      t.text :preparation_notes
      t.boolean :optional, default: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :recipe_ingredients, :ingredient_group_id
    add_index :recipe_ingredients, :ingredient_id
    add_index :recipe_ingredients, [:ingredient_group_id, :position]

    create_table :ingredient_nutrition, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :ingredient_id, null: false
      t.decimal :calories, precision: 8, scale: 2
      t.decimal :protein_g, precision: 6, scale: 2
      t.decimal :carbs_g, precision: 6, scale: 2
      t.decimal :fat_g, precision: 6, scale: 2
      t.decimal :fiber_g, precision: 6, scale: 2
      t.string :data_source
      t.decimal :confidence_score, precision: 3, scale: 2
      t.timestamps
    end
    add_index :ingredient_nutrition, :ingredient_id

    create_table :ingredient_aliases, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :ingredient_id, null: false
      t.string :alias, null: false
      t.string :language
      t.string :alias_type
      t.timestamps
    end
    add_index :ingredient_aliases, :ingredient_id
    add_index :ingredient_aliases, [:alias, :language], unique: true

    # ============================================================================
    # RECIPE STEPS
    # ============================================================================
    create_table :recipe_steps, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.integer :step_number, null: false
      t.timestamps
    end
    add_index :recipe_steps, :recipe_id
    add_index :recipe_steps, [:recipe_id, :step_number], unique: true

    # ============================================================================
    # EQUIPMENT
    # ============================================================================
    create_table :equipment, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :canonical_name, null: false
      t.string :category
      t.jsonb :metadata, default: {}
      t.timestamps
    end
    add_index :equipment, :canonical_name, unique: true

    create_table :recipe_equipments, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :equipment_id, null: false
      t.boolean :optional, default: false
      t.timestamps
    end
    add_index :recipe_equipments, :recipe_id
    add_index :recipe_equipments, [:recipe_id, :equipment_id], unique: true

    # ============================================================================
    # REFERENCE DATA
    # ============================================================================
    create_table :data_references, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :reference_type, null: false
      t.string :key, null: false
      t.string :display_name
      t.jsonb :metadata, default: {}
      t.integer :sort_order, default: 0
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :data_references, [:reference_type, :key], unique: true
    add_index :data_references, :reference_type

    create_table :recipe_dietary_tags, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false
      t.timestamps
    end
    add_index :recipe_dietary_tags, :recipe_id
    add_index :recipe_dietary_tags, :data_reference_id
    add_index :recipe_dietary_tags, [:recipe_id, :data_reference_id], unique: true

    create_table :recipe_dish_types, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false
      t.timestamps
    end
    add_index :recipe_dish_types, :recipe_id
    add_index :recipe_dish_types, :data_reference_id
    add_index :recipe_dish_types, [:recipe_id, :data_reference_id], unique: true

    create_table :recipe_cuisines, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false
      t.timestamps
    end
    add_index :recipe_cuisines, :recipe_id
    add_index :recipe_cuisines, :data_reference_id
    add_index :recipe_cuisines, [:recipe_id, :data_reference_id], unique: true

    create_table :recipe_recipe_types, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false
      t.timestamps
    end
    add_index :recipe_recipe_types, :recipe_id
    add_index :recipe_recipe_types, :data_reference_id
    add_index :recipe_recipe_types, [:recipe_id, :data_reference_id], unique: true

    create_table :recipe_aliases, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.string :alias_name, null: false
      t.string :language, default: "en", null: false
      t.timestamps
    end
    add_index :recipe_aliases, :recipe_id
    add_index :recipe_aliases, [:recipe_id, :alias_name, :language], unique: true

    # ============================================================================
    # RECIPE NUTRITION
    # ============================================================================
    create_table :recipe_nutritions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.decimal :calories, precision: 8, scale: 2
      t.decimal :protein_g, precision: 8, scale: 2
      t.decimal :carbs_g, precision: 8, scale: 2
      t.decimal :fat_g, precision: 8, scale: 2
      t.decimal :fiber_g, precision: 8, scale: 2
      t.decimal :sodium_mg, precision: 8, scale: 2
      t.decimal :sugar_g, precision: 8, scale: 2
      t.timestamps
    end
    add_index :recipe_nutritions, :recipe_id, unique: true

    # ============================================================================
    # USER INTERACTIONS
    # ============================================================================
    create_table :user_recipe_notes, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :recipe_id, null: false
      t.text :notes
      t.timestamps
    end
    add_index :user_recipe_notes, :user_id
    add_index :user_recipe_notes, :recipe_id
    add_index :user_recipe_notes, [:user_id, :recipe_id], unique: true

    create_table :user_favorites, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :recipe_id, null: false
      t.timestamps
    end
    add_index :user_favorites, :user_id
    add_index :user_favorites, :recipe_id
    add_index :user_favorites, [:user_id, :recipe_id], unique: true

    # ============================================================================
    # AI PROMPTS
    # ============================================================================
    create_table :ai_prompts, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :prompt_key, null: false
      t.string :prompt_type, null: false
      t.string :feature_area, null: false
      t.text :prompt_text, null: false
      t.text :description
      t.jsonb :variables, default: []
      t.boolean :active, default: true
      t.integer :version, default: 1
      t.timestamps
    end
    add_index :ai_prompts, :prompt_key, unique: true
    add_index :ai_prompts, :feature_area

    # ============================================================================
    # TRANSLATION TABLES
    # ============================================================================
    create_table :recipe_translations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.string :locale, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :recipe_translations, :recipe_id
    add_index :recipe_translations, :locale
    add_index :recipe_translations, [:recipe_id, :locale], unique: true

    create_table :ingredient_group_translations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :ingredient_group_id, null: false
      t.string :locale, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :ingredient_group_translations, :ingredient_group_id
    add_index :ingredient_group_translations, :locale
    add_index :ingredient_group_translations, [:ingredient_group_id, :locale], unique: true

    create_table :recipe_ingredient_translations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_ingredient_id, null: false
      t.string :locale, null: false
      t.string :name, null: false
      t.text :preparation_notes
      t.timestamps
    end
    add_index :recipe_ingredient_translations, :recipe_ingredient_id
    add_index :recipe_ingredient_translations, :locale
    add_index :recipe_ingredient_translations, [:recipe_ingredient_id, :locale], unique: true

    create_table :equipment_translations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :equipment_id, null: false
      t.string :locale, null: false
      t.string :canonical_name, null: false
      t.timestamps
    end
    add_index :equipment_translations, :equipment_id
    add_index :equipment_translations, :locale
    add_index :equipment_translations, [:equipment_id, :locale], unique: true

    create_table :recipe_step_translations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_step_id, null: false
      t.string :locale, null: false
      t.text :instruction_original
      t.text :instruction_easier
      t.text :instruction_no_equipment
      t.timestamps
    end
    add_index :recipe_step_translations, :recipe_step_id
    add_index :recipe_step_translations, :locale
    add_index :recipe_step_translations, [:recipe_step_id, :locale], unique: true

    create_table :data_reference_translations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :data_reference_id, null: false
      t.string :locale, null: false
      t.string :display_name, null: false
      t.timestamps
    end
    add_index :data_reference_translations, :data_reference_id
    add_index :data_reference_translations, :locale
    add_index :data_reference_translations, [:data_reference_id, :locale], unique: true

    # ============================================================================
    # FOREIGN KEYS
    # ============================================================================
    add_foreign_key :ingredient_groups, :recipes, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :ingredient_groups, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :ingredients, on_delete: :nullify
    add_foreign_key :recipe_steps, :recipes, on_delete: :cascade
    add_foreign_key :recipe_equipments, :recipes, on_delete: :cascade
    add_foreign_key :recipe_equipments, :equipment, on_delete: :cascade
    add_foreign_key :recipe_dietary_tags, :recipes, on_delete: :cascade
    add_foreign_key :recipe_dietary_tags, :data_references, on_delete: :cascade
    add_foreign_key :recipe_dish_types, :recipes, on_delete: :cascade
    add_foreign_key :recipe_dish_types, :data_references, on_delete: :cascade
    add_foreign_key :recipe_cuisines, :recipes, on_delete: :cascade
    add_foreign_key :recipe_cuisines, :data_references, on_delete: :cascade
    add_foreign_key :recipe_recipe_types, :recipes, on_delete: :cascade
    add_foreign_key :recipe_recipe_types, :data_references, on_delete: :cascade
    add_foreign_key :recipe_aliases, :recipes, on_delete: :cascade
    add_foreign_key :recipe_nutritions, :recipes, on_delete: :cascade
    add_foreign_key :user_recipe_notes, :users, on_delete: :cascade
    add_foreign_key :user_recipe_notes, :recipes, on_delete: :cascade
    add_foreign_key :user_favorites, :users, on_delete: :cascade
    add_foreign_key :user_favorites, :recipes, on_delete: :cascade
    add_foreign_key :ingredient_nutrition, :ingredients, on_delete: :cascade
    add_foreign_key :ingredient_aliases, :ingredients, on_delete: :cascade
    add_foreign_key :recipe_translations, :recipes, on_delete: :cascade
    add_index :ingredients, :category
    add_index :equipment, :category
    add_foreign_key :ingredient_group_translations, :ingredient_groups, on_delete: :cascade
    add_foreign_key :recipe_ingredient_translations, :recipe_ingredients, on_delete: :cascade
    add_foreign_key :equipment_translations, :equipment, on_delete: :cascade
    add_foreign_key :recipe_step_translations, :recipe_steps, on_delete: :cascade
    add_foreign_key :data_reference_translations, :data_references, on_delete: :cascade
  end
end
