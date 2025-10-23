# Phase 2: Database Schema Normalization - API & Service Acceptance Criteria

**Status:** Draft
**Date:** 2025-10-23
**Purpose:** Define acceptance criteria for fixing API endpoints, serializers, and services to work with normalized database schema while maintaining backward compatibility with existing API responses.

---

## Overview

Phase 2 focuses on updating the backend to work with Phase 1's normalized schema:
- **servings_original, servings_min, servings_max** (integer columns instead of JSONB)
- **prep_minutes, cook_minutes, total_minutes** (integer columns instead of JSONB)
- **ingredient_groups, recipe_ingredients** (relational tables instead of JSONB)
- **recipe_steps** (relational table with separate instruction variants instead of nested JSONB)
- **equipment, recipe_equipment** (relational tables instead of JSONB array)
- **dietary_tags, dish_types, cuisines, recipe_types** (join tables instead of JSONB arrays)

All existing API responses must remain JSONB-compatible (AC-PHASE2-BACKWARD-COMPAT-001 through -003).

---

## API Endpoints - Backward Compatibility

### AC-PHASE2-BACKWARD-COMPAT-001: GET /api/v1/recipes - JSONB Response Format
**GIVEN** recipes stored with normalized schema (servings_original, ingredient_groups table, recipe_steps table, etc.)
**WHEN** client calls GET /api/v1/recipes
**THEN** response should include servings as `{original: 4, min: 2, max: 8}` (JSONB structure, not separate fields)
**AND** response should include timing as `{prep_minutes: 15, cook_minutes: 30, total_minutes: 45}` (JSONB structure)
**AND** response should include dietary_tags as `["vegetarian", "gluten-free"]` (array, not join table references)
**AND** response should maintain all existing fields (id, name, language, servings, timing, dietary_tags, dish_types, cuisines, created_at, updated_at)

### AC-PHASE2-BACKWARD-COMPAT-002: GET /api/v1/recipes/:id - JSONB Response Format
**GIVEN** recipe stored with normalized schema
**WHEN** client calls GET /api/v1/recipes/:id
**THEN** response should include ingredient_groups as nested JSONB with items array (AC-SCALE-001 structure from acceptance-criteria.md)
**AND** response should include steps as array with `id`, `order`, `instructions: {original, easier, no_equipment}` structure
**AND** response should include equipment as simple array `["pan", "knife", "cutting board"]`
**AND** recipe_nutrition should be returned if exists (or omitted if null)

### AC-PHASE2-BACKWARD-COMPAT-003: POST /api/v1/recipes/:id/scale - Scaling with Normalized Data
**GIVEN** recipe with normalized ingredient_groups + recipe_ingredients associations
**WHEN** client calls POST /api/v1/recipes/:id/scale with `{servings: 8}`
**THEN** response should return scaled recipe with JSONB ingredient_groups structure (backward compatible)
**AND** RecipeScaler service should query ingredient_groups.recipe_ingredients associations
**AND** response should maintain all scaling logic (AC-SCALE-001 through AC-SCALE-012 from acceptance-criteria.md)

---

## Serializers - Transformation Logic

### AC-PHASE2-SERIALIZER-001: RecipeSerializer - Transform Servings
**GIVEN** recipe record with servings_original, servings_min, servings_max integer columns
**WHEN** RecipeSerializer serializes the recipe
**THEN** serialized output should include `servings: {original: 4, min: 2, max: 8}` (JSONB object)

### AC-PHASE2-SERIALIZER-001B: RecipeSerializer - Servings Null Handling
**GIVEN** recipe record with null servings fields
**WHEN** RecipeSerializer serializes the recipe
**THEN** servings field should be omitted from response (not included as null)

### AC-PHASE2-SERIALIZER-002: RecipeSerializer - Transform Timing
**GIVEN** recipe record with prep_minutes, cook_minutes, total_minutes integer columns
**WHEN** RecipeSerializer serializes the recipe
**THEN** serialized output should include `timing: {prep_minutes: 15, cook_minutes: 30, total_minutes: 45}`

### AC-PHASE2-SERIALIZER-002B: RecipeSerializer - Timing Null Handling
**GIVEN** recipe record with null timing fields (e.g., prep_minutes: null)
**WHEN** RecipeSerializer serializes the recipe
**THEN** timing field should be omitted from response (not included as null)

### AC-PHASE2-SERIALIZER-003: RecipeSerializer - Transform Tags
**GIVEN** recipe with recipe_dietary_tags, recipe_dish_types, recipe_cuisines, recipe_recipe_types join table records
**WHEN** RecipeSerializer serializes the recipe
**THEN** serialized output should include `dietary_tags: ["vegetarian", "gluten-free"]` (array of display_name values)
**AND** serialized output should include `dish_types: ["main-course"]`
**AND** serialized output should include `cuisines: ["italian"]`
**AND** serialized output should include `recipe_types: ["quick-weeknight"]`

### AC-PHASE2-SERIALIZER-004: RecipeSerializer - Transform Ingredient Groups
**GIVEN** recipe with ingredient_groups and recipe_ingredients associations
**WHEN** RecipeSerializer serializes the recipe
**THEN** serialized output should include `ingredient_groups` as JSONB array with structure:
```json
[
  {
    "name": "Main Ingredients",
    "items": [
      {
        "name": "chicken breast",
        "amount": "500",
        "unit": "g",
        "preparation": "diced"
      }
    ]
  }
]
```
**AND** items should be ordered by position
**AND** preparation should be omitted if null/empty

