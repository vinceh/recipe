# Recipe Database Re-Architecture Plan

**Created**: 2025-10-22
**Updated**: 2025-10-22 (Added comprehensive i18n strategy + testing infrastructure)
**Status**: Draft for Review
**Scope**: Database schema normalization + i18n integration + testing infrastructure, ~226 atomic tasks across 16 phases

---

## What's New in This Update (2025-10-22)

**Major Addition: Comprehensive I18n Strategy**

This plan now includes full internationalization (i18n) support using the **Mobility gem** (Rails industry standard):

**Changes from Original Plan:**
1. ✅ **Mobility Gem Integration** (Phase 11) - Install and configure with Table Backend
2. ✅ **Translation System Refactor** (Phase 12) - Update background jobs to translate ALL recipe content
3. ✅ **Frontend Integration** (Phase 13) - 26 tasks for updating frontend to work with normalized schema
4. ✅ **Acceptance Criteria & RSpec Updates** (Phase 14) - Audit ACs, remove obsolete ones, add new ones, update/write RSpecs
5. ✅ **Testing Infrastructure** (Phases 15-16) - Model specs, CI/CD, job callbacks, security, frontend tests (~50 tasks)
6. ✅ **API Locale Support** - API accepts `?locale=ja` parameter, returns content in requested language
7. ✅ **Rename `language` → `source_language`** - Clarifies this tracks original authoring language
8. ✅ **~114 additional tasks** (62 from i18n/frontend/AC, 50 from testing) - Now **~226 total tasks** (was 112)
9. ✅ **No timeline section** - Focus on development with parallel Haiku agents (removed for MVP)

**What Gets Translated:**
- Recipe name (via Mobility)
- Ingredient group names (via Mobility)
- Ingredient names & preparation notes (via Mobility)
- Equipment names (via Mobility)
- Step instructions - all 3 variants: original, easier, no_equipment (via custom step_instructions table)
- Data reference tags like "Vegetarian" → "ベジタリアン" (via Mobility)

