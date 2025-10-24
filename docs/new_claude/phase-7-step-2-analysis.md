# Phase 7 Step 2: Frontend Codebase Analysis

## Overview
Analyzed Vue 3 + TypeScript frontend application with 7-language I18n support and Mobility translation integration. Frontend uses axios API client, Pinia for state management, and Vue Router for routing.

## Current Language Support Implementation

### Language Switching (Working)
- **UI Component**: `src/components/shared/LanguageSwitcher.vue`
  - Dropdown selector with 7 languages: en, ja, ko, zh-tw, zh-cn, es, fr
  - Calls `uiStore.setLanguage(languageCode)`

- **State Management**: `src/stores/uiStore.ts`
  - `setLanguage()` action:
    - Updates Vue I18n locale: `i18n.global.locale.value = newLanguage`
    - Stores to localStorage: `localStorage.setItem('locale', newLanguage)`
    - Updates document lang: `document.documentElement.lang = newLanguage`
    - Prepared for RTL support (currently disabled)

### API Client Language Support (Partial)
- **File**: `src/services/api.ts`
- **Current Implementation**:
  - Reads locale from localStorage: `const locale = localStorage.getItem('locale') || 'en'`
  - Sets Accept-Language header: `config.headers['Accept-Language'] = locale`
  - Uses standard axios interceptor pattern

- **Issue**: Only sends Accept-Language header; does not support ?lang query parameter
  - Backend expects both ?lang param (priority) and Accept-Language header fallback
  - Frontend should support ?lang param for explicit API calls

### Recipe API Functions
- **File**: `src/services/recipeApi.ts`
- **Current Functions**:
  - `getRecipes(filters)` - List with pagination/filtering
  - `getRecipe(id)` - Detail view
  - `scaleRecipe(id, payload)` - Ingredient scaling
  - Other methods: favorite, notes management

- **Issue**: No lang parameter support in function signatures
  - Functions accept generic filters but don't explicitly handle lang
  - Should support passing lang to API calls

## Type Definition Issues

### Files Analyzed
1. **`src/services/types.ts`**
   - Recipe interface mostly correct but:
     - Missing: `last_translated_at?: string` field
     - RecipeStep.instructions incorrectly typed as object (should support string)
     - RecipeIngredientGroup correctly structured

### TypeScript Errors (40+ found)

**RecipeForm.vue (34 errors)**
- Lines 45-47, 50-52, 304-306, 311-313: "Type 'undefined' not assignable to 'number'"
  - Root cause: Recipe.servings fields (min, max, original) initialized as undefined
  - Issue: Type definitions allow undefined but component assigns to number refs

- Lines 89, 220, 224, 228-229, 240, 245-248, 268-269: "Object is possibly 'undefined'"
  - Root cause: formData.value.servings, ingredient_groups items, steps items may be undefined
  - Issue: No null checks before destructuring/mapping

**ViewRecipe.vue (2 errors)**
- Line 33: "Property 'trim' does not exist on type 'never'"
  - Root cause: Code checks `if (typeof s === 'string')` but TypeScript doesn't narrow properly
  - Line 34: Tries to access `s.instructions?.[lang]` but s could be different type
  - Issue: RecipeStep structure mismatch - API returns single `instruction` string, type expects `instructions` object

**PlayfulLoadingSpinner.vue (1 error)**
- Line 62: "Argument of type 'string | undefined' not assignable to 'string | number'"

## Components Requiring Updates

### Tier 1: Type Definition Updates (Foundational)
1. `src/services/types.ts`
   - Add `last_translated_at?: string` to Recipe
   - Fix RecipeStep.instructions to be `string` not object with language keys
   - Make Recipe.servings fields in RecipeServings optional in form contexts
   - Add `lang?: string` to RecipeFilters for API calls

### Tier 2: API Client Updates
1. `src/services/api.ts`
   - Add lang parameter support to axios config
   - Update interceptor to include ?lang param in requests

