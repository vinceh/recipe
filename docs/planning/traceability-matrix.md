# Recipe App - Traceability Matrix

**Author:** V (with Winston, Architect Agent)
**Date:** 2025-10-07
**Version:** 1.0
**Status:** Draft

---

## Purpose

This traceability matrix maps PRD requirements to acceptance criteria, technical components, implementation files, and test coverage. It enables:

1. **Completeness Verification** - Ensure all requirements are implemented
2. **Gap Analysis** - Identify missing implementations or tests
3. **Impact Analysis** - Understand which code is affected by requirement changes
4. **Progress Tracking** - Monitor implementation status across the MVP

---

## How to Use This Matrix

- **PRD Req ID**: Functional requirement from PRD (FR1, FR2, etc.)
- **AC ID**: Acceptance criteria ID (AC-SCALE-001, etc.)
- **Component**: Service, job, model, or controller responsible
- **Implementation File**: Path to code file
- **Test File**: Path to test file (RSpec or Vue test)
- **Status**: Not Started | In Progress | Implemented | Tested

---

## Matrix Legend

- ✅ **Implemented & Tested**
- 🟡 **Implemented, Not Tested**
- 🔵 **In Progress**
- ⚪ **Not Started**

---

## 1. Smart Scaling System (FR2)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-SCALE-001 | Scale by servings - basic proportional | RecipeScaler#scale_by_servings | app/services/recipe_scaler.rb:3993-3997 | spec/services/recipe_scaler_spec.rb:1754 | ⚪ |
| AC-SCALE-002 | Scale by servings - fractional scaling | RecipeScaler#scale_by_servings | app/services/recipe_scaler.rb:3993-3997 | spec/services/recipe_scaler_spec.rb:1760 | ⚪ |
| AC-SCALE-003 | Scale by ingredient - calculate factor | RecipeScaler#scale_by_ingredient | app/services/recipe_scaler.rb:3998-4011 | spec/services/recipe_scaler_spec.rb:1780 | ⚪ |
| AC-SCALE-004 | Context-aware precision - baking | RecipeScaler#preserve_precision | app/services/recipe_scaler.rb:4066-4075 | spec/services/recipe_scaler_spec.rb:1771 | ⚪ |
| AC-SCALE-005 | Context-aware precision - cooking | RecipeScaler#round_to_friendly_fraction | app/services/recipe_scaler.rb:4041-4064 | spec/services/recipe_scaler_spec.rb:1763 | ⚪ |
| AC-SCALE-006 | Unit step-down - tbsp to tsp | RecipeScaler#check_unit_step_down! | app/services/recipe_scaler.rb:4077-4092 | spec/services/recipe_scaler_spec.rb (missing) | ⚪ |
| AC-SCALE-007 | Unit step-down - cups to tbsp | RecipeScaler#check_unit_step_down! | app/services/recipe_scaler.rb:4077-4092 | spec/services/recipe_scaler_spec.rb (missing) | ⚪ |
| AC-SCALE-008 | Whole item rounding - eggs | WholeItemHandler.scale_whole_item | app/services/whole_item_handler.rb:4177 | spec/services/whole_item_handler_spec.rb (missing) | ⚪ |
| AC-SCALE-009 | Whole item rounding - baking | WholeItemHandler.scale_whole_item | app/services/whole_item_handler.rb:4182-4184 | spec/services/whole_item_handler_spec.rb (missing) | ⚪ |
| AC-SCALE-010 | Whole item omit - very small | WholeItemHandler.scale_whole_item | app/services/whole_item_handler.rb:4185-4187 | spec/services/whole_item_handler_spec.rb (missing) | ⚪ |
| AC-SCALE-011 | Nutrition recalculation | RecipeScaler#scale_all_ingredients | app/services/recipe_scaler.rb:4015-4027 | spec/services/recipe_scaler_spec.rb (missing) | ⚪ |
| AC-SCALE-012 | Real-time client-side scaling | scalingService.scaleRecipe | frontend/src/services/scalingService.js:4233 | frontend/tests/unit/scalingService.spec.js (missing) | ⚪ |

