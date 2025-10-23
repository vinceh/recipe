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