### AC-PHASE2-SERIALIZER-005: RecipeSerializer - Transform Steps
**GIVEN** recipe with recipe_steps association (instruction_original, instruction_easier, instruction_no_equipment columns)
**WHEN** RecipeSerializer serializes the recipe
**THEN** serialized output should include `steps` as JSONB array with structure:
```json
[
  {
    "id": "step-001",
    "order": 1,
    "instructions": {
      "original": "Heat oil in pan",
      "easier": "Add oil to hot pan",
      "no_equipment": "Use hands to warm oil"
    }
  }
]
```
**AND** steps should be ordered by step_number
**AND** instruction variants (easier, no_equipment) should be omitted if null/empty
**AND** id should be formatted as "step-NNN" (zero-padded step_number)

### AC-PHASE2-SERIALIZER-006: RecipeSerializer - Transform Equipment
**GIVEN** recipe with recipe_equipment and equipment associations
**WHEN** RecipeSerializer serializes the recipe
**THEN** serialized output should include `equipment: ["large pan", "knife", "cutting board"]`
**AND** equipment should be ordered as stored (by equipment association order)

### AC-PHASE2-SERIALIZER-007: IngredientGroupSerializer - Nested Serialization
**GIVEN** ingredient_group with recipe_ingredients
**WHEN** IngredientGroupSerializer serializes within recipe context
**THEN** should return name and items array (tested via RecipeSerializer)
**AND** should NOT serialize recipe_id or recipe association (internal use only)

### AC-PHASE2-SERIALIZER-008: RecipeSerializer - Empty Ingredient Groups
**GIVEN** recipe with no ingredient_groups
**WHEN** RecipeSerializer serializes the recipe
**THEN** ingredient_groups field should be empty array `[]`
**AND** response should NOT omit the field (array should be present)

### AC-PHASE2-SERIALIZER-009: RecipeSerializer - Empty Steps
**GIVEN** recipe with no recipe_steps
**WHEN** RecipeSerializer serializes the recipe
**THEN** steps field should be empty array `[]`
**AND** response should NOT omit the field

### AC-PHASE2-SERIALIZER-010: RecipeSerializer - Empty Equipment
**GIVEN** recipe with no recipe_equipment associations
**WHEN** RecipeSerializer serializes the recipe
**THEN** equipment field should be empty array `[]`
**AND** response should NOT omit the field

### AC-PHASE2-SERIALIZER-011: RecipeSerializer - Empty Tags
**GIVEN** recipe with no recipe_dietary_tags, recipe_dish_types, cuisines, or recipe_types
**WHEN** RecipeSerializer serializes the recipe
**THEN** dietary_tags, dish_types, cuisines, recipe_types fields should be empty arrays `[]`
**AND** response should include all four tag fields (not omit them)

---

## Services - Normalized Data Handling

### AC-PHASE2-SERVICE-001: RecipeScaler - Scales with Normalized Ingredients
**GIVEN** recipe with normalized ingredient_groups/recipe_ingredients
**WHEN** RecipeScaler.scale(recipe, servings: 8) is called
**THEN** scaling logic works identically to JSONB version (AC-SCALE-001 through AC-SCALE-012)
**AND** all ingredient amounts scale correctly
**AND** fractional amounts display as friendly fractions (AC-SCALE-002)

### AC-PHASE2-SERVICE-002: RecipeScaler - Returns Serializable Format
**GIVEN** scaled ingredients from RecipeScaler with normalized structure
**WHEN** RecipeScaler returns result
**THEN** result is compatible with RecipeSerializer (ingredient_group/items structure)
**AND** scaled recipe can be serialized to JSONB format
**AND** database recipe record is NOT modified (scaling is view-only)

### AC-PHASE2-SERVICE-003: RecipeParserService - Creates Normalized Records
**GIVEN** parsed recipe JSON from AI with ingredient_groups and steps arrays
**WHEN** RecipeParserService.create_recipe(parsed_data) is called
**THEN** Recipe is created with servings_original, servings_min, servings_max values
**AND** IngredientGroup records are created with position field (ordered)
**AND** RecipeIngredient records are created with position field (ordered)
**AND** RecipeStep records are created with step_number field (ordered)
**AND** Equipment and recipe_equipment associations are created correctly

### AC-PHASE2-SERVICE-004: StepVariantGenerator - Generates Variants for Normalized Steps
**GIVEN** recipe with multiple recipe_steps (normalized)
**WHEN** StepVariantGenerator.generate(recipe) is called
**THEN** instruction_easier variant is generated for each step
**AND** instruction_no_equipment variant is generated for each step
**AND** recipe.variants_generated flag is set to true
**AND** database records are updated correctly

### AC-PHASE2-SERVICE-005: RecipeSearchService - Filters by Normalized Tags
**GIVEN** multiple recipes with normalized tag associations (recipe_dietary_tags, recipe_cuisines)
**WHEN** RecipeSearchService searches by dietary_tag: "vegetarian"
**THEN** only recipes with matching dietary_tags are returned
**AND** search results are accurate
**AND** filtering works for all tag types (dietary_tags, dish_types, cuisines, recipe_types)

### AC-PHASE2-SERVICE-006: RecipeTranslator - Translates Normalized Steps
**GIVEN** recipe with multiple recipe_steps (normalized)
**WHEN** RecipeTranslator.translate(recipe, target_lang: "ja") is called
**THEN** instruction_original is translated correctly
**AND** instruction_easier and instruction_no_equipment variants are translated
**AND** database recipe_step_translation records are created