**Supporting Components:**
- UnitConverter.convert | app/services/unit_converter.rb:4117-4157
- Api::V1::RecipesController#scale | app/controllers/api/v1/recipes_controller.rb:4211-4227
- RecipeDetail.vue component | frontend/src/views/RecipeShow.vue
- ScalingControls.vue component | frontend/src/components/recipe/ScalingControls.vue

---

## 2. Step Instruction Variants (FR1 - partial)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-VARIANT-001 | Easier variant - simplify jargon | StepVariantGenerator#generate_easier_variant | app/services/step_variant_generator.rb:1979-2001 | spec/services/step_variant_generator_spec.rb (missing) | ⚪ |
| AC-VARIANT-002 | Easier variant - add time estimates | StepVariantGenerator (via AI prompt) | app/services/step_variant_generator.rb:1979-2001 | spec/services/step_variant_generator_spec.rb (missing) | ⚪ |
| AC-VARIANT-003 | Easier variant - add sensory cues | StepVariantGenerator (via AI prompt) | app/services/step_variant_generator.rb:1979-2001 | spec/services/step_variant_generator_spec.rb (missing) | ⚪ |
| AC-VARIANT-004 | No equipment - whisk substitution | StepVariantGenerator#generate_no_equipment_variant | app/services/step_variant_generator.rb:2003-2022 | spec/services/step_variant_generator_spec.rb (missing) | ⚪ |
| AC-VARIANT-005 | No equipment - food processor substitution | StepVariantGenerator#generate_no_equipment_variant | app/services/step_variant_generator.rb:2003-2022 | spec/services/step_variant_generator_spec.rb (missing) | ⚪ |
| AC-VARIANT-006 | No equipment - honest tradeoffs | StepVariantGenerator (via AI prompt) | app/services/step_variant_generator.rb:2003-2022 | spec/services/step_variant_generator_spec.rb (missing) | ⚪ |
| AC-VARIANT-007 | Variants pre-generated on save | GenerateStepVariantsJob | app/jobs/generate_step_variants_job.rb:2172-2196 | spec/jobs/generate_step_variants_job_spec.rb (missing) | ⚪ |
| AC-VARIANT-008 | User toggles variant per step | StepList.vue component | frontend/src/components/recipe/StepList.vue | frontend/tests/unit/StepList.spec.js (missing) | ⚪ |
| AC-VARIANT-009 | Variant selection persists | recipeStore (Pinia) | frontend/src/stores/recipeStore.js | frontend/tests/unit/recipeStore.spec.js (missing) | ⚪ |

**Supporting Components:**
- AiPrompt model | app/models/ai_prompt.rb:1014-1052
- AI prompts (DB seeds) | db/seeds.rb:1060-1196
- Recipe model callbacks | app/models/recipe.rb:2388-2403
- StepVariantToggle.vue | frontend/src/components/recipe/StepVariantToggle.vue

---

## 3. Multi-lingual Translation (FR3)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-TRANSLATE-001 | Pre-translation on save | TranslateRecipeJob | app/jobs/translate_recipe_job.rb:2198-2218 | spec/jobs/translate_recipe_job_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-002 | Cultural accuracy - native term | RecipeTranslator (via AI prompt) | app/services/recipe_translator.rb:2057-2100 | spec/services/recipe_translator_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-003 | Cultural accuracy - transliteration | RecipeTranslator (via AI prompt) | app/services/recipe_translator.rb:2057-2100 | spec/services/recipe_translator_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-004 | All text fields translated | RecipeTranslator#translate_recipe | app/services/recipe_translator.rb:2067-2085 | spec/services/recipe_translator_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-005 | Translation quality - step instructions | RecipeTranslator (via AI prompt) | app/services/recipe_translator.rb:2067-2085 | spec/services/recipe_translator_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-006 | Language selection persists | LanguageSelector.vue + uiStore | frontend/src/components/layout/LanguageSelector.vue:2342-2352 | frontend/tests/unit/LanguageSelector.spec.js (missing) | ⚪ |
| AC-TRANSLATE-007 | Fallback to original language | Api::V1::RecipesController#show | app/controllers/api/v1/recipes_controller.rb:2532-2568 | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-008 | API endpoint language parameter | Api::V1::RecipesController#show | app/controllers/api/v1/recipes_controller.rb:2532-2568 | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-TRANSLATE-009 | Translation status indicator | TranslationStatus.vue | frontend/src/components/recipe/TranslationStatus.vue:2613-2677 | frontend/tests/unit/TranslationStatus.spec.js (missing) | ⚪ |

