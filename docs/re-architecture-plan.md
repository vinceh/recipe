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
     - Write ACs in GIVEN/WHEN/THEN format
     - Run sub-agent with acceptance-test-writing skill to review, identify gaps, and refine
     - Update ACs based on sub-agent recommendations
     - Commit the ACs
     - Then request approval before proceeding to Step 2
   - **For other steps:**
     - Work through all subtasks to completion
     - Mark each completed subtask: `- [x] Task name`
     - Commit the step implementation with message: `[Phase X] Step N: <description>`
     - **QUALITY CHECK**: Run sub-agent with code-quality-auditor skill to review code
     - Address all issues identified by code audit
     - Commit fixes if any issues were addressed: `[Phase X] Step N: Address code quality issues`
     - Mark subtask progress in plan document
     - Commit plan update: `[Phase X] Step N: Mark complete`
     - **PAUSE AND REQUEST APPROVAL**
     - In approval request, disclose any code audit suggestions that were NOT addressed, with reasons why
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
    t.integer  "timing_minutes"
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
- [ ] Run `rails db:migrate` to apply all Phase 1 schema changes
- [ ] Verify migration completes without errors
- [ ] Update db/seeds.rb with test recipes for new schema
- [ ] **CRITICAL: ALL fields must be covered to test every field works**
  - [ ] All servings variations (servings_original, servings_min, servings_max)
  - [ ] All timing fields (prep_minutes, cook_minutes, total_minutes)
  - [ ] All ingredient group variations (single group, multiple groups)
  - [ ] All recipe ingredient fields (amount, unit, preparation_notes, optional flag)
  - [ ] All recipe step fields (step_number, timing_minutes, instruction_original, instruction_easier, instruction_no_equipment)
  - [ ] All equipment variations (required and optional)
  - [ ] All reference data associations (dietary_tags, dish_types, cuisines, recipe_types)
  - [ ] All recipe aliases with multiple languages
  - [ ] All nutrition fields
  - [ ] Null/missing values to test optional fields
- [ ] Ensure 10+ test recipes with comprehensive coverage
- [ ] Cover edge cases per AC-PHASE1-014c
- [ ] Run `rails db:seed` to populate test data
- [ ] Verify no errors and check data integrity
- [ ] Commit: `[Phase 1] Step 5: Run migration and comprehensive seeds`

**Step 6: Write RSpec Tests**
- [ ] Write test suite covering Phase 1 ACs
- [ ] All tests passing
- [ ] Commit: `[Phase 1] Step 6: Add RSpec tests for schema normalization`

**Step 7: Final Review**
- [ ] Review plan against actual discoveries
- [ ] Evaluate direction and assumptions
- [ ] Update documentation if needed
- [ ] Final commit: `[Phase 1] Step 7: Complete - Database schema normalization`

---

### Phase 2: Fix Existing Backend Specs

**BEFORE starting development:**
Write comprehensive GIVEN/WHEN/THEN acceptance criteria for API endpoints with normalized schema in `docs/new_claude/acceptance-criteria.md`.

Run `bundle exec rspec` and fix failures iteratively.

Update as needed:
- Services (RecipeScaler, RecipeTranslator, RecipeParserService, StepVariantGenerator, RecipeSearchService, etc.)
- Serializers
- Controllers
- Models

Update `docs/api-reference.md` to reflect API changes.

Update `docs/new_claude/architecture.md` backend section.

**Deliverable**: All existing tests pass, API docs updated

**End of Phase**: Write RSpec tests against Phase 2 ACs for normalized structure (ingredient_groups, recipe_ingredients, join tables)

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
