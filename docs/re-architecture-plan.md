# Recipe Database Re-Architecture Plan

**Status**: In Progress
**Scope**: Database schema normalization + Mobility i18n integration
**Approach**: 9 linear phases (Backend → Frontend → Documentation)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Target Architecture](#target-architecture)
4. [Phased Implementation](#phased-implementation)
5. [Migration Strategy](#migration-strategy)
6. [Risks & Mitigation](#risks--mitigation)
7. [Success Criteria](#success-criteria)

---

## Acceptance Criteria Requirements

Each phase requires comprehensive GIVEN/WHEN/THEN acceptance criteria written BEFORE development begins:
- **Phase 1**: ACs for schema structure and normalized data relationships
- **Phase 2**: ACs for API endpoints with normalized schema
- **Phase 3**: ACs for model validations and constraints
- **Phase 4**: ACs for Mobility translation system
- **Phase 5**: ACs for translation jobs and background processing
- **Phase 6**: ACs for locale-aware API responses
- **Phase 7**: ACs for frontend integration with all 7 languages
- **Phase 8**: Documentation verification (no ACs needed)

All ACs go into `docs/new_claude/acceptance-criteria.md` in GIVEN/WHEN/THEN format.

---

## Development Workflow

**Branch Strategy:**
- Create feature branch: `git checkout -b feature/database-rearch`
- All work for this project goes in this branch

**Commit Strategy:**
- One commit per phase (after all phase work is complete and tests pass)
- Commit message: `[Phase X] <description>`
- Example: `[Phase 1] Database schema normalization and migration`

**Task Tracking Within Phases:**

**CRITICAL: Each step must be committed and approved before moving to the next step.**

1. **When starting a new phase (BEFORE development):**
   - Break the phase down into logical steps (Step 1, Step 2, Step 3, etc.)
   - Each step should be completable in one focused work session
   - Within each step, break down into atomic subtasks
   - Group related subtasks with nested bullets
   - Add steps and subtasks to the phase section with unchecked checkboxes: `- [ ] Task name`
   - **Important: Step 1 of every phase should be "Write Acceptance Criteria"**
   - Commit this documentation update with message: `[Phase X] Plan steps and subtasks`

2. **During development (STEP BY STEP):**
   - **For Step 1 (Acceptance Criteria) in every phase:**
     - Write ACs in GIVEN/WHEN/THEN format in the re-arch-ACs.md file
     - Run sub-agent with @acceptance-test-writing skill to review, identify gaps, and refine
     - Update ACs based on sub-agent recommendations
     - Commit the ACs
     - Then request approval before proceeding to Step 2
   - **For other steps:**
     - Work through all subtasks to completion
     - Mark each completed subtask: `- [x] Task name`
     - Commit the step implementation with message: `[Phase X] Step N: <description>`
     - Run a sub-agent with the code-quality-auditor skill
     - Address all issues identified by code audit
     - Commit fixes if any issues were addressed: `[Phase X] Step N: Address code quality issues`
     - Mark subtask progress in plan document
     - Commit plan update: `[Phase X] Step N: Mark complete`
     - **PAUSE AND REQUEST APPROVAL**
     - In approval request, disclose any code audit suggestions that were NOT addressed, with reasons why, and ask if those deferred items should be added to later phase documentation
   - Only after user approval, move to next step
   - This gating mechanism with quality checks ensures high-quality work and allows for informed course corrections at each step

3. **At the end of each phase (BEFORE final phase commit):**
   - Verify all steps and subtasks are marked complete: `- [x] Task name`
   - Review the phase plan and assumptions against what you actually learned
   - Evaluate whether current direction still makes sense
   - Check if any discoveries require documentation updates
   - Update this re-architecture-plan.md if needed
   - Then create final commit with message: `[Phase X] Complete: <description>`

4. **Example Phase with Steps and Subtasks:**
   ```
   ### Phase X: Example Phase

   Step 1: Write acceptance criteria
   - [ ] Define schema-related ACs
   - [ ] Define behavior-related ACs
   - [ ] Run sub-agent with acceptance-test-writing skill to review, identify gaps, and refine
   - [ ] Update ACs based on sub-agent recommendations
   - [ ] Commit ACs document

   Step 2: Implement feature A
   - [ ] Create model file
   - [ ] Add associations
   - [ ] Write tests
   - [ ] All tests passing
   - [ ] Commit implementation
   - [ ] Run code-quality-auditor sub-agent review
   - [ ] Address code quality issues
   - [ ] Request approval (disclose any skipped suggestions with reasons)

   Step 3: Implement feature B
   - [ ] Create controller
   - [ ] Add routes
   - [ ] Write integration tests
   - [ ] All tests passing
   - [ ] Commit implementation
   - [ ] Run code-quality-auditor sub-agent review
   - [ ] Address code quality issues
   - [ ] Request approval (disclose any skipped suggestions with reasons)

   Step 4: Final review
   - [ ] Review plan and assumptions
   - [ ] Evaluate direction
   - [ ] Update documentation
   - [ ] All tests passing
   - [ ] Run code-quality-auditor sub-agent review
   - [ ] Address code quality issues
   - [ ] Request approval (disclose any skipped suggestions with reasons)
   ```

---

## Executive Summary

### Problem

**Database Issues:**
- 12 JSONB fields used for recipe data (servings, timing, ingredients, steps, etc.)
- No referential integrity
- Limited queryability
- No industry-standard i18n (only steps support language variants)

**I18n Issues:**
- Recipe locked to single language
- Recipe name, ingredients, equipment not translatable
- Unused `translations` JSONB field
- No API support for locale selection

### Solution

**Part A: Normalize to relational schema**
- Convert 12 JSONB fields to proper tables and columns
- Add foreign keys and constraints
- Create join tables for many-to-many relationships

**Part B: Implement Mobility gem for i18n**
- Install Mobility (Table Backend)
- Create translation tables for all translatable fields
- API accepts `?locale=` parameter
- Auto-translate via background jobs

### Benefits

- Queryable data with proper SQL joins
- Data integrity via foreign keys
- Simpler service code (work with associations, not nested JSON)
- Complete i18n support for all recipe content
- Industry-standard patterns

---

## Current State Analysis

### JSONB Fields Audit

| Field | Type | Current Use | Target |
|-------|------|-------------|--------|
| `servings` | JSONB | `{original: 2, min: 1, max: 4}` | 3 integer columns |
| `timing` | JSONB | `{prep: 15, cook: 30, total: 45}` | 3 integer columns |
| `nutrition` | JSONB | Currently empty | `recipe_nutrition` table |
| `aliases` | JSONB array | `["alt name"]` | `recipe_aliases` table |
| `dietary_tags` | JSONB array | `["vegetarian"]` | `recipe_dietary_tags` join table |
| `dish_types` | JSONB array | `["main-course"]` | `recipe_dish_types` join table |
| `recipe_types` | JSONB array | `["quick-weeknight"]` | `recipe_recipe_types` join table |
| `cuisines` | JSONB array | `["japanese"]` | `recipe_cuisines` join table |
| `ingredient_groups` | JSONB | Nested structure | `ingredient_groups` + `recipe_ingredients` tables |
| `steps` | JSONB | Nested with i18n | `recipe_steps` + `recipe_step_translations` tables |
| `equipment` | JSONB array | `["pan", "knife"]` | `equipment` + `recipe_equipment` tables |
| `translations` | JSONB | Empty, unused | Remove, use Mobility instead |

### Services Affected

11 services depend on current JSONB structure:
1. RecipeScaler
2. RecipeTranslator
3. RecipeParserService
4. StepVariantGenerator
5. RecipeNutritionCalculator
6. RecipeSearchService
7. RecipeSerializer
8. AdminRecipesController
9. RecipeValidator
10. I18nService
11. UnitConverter

### Current I18n Situation

**Translatable:**
- Step instructions (have language variants: `instructions.en`, `instructions.ja`)
- RecipeTranslator service exists
- TranslateRecipeJob background job exists

**Not Translatable:**
- Recipe name
- Ingredient group names
- Ingredient names & preparation notes
- Equipment names
- DataReference display names (tags)
- Recipe locked to one language via `language` column

---

## Target Architecture

### Phase 1 Schema (Rails schema.rb Format)

All tables created in Phase 1 migration:

```ruby
ActiveRecord::Schema[8.0].define(version: 2025_10_23_000000) do
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # ============================================================================
  # CORE RECIPE TABLE
  # ============================================================================

  create_table "recipes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string   "name", null: false
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
    t.jsonb    "translation_status", default: {}

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["name"]], name: "index_recipes_on_name"
    t.index [["source_language"]], name: "index_recipes_on_source_language"
  end

  # ============================================================================
  # MANY-TO-MANY JOIN TABLES (was JSONB arrays)
  # ============================================================================

  create_table "recipe_dietary_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index [["recipe_id", "data_reference_id"]], name: "index_recipe_dietary_tags_unique", unique: true
  end

  create_table "recipe_dish_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index [["recipe_id", "data_reference_id"]], name: "index_recipe_dish_types_unique", unique: true
  end

  create_table "recipe_recipe_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index [["recipe_id", "data_reference_id"]], name: "index_recipe_recipe_types_unique", unique: true
  end

  create_table "recipe_cuisines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "data_reference_id", null: false
    t.datetime "created_at", null: false

    t.index [["recipe_id", "data_reference_id"]], name: "index_recipe_cuisines_unique", unique: true
  end

  create_table "recipe_aliases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.string   "alias_name", null: false
    t.string   "language"
    t.datetime "created_at", null: false

    t.index [["recipe_id"]], name: "index_recipe_aliases_on_recipe_id"
    t.index [["recipe_id", "alias_name", "language"]], name: "index_recipe_aliases_unique", unique: true
  end

  # ============================================================================
  # INGREDIENTS (was complex JSONB)
  # ============================================================================

  create_table "ingredient_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.string   "name", null: false
    t.integer  "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["recipe_id"]], name: "index_ingredient_groups_on_recipe_id"
    t.index [["recipe_id", "position"]], name: "index_ingredient_groups_on_recipe_id_and_position", unique: true
  end

  create_table "recipe_ingredients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "ingredient_group_id", null: false
    t.uuid     "ingredient_id"
    t.string   "ingredient_name", null: false
    t.decimal  "amount", precision: 10, scale: 2
    t.string   "unit"
    t.text     "preparation_notes"
    t.boolean  "optional", default: false
    t.integer  "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["ingredient_group_id"]], name: "index_recipe_ingredients_on_group_id"
    t.index [["ingredient_id"]], name: "index_recipe_ingredients_on_ingredient_id"
    t.index [["ingredient_group_id", "position"]], name: "index_recipe_ingredients_unique_position", unique: true
  end

  # ============================================================================
  # EQUIPMENT (was JSONB array)
  # ============================================================================

  create_table "equipment", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string   "canonical_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["canonical_name"]], name: "index_equipment_on_canonical_name", unique: true
  end

  create_table "recipe_equipment", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.uuid     "equipment_id", null: false
    t.boolean  "optional", default: false
    t.datetime "created_at", null: false

    t.index [["recipe_id"]], name: "index_recipe_equipment_on_recipe_id"
    t.index [["recipe_id", "equipment_id"]], name: "index_recipe_equipment_unique", unique: true
  end

  # ============================================================================
  # RECIPE STEPS (was complex JSONB)
  # ============================================================================

  create_table "recipe_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.integer  "step_number", null: false
    t.text     "instruction_original"
    t.text     "instruction_easier"
    t.text     "instruction_no_equipment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["recipe_id"]], name: "index_recipe_steps_on_recipe_id"
    t.index [["recipe_id", "step_number"]], name: "index_recipe_steps_on_recipe_id_and_step_number", unique: true
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

    t.index [["recipe_id"]], name: "index_recipe_nutrition_on_recipe_id", unique: true
  end

  # ============================================================================
  # FOREIGN KEYS (Phase 1)
  # ============================================================================

  add_foreign_key "recipe_dietary_tags", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dietary_tags", "data_references", on_delete: :cascade
  add_foreign_key "recipe_dish_types", "recipes", on_delete: :cascade
  add_foreign_key "recipe_dish_types", "data_references", on_delete: :cascade
  add_foreign_key "recipe_recipe_types", "recipes", on_delete: :cascade
  add_foreign_key "recipe_recipe_types", "data_references", on_delete: :cascade
  add_foreign_key "recipe_cuisines", "recipes", on_delete: :cascade
  add_foreign_key "recipe_cuisines", "data_references", on_delete: :cascade
  add_foreign_key "recipe_aliases", "recipes", on_delete: :cascade
  add_foreign_key "ingredient_groups", "recipes", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "ingredient_groups", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "ingredients", on_delete: :nullify
  add_foreign_key "recipe_equipment", "recipes", on_delete: :cascade
  add_foreign_key "recipe_equipment", "equipment", on_delete: :cascade
  add_foreign_key "recipe_steps", "recipes", on_delete: :cascade
  add_foreign_key "recipe_nutrition", "recipes", on_delete: :cascade
end
```

### Phase 4 Schema - Mobility Translation Tables

All translation tables created in Phase 4 migration:

```ruby
ActiveRecord::Schema[8.0].define(version: 2025_10_24_000000) do
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # ============================================================================
  # MOBILITY TRANSLATION TABLES
  # ============================================================================

  create_table "recipe_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_id", null: false
    t.string   "locale", null: false
    t.string   "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["recipe_id"]], name: "index_recipe_translations_on_recipe_id"
    t.index [["locale"]], name: "index_recipe_translations_on_locale"
    t.index [["recipe_id", "locale"]], name: "index_recipe_translations_on_recipe_id_and_locale", unique: true
  end

  create_table "ingredient_group_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "ingredient_group_id", null: false
    t.string   "locale", null: false
    t.string   "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["ingredient_group_id"]], name: "index_ingredient_group_translations_on_group_id"
    t.index [["locale"]], name: "index_ingredient_group_translations_on_locale"
    t.index [["ingredient_group_id", "locale"]], name: "index_ingredient_group_translations_unique", unique: true
  end

  create_table "recipe_ingredient_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_ingredient_id", null: false
    t.string   "locale", null: false
    t.string   "ingredient_name", null: false
    t.text     "preparation_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["recipe_ingredient_id"]], name: "index_recipe_ingredient_translations_on_ingredient_id"
    t.index [["locale"]], name: "index_recipe_ingredient_translations_on_locale"
    t.index [["recipe_ingredient_id", "locale"]], name: "index_recipe_ingredient_translations_unique", unique: true
  end

  create_table "equipment_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "equipment_id", null: false
    t.string   "locale", null: false
    t.string   "canonical_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["equipment_id"]], name: "index_equipment_translations_on_equipment_id"
    t.index [["locale"]], name: "index_equipment_translations_on_locale"
    t.index [["equipment_id", "locale"]], name: "index_equipment_translations_unique", unique: true
  end

  create_table "recipe_step_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "recipe_step_id", null: false
    t.string   "locale", null: false
    t.text     "instruction_original"
    t.text     "instruction_easier"
    t.text     "instruction_no_equipment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["recipe_step_id"]], name: "index_recipe_step_translations_on_step_id"
    t.index [["locale"]], name: "index_recipe_step_translations_on_locale"
    t.index [["recipe_step_id", "locale"]], name: "index_recipe_step_translations_unique", unique: true
  end

  create_table "data_reference_translations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "data_reference_id", null: false
    t.string   "locale", null: false
    t.string   "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.index [["data_reference_id"]], name: "index_data_reference_translations_on_reference_id"
    t.index [["locale"]], name: "index_data_reference_translations_on_locale"
    t.index [["data_reference_id", "locale"]], name: "index_data_reference_translations_unique", unique: true
  end

  # ============================================================================
  # FOREIGN KEYS (Phase 4)
  # ============================================================================

  add_foreign_key "recipe_translations", "recipes", on_delete: :cascade
  add_foreign_key "ingredient_group_translations", "ingredient_groups", on_delete: :cascade
  add_foreign_key "recipe_ingredient_translations", "recipe_ingredients", on_delete: :cascade
  add_foreign_key "equipment_translations", "equipment", on_delete: :cascade
  add_foreign_key "recipe_step_translations", "recipe_steps", on_delete: :cascade
  add_foreign_key "data_reference_translations", "data_references", on_delete: :cascade
end
```

### Model Declarations

Phase 1 and Phase 4 model updates:

**Phase 1 Models:**

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  has_many :ingredient_groups, dependent: :destroy
  has_many :recipe_ingredients, through: :ingredient_groups
  has_many :recipe_steps, -> { order(:step_number) }, dependent: :destroy
  has_one :recipe_nutrition, dependent: :destroy
  has_many :recipe_equipment, dependent: :destroy
  has_many :equipment, through: :recipe_equipment
  has_many :recipe_dietary_tags, dependent: :destroy
  has_many :dietary_tags, through: :recipe_dietary_tags, source: :data_reference
end

# app/models/ingredient_group.rb
class IngredientGroup < ApplicationRecord
  belongs_to :recipe
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy
end

# app/models/recipe_ingredient.rb
class RecipeIngredient < ApplicationRecord
  belongs_to :ingredient_group
  belongs_to :ingredient, optional: true
end

# app/models/recipe_step.rb
class RecipeStep < ApplicationRecord
  belongs_to :recipe
end

# app/models/equipment.rb
class Equipment < ApplicationRecord
  has_many :recipe_equipment
  has_many :recipes, through: :recipe_equipment
end
```

**Phase 4 Model Updates (add Mobility translates declarations):**

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

  # ... associations ...
end

# app/models/ingredient_group.rb
class IngredientGroup < ApplicationRecord
  extend Mobility
  translates :name, backend: :table

  # ... associations ...
end

# app/models/recipe_ingredient.rb
class RecipeIngredient < ApplicationRecord
  extend Mobility
  translates :ingredient_name, :preparation_notes, backend: :table

  # ... associations ...
end

# app/models/recipe_step.rb
class RecipeStep < ApplicationRecord
  extend Mobility
  translates :instruction_original, :instruction_easier, :instruction_no_equipment, backend: :table

  # ... associations ...
end

# app/models/equipment.rb
class Equipment < ApplicationRecord
  extend Mobility
  translates :canonical_name, backend: :table

  # ... associations ...
end

# app/models/data_reference.rb
class DataReference < ApplicationRecord
  extend Mobility
  translates :display_name, backend: :table
end
```

---

## Phased Implementation

### Phase 1: Giant Database Migration

**Step 1: Acceptance Criteria**
- [x] Write Phase 1 ACs in GIVEN/WHEN/THEN format
- [x] Run sub-agent with acceptance-test-writing skill to review, identify gaps, and refine
- [x] Update ACs based on sub-agent recommendations
- [x] Commit: `[Phase 1 ACs] Add schema normalization acceptance criteria`

**Step 2: Schema Migration**
- [x] Create migration file: 20251023000001_normalize_recipes_schema.rb
- [x] Review migration against Phase 1 ACs
- [x] Commit: `[Phase 1] Add database schema normalization migration`

**Step 3: Create Model Files**
- [x] Create 4 initial models (IngredientGroup, RecipeIngredient, RecipeStep, Equipment)
- [x] Commit: `[Phase 1] Create initial model files with associations`
- [x] Create 7 remaining models:
  - [x] RecipeNutrition
  - [x] RecipeDietaryTag
  - [x] RecipeDishType
  - [x] RecipeRecipeType
  - [x] RecipeCuisine
  - [x] RecipeAlias
  - [x] RecipeEquipment
- [x] Commit: `[Phase 1] Create remaining 7 model files with associations`
- [x] Run code-quality-auditor sub-agent review
- [x] Address Step 3-specific issues:
  - [x] Equipment: added dependent: :destroy
  - [x] Join tables: added uniqueness validations
  - [x] Ordering models: added default_scope for position/step_number
- [x] Commit: `[Phase 1] Step 3: Address code quality audit findings`
- [x] Mark Step 3 complete

**Step 4: Update Recipe Model**
- [x] Remove JSONB field validations
- [x] Add all 17 associations (ingredient_groups, recipe_steps, equipment, dietary_tags, dish_types, cuisines, recipe_types, etc.)
- [x] Verify all associations match Phase 1 ACs (AC-PHASE1-015)
- [x] Commit Recipe model updates: `[Phase 1] Step 4: Update Recipe model with normalized associations`
- [x] Run code-quality-auditor sub-agent review
- [x] Address code audit issues:
  - [x] Added missing through: associations (dish_types, cuisines, recipe_types)
  - [x] Removed redundant ordering from recipe_steps
  - [x] Added inverse associations to DataReference model
- [x] Commit fixes: `[Phase 1] Step 4: Fix code audit issues in Recipe and DataReference models`
- [x] Mark Step 4 complete

**Step 5: Run Migration and Seeds**
- [x] Run `rails db:migrate` to apply all Phase 1 schema changes
- [x] Verify migration completes without errors
- [x] Update db/seeds.rb with test recipes for new schema
- [x] **CRITICAL: ALL fields covered to test every field works**
  - [x] All servings variations (servings_original, servings_min, servings_max)
  - [x] All timing fields (prep_minutes, cook_minutes, total_minutes)
  - [x] All ingredient group variations (single group, multiple groups)
  - [x] All recipe ingredient fields (amount, unit, preparation_notes, optional flag)
  - [x] All recipe step fields (step_number)
  - [x] All equipment variations (required and optional)
  - [x] All reference data associations (dietary_tags, dish_types, cuisines, recipe_types)
  - [x] All recipe aliases with multiple languages
  - [x] All nutrition fields
  - [x] Null/missing values to test optional fields
- [x] 14 test recipes with comprehensive coverage
- [x] Fixed servings (Recipe 1: 2) and variable servings (Recipes 2-14: min < max)
- [x] Run `rails db:seed` to populate test data
- [x] Verified no errors and data integrity
- [x] Commit: `[Phase 1] Step 5: Address code audit findings in migration and seeds`
- [x] Run code quality audit with sub-agent (identified 6 HIGH, 11 MEDIUM, 9 LOW severity issues)
- [x] Address all HIGH severity issues:
  - [x] H-1: Rename recipe_ingredients.name to ingredient_name
  - [x] H-2: Add foreign key constraint (ingredient_nutrition)
  - [x] H-3: Add foreign key constraint (ingredient_aliases)
  - [x] H-4: Add comprehensive field coverage (14 recipes, all fields tested)
  - [x] H-5: Update seeds to use correct column names
  - [x] H-6: Add edge case coverage (NULL values, constraints)
- [x] Address key MEDIUM severity issues:
  - [x] M-1: Correct decimal precision (8 → 10)
  - [x] M-2, M-3: Add category indexes
  - [x] M-4: Fix position column (remove default, add NOT NULL)
- [x] Address selected LOW severity issues for improved quality:
  - [x] L-1: Confirmed locale indexes already present in migration
  - [x] L-5: Explicit step creation (replaced hardcoded timing arrays)
  - [x] L-6: Realistic ingredient names (replaced "ingredient 1" placeholders)
  - [x] L-7: Nutrition data for all 14 recipes (was missing for 9)
  - [x] L-9: Admin notes on all recipes (was only on Recipe 1)

**Step 6: Write RSpec Tests**
- [x] Write test suite covering Phase 1 ACs (50 tests covering validations, associations, normalized schema)
- [x] All tests passing (50/50 pass, 0 failures)
- [x] Add inverse associations to Ingredient and DataReference models
- [x] Run code quality audit: **38 total issues identified**
  - [x] Address all HIGH severity issues (8 issues: H-1 through H-8)
    - H-1: Fixed ambiguous `recipes` association → `recipes_as_dietary_tag`
    - H-2 through H-4: Added validations to IngredientGroup, RecipeIngredient, Equipment
    - H-5: Fixed cascade deletion test
    - H-6, H-7: Removed dangerous default_scope usage
    - H-8: Fixed hardcoded count assertions
  - [x] Address key MEDIUM severity issues (3 of 15 addressed: M-1, M-2, M-15)
    - M-1, M-2: Extracted duplicated test code patterns with helper methods
    - M-15: Added presence validations to all join table models
- [x] Commit: `[Phase 1] Step 6: Add RSpec tests for schema normalization`
- [x] Commit: `[Phase 1] Step 6: Address code quality audit findings`

**Step 7: Final Review**
- [x] Review plan against actual discoveries
  - ✅ All Phase 1 ACs implemented and tested (50 tests, 100% passing)
  - ✅ Code quality audit completed (11 issues fixed)
  - ✅ Discovered timing_minutes unnecessary → removed as simplification
  - ✅ 27 deferred code quality items documented for Phase 2-3
  - ✅ M-3, M-4 formally added to Phase 2 action items
- [x] Evaluate direction and assumptions
  - ✅ Schema normalization approach is sound
  - ✅ Relational structure enables Phase 2 APIs
  - ✅ Mobility i18n path remains viable for Phase 4+
  - ✅ No blockers identified for proceeding to Phase 2
- [x] Update documentation if needed
  - ✅ Removed timing_minutes from line 682 (step fields list)
  - ✅ Documented timing_minutes removal decision
  - ✅ Code quality audit findings documented
- [x] Final commit: `[Phase 1] Step 7: Complete - Database schema normalization`

---

### Phase 2: Fix Existing Backend Specs

**Step 1: Write Acceptance Criteria**
- [x] Define ACs for API endpoints with normalized schema (GIVEN/WHEN/THEN format)
- [x] Define ACs for serializers handling relational data
- [x] Define ACs for services using associations instead of JSONB
- [x] Run sub-agent with acceptance-test-writing skill to review, identify gaps, and refine
  - Identified gaps: null/empty handling, error scenarios, performance, search/filtering
  - Added 12 new ACs to address gaps
- [x] Update ACs based on sub-agent recommendations
  - Added 4 ACs for serializer null/empty handling (AC-PHASE2-SERIALIZER-001B, -002B, -008, -009, -010, -011)
  - Refactored 6 service ACs to focus on behavior vs implementation details
  - Refactored 3 model ACs to test cascading behavior and ordering
  - Added 5 error handling ACs (API errors, constraint violations)
  - Added 4 performance/optimization ACs (eager loading, ordering, efficiency)
  - Added 4 search/filtering ACs (join table queries, multi-tag logic)
- [x] Commit ACs document: `[Phase 2] Step 1: Write Phase 2 Acceptance Criteria - 40 ACs covering API, serializers, services, error handling, performance`
- [ ] Request approval

**Step 2: Deep Discovery & Analysis**
- [x] Run full bundle exec rspec suite and document all failures by category
  - Found 44+ total failures
  - Categorized: 19 API endpoint failures, 12 service failures, 13 job failures, 10 controller failures
- [x] Cross-reference with acceptance-criteria.md:
  - [x] Identified which ACs depend on JSONB structure (AC-SCALE, AC-ADMIN, AC-VIEW, AC-SEARCH families)
  - [x] Mapped ACs to affected components (RecipeSerializer, RecipeScaler, RecipeSearchService, etc.)
  - [x] Documented functional requirements that must be preserved (backward-compatible API responses)
- [x] Cross-reference with api-reference.md:
  - [x] Documented current API response formats (all 9 endpoints return JSONB structure)
  - [x] Identified all endpoints returning recipe data (GET/POST/PUT/DELETE + parse endpoints)
  - [x] Mapped JSONB fields to new normalized schema (5 Tier 1-3 files require updates)
  - [x] Documented transformation logic needed for each endpoint (serializers must rebuild JSONB hashes)
- [x] Analyze transformation requirements:
  - [x] RecipeSerializer must rebuild JSONB-like responses from normalized data (11 serializer ACs)
  - [x] Services need to query associations instead of JSONB (6 service ACs, specific line numbers documented)
  - [x] Controller logic changes needed (strong params, eager loading, nested attributes)
  - [x] Identified shared transformation patterns (hash building, association joins)
- [x] Create "Phase 2 Reference: Transformation Requirements" section in re-architecture-plan.md documenting:
  - [x] Failure categories and affected endpoints (19 API failures analyzed with line numbers)
  - [x] AC-to-component mapping (40 Phase 2 ACs mapped to 11 files requiring changes)
  - [x] JSONB-to-relational schema transformations (detailed matrix with 10 field transformations)
  - [x] Serializer rebuild logic needed (hash construction from 3 columns, association serialization)
  - [x] Service updates required (association queries instead of JSONB operators, nested_attributes)
  - [x] Tier 1-2-3 file dependencies (11 files with change priorities)
- [x] Define specific Steps 3-5 based on findings:
  - [x] Step 3: Fix Serializers (RecipeSerializer, eager loading, backward-compatible response format)
  - [x] Step 4: Fix Services (RecipeScaler, RecipeSearchService, RecipeParser, Translator, StepVariantGenerator)
  - [x] Step 5: Fix Controllers (strong params, nested attributes, eager loading)
- [x] Commit assessment document + updated plan with reference section: `[Phase 2] Step 2: Deep discovery complete...`
- [ ] Request approval

---

## Phase 2 Reference: Transformation Requirements

### Critical Discovery: Schema Migration Complete, Code Not Updated

Phase 1 successfully migrated the database schema to normalized structure:
- ✅ `servings_original`, `servings_min`, `servings_max` (integer columns, not JSONB)
- ✅ `prep_minutes`, `cook_minutes`, `total_minutes` (integer columns, not JSONB)
- ✅ `ingredient_groups`, `recipe_ingredients`, `recipe_steps` (relational tables)
- ✅ `equipment`, `recipe_equipment` (join tables)
- ✅ `recipe_dietary_tags`, `recipe_dish_types`, `recipe_cuisines`, `recipe_recipe_types` (join tables)

**BUT: All code still accesses JSONB fields that no longer exist.**

### Test Failure Summary

**Total Failures: 44+ (includes 25+ request/API endpoint failures)**

**Failure Categories:**

1. **API Endpoint Failures (19 critical)**
   - GET /api/v1/recipes (list) - FAILED (returns JSONB field access errors)
   - GET /api/v1/recipes/:id (show) - FAILED
   - POST /api/v1/recipes/:id/scale - FAILED (RecipeScaler tries to access recipe.servings['original'])
   - POST /api/v1/recipes/:id/translate - FAILED
   - POST /api/v1/recipes/:id/generate_step_variants - FAILED
   - All admin endpoints for create/update/delete - FAILED
   - All parse endpoints (text/url/image) - FAILED

2. **Service Failures (12 critical)**
   - RecipeScaler: Line 17 `@recipe.servings['original']` (field doesn't exist)
   - RecipeSearchService: Lines 162, 170, 178 use SQL JSONB operators on removed fields
   - RecipeTranslator: Expects JSONB ingredient_groups, steps, equipment
   - StepVariantGenerator: Expects JSONB steps
   - RecipeParser: Creates data structure for non-existent JSONB fields
   - RecipeNutritionCalculator: Accesses ingredient_groups JSONB array

3. **Job Failures (13)**
   - GenerateStepVariantsJob: 9 failures (variants_generated, step iteration, multiple steps)
   - NutritionLookupJob: 2 failures
   - TranslateRecipeJob: 2 failures

4. **Controller Failures (10)**
   - Api::V1::RecipesController: Multiple endpoints try to access non-existent JSONB fields
   - Admin::RecipesController: Create/update with strong params for non-existent fields
   - Admin::AiPrompts, Admin::DataReferences: 8 failures

### Component-to-AC Mapping & Required Changes

#### RecipeSerializer (backend/app/serializers/recipe_serializer.rb)

**Current Code**:
```ruby
attributes :id, :title, :description, :servings, :prep_time, :cook_time,
           :total_time, :difficulty, :cuisine, :dietary_tags,
           :ingredient_groups, :steps, :notes, :source_url
```

**Issue**: Tries to access `servings` as JSONB, but now it's split across 3 columns

**Required Changes**:
- `servings` → build hash from `servings_original`, `servings_min`, `servings_max` columns
- `ingredient_groups` → serialize `recipe.ingredient_groups` association (eager loaded)
- `steps` → serialize `recipe.recipe_steps` association
- `dietary_tags`, etc. → serialize join table associations

**Related ACs**: AC-PHASE2-SERIALIZER-001 through -011, AC-PHASE2-BACKWARD-COMPAT-001 through -003

#### RecipeScaler (backend/app/services/recipe_scaler.rb)

**Current JSONB Access** (Lines 17, 40, 42, 48, 154, 158):
```ruby
line 17: scaling_factor = target_servings.to_f / @recipe.servings['original']
line 40: scaled_recipe.ingredient_groups = deep_dup_jsonb(@recipe.ingredient_groups)
line 158: @recipe.ingredient_groups.each do |group|
line 154: recipe.recipe_types.any? { |type| precision_types.include?(type) }
```

**Required Changes**:
- Replace `@recipe.servings['original']` with `@recipe.servings_original` (integer column)
- Replace `@recipe.ingredient_groups` with `@recipe.ingredient_groups.includes(:recipe_ingredients)` (association)
- Iterate `ingredient_groups` association and scale nested `recipe_ingredients` amounts
- Replace `recipe.recipe_types` JSONB access with `recipe.recipe_types.pluck(:key)` (join table)

**Related ACs**: AC-PHASE2-SERVICE-001, AC-PHASE2-SERVICE-002, AC-PHASE2-PERF-001

#### RecipeSearchService (backend/app/services/recipe_search_service.rb)

**Current JSONB Queries** (Lines 32-35, 44-49, 73-105, 108-115, 122-130, 134-142, 146-154):
```ruby
line 32-35: SELECT 1 FROM jsonb_array_elements_text(aliases)  # aliases no longer JSONB
line 44-49: SELECT FROM jsonb_array_elements(ingredient_groups) # now relational
line 73-105: nutrition->'per_serving'->>'calories' # JSONB operators
line 108-115: dietary_tags @> ? # JSONB containment
line 122-130: cuisines @> ? # JSONB containment
```

**Required Changes**:
- Replace JSONB array filtering with association joins
- `dietary_tags @> ?` → `joins(:dietary_tags).where(recipe_dietary_tags: { data_reference_id: tag_ids })`
- `cuisines @> ?` → `joins(:cuisines).where(recipe_cuisines: { data_reference_id: cuisine_ids })`
- Ingredient name search → `joins(ingredient_groups: :recipe_ingredients).where(recipe_ingredients: { ingredient_name: ... })`
- Nutrition filtering → `joins(:recipe_nutrition).where(recipe_nutrition: { calories: ... })`

**Related ACs**: AC-PHASE2-SEARCH-001 through -004, AC-PHASE2-PERF-001

#### RecipeParserService (backend/app/services/recipe_parser_service.rb)

**Current Behavior** (Lines 181, 189-193):
```ruby
Returns: {
  title: ...,
  servings: { original: 4, min: 2, max: 8 },
  ingredient_groups: [...],
  steps: [...],
  equipment: [...]
}
```

**Issue**: Returns JSONB-formatted hash for non-existent JSONB columns

**Required Changes**:
- Change return to create normalized record structure:
  ```ruby
  {
    title: ...,
    servings_original: 4,
    servings_min: 2,
    servings_max: 8,
    prep_minutes: 15,
    cook_minutes: 30,
    total_minutes: 45,
    ingredient_groups_attributes: [...],
    recipe_steps_attributes: [...],
    equipment_attributes: [...]
  }
  ```
- Use nested_attributes to create associated records in single transaction

**Related ACs**: AC-PHASE2-SERVICE-003

#### RecipeTranslator (backend/app/services/recipe_translator.rb)

**Current JSONB Access** (Lines 6-8, 20-30):
```ruby
ingredient_groups: translate_ingredient_groups(recipe.ingredient_groups, target_language),
steps: translate_steps(recipe.steps, target_language),
equipment: translate_equipment(recipe.equipment, target_language)
```

**Required Changes**:
- Query associations: `recipe.ingredient_groups.includes(:recipe_ingredients)`
- Translate ingredient names via `recipe.recipe_ingredients`
- Translate step instructions via `recipe.recipe_steps`
- Use Mobility gem or translation table for multi-language support (Phase 4)
- For Phase 2: Store translated data in `recipe_step_translations` table

**Related ACs**: AC-PHASE2-SERVICE-006

#### StepVariantGenerator (backend/app/services/step_variant_generator.rb)

**Current JSONB Access** (Line 54):
```ruby
recipe.ingredient_groups.flat_map do |group|
```

**Required Changes**:
- Replace with: `recipe.ingredient_groups.includes(:recipe_ingredients).flat_map`
- Iterate `recipe_ingredients` within each group
- Generate variants via Anthropic API (unchanged logic)
- Store variants in `recipe_steps.instruction_easier` and `instruction_no_equipment` columns

**Related ACs**: AC-PHASE2-SERVICE-004

#### Controllers (Api::V1::RecipesController, Admin::RecipesController)

**Current Issues**:

**Api::V1::RecipesController** (Lines 69, 160-190):
```ruby
def scale
  scaled_ingredient_groups = recipe.ingredient_groups.map do |group|
    # Accesses JSONB array directly
  end
end

def index
  render json: RecipeListSerializer.new(@recipes).serializable_hash
  # Serializer tries to return JSONB fields
end
```

**Admin::RecipesController** (Lines 325-378):
```ruby
def recipe_params
  params.require(:recipe).permit(
    :servings,      # Should be :servings_original, :servings_min, :servings_max
    :timing,        # Should be :prep_minutes, :cook_minutes, :total_minutes
    :ingredient_groups,
    :steps
  )
end

def create
  @recipe = Recipe.new(recipe_params)
  # Tries to assign JSONB hashes to non-existent JSONB columns
end
```

**Required Changes**:
- Update strong params to use normalized column names
- Use nested_attributes for associated records
- Ensure eager loading of associations in queries
- Update serializers to rebuild JSONB-compatible response format

**Related ACs**: AC-PHASE2-CONTROLLER-001 through -003, AC-PHASE2-BACKWARD-COMPAT-001 through -003

### JSONB-to-Relational Transformation Matrix

| JSONB Field | Current Code Access | Old Structure | New Column(s) | New Association | Transformation Logic |
|-------------|-------------------|---------------|----------------|-----------------|----------------------|
| servings | `recipe.servings['original']` | `{original: 4, min: 2, max: 8}` | `servings_original`, `servings_min`, `servings_max` (int) | None | Build hash in serializer from 3 columns |
| timing | `timing->>'prep_minutes'` | `{prep_minutes: 15, cook_minutes: 30, total_minutes: 45}` | `prep_minutes`, `cook_minutes`, `total_minutes` (int) | None | Build hash in serializer from 3 columns |
| ingredient_groups | `recipe.ingredient_groups` | Array of hashes | `ingredient_groups` table | `has_many :ingredient_groups` | Serialize association + nested items |
| recipe_ingredients | Nested in ingredient_groups | `{quantity, unit, item, notes}` | `recipe_ingredients` table | `has_many :recipe_ingredients through: :ingredient_groups` | Serialize through parent |
| steps | `recipe.steps` | Array of hashes | `recipe_steps` table | `has_many :recipe_steps` | Serialize with instruction variants |
| equipment | `recipe.equipment` | Array of strings | `equipment` + `recipe_equipment` tables | `has_many :equipment through: :recipe_equipment` | Serialize through join table |
| dietary_tags | `dietary_tags @> ?` | `["vegetarian"]` | `recipe_dietary_tags` join table | `has_many :dietary_tags through: :recipe_dietary_tags` | Join query, serialize display_name array |
| dish_types | `dish_types @> ?` | `["main-course"]` | `recipe_dish_types` join table | `has_many :dish_types through: :recipe_dish_types` | Join query, serialize display_name array |
| cuisines | `cuisines @> ?` | `["italian"]` | `recipe_cuisines` join table | `has_many :cuisines through: :recipe_cuisines` | Join query, serialize display_name array |
| recipe_types | `recipe.recipe_types` | `["quick-weeknight"]` | `recipe_recipe_types` join table | `has_many :recipe_types through: :recipe_recipe_types` | Join query, serialize display_name array |

### Critical Files Requiring Changes

**Tier 1: Immediate/Blocking** (must fix to pass tests)
1. `backend/app/serializers/recipe_serializer.rb` - Rebuild JSONB-compatible response
2. `backend/app/services/recipe_scaler.rb` - Query associations instead of JSONB
3. `backend/app/services/recipe_search_service.rb` - Join-based queries instead of JSONB operators
4. `backend/app/controllers/api/v1/recipes_controller.rb` - Ensure eager loading, scale endpoint
5. `backend/app/controllers/admin/recipes_controller.rb` - Update strong params, create with associations

**Tier 2: Secondary** (used by Tier 1)
6. `backend/app/services/recipe_parser_service.rb` - Return normalized structure
7. `backend/app/services/recipe_translator.rb` - Work with associations
8. `backend/app/services/step_variant_generator.rb` - Work with recipe_steps association
9. `backend/app/jobs/generate_step_variants_job.rb` - Depends on step_variant_generator

**Tier 3: Tertiary** (dependent on Tier 1-2)
10. `backend/spec/**/*` - Update factories, specs for normalized structure
11. `backend/app/models/recipe.rb` - Verify associations

---

**Step 3: Fix Serializers & Core API Response Transformation** ✅ COMPLETE

Goal: Make all API endpoints return correct JSONB-compatible responses despite using normalized schema

Subtasks:
- [x] Update RecipeSerializer:
  - [x] Build `servings` hash from 3 columns (servings_original, servings_min, servings_max)
  - [x] Build `timing` hash from 3 columns (prep_minutes, cook_minutes, total_minutes)
  - [x] Serialize `ingredient_groups` association with nested `recipe_ingredients`
  - [x] Serialize `recipe_steps` association with instruction variants
  - [x] Serialize `equipment` through join table
  - [x] Serialize tag associations as arrays (dietary_tags, dish_types, cuisines, recipe_types)
  - [x] Handle null/empty collections consistently
- [x] Create RecipeStepTranslation model for nested instruction serialization
- [x] Update Api::V1::RecipesController to eager-load all associations
- [x] Verify GET /api/v1/recipes returns correct format
- [x] Verify GET /api/v1/recipes/:id returns correct format
- [x] Update admin response serializer similarly
- [x] All serializer tests passing (23/23 tests)
- [x] Commit: `[Phase 2] Step 3: Fix serializers to rebuild JSONB-compatible responses`
- [x] Run code audit and address issues
- [x] Request approval ⏳ APPROVAL REQUESTED

**Step 4: Fix Services (RecipeScaler, RecipeParser, RecipeSearchService)**

Goal: Update all services to query normalized schema instead of JSONB

**Subtask A: Update RecipeScaler (backend/app/services/recipe_scaler.rb)**
- [ ] A1: Fix scale_by_servings method
  - [ ] Line 17: Replace `@recipe.servings['original']` with `@recipe.servings_original`
  - [ ] Update return value to use normalized structure
- [ ] A2: Fix scale_all_ingredients method
  - [ ] Line 40: Remove `deep_dup_jsonb` - no longer needed
  - [ ] Lines 42-46: Replace JSONB iteration with association query
  - [ ] Use: `ingredient_group.recipe_ingredients.each do |ingredient|`
  - [ ] Line 48: Replace `scaled_recipe.servings['original']` with `@recipe.servings_original`
  - [ ] Update response structure to include scaled servings value
- [ ] A3: Fix detect_cooking_context method
  - [ ] Line 154: Replace `recipe.recipe_types.any? { |type| ... }` JSONB check with join query
  - [ ] Use: `recipe.recipe_types.joins(:data_reference).where(data_references: { key: precision_types }).exists?`
- [ ] A4: Fix find_ingredient_by_id method
  - [ ] Lines 157-163: Replace JSONB search with association query
  - [ ] Use: `recipe.recipe_ingredients.find_by(id: ingredient_id)`
- [ ] A5: Remove or update deep_dup_jsonb method (no longer needed)
- [ ] A6: Test scaling with normalized data
  - [ ] Verify AC-PHASE2-SERVICE-001: Scales with correct amounts
  - [ ] Verify AC-PHASE2-SERVICE-002: Returns serializable format

**Subtask B: Update RecipeSearchService (backend/app/services/recipe_search_service.rb)**
- [ ] B1: Fix search_by_alias method (lines 26-36)
  - [ ] Replace JSONB query: `jsonb_array_elements_text(aliases)`
  - [ ] Use: `Recipe.joins(:recipe_aliases).where("LOWER(recipe_aliases.alias_name) LIKE ?", ...)`
  - [ ] Test with alias search
- [ ] B2: Fix search_by_ingredient method (lines 38-50)
  - [ ] Replace JSONB query: `jsonb_array_elements(ingredient_groups)`
  - [ ] Use: `Recipe.joins(ingredient_groups: :recipe_ingredients).where(...)`
  - [ ] Test ingredient name search
- [ ] B3: Fix nutrition filter methods (lines 69-194)
  - [ ] Lines 69-81: Replace `nutrition->'per_serving'->>'calories'` with join to recipe_nutrition.calories
  - [ ] Lines 84-89: Replace `nutrition->'per_serving'->>'protein_g'` with recipe_nutrition.protein_g
  - [ ] Lines 92-97: Replace `nutrition->'per_serving'->>'carbs_g'` with recipe_nutrition.carbs_g
  - [ ] Lines 100-105: Replace `nutrition->'per_serving'->>'fat_g'` with recipe_nutrition.fat_g
- [ ] B4: Fix dietary tag filter method (lines 108-119)
  - [ ] Replace JSONB containment: `dietary_tags @> ?`
  - [ ] Use: `joins(:dietary_tags).where(data_references: { key: tags }).group('recipes.id').having('COUNT(*) = ?', tags.size)`
  - [ ] Test AND logic for multiple tags
- [ ] B5: Fix cuisine filter method (lines 122-131)
  - [ ] Replace JSONB containment: `cuisines @> ?`
  - [ ] Use: `joins(:cuisines).where(data_references: { key: cuisines })`
  - [ ] Test OR logic for multiple cuisines
- [ ] B6: Fix dish type filter method (lines 134-143)
  - [ ] Replace JSONB containment: `dish_types @> ?`
  - [ ] Use: `joins(:dish_types).where(data_references: { key: dish_types })`
- [ ] B7: Fix recipe type filter method (lines 146-155)
  - [ ] Replace JSONB containment: `recipe_types @> ?`
  - [ ] Use: `joins(:recipe_types).where(data_references: { key: recipe_types })`
- [ ] B8: Fix timing filter methods (lines 158-179)
  - [ ] Line 162: Replace `timing->>'prep_minutes'` with `prep_minutes` column
  - [ ] Line 170: Replace `timing->>'cook_minutes'` with `cook_minutes` column
  - [ ] Line 178: Replace `timing->>'total_minutes'` with `total_minutes` column
- [ ] B9: Fix serving filter method (lines 182-194)
  - [ ] Line 186: Replace `servings->>'original'` with `servings_original` column
  - [ ] Line 190: Replace `servings->>'original'` with `servings_original` column
- [ ] B10: Fix exclude_ingredients method (lines 197-213)
  - [ ] Replace JSONB negation query with association NOT EXISTS
  - [ ] Test allergen filtering
- [ ] B11: Test all search/filter methods
  - [ ] Verify AC-PHASE2-SEARCH-001: Filter by dietary tag
  - [ ] Verify AC-PHASE2-SEARCH-002: Filter by multiple cuisines (OR)
  - [ ] Verify AC-PHASE2-SEARCH-003: Filter by dish type
  - [ ] Verify AC-PHASE2-SEARCH-004: Combine search with filters

**Subtask C: Update RecipeParserService (backend/app/services/recipe_parser_service.rb)**
- [ ] C1: Update validate_recipe_structure method (lines 180-209)
  - [ ] Change expected field names from `servings` to `servings_original, servings_min, servings_max`
  - [ ] Change expected field names from `timing` to `prep_minutes, cook_minutes, total_minutes`
  - [ ] Update ingredient_groups validation to accept flat structure
  - [ ] Update steps validation to accept flat structure
- [ ] C2: Update parse_response method to transform output
  - [ ] After parsing JSON from Claude, transform to normalized format
  - [ ] Create helper method to convert JSONB-like structure to nested_attributes format
  - [ ] Test AC-PHASE2-SERVICE-003: Creates normalized records

**Subtask D: Update RecipeTranslator (backend/app/services/recipe_translator.rb)**
- [ ] D1: Update translate_recipe method (lines 11-30)
  - [ ] Remove: `recipe.to_json` (JSONB structure)
  - [ ] Add: Manual serialization using associations
  - [ ] Query: `recipe.ingredient_groups.includes(:recipe_ingredients)`
  - [ ] Query: `recipe.recipe_steps`
  - [ ] Query: `recipe.equipment`
  - [ ] Build JSON structure from associations
- [ ] D2: Test translation with normalized data
  - [ ] Verify AC-PHASE2-SERVICE-006: Translates normalized steps

**Subtask E: Update StepVariantGenerator (backend/app/services/step_variant_generator.rb)**
- [ ] E1: Fix extract_step_ingredients method (lines 49-59)
  - [ ] Line 54: Replace `recipe.ingredient_groups` (JSONB) with association query
  - [ ] Use: `recipe.ingredient_groups.includes(:recipe_ingredients)`
  - [ ] Line 55: Replace `group['items']` with `group.recipe_ingredients`
  - [ ] Line 56: Replace `ing['name']` with `ing.ingredient_name` (ActiveRecord attribute)
  - [ ] Line 57: Build display string from model attributes
- [ ] E2: Fix generate_easier_variant method (lines 2-24)
  - [ ] Line 8: Replace `recipe.cuisines.join(', ')` with `recipe.cuisines.map(&:display_name).join(', ')`
  - [ ] Line 9: Replace `recipe.recipe_types.join(', ')` with `recipe.recipe_types.map(&:display_name).join(', ')`
  - [ ] Update step parameter handling (change from JSONB hash to RecipeStep model)
  - [ ] Lines 10-14: Use RecipeStep attributes instead of JSONB hash access
- [ ] E3: Fix generate_no_equipment_variant method (lines 26-45)
  - [ ] Update step parameter to accept RecipeStep model
  - [ ] Replace hash field access with model attributes
  - [ ] Test variant generation with normalized steps
- [ ] E4: Test step variant generation
  - [ ] Verify AC-PHASE2-SERVICE-004: Generates variants for normalized steps

**Subtask F: Integration Testing & Quality**
- [ ] F1: Run individual service tests
  - [ ] `bundle exec rspec spec/services/recipe_scaler_spec.rb`
  - [ ] `bundle exec rspec spec/services/recipe_search_service_spec.rb`
  - [ ] `bundle exec rspec spec/services/recipe_parser_service_spec.rb`
  - [ ] `bundle exec rspec spec/services/recipe_translator_spec.rb`
  - [ ] `bundle exec rspec spec/services/step_variant_generator_spec.rb`
- [ ] F2: Run related request specs
  - [ ] `bundle exec rspec spec/requests/api/v1/recipes_spec.rb` (scale endpoint)
  - [ ] Verify all scaling tests pass
- [ ] F3: Run job specs
  - [ ] `bundle exec rspec spec/jobs/generate_step_variants_job_spec.rb`
  - [ ] `bundle exec rspec spec/jobs/translate_recipe_job_spec.rb`
- [ ] F4: Address test failures
  - [ ] Debug and fix any failures
  - [ ] Verify all tests passing before code audit

**Subtask G: Code Quality & Completion**
- [ ] G1: Commit implementation
  - [ ] Commit message: `[Phase 2] Step 4: Update services to work with normalized schema`
- [ ] G2: Run code-quality-auditor sub-agent
  - [ ] Delegate to code-quality-auditor agent for review
- [ ] G3: Address audit findings
  - [ ] Fix all HIGH severity issues
  - [ ] Fix critical MEDIUM severity issues
  - [ ] Document deferred issues with justification
  - [ ] If fixes made: Commit `[Phase 2] Step 4: Address code quality audit findings`
- [ ] G4: Mark step complete
  - [ ] Update re-architecture-plan.md with checkmarks for completed subtasks
  - [ ] Commit: `[Phase 2] Step 4: Mark complete`
- [ ] G5: Request approval
  - [ ] Disclose any deferred audit suggestions with reasoning
  - [ ] Summarize which ACs are now passing

**Step 5: Fix Controllers & Strong Parameters**

Goal: Update controllers to handle normalized field names and nested attributes

Subtasks:
- [ ] Update Admin::RecipesController#recipe_params:
  - [ ] Change `:servings` → `:servings_original`, `:servings_min`, `:servings_max`
  - [ ] Change `:timing` → `:prep_minutes`, `:cook_minutes`, `:total_minutes`
  - [ ] Add `ingredient_groups_attributes: [...]` for nested record creation
  - [ ] Add `recipe_steps_attributes: [...]` for step creation
  - [ ] Add `equipment_attributes: [...]` for equipment
  - [ ] Add `recipe_dietary_tags_attributes: [...]` for tags
- [ ] Update Api::V1::RecipesController#scale:
  - [ ] Ensure eager loading of ingredient_groups and recipe_ingredients
  - [ ] Pass correct parameters to RecipeScaler
  - [ ] Test AC-PHASE2-BACKWARD-COMPAT-003
- [ ] Update admin create/update/delete endpoints to use RecipeParserService correctly
- [ ] Verify POST /admin/recipes works with normalized structure
- [ ] Verify PUT /admin/recipes/:id works with normalized structure
- [ ] Verify POST /admin/recipes/parse_text creates normalized records
- [ ] Verify POST /admin/recipes/parse_url creates normalized records
- [ ] All controller tests passing
- [ ] Commit: `[Phase 2] Step 5: Update controllers for normalized schema`
- [ ] Run code audit and address issues
- [ ] Request approval

**Step 6: Add Constraint Tests + Write RSpec Tests Against Phase 2 ACs**
- [ ] Add position uniqueness constraint tests for ingredient_groups (M-3)
- [ ] Add step_number uniqueness constraint tests for recipe_steps (M-4)
- [ ] Write RSpec tests against Phase 2 acceptance criteria
- [ ] All tests passing
- [ ] Commit implementation
- [ ] Run code audit
- [ ] Address issues
- [ ] Request approval

**Step 7: Update Documentation**
- [ ] Update docs/api-reference.md with normalized schema examples
- [ ] Update docs/new_claude/architecture.md backend section
- [ ] Commit documentation updates
- [ ] Request approval

**Step 8: Final Review & Phase 2 Completion**
- [ ] Review plan vs actual discoveries
- [ ] Evaluate direction and assumptions
- [ ] Run full test suite - verify 100% passing
- [ ] Run code audit
- [ ] Address issues
- [ ] Final commit: [Phase 2] Complete: Backend specs fixed for normalized schema
- [ ] Request approval to proceed to Phase 3

---

### Phase 3: Model Specs

**BEFORE starting development:**
Write comprehensive GIVEN/WHEN/THEN acceptance criteria for model validations and constraints in `docs/new_claude/acceptance-criteria.md`.

Fill in all empty pending specs in `spec/models/`:
- Recipe validations
- User model
- Ingredient model
- IngredientAlias model
- DataReference model
- UserRecipeNote model
- UserFavorite model
- AiPrompt model
- JwtDenylist model

Ensure 100% pass.

**Deliverable**: All model specs fully implemented

**End of Phase**: Write RSpec tests against Phase 3 ACs for model validations

---

### Phase 4: Mobility Integration

**BEFORE starting development:**
Write comprehensive GIVEN/WHEN/THEN acceptance criteria for Mobility translation system in `docs/new_claude/acceptance-criteria.md`.

1. Add `gem 'mobility'` to Gemfile, run `bundle install`
2. Create `config/initializers/mobility.rb` with Table Backend configuration
3. Create migration for 6 translation tables:
   - recipe_translations
   - ingredient_group_translations
   - recipe_ingredient_translations
   - equipment_translations
   - recipe_step_translations
   - data_reference_translations
4. Add `translates :field_name` declarations to models:
   - Recipe: translates :name
   - IngredientGroup: translates :name
   - RecipeIngredient: translates :ingredient_name, :preparation_notes
   - Equipment: translates :canonical_name
   - RecipeStep: translates :instruction_original, :instruction_easier, :instruction_no_equipment
   - DataReference: translates :display_name

Update `docs/api-reference.md` to show Mobility behavior.

Update `docs/new_claude/architecture.md` to explain Mobility integration.

**Deliverable**: Mobility gem installed, translation tables created, models configured

**End of Phase**: Write RSpec tests against Phase 4 ACs for Mobility translations (verify translated fields work)

---

### Phase 5: Translation System & Background Jobs

**BEFORE starting development:**
Write comprehensive GIVEN/WHEN/THEN acceptance criteria for translation jobs and background processing in `docs/new_claude/acceptance-criteria.md`.

1. Refactor `TranslateRecipeJob` to use Mobility instead of JSONB
2. Update `StepVariantGenerator` to generate variants in source language first
3. Update `RecipeTranslator` service to use `Mobility.with_locale`
4. Add `after_commit` callback to Recipe model to trigger translation jobs
5. Test translation workflow end-to-end

Update `docs/api-reference.md` to show locale parameter handling.

Update `docs/new_claude/architecture.md` job callback patterns.

Create `docs/i18n-workflow.md` explaining translation system.

**Deliverable**: Translation system working, jobs auto-trigger, documentation created

**End of Phase**: Write RSpec tests against Phase 5 ACs for translation jobs (verify variants generated, translations created)

---

### Phase 6: New Backend Specs

**BEFORE starting development:**
Write comprehensive GIVEN/WHEN/THEN acceptance criteria for locale-aware API responses in `docs/new_claude/acceptance-criteria.md`.

Write RSpec tests for all remaining backend ACs:
- API responses include locale-aware translations
- Fallback behavior when translation missing
- Translation status tracking
- API accepts `?locale=` parameter correctly

Ensure 100% pass.

**Deliverable**: All backend ACs have passing tests

**End of Phase**: All backend tests pass

---

### Phase 7: Frontend Integration

**BEFORE starting development:**
Write comprehensive GIVEN/WHEN/THEN acceptance criteria for frontend integration with all 7 languages in `docs/new_claude/acceptance-criteria.md`.

1. Run existing frontend tests to identify breaks: `npm run test`
2. Update `frontend/src/types.ts` for normalized API responses
3. Update `frontend/src/api/recipeApi.ts` to pass `?locale=` parameter
4. Update components to handle new relational data structure (ingredients, steps, nutrition)
5. Test all 7 languages - verify language switcher triggers API refetch
6. Update `docs/component-library.md` with changes

**Deliverable**: All frontend tests pass, all 7 languages work

**End of Phase**: Run frontend test suite, verify 100% pass

---

### Phase 8: Final Documentation

1. Create `docs/database-architecture.md` with complete field definitions, units, relationships
2. Update `docs/new_claude/entry.md` to reference database-architecture.md
3. Update `docs/new_claude/architecture.md` to reference database-architecture.md
4. Post-mortem document

**Deliverable**: All documentation current and complete

**End of Phase**: N/A (final phase)

---

## Migration Strategy

### Development Approach

Since this is MVP with test data only:

1. **Run migration**: Execute migration file to create all tables
2. **Seed data**: Run updated seeds to populate 14 test recipes
3. **Test**: Verify seeds completed successfully
4. **Test application**: Run full RSpec suite, frontend tests
5. **Done**: Schema is live, move to next phase

If issues discovered midway: Revert git changes, drop new tables, re-seed from old data, investigate.

No complex rollback procedures needed.

---

## Risks & Mitigation

| Risk | Mitigation |
|------|------------|
| Seeds fail due to schema issues | Test seed logic before running full suite; debug incrementally |
| Service code breaks | Comprehensive RSpec tests in Phase 2 catch issues early |
| Mobility misconfiguration | Reference Mobility docs, test translations thoroughly in Phase 4 |
| Frontend breaks with new API format | Run existing tests first (Phase 7), fix one component at a time |
| Data structure issues | Update seeds, re-test, iterate |

---

## Success Criteria

Migration is successful when:

1. ✅ All 14 recipes display correctly in admin interface
2. ✅ All 14 recipes display correctly in user interface
3. ✅ Recipe CRUD operations work
4. ✅ Recipe search & filtering works
5. ✅ Recipe scaling works
6. ✅ Recipe translation workflow works
7. ✅ All automated tests pass (100% of test suite)
8. ✅ Zero JSONB columns remain in recipes table
9. ✅ Database schema documented in `docs/database-architecture.md`
10. ✅ Architecture docs updated with Mobility references
11. ✅ No performance regressions
12. ✅ All 7 languages work correctly in UI
13. ✅ API locale parameter works correctly