**Supporting Components:**
- Recipe model callbacks | app/models/recipe.rb:2388-2403
- Translation prompts (DB) | db/seeds.rb:1148-1184
- uiStore (Pinia) | frontend/src/stores/uiStore.js:2575-2587
- recipeService.getRecipe | frontend/src/services/recipeService.js:2589-2595

---

## 4. Nutrition System (FR5)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-NUTR-001 | Lookup - database first | NutritionLookupService#lookup_ingredient | app/services/nutrition_lookup_service.rb:2843-2861 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-002 | Lookup - API fallback | NutritionLookupService#fetch_from_nutritionix | app/services/nutrition_lookup_service.rb:2908-2925 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-003 | Lookup - AI estimation fallback | NutritionLookupService#estimate_with_ai | app/services/nutrition_lookup_service.rb:2927-2946 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-004 | Fuzzy matching - exact match | NutritionLookupService#find_in_database | app/services/nutrition_lookup_service.rb:2865-2883 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-005 | Fuzzy matching - plural/singular | NutritionLookupService#normalize_ingredient_name | app/services/nutrition_lookup_service.rb:2978-2984 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-006 | Fuzzy matching - alias match | NutritionLookupService#find_in_database | app/services/nutrition_lookup_service.rb:2873-2878 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-007 | Fuzzy matching - Levenshtein | NutritionLookupService#fuzzy_match_ingredient | app/services/nutrition_lookup_service.rb:2885-2906 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-NUTR-008 | Recipe nutrition - per serving | RecipeNutritionCalculator#calculate | app/services/recipe_nutrition_calculator.rb:3084-3119 | spec/services/recipe_nutrition_calculator_spec.rb:1796 | ⚪ |
| AC-NUTR-009 | Unit conversion - volume to weight | RecipeNutritionCalculator#convert_to_grams | app/services/recipe_nutrition_calculator.rb:3144-3168 | spec/services/recipe_nutrition_calculator_spec.rb (missing) | ⚪ |
| AC-NUTR-010 | Nutrition display - all macros | NutritionInfo.vue | frontend/src/components/recipe/NutritionInfo.vue | frontend/tests/unit/NutritionInfo.spec.js (missing) | ⚪ |
| AC-NUTR-011 | Auto-update on scaling | RecipeDetail.vue computed property | frontend/src/views/RecipeShow.vue:3779-3783 | frontend/tests/unit/RecipeShow.spec.js (missing) | ⚪ |
| AC-NUTR-012 | Admin dashboard - statistics | Admin::IngredientsController#index | app/controllers/admin/ingredients_controller.rb (not in spec) | spec/requests/admin/ingredients_spec.rb (missing) | ⚪ |
| AC-NUTR-013 | Admin refresh from API | Admin::IngredientsController#refresh_nutrition | app/controllers/admin/ingredients_controller.rb (not in spec) | spec/requests/admin/ingredients_spec.rb (missing) | ⚪ |

**Supporting Components:**
- NutritionixClient | app/clients/nutritionix_client.rb:3018-3057
- NutritionLookupJob | app/jobs/nutrition_lookup_job.rb:3218-3243
- Ingredient model | app/models/ingredient.rb
- IngredientNutrition model | app/models/ingredient_nutrition.rb
- IngredientAlias model | app/models/ingredient_alias.rb
- Redis cache wrapper | config/initializers/redis.rb:3350-3356

---

