# Recipe Database Re-Architecture - Acceptance Criteria

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
**THEN** the create should fail with a position uniqueness validation error
**AND** the database should not insert the duplicate record

##### AC-PHASE2-STEP6-002: IngredientGroup Position Uniqueness Scope
**GIVEN** a recipe with an ingredient_group at position 1
**AND** another recipe with an ingredient_group at position 1
**WHEN** querying ingredient_groups
**THEN** both records should exist (position uniqueness is scoped to recipe_id)

##### AC-PHASE2-STEP6-003: RecipeStep StepNumber Uniqueness Validation
**GIVEN** a recipe with a recipe_step at step_number 1
**WHEN** attempting to create another recipe_step for the same recipe at step_number 1
**THEN** the create should fail with a step_number uniqueness validation error
**AND** the database should not insert the duplicate record

##### AC-PHASE2-STEP6-004: RecipeStep StepNumber Uniqueness Scope
**GIVEN** a recipe with a recipe_step at step_number 1
**AND** another recipe with a recipe_step at step_number 1
**WHEN** querying recipe_steps
**THEN** both records should exist (step_number uniqueness is scoped to recipe_id)

#### Nested Attributes Integration Tests

##### AC-PHASE2-STEP6-005: Create Recipe with Nested IngredientGroups
**GIVEN** a recipe is being created with nested ingredient_groups_attributes
**WHEN** the recipe attributes include:
  - ingredient_groups with name, position, and recipe_ingredients_attributes
  - recipe_ingredients with ingredient_name, amount, unit, position
**THEN** the recipe should be persisted successfully
**AND** all ingredient_groups should be created and belong to the recipe
**AND** all recipe_ingredients should be created and belong to their respective ingredient_groups

##### AC-PHASE2-STEP6-006: Create Recipe with Nested RecipeSteps
**GIVEN** a recipe is being created with nested recipe_steps_attributes
**WHEN** the recipe attributes include recipe_steps with step_number, instruction_original, instruction_easier, instruction_no_equipment
**THEN** the recipe should be persisted successfully
**AND** all recipe_steps should be created and belong to the recipe
**AND** each step's instructions should be persisted as provided

##### AC-PHASE2-STEP6-007: Reject Empty Nested Attributes
**GIVEN** a recipe is being created with empty nested attribute hashes
**WHEN** ingredient_groups_attributes contains an empty hash {}
**THEN** the empty ingredient_group should NOT be created
**AND** the recipe should still be created successfully (if other attributes are valid)
**AND** no record with nil name/position should exist in the database

##### AC-PHASE2-STEP6-008a: Update Existing Nested IngredientGroup
**GIVEN** a recipe exists with an ingredient_group named "Group A" at position 1
**WHEN** the recipe is updated with ingredient_groups_attributes containing the group's id and updated name "Group B"
**THEN** the ingredient_group name should be updated to "Group B"
**AND** all associations should remain intact

##### AC-PHASE2-STEP6-008b: Add New Nested IngredientGroup During Update
**GIVEN** a recipe exists with one ingredient_group at position 1
**WHEN** the recipe is updated with ingredient_groups_attributes containing a new group without id and position 2
**THEN** the new ingredient_group should be created and added to the recipe
**AND** the recipe should have 2 ingredient_groups after update

##### AC-PHASE2-STEP6-008c: Delete Nested IngredientGroup Using _destroy Flag
**GIVEN** a recipe exists with two ingredient_groups
**WHEN** the recipe is updated with ingredient_groups_attributes containing one group's id and _destroy: true
**THEN** the ingredient_group should be deleted from the database
**AND** the recipe should have one ingredient_group remaining
**AND** the deleted group's recipe_ingredients should also be deleted (cascade)

##### AC-PHASE2-STEP6-009: Nested Attribute Validation Error Propagation on Create
**GIVEN** a recipe is being created with nested ingredient_groups and recipe_ingredients
**WHEN** a recipe_ingredient in the 2nd ingredient_group has no ingredient_name
**THEN** the entire recipe creation should fail (transaction rollback)
**AND** no recipe, ingredient_groups, or recipe_ingredients should be persisted
**AND** the error response should indicate which nested record failed validation