---

## Controllers - Handling Normalized Data

### AC-PHASE2-CONTROLLER-001: AdminRecipesController#create - Save Normalized Data
**GIVEN** admin submits recipe creation form with JSON payload
**WHEN** POST /admin/recipes request is processed
**THEN** controller should pass parsed data to RecipeParserService
**AND** service should create normalized database records
**AND** response should serialize using RecipeSerializer (JSONB format)

### AC-PHASE2-CONTROLLER-002: RecipesController#show - Serialization
**GIVEN** recipe stored with normalized schema
**WHEN** GET /api/v1/recipes/:id request is processed
**THEN** controller should serialize using RecipeSerializer
**AND** response should include all JSONB-compatible fields (backward compatible)

### AC-PHASE2-CONTROLLER-003: RecipesController#scale - Scaling Endpoint
**GIVEN** recipe and scaling request with servings or ingredient parameter
**WHEN** POST /api/v1/recipes/:id/scale is processed
**THEN** controller should call RecipeScaler with normalized recipe
**AND** controller should serialize scaled output
**AND** response should NOT save to database (view-only)

---

## Data Constraints & Validations

### AC-PHASE2-CONSTRAINT-001: Ingredient Group Position Uniqueness
**GIVEN** recipe with multiple ingredient_groups
**WHEN** attempting to create two ingredient_groups with same position
**THEN** database constraint (recipe_id + position unique index) should prevent duplicate
**AND** ActiveRecord should raise error on validation

### AC-PHASE2-CONSTRAINT-002: Recipe Step Number Uniqueness
**GIVEN** recipe with multiple recipe_steps
**WHEN** attempting to create two recipe_steps with same step_number
**THEN** database constraint (recipe_id + step_number unique index) should prevent duplicate
**AND** ActiveRecord should raise error on validation

### AC-PHASE2-CONSTRAINT-003: Join Table Uniqueness
**GIVEN** recipe with dietary_tags
**WHEN** attempting to add same dietary tag twice
**THEN** database constraint (recipe_id + data_reference_id unique index) should prevent duplicate
**AND** ActiveRecord has_many through: should handle uniqueness

---

## Model Associations & Behavior

### AC-PHASE2-MODEL-001: Recipe Cascade Delete - Deletes All Related Data
**GIVEN** recipe with ingredient_groups, recipe_steps, equipment, and tag associations
**WHEN** recipe is deleted from database
**THEN** all associated ingredient_groups are deleted
**AND** all associated recipe_steps are deleted
**AND** all recipe_equipment records are deleted
**AND** all recipe tag associations (dietary_tags, dish_types, etc.) are deleted
**AND** no orphaned records remain in database

### AC-PHASE2-MODEL-002: IngredientGroup Ordering - Maintains Position
**GIVEN** recipe with multiple ingredient_groups (position: 1, 2, 3)
**WHEN** loading recipe.ingredient_groups
**THEN** groups are returned in order by position
**AND** recipe.ingredient_groups.first has position 1

### AC-PHASE2-MODEL-003: RecipeStep Ordering - Maintains Step Number
**GIVEN** recipe with multiple recipe_steps (step_number: 1, 2, 3, 4)
**WHEN** loading recipe.recipe_steps
**THEN** steps are returned in order by step_number
**AND** recipe.recipe_steps.first.step_number is 1

---

## Error Handling

### AC-PHASE2-ERROR-001: GET /api/v1/recipes/:id - Recipe Not Found
**GIVEN** request for non-existent recipe
**WHEN** GET /api/v1/recipes/:id is called with invalid UUID
**THEN** response should return 404 status
**AND** response should include error message: "Record not found"
**AND** no exception should be logged

### AC-PHASE2-ERROR-002: POST /api/v1/recipes/:id/scale - Invalid Servings
**GIVEN** recipe with normalized servings
**WHEN** POST /api/v1/recipes/:id/scale is called with invalid servings (negative, string, null)
**THEN** response should return 400 status
**AND** error message should explain what went wrong
**AND** no partial scale result should be returned

### AC-PHASE2-ERROR-003: Duplicate Ingredient Group Position
**GIVEN** recipe with ingredient_group at position 1
**WHEN** attempting to create another ingredient_group with position 1
**THEN** database should prevent duplicate (unique constraint violation)
**AND** ActiveRecord should raise validation error

### AC-PHASE2-ERROR-004: Duplicate Recipe Step Number
**GIVEN** recipe with recipe_step with step_number 2
**WHEN** attempting to create another recipe_step with step_number 2
**THEN** database should prevent duplicate (unique constraint violation)
**AND** ActiveRecord should raise validation error

### AC-PHASE2-ERROR-005: Duplicate Recipe Tag Assignment
**GIVEN** recipe already has dietary_tag "vegetarian"
**WHEN** attempting to add dietary_tag "vegetarian" again
**THEN** database should prevent duplicate (unique constraint on join table)
**AND** ActiveRecord should raise validation error

---

## Performance & Optimization

### AC-PHASE2-PERF-001: RecipeSerializer Uses Eager Loading
**GIVEN** request to GET /api/v1/recipes (list endpoint with 10 recipes)
**WHEN** controller serializes list of recipes
**THEN** serialization should use eager-loaded associations (ingredient_groups, recipe_steps, equipment, tags)
**AND** should NOT trigger N+1 queries (should use single query per association)
**AND** response time should match JSONB version (AC-PERF-002 baseline)