## 5. Search & Filtering (FR4)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-SEARCH-001 | Fuzzy text search - recipe name | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb:1847 | ⚪ |
| AC-SEARCH-002 | Fuzzy text search - alias match | Recipe.search (scope) | app/models/recipe.rb | spec/models/recipe_spec.rb (missing) | ⚪ |
| AC-SEARCH-003 | Fuzzy text search - ingredient match | Recipe.search (scope) | app/models/recipe.rb | spec/models/recipe_spec.rb (missing) | ⚪ |
| AC-SEARCH-004 | Nutrition filter - calorie range | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-005 | Nutrition filter - protein minimum | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-006 | Nutrition filter - cal/protein ratio | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-007 | Dietary tag filter - single | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb:1855 | ⚪ |
| AC-SEARCH-008 | Dietary tag filter - multiple (AND) | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-009 | Cuisine filter - single | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-010 | Dish type filter | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-011 | Recipe type filter | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-012 | Cooking time filter - range | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-013 | Combined filters - AND logic | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb (not in spec) | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-SEARCH-014 | Filter state persistence | FilterToolbar.vue + sessionStorage | frontend/src/components/search/FilterToolbar.vue | frontend/tests/unit/FilterToolbar.spec.js (missing) | ⚪ |
| AC-SEARCH-015 | Real-time results update | RecipeList.vue | frontend/src/views/RecipeList.vue | frontend/tests/unit/RecipeList.spec.js (missing) | ⚪ |
| AC-SEARCH-016 | Empty results handling | RecipeList.vue | frontend/src/views/RecipeList.vue | frontend/tests/unit/RecipeList.spec.js (missing) | ⚪ |

**Supporting Components:**
- Recipe model scopes | app/models/recipe.rb
- SearchBar.vue | frontend/src/components/search/SearchBar.vue
- FilterPanel.vue | frontend/src/components/search/FilterPanel.vue

---

## 6. User Features (FR6)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-USER-001 | User registration | Devise::RegistrationsController | gem: devise | spec/requests/users/registrations_spec.rb (missing) | ⚪ |
| AC-USER-002 | User login - valid credentials | Devise::SessionsController | gem: devise | spec/requests/users/sessions_spec.rb (missing) | ⚪ |
| AC-USER-003 | User login - invalid credentials | Devise::SessionsController | gem: devise | spec/requests/users/sessions_spec.rb (missing) | ⚪ |
| AC-USER-004 | Favorite recipe - add | Api::V1::RecipesController#favorite | app/controllers/api/v1/recipes_controller.rb:289 | spec/requests/api/v1/recipes_spec.rb:1873 | ⚪ |
| AC-USER-005 | Favorite recipe - remove | Api::V1::RecipesController#unfavorite | app/controllers/api/v1/recipes_controller.rb:290 | spec/requests/api/v1/recipes_spec.rb (missing) | ⚪ |
| AC-USER-006 | Favorite - requires auth | before_action :authenticate_user! | app/controllers/api/v1/recipes_controller.rb | spec/requests/api/v1/recipes_spec.rb:1866 | ⚪ |
| AC-USER-007 | User notes - create recipe-level | Api::V1::NotesController#create | app/controllers/api/v1/notes_controller.rb:293 | spec/requests/api/v1/notes_spec.rb (missing) | ⚪ |
| AC-USER-008 | User notes - create step-level | Api::V1::NotesController#create | app/controllers/api/v1/notes_controller.rb:293 | spec/requests/api/v1/notes_spec.rb (missing) | ⚪ |
| AC-USER-009 | User notes - create ingredient-level | Api::V1::NotesController#create | app/controllers/api/v1/notes_controller.rb:293 | spec/requests/api/v1/notes_spec.rb (missing) | ⚪ |
| AC-USER-010 | User notes - edit | Api::V1::NotesController#update | app/controllers/api/v1/notes_controller.rb:294 | spec/requests/api/v1/notes_spec.rb (missing) | ⚪ |
| AC-USER-011 | User notes - delete | Api::V1::NotesController#destroy | app/controllers/api/v1/notes_controller.rb:295 | spec/requests/api/v1/notes_spec.rb (missing) | ⚪ |
| AC-USER-012 | User dashboard - favorites list | Api::V1::UsersController#favorites | app/controllers/api/v1/users_controller.rb:291 | spec/requests/api/v1/users_spec.rb (missing) | ⚪ |
| AC-USER-013 | Preferred language - save | User#update | app/models/user.rb:94 | spec/models/user_spec.rb (missing) | ⚪ |