#### Phase 2 Acceptance Criteria Test Coverage

##### AC-PHASE2-STEP6-010: RSpec Model Tests for Constraint Validations
**GIVEN** RSpec model tests exist for IngredientGroup and RecipeStep constraints
**WHEN** running the model test suite
**THEN** tests verify position uniqueness within recipe_id scope
**AND** tests verify step_number uniqueness within recipe_id scope
**AND** tests verify position and step_number numericality validations
**AND** all tests pass with 100% line coverage for constraint validation logic

##### AC-PHASE2-STEP6-011: RSpec Integration Tests for Nested Attributes
**GIVEN** RSpec integration tests exist for Recipe nested attribute operations
**WHEN** running the integration test suite for nested attributes
**THEN** tests verify successful creation of recipe with nested ingredient_groups and recipe_steps
**AND** tests verify successful update of existing nested records
**AND** tests verify successful deletion of nested records with _destroy flag
**AND** tests verify reject_if clauses prevent empty record creation
**AND** tests verify validation error propagation from nested records
**AND** all tests pass with 100% coverage for nested attribute operations

##### AC-PHASE2-STEP6-012: Step 6 Edge Case and Boundary Tests
**GIVEN** RSpec tests exist for edge cases in constraint and nested attribute handling
**WHEN** running edge case test suite
**THEN** tests verify rejection of nil/blank position and step_number values
**AND** tests verify rejection of zero and negative position/step_number values
**AND** tests verify cascade deletion of nested records when parent is deleted
**AND** tests verify transaction rollback when nested validation fails
**AND** tests verify ordering of ingredient_groups by position
**AND** tests verify ordering of recipe_steps by step_number
**AND** all tests pass

#### Additional Edge Case and Boundary Tests

##### AC-PHASE2-STEP6-013: Reject IngredientGroup with Nil Position
**GIVEN** a recipe exists
**WHEN** attempting to create an ingredient_group without a position value
**THEN** the create should fail with a presence validation error
**AND** the database should not insert the record

##### AC-PHASE2-STEP6-014: Reject IngredientGroup with Invalid Position Values
**GIVEN** a recipe exists
**WHEN** attempting to create an ingredient_group with position 0 or negative
**THEN** the create should fail with a numericality validation error
**AND** the database should not insert the record

##### AC-PHASE2-STEP6-015: Reject RecipeStep with Invalid Step Number Values
**GIVEN** a recipe exists
**WHEN** attempting to create a recipe_step with step_number 0 or negative
**THEN** the create should fail with a numericality validation error
**AND** the database should not insert the record

##### AC-PHASE2-STEP6-016: Database Constraint Prevents Duplicate Positions
**GIVEN** a recipe with an ingredient_group at position 1
**WHEN** attempting to insert a duplicate position at the database level (bypassing Rails)
**THEN** the database should reject the insert with a unique constraint violation
**AND** no duplicate record exists in the database

##### AC-PHASE2-STEP6-017: Cascade Delete IngredientGroups When Recipe Deleted
**GIVEN** a recipe exists with 2 ingredient_groups, each with 3 recipe_ingredients
**WHEN** the recipe is deleted
**THEN** all 2 ingredient_groups should also be deleted
**AND** all 6 recipe_ingredients should also be deleted
**AND** no orphaned records remain in the database

##### AC-PHASE2-STEP6-018: Cascade Delete RecipeSteps When Recipe Deleted
**GIVEN** a recipe exists with 5 recipe_steps
**WHEN** the recipe is deleted
**THEN** all 5 recipe_steps should also be deleted
**AND** no orphaned recipe_steps remain

