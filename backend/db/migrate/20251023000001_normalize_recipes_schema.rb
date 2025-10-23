class NormalizeRecipesSchema < ActiveRecord::Migration[8.0]
  def change
    # ============================================================================
    # RECIPES TABLE MODIFICATIONS
    # ============================================================================

    # Add new columns for servings (was JSONB)
    add_column :recipes, :servings_original, :integer
    add_column :recipes, :servings_min, :integer
    add_column :recipes, :servings_max, :integer

    # Add new columns for timing (was JSONB)
    add_column :recipes, :prep_minutes, :integer
    add_column :recipes, :cook_minutes, :integer
    add_column :recipes, :total_minutes, :integer

    # Rename language to source_language
    rename_column :recipes, :language, :source_language
    change_column_default :recipes, :source_language, "en"

    # Add translation status tracking
    add_column :recipes, :translation_status, :jsonb, default: {}

    # Add index for source_language
    add_index :recipes, :source_language

    # Drop JSONB columns that are now normalized
    remove_column :recipes, :servings, :jsonb
    remove_column :recipes, :timing, :jsonb
    remove_column :recipes, :aliases, :jsonb
    remove_column :recipes, :dietary_tags, :jsonb
    remove_column :recipes, :dish_types, :jsonb
    remove_column :recipes, :recipe_types, :jsonb
    remove_column :recipes, :cuisines, :jsonb
    remove_column :recipes, :ingredient_groups, :jsonb
    remove_column :recipes, :steps, :jsonb
    remove_column :recipes, :equipment, :jsonb
    remove_column :recipes, :translations, :jsonb
    remove_column :recipes, :translations_completed, :boolean

    # Drop indexes on removed JSONB columns
    remove_index :recipes, name: "index_recipes_on_aliases"
    remove_index :recipes, name: "index_recipes_on_cuisines"
    remove_index :recipes, name: "index_recipes_on_dietary_tags"
    remove_index :recipes, name: "index_recipes_on_dish_types"
    remove_index :recipes, name: "index_recipes_on_recipe_types"

    # ============================================================================
    # CREATE INGREDIENT_GROUPS TABLE
    # ============================================================================

    create_table :ingredient_groups, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.string :name, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :ingredient_groups, :recipe_id
    add_index :ingredient_groups, [:recipe_id, :position], unique: true

    # ============================================================================
    # CREATE RECIPE_INGREDIENTS TABLE
    # ============================================================================

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
    add_index :recipe_ingredients, [:ingredient_group_id, :position], unique: true

    # ============================================================================
    # CREATE RECIPE_STEPS TABLE
    # ============================================================================

    create_table :recipe_steps, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.integer :step_number, null: false
      t.integer :timing_minutes
      t.text :instruction_original
      t.text :instruction_easier
      t.text :instruction_no_equipment

      t.timestamps
    end

    add_index :recipe_steps, :recipe_id
    add_index :recipe_steps, [:recipe_id, :step_number], unique: true

    # ============================================================================
    # CREATE EQUIPMENT TABLE
    # ============================================================================

    create_table :equipment, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :canonical_name, null: false

      t.timestamps
    end

    add_index :equipment, :canonical_name, unique: true

    # ============================================================================
    # CREATE RECIPE_EQUIPMENT TABLE
    # ============================================================================

    create_table :recipe_equipment, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :equipment_id, null: false
      t.boolean :optional, default: false

      t.datetime :created_at, null: false
    end

    add_index :recipe_equipment, :recipe_id
    add_index :recipe_equipment, [:recipe_id, :equipment_id], unique: true

    # ============================================================================
    # CREATE RECIPE_DIETARY_TAGS TABLE
    # ============================================================================

    create_table :recipe_dietary_tags, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false

      t.datetime :created_at, null: false
    end

    add_index :recipe_dietary_tags, [:recipe_id, :data_reference_id], unique: true

    # ============================================================================
    # CREATE RECIPE_DISH_TYPES TABLE
    # ============================================================================

    create_table :recipe_dish_types, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false

      t.datetime :created_at, null: false
    end

    add_index :recipe_dish_types, [:recipe_id, :data_reference_id], unique: true

    # ============================================================================
    # CREATE RECIPE_RECIPE_TYPES TABLE
    # ============================================================================

    create_table :recipe_recipe_types, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false

      t.datetime :created_at, null: false
    end

    add_index :recipe_recipe_types, [:recipe_id, :data_reference_id], unique: true

    # ============================================================================
    # CREATE RECIPE_CUISINES TABLE
    # ============================================================================

    create_table :recipe_cuisines, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.uuid :data_reference_id, null: false

      t.datetime :created_at, null: false
    end

    add_index :recipe_cuisines, [:recipe_id, :data_reference_id], unique: true

    # ============================================================================
    # CREATE RECIPE_ALIASES TABLE
    # ============================================================================

    create_table :recipe_aliases, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.string :alias_name, null: false
      t.string :language

      t.datetime :created_at, null: false
    end

    add_index :recipe_aliases, :recipe_id
    add_index :recipe_aliases, [:recipe_id, :alias_name, :language], unique: true

    # ============================================================================
    # CREATE RECIPE_NUTRITION TABLE
    # ============================================================================

    create_table :recipe_nutrition, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :recipe_id, null: false
      t.decimal :calories, precision: 8, scale: 2
      t.decimal :protein_g, precision: 6, scale: 2
      t.decimal :carbs_g, precision: 6, scale: 2
      t.decimal :fat_g, precision: 6, scale: 2
      t.decimal :fiber_g, precision: 6, scale: 2
      t.decimal :sodium_mg, precision: 8, scale: 2
      t.decimal :sugar_g, precision: 6, scale: 2

      t.timestamps
    end

    add_index :recipe_nutrition, :recipe_id, unique: true

    # ============================================================================
    # ADD FOREIGN KEYS
    # ============================================================================

    add_foreign_key :ingredient_groups, :recipes, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :ingredient_groups, on_delete: :cascade
    add_foreign_key :recipe_ingredients, :ingredients, on_delete: :nullify
    add_foreign_key :recipe_steps, :recipes, on_delete: :cascade
    add_foreign_key :recipe_equipment, :recipes, on_delete: :cascade
    add_foreign_key :recipe_equipment, :equipment, on_delete: :cascade
    add_foreign_key :recipe_dietary_tags, :recipes, on_delete: :cascade
    add_foreign_key :recipe_dietary_tags, :data_references, on_delete: :cascade
    add_foreign_key :recipe_dish_types, :recipes, on_delete: :cascade
    add_foreign_key :recipe_dish_types, :data_references, on_delete: :cascade
    add_foreign_key :recipe_recipe_types, :recipes, on_delete: :cascade
    add_foreign_key :recipe_recipe_types, :data_references, on_delete: :cascade
    add_foreign_key :recipe_cuisines, :recipes, on_delete: :cascade
    add_foreign_key :recipe_cuisines, :data_references, on_delete: :cascade
    add_foreign_key :recipe_aliases, :recipes, on_delete: :cascade
    add_foreign_key :recipe_nutrition, :recipes, on_delete: :cascade
  end
end