**Supporting Components:**
- User model | app/models/user.rb:82-100
- UserFavorite model | app/models/user_favorite.rb
- UserRecipeNote model | app/models/user_recipe_note.rb
- UserDashboard.vue | frontend/src/views/UserDashboard.vue

---

## 7. Admin Recipe Management (FR7)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-ADMIN-001 | Manual recipe creation | Admin::RecipesController#create | app/controllers/admin/recipes_controller.rb:306 | spec/requests/admin/recipes_spec.rb (missing) | ⚪ |
| AC-ADMIN-002 | Text block import - parse | RecipeDiscoveryService#extract_recipe | app/services/recipe_discovery_service.rb:2126-2141 | spec/services/recipe_discovery_service_spec.rb (missing) | ⚪ |
| AC-ADMIN-003 | URL import - scrape | RecipeDiscoveryService#extract_recipe | app/services/recipe_discovery_service.rb:2126-2141 | spec/services/recipe_discovery_service_spec.rb (missing) | ⚪ |
| AC-ADMIN-004 | Image import - vision extraction | RecipeDiscoveryService (with vision) | app/services/recipe_discovery_service.rb (not in spec) | spec/services/recipe_discovery_service_spec.rb (missing) | ⚪ |
| AC-ADMIN-005 | Duplicate detection - warn on save | Admin::RecipesController#check_duplicates | app/controllers/admin/recipes_controller.rb:903-921 | spec/requests/admin/recipes_spec.rb (missing) | ⚪ |
| AC-ADMIN-006 | Duplicate detection - check aliases | Recipe.find_duplicates | app/models/recipe.rb:827-842 | spec/models/recipe_spec.rb:1817 | ⚪ |
| AC-ADMIN-007 | Manual variant regeneration | Admin::RecipesController#regenerate_variants | app/controllers/admin/recipes_controller.rb:308 | spec/requests/admin/recipes_spec.rb (missing) | ⚪ |
| AC-ADMIN-008 | Manual translation regeneration | Admin::RecipesController#regenerate_translations | app/controllers/admin/recipes_controller.rb:309 | spec/requests/admin/recipes_spec.rb (missing) | ⚪ |
| AC-ADMIN-009 | Bulk delete recipes | Admin::RecipesController#bulk_destroy | app/controllers/admin/recipes_controller.rb (not in spec) | spec/requests/admin/recipes_spec.rb (missing) | ⚪ |
| AC-ADMIN-010 | Recipe list - search and filter | Admin::RecipesController#index | app/controllers/admin/recipes_controller.rb:306 | spec/requests/admin/recipes_spec.rb (missing) | ⚪ |
| AC-ADMIN-011 | Recipe audit trail | Recipe model timestamps | app/models/recipe.rb:62-69 | spec/models/recipe_spec.rb (missing) | ⚪ |
| AC-ADMIN-012 | Data reference - edit tag | Admin::DataReferencesController#update | app/controllers/admin/data_references_controller.rb:318 | spec/requests/admin/data_references_spec.rb (missing) | ⚪ |
| AC-ADMIN-013 | Data reference - deactivate tag | Admin::DataReferencesController#update | app/controllers/admin/data_references_controller.rb:318 | spec/requests/admin/data_references_spec.rb (missing) | ⚪ |
| AC-ADMIN-014 | Prompt management - edit prompt | Admin::AiPromptsController#update | app/controllers/admin/ai_prompts_controller.rb:1390-1397 | spec/requests/admin/ai_prompts_spec.rb (missing) | ⚪ |
| AC-ADMIN-015 | Prompt management - test prompt | Admin::AiPromptsController#test | app/controllers/admin/ai_prompts_controller.rb:1409-1419 | spec/requests/admin/ai_prompts_spec.rb (missing) | ⚪ |

**Supporting Components:**
- RecipeDiscoveryService | app/services/recipe_discovery_service.rb:2109-2163
- Recipe.find_duplicates | app/models/recipe.rb:827-863
- AiPrompt model | app/models/ai_prompt.rb:1014-1052
- RecipeForm.vue | frontend/src/components/admin/RecipeForm.vue
- AIRecipeDiscovery.vue | frontend/src/components/admin/AIRecipeDiscovery.vue
- DataReferenceManager.vue | frontend/src/components/admin/DataReferenceManager.vue
- PromptManagement.vue | frontend/src/views/admin/PromptManagement.vue:1436-1518

