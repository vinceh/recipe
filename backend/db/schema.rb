# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_24_055252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"

  create_table "ai_prompts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "prompt_key", null: false
    t.string "prompt_type", null: false
    t.string "feature_area", null: false
    t.text "prompt_text", null: false
    t.text "description"
    t.jsonb "variables", default: []
    t.boolean "active", default: true
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_area"], name: "index_ai_prompts_on_feature_area"
    t.index ["prompt_key"], name: "index_ai_prompts_on_prompt_key", unique: true
  end

  create_table "data_reference_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "data_reference_id", null: false
    t.string "locale", null: false
    t.string "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_reference_id", "locale"], name: "idx_on_data_reference_id_locale_0fc7470964", unique: true
    t.index ["data_reference_id"], name: "index_data_reference_translations_on_data_reference_id"
    t.index ["locale"], name: "index_data_reference_translations_on_locale"
  end

  create_table "data_references", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_type", null: false
    t.string "key", null: false
    t.string "display_name"
    t.jsonb "metadata", default: {}
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference_type", "key"], name: "index_data_references_on_reference_type_and_key", unique: true
    t.index ["reference_type"], name: "index_data_references_on_reference_type"
  end

  create_table "equipment", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "canonical_name"
    t.string "category"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canonical_name"], name: "index_equipment_on_canonical_name", unique: true
    t.index ["category"], name: "index_equipment_on_category"
  end

  create_table "equipment_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "equipment_id", null: false
    t.string "locale", null: false
    t.string "canonical_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id", "locale"], name: "index_equipment_translations_on_equipment_id_and_locale", unique: true
    t.index ["equipment_id"], name: "index_equipment_translations_on_equipment_id"
    t.index ["locale"], name: "index_equipment_translations_on_locale"
  end

  create_table "ingredient_aliases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ingredient_id", null: false
    t.string "alias", null: false
    t.string "language"
    t.string "alias_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alias", "language"], name: "index_ingredient_aliases_on_alias_and_language", unique: true
    t.index ["ingredient_id"], name: "index_ingredient_aliases_on_ingredient_id"
  end

  create_table "ingredient_group_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ingredient_group_id", null: false
    t.string "locale", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_group_id", "locale"], name: "idx_on_ingredient_group_id_locale_d7ab14909d", unique: true
    t.index ["ingredient_group_id"], name: "index_ingredient_group_translations_on_ingredient_group_id"
    t.index ["locale"], name: "index_ingredient_group_translations_on_locale"
  end

  create_table "ingredient_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.string "name"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "position"], name: "index_ingredient_groups_on_recipe_id_and_position", unique: true
    t.index ["recipe_id"], name: "index_ingredient_groups_on_recipe_id"
  end

  create_table "ingredient_nutrition", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ingredient_id", null: false
    t.decimal "calories", precision: 8, scale: 2
    t.decimal "protein_g", precision: 6, scale: 2
    t.decimal "carbs_g", precision: 6, scale: 2
    t.decimal "fat_g", precision: 6, scale: 2
    t.decimal "fiber_g", precision: 6, scale: 2
    t.string "data_source"
    t.decimal "confidence_score", precision: 3, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_ingredient_nutrition_on_ingredient_id"
  end

  create_table "ingredients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "canonical_name", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canonical_name"], name: "index_ingredients_on_canonical_name", unique: true
    t.index ["category"], name: "index_ingredients_on_category"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "recipe_aliases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.string "alias_name", null: false
    t.string "language", default: "en", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "alias_name", "language"], name: "index_recipe_aliases_on_recipe_id_and_alias_name_and_language", unique: true
    t.index ["recipe_id"], name: "index_recipe_aliases_on_recipe_id"
  end

  create_table "recipe_cuisines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.uuid "data_reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_reference_id"], name: "index_recipe_cuisines_on_data_reference_id"
    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_cuisines_on_recipe_id_and_data_reference_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_cuisines_on_recipe_id"
  end

  create_table "recipe_dietary_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.uuid "data_reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_reference_id"], name: "index_recipe_dietary_tags_on_data_reference_id"
    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_dietary_tags_on_recipe_id_and_data_reference_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_dietary_tags_on_recipe_id"
  end

  create_table "recipe_dish_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.uuid "data_reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_reference_id"], name: "index_recipe_dish_types_on_data_reference_id"
    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_dish_types_on_recipe_id_and_data_reference_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_dish_types_on_recipe_id"
  end

  create_table "recipe_equipments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.uuid "equipment_id", null: false
    t.boolean "optional", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id", "equipment_id"], name: "index_recipe_equipments_on_recipe_id_and_equipment_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_equipments_on_recipe_id"
  end

  create_table "recipe_ingredient_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_ingredient_id", null: false
    t.string "locale", null: false
    t.string "ingredient_name", null: false
    t.text "preparation_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_recipe_ingredient_translations_on_locale"
    t.index ["recipe_ingredient_id", "locale"], name: "idx_on_recipe_ingredient_id_locale_9c5100c08b", unique: true
    t.index ["recipe_ingredient_id"], name: "index_recipe_ingredient_translations_on_recipe_ingredient_id"
  end

  create_table "recipe_ingredients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ingredient_group_id", null: false
    t.uuid "ingredient_id"
    t.string "ingredient_name"
    t.decimal "amount", precision: 10, scale: 2
    t.string "unit"
    t.text "preparation_notes"
    t.boolean "optional", default: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_group_id", "position"], name: "index_recipe_ingredients_on_ingredient_group_id_and_position"
    t.index ["ingredient_group_id"], name: "index_recipe_ingredients_on_ingredient_group_id"
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
  end

  create_table "recipe_nutritions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.decimal "calories", precision: 8, scale: 2
    t.decimal "protein_g", precision: 8, scale: 2
    t.decimal "carbs_g", precision: 8, scale: 2
    t.decimal "fat_g", precision: 8, scale: 2
    t.decimal "fiber_g", precision: 8, scale: 2
    t.decimal "sodium_mg", precision: 8, scale: 2
    t.decimal "sugar_g", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_nutritions_on_recipe_id", unique: true
  end

  create_table "recipe_recipe_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.uuid "data_reference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_reference_id"], name: "index_recipe_recipe_types_on_data_reference_id"
    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_recipe_types_on_recipe_id_and_data_reference_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_recipe_types_on_recipe_id"
  end

  create_table "recipe_step_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_step_id", null: false
    t.string "locale", null: false
    t.text "instruction_original"
    t.text "instruction_easier"
    t.text "instruction_no_equipment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_recipe_step_translations_on_locale"
    t.index ["recipe_step_id", "locale"], name: "index_recipe_step_translations_on_recipe_step_id_and_locale", unique: true
    t.index ["recipe_step_id"], name: "index_recipe_step_translations_on_recipe_step_id"
  end

  create_table "recipe_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.integer "step_number", null: false
    t.integer "timing_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "instruction_original"
    t.text "instruction_easier"
    t.text "instruction_no_equipment"
    t.index ["recipe_id", "step_number"], name: "index_recipe_steps_on_recipe_id_and_step_number", unique: true
    t.index ["recipe_id"], name: "index_recipe_steps_on_recipe_id"
  end

  create_table "recipe_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "recipe_id", null: false
    t.string "locale", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_recipe_translations_on_locale"
    t.index ["recipe_id", "locale"], name: "index_recipe_translations_on_recipe_id_and_locale", unique: true
    t.index ["recipe_id"], name: "index_recipe_translations_on_recipe_id"
  end

  create_table "recipes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "source_language", default: "en", null: false
    t.integer "servings_original"
    t.integer "servings_min"
    t.integer "servings_max"
    t.integer "prep_minutes"
    t.integer "cook_minutes"
    t.integer "total_minutes"
    t.boolean "requires_precision", default: false
    t.string "precision_reason"
    t.string "source_url"
    t.text "admin_notes"
    t.boolean "variants_generated", default: false
    t.datetime "variants_generated_at"
    t.boolean "translations_completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_recipes_on_name"
    t.index ["source_language"], name: "index_recipes_on_source_language"
  end

  create_table "user_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_user_favorites_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_user_favorites_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_user_favorites_on_user_id"
  end

  create_table "user_recipe_notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "recipe_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_user_recipe_notes_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_user_recipe_notes_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_user_recipe_notes_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "role", default: "user"
    t.string "preferred_language", default: "en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "data_reference_translations", "data_references", on_delete: :cascade
  add_foreign_key "equipment_translations", "equipment", on_delete: :cascade
  add_foreign_key "ingredient_aliases", "ingredients", on_delete: :cascade
  add_foreign_key "ingredient_group_translations", "ingredient_groups", on_delete: :cascade
  add_foreign_key "ingredient_groups", "recipes", on_delete: :cascade
  add_foreign_key "ingredient_nutrition", "ingredients", on_delete: :cascade
  add_foreign_key "recipe_aliases", "recipes", on_delete: :cascade
  add_foreign_key "recipe_cuisines", "data_references", on_delete: :cascade
  add_foreign_key "recipe_cuisines", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dietary_tags", "data_references", on_delete: :cascade
  add_foreign_key "recipe_dietary_tags", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dish_types", "data_references", on_delete: :cascade
  add_foreign_key "recipe_dish_types", "recipes", on_delete: :cascade
  add_foreign_key "recipe_equipments", "equipment", on_delete: :cascade
  add_foreign_key "recipe_equipments", "recipes", on_delete: :cascade
  add_foreign_key "recipe_ingredient_translations", "recipe_ingredients", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "ingredient_groups", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "ingredients", on_delete: :nullify
  add_foreign_key "recipe_nutritions", "recipes", on_delete: :cascade
  add_foreign_key "recipe_recipe_types", "data_references", on_delete: :cascade
  add_foreign_key "recipe_recipe_types", "recipes", on_delete: :cascade
  add_foreign_key "recipe_step_translations", "recipe_steps", on_delete: :cascade
  add_foreign_key "recipe_steps", "recipes", on_delete: :cascade
  add_foreign_key "recipe_translations", "recipes", on_delete: :cascade
  add_foreign_key "user_favorites", "recipes", on_delete: :cascade
  add_foreign_key "user_favorites", "users", on_delete: :cascade
  add_foreign_key "user_recipe_notes", "recipes", on_delete: :cascade
  add_foreign_key "user_recipe_notes", "users", on_delete: :cascade
end