### AC-PHASE2-PERF-002: Ingredient Position Ordering - Database Level
**GIVEN** recipe with multiple ingredient_groups
**WHEN** recipe.ingredient_groups is queried
**THEN** query should include ORDER BY position in SQL
**AND** results are pre-ordered by database (no application-level sorting needed)

### AC-PHASE2-PERF-003: Step Number Ordering - Database Level
**GIVEN** recipe with multiple recipe_steps
**WHEN** recipe.recipe_steps is queried
**THEN** query should include ORDER BY step_number in SQL
**AND** results are pre-ordered by database

### AC-PHASE2-PERF-004: RecipeScaler - Efficient Scaled Response
**GIVEN** recipe with 50 ingredient_groups (100+ total ingredients)
**WHEN** POST /api/v1/recipes/:id/scale is called
**THEN** scaling should complete within 200ms (client-side calculation speed)
**AND** response serialization should include eager loading
**AND** no additional database queries should be made during scaling

---

## Search & Filtering

### AC-PHASE2-SEARCH-001: Filter by Dietary Tag - Query Normalized Join Table
**GIVEN** 10 recipes, 3 marked vegetarian, 7 non-vegetarian
**WHEN** GET /api/v1/recipes?dietary_tags=vegetarian is called
**THEN** only 3 vegetarian recipes are returned
**AND** search uses recipe_dietary_tags join table (not JSONB query)
**AND** results are accurate and efficient

### AC-PHASE2-SEARCH-002: Filter by Multiple Cuisines - OR Logic
**GIVEN** recipes with various cuisines (italian, japanese, mexican, etc.)
**WHEN** GET /api/v1/recipes?cuisines=italian,japanese is called
**THEN** recipes with italian OR japanese cuisine are returned
**AND** search uses recipe_cuisines join table
**AND** filtering is case-insensitive and matches display_name

### AC-PHASE2-SEARCH-003: Filter by Dish Type - Query Join Table
**GIVEN** recipes with dish_types (main-course, side-dish, dessert)
**WHEN** GET /api/v1/recipes?dish_types=main-course is called
**THEN** only main-course recipes are returned
**AND** search uses recipe_dish_types join table

### AC-PHASE2-SEARCH-004: Combine Search Query with Tag Filters
**GIVEN** recipes: "Vegetarian Curry" (vegetarian, indian), "Beef Curry" (non-vegetarian, indian)
**WHEN** GET /api/v1/recipes?q=curry&dietary_tags=vegetarian is called
**THEN** only "Vegetarian Curry" is returned
**AND** search combines full-text name query with tag filter AND logic
**AND** results are accurate

---

## Summary

- **Total Phase 2 ACs:** 40
- **Backward Compatibility:** 3 ACs
- **Serializers:** 11 ACs (including null/empty handling)
- **Services:** 6 ACs (refactored for behavior focus)
- **Controllers:** 3 ACs
- **Constraints & Validations:** 3 ACs
- **Model Associations & Behavior:** 3 ACs (refactored for cascading and ordering)
- **Error Handling:** 5 ACs (including API errors and constraint violations)
- **Performance & Optimization:** 4 ACs
- **Search & Filtering:** 4 ACs

All ACs map to existing acceptance criteria in acceptance-criteria.md (e.g., AC-SCALE-001 through AC-SCALE-012, AC-ADMIN-001 through AC-ADMIN-015, AC-VIEW-001 through AC-VIEW-007) ensuring Phase 2 implementation maintains all existing functionality while working with normalized schema.

---

# Phase 4: Mobility Translation System - Internationalization Acceptance Criteria

**Status:** Draft
**Date:** 2025-10-24
**Purpose:** Define acceptance criteria for integrating Mobility gem to manage multi-language translations across Recipe, IngredientGroup, RecipeIngredient, Equipment, RecipeStep, and DataReference models using Table Backend with UUID foreign key support.

---

## Overview

Phase 4 implements the Mobility gem for managing translations with:
- **Mobility gem installation** with Table Backend configuration
- **Translated fields** declared on 6 core models (Recipe, IngredientGroup, RecipeIngredient, Equipment, RecipeStep, DataReference)
- **Locale switching** via I18n.with_locale and Mobility.locale
- **Fallback chains** for missing translations (ja→en, ko→en, zh-tw→zh-cn→en)
- **Translation tables** (existing from Phase 1) compatible with Mobility Table Backend
- **Reading/writing translations** via Mobility attribute accessors and API
- **Querying translated fields** with .i18n scope
- **Edge cases** for null/missing translations and validation behavior

---

## Mobility Installation & Configuration

### AC-PHASE4-CONFIG-001: Mobility Gem Installation and Gemfile
**GIVEN** Rails 7.0+ backend project with Gemfile
**WHEN** Mobility gem is added to Gemfile and `bundle install` is run
**THEN** Mobility gem version 1.2+ should be installed
**AND** Mobility should be available in the application via `require 'mobility'`
**AND** Rails generators should include Mobility generators

### AC-PHASE4-CONFIG-002: Mobility Table Backend Configuration
**GIVEN** Rails application with Mobility gem installed and configured
**WHEN** a translatable model saves a translated field value
**THEN** translation should be persisted to database table (not JSONB column)
**AND** translation should be retrievable from table backend
**AND** reading/writing translated fields should work without errors