##### AC-PHASE2-STEP6-019: Position Gaps are Allowed After Deletion
**GIVEN** a recipe has ingredient_groups at positions 1, 2, 3
**WHEN** the ingredient_group at position 2 is deleted
**THEN** ingredient_groups at positions 1 and 3 should remain unchanged
**AND** no automatic re-numbering occurs
**AND** gaps in position sequence are allowed

##### AC-PHASE2-STEP6-020: IngredientGroups Returned in Position Order
**GIVEN** a recipe has ingredient_groups created at positions 3, 1, 2 (in that creation order)
**WHEN** retrieving the recipe's ingredient_groups
**THEN** they are returned in position order: 1, 2, 3
**AND** the order matches the model's order scope definition

##### AC-PHASE2-STEP6-021: RecipeSteps Returned in Step Number Order
**GIVEN** a recipe has recipe_steps created with step_numbers 3, 1, 2 (in that creation order)
**WHEN** retrieving the recipe's recipe_steps
**THEN** they are returned in step_number order: 1, 2, 3
**AND** the order is consistent across multiple queries

##### AC-PHASE2-STEP6-022: Update IngredientGroup Position to Duplicate Value Fails
**GIVEN** a recipe has ingredient_groups at positions 1 and 2
**WHEN** attempting to update the group at position 2 to position 1
**THEN** the update should fail with a position uniqueness validation error
**AND** the position remains 2 (no change persisted)

##### AC-PHASE2-STEP6-023: Update RecipeStep Number to Duplicate Value Fails
**GIVEN** a recipe has recipe_steps with step_numbers 1 and 2
**WHEN** attempting to update the step with step_number 2 to step_number 1
**THEN** the update should fail with a step_number uniqueness validation error
**AND** the step_number remains 2 (no change persisted)

##### AC-PHASE2-STEP6-024: Whitespace-Only Ingredient Names are Rejected
**GIVEN** a recipe is being created with nested ingredient_groups
**WHEN** a recipe_ingredient has ingredient_name with only whitespace
**THEN** the ingredient should be rejected during validation
**AND** the ingredient_group should still be created (if other attributes valid)
**AND** no whitespace-only ingredient records exist in database

##### AC-PHASE2-STEP6-025: Nested Transaction Rollback on Validation Failure
**GIVEN** a recipe is being created with 3 ingredient_groups with 2 ingredients each
**WHEN** the 2nd ingredient_group's 1st ingredient has invalid data (missing ingredient_name)
**THEN** the entire recipe creation should fail (transaction rollback)
**AND** no recipe should be persisted
**AND** no ingredient_groups should be persisted
**AND** no recipe_ingredients should be persisted
**AND** the database state is unchanged from before the operation

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

### AC-PHASE7-001: Recipe List View - Display New API Response Fields
**GIVEN** frontend receives API response with new fields (translations_completed, last_translated_at, dietary_tags array)
**WHEN** recipe list is rendered
**THEN** recipe names, servings, and timing information should be visible to user
**AND** dietary_tags should be displayed as a list
**AND** pagination controls should be visible and functional
**AND** no errors should occur during rendering

### AC-PHASE7-002: Recipe Detail View - Display Ingredient Groups Structure
**GIVEN** frontend receives recipe detail API response with ingredient_groups array
**WHEN** ingredients section is rendered
**THEN** ingredients should be grouped by ingredient_group.name
**AND** within each group, items should display: name, amount, unit, preparation notes
**AND** optional ingredients should be marked as optional
**AND** all information should be visible without scrolling errors

### AC-PHASE7-003: Recipe Detail View - Display Recipe Steps
**GIVEN** frontend receives recipe detail API response with recipe_steps array
**WHEN** steps section is rendered
**THEN** steps should display in order by step_number (1, 2, 3, etc.)
**AND** each step should show: step number, instruction text
**AND** steps with null/missing instructions should display a placeholder instead of breaking the UI