---

## 8. Recipe Viewing (FR1 - partial)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-VIEW-001 | Recipe display - all fields | RecipeDetail.vue | frontend/src/views/RecipeShow.vue | frontend/tests/unit/RecipeShow.spec.js (missing) | ⚪ |
| AC-VIEW-002 | Recipe display - ingredient groups | IngredientList.vue | frontend/src/components/recipe/IngredientList.vue | frontend/tests/unit/IngredientList.spec.js (missing) | ⚪ |
| AC-VIEW-003 | Recipe display - steps with timing | StepList.vue | frontend/src/components/recipe/StepList.vue | frontend/tests/unit/StepList.spec.js (missing) | ⚪ |
| AC-VIEW-004 | Recipe display - equipment list | RecipeDetail.vue | frontend/src/views/RecipeShow.vue | frontend/tests/unit/RecipeShow.spec.js (missing) | ⚪ |
| AC-VIEW-005 | Recipe display - dietary tags | RecipeCard.vue | frontend/src/components/recipe/RecipeCard.vue | frontend/tests/unit/RecipeCard.spec.js (missing) | ⚪ |
| AC-VIEW-006 | Mobile responsive - card layout | RecipeCard.vue (CSS) | frontend/src/components/recipe/RecipeCard.vue | (visual testing) | ⚪ |
| AC-VIEW-007 | Mobile responsive - ingredient list | IngredientList.vue (CSS) | frontend/src/components/recipe/IngredientList.vue | (visual testing) | ⚪ |

**Supporting Components:**
- Api::V1::RecipesController#show | app/controllers/api/v1/recipes_controller.rb:284
- Recipe model | app/models/recipe.rb
- RecipeCard.vue | frontend/src/components/recipe/RecipeCard.vue

---

## 9. Performance & Reliability (NFRs)

| AC ID | Requirement | Component | Implementation File | Test File | Status |
|-------|-------------|-----------|---------------------|-----------|--------|
| AC-PERF-001 | Page load time - recipe view | RecipeShow.vue (SSR if applicable) | frontend/src/views/RecipeShow.vue | (performance testing) | ⚪ |
| AC-PERF-002 | API response time - recipe list | Api::V1::RecipesController#index | app/controllers/api/v1/recipes_controller.rb | (performance testing) | ⚪ |
| AC-PERF-003 | Database query - nutrition lookup | NutritionLookupService | app/services/nutrition_lookup_service.rb:2865-2883 | (performance testing) | ⚪ |
| AC-PERF-004 | Cache performance - Redis | NUTRITION_CACHE.get | app/services/nutrition_lookup_service.rb:3360-3376 | (performance testing) | ⚪ |
| AC-PERF-005 | Background job - variant generation | GenerateStepVariantsJob | app/jobs/generate_step_variants_job.rb:2172-2196 | (performance testing) | ⚪ |
| AC-PERF-006 | Background job - translation | TranslateRecipeJob | app/jobs/translate_recipe_job.rb:2198-2218 | (performance testing) | ⚪ |
| AC-PERF-007 | Uptime - service availability | Production monitoring | (infrastructure) | (uptime monitoring) | ⚪ |
| AC-PERF-008 | Error handling - API rate limit | AiService#call_claude | app/services/ai_service.rb:2226-2261 | spec/services/ai_service_spec.rb (missing) | ⚪ |
| AC-PERF-009 | Error handling - Nutritionix failure | NutritionLookupService#lookup_ingredient | app/services/nutrition_lookup_service.rb:2843-2861 | spec/services/nutrition_lookup_service_spec.rb (missing) | ⚪ |
| AC-PERF-010 | Error handling - background job failure | GenerateStepVariantsJob rescue block | app/jobs/generate_step_variants_job.rb:2192-2195 | spec/jobs/generate_step_variants_job_spec.rb (missing) | ⚪ |
| AC-PERF-011 | Database hit rate - nutrition cache | NutritionLookupService metrics | app/services/nutrition_lookup_service.rb | (analytics/monitoring) | ⚪ |
| AC-PERF-012 | Cost management - operating costs | Cost tracking spreadsheet | (operations) | (monthly cost review) | ⚪ |