**Translation Workflow:**
1. User saves recipe in source language (e.g., English)
2. Background job generates step variants (easier, no_equipment) in source language
3. Background job translates ALL fields to all 6 target languages (ja, ko, zh-tw, zh-cn, es, fr)
4. User views recipe → Frontend passes `?locale=ja` → API returns Japanese content

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Part 1: Current State Analysis](#part-1-current-state-analysis)
3. [Part 2: Target Architecture](#part-2-target-architecture)
4. [Part 3: Phased Implementation](#part-3-phased-implementation)
5. [Part 4: Migration Strategy](#part-4-migration-strategy)
6. [Part 5: Risks & Mitigation](#part-5-risks--mitigation)
7. [Part 6: Success Criteria](#part-6-success-criteria)
8. [Questions for Approval](#questions-for-approval)

---

## Executive Summary

### Problem Statement

**Database Architecture Issues:**

The `recipes` table currently uses **12 JSONB fields** for storing recipe data:
- `servings`, `timing`, `nutrition` - Simple scalars as JSON
- `aliases`, `dietary_tags`, `dish_types`, `recipe_types`, `cuisines` - Arrays as JSONB
- `ingredient_groups`, `steps`, `equipment` - Complex nested structures
- `translations` - Currently unused JSONB field

**I18n Architecture Issues:**

- Recipe `language` column locks each recipe to ONE language (no translations)
- Only step instructions support language variants (`instructions.en`, `instructions.ja`)
- Recipe name, ingredients, equipment are NOT translatable
- User changes UI language but recipe content stays in original language
- `translations` JSONB field exists but is completely unused
- No standard Rails i18n gem integration (should use Mobility)

**Combined Issues**:
- ❌ No referential integrity (foreign keys)
- ❌ Queryability limited (can't join, filter, aggregate easily)
- ❌ I18n incomplete (only steps translated, recipe locked to one language)
- ❌ No schema documentation (structure only in Ruby validations)
- ❌ Service complexity (RecipeScaler, RecipeTranslator work with deeply nested JSON)
- ❌ Data consistency hard to enforce
- ❌ No industry-standard i18n gem (should use Mobility)

### Solution

**Part A: Normalize to proper relational schema:**
- Move simple scalars to columns (`servings_original`, `prep_minutes`, etc.)
- Create join tables for many-to-many relationships (dietary_tags, cuisines, etc.)
- Create proper tables for complex structures (ingredient_groups, recipe_ingredients, recipe_steps)
- Create equipment reference table + join table
- Create recipe_nutrition table with proper decimal columns

**Part B: Implement comprehensive i18n with Mobility gem:**
- Install Mobility gem (industry-standard Rails i18n, replaces deprecated Globalize)
- Use Table Backend: Each model gets `{model}_translations` table
- Rename `recipe.language` → `recipe.source_language` (tracks original authoring language)
- Translatable fields:
  - Recipe: `name` (via Mobility)
  - IngredientGroup: `name` (via Mobility)
  - RecipeIngredient: `ingredient_name`, `preparation_notes` (via Mobility)
  - Equipment: `canonical_name` (via Mobility)
  - DataReference: `display_name` (via Mobility - for tags like "Vegetarian" → "ベジタリアン")
  - Step instructions: Already have custom `step_instructions` table with language + variant columns
- API accepts `?locale=ja` parameter to return translated content
- Background jobs auto-translate on recipe save (existing RecipeTranslator service)

**Part C: Document everything:**
- Complete schema documentation with all field definitions
- I18n workflow documentation
- Migration guides

### Expected Benefits

**Database Benefits:**
- ✅ Query by nutrition, timing, ingredients, tags with proper SQL joins
- ✅ Enforce data integrity with foreign keys and constraints
- ✅ Simpler service code (work with associations, not nested JSON)
- ✅ Clear schema documentation
- ✅ Better performance (proper indexes, reduced data fetching)

**I18n Benefits:**
- ✅ Users can view ANY recipe in ANY supported language
- ✅ Recipe name, ingredients, steps, equipment all translatable
- ✅ UI language change immediately reflects in recipe content
- ✅ Industry-standard Mobility gem (actively maintained, well-documented)
- ✅ Automatic translation via AI background jobs
- ✅ Fallback to source language if translation missing

**Maintainability:**
- ✅ Easier future maintenance
- ✅ Standard Rails patterns (developers familiar with Mobility)
- ✅ Comprehensive documentation

### Scope & Scale

- **~226 atomic sub-tasks** across 16 phases (Phases 1-10 core refactor + expanded testing, 11-12 i18n, 13 frontend, 14-16 testing infrastructure)
- **~65% run by Haiku sub-agents** in parallel (schema, migrations, UI updates, tests)
- **~35% run by MAIN agent** (architecture decisions, complex i18n, comprehensive testing, security)
- **Development-focused migration** (no zero-downtime needed - MVP with test data only)
- **Comprehensive testing infrastructure** (backend models, frontend components, CI/CD)
- **Mobility gem integration** (industry-standard i18n)
- **Complete acceptance criteria audit** with RSpec & frontend test coverage

---

## Part 1: Current State Analysis

### JSONB Fields Audit

| Field | Type | Current Use | Issues | Target |
|-------|------|-------------|--------|--------|
| `servings` | JSONB | `{original: 2, min: 1, max: 4}` | No reason for JSON | **3 integer columns** |
| `timing` | JSONB | `{prep: 15, cook: 30, total: 45}` | Simple scalars | **3 integer columns** |
| `nutrition` | JSONB | Currently empty | Will contain nutrition data | **Separate table** |
| `aliases` | JSONB array | `["alt name"]` | Many-to-many | **Join table** |
| `dietary_tags` | JSONB array | `["vegetarian"]` | References data_references | **Join table** |
| `dish_types` | JSONB array | `["main-course"]` | References data_references | **Join table** |
| `recipe_types` | JSONB array | `["quick-weeknight"]` | References data_references | **Join table** |
| `cuisines` | JSONB array | `["japanese"]` | References data_references | **Join table** |
| `ingredient_groups` | JSONB | Nested structure | Complex model | **2 tables** (ingredient_groups + recipe_ingredients) + Mobility translations |
| `steps` | JSONB | Nested with i18n | Complex + translation needs | **2 tables** (recipe_steps + step_instructions) |
| `equipment` | JSONB array | `["pan", "knife"]` | Should be normalized | **Reference table + join table** + Mobility translations |
| `translations` | JSONB | Empty, unused | Wrong i18n approach | **Remove entirely, use Mobility** |

### Current Structure Examples

**Servings (unnecessary JSONB):**
```json
{
  "original": 2,
  "min": 1,
  "max": 4
}
```
→ Should be: `servings_original: 2, servings_min: 1, servings_max: 4`

**Ingredient Groups (necessary complex structure):**
```json
{
  "name": "Main Ingredients",
  "items": [
    {
      "id": 1,
      "name": "chicken",
      "amount": 300,
      "unit": "g",
      "notes": "boneless"
    }
  ]
}
```
→ Should be: Separate `ingredient_groups` and `recipe_ingredients` tables

**Steps (needs i18n):**
```json
{
  "id": "step-001",
  "order": 1,
  "instructions": {
    "en": "Heat oil..."
  }
}
```
→ Should be: `recipe_steps` table + `step_instructions` table with language key

### I18n Current State Audit

**What's Already Translatable:**
- ✅ Step instructions support language variants (`instructions.en`, `instructions.ja`, etc.)
- ✅ `RecipeTranslator` service exists (uses AI to generate translations)
- ✅ `TranslateRecipeJob` background job exists
- ✅ `I18nService` handles locale detection from Accept-Language header
- ✅ Frontend i18n configured (Vue i18n with 7 locales)

**What's NOT Translatable (Problems):**
- ❌ Recipe `name` - locked to source language
- ❌ Ingredient group `name` - locked to source language
- ❌ Recipe ingredient `ingredient_name` - locked to source language
- ❌ Recipe ingredient `preparation_notes` - locked to source language
- ❌ Equipment names - locked to source language
- ❌ DataReference `display_name` (tags) - locked to source language (e.g., "Vegetarian" can't become "ベジタリアン")
- ❌ Recipe `language` column locks entire recipe to one language
- ❌ `translations` JSONB field exists but completely unused

**Translation Workflow Issues:**
- Current: `TranslateRecipeJob` writes to unused `translations` JSONB field
- Current: `StepVariantGenerator` assumes `instructions.original` exists (but we use `instructions.en`)
- Current: No callback triggers translation jobs after recipe save
- Missing: No API support for `?locale=` parameter
- Missing: Frontend can't request recipes in different languages

**Target I18n Architecture:**
- Install **Mobility gem** (industry standard, Table Backend)
- Rename `recipe.language` → `recipe.source_language`
- Add translation tables:
  - `recipe_translations` (name)
  - `ingredient_group_translations` (name)
  - `recipe_ingredient_translations` (ingredient_name, preparation_notes)
  - `equipment_translations` (canonical_name)
  - `data_reference_translations` (display_name)
- Keep manual `step_instructions` table (already has language column)
- API accepts `?locale=ja` to set Mobility.locale
- Background jobs auto-translate after recipe save

### Services Affected

**11 services** depend on current JSONB structure:
1. **RecipeScaler** - Reads servings, scaling logic
2. **RecipeTranslator** - Writes to translations JSONB (currently unused)
3. **RecipeParserService** - Creates steps/ingredients JSONB
4. **StepVariantGenerator** - Reads steps, modifies instructions
5. **RecipeNutritionCalculator** - Would read/write nutrition
6. **RecipeSearchService** - Filters on tags, cuisines
7. **RecipeSerializer** - Reads all JSONB for API response
8. **AdminRecipesController** - CRUD on all fields
9. **RecipeValidator** - Validates nested structures
10. **I18nService** - Handles translation (if exists)
11. **UnitConverter** - Works with ingredient amounts

### Translation System Analysis

**Existing Code (`app/jobs/translate_recipe_job.rb`):**
```ruby
class TranslateRecipeJob < ApplicationJob
  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    translator = RecipeTranslator.new
    translations = {}

    RecipeTranslator::LANGUAGES.keys.each do |lang|
      translations[lang] = translator.translate_recipe(recipe, lang)
    end

    recipe.update!(
      translations: translations,        # ❌ Writes to JSONB (being removed)
      translations_completed: true       # ❌ Column being removed
    )
  end
end
```

**Existing Code (`app/services/recipe_translator.rb`):**
```ruby
class RecipeTranslator < AiService
  LANGUAGES = { 'ja' => 'Japanese', 'ko' => 'Korean', 'zh-tw' => 'Traditional Chinese (Taiwan)',
                'zh-cn' => 'Simplified Chinese (China)', 'es' => 'Spanish', 'fr' => 'French' }

  def translate_recipe(recipe, target_language)
    # Gets prompts: 'recipe_translation_system', 'recipe_translation_user' (DON'T EXIST YET!)
    # Calls Claude AI with recipe.to_json
    # Returns translated JSON
  end
end
```

**Current Problems:**
1. ❌ No `after_save` callback - translation jobs never triggered automatically
2. ❌ Writes to `translations` JSONB field - being removed
3. ❌ Translation prompts don't exist in database yet
4. ❌ Translates entire recipe as one JSON blob - doesn't work with new schema
5. ❌ `translations_completed` column - being removed

**What Needs to Change:**

**1. Add Model Callback**
```ruby
# app/models/recipe.rb
after_commit :enqueue_translation_jobs, on: [:create, :update]

def enqueue_translation_jobs
  GenerateStepVariantsJob.perform_later(id)  # First: generate easier/no_equipment variants
  TranslateRecipeJob.perform_later(id)       # Then: translate everything
end
```

**2. Refactor TranslateRecipeJob**
- Change from single monolithic job to orchestrator
- Trigger 5 specialized jobs in parallel:
  - `TranslateRecipeFieldsJob` - Translates recipe.name via Mobility
  - `TranslateIngredientGroupsJob` - Translates ingredient group names via Mobility
  - `TranslateIngredientsJob` - Translates ingredient names/notes via Mobility
  - `TranslateEquipmentJob` - Translates equipment names via Mobility
  - `TranslateStepInstructionsJob` - Translates step instructions (all 3 variants) via Mobility

**3. Update RecipeTranslator Service**
- Use `Mobility.with_locale(target_language)` instead of JSONB
- Translate field-by-field instead of whole recipe JSON
- Example:
```ruby
def translate_recipe_name(recipe, target_language)
  Mobility.with_locale(target_language) do
    translated_name = call_claude_for_translation(recipe.name, target_language)
    recipe.name = translated_name
    recipe.save!
  end
end
```

**4. Create Translation AI Prompts**
- Need to seed `ai_prompts` table with:
  - `recipe_translation_system` - System prompt for translations
  - `recipe_translation_user` - User prompt template
  - Separate prompts for different field types (name, ingredients, steps, equipment)

**5. Track Translation Status**
- Add `translation_status` JSONB field to track progress per language
```json
{
  "ja": { "status": "completed", "completed_at": "2025-10-22T10:00:00Z" },
  "ko": { "status": "in_progress", "started_at": "2025-10-22T10:01:00Z" },
  "zh-tw": { "status": "pending" }
}
```

---

## Part 2: Target Architecture

### Complete Schema Design (Rails schema.rb Format)

The target schema uses Rails conventions with Mobility gem for i18n. All IDs are UUIDs.

```ruby
# db/schema.rb (target state after migration)

ActiveRecord::Schema[8.0].define(version: 2025_10_22_000000) do
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # ============================================================================
  # CORE RECIPE TABLE
  # ============================================================================

  create_table "recipes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string   "name", null: false                    # Translatable via Mobility
    t.string   "source_language", default: "en", null: false

    # Simple scalars (was JSONB servings)
    t.integer  "servings_original"
    t.integer  "servings_min"
    t.integer  "servings_max"

    # Simple scalars (was JSONB timing)
    t.integer  "prep_minutes"
    t.integer  "cook_minutes"
    t.integer  "total_minutes"

    # Metadata
    t.boolean  "requires_precision", default: false
    t.string   "precision_reason"
    t.string   "source_url"
    t.text     "admin_notes"

    # Processing status
    t.boolean  "variants_generated", default: false
    t.datetime "variants_generated_at"
    t.jsonb    "translation_status", default: {}      # Track translation progress per language

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["name"], name: "index_recipes_on_name"
    t.index ["source_language"], name: "index_recipes_on_source_language"
  end

  # Mobility translation table for recipe names
  create_table "recipe_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.string   "locale", null: false
    t.string   "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["recipe_id"], name: "index_recipe_translations_on_recipe_id"
    t.index ["locale"], name: "index_recipe_translations_on_locale"
    t.index ["recipe_id", "locale"], name: "index_recipe_translations_on_recipe_id_and_locale", unique: true
  end

  # ============================================================================
  # MANY-TO-MANY JOIN TABLES (was JSONB arrays)
  # ============================================================================

  create_table "recipe_dietary_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_dietary_tags_unique", unique: true
  end

  create_table "recipe_dish_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_dish_types_unique", unique: true
  end

  create_table "recipe_recipe_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_recipe_types_unique", unique: true
  end

  create_table "recipe_cuisines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index ["recipe_id", "data_reference_id"], name: "index_recipe_cuisines_unique", unique: true
  end

  create_table "recipe_aliases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.string   "alias_name", null: false
    t.string   "language"
    t.datetime "created_at", null: false

    t.index ["recipe_id"], name: "index_recipe_aliases_on_recipe_id"
    t.index ["recipe_id", "alias_name", "language"], name: "index_recipe_aliases_unique", unique: true
  end

  # ============================================================================
  # DATA REFERENCES + TRANSLATIONS
  # ============================================================================

  # (data_references table already exists, adding translations support)

  create_table "data_reference_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "data_reference_id", null: false
    t.string   "locale", null: false
    t.string   "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["data_reference_id"], name: "index_data_reference_translations_on_reference_id"
    t.index ["locale"], name: "index_data_reference_translations_on_locale"
    t.index ["data_reference_id", "locale"], name: "index_data_reference_translations_unique", unique: true
  end

  # ============================================================================
  # INGREDIENTS (was complex JSONB)
  # ============================================================================

  create_table "ingredient_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.string   "name", null: false                    # Translatable via Mobility
    t.integer  "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["recipe_id"], name: "index_ingredient_groups_on_recipe_id"
    t.index ["recipe_id", "position"], name: "index_ingredient_groups_on_recipe_id_and_position", unique: true
  end

  create_table "ingredient_group_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "ingredient_group_id", null: false
    t.string   "locale", null: false
    t.string   "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["ingredient_group_id"], name: "index_ingredient_group_translations_on_group_id"
    t.index ["locale"], name: "index_ingredient_group_translations_on_locale"
    t.index ["ingredient_group_id", "locale"], name: "index_ingredient_group_translations_unique", unique: true
  end

  create_table "recipe_ingredients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "ingredient_group_id", null: false
    t.uuid     "ingredient_id"                        # Optional FK to ingredients table (for nutrition)
    t.string   "ingredient_name", null: false         # Denormalized, translatable via Mobility
    t.decimal  "amount", precision: 10, scale: 2
    t.string   "unit"
    t.text     "preparation_notes"                    # Translatable via Mobility
    t.boolean  "optional", default: false
    t.integer  "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["ingredient_group_id"], name: "index_recipe_ingredients_on_group_id"
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["ingredient_group_id", "position"], name: "index_recipe_ingredients_unique_position", unique: true
  end

  create_table "recipe_ingredient_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_ingredient_id", null: false
    t.string   "locale", null: false
    t.string   "ingredient_name", null: false
    t.text     "preparation_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["recipe_ingredient_id"], name: "index_recipe_ingredient_translations_on_ingredient_id"
    t.index ["locale"], name: "index_recipe_ingredient_translations_on_locale"
    t.index ["recipe_ingredient_id", "locale"], name: "index_recipe_ingredient_translations_unique", unique: true
  end

  # ============================================================================
  # EQUIPMENT (was JSONB array)
  # ============================================================================

  create_table "equipment", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string   "canonical_name", null: false          # Translatable via Mobility
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["canonical_name"], name: "index_equipment_on_canonical_name", unique: true
  end

  create_table "equipment_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "equipment_id", null: false
    t.string   "locale", null: false
    t.string   "canonical_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["equipment_id"], name: "index_equipment_translations_on_equipment_id"
    t.index ["locale"], name: "index_equipment_translations_on_locale"
    t.index ["equipment_id", "locale"], name: "index_equipment_translations_unique", unique: true
  end

  create_table "recipe_equipment", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "equipment_id", null: false
    t.boolean  "optional", default: false
    t.datetime "created_at", null: false

    t.index ["recipe_id"], name: "index_recipe_equipment_on_recipe_id"
    t.index ["recipe_id", "equipment_id"], name: "index_recipe_equipment_unique", unique: true
  end

  # ============================================================================
  # RECIPE STEPS + INSTRUCTIONS (was complex JSONB with nested i18n)
  # ============================================================================

  create_table "recipe_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.integer  "step_number", null: false
    t.integer  "timing_minutes"
    t.text     "instruction_original"                 # Translatable via Mobility
    t.text     "instruction_easier"                   # Translatable via Mobility
    t.text     "instruction_no_equipment"             # Translatable via Mobility
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["recipe_id"], name: "index_recipe_steps_on_recipe_id"
    t.index ["recipe_id", "step_number"], name: "index_recipe_steps_on_recipe_id_and_step_number", unique: true
  end

  # Mobility translation table for step instructions (3 variants per locale)
  create_table "recipe_step_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_step_id", null: false
    t.string   "locale", null: false
    t.text     "instruction_original"
    t.text     "instruction_easier"
    t.text     "instruction_no_equipment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["recipe_step_id"], name: "index_recipe_step_translations_on_step_id"
    t.index ["locale"], name: "index_recipe_step_translations_on_locale"
    t.index ["recipe_step_id", "locale"], name: "index_recipe_step_translations_unique", unique: true
  end

  # ============================================================================
  # NUTRITION (was unused JSONB, now proper table)
  # ============================================================================

  create_table "recipe_nutrition", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.decimal  "calories", precision: 8, scale: 2
    t.decimal  "protein_g", precision: 6, scale: 2
    t.decimal  "carbs_g", precision: 6, scale: 2
    t.decimal  "fat_g", precision: 6, scale: 2
    t.decimal  "fiber_g", precision: 6, scale: 2
    t.decimal  "sodium_mg", precision: 8, scale: 2
    t.decimal  "sugar_g", precision: 6, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index ["recipe_id"], name: "index_recipe_nutrition_on_recipe_id", unique: true
  end

  # ============================================================================
  # FOREIGN KEYS
  # ============================================================================

  add_foreign_key "recipe_translations", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dietary_tags", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dietary_tags", "data_references", on_delete: :cascade
  add_foreign_key "recipe_dish_types", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dish_types", "data_references", on_delete: :cascade
  add_foreign_key "recipe_recipe_types", "recipes", on_delete: :cascade
  add_foreign_key "recipe_recipe_types", "data_references", on_delete: :cascade
  add_foreign_key "recipe_cuisines", "recipes", on_delete: :cascade
  add_foreign_key "recipe_cuisines", "data_references", on_delete: :cascade
  add_foreign_key "recipe_aliases", "recipes", on_delete: :cascade
  add_foreign_key "data_reference_translations", "data_references", on_delete: :cascade
  add_foreign_key "ingredient_groups", "recipes", on_delete: :cascade
  add_foreign_key "ingredient_group_translations", "ingredient_groups", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "ingredient_groups", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "ingredients", on_delete: :nullify
  add_foreign_key "recipe_ingredient_translations", "recipe_ingredients", on_delete: :cascade
  add_foreign_key "equipment_translations", "equipment", on_delete: :cascade
  add_foreign_key "recipe_equipment", "recipes", on_delete: :cascade
  add_foreign_key "recipe_equipment", "equipment", on_delete: :cascade
  add_foreign_key "recipe_steps", "recipes", on_delete: :cascade
  add_foreign_key "recipe_step_translations", "recipe_steps", on_delete: :cascade
  add_foreign_key "recipe_nutrition", "recipes", on_delete: :cascade
end
```

### Model Declarations (with Mobility)

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

  has_many :ingredient_groups, dependent: :destroy
  has_many :recipe_ingredients, through: :ingredient_groups
  has_many :recipe_steps, -> { order(:step_number) }, dependent: :destroy
  has_one :recipe_nutrition, dependent: :destroy
  has_many :recipe_equipment, dependent: :destroy
  has_many :equipment, through: :recipe_equipment
  has_many :recipe_dietary_tags, dependent: :destroy
  has_many :dietary_tags, through: :recipe_dietary_tags, source: :data_reference
  # ... other associations

  after_commit :enqueue_translation_jobs, on: [:create, :update]
end

# app/models/ingredient_group.rb
class IngredientGroup < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

  belongs_to :recipe
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy
end

# app/models/recipe_ingredient.rb
class RecipeIngredient < ApplicationRecord
  extend Mobility
  translates :ingredient_name, :preparation_notes, backend: :table

  belongs_to :ingredient_group
  belongs_to :ingredient, optional: true  # For nutrition lookup
end

# app/models/recipe_step.rb
class RecipeStep < ApplicationRecord
  extend Mobility
  translates :instruction_original, :instruction_easier, :instruction_no_equipment, backend: :table

  belongs_to :recipe
end

# app/models/equipment.rb
class Equipment < ApplicationRecord
  extend Mobility
  translates :canonical_name, backend: :table

  has_many :recipe_equipment
  has_many :recipes, through: :recipe_equipment
end

# app/models/data_reference.rb
class DataReference < ApplicationRecord
  extend Mobility
  translates :display_name, backend: :table
end
```

### Key Changes from Current Schema

1. **Removed JSONB columns:**
   - `servings` → 3 integer columns
   - `timing` → 3 integer columns
   - `aliases` → `recipe_aliases` table
   - `dietary_tags`, `dish_types`, `recipe_types`, `cuisines` → 4 join tables
   - `ingredient_groups` → 2 tables (`ingredient_groups` + `recipe_ingredients`)
   - `steps` → 2 tables (`recipe_steps` + `recipe_step_translations`)
   - `equipment` → 2 tables (`equipment` + `recipe_equipment`)
   - `translations` → Removed, handled by Mobility translation tables
   - `nutrition` → `recipe_nutrition` table

2. **Added Mobility translation tables** (6 total):
   - `recipe_translations` (name)
   - `ingredient_group_translations` (name)
   - `recipe_ingredient_translations` (ingredient_name, preparation_notes)
   - `equipment_translations` (canonical_name)
   - `recipe_step_translations` (all 3 instruction variants)
   - `data_reference_translations` (display_name)

3. **Renamed column:**
   - `language` → `source_language`

4. **Added column:**
   - `translation_status` JSONB (track progress per language)

---

## Part 3: Phased Implementation

### Phase 1: Preparation & Documentation (5 MAIN/HAIKU tasks)

| Task ID | Agent | Description | Deliverable | AC |
|---------|-------|-------------|-------------|-----|
| PREP-001 | MAIN | Document current JSONB structures | `docs/database-schema-current.md` | All 12 fields documented with examples |
| PREP-002 | HAIKU | Audit all services dependencies | Spreadsheet: Service → Fields → Methods | List of 11+ services with dependencies |
| PREP-003 | HAIKU | Create test data snapshot | `spec/fixtures/recipes_pre_migration.json` | JSON export of all 14 recipes |
| PREP-004 | MAIN | Design migration validation strategy | Validation checklist | 20+ validation points documented |
| PREP-005 | HAIKU | Set up parallel schema branch | Git branch `feature/schema-normalization` | Clean branch ready for work |

### Phase 2: Simple Scalar Fields (8 HAIKU tasks)

| Task ID | Agent | Description | Acceptance Criteria |
|---------|-------|-------------|---------------------|
| SCALAR-001 | HAIKU | Create migration: Extract servings | servings_original, servings_min, servings_max columns added |
| SCALAR-002 | HAIKU | Create migration: Extract timing | prep_minutes, cook_minutes, total_minutes columns added |
| SCALAR-003 | HAIKU | Update Recipe model with dual-read | Model can read both JSONB and new columns, backwards compatible |
| SCALAR-004 | HAIKU | Update frontend RecipeForm | Form works with new column names in API |
| SCALAR-005 | HAIKU | Update RecipeScaler service | Uses new columns, all tests pass |
| SCALAR-006 | HAIKU | Update API serializers | JSON response unchanged, uses new columns |
| SCALAR-007 | HAIKU | Create data migration script | Copies all servings/timing from JSONB to columns, validates 14 recipes |
| SCALAR-008 | HAIKU | Remove JSONB columns | Drop servings, timing; all tests pass |

### Phase 3: Many-to-Many Join Tables (12 HAIKU tasks)

Create join tables: `recipe_dietary_tags`, `recipe_dish_types`, `recipe_recipe_types`, `recipe_cuisines`

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| JOIN-001 to JOIN-004 | HAIKU | Create 4 join table migrations | All tables created with FK + unique constraints |
| JOIN-005 | HAIKU | Update Recipe model associations | has_many through associations defined |
| JOIN-006 to JOIN-009 | HAIKU | Create 4 data migration scripts | All tags/types/cuisines migrated from JSONB arrays |
| JOIN-010 | MAIN | Update RecipeSearchService | Filtering uses JOIN tables, no performance regression |
| JOIN-011 | HAIKU | Update admin recipes controller | Filtering endpoints work correctly |
| JOIN-012 | HAIKU | Remove JSONB tag columns | Drop all 4 arrays, tests pass |

### Phase 4: Ingredient Groups Normalization (15 MAIN/HAIKU mix)

Create `ingredient_groups` and `recipe_ingredients` tables

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| ING-001 to ING-002 | HAIKU | Create 2 table migrations | Tables created with PKs, FKs, indexes |
| ING-003 to ING-004 | HAIKU | Create 2 models | IngredientGroup + RecipeIngredient models |
| ING-005 | MAIN | Update Recipe model associations | has_many :ingredient_groups and nested associations |
| ING-006 | MAIN | Create complex data migration | Parses JSONB, creates records, preserves ordering |
| ING-007 to ING-013 | HAIKU | Update 7 services/components | RecipeScaler, calculator, serializers, form, detail, parser, seeds |
| ING-014 | HAIKU | Remove ingredient_groups column | Drop JSONB, tests pass |
| ING-015 | HAIKU | Add performance indexes | Index on recipe_id, ingredient_group_id, position |

### Phase 5: Steps Normalization & I18n (18 MAIN/HAIKU mix)

Create `recipe_steps` and `step_instructions` tables

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| STEP-001 to STEP-002 | HAIKU | Create 2 table migrations | recipe_steps + step_instructions tables |
| STEP-003 to STEP-004 | HAIKU | Create 2 models | RecipeStep + StepInstruction models with validations |
| STEP-005 | MAIN | Update Recipe model associations | has_many :recipe_steps with ordering |
| STEP-006 | MAIN | Create complex data migration | Parses steps JSONB, creates records, handles i18n |
| STEP-007 to STEP-008 | HAIKU | Update StepVariantGenerator + RecipeTranslator | Uses new tables, creates step_instructions |
| STEP-009 to STEP-014 | HAIKU | Update 6 services/components | Serializers, StepList, variant toggle, parser, seeds |
| STEP-015 | HAIKU | Add indexes | On recipe_steps and step_instructions |
| STEP-016 to STEP-017 | HAIKU | Create step_equipment table | Join table linking steps to equipment |
| STEP-018 | HAIKU | Update StepList UI | Show equipment per step (optional) |

### Phase 6: Equipment & Aliases (8 HAIKU tasks)

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| EQUIP-001 to EQUIP-002 | HAIKU | Create equipment + recipe_equipment migrations | Tables created |
| EQUIP-003 | HAIKU | Seed equipment reference data | 200-300 equipment records created + categorized |
| EQUIP-004 | MAIN | Create equipment data migration | Match recipes to equipment, handle fuzzy matching |
| EQUIP-005 to EQUIP-007 | HAIKU | Update model, API, remove column | Association added, API updated, JSONB removed |
| ALIAS-001 | HAIKU | Complete aliases normalization | Create table, migrate data, update code, remove JSONB |

### Phase 7: Nutrition Normalization (6 HAIKU tasks)

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| NUT-001 | HAIKU | Create recipe_nutrition migration | Table created with 8 columns, decimal precision |
| NUT-002 to NUT-003 | HAIKU | Create model + associations | RecipeNutrition model + Recipe has_one |
| NUT-004 to NUT-005 | HAIKU | Update calculator + API | Uses new table, API returns nutrition |
| NUT-006 | HAIKU | Remove nutrition column | Drop JSONB, tests pass |

### Phase 8: Application Code Updates (20 MAIN/HAIKU mix)

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| APP-001 to APP-003 | HAIKU | Update RSpec tests | Model, service, controller tests pass |
| APP-004 | MAIN | Optimize RecipeSearchService | Query performance meets benchmarks |
| APP-005 to APP-006 | HAIKU | Update API endpoints | Admin + user endpoints work |
| APP-007 to APP-015 | HAIKU | Update 9 frontend components | All views render correctly with new API |
| APP-016 | HAIKU | Update Pinia stores | Store logic updated for associations |
| APP-017 | HAIKU | Run integration tests | E2E workflows pass |
| APP-018 | MAIN | Performance optimization | No N+1 queries, proper eager loading |
| APP-019 | HAIKU | Update seeds | All 14 recipes seed with new schema |
| APP-020 | MAIN | Security audit | SQL injection + auth checks pass |

### Phase 9: Data Migration Scripts (16 MAIN/HAIKU mix)

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| MIG-001 | MAIN | Create master orchestration script | Single script runs all migrations in order |
| MIG-002 to MIG-010 | HAIKU | Create 9 validation/utility scripts | Validation, rollback, cleanup scripts |
| MIG-011 | MAIN | Estimate downtime window | Timeline for cutover calculated |
| MIG-012 | MAIN | Create deployment checklist | Step-by-step runbook with checkpoints |
| MIG-013 | MAIN | Write migration reversibility tests | Each migration can be reversed (up/down) without data loss |
| MIG-014 | HAIKU | Write JSONB data transformation tests | Test old JSONB structure → new normalized schema data integrity |
| MIG-015 | HAIKU | Test default values and constraints | JSONB defaults, unique constraints, foreign keys work correctly |
| MIG-016 | MAIN | Run migration tests in CI | CI pipeline validates all migrations before merge |

### Phase 10: Documentation Updates (11 HAIKU/MAIN mix)

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| DOC-001 | MAIN | Create comprehensive database documentation | `docs/database-architecture.md` created with all fields, units, JSONB structures, relationships |
| DOC-002 | HAIKU | Add database-architecture.md reference to entry.md | Entry.md updated with link in Backend Docs table + Common Tasks + Document Organization |
| DOC-003 | HAIKU | Remove duplicate database section from architecture.md | Replaced detailed database schema with reference to database-architecture.md |
| DOC-004 | HAIKU | Update api-reference.md with schema reference | Add note pointing to database-architecture.md for field definitions |
| DOC-005 | MAIN | Create i18n workflow documentation | `docs/i18n-workflow.md` explains Mobility, translation jobs, locale handling, API usage |
| DOC-006 | HAIKU | Update architecture.md Models section | Clarify which models use Mobility translations, reference database-architecture.md |
| DOC-007 | MAIN | Create migration guide for developers | Document how to migrate from old JSONB schema to new normalized tables |
| DOC-008 | MAIN | Post-mortem & lessons learned | Document completed re-architecture, key decisions, performance improvements |
| DOC-009 | HAIKU | Document job callback patterns | Explain when GenerateStepVariantsJob, TranslateRecipeJob, NutritionLookupJob trigger |
| DOC-010 | HAIKU | Document error handling conventions | Service layer error patterns, retry logic, graceful fallbacks |
| DOC-011 | HAIKU | Document testing patterns & conventions | Test structure, fixtures, mock patterns for developers |

### Phase 11: Mobility Gem Integration (15 MAIN/HAIKU mix)

Install and configure Mobility gem with Table Backend for comprehensive i18n support

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| MOB-001 | HAIKU | Add Mobility gem to Gemfile | `gem 'mobility'` added, bundle install succeeds |
| MOB-002 | MAIN | Configure Mobility initializer | `config/initializers/mobility.rb` with Table Backend configured |
| MOB-003 | HAIKU | Create 5 translation table migrations | recipe_translations, ingredient_group_translations, recipe_ingredient_translations, equipment_translations, data_reference_translations |
| MOB-004 to MOB-008 | HAIKU | Add `translates` to 5 models | Recipe, IngredientGroup, RecipeIngredient, Equipment, DataReference have `translates :field_name` |
| MOB-009 | HAIKU | Rename `language` to `source_language` | Migration + model updates complete |
| MOB-010 | HAIKU | Remove unused `translations` JSONB column | Column dropped, tests pass |
| MOB-011 | MAIN | Update Recipe model callbacks | Mobility configured correctly, I18n.locale works |
| MOB-012 to MOB-014 | HAIKU | Update serializers to use Mobility | API returns translated content based on locale |
| MOB-015 | HAIKU | Add Mobility fallback configuration | Falls back to source_language if translation missing |

### Phase 12: Translation System Refactor (22 MAIN/HAIKU mix)

Refactor translation workflow to use Mobility + background jobs

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| TRANS-001 | MAIN | Audit existing RecipeTranslator service | Document current behavior, identify changes needed |
| TRANS-002 | MAIN | Design new translation job architecture | Job flow diagram: variant generation → translation |
| TRANS-003 | HAIKU | Update StepVariantGenerator | Generates variants in source language first |
| TRANS-004 | MAIN | Refactor TranslateRecipeJob | Now translates ALL fields via Mobility + step_instructions |
| TRANS-005 to TRANS-009 | HAIKU | Create 5 specialized translation jobs | TranslateRecipeFieldsJob, TranslateIngredientGroupsJob, TranslateIngredientsJob, TranslateEquipmentJob, TranslateStepsJob |
| TRANS-010 | MAIN | Update RecipeTranslator service | Uses Mobility.with_locale to set translations |
| TRANS-011 | HAIKU | Add after_save callback to Recipe | Triggers GenerateStepVariantsJob then TranslateRecipeJob |
| TRANS-012 to TRANS-013 | HAIKU | Update AI prompt seeds | Update prompts to generate translations correctly |
| TRANS-014 | MAIN | Create translation status tracking | Recipe has translation_status JSONB field tracking progress per language |
| TRANS-015 to TRANS-018 | HAIKU | Update 4 controllers | API accepts `?locale=` param, sets Mobility.locale |
| TRANS-019 | HAIKU | Update frontend API client | Passes current UI language as `?locale=` param |
| TRANS-020 | HAIKU | Test translation workflow end-to-end | Create recipe → variants generated → all 6 languages translated |
| TRANS-021 | HAIKU | Update admin UI | Show translation status, allow manual re-translation |
| TRANS-022 | MAIN | Performance optimization | Translation jobs don't block recipe save, run in parallel |

### Phase 13: Frontend Integration & Verification (26 HAIKU/MAIN mix)

Update frontend to work with normalized backend schema and Mobility i18n system

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| FE-001 | HAIKU | Update `types.ts` to match new normalized API responses | TypeScript interfaces updated for normalized data structure |
| FE-002 | HAIKU | Update RecipeDetail interface with relational structure | Interface includes separate ingredient_groups, steps, nutrition relations |
| FE-003 | HAIKU | Update ingredient/step interfaces for normalized data | Interfaces match backend normalized models |
| FE-004 | HAIKU | Add types for translation status and Mobility responses | TypeScript types for `translation_status` JSONB and Mobility patterns |
| FE-005 | HAIKU | Update recipeApi.ts to handle new response format | API service correctly parses normalized responses |
| FE-006 | HAIKU | Add locale parameter to all recipe API calls | All recipe endpoints include `?locale=` query parameter |
| FE-007 | HAIKU | Update admin API calls to work with normalized data | Admin endpoints handle create/update with normalized structure |
| FE-008 | HAIKU | Update AdminRecipes.vue list view for new data structure | Recipe list displays correctly with normalized data |
| FE-009 | HAIKU | Update AdminRecipeDetail.vue to display normalized data | Recipe detail view shows all normalized fields correctly |
| FE-010 | HAIKU | Update AdminRecipeNew.vue form to work with new structure | Recipe creation form submits normalized data |
| FE-011 | HAIKU | Update RecipeForm.vue to handle separate ingredient_groups API | Form correctly creates/updates ingredient groups as separate entities |
| FE-012 | HAIKU | Update RecipeForm.vue to handle separate steps API | Form correctly creates/updates steps with Mobility translations |
| FE-013 | HAIKU | Update tag selectors to use join table relationships | Dietary tags, dish types, cuisines, recipe types use join tables |
| FE-014 | HAIKU | Update ViewRecipe.vue to read normalized data structure | User-facing recipe view displays normalized data correctly |
| FE-015 | HAIKU | Update ingredient display to handle separate translations | Ingredients show translated names based on locale |
| FE-016 | HAIKU | Update step display to handle Mobility translations | Steps show translated instructions (original/easier/no_equipment) |
| FE-017 | MAIN | Add locale detection from UI language | Frontend detects current UI language and uses it for API calls |
| FE-018 | HAIKU | Pass `?locale=` param to all recipe endpoints | All API calls include user's selected language |
| FE-019 | HAIKU | Handle translation fallbacks when translation missing | App gracefully falls back to source language if translation unavailable |
| FE-020 | HAIKU | Update language switcher to refetch recipe data | Switching UI language triggers recipe data refresh with new locale |
| FE-021 | MAIN | Test all 7 languages in admin recipe list view | All languages display correctly in recipe list |
| FE-022 | MAIN | Test all 7 languages in admin recipe detail view | All languages display correctly in recipe detail |
| FE-023 | MAIN | Test all 7 languages in user recipe view | All languages display correctly in user-facing view |
| FE-024 | MAIN | Test recipe create/edit/delete workflows | CRUD operations work with normalized schema |
| FE-025 | MAIN | Test recipe search & filtering with new join tables | Search and filters work with normalized tag relationships |
| FE-026 | MAIN | Visual regression testing | No UI breaks, all components render properly |

### Phase 14: Acceptance Criteria & RSpec Updates (18 HAIKU/MAIN mix)

Update acceptance criteria and test suite to reflect normalized schema and new i18n approach

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| AC-001 | MAIN | Audit existing acceptance criteria | Document which ACs are still valid, which need updates, which are obsolete |
| AC-002 | HAIKU | Remove obsolete ACs from acceptance-criteria.md | Delete ACs that no longer apply to new architecture |
| AC-003 | HAIKU | Update scaling ACs for normalized schema | ACs still valid, clarify they work with new ingredient structure |
| AC-004 | HAIKU | Update i18n ACs for Mobility gem | Update translation ACs to reference Mobility Table Backend approach |
| AC-005 | HAIKU | Update nutrition ACs for normalized table | ACs valid, clarify they use new recipe_nutrition table |
| AC-006 | MAIN | Add new ACs for normalized relationships | ACs for ingredient groups, steps, join tables (recipe_dietary_tags, etc.) |
| AC-007 | MAIN | Add new ACs for Mobility i18n | ACs for locale-based responses, translation fallbacks, status tracking |
| AC-008 | MAIN | Add new ACs for API changes | ACs for new API response format, ?locale= parameter handling |
| RSPEC-001 | HAIKU | Delete obsolete RSpec tests | Remove tests for old JSONB field structures |
| RSPEC-002 | HAIKU | Update scaling RSpecs | RSpecs still pass with normalized schema |
| RSPEC-003 | HAIKU | Update i18n RSpecs | RSpecs updated for Mobility gem approach |
| RSPEC-004 | HAIKU | Update nutrition RSpecs | RSpecs for recipe_nutrition table structure |
| RSPEC-005 | MAIN | Write RSpecs for normalized relationships | Tests for ingredient_groups, steps, join table associations |
| RSPEC-006 | MAIN | Write RSpecs for Mobility translations | Tests for translate blocks, locale switching, fallbacks |
| RSPEC-007 | MAIN | Write RSpecs for API endpoints with locale | Tests for ?locale= parameter, translation_status responses |
| RSPEC-008 | HAIKU | Run full RSpec suite | All tests pass with 100% coverage on refactored code |
| RSPEC-009 | MAIN | Update factory fixtures | Recipe factories generate normalized data structure |
| RSPEC-010 | HAIKU | Verify all ACs have corresponding tests | Every AC has at least one RSpec test |

### Phase 15: Model Spec Tests (8 HAIKU/MAIN mix)

Write comprehensive RSpec tests for all models (currently empty pending blocks)

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| MSPEC-001 | MAIN | Audit Recipe model validations | Document all 5 validate_* methods and their requirements |
| MSPEC-002 | HAIKU | Write Recipe model JSONB validation tests | Tests for servings, timing, nutrition, ingredient_groups, steps structure validation |
| MSPEC-003 | HAIKU | Write User model tests | Tests for role enum, preferred_language defaults, associations |
| MSPEC-004 | HAIKU | Write Ingredient & IngredientNutrition tests | Tests for canonical_name uniqueness, category enum, decimal precision |
| MSPEC-005 | HAIKU | Write IngredientAlias & DataReference tests | Tests for language scoping, reference_type validation, metadata JSONB |
| MSPEC-006 | HAIKU | Write UserRecipeNote & UserFavorite tests | Tests for foreign keys, uniqueness constraints, associations |
| MSPEC-007 | HAIKU | Write AiPrompt & JwtDenylist tests | Tests for prompt_type/feature_area enums, variables JSONB |
| MSPEC-008 | MAIN | Verify all model specs pass | All 10 model spec files fully implemented with 100% passing tests |

### Phase 15b: CI/CD Pipeline Enhancement (5 HAIKU/MAIN mix)

Enable automated test execution in CI pipeline

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| CI-001 | HAIKU | Add RSpec execution to GitHub Actions workflow | CI runs `bundle exec rspec` before merge |
| CI-002 | HAIKU | Configure SimpleCov code coverage reporting | Coverage reports generated, uploaded to CI artifacts |
| CI-003 | HAIKU | Add frontend build step to CI pipeline | `npm run build` succeeds in CI |
| CI-004 | HAIKU | Add frontend test step to CI pipeline | `npm run test` runs all frontend tests before merge |
| CI-005 | MAIN | Verify CI passes for all phases | Green builds required before merging any phase |

### Phase 15c: Background Job Callback Integration (4 HAIKU/MAIN mix)

Wire up GenerateStepVariantsJob and TranslateRecipeJob to auto-trigger on recipe save

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| JOB-001 | MAIN | Add after_save callback to Recipe model | Recipe triggers GenerateStepVariantsJob on create/update |
| JOB-002 | MAIN | Add translation job callback | Recipe triggers TranslateRecipeJob after variants complete |
| JOB-003 | HAIKU | Connect admin regenerate endpoints to jobs | `/admin/recipes/:id/regenerate_variants` actually enqueues job |
| JOB-004 | HAIKU | Document job triggering sequence | Variants → Translation → Nutrition (if enabled) |

### Phase 15d: Secrets Management & Security (3 HAIKU/MAIN mix)

Remove exposed API keys and implement proper secret management

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| SEC-001 | HAIKU | Create .env.example template | Template shows all required variables without secrets |
| SEC-002 | HAIKU | Add .env to .gitignore | Verify .env files not tracked in git |
| SEC-003 | MAIN | Rotate exposed API keys | ANTHROPIC_API_KEY, NUTRITIONIX keys regenerated |

### Phase 16: Frontend Test Infrastructure (15 HAIKU/MAIN mix)

Setup testing framework and write component/store/service tests

| Task ID | Agent | Description | AC |
|---------|-------|-------------|-----|
| FE-TEST-001 | MAIN | Setup Vitest + Vue Test Utils | Vitest configured, can run `npm run test` |
| FE-TEST-002 | HAIKU | Create test fixtures for Recipe types | Reusable Recipe, RecipeDetail, User test data |
| FE-TEST-003 | HAIKU | Write store unit tests | Tests for recipeStore, userStore, adminStore, uiStore getters/actions |
| FE-TEST-004 | HAIKU | Write API service tests | Tests for auth, recipe, admin, dataReference API clients |
| FE-TEST-005 | HAIKU | Write composable tests | Tests for useAuth, useBreakpoints, useDebounce, useToast |
| FE-TEST-006 | HAIKU | Write ViewRecipe component tests | Tests for rendering, i18n, scaling display |
| FE-TEST-007 | HAIKU | Write AdminRecipes component tests | Tests for list view, filtering, CRUD operations |
| FE-TEST-008 | HAIKU | Write AdminRecipeDetail component tests | Tests for detail view, editing, action buttons |
| FE-TEST-009 | HAIKU | Write RecipeForm component tests | Tests for form submission, validation, ingredient/step management |
| FE-TEST-010 | HAIKU | Write e2e test examples | Sample e2e tests for recipe view, search, scale workflows |
| FE-TEST-011 | HAIKU | Setup frontend test CI | CI runs `npm run test` on every PR |
| FE-TEST-012 | HAIKU | Generate coverage reports | Frontend coverage reports generated and visible |
| FE-TEST-013 | MAIN | Achieve 80%+ code coverage | Frontend codebase covered by automated tests |
| FE-TEST-014 | MAIN | Document frontend testing patterns | Guide for writing new component/store tests |
| FE-TEST-015 | MAIN | Update component-library.md with test examples | Each component doc includes test usage example |

---

## Part 4: Migration Strategy

### Development Approach

Since this is an MVP with test data only (no live server/users):

**1. Run Schema Migrations**
- Execute all Phase 1-9 migration files sequentially
- Create all new tables (ingredient_groups, recipe_steps, nutrition, join tables, etc.)
- Keep JSONB columns temporarily for validation

**2. Data Transformation**
- Run data migration scripts to copy JSONB data to normalized tables
- All 14 test recipes automatically transformed
- Verify counts match (1860+ steps, 420+ ingredients)

**3. Validation & Testing**
- Run full test suite (RSpec)
- Test all recipe views in admin UI
- Test all recipe views in user UI
- Verify search, filtering, scaling work
- Check i18n with all 7 languages

**4. Cleanup (when verified)**
- Drop JSONB columns from recipes table
- Final test suite run
- Done

**No complex rollback needed** - if issues found, revert git changes, drop new tables, reseed test data from git.

---

## Part 5: Development Risks & Mitigation

| Risk | Mitigation |
|------|-----------|
| Test data doesn't match after migration | Run validation scripts comparing counts, spot-check 3 recipes visually |
| Service code breaks | Comprehensive RSpec tests, gradual component updates |
| Missing Mobility configuration | Complete gem setup before Phase 11, reference existing i18n patterns |
| Step variants not generated | Test GenerateStepVariantsJob in Phase 5, verify all 3 variants for all steps |
| Translation jobs fail | Test RecipeTranslator in Phase 12 before running on all recipes |
| UI doesn't handle new schema | Frontend tests with all 7 languages, check no raw JSON displays |

---

## Part 6: Success Criteria

**Migration is successful when:**

1. ✅ All 14 recipes display correctly in admin interface
2. ✅ All 14 recipes display correctly in user interface
3. ✅ Recipe CRUD operations work (create, read, update, delete)
4. ✅ Recipe search & filtering works (by tags, cuisine, timing)
5. ✅ Recipe scaling (servings adjustment) works correctly
6. ✅ Recipe translation workflow works
7. ✅ All automated tests pass (100% of test suite)
8. ✅ Zero JSONB columns remain in recipes table
9. ✅ Database schema fully documented in `docs/database-schema.md`
10. ✅ Architecture docs updated (refs to JSONB removed)
11. ✅ No performance regressions (< 10% slowdown on critical paths)
12. ✅ Zero data loss (validated with 3+ scripts)
13. ✅ System stable for 7 consecutive days post-migration
14. ✅ API consumers report no breaking changes

---

## Questions for Approval

**I18n Architecture Decisions (CONFIRMED):**

✅ **1. Mobility Gem with Table Backend**
- Use Mobility gem (industry-standard Rails i18n)
- Table Backend: Each model gets `{model}_translations` table
- ✅ APPROVED by user

✅ **2. Translation Workflow**
- Translations happen via AI background jobs when recipe is saved
- Generate step variants (easier, no_equipment) first in source language
- Then translate ALL content to all 6 target languages
- ✅ APPROVED by user

✅ **3. API Locale Selection**
- API accepts `?locale=ja` query parameter
- Frontend passes current UI language as locale param
- ✅ APPROVED by user

✅ **4. Source Language Column**
- Rename `recipe.language` → `recipe.source_language`
- Tracks original authoring language of the recipe
- ✅ APPROVED by user

**Database Architecture Decisions (APPROVED):**

✅ **5. Ingredient Denormalization - APPROVED**
- Keep `ingredient_name` denormalized in `recipe_ingredients` table
- This allows flexibility for user-entered ingredients
- Defer normalization to future project

✅ **6. Equipment Normalization Timing - APPROVED**
- Defer equipment normalization to future project
- Keep equipment as JSONB array for now
- Focus on recipe/ingredients/steps normalization first
- Equipment can be normalized later without blocking current work

✅ **7. Downtime Window - N/A**
- Project not live yet, downtime not a concern

✅ **8. Translation Workflow - NEEDS IMPLEMENTATION**
- Existing code found and analyzed (see Translation System section)
- Refactor needed to work with new schema (see Phase 12)

✅ **9. Documentation Requirements - NEW REQUIREMENT**
- Create comprehensive `/docs/database-architecture.md`
- Document all fields, data types, units, and relationships
- Define JSONB structure for `translation_status` field
- Add reference to `/docs/new_claude/entry.md`
- Remove database architecture section from `/docs/new_claude/architecture.md`

---

## Next Steps

**Upon approval:**

1. Create this document at `docs/re-architecture-plan.md` ✅
2. Begin Phase 1 (PREP) with MAIN agent
3. Launch Haiku sub-agents on Phase 2 (SCALAR) in parallel
4. Weekly progress reviews
5. Contingency planning if issues arise

**Contingency Thresholds:**
- If any phase > 20% over estimate → reassess timeline
- If validation scripts find inconsistencies → pause and investigate
- If test failures in Phase 8 > 10% → add debugging time

---

**Document Status**: Draft awaiting review and approval
**Last Updated**: 2025-10-22
**Created By**: Architecture Planning
**For**: Recipe Database Re-Architecture Project