### AC-PHASE7-004: Recipe Detail View - Display Equipment and Tags
**GIVEN** frontend receives recipe detail API response with equipment, dietary_tags, cuisines, dish_types, recipe_types arrays
**WHEN** recipe metadata section is rendered
**THEN** equipment should be visible as a list
**AND** dietary_tags should be visible as tags/badges
**AND** cuisines should be visible as tags/badges
**AND** dish_types should be visible as tags/badges
**AND** recipe_types should be visible as tags/badges
**AND** empty arrays should display gracefully (no errors, empty state clear to user)

### AC-PHASE7-005A: Language Parameter - Explicit Locale in Query String
**GIVEN** frontend has language selection (en, ja, ko, zh-tw, zh-cn, es, fr)
**WHEN** user selects a language and API call is made to getRecipes() or getRecipe()
**THEN** query parameter ?lang=<selected_language> should be included in request
**AND** API should return response in selected language
**AND** no error should occur due to language parameter

### AC-PHASE7-005B: Language Parameter - Accept-Language Header Fallback
**GIVEN** frontend does not have explicit ?lang parameter set
**WHEN** API call is made
**THEN** Accept-Language header should be sent in HTTP request
**AND** header format should follow RFC 7231 (e.g., "en-US,en;q=0.9,ja;q=0.8")
**AND** API should interpret header and return appropriate language translation

### AC-PHASE7-006: Language Switching - Refetch with New Language
**GIVEN** user is viewing a recipe in English (en)
**WHEN** user switches language to Japanese (ja) via language switcher
**THEN** API should be called with ?lang=ja parameter
**AND** component state should update with Japanese translation data
**AND** page should re-render with recipe name, ingredients, steps, and tags in Japanese
**AND** no loading errors should occur during language switch

### AC-PHASE7-007: List View Filtering and Search - Works with New API
**GIVEN** frontend has search and filter functionality (name search, dietary_tags filter, etc.)
**WHEN** user performs search or filter
**THEN** API should be called with search/filter parameters
**AND** pagination should work correctly (total_count, current_page, per_page)
**AND** results should display with translations in current language
**AND** filtered results should update without errors

### AC-PHASE7-008: Type Safety - TypeScript Compilation Without Errors
**GIVEN** new API response structures with ingredient_groups, recipe_steps, etc.
**WHEN** TypeScript compiler runs on frontend code
**THEN** src/types.ts should compile without errors
**AND** RecipeList, RecipeDetail, IngredientGroup, RecipeStep component files should compile without type errors
**AND** types should include new fields: translations_completed, last_translated_at

### AC-PHASE7-009: Error Handling - API Failures Handled Gracefully
**GIVEN** API returns error response (400, 500) or request times out
**WHEN** recipe list or detail page attempts to load data
**THEN** user-friendly error message should be displayed (e.g., "Failed to load recipes. Please try again.")
**AND** UI should not crash or show broken layout
**AND** user should be able to retry the operation

### AC-PHASE7-010: Multi-Language Support - All 7 Languages Render Correctly
**GIVEN** backend returns translations in all 7 languages (en, ja, ko, zh-tw, zh-cn, es, fr)
**WHEN** user selects each language
**THEN** recipe names should display in selected language
**AND** ingredient names should display in selected language
**AND** recipe steps should display in selected language
**AND** tags (dietary, cuisines, dish types) should display in selected language
**AND** Japanese and Chinese special characters should render correctly without encoding issues

### AC-PHASE7-011: Language Parameter in Pagination
**GIVEN** user is viewing page 2 of recipes in English (en)
**WHEN** user switches language to Japanese (ja)
**THEN** API should be called with both ?lang=ja and ?page=2 parameters
**AND** results should display page 2 of recipes in Japanese
**AND** pagination state (current page, per page) should be maintained

### AC-PHASE7-012: Recipe Scaling with Language Support
**GIVEN** user is viewing a recipe in a non-English language (e.g., ja for Japanese)
**WHEN** user scales the recipe to a different serving size
**THEN** API should be called to scale ingredients
**AND** scaled ingredient amounts should display in the current language
**AND** no language switching should occur during scaling operation
**AND** scaled values should be accurate and readable

---

**End of Re-Architecture Acceptance Criteria**