### AC-PHASE4-CONFIG-003: UUID Foreign Key Support in Translations
**GIVEN** Recipe model with UUID primary key
**WHEN** translation is saved via Mobility for that recipe
**THEN** translation record should link to recipe via UUID foreign key without type errors
**AND** translation should persist and be retrievable correctly
**AND** no database constraint violations should occur

### AC-PHASE4-CONFIG-004: Default Locale and Fallback Chain
**GIVEN** Rails application with I18n configured
**WHEN** config/initializers/i18n.rb is set
**THEN** I18n.default_locale should be :en (English)
**AND** I18n.fallback_locales should include fallback chain: ja→en, ko→en, zh-tw→zh-cn→en, es→en
**AND** Mobility should respect fallback_locales for missing translations

---

## Model Translation Declarations

### AC-PHASE4-MODEL-001: Recipe Model - Translate Name
**GIVEN** Recipe model with name column
**WHEN** `translates :name` is declared in Recipe model
**THEN** recipe.name should be translatable
**AND** recipe.name = "value" should write to translation table for current locale
**AND** recipe.name should read from translation table for current locale
**AND** translation storage should use Mobility Table Backend

### AC-PHASE4-MODEL-002: IngredientGroup Model - Translate Name
**GIVEN** IngredientGroup model with name column
**WHEN** `translates :name` is declared in IngredientGroup model
**THEN** ingredient_group.name should be translatable
**AND** ingredient_group.name = "value" should write to translation table
**AND** translation should be scoped to ingredient_group and locale

### AC-PHASE4-MODEL-003: RecipeIngredient Model - Translate Multiple Fields
**GIVEN** RecipeIngredient model with ingredient_name and preparation_notes columns
**WHEN** `translates :ingredient_name, :preparation_notes` is declared
**THEN** recipe_ingredient.ingredient_name should be translatable
**AND** recipe_ingredient.preparation_notes should be translatable
**AND** both fields should store/read independently from translation table
**AND** each field can have different values across locales

### AC-PHASE4-MODEL-004: Equipment Model - Translate Canonical Name
**GIVEN** Equipment model with canonical_name column
**WHEN** `translates :canonical_name` is declared
**THEN** equipment.canonical_name should be translatable
**AND** equipment.canonical_name = "value" should write to translation table

### AC-PHASE4-MODEL-005: RecipeStep Model - Translate Instruction Variants
**GIVEN** RecipeStep model with instruction_original, instruction_easier, instruction_no_equipment columns
**WHEN** `translates :instruction_original, :instruction_easier, :instruction_no_equipment` is declared
**THEN** all three instruction fields should be translatable independently
**AND** each variant can have different translation per locale
**AND** reading recipe_step.instruction_original in different locales returns locale-specific value

### AC-PHASE4-MODEL-006: DataReference Model - Translate Display Name
**GIVEN** DataReference model with display_name column
**WHEN** `translates :display_name` is declared
**THEN** data_reference.display_name should be translatable
**AND** translations should be scoped to data_reference and locale

---

## Reading Translations - Locale Switching

### AC-PHASE4-READ-001: Reading Translation in Current Locale
**GIVEN** recipe with name translated to ja (Japanese) and en (English)
**WHEN** I18n.locale is set to :ja
**AND** recipe.name is accessed
**THEN** Japanese translation should be returned
**AND** translatable accessor returns the translation for current locale

### AC-PHASE4-READ-002: Reading Translation with I18n.with_locale
**GIVEN** recipe with name in multiple locales
**WHEN** `I18n.with_locale(:ja) { recipe.name }` is called
**THEN** Japanese translation should be returned
**AND** I18n.locale should not change outside the block
**AND** original locale should be restored after block execution

### AC-PHASE4-READ-003: Reading Translation with Mobility.with_locale
**GIVEN** recipe with translations
**WHEN** `Mobility.with_locale(:ko) { recipe.name }` is called
**THEN** Korean translation should be returned
**AND** original locale should be restored after block

### AC-PHASE4-READ-004: Missing Translation Falls Back to Fallback Locale
**GIVEN** recipe with name in en but not ja (and fallback chain: ja→en)
**WHEN** I18n.locale is set to :ja
**AND** recipe.name is accessed
**THEN** English translation should be returned (fallback)
**AND** no error should be raised

### AC-PHASE4-READ-005: Missing Translation in All Locales Returns Nil
**GIVEN** recipe with no translation for ingredient_name in any locale
**WHEN** recipe_ingredient.ingredient_name is accessed in ja
**THEN** nil should be returned (no fallback available)
**AND** no error should be raised

### AC-PHASE4-READ-006: Translated Field Without Translation Uses Fallback Chain
**GIVEN** recipe with name translated only to en
**WHEN** I18n.locale set to ja, ko, zh-tw (none have translation)
**AND** recipe.name is accessed
**THEN** English translation should be returned (final fallback locale)

---

## Writing Translations

### AC-PHASE4-WRITE-001: Writing Translation to Current Locale
**GIVEN** recipe with current I18n.locale = :en
**WHEN** recipe.name = "New Recipe Name" is assigned
**THEN** translation should be written to translation table for :en locale
**AND** database recipe_id, locale, key, and value should be stored
**AND** no JSONB column should be created (Table Backend only)

### AC-PHASE4-WRITE-002: Writing Translation Creates Translation Record
**GIVEN** recipe with no existing translation for ja locale
**WHEN** I18n.with_locale(:ja) { recipe.name = "レシピ名" }
**THEN** new record should be created in translation table
**AND** record should have recipe_id, key: "name", locale: "ja", value: "レシピ名"
**AND** record.translatable_type should be "Recipe"

