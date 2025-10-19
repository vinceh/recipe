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

ActiveRecord::Schema[8.0].define(version: 2025_10_07_154505) do
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

  create_table "data_references", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reference_type", null: false
    t.string "key", null: false
    t.string "display_name", null: false
    t.jsonb "metadata", default: {}
    t.integer "sort_order", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference_type", "key"], name: "index_data_references_on_reference_type_and_key", unique: true
    t.index ["reference_type"], name: "index_data_references_on_reference_type"
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
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "recipes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "language", default: "en"
    t.boolean "requires_precision", default: false
    t.string "precision_reason"
    t.jsonb "servings", default: {}
    t.jsonb "timing", default: {}
    t.jsonb "nutrition", default: {}
    t.jsonb "aliases", default: []
    t.jsonb "dietary_tags", default: []
    t.jsonb "dish_types", default: []
    t.jsonb "recipe_types", default: []
    t.jsonb "cuisines", default: []
    t.jsonb "ingredient_groups", default: []
    t.jsonb "steps", default: []
    t.jsonb "equipment", default: []
    t.jsonb "translations", default: {}
    t.boolean "variants_generated", default: false
    t.datetime "variants_generated_at"
    t.boolean "translations_completed", default: false
    t.string "source_url"
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aliases"], name: "index_recipes_on_aliases", using: :gin
    t.index ["cuisines"], name: "index_recipes_on_cuisines", using: :gin
    t.index ["dietary_tags"], name: "index_recipes_on_dietary_tags", using: :gin
    t.index ["dish_types"], name: "index_recipes_on_dish_types", using: :gin
    t.index ["language"], name: "index_recipes_on_language"
    t.index ["name"], name: "index_recipes_on_name"
    t.index ["recipe_types"], name: "index_recipes_on_recipe_types", using: :gin
  end

  create_table "user_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "recipe_id"], name: "index_user_favorites_on_user_id_and_recipe_id", unique: true
  end

  create_table "user_recipe_notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "recipe_id", null: false
    t.string "note_type", null: false
    t.string "note_target_id"
    t.text "note_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "recipe_id"], name: "index_user_recipe_notes_on_user_id_and_recipe_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0
    t.string "preferred_language", default: "en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ingredient_aliases", "ingredients"
  add_foreign_key "ingredient_nutrition", "ingredients"
  add_foreign_key "user_favorites", "recipes"
  add_foreign_key "user_favorites", "users"
  add_foreign_key "user_recipe_notes", "recipes"
  add_foreign_key "user_recipe_notes", "users"
end
