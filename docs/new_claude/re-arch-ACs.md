# Recipe Database Re-Architecture - Acceptance Criteria

**Project**: Database Schema Normalization + Mobility i18n Integration
**Version**: 1.0
**Status**: Draft

---

## Table of Contents

1. [Phase 1: Database Schema Normalization](#phase-1-database-schema-normalization)
2. [Phase 2: API Endpoints with Normalized Schema](#phase-2-api-endpoints-with-normalized-schema)
3. [Phase 3: Model Validations](#phase-3-model-validations)
4. [Phase 4: Mobility Translation System](#phase-4-mobility-translation-system)
5. [Phase 5: Translation Jobs and Background Processing](#phase-5-translation-jobs-and-background-processing)
6. [Phase 6: Locale-Aware API Responses](#phase-6-locale-aware-api-responses)
7. [Phase 7: Frontend Integration](#phase-7-frontend-integration)

---

## Phase 1: Database Schema Normalization

### AC-PHASE1-001: Recipes Table - New Columns Added
**GIVEN** a database migration is executed
**WHEN** recipes table is inspected
**THEN** should have new columns: servings_original, servings_min, servings_max, prep_minutes, cook_minutes, total_minutes, source_language, translation_status
**AND** source_language should have default value "en"
**AND** translation_status should be JSONB type with default {}

### AC-PHASE1-002: Recipes Table - Old JSONB Columns Dropped
**GIVEN** a database migration is executed
**WHEN** recipes table is inspected
**THEN** should NOT have columns: language, servings, timing, aliases, dietary_tags, dish_types, recipe_types, cuisines, ingredient_groups, steps, equipment, translations, translations_completed

### AC-PHASE1-003: IngredientGroup Table Created
**GIVEN** a database migration is executed
**WHEN** ingredient_groups table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), name (string), position (integer), created_at, updated_at
**AND** should have unique index on (recipe_id, position)
**AND** should have foreign key constraint to recipes table with ON DELETE CASCADE

### AC-PHASE1-004: RecipeIngredient Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_ingredients table is inspected
**THEN** should have columns: id (uuid), ingredient_group_id (uuid), ingredient_id (uuid, nullable), ingredient_name (string), amount (decimal), unit (string), preparation_notes (text), optional (boolean), position (integer), created_at, updated_at
**AND** should have unique index on (ingredient_group_id, position)
**AND** should have foreign keys to ingredient_groups and ingredients tables
**AND** ingredient_id foreign key should have ON DELETE NULLIFY

### AC-PHASE1-005: RecipeStep Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_steps table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), step_number (integer), timing_minutes (integer), instruction_original (text), instruction_easier (text), instruction_no_equipment (text), created_at, updated_at
**AND** should have unique index on (recipe_id, step_number)
**AND** should have foreign key constraint to recipes table with ON DELETE CASCADE

### AC-PHASE1-006: Equipment Table Created
**GIVEN** a database migration is executed
**WHEN** equipment table is inspected
**THEN** should have columns: id (uuid), canonical_name (string), created_at, updated_at
**AND** should have unique index on canonical_name

### AC-PHASE1-007: RecipeEquipment Join Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_equipment table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), equipment_id (uuid), optional (boolean), created_at
**AND** should have unique index on (recipe_id, equipment_id)
**AND** should have foreign keys to recipes and equipment tables with ON DELETE CASCADE

### AC-PHASE1-008: RecipeDietaryTag Join Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_dietary_tags table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), data_reference_id (uuid), created_at
**AND** should have unique index on (recipe_id, data_reference_id)
**AND** should have foreign keys to recipes and data_references tables with ON DELETE CASCADE

### AC-PHASE1-009: RecipeDishType Join Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_dish_types table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), data_reference_id (uuid), created_at
**AND** should have unique index on (recipe_id, data_reference_id)
**AND** should have foreign keys to recipes and data_references tables with ON DELETE CASCADE

### AC-PHASE1-010: RecipeRecipeType Join Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_recipe_types table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), data_reference_id (uuid), created_at
**AND** should have unique index on (recipe_id, data_reference_id)
**AND** should have foreign keys to recipes and data_references tables with ON DELETE CASCADE

### AC-PHASE1-011: RecipeCuisine Join Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_cuisines table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), data_reference_id (uuid), created_at
**AND** should have unique index on (recipe_id, data_reference_id)
**AND** should have foreign keys to recipes and data_references tables with ON DELETE CASCADE

### AC-PHASE1-012: RecipeAlias Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_aliases table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), alias_name (string), language (string), created_at
**AND** should have unique index on (recipe_id, alias_name, language)
**AND** should have foreign key constraint to recipes table with ON DELETE CASCADE

### AC-PHASE1-013: RecipeNutrition Table Created
**GIVEN** a database migration is executed
**WHEN** recipe_nutrition table is inspected
**THEN** should have columns: id (uuid), recipe_id (uuid), calories (decimal), protein_g (decimal), carbs_g (decimal), fat_g (decimal), fiber_g (decimal), sodium_mg (decimal), sugar_g (decimal), created_at, updated_at
**AND** should have unique index on recipe_id
**AND** should have foreign key constraint to recipes table with ON DELETE CASCADE

### AC-PHASE1-014: Seeds Run Successfully
**GIVEN** database migration is applied
**WHEN** rails db:seed is executed
**THEN** should create 14 test recipes using new schema
**AND** each recipe should have ingredient_groups with recipe_ingredients
**AND** each recipe should have recipe_steps
**AND** each recipe should have recipe_dietary_tags, recipe_dish_types, recipe_recipe_types, recipe_cuisines associations
**AND** some recipes should have recipe_equipment associations
**AND** some recipes should have recipe_nutrition data
**AND** no errors should be raised

### AC-PHASE1-015: Recipe Model Has Correct Associations
**GIVEN** Recipe model is loaded
**WHEN** inspecting model associations
**THEN** should have: has_many :ingredient_groups (dependent: destroy)
**AND** has_many :recipe_steps (dependent: destroy)
**AND** has_many :recipe_equipment (dependent: destroy)
**AND** has_many :equipment through :recipe_equipment
**AND** has_many :recipe_dietary_tags (dependent: destroy)
**AND** has_many :dietary_tags through :recipe_dietary_tags
**AND** has_many :recipe_dish_types (dependent: destroy)
**AND** has_many :recipe_cuisines (dependent: destroy)
**AND** has_many :recipe_recipe_types (dependent: destroy)
**AND** has_many :recipe_aliases (dependent: destroy)
**AND** has_one :recipe_nutrition (dependent: destroy)

### AC-PHASE1-016: IngredientGroup Model Has Correct Associations
**GIVEN** IngredientGroup model is loaded
**WHEN** inspecting model associations
**THEN** should have: belongs_to :recipe
**AND** has_many :recipe_ingredients (dependent: destroy)

### AC-PHASE1-017: RecipeIngredient Model Has Correct Associations
**GIVEN** RecipeIngredient model is loaded
**WHEN** inspecting model associations
**THEN** should have: belongs_to :ingredient_group
**AND** belongs_to :ingredient (optional: true)

### AC-PHASE1-018: RecipeStep Model Has Correct Associations
**GIVEN** RecipeStep model is loaded
**WHEN** inspecting model associations
**THEN** should have: belongs_to :recipe

### AC-PHASE1-019: Equipment Model Has Correct Associations
**GIVEN** Equipment model is loaded
**WHEN** inspecting model associations
**THEN** should have: has_many :recipe_equipment
**AND** has_many :recipes through :recipe_equipment

### AC-PHASE1-020: Data Integrity - No Orphaned Records
**GIVEN** a recipe is deleted
**WHEN** database is queried
**THEN** all associated ingredient_groups, recipe_ingredients, recipe_steps, recipe_equipment, recipe_dietary_tags, recipe_dish_types, recipe_recipe_types, recipe_cuisines, recipe_aliases, recipe_nutrition records should also be deleted (CASCADE)
**AND** no orphaned records should exist

---

## Phase 2: API Endpoints with Normalized Schema

### Step 6 ACs: Model Constraints and Test Coverage

#### Model Constraint Tests

##### AC-PHASE2-STEP6-001: IngredientGroup Position Uniqueness Validation
**GIVEN** a recipe with an ingredient_group at position 1
**WHEN** attempting to create another ingredient_group for the same recipe at position 1
**THEN** the create should fail with validation error "Position has already been taken"
**AND** the database should not insert the duplicate record

##### AC-PHASE2-STEP6-002: IngredientGroup Position Uniqueness Scope
**GIVEN** a recipe with an ingredient_group at position 1
**AND** another recipe with an ingredient_group at position 1
**WHEN** querying ingredient_groups
**THEN** both records should exist (position uniqueness is scoped to recipe_id)

##### AC-PHASE2-STEP6-003: RecipeStep StepNumber Uniqueness Validation
**GIVEN** a recipe with a recipe_step at step_number 1
**WHEN** attempting to create another recipe_step for the same recipe at step_number 1
**THEN** the create should fail with validation error "Step number has already been taken"
**AND** the database should not insert the duplicate record

##### AC-PHASE2-STEP6-004: RecipeStep StepNumber Uniqueness Scope
**GIVEN** a recipe with a recipe_step at step_number 1
**AND** another recipe with a recipe_step at step_number 1
**WHEN** querying recipe_steps
**THEN** both records should exist (step_number uniqueness is scoped to recipe_id)

#### Nested Attributes Integration Tests

##### AC-PHASE2-STEP6-005: Create Recipe with Nested IngredientGroups
**GIVEN** a POST request to /admin/recipes with nested ingredient_groups_attributes
**WHEN** the request includes:
  - ingredient_groups_attributes with name, position, and recipe_ingredients_attributes
  - recipe_ingredients_attributes with ingredient_name, amount, unit, position
**THEN** the recipe should be created successfully
**AND** all ingredient_groups should be created with correct associations
**AND** all recipe_ingredients should be created with correct parent relationships

##### AC-PHASE2-STEP6-006: Create Recipe with Nested RecipeSteps
**GIVEN** a POST request to /admin/recipes with nested recipe_steps_attributes
**WHEN** the request includes recipe_steps_attributes with step_number, instruction_original, instruction_easier, instruction_no_equipment
**THEN** the recipe should be created successfully
**AND** all recipe_steps should be created with correct step_number and instructions

##### AC-PHASE2-STEP6-007: Reject Empty Nested Attributes
**GIVEN** a POST request to /admin/recipes with empty nested attribute hashes {}
**WHEN** the request includes ingredient_groups_attributes: [{}]
**THEN** the empty record should NOT be created (reject_if clause prevents it)
**AND** the recipe should be created with no ingredient_groups

##### AC-PHASE2-STEP6-008: Update Recipe with Nested Attributes
**GIVEN** a PUT request to /admin/recipes/:id with nested ingredient_groups_attributes
**WHEN** the request includes:
  - existing ingredient_group with updated name
  - new ingredient_group_attributes to add
  - ingredient_group with _destroy: true to delete
**THEN** existing records should be updated
**AND** new records should be created
**AND** destroyed records should be deleted from database

##### AC-PHASE2-STEP6-009: Nested Attribute Validation Error Propagation
**GIVEN** a POST request to /admin/recipes with nested ingredient_groups_attributes
**WHEN** recipe_ingredients_attributes has missing ingredient_name
**THEN** the create should fail
**AND** error response should include nested error message indicating which ingredient failed

#### Phase 2 Acceptance Criteria Test Coverage

##### AC-PHASE2-STEP6-010: All Phase 2 API Endpoint Tests Passing
**GIVEN** RSpec tests are written for Phase 2 acceptance criteria
**WHEN** tests cover:
  - API endpoint responses (GET /recipes, GET /recipes/:id, POST /recipes/:id/scale, etc.)
  - Serializer response format (servings hash, timing hash, ingredient_groups array, steps array)
  - Backward compatibility of API responses
  - Filter and search functionality
**THEN** all tests should pass
**AND** code coverage report should show >95% coverage for modified files

##### AC-PHASE2-STEP6-011: Service Layer Tests for Normalized Schema
**GIVEN** RSpec tests are written for services using normalized schema
**WHEN** tests cover:
  - RecipeScaler scaling with normalized servings and ingredient_groups
  - RecipeSearchService filtering by normalized associations
  - RecipeParserService returning normalized structure
  - RecipeTranslator working with associations
  - StepVariantGenerator using recipe_steps association
**THEN** all tests should pass

##### AC-PHASE2-STEP6-012: Error Handling Tests
**GIVEN** tests for error scenarios
**WHEN** tests cover:
  - Invalid servings (below min, above max)
  - Missing required fields in nested attributes
  - Validation failures in nested records
  - Database constraint violations
**THEN** all error handling tests should pass
**AND** error messages should be clear and actionable

---

## Phase 3: Model Validations

*ACs to be written in Phase 3*

---

## Phase 4: Mobility Translation System

*ACs to be written in Phase 4*

---

## Phase 5: Translation Jobs and Background Processing

*ACs to be written in Phase 5*

---

## Phase 6: Locale-Aware API Responses

*ACs to be written in Phase 6*

---

## Phase 7: Frontend Integration

*ACs to be written in Phase 7*

---

**End of Re-Architecture Acceptance Criteria**