### AC-PHASE4-WRITE-003: Updating Translation Overwrites Existing Value
**GIVEN** recipe with existing translation name: "Old Name" in ja locale
**WHEN** I18n.with_locale(:ja) { recipe.name = "New Name" }
**AND** recipe.save is called
**THEN** translation value should be updated to "New Name"
**AND** existing translation record should be modified, not replaced

### AC-PHASE4-WRITE-003B: No Duplicate Translation Records After Update
**GIVEN** recipe with existing translation record for recipe_id/ja/name
**WHEN** translation is updated and recipe.save is called
**THEN** translation table should contain single record for recipe_id/ja/name (not duplicates)
**AND** translation record count should not increase

### AC-PHASE4-WRITE-004: Writing Null Translation
**GIVEN** recipe with translation value = "Recipe Name"
**WHEN** I18n.with_locale(:en) { recipe.name = nil }
**AND** recipe.save is called
**THEN** translation record should be updated with value: null
**AND** subsequent read returns nil (no fallback to previous value)

### AC-PHASE4-WRITE-005: Writing Multiple Fields in Different Locales
**GIVEN** recipe_step with instruction_original, instruction_easier, instruction_no_equipment
**WHEN** I18n.with_locale(:ja) { recipe_step.instruction_original = "焼く" }
**AND** I18n.with_locale(:ja) { recipe_step.instruction_easier = "温める" }
**AND** recipe_step.save
**THEN** two separate translation records should be created
**AND** each record has different key but same recipe_step_id and locale

---

## Querying Translated Fields

### AC-PHASE4-QUERY-001: Querying Translated Fields with .i18n Scope
**GIVEN** 5 recipes: 2 with English name "Curry", 2 with English name "Pad Thai", 1 with English name "Sushi"
**WHEN** `Recipe.i18n.where(name: "Curry")` is called with I18n.locale = :en
**THEN** exactly 2 recipes with English name "Curry" should be returned
**AND** "Pad Thai" and "Sushi" recipes should not be included
**AND** query should use translation table join for locale-aware filtering

### AC-PHASE4-QUERY-002: Searching Across Locales with .i18n
**GIVEN** recipes: "Curry" (en), "カレー" (ja), "Curry Chicken" (en)
**WHEN** `Recipe.i18n.where(name: "Curry")` is called in en locale
**THEN** "Curry" and "Curry Chicken" should be returned
**AND** "カレー" should NOT be returned (different locale)

### AC-PHASE4-QUERY-003: Querying with Fallback Locale
**GIVEN** recipes with translations only in en (no ja)
**WHEN** `Recipe.i18n.where(name: "Curry")` is called with I18n.locale = :ja
**AND** fallback chain is ja→en
**THEN** recipes with English name "Curry" should be returned
**AND** query uses fallback locale when no ja translation exists

### AC-PHASE4-QUERY-004: Combining .i18n with Other Scopes
**GIVEN** recipes with category "dessert" and names in en
**WHEN** `Recipe.where(category: "dessert").i18n.where(name: "Cake")` is called
**THEN** only dessert recipes with name "Cake" should be returned
**AND** filtering works on both translated and non-translated fields

### AC-PHASE4-QUERY-005: Ordering by Translated Field
**GIVEN** 5 recipes with names: "Zucchini Bread", "Apple Pie", "Carrot Cake", "Beef Stew", "Avocado Toast" (all in en)
**WHEN** recipes are queried and ordered by .i18n.order("name ASC") with I18n.locale = :en
**THEN** results should be ordered alphabetically: "Apple Pie", "Avocado Toast", "Beef Stew", "Carrot Cake", "Zucchini Bread"
**AND** ordering should use translated name values from translation table, not original column

---

## Validation & Constraints

### AC-PHASE4-VALID-001: Presence Validation on Translated Field
**GIVEN** Recipe model with `validates :name, presence: true`
**WHEN** I18n.with_locale(:en) { recipe.name = nil; recipe.valid? } is called
**THEN** recipe.valid? should return false
**AND** errors[:name] should include presence error message

### AC-PHASE4-VALID-002: Uniqueness Validation on Translated Field (Same Locale)
**GIVEN** recipe1 with name "Curry" in en, trying to create recipe2
**WHEN** I18n.with_locale(:en) { recipe2.name = "Curry"; recipe2.valid? }
**THEN** recipe2.valid? should return false (if uniqueness is enforced)
**AND** uniqueness constraint should be scoped to locale

### AC-PHASE4-VALID-003: Allowing Same Value in Different Locales
**GIVEN** recipe with name "Curry" in en
**WHEN** I18n.with_locale(:ja) { recipe.name = "Curry"; recipe.valid? }
**THEN** recipe.valid? should return true
**AND** same value can exist in different locales for same record

### AC-PHASE4-VALID-004: Validation Error Includes Field and Locale
**GIVEN** recipe with missing translations
**WHEN** recipe.valid? returns false with presence error
**THEN** error message should clearly indicate which field failed
**AND** validation should work regardless of current locale

---

## Serialization with Translations

### AC-PHASE4-SERIAL-001: API Response Includes Current Locale Translation
**GIVEN** recipe with names in en and ja
**WHEN** GET /api/v1/recipes/:id is called with Accept-Language: ja-JP
**AND** I18n.locale is set from request header
**THEN** response should include recipe.name as Japanese translation
**AND** serializer should use current I18n.locale