**Supporting Components:**
- Redis cache initialization | config/initializers/redis.rb:3350-3356
- Sidekiq configuration | config/sidekiq.yml (not in spec)
- Error logging | Rails.logger calls throughout
- Monitoring setup | (production infrastructure)

---

## Coverage Summary

### By Feature Area

| Feature Area | Total ACs | Implemented | Tested | Coverage % |
|--------------|-----------|-------------|--------|------------|
| Smart Scaling | 12 | 0 | 0 | 0% |
| Step Variants | 9 | 0 | 0 | 0% |
| Multi-lingual | 9 | 0 | 0 | 0% |
| Nutrition | 13 | 0 | 0 | 0% |
| Search & Filtering | 16 | 0 | 0 | 0% |
| User Features | 13 | 0 | 0 | 0% |
| Admin Management | 15 | 0 | 0 | 0% |
| Recipe Viewing | 7 | 0 | 0 | 0% |
| Performance & Reliability | 12 | 0 | 0 | 0% |
| **TOTAL** | **106** | **0** | **0** | **0%** |

### Implementation Status Legend

- **Implemented**: Code exists in specified file location
- **Tested**: RSpec or Vue test exists and passes
- **Coverage %**: (Tested / Total ACs) × 100

---

## Missing Test Files (To Be Created)

### Backend Tests (RSpec)

**Services:**
- spec/services/recipe_scaler_spec.rb (partial - needs expansion)
- spec/services/whole_item_handler_spec.rb
- spec/services/step_variant_generator_spec.rb
- spec/services/recipe_translator_spec.rb
- spec/services/nutrition_lookup_service_spec.rb
- spec/services/recipe_nutrition_calculator_spec.rb (partial)
- spec/services/recipe_discovery_service_spec.rb
- spec/services/ai_service_spec.rb

**Jobs:**
- spec/jobs/generate_step_variants_job_spec.rb
- spec/jobs/translate_recipe_job_spec.rb
- spec/jobs/nutrition_lookup_job_spec.rb

**Models:**
- spec/models/recipe_spec.rb (partial - needs expansion)
- spec/models/user_spec.rb
- spec/models/ingredient_spec.rb
- spec/models/ingredient_nutrition_spec.rb
- spec/models/ingredient_alias_spec.rb
- spec/models/ai_prompt_spec.rb

**Controllers:**
- spec/requests/api/v1/recipes_spec.rb (partial - needs expansion)
- spec/requests/api/v1/users_spec.rb
- spec/requests/api/v1/notes_spec.rb
- spec/requests/admin/recipes_spec.rb
- spec/requests/admin/ingredients_spec.rb
- spec/requests/admin/data_references_spec.rb
- spec/requests/admin/ai_prompts_spec.rb
- spec/requests/users/registrations_spec.rb
- spec/requests/users/sessions_spec.rb

### Frontend Tests (Vue Test Utils)

**Components:**
- frontend/tests/unit/RecipeShow.spec.js
- frontend/tests/unit/RecipeCard.spec.js
- frontend/tests/unit/RecipeList.spec.js
- frontend/tests/unit/IngredientList.spec.js
- frontend/tests/unit/StepList.spec.js
- frontend/tests/unit/StepVariantToggle.spec.js
- frontend/tests/unit/ScalingControls.spec.js
- frontend/tests/unit/NutritionInfo.spec.js
- frontend/tests/unit/SearchBar.spec.js
- frontend/tests/unit/FilterToolbar.spec.js
- frontend/tests/unit/FilterPanel.spec.js
- frontend/tests/unit/LanguageSelector.spec.js
- frontend/tests/unit/TranslationStatus.spec.js
- frontend/tests/unit/UserDashboard.spec.js
- frontend/tests/unit/RecipeForm.spec.js (admin)
- frontend/tests/unit/AIRecipeDiscovery.spec.js (admin)
- frontend/tests/unit/DataReferenceManager.spec.js (admin)