2. `src/services/recipeApi.ts`
   - Update function signatures to accept optional lang parameter
   - Pass lang to API calls via filters or params

### Tier 3: Component Updates
1. `src/components/shared/ViewRecipe.vue`
   - Fix RecipeStep handling to work with string instructions (new format)
   - Remove code expecting instructions object with language keys
   - Add type narrowing or conditional rendering

2. `src/components/admin/recipes/RecipeForm.vue`
   - Initialize Recipe fields with proper defaults (0 not undefined)
   - Add null checks for servings object before destructuring
   - Add null checks for ingredient_groups items
   - Add null checks for steps items

3. `src/views/admin/AdminRecipeDetail.vue`
   - Already has language switching logic for translations
   - Should be updated to use new API lang parameter support

### Tier 4: Integration Updates
1. Language switching should trigger recipe re-fetch with new lang
2. RecipeStore should track current language context
3. Components should pass language to all recipe API calls

## API Response Structure (Current)
```typescript
{
  "success": true,
  "data": {
    "recipe": {
      "id": "...",
      "name": "translated name from mobility",
      "language": "en",
      "servings": {
        "original": 4,
        "min": 2,
        "max": 8
      },
      "ingredient_groups": [
        {
          "name": "Main",
          "items": [
            {
              "name": "ingredient name",
              "amount": "2",
              "unit": "cup",
              "preparation": "notes",
              "optional": false
            }
          ]
        }
      ],
      "steps": [
        {
          "id": "step-001",
          "order": 1,
          "instruction": "single string instruction (new format)",
        }
      ],
      "equipment": ["oven", "bowl"],
      "translations_completed": boolean,
      "last_translated_at": "ISO datetime (MISSING from types)",
      "dietary_tags": ["vegetarian"],
      "dish_types": ["main-course"],
      "cuisines": ["italian"],
      "recipe_types": []
    }
  }
}
```

## Language Parameter Handling Missing

### Backend (Already Implemented)
- ✅ Accepts ?lang query parameter
- ✅ Accepts Accept-Language header
- ✅ Returns translated content via Mobility

### Frontend (Needs Implementation)
- ❌ Does not pass ?lang parameter in API calls
- ✅ Sends Accept-Language header (but as simple language code, not RFC 7231 format)
- ❌ Recipe components don't re-fetch when language changes
- ❌ No mechanism to store/retrieve language-specific recipe data

## Test Status

### No Frontend Unit Tests Found
- No unit test script in npm scripts
- Uses Playwright for e2e testing (test:e2e, test:recipe scripts available)
- No test framework configured (Jest, Vitest, etc.)

### Type Checking
- Vue-tsc available: `npm run type-check`
- Currently failing with 40+ TypeScript errors
- Must be fixed before proceeding

### Build Status
- `npm run build` available - should be run after type fixes
- `npm run dev` available for local development

## Next Steps (Phase 7 Step 3+)

1. **Update Type Definitions** (Step 3)
   - Fix Recipe interface with missing fields
   - Fix RecipeStep structure
   - Make optional fields properly typed

2. **Update API Client** (Step 4)
   - Add lang parameter support
   - Update interceptor to pass lang with each request

3. **Update Components** (Steps 5-6)
   - Fix ViewRecipe for new step format
   - Fix RecipeForm initialization
   - Add language context awareness

4. **Test & Build** (Step 8)
   - Run type-check → fix remaining errors
   - Run build
   - Run e2e tests

## Key Findings

1. **Language switching UI exists** but API integration is incomplete
2. **Accept-Language header support** is functional but ?lang parameter missing
3. **Type definitions lag behind API changes** - causing 40+ type errors
4. **RecipeStep structure changed** in API but component code hasn't been updated
5. **Recipe re-fetching on language change** not implemented
6. **No frontend unit tests** but e2e test infrastructure exists