### AC-PHASE4-SERIAL-002: API Response with Fallback Locale
**GIVEN** recipe with name only in en
**WHEN** GET /api/v1/recipes/:id is called with Accept-Language: ja
**THEN** response should include English translation (fallback)
**AND** no error should be returned

### AC-PHASE4-SERIAL-003: Serializing Multiple Translated Fields
**GIVEN** recipe_step with instruction_original, instruction_easier in ja
**WHEN** recipe_step is serialized with I18n.locale = :ja
**THEN** response should include all three instruction fields with Japanese values
**AND** null variants should be omitted or explicitly null based on design

### AC-PHASE4-SERIAL-004: Serializing Nested Translated Objects
**GIVEN** recipe with ingredient_groups (translated name) and recipe_ingredients (translated ingredient_name)
**WHEN** recipe is serialized with I18n.locale = :ja
**THEN** nested ingredient_groups should include Japanese names
**AND** nested recipe_ingredients should include Japanese ingredient_names
**AND** serialization should recursively apply locale context

### AC-PHASE4-SERIAL-005: Partial Translations in Nested Objects
**GIVEN** recipe with 3 ingredient_groups: 2 with ja translations, 1 without ja translation (en fallback only)
**WHEN** recipe is serialized with I18n.locale = :ja
**THEN** ingredient_groups with ja translations should return Japanese names
**AND** ingredient_group without ja translation should return English name (fallback)
**AND** serialization should handle mixed translation states gracefully

---

## Service Integration with Translations

### AC-PHASE4-SERVICE-001: RecipeParserService Saves Translations
**GIVEN** parsed recipe JSON with names in multiple languages
**WHEN** RecipeParserService.create_recipe(parsed_data, locales: [:en, :ja])
**THEN** Recipe should be created with name translation in en
**AND** IngredientGroup names should be translated in en and ja
**AND** RecipeStep instructions should be translated in en and ja

### AC-PHASE4-SERVICE-002: TranslateRecipeJob Uses Mobility API
**GIVEN** recipe with English instructions
**WHEN** TranslateRecipeJob.perform_later(recipe_id, target_lang: "ja")
**AND** job executes AI translation
**THEN** job should use `I18n.with_locale(:ja) { recipe_step.instruction_original = translated_value }`
**AND** translation should be saved via Mobility API (not direct column write)
**AND** recipe_step.save should persist to translation table

### AC-PHASE4-SERVICE-003: RecipeScaler Preserves Translations
**GIVEN** recipe with scaled ingredients where ingredient_name is translated
**WHEN** RecipeScaler.scale(recipe, servings: 8) is called with I18n.locale = :ja
**THEN** scaled ingredient_name should return Japanese translation
**AND** scaling logic works identically for translated vs non-translated fields

---

## Edge Cases & Error Handling

### AC-PHASE4-EDGE-001: Reading Empty String Translation
**GIVEN** recipe_ingredient with preparation_notes = ""
**WHEN** recipe_ingredient.preparation_notes is accessed
**THEN** empty string should be returned (not treated as missing)
**AND** serializer should include empty string (or omit if design specifies)

### AC-PHASE4-EDGE-002: Switching Locale Mid-Record Edit
**GIVEN** recipe with I18n.locale = :en, recipe.name = "Recipe" is assigned but not saved
**WHEN** I18n.locale is switched to :ja
**AND** recipe.name is accessed before save
**THEN** nil should be returned (in-memory en translation not persisted to ja)
**AND** unsaved en changes should remain in memory (if reassigning recipe.name back to en)

### AC-PHASE4-EDGE-003: Fallback Locale Doesn't Match Any Locale
**GIVEN** recipe with translations only in zh-cn
**WHEN** I18n.locale = :ja (fallback: ja→en)
**AND** recipe.name is accessed
**THEN** English translation should be returned (final fallback)
**AND** if no English translation exists, nil should be returned

### AC-PHASE4-EDGE-004: Updating Record After Locale Switch
**GIVEN** recipe with en translation, I18n.locale = :en, recipe.save
**WHEN** I18n.locale switched to :ja without saving
**AND** recipe.name = "新しいレシピ" is assigned
**AND** recipe.save is called
**THEN** ja translation should be created
**AND** en translation should remain unchanged

### AC-PHASE4-EDGE-005: Mass Assignment with Translated Fields
**GIVEN** recipe with name translatable
**WHEN** Recipe.create!(name: "Curry", cuisine: "Indian") with I18n.locale = :en
**THEN** recipe should be created with en translation for name
**AND** cuisine (non-translated) should be assigned normally

### AC-PHASE4-EDGE-006: Nil Fallback Handling
**GIVEN** recipe with no translation in any locale (completely untranslated)
**WHEN** recipe.name is accessed in any locale
**THEN** nil should be returned
**AND** reading nil multiple times should be consistent

### AC-PHASE4-EDGE-007: Translation Deletion vs Null Storage
**GIVEN** recipe with translation value = "Recipe Name"
**WHEN** I18n.with_locale(:en) { recipe.name = nil; recipe.save }
**THEN** translation record should exist with null value (not deleted)
**AND** accessing recipe.name should return nil
**AND** translation record should be retrievable if needed for audit purposes

### AC-PHASE4-EDGE-008: Invalid Locale Handling
**GIVEN** I18n.locale set to invalid/unsupported locale :xx (not in fallback chain)
**WHEN** translated field is accessed
**THEN** fallback chain should be used (default locale en)
**AND** no error should be raised
**AND** English translation should be returned

