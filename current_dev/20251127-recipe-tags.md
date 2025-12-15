# Feature: Recipe Tags

**Description:** Add free-form tags to recipes that admins can set during create/edit, and users can filter by.

**Date:** 2025-11-27

---

## Stories

### Backend

- [x] Story 1: Add tags column to recipes table
  - AC: Migration adds `tags` as `text[]` with default empty array and GIN index
  - Files: `backend/db/migrate/20251209093343_add_tags_to_recipes.rb`

- [x] Story 2: Update Recipe model
  - AC: Recipe model permits `tags` attribute, serialized as array
  - Files: `backend/app/controllers/admin/recipes_controller.rb` (strong params)

- [x] Story 3: Update Admin recipes controller
  - AC: `tags` can be set via create/update actions
  - Files: `backend/app/controllers/admin/recipes_controller.rb`

- [x] Story 4: Update API recipes controller for filtering
  - AC: API index action accepts `tags[]` filter param and returns matching recipes
  - Files: `backend/app/controllers/api/v1/recipes_controller.rb`

- [x] Story 5: Include tags in recipe serialization
  - AC: Both API and admin recipe JSON responses include `tags` array
  - Files: `backend/app/controllers/api/v1/recipes_controller.rb`, `backend/app/controllers/admin/recipes_controller.rb`

- [x] Story 6: Backend tests
  - AC: RSpec tests for model, controller actions, and filtering
  - Files: `backend/spec/models/recipe_spec.rb`, `backend/spec/requests/api/v1/recipes_spec.rb`, `backend/spec/requests/admin/recipes_spec.rb`

### Frontend

- [x] Story 7: Update Recipe TypeScript interface
  - AC: Recipe type includes `tags?: string[]`
  - Files: `frontend/src/services/types.ts`

- [x] Story 8: Add tags input to RecipeForm
  - AC: Admin can add/remove tags when creating/editing recipes (use existing tag input pattern with pills)
  - Files: `frontend/src/components/admin/recipes/RecipeForm.vue`

- [x] Story 9: Update recipe store filters
  - AC: RecipeFilters interface includes `tags` array, store passes to API
  - Files: `frontend/src/stores/recipeStore.ts`

- [x] Story 10: Display tags on recipe cards/detail
  - AC: Tags shown on RecipeCard and ViewRecipe components
  - Files: `frontend/src/components/recipe/RecipeCard.vue`, `frontend/src/components/shared/ViewRecipe.vue`

- [x] Story 11: Frontend E2E tests
  - AC: Playwright tests for admin tag management and user filtering
  - Files: `frontend/e2e/admin/recipes-tags.spec.ts`

---

## Notes

- Uses PostgreSQL array type for simple storage without join tables
- Filtering will use `ANY` operator: `WHERE 'tag' = ANY(tags)`
- No i18n needed for tags - stored as entered by admin
- Reuse existing tag pill styling from RecipeForm (`.recipe-form__tag` pattern)
