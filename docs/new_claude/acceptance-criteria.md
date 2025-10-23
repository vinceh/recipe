# Recipe App - Acceptance Criteria

**Author:** V (with Winston, Architect Agent)
**Date:** 2025-10-07
**Version:** 1.0
**Status:** Draft

---

## Purpose

This document defines atomic, testable acceptance criteria for all Recipe App MVP features using GIVEN-WHEN-THEN format. Each criterion is assigned a unique ID for traceability to technical components and tests.

---

## Table of Contents

1. [Smart Scaling System](#smart-scaling-system)
2. [Step Instruction Variants](#step-instruction-variants)
3. [Multi-lingual Translation](#multi-lingual-translation)
4. [Internationalization (i18n)](#internationalization-i18n)
5. [Nutrition System](#nutrition-system)
6. [Search & Filtering](#search--filtering)
7. [User Features](#user-features)
8. [Admin Recipe Management](#admin-recipe-management)
9. [Recipe Viewing](#recipe-viewing)
10. [Performance & Reliability](#performance--reliability)

---

## Smart Scaling System

### AC-SCALE-001: Scale by Servings - Basic Proportional Scaling
**GIVEN** a recipe with 4 servings
**WHEN** user scales to 8 servings
**THEN** all ingredient amounts should double
**AND** servings display should show "8 servings (scaled from 4)"

### AC-SCALE-002: Scale by Servings - Fractional Scaling
**GIVEN** a recipe with 4 servings
**WHEN** user scales to 2 servings
**THEN** all ingredient amounts should be halved
**AND** fractional amounts should display as friendly fractions (e.g., "1/2 cup" not "0.5 cups")

### AC-SCALE-003: Scale by Ingredient - Calculate Factor
**GIVEN** a recipe with 500g chicken thigh as ingredient
**WHEN** user sets chicken thigh to 200g
**THEN** scaling factor should be 0.4 (200/500)
**AND** all other ingredients should scale by 0.4x
**AND** servings should show "1.6 servings (scaled from 4)"

### AC-SCALE-004: Context-Aware Precision - Baking Recipe
**GIVEN** a baking recipe (requires_precision = true)
**WHEN** user scales to 1.5x
**THEN** ingredient amounts should maintain 2 decimal places (e.g., "187.50g flour")
**AND** small amounts should convert to grams if < 0.25 units (e.g., "0.2 cups" → "25g")

### AC-SCALE-005: Context-Aware Precision - Cooking Recipe
**GIVEN** a cooking recipe (requires_precision = false)
**WHEN** user scales to 1.5x
**THEN** ingredient amounts should round to friendly fractions (e.g., "1 1/2 cups")
**AND** amounts like 0.66 cups should display as "2/3 cup"

### AC-SCALE-006: Unit Step-Down - Tablespoons to Teaspoons
**GIVEN** a recipe with 1 tbsp butter
**WHEN** user scales to 0.5x
**THEN** butter should display as "1.5 tsp" (stepped down from 0.5 tbsp)

### AC-SCALE-007: Unit Step-Down - Cups to Tablespoons
**GIVEN** a recipe with 1 cup milk
**WHEN** user scales to 0.125x
**THEN** milk should display as "2 tbsp" (stepped down from 0.125 cups)

### AC-SCALE-008: Whole Item Rounding - Eggs
**GIVEN** a recipe with 3 eggs
**WHEN** user scales to 0.66x
**THEN** eggs should display as "2 eggs" (rounded from 1.98 to nearest 0.5)

### AC-SCALE-009: Whole Item Rounding - Baking Context
**GIVEN** a baking recipe with 1 egg
**WHEN** user scales to 0.5x
**THEN** egg should display as "25g beaten egg" (converted from 0.5 eggs)

### AC-SCALE-010: Whole Item Omit - Very Small Amounts
**GIVEN** a recipe with 1 garlic clove
**WHEN** user scales to 0.2x
**THEN** garlic should display as "omit" or "0 cloves" (too small to be meaningful)

### AC-SCALE-011: Nutrition Recalculation on Scaling
**GIVEN** a recipe with 500 calories per serving (original 4 servings)
**WHEN** user scales to 8 servings
**THEN** per-serving nutrition should remain 500 calories
**AND** total recipe nutrition should show 4000 calories (8 × 500)

### AC-SCALE-012: Real-time Client-Side Scaling
**GIVEN** user is viewing a recipe
**WHEN** user adjusts serving slider
**THEN** ingredient amounts should update within 100ms
**AND** no API call should be made (client-side calculation)

---

## Step Instruction Variants

### AC-VARIANT-001: Easier Variant - Simplify Jargon
**GIVEN** an original instruction "Sauté the aromatics until translucent"
**WHEN** easier variant is generated
**THEN** it should replace jargon with everyday language (e.g., "Cook the onions and garlic in oil until they become see-through")

### AC-VARIANT-002: Easier Variant - Add Time Estimates
**GIVEN** an original instruction "Cook until done"
**WHEN** easier variant is generated
**THEN** it should include time estimate (e.g., "Cook for about 3-5 minutes")

### AC-VARIANT-003: Easier Variant - Add Sensory Cues
**GIVEN** an original instruction "Whisk until stiff peaks form"
**WHEN** easier variant is generated
**THEN** it should include visual cue (e.g., "Whisk until the mixture stands up straight when you lift the whisk, like soft ice cream peaks")

### AC-VARIANT-004: No Equipment Variant - Whisk Substitution
**GIVEN** an original instruction requires a whisk
**WHEN** no-equipment variant is generated
**THEN** it should suggest fork alternative (e.g., "Use a fork and whisk vigorously in circular motions")

### AC-VARIANT-005: No Equipment Variant - Food Processor Substitution
**GIVEN** an original instruction requires a food processor
**WHEN** no-equipment variant is generated
**THEN** it should suggest knife and cutting board (e.g., "Finely chop by hand with a sharp knife—takes longer but works just as well")

### AC-VARIANT-006: No Equipment Variant - Honest Tradeoffs
**GIVEN** a no-equipment variant suggests an alternative
**WHEN** the alternative is inferior
**THEN** variant should acknowledge tradeoff (e.g., "This will take 10 minutes longer" or "Requires more arm strength")

### AC-VARIANT-007: Variants Pre-Generated on Save
**GIVEN** admin creates a new recipe with original instructions
**WHEN** recipe is saved
**THEN** background job should generate easier and no-equipment variants for all steps
**AND** variants_generated flag should be set to true
**AND** variants_generated_at timestamp should be recorded

### AC-VARIANT-008: User Toggles Variant Per Step
**GIVEN** a recipe with all three variants available
**WHEN** user selects "Easier" for step 1 and "No Equipment" for step 2
**THEN** step 1 should display easier variant
**AND** step 2 should display no-equipment variant
**AND** remaining steps should display original variant (default)

### AC-VARIANT-009: Variant Selection Persists During Session
**GIVEN** user has selected "Easier" variant for a step
**WHEN** user scales the recipe
**THEN** step should continue displaying easier variant (selection persists)

---

## Multi-lingual Translation

### AC-TRANSLATE-001: Pre-Translation on Save
**GIVEN** admin creates a recipe in English
**WHEN** recipe is saved
**THEN** background job should translate to all 6 target languages (ja, ko, zh-tw, zh-cn, es, fr)
**AND** translations_completed flag should be set to true

### AC-TRANSLATE-002: Cultural Ingredient Accuracy - Native Term
**GIVEN** an English recipe with ingredient "negi (Japanese green onion)"
**WHEN** translated to Japanese
**THEN** ingredient name should be "ネギ" (native Japanese term, no explanation needed)

### AC-TRANSLATE-003: Cultural Ingredient Accuracy - Transliteration with Context
**GIVEN** an English recipe with ingredient "negi (Japanese green onion)"
**WHEN** translated to Korean
**THEN** ingredient name should be "네기 (일본식 파)" (transliteration + Korean explanation)

### AC-TRANSLATE-004: All Text Fields Translated
**GIVEN** a recipe with name, ingredient names, steps, and equipment
**WHEN** translation job completes
**THEN** all text fields should be translated
**AND** IDs, amounts, units should remain unchanged
**AND** JSON structure should be identical to original

### AC-TRANSLATE-005: Translation Quality - Step Instructions
**GIVEN** a recipe step "Bring to a simmer"
**WHEN** translated to Spanish
**THEN** translation should be culturally appropriate cooking terminology (e.g., "Llevar a fuego lento" not literal word-for-word)

### AC-TRANSLATE-006: Language Selection Persists
**GIVEN** user selects Japanese as preferred language
**WHEN** user navigates to another recipe
**THEN** new recipe should display in Japanese (if translation available)
**AND** language preference should persist across sessions (localStorage)

### AC-TRANSLATE-007: Fallback to Original Language
**GIVEN** a recipe has no Japanese translation
**WHEN** user requests Japanese version
**THEN** system should display original English version
**AND** show warning "Translation to Japanese not available"

### AC-TRANSLATE-008: API Endpoint Language Parameter
**GIVEN** a recipe with completed translations
**WHEN** API request includes `?lang=ja`
**THEN** response should contain Japanese-translated recipe data
**AND** language field should indicate "ja"

### AC-TRANSLATE-009: Translation Status Indicator
**GIVEN** a recipe is newly created
**WHEN** translations are in progress
**THEN** UI should show "Translations in progress..." indicator
**AND** available languages should be grayed out until complete

---

## Internationalization (i18n)

### AC-I18N-001: Backend Locale Files Structure
**GIVEN** the application supports multiple languages
**WHEN** Rails I18n is configured
**THEN** locale files should exist for each supported language: en.yml, ja.yml, ko.yml, zh-tw.yml, zh-cn.yml, es.yml, fr.yml
**AND** each locale file should contain UI text translations (buttons, labels, messages)

### AC-I18N-002: Frontend Locale Files Structure
**GIVEN** the Vue.js frontend supports multiple languages
**WHEN** Vue I18n is configured
**THEN** locale JSON files should exist in frontend/src/locales/ for each language
**AND** each locale should contain all UI strings (navigation, forms, validation messages, etc.)

### AC-I18N-003: Language Detection - User Preference
**GIVEN** a logged-in user with preferred_language = "ja"
**WHEN** user accesses the application
**THEN** UI should display in Japanese
**AND** API requests should include Accept-Language: ja header

### AC-I18N-004: Language Detection - Browser Default
**GIVEN** a non-authenticated user with browser language set to Korean
**WHEN** user accesses the application for the first time
**THEN** UI should detect browser language and display in Korean
**AND** language preference should be stored in localStorage

### AC-I18N-005: Language Switcher - Global Access
**GIVEN** a user is anywhere in the application
**WHEN** user clicks language switcher in navigation
**THEN** dropdown should show all available languages with native names (English, 日本語, 한국어, 繁體中文, 简体中文, Español, Français)
**AND** current language should be highlighted

### AC-I18N-006: Language Switcher - Immediate Update
**GIVEN** a user is viewing the homepage in English
**WHEN** user selects Japanese from language switcher
**THEN** all UI text should update to Japanese within 100ms
**AND** no page reload should occur
**AND** language preference should persist in localStorage

### AC-I18N-007: Date and Time Formatting - Locale Aware
**GIVEN** a recipe created_at timestamp is 2025-01-15 14:30:00 UTC
**WHEN** displayed in Japanese locale
**THEN** should format as "2025年1月15日 14:30" (Japanese format)
**AND** when displayed in English locale, should format as "Jan 15, 2025 2:30 PM"

### AC-I18N-008: Number Formatting - Locale Aware
**GIVEN** a recipe nutrition shows 1500 calories
**WHEN** displayed in English locale
**THEN** should format as "1,500" (comma separator)
**AND** when displayed in French locale, should format as "1 500" (space separator)

### AC-I18N-009: Currency Formatting - Not Applicable for MVP
**GIVEN** MVP does not include pricing features
**WHEN** currency formatting is needed
**THEN** should be implemented in future iteration (not required for MVP)

### AC-I18N-010: Pluralization Rules - English
**GIVEN** a recipe list shows 1 recipe
**WHEN** displayed in English
**THEN** should show "1 recipe"
**AND** when showing 3 recipes, should show "3 recipes"

### AC-I18N-011: Pluralization Rules - Japanese (No Plural Form)
**GIVEN** a recipe list shows 1 recipe
**WHEN** displayed in Japanese
**THEN** should show "1 レシピ"
**AND** when showing 3 recipes, should show "3 レシピ" (same form, Japanese has no plural)

### AC-I18N-012: Form Validation Messages - Localized
**GIVEN** a user submits a form with missing required field
**WHEN** UI is in Spanish
**THEN** validation error should display in Spanish (e.g., "Este campo es obligatorio")

### AC-I18N-013: API Error Messages - Localized
**GIVEN** an API request fails with 404 error
**WHEN** Accept-Language header is "ko"
**THEN** error message should be returned in Korean
**AND** error structure should include message key for client-side localization

### AC-I18N-014: Fallback Language - Missing Translation
**GIVEN** a UI string exists in English but not in French locale file
**WHEN** UI is set to French
**THEN** should fall back to English for missing string
**AND** log warning in development environment

### AC-I18N-015: Admin UI - Translation Management
**GIVEN** an admin views the i18n management page
**WHEN** page loads
**THEN** should show all translation keys grouped by namespace (common, errors, navigation, etc.)
**AND** allow inline editing of translations for all languages

### AC-I18N-016: Missing Translation Detection
**GIVEN** the application is running in development mode
**WHEN** a translation key is missing
**THEN** should display the key in brackets (e.g., "[missing.translation.key]")
**AND** log warning to console with file location

### AC-I18N-017: Translation Coverage Report
**GIVEN** admin views i18n statistics
**WHEN** page loads
**THEN** should show translation coverage percentage for each language
**AND** highlight missing translations with warnings

### AC-I18N-018: RTL Language Support - Not Required for MVP
**GIVEN** MVP supports LTR languages only (en, ja, ko, zh, es, fr)
**WHEN** RTL languages (Arabic, Hebrew) are needed
**THEN** should be implemented in future iteration (not required for MVP)

---

## Nutrition System

### AC-NUTR-001: Nutrition Lookup - Database First
**GIVEN** an ingredient exists in nutrition database
**WHEN** recipe nutrition is calculated
**THEN** system should use database nutrition data (no API call)
**AND** response time should be <10ms

### AC-NUTR-002: Nutrition Lookup - API Fallback
**GIVEN** an ingredient does NOT exist in database
**WHEN** recipe nutrition is calculated
**THEN** system should call Nutritionix API
**AND** cache response in database for future use
**AND** mark data source as "nutritionix"

### AC-NUTR-003: Nutrition Lookup - AI Estimation Fallback
**GIVEN** an ingredient is not found in database OR Nutritionix API
**WHEN** recipe nutrition is calculated
**THEN** system should use Claude AI to estimate nutrition
**AND** store estimate in database with data_source = "ai"
**AND** set confidence_score = 0.7

### AC-NUTR-004: Fuzzy Ingredient Matching - Exact Match
**GIVEN** database contains "chicken breast"
**WHEN** looking up "chicken breast"
**THEN** should return exact match immediately (no API call)

### AC-NUTR-005: Fuzzy Ingredient Matching - Plural/Singular
**GIVEN** database contains "tomato"
**WHEN** looking up "tomatoes"
**THEN** should match "tomato" via normalization (singularize)
**AND** return cached nutrition data

### AC-NUTR-006: Fuzzy Ingredient Matching - Alias Match
**GIVEN** database contains ingredient "green onion" with alias "scallion"
**WHEN** looking up "scallion"
**THEN** should match via alias and return "green onion" nutrition data

### AC-NUTR-007: Fuzzy Ingredient Matching - Levenshtein Similarity
**GIVEN** database contains "chicken"
**WHEN** looking up "chiken" (typo)
**THEN** should match "chicken" via Levenshtein distance (>85% similarity)
**AND** return cached nutrition data

### AC-NUTR-008: Recipe Nutrition Calculation - Per Serving
**GIVEN** a recipe with 500g chicken (300 cal/100g) and 4 servings
**WHEN** nutrition is calculated
**THEN** total calories should be 1500 (500g × 3)
**AND** per-serving calories should be 375 (1500 ÷ 4)

### AC-NUTR-009: Unit Conversion for Nutrition - Volume to Weight
**GIVEN** an ingredient "1 cup flour"
**WHEN** converting for nutrition calculation
**THEN** should estimate grams based on ingredient density (1 cup flour ≈ 120g)
**AND** calculate nutrition based on 120g

### AC-NUTR-010: Nutrition Display - All Macros
**GIVEN** a recipe with calculated nutrition
**WHEN** user views recipe
**THEN** nutrition panel should display per serving: calories, protein (g), carbs (g), fat (g), fiber (g)

### AC-NUTR-011: Nutrition Auto-Update on Scaling
**GIVEN** a recipe showing 500 calories per serving (4 servings)
**WHEN** user scales to 2 servings
**THEN** per-serving calories should remain 500
**AND** total recipe calories should update to 1000 (2 × 500)

### AC-NUTR-012: Admin Nutrition Database Management
**GIVEN** admin views nutrition database dashboard
**WHEN** viewing statistics
**THEN** should show total ingredients, database hit rate %, API calls this month, cost savings estimate

### AC-NUTR-013: Admin Refresh Nutrition from API
**GIVEN** admin selects an ingredient with data_source = "ai"
**WHEN** admin clicks "Refresh from API"
**THEN** system should re-fetch from Nutritionix
**AND** update database with new data
**AND** change data_source to "nutritionix"
**AND** set confidence_score to 1.0

---

## Search & Filtering

### AC-SEARCH-001: Fuzzy Text Search - Recipe Name Match
**GIVEN** database contains recipe "Pad Thai"
**WHEN** user searches for "pad tai" (typo)
**THEN** "Pad Thai" should appear in results (fuzzy match tolerance)

### AC-SEARCH-002: Fuzzy Text Search - Alias Match
**GIVEN** recipe "Oyakodon" has alias "Chicken and Egg Bowl"
**WHEN** user searches for "chicken egg bowl"
**THEN** "Oyakodon" should appear in results

### AC-SEARCH-003: Fuzzy Text Search - Ingredient Match
**GIVEN** recipe "Carbonara" contains ingredient "guanciale"
**WHEN** user searches for "guanciale"
**THEN** "Carbonara" should appear in results

### AC-SEARCH-004: Nutrition Filter - Calorie Range
**GIVEN** user sets calorie filter to 300-500
**WHEN** search executes
**THEN** only recipes with 300-500 calories per serving should appear

### AC-SEARCH-005: Nutrition Filter - Protein Minimum
**GIVEN** user sets protein filter to ≥30g
**WHEN** search executes
**THEN** only recipes with 30g+ protein per serving should appear

### AC-SEARCH-006: Nutrition Filter - Calorie-to-Protein Ratio
**GIVEN** user sets calorie-to-protein ratio filter to ≤15:1
**WHEN** search executes
**THEN** only recipes with ratio ≤15 (e.g., 450 cal ÷ 30g protein = 15) should appear

### AC-SEARCH-007: Dietary Tag Filter - Single Selection
**GIVEN** user selects "vegetarian" filter
**WHEN** search executes
**THEN** only recipes tagged "vegetarian" should appear

### AC-SEARCH-008: Dietary Tag Filter - Multiple Selection (AND Logic)
**GIVEN** user selects "vegetarian" AND "gluten-free"
**WHEN** search executes
**THEN** only recipes with BOTH tags should appear

### AC-SEARCH-009: Cuisine Filter - Single Cuisine
**GIVEN** user selects "Japanese" cuisine
**WHEN** search executes
**THEN** only recipes with cuisine "japanese" should appear

### AC-SEARCH-010: Dish Type Filter - Main Course
**GIVEN** user selects "Main Course" dish type
**WHEN** search executes
**THEN** only recipes with dish_type "main-course" should appear

### AC-SEARCH-011: Recipe Type Filter - Quick Weeknight
**GIVEN** user selects "Quick Weeknight" recipe type
**WHEN** search executes
**THEN** only recipes with recipe_type "quick-weeknight" should appear

### AC-SEARCH-012: Cooking Time Filter - Total Time Range
**GIVEN** user sets total time filter to 10-30 minutes
**WHEN** search executes
**THEN** only recipes with total_minutes between 10-30 should appear

### AC-SEARCH-013: Combined Filters - AND Logic
**GIVEN** user selects "vegetarian" + "Japanese" cuisine + calories <500
**WHEN** search executes
**THEN** only recipes matching ALL three criteria should appear

### AC-SEARCH-014: Filter State Persistence - Session Storage
**GIVEN** user sets filters (vegetarian, <500 cal)
**WHEN** user navigates away and returns
**THEN** filters should remain active (persisted in sessionStorage)

### AC-SEARCH-015: Real-time Results Update
**GIVEN** user is viewing search results
**WHEN** user changes any filter
**THEN** results should update within 500ms (no page reload)

### AC-SEARCH-016: Empty Results Handling
**GIVEN** user sets filters with no matching recipes
**WHEN** search executes
**THEN** UI should display "No recipes found. Try adjusting your filters."

---

## User Features

### AC-USER-001: User Registration - Email/Password
**GIVEN** a new user provides email and password
**WHEN** registration form is submitted
**THEN** user account should be created
**AND** user should be logged in automatically
**AND** role should default to "user" (not admin)

### AC-USER-002: User Login - Valid Credentials
**GIVEN** a user with valid email/password
**WHEN** login form is submitted
**THEN** user should be authenticated
**AND** JWT token should be stored in localStorage
**AND** user should be redirected to dashboard

### AC-USER-003: User Login - Invalid Credentials
**GIVEN** a user with invalid password
**WHEN** login form is submitted
**THEN** authentication should fail
**AND** error message "Invalid email or password" should display

### AC-USER-004: Favorite Recipe - Add
**GIVEN** a logged-in user viewing a recipe
**WHEN** user clicks "Add to Favorites"
**THEN** recipe should be added to user's favorites list
**AND** button should change to "Remove from Favorites"

### AC-USER-005: Favorite Recipe - Remove
**GIVEN** a logged-in user viewing a favorited recipe
**WHEN** user clicks "Remove from Favorites"
**THEN** recipe should be removed from favorites list
**AND** button should change to "Add to Favorites"

### AC-USER-006: Favorite Recipe - Requires Authentication
**GIVEN** a non-authenticated user viewing a recipe
**WHEN** user clicks "Add to Favorites"
**THEN** system should show login prompt
**AND** favorite action should not execute

### AC-USER-007: User Notes - Create Recipe-Level Note
**GIVEN** a logged-in user viewing a recipe
**WHEN** user adds a note at recipe level
**THEN** note should be saved with note_type = "recipe", note_target_id = null
**AND** note should be private to user (not visible to others)

### AC-USER-008: User Notes - Create Step-Level Note
**GIVEN** a logged-in user viewing a recipe step
**WHEN** user adds a note at step level
**THEN** note should be saved with note_type = "step", note_target_id = "step-001"
**AND** note should appear next to that specific step

### AC-USER-009: User Notes - Create Ingredient-Level Note
**GIVEN** a logged-in user viewing an ingredient
**WHEN** user adds a note at ingredient level
**THEN** note should be saved with note_type = "ingredient", note_target_id = "ing-005"

### AC-USER-010: User Notes - Edit Existing Note
**GIVEN** a user has an existing note
**WHEN** user edits and saves the note
**THEN** note text should update
**AND** updated_at timestamp should refresh

### AC-USER-011: User Notes - Delete Note
**GIVEN** a user has an existing note
**WHEN** user deletes the note
**THEN** note should be removed from database
**AND** note should disappear from UI

### AC-USER-012: User Dashboard - Favorites List
**GIVEN** a logged-in user
**WHEN** user visits dashboard
**THEN** favorites section should display all favorited recipes
**AND** recipes should show name, image, cuisine, total time

### AC-USER-013: User Preferred Language - Save Preference
**GIVEN** a logged-in user
**WHEN** user selects Japanese as preferred language
**THEN** user record should update preferred_language = "ja"
**AND** all recipes should display in Japanese by default

---

## Admin Recipe Management

### AC-ADMIN-001: Manual Recipe Creation - Full Form
**GIVEN** an admin user
**WHEN** admin submits recipe form with all fields
**THEN** recipe should be created in database
**AND** background jobs should trigger (variant generation, translation, nutrition)

### AC-ADMIN-002: Text Block Import - Parse Recipe
**GIVEN** an admin pastes a recipe text block
**WHEN** admin clicks "Import"
**THEN** Claude AI should parse text and extract: name, ingredients, steps, timing
**AND** extracted data should pre-fill edit form
**AND** admin can review/edit before saving

### AC-ADMIN-UI-TEXT-001: Import Button Visibility
**GIVEN** admin is on the "Create New Recipe" page
**WHEN** page loads
**THEN** an "Import from Text" button should be visible in the page header
**AND** button should display correct text in all 7 languages
**AND** button should have an icon indicating text/paste action

### AC-ADMIN-UI-TEXT-002: Import Dialog Opening
**GIVEN** admin is on the "Create New Recipe" page
**WHEN** admin clicks "Import from Text" button
**THEN** a dialog/modal should open with title "Import Recipe from Text"
**AND** dialog should contain a large textarea for pasting recipe text
**AND** dialog should have "Import" and "Cancel" buttons
**AND** textarea should have placeholder text instructing user to paste recipe
**AND** all text should be properly translated in current language

### AC-ADMIN-UI-TEXT-003: Text Import and Form Population
**GIVEN** admin has opened the import dialog
**WHEN** admin pastes recipe text into textarea
**AND** clicks "Import" button
**THEN** loading indicator should appear with message "Parsing recipe..."
**AND** API call should be made to POST /admin/recipes/parse_text
**AND** upon successful parse, dialog should close
**AND** RecipeForm should be populated with all parsed data:
  - Recipe name
  - Language
  - Servings (original, min, max)
  - Timing (prep, cook, total minutes)
  - Ingredient groups with items (name, amount, unit, notes)
  - Steps with instructions
  - Equipment (if parsed)
  - Cuisines, dietary tags, dish types (if parsed)
**AND** success message should display: "Recipe imported successfully. Please review and save."
**AND** admin can review and edit all fields before saving

### AC-ADMIN-UI-TEXT-004: Import Error Handling
**GIVEN** admin has pasted text and clicked "Import"
**WHEN** API returns an error (parsing failed, invalid text, API error)
**THEN** error message should display in the dialog
**AND** error message should be user-friendly and translated
**AND** dialog should remain open so user can retry
**AND** textarea content should be preserved
**AND** specific error messages for common issues:
  - "Could not parse recipe. Please ensure text includes ingredients and steps."
  - "Parsing service unavailable. Please try again later."
  - "Text too short. Please provide complete recipe text."

### AC-ADMIN-UI-TEXT-005: Empty Text Validation
**GIVEN** admin has opened the import dialog
**WHEN** admin clicks "Import" with empty or whitespace-only textarea
**THEN** validation message should display: "Please paste recipe text before importing"
**AND** no API call should be made
**AND** textarea should receive focus

### AC-ADMIN-UI-URL-001: Import from URL Button Visibility
**GIVEN** admin is on the "Create New Recipe" page
**WHEN** page loads
**THEN** an "Import from URL" button should be visible alongside "Import from Text" button
**AND** button should display correct text in all 7 languages
**AND** button should have a link/chain icon

### AC-ADMIN-UI-URL-002: URL Import Dialog Opening
**GIVEN** admin is on the "Create New Recipe" page
**WHEN** admin clicks "Import from URL" button
**THEN** a modal dialog should open with title "Import Recipe from URL"
**AND** dialog should contain a URL input field with placeholder text
**AND** dialog should have "Import" and "Cancel" buttons
**AND** dialog should be dismissible by clicking outside or pressing ESC

### AC-ADMIN-UI-URL-003: URL Format Validation
**GIVEN** admin has opened the URL import dialog
**WHEN** admin enters an invalid URL (no http/https, malformed)
**THEN** inline validation error should display: "Please enter a valid URL"
**AND** "Import" button should be disabled
**AND** no API call should be made

### AC-ADMIN-UI-URL-004: Empty URL Validation
**GIVEN** admin has opened the URL import dialog
**WHEN** admin clicks "Import" with empty URL field
**THEN** validation message should display: "URL is required"
**AND** no API call should be made
**AND** URL field should receive focus

### AC-ADMIN-UI-URL-005: Playful Loading State - Cooking Puns
**GIVEN** admin has entered a valid URL and clicked "Import"
**WHEN** API request is in progress
**THEN** playful loading spinner should display with cooking-related puns rotating every 2 seconds
**AND** puns should include: "Prepping ingredients...", "Simmering your recipe...", "Seasoning to perfection...", "Reducing the sauce...", "Letting it marinate...", "Whisking away...", "Bringing to a boil...", "Adding a pinch of magic..."
**AND** subtitle text should display: "(this may take a while)"
**AND** dialog should not be dismissible during loading

### AC-ADMIN-UI-URL-006: URL Import Success - Form Population
**GIVEN** admin has submitted a valid recipe URL
**WHEN** API successfully parses the recipe
**THEN** dialog should close
**AND** recipe form should populate with all extracted fields:
  - name, source_url, servings, difficulty, language
  - timing (prep_minutes, cook_minutes, total_minutes)
  - tags (dietary_tags, cuisines, dish_types, recipe_types)
  - aliases array
  - ingredient_groups with all items (name, amount, unit, notes, optional flag)
  - steps with instructions and timing
  - equipment array
  - admin_notes (if present)
  - nutrition data (if present)
**AND** success message should display: "Recipe imported successfully! Please review and save."
**AND** form preview should update with imported data

### AC-ADMIN-UI-URL-007: URL Import Error - Cannot Access URL
**GIVEN** admin has submitted a URL
**WHEN** API returns 500 error with "Could not access this URL"
**THEN** error message should display in dialog: "Could not access this URL"
**AND** dialog should remain open
**AND** URL should remain in input field
**AND** "Try Again" button should be visible
**AND** "Switch to Text Import" button should be visible

### AC-ADMIN-UI-URL-008: URL Import Error - No Recipe Found
**GIVEN** admin has submitted a URL
**WHEN** API returns 422 error with "Could not find a recipe on this page"
**THEN** error message should display: "Could not find a recipe on this page"
**AND** dialog should remain open
**AND** "Try Again" button should be visible
**AND** "Switch to Text Import" button should be visible

### AC-ADMIN-UI-URL-009: URL Import Error - Timeout
**GIVEN** admin has submitted a URL
**WHEN** request takes longer than 90 seconds
**THEN** timeout error should display: "Request timed out"
**AND** dialog should remain open with retry option

### AC-ADMIN-UI-URL-010: URL Import Error - AI Service Unavailable
**GIVEN** admin has submitted a URL
**WHEN** API returns 503 error "AI service temporarily unavailable"
**THEN** error message should display: "AI service temporarily unavailable. Please try again in a moment."
**AND** dialog should remain open
**AND** "Try Again" button should be visible

### AC-ADMIN-UI-URL-011: Switch to Text Import from URL Error
**GIVEN** admin received "no recipe found" error on URL import
**WHEN** admin clicks "Switch to Text Import" button
**THEN** URL import dialog should close
**AND** text import dialog should open
**AND** URL should be displayed in a helper message: "Having trouble? Try copying the recipe text manually from: [URL]"

### AC-ADMIN-UI-URL-012: URL Import - All Languages Supported
**GIVEN** admin has language set to any of the 7 supported languages (en, ja, ko, zh-tw, zh-cn, es, fr)
**WHEN** admin uses URL import feature
**THEN** all UI text (button, dialog title, placeholders, errors, loading puns) should display in selected language
**AND** loading puns should be culturally appropriate and cooking-related

### AC-ADMIN-003: URL Import - AI Direct Access (Primary)
**GIVEN** an admin provides a recipe URL
**WHEN** POST /admin/recipes/parse_url is called
**THEN** system should first attempt AI direct access (Claude fetches URL directly)
**AND** if successful, return structured recipe data
**AND** source_url should be included in response

### AC-ADMIN-003-A: URL Import - Web Scraping Fallback
**GIVEN** AI direct access fails (cannot access URL, 403/404, SSL error)
**WHEN** primary method fails
**THEN** system should automatically fall back to web scraping with Nokogiri
**AND** scraped HTML content should be cleaned (remove scripts, styles, navigation)
**AND** cleaned content should be passed to AI for parsing
**AND** if successful, return structured recipe data with source_url

### AC-ADMIN-003-B: URL Import - Complete Failure
**GIVEN** both AI direct access and web scraping fail
**WHEN** neither method can extract recipe data
**THEN** API should return 422 error with message "Could not extract recipe from this page"
**AND** error should include details about which methods were attempted

### AC-ADMIN-004: Image Import - Vision Extraction
**GIVEN** an admin uploads a recipe image (cookbook photo, screenshot, handwritten)
**WHEN** admin clicks "Import from Image"
**THEN** Claude AI vision should extract recipe data
**AND** extracted data should pre-fill edit form for review

### AC-ADMIN-005: Duplicate Detection - Warn on Save
**GIVEN** database contains recipe "Pad Thai"
**WHEN** admin creates new recipe "Phad Thai" (>85% similarity)
**THEN** system should show warning modal:
"Similar recipes found: Pad Thai (95% match) [View]"
**AND** admin can choose [Continue Anyway] or [Cancel]

### AC-ADMIN-006: Duplicate Detection - Check Aliases
**GIVEN** database contains recipe "Oyakodon" with alias "Chicken and Egg Bowl"
**WHEN** admin creates new recipe "chicken egg bowl"
**THEN** duplicate warning should trigger (alias match)

### AC-ADMIN-007: Manual Variant Regeneration
**GIVEN** an existing recipe with generated variants
**WHEN** admin clicks "Regenerate Variants"
**THEN** GenerateStepVariantsJob should trigger
**AND** existing variants should be overwritten with new AI-generated versions

### AC-ADMIN-008: Manual Translation Regeneration
**GIVEN** an existing recipe with completed translations
**WHEN** admin clicks "Regenerate Translations"
**THEN** TranslateRecipeJob should trigger
**AND** existing translations should be overwritten with new versions

### AC-ADMIN-009: Bulk Delete Recipes
**GIVEN** admin selects multiple recipes in list view
**WHEN** admin clicks "Bulk Delete"
**THEN** confirmation modal should appear
**AND** upon confirmation, all selected recipes should be deleted

### AC-ADMIN-010: Recipe List - Search and Filter
**GIVEN** admin is viewing recipe list
**WHEN** admin uses search box or filters (cuisine, dietary tags)
**THEN** recipe list should update to show only matching recipes

### AC-ADMIN-011: Recipe Audit Trail
**GIVEN** a recipe has been created and edited
**WHEN** admin views recipe details
**THEN** metadata should show: created_at, updated_at, source_url, admin_notes, import_method

### AC-ADMIN-012: Data Reference Management - Edit Dietary Tag
**GIVEN** admin views data references for dietary tags
**WHEN** admin edits a tag display name
**THEN** tag should update in database
**AND** all recipes using that tag should reflect new display name

### AC-ADMIN-013: Data Reference Management - Deactivate Tag
**GIVEN** admin views data references
**WHEN** admin sets a tag to inactive
**THEN** tag should no longer appear in recipe forms or filters
**AND** existing recipes with that tag should keep it (not removed)

### AC-ADMIN-014: Prompt Management - Edit AI Prompt
**GIVEN** admin views AI prompts list
**WHEN** admin edits prompt text for "step_variant_easier_user"
**THEN** prompt should update in database
**AND** next variant generation job should use new prompt

### AC-ADMIN-015: Prompt Management - Test Prompt with Variables
**GIVEN** admin is editing a prompt with variables {{recipe_name}}, {{step_order}}
**WHEN** admin provides test values and clicks "Render Preview"
**THEN** system should show rendered prompt with variables substituted
**AND** display character count and estimated token count

---

## Recipe Viewing

### AC-VIEW-001: Recipe Display - All Fields Visible
**GIVEN** a user views a recipe
**WHEN** recipe page loads
**THEN** should display: name, image, servings, timing, nutrition, dietary tags, cuisines, ingredients, steps, equipment

### AC-VIEW-002: Recipe Display - Ingredient Groups
**GIVEN** a recipe with multiple ingredient groups (e.g., "Main Ingredients", "Sauce")
**WHEN** recipe displays
**THEN** ingredients should be grouped with group name headers

### AC-VIEW-003: Recipe Display - Steps with Timing
**GIVEN** a recipe step has timing_minutes = 5
**WHEN** step displays
**THEN** step should show "⏱ 5 minutes" indicator

### AC-VIEW-004: Recipe Display - Equipment List
**GIVEN** a recipe uses equipment: ["wok", "rice_cooker"]
**WHEN** recipe displays
**THEN** equipment section should show "Wok, Rice Cooker"

### AC-VIEW-005: Recipe Display - Dietary Tags as Chips
**GIVEN** a recipe is tagged "vegetarian", "gluten-free"
**WHEN** recipe displays
**THEN** tags should appear as colored chips/badges

### AC-VIEW-006: Mobile Responsive - Recipe Card Layout
**GIVEN** a user on mobile device (screen width <768px)
**WHEN** viewing recipe list
**THEN** recipe cards should stack vertically
**AND** images should be full-width

### AC-VIEW-007: Mobile Responsive - Ingredient List
**GIVEN** a user on mobile device
**WHEN** viewing recipe ingredients
**THEN** ingredient list should be readable without horizontal scroll
**AND** font size should be minimum 16px for legibility

---

## Performance & Reliability

### AC-PERF-001: Page Load Time - Recipe View
**GIVEN** a user requests a recipe page
**WHEN** page loads
**THEN** initial render should complete within 2 seconds
**AND** full page load (including images) within 3 seconds

### AC-PERF-002: API Response Time - Recipe List
**GIVEN** a user requests recipe list (GET /api/v1/recipes)
**WHEN** API processes request
**THEN** response should return within 500ms
**AND** include pagination metadata (total, page, per_page)

### AC-PERF-003: Database Query Performance - Nutrition Lookup
**GIVEN** an ingredient exists in database
**WHEN** nutrition lookup service queries database
**THEN** query should complete within 10ms

### AC-PERF-004: Cache Performance - Redis Nutrition Cache
**GIVEN** an ingredient nutrition is cached in Redis
**WHEN** lookup service checks cache
**THEN** retrieval should complete within 1ms

### AC-PERF-005: Background Job - Variant Generation Completion
**GIVEN** a recipe with 10 steps is created
**WHEN** GenerateStepVariantsJob executes
**THEN** job should complete within 2 minutes (20 steps × 2 variants × ~3 seconds per AI call)

### AC-PERF-006: Background Job - Translation Completion
**GIVEN** a recipe is created
**WHEN** TranslateRecipeJob executes (6 languages)
**THEN** job should complete within 5 minutes (6 languages × ~30 seconds per translation)

### AC-PERF-007: Uptime - Service Availability
**GIVEN** the application is deployed to production
**WHEN** measured over 30-day period
**THEN** uptime should be ≥95%

### AC-PERF-008: Error Handling - API Rate Limit
**GIVEN** Anthropic API returns 429 (rate limit)
**WHEN** AI service calls Claude
**THEN** service should retry with exponential backoff (2s, 4s, 8s)
**AND** retry up to 3 times before failing

### AC-PERF-009: Error Handling - Nutritionix API Failure
**GIVEN** Nutritionix API is unavailable
**WHEN** nutrition lookup occurs
**THEN** service should fall back to AI estimation
**AND** log error for monitoring

### AC-PERF-010: Error Handling - Background Job Failure
**GIVEN** a background job fails (e.g., AI API timeout)
**WHEN** job executes
**THEN** error should be logged
**AND** job should NOT be marked as complete
**AND** Sidekiq should retry job according to retry policy

### AC-PERF-011: Database Hit Rate - Nutrition Cache
**GIVEN** system has been running for 12 months
**WHEN** measuring nutrition lookup performance
**THEN** database + Redis cache hit rate should be ≥95%
**AND** API calls should be <5% of total lookups

### AC-PERF-012: Cost Management - Operating Costs
**GIVEN** system is running at MVP scale (100 users, 50 recipes)
**WHEN** measured over 1 month
**THEN** total operating costs should be <$100/month
**AND** breakdown: Nutritionix API <$40, Anthropic API <$20, hosting <$40

---

## Summary Statistics

- **Total Acceptance Criteria:** 145
- **Smart Scaling:** 12 criteria
- **Step Variants:** 9 criteria
- **Multi-lingual:** 9 criteria
- **Internationalization (i18n):** 18 criteria
- **Nutrition:** 13 criteria
- **Search & Filtering:** 16 criteria
- **User Features:** 13 criteria
- **Admin Management:** 15 criteria
- **Recipe Viewing:** 7 criteria
- **Performance & Reliability:** 12 criteria
- **Additional Requirements:** 21 criteria (from ongoing analysis)

---

## Usage Notes

### For Developers
- Each AC ID maps to technical components in traceability matrix
- Use AC IDs in test descriptions (e.g., `it 'should scale ingredients proportionally (AC-SCALE-001)'`)
- Reference ACs in commit messages and PR descriptions

### For Product Owner
- Use as checklist for MVP completion validation
- Mark ACs as "Done" when feature passes testing
- Update ACs if requirements change (version history in Git)

### For QA/Testing
- Create test cases based on GIVEN-WHEN-THEN scenarios
- Each AC should have at least one corresponding test
- Use traceability matrix to track test coverage

---

**End of Acceptance Criteria Document**