### AC-PHASE4-EDGE-009: Circular Fallback Chain Detection
**GIVEN** fallback chain configured with circular reference (ja→en→ja)
**WHEN** translation is accessed in ja locale
**THEN** system should not enter infinite loop
**AND** should return translation or nil (without hang)

### AC-PHASE4-EDGE-010: Concurrent Translation Updates
**GIVEN** recipe with translation value = "Original Name"
**WHEN** two concurrent requests both update translation to different values
**AND** both requests call recipe.save simultaneously
**THEN** one update should succeed and be persisted
**AND** database should be in consistent state (no corruption)
**AND** last-write-wins or explicit locking should prevent data loss

### AC-PHASE4-EDGE-011: Batch Translation Updates
**GIVEN** 100 recipes in database
**WHEN** batch job updates translations for all recipes with I18n.locale = :ja
**AND** all recipes.save is called
**THEN** all 100 translations should persist correctly
**AND** no translation records should be skipped or partially saved

### AC-PHASE4-EDGE-012: Validation Failure Prevents Translation Save
**GIVEN** recipe with presence validation on name
**WHEN** recipe.name = nil is assigned in any locale
**AND** recipe.save is called
**THEN** save should fail
**AND** translation record should NOT be created
**AND** recipe.errors[:name] should include validation message

---

## Compatibility with Existing Features

### AC-PHASE4-COMPAT-001: Translations Don't Break Existing Serializers
**GIVEN** RecipeSerializer with existing fields (id, cuisine, servings, etc.)
**WHEN** translates :name is added to Recipe
**THEN** existing serializer should continue to work without modification
**AND** serializer should return translated name based on I18n.locale
**AND** all existing fields should serialize identically

### AC-PHASE4-COMPAT-002: Translations Work with Existing Validations
**GIVEN** Recipe with `validates :name, presence: true, uniqueness: true`
**WHEN** translates :name is added
**THEN** presence validation should work on translated field
**AND** existing validations should not conflict with Mobility
**AND** migration should preserve existing name data as en translation

### AC-PHASE4-COMPAT-003: Admin Panel Recipes Still Create Correctly
**GIVEN** admin submitting recipe via POST /admin/recipes
**WHEN** RecipeParserService creates recipe with translations
**AND** translations are saved to translation table
**THEN** recipe should be visible in admin panel
**AND** admin should be able to edit translations in interface

### AC-PHASE4-COMPAT-004: API Backward Compatibility with Locale Headers
**GIVEN** existing API clients that send Accept-Language headers
**WHEN** API receives ja Accept-Language header
**AND** I18n.locale is set from header
**THEN** API response should automatically return Japanese translations
**AND** clients using default en locale should continue working unchanged

---

## Database & Performance

### AC-PHASE4-DB-001: Translation Table Uniqueness Constraint
**GIVEN** recipe with translation for name in en locale
**WHEN** attempting to create duplicate translation (same recipe_id, locale, key)
**THEN** database should prevent duplicate via composite unique constraint
**AND** ActiveRecord should raise validation error on save
**AND** same translation value for different recipe or locale should succeed

### AC-PHASE4-DB-002: Migration Preserves Existing Name Data
**GIVEN** recipes with existing name column values
**WHEN** migration is run to add translates :name
**THEN** existing recipe names should be copied to translation table as en locale
**AND** original name column should remain (for backward compatibility until removal in later phase)
**AND** no data loss should occur

### AC-PHASE4-DB-003: Translation Records Cascade Delete
**GIVEN** recipe with translations in translation table
**WHEN** recipe is deleted
**THEN** all translation records for that recipe should be deleted
**AND** dependent: :destroy should be configured on Recipe translates declaration

### AC-PHASE4-DB-004: Eager Loading Translations
**GIVEN** 10 recipes to be serialized with translations
**WHEN** Recipe.includes(:translations) is queried (or automatic via Mobility)
**THEN** should use single or minimal queries to load all translations
**AND** N+1 query problem should not occur

### AC-PHASE4-DB-005: Migration Rollback Preserves Data
**GIVEN** recipes with existing name column values
**WHEN** migration copies names to translation table as en locale
**AND** migration fails or is rolled back mid-process
**THEN** original recipe name column values should be intact
**AND** no partial translation records should remain
**AND** database should be in consistent state (no orphaned records)

---

## Summary

- **Total Phase 4 ACs:** 63
- **Configuration:** 4 ACs
- **Model Declarations:** 6 ACs
- **Reading Translations:** 6 ACs
- **Writing Translations:** 6 ACs (includes AC-PHASE4-WRITE-003B: No Duplicate Records)
- **Querying Translated Fields:** 5 ACs
- **Validation & Constraints:** 4 ACs
- **Serialization:** 5 ACs (includes AC-PHASE4-SERIAL-005: Partial Translations)
- **Service Integration:** 3 ACs
- **Edge Cases:** 12 ACs (includes new edge cases for deletion, invalid locale, concurrent updates, batch updates, validation failure)
- **Compatibility:** 4 ACs
- **Database & Performance:** 5 ACs (includes AC-PHASE4-DB-005: Migration Rollback)

All ACs ensure Mobility gem integration provides seamless multi-language support across core models while maintaining backward compatibility with existing API responses, validations, and serializers. Revised ACs address critical implementation gaps and edge cases identified during quality review.