**Stores:**
- frontend/tests/unit/recipeStore.spec.js
- frontend/tests/unit/userStore.spec.js
- frontend/tests/unit/uiStore.spec.js

**Services:**
- frontend/tests/unit/scalingService.spec.js
- frontend/tests/unit/recipeService.spec.js
- frontend/tests/unit/authService.spec.js

---

## Gap Analysis

### Critical Gaps (Blocking MVP)

1. **No test coverage exists** - All 106 ACs lack corresponding tests
2. **Api::V1::RecipesController#index** - Implementation missing for search/filter logic
3. **Admin controllers** - Most admin endpoints not implemented in tech spec
4. **Frontend components** - Many components mentioned but not fully specified

### Medium Priority Gaps

1. **Performance tests** - No performance test suite defined
2. **Integration tests** - No cross-component integration tests
3. **Error handling tests** - Retry logic and fallbacks need test coverage
4. **Mobile responsive tests** - Visual/responsive design testing undefined

### Low Priority Gaps

1. **E2E tests** - No end-to-end test suite (deferred per tech spec philosophy)
2. **Load tests** - No load/stress testing defined
3. **Security tests** - Authentication/authorization testing minimal

---

## Recommendations

### Immediate Actions (Week 1-2)

1. **Create test infrastructure**
   - Set up RSpec test suite with FactoryBot
   - Configure Vue Test Utils
   - Set up test database

2. **Implement critical missing endpoints**
   - Api::V1::RecipesController#index with search/filter logic
   - Admin CRUD controllers for recipes, ingredients, data references

3. **Write core service tests**
   - RecipeScaler (smart scaling is MVP critical)
   - NutritionLookupService (nutrition is MVP critical)
   - RecipeTranslator (multi-lingual is MVP critical)

### Short-term Actions (Week 3-4)

4. **Implement remaining backend tests**
   - All job specs (variant generation, translation, nutrition)
   - All model specs (Recipe, User, Ingredient, etc.)
   - All API request specs

5. **Implement frontend tests**
   - Core component tests (RecipeShow, RecipeList, RecipeCard)
   - Store tests (recipeStore, userStore, uiStore)
   - Service tests (scalingService, recipeService)

### Medium-term Actions (Week 5-8)

6. **Performance testing**
   - Set up performance test suite (RSpec Benchmark, Lighthouse for frontend)
   - Measure API response times, database query times, cache hit rates
   - Validate against AC-PERF-001 through AC-PERF-012

7. **Integration testing**
   - Test cross-component workflows (search → view → scale)
   - Test background job pipelines (save → variants → translations → nutrition)

8. **Production readiness**
   - Set up monitoring (Datadog, New Relic, or similar)
   - Implement cost tracking for API usage
   - Configure uptime monitoring

---

## Usage Notes

### For Developers

**Before implementing a feature:**
1. Find AC IDs in this matrix
2. Identify component and file path
3. Implement code at specified location
4. Create test file if missing
5. Write test covering AC
6. Update status to "Implemented & Tested"

**Example workflow:**
```
1. Task: Implement smart scaling by servings
2. Find: AC-SCALE-001 in matrix
3. Implement: app/services/recipe_scaler.rb:3993-3997
4. Create: spec/services/recipe_scaler_spec.rb
5. Write test: it 'should scale ingredients proportionally (AC-SCALE-001)'
6. Update matrix: Status → ✅
```

### For Product Owner

**Track progress:**
- Use Coverage Summary to see % complete by feature area
- Review Gap Analysis to understand blockers
- Prioritize missing implementations based on Critical/Medium/Low

**Validate completeness:**
- Before declaring MVP complete, verify all ACs are ✅
- Review Coverage % for each feature area (target: 100%)

### For QA

**Create test plans:**
- Each AC is a test case
- Use GIVEN-WHEN-THEN as test steps
- Map test results back to AC IDs

**Report bugs:**
- Reference AC ID in bug title (e.g., "Bug in AC-SCALE-003: Scaling factor incorrect")
- Links bug directly to requirement and implementation

---

**End of Traceability Matrix**
