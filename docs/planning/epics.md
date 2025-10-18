# recipe - Epic Breakdown

**Author:** V
**Date:** 2025-10-07
**Project Level:** Level 3 (Full Product)
**Target Scale:** 12-40 stories, 4 epics, 8-week MVP timeline

---

## Epic Overview

The recipe platform MVP is organized into **4 core epics** delivering value incrementally over 8 weeks. Each epic represents a complete vertical slice of functionality that can be developed, tested, and validated independently.

**Epic 1: Recipe Foundation & Viewing** (Weeks 1-2)
- Core recipe data model, display system, and basic viewing features
- Enables admin to create recipes and users to view them
- Foundation for all subsequent features
- **Stories:** 8-10 stories

**Epic 2: Smart Recipe Adaptation** (Weeks 3-4)
- Smart scaling (by servings and by ingredient)
- Three instruction variants (Original/Easier/No Equipment)
- Ingredient substitution system
- Makes recipes flexible and adaptive to user needs
- **Stories:** 6-8 stories

**Epic 3: Search, Filtering & Multi-Lingual** (Weeks 5-6)
- Comprehensive search and filtering system
- Multi-lingual support (7 languages)
- Nutrition integration and database
- Enables discoverability and accessibility
- **Stories:** 8-10 stories

**Epic 4: User Features & Admin Tools** (Weeks 7-8)
- User authentication, favorites, notes
- AI recipe customization (chat interface)
- Admin management tools and monitoring
- Completes full user experience and operational capabilities
- **Stories:** 10-12 stories

---

## Epic 1: Recipe Foundation & Viewing

### Epic Goal
Establish core recipe data model and basic viewing capabilities to enable recipe creation and consumption.

### User Value
Users can browse and view recipes with clean, mobile-optimized interface. Admins can create and manage recipe content.

### Success Criteria
- Admin can create recipes with full schema (ingredients, steps, metadata)
- Users can view recipes with clear layout (ingredients, steps, timing, nutrition)
- Mobile-responsive design works on phones and tablets
- Recipe data stored in PostgreSQL JSONB with proper indexing
- 10+ recipes created and viewable by end of epic

### Technical Foundation
- Rails backend with Recipe model (JSONB fields)
- Vue.js frontend with PrimeVue components
- PostgreSQL database with GIN indexes
- Basic routing and API endpoints
- Devise authentication (user roles: user, admin)

---

### Story 1.1: Database Schema & Recipe Model
**As a** developer
**I want** to create the recipe database schema with JSONB storage
**So that** we can store flexible recipe data with good query performance

**Prerequisites:** None (foundational story)

**Acceptance Criteria:**
1. Recipe table created with UUID primary key
2. JSONB fields implemented: servings, timing, nutrition, dietary_tags, dish_types, recipe_types, cuisines, ingredient_groups, steps, equipment, translations
3. String fields: name, language, precision_reason, source_url
4. Boolean fields: requires_precision, variants_generated, translations_completed
5. Timestamp fields: variants_generated_at, created_at, updated_at
6. GIN indexes created on: name, language, dietary_tags, dish_types, recipe_types, cuisines
7. Recipe model validates presence of name, language
8. JSONB fields have default values (empty arrays/objects)

**Technical Notes:**
- Use PostgreSQL JSONB for flexibility and native querying
- GIN indexes critical for array field filtering performance
- Consider add_index with `using: :gin` for JSONB fields

---

### Story 1.2: User Authentication & Roles
**As a** system
**I want** user authentication with role-based access control
**So that** we can distinguish between regular users and admins

**Prerequisites:** Story 1.1 (database foundation)

**Acceptance Criteria:**
1. Devise installed and configured
2. User model created with email/password authentication
3. Role enum implemented: user (0), admin (1)
4. User registration works (email/password)
5. User login/logout works
6. Session persistence works
7. Admin role can be assigned (via Rails console for MVP)
8. Authorization helper methods: `current_user.admin?`

**Technical Notes:**
- Use Devise for authentication (battle-tested)
- Simple role enum sufficient for MVP (no complex RBAC needed)
- Admin assignment manual via console acceptable for MVP

---

### Story 1.3: Admin Recipe Form (Manual Entry)
**As an** admin
**I want** a form to manually create recipes with all fields
**So that** I can build the recipe database

**Prerequisites:** Story 1.1 (Recipe model), Story 1.2 (Admin role)

**Acceptance Criteria:**
1. Admin-only route `/admin/recipes/new` accessible
2. Form includes all recipe fields:
   - Name, language, servings (original/min/max)
   - Timing (prep/cook/total minutes)
   - Dietary tags (multi-select)
   - Dish types, recipe types, cuisines (multi-select)
   - Ingredient groups (dynamic add/remove)
   - Each ingredient: name, amount, unit, preparation notes
   - Steps (dynamic add/remove)
   - Each step: order, original instruction, timing
   - Equipment list
   - Admin notes, source URL
3. Form validation works (required fields, data types)
4. Submit creates recipe in database
5. Success message shown, redirects to recipe list
6. Error messages shown for validation failures
7. Cancel button returns to recipe list

**Technical Notes:**
- Use PrimeVue form components (InputText, InputNumber, MultiSelect, Textarea)
- Vue reactive forms with v-model
- Dynamic ingredient/step addition with array manipulation
- Only "original" instruction variant entered manually (AI generates others later)

---

### Story 1.4: Recipe List View (Admin)
**As an** admin
**I want** to see a list of all recipes
**So that** I can manage my recipe database

**Prerequisites:** Story 1.3 (recipes can be created)

**Acceptance Criteria:**
1. Admin route `/admin/recipes` shows paginated recipe list
2. Table displays: name, cuisine, dietary tags, created date
3. Pagination works (20 recipes per page)
4. Search by name works (fuzzy match)
5. Filter by cuisine works
6. Filter by dietary tags works
7. Sort by name, created_at works
8. Edit button links to edit page (deferred to later story)
9. Delete button removes recipe (with confirmation dialog)
10. "Create New" button links to recipe form

**Technical Notes:**
- Use PrimeVue DataTable component
- Server-side pagination for scalability
- Search/filter via query params

---

### Story 1.5: Recipe Viewing Page (User-Facing)
**As a** user
**I want** to view a recipe with clear layout
**So that** I can follow it while cooking

**Prerequisites:** Story 1.1 (Recipe model), Story 1.3 (recipes exist)

**Acceptance Criteria:**
1. Public route `/recipes/:id` accessible without login
2. Recipe name displayed prominently
3. Servings, timing, dietary tags visible in header section
4. Ingredient groups displayed with clear headings
5. Each ingredient shows: amount, unit, name, preparation
6. Steps displayed in numbered order
7. Each step shows: instruction text (original variant), timing if available
8. Equipment list displayed
9. Nutrition info displayed (calories, protein, carbs, fat, fiber per serving)
10. Mobile-responsive layout (readable on phone while cooking)
11. Large touch targets for mobile
12. Clean, distraction-free design

**Technical Notes:**
- Use PrimeVue Card, Chip, Tag components
- Mobile-first CSS (breakpoints for tablet/desktop)
- Sticky ingredient list on scroll (future enhancement)
- Only show "original" variant initially (toggles added in Epic 2)

---

### Story 1.6: Recipe List/Browse Page (User-Facing)
**As a** user
**I want** to browse available recipes
**So that** I can find something to cook

**Prerequisites:** Story 1.5 (recipe viewing works)

**Acceptance Criteria:**
1. Public route `/recipes` shows recipe list
2. Recipe cards display: name, image placeholder, cuisine, timing, calories
3. Click recipe card navigates to recipe detail page
4. Responsive grid layout (1 column mobile, 2-3 columns tablet/desktop)
5. Basic pagination works (20 recipes per page)
6. "Load More" or pagination controls present
7. Empty state shown if no recipes ("No recipes yet")

**Technical Notes:**
- Use PrimeVue DataView or custom card grid
- Image placeholders for MVP (actual images deferred)
- Consider lazy loading for performance

---

### Story 1.7: API Endpoints for Recipes
**As a** frontend developer
**I want** RESTful API endpoints for recipes
**So that** the Vue.js frontend can fetch data

**Prerequisites:** Story 1.1 (Recipe model)

**Acceptance Criteria:**
1. `GET /api/v1/recipes` - list recipes (paginated, filterable)
2. `GET /api/v1/recipes/:id` - get single recipe
3. `POST /api/v1/recipes` - create recipe (admin only)
4. `PUT /api/v1/recipes/:id` - update recipe (admin only)
5. `DELETE /api/v1/recipes/:id` - delete recipe (admin only)
6. All endpoints return JSON
7. Proper HTTP status codes (200, 201, 404, 422, 401, 403)
8. Error responses include meaningful messages
9. Authentication required for admin endpoints
10. CORS configured for frontend

**Technical Notes:**
- Rails API mode for `/api/v1` namespace
- Use `before_action :authenticate_user!` for protected routes
- Use `before_action :require_admin` for admin routes
- Serializers for consistent JSON structure

---

### Story 1.8: Vue.js Frontend Foundation
**As a** developer
**I want** Vue.js 3 + Vite frontend with routing
**So that** we have a modern SPA foundation

**Prerequisites:** None (parallel to backend)

**Acceptance Criteria:**
1. Vue.js 3 project initialized with Vite
2. Vue Router configured with routes: /, /recipes, /recipes/:id, /admin/*
3. PrimeVue installed and configured
4. Pinia store initialized (recipeStore, userStore)
5. Axios configured for API calls
6. Base layout component with navigation
7. Environment variables setup (.env for API base URL)
8. Dev server runs on localhost:5173
9. Production build works

**Technical Notes:**
- Vite for fast HMR
- PrimeVue theme imported (Lara Light Blue)
- Axios interceptors for auth headers

---

### Story 1.9: Navigation & Layout
**As a** user
**I want** consistent navigation across the app
**So that** I can easily move between pages

**Prerequisites:** Story 1.8 (Vue foundation)

**Acceptance Criteria:**
1. Top navigation bar with logo/branding
2. Navigation links: Browse Recipes, (Login/Register or User Menu)
3. User menu shows: Dashboard, Favorites, Logout (when authenticated)
4. Admin menu shows: Admin Dashboard, Manage Recipes (when admin)
5. Mobile hamburger menu for small screens
6. Footer with basic info (optional for MVP)
7. Active route highlighted in navigation
8. Responsive navigation for all screen sizes

**Technical Notes:**
- Use PrimeVue Menubar component
- Conditional rendering based on `userStore.isAuthenticated` and `userStore.isAdmin`

---

### Story 1.10: Data Reference Seeding
**As a** developer
**I want** initial data references seeded
**So that** admins can select from predefined options

**Prerequisites:** Story 1.1 (database)

**Acceptance Criteria:**
1. DataReferences table created (reference_type, key, display_name, metadata, sort_order, active)
2. Seed script loads dietary tags (42 tags: vegetarian, vegan, gluten-free, etc.)
3. Seed script loads dish types (16 types: main-course, soup, dessert, etc.)
4. Seed script loads cuisines (100+ cuisines: japanese, italian, mexican, etc.)
5. Seed script loads recipe types (70+ types: baking, stir-fry, quick-weeknight, etc.)
6. Seed script loads units (cup, tbsp, tsp, g, kg, oz, lb, etc.)
7. `rails db:seed` populates all reference data
8. Reference data queryable via API for form dropdowns

**Technical Notes:**
- Reference Product Brief data-references/ folder for complete lists
- Use find_or_create_by to make seeds idempotent

---

## Epic 2: Smart Recipe Adaptation

### Epic Goal
Make recipes flexible and adaptable through smart scaling, instruction variants, and ingredient substitution.

### User Value
Recipes adjust to what users have on hand (ingredients, equipment, skill level) rather than forcing exact adherence.

### Success Criteria
- Users can scale recipes by servings with real-time UI updates (<100ms)
- Users can scale by single ingredient amount ("I have 200g chicken")
- All recipes have 3 instruction variants per step (Original/Easier/No Equipment) generated by AI
- Users can toggle variants per step independently
- Users can substitute ingredients with smart suggestions and nutrition recalculation
- Background jobs generate variants and handle API failures gracefully

---

### Story 2.1: Scaling UI Controls
**As a** user
**I want** UI controls to scale a recipe
**So that** I can adjust ingredient amounts

**Prerequisites:** Epic 1 complete (recipe viewing works)

**Acceptance Criteria:**
1. Scaling controls visible on recipe page
2. "Scale by Servings" option with dropdown or input (0.5x, 1x, 2x, 4x, custom)
3. "Scale by Ingredient" option with ingredient selector + amount input
4. Current scaling factor displayed (e.g., "1.5x original recipe")
5. "Reset to Original" button clears scaling
6. Scaling state persists during session (not across page reloads)
7. Mobile-friendly controls

**Technical Notes:**
- Use PrimeVue InputNumber, Dropdown components
- Store scaling state in component reactive data
- No API call needed (client-side calculation)

---

### Story 2.2: Client-Side Scaling Algorithm
**As a** user
**I want** ingredient amounts to update instantly when scaling
**So that** I see adjusted quantities in real-time

**Prerequisites:** Story 2.1 (scaling UI)

**Acceptance Criteria:**
1. Scaling by servings multiplies all ingredient amounts by factor
2. Scaling by ingredient calculates factor from (target amount / original amount)
3. Scaled amounts display with appropriate precision:
   - Baking recipes (requires_precision=true): show grams, no rounding
   - Cooking recipes: show friendly fractions (0.66 → 2/3, 0.5 → 1/2)
4. Unit step-down logic: 1.5 tbsp → 1 tbsp + 1.5 tsp
5. Very small amounts handled gracefully (0.1 tsp → "pinch")
6. Nutrition values recalculate based on scaling factor
7. Update happens <100ms (instant feedback)
8. Original values restorable via "Reset"

**Technical Notes:**
- Implement RecipeScaler service in Vue
- Friendly fraction mapping: 0.25→1/4, 0.33→1/3, 0.5→1/2, 0.66→2/3, 0.75→3/4
- Context-aware rounding based on requires_precision flag
- Reference smart-scaling-system.md for algorithm details

---

### Story 2.3: Background Job Infrastructure (Sidekiq)
**As a** developer
**I want** Sidekiq + Redis for background jobs
**So that** we can process AI tasks asynchronously

**Prerequisites:** None (infrastructure story)

**Acceptance Criteria:**
1. Sidekiq gem installed and configured
2. Redis installed and running locally
3. Sidekiq configured for development and production
4. Sidekiq Web UI accessible at `/sidekiq` (admin only)
5. Job queues configured: default, translations, nutrition
6. Job retry logic configured (exponential backoff)
7. Dead job queue monitored
8. Sidekiq process runs alongside Rails server

**Technical Notes:**
- Use Sidekiq 7.x
- Configure Redis connection (localhost:6379 for dev)
- Add sidekiq-cron for scheduled jobs (future)

---

### Story 2.4: AI Prompt Management System
**As an** admin
**I want** AI prompts stored in database
**So that** I can edit prompts without code deployment

**Prerequisites:** Epic 1 complete (database, admin UI)

**Acceptance Criteria:**
1. AiPrompts table created (prompt_key, prompt_type, feature_area, prompt_text, description, variables, active, version)
2. Seed script loads all prompts: step_variant_easier, step_variant_no_equipment, recipe_translation, recipe_discovery, nutrition_estimation
3. Admin UI at `/admin/ai_prompts` shows prompt list
4. Admin can view prompt details (text, variables, description)
5. Admin can edit prompt text
6. Admin can test prompt with sample variables (renders output)
7. Admin can create new prompt version
8. Admin can activate/deactivate prompts
9. Only active prompts used by system
10. Character count and estimated tokens shown

**Technical Notes:**
- Prompt keys must be unique
- Variables stored as JSON array
- Template variable replacement: `{{recipe_name}}` → actual value
- Reference Technical Specification prompt management section

---

### Story 2.5: Generate Step Variants Job
**As an** admin
**I want** AI to generate Easier and No Equipment variants
**So that** recipes adapt to different skill levels and equipment

**Prerequisites:** Story 2.3 (Sidekiq), Story 2.4 (AI prompts), Claude API configured

**Acceptance Criteria:**
1. GenerateStepVariantsJob created
2. Job triggered when recipe saved/updated
3. For each step, calls Claude API with step_variant_easier_user prompt
4. For each step, calls Claude API with step_variant_no_equipment_user prompt
5. Stores variants in step JSONB: `instructions: { original, easier, no_equipment }`
6. Sets variants_generated=true and variants_generated_at timestamp
7. Job handles API failures gracefully (retries 3 times with backoff)
8. Job logs errors for admin review
9. Recipe viewable even if variants fail (shows original only)
10. Admin can manually trigger regeneration

**Technical Notes:**
- Use Claude API (claude-3-5-sonnet-20241022)
- Max tokens: 1024 per variant
- Parse JSON response from Claude
- Graceful fallback: if variant generation fails, original instruction shown for all variants

---

### Story 2.6: Instruction Variant Toggle UI
**As a** user
**I want** to toggle between instruction variants per step
**So that** I can choose the level of detail I need

**Prerequisites:** Story 2.5 (variants generated)

**Acceptance Criteria:**
1. Each recipe step shows variant toggle buttons: Original / Easier / No Equipment
2. Clicking toggle switches instruction text instantly (no page reload)
3. Active variant highlighted/selected
4. Each step can have different variant selected (independent toggles)
5. Default variant: Original
6. If variant missing (generation failed), button disabled with tooltip
7. Variant preference persists during session (not across page reloads)
8. Mobile-friendly toggle design (large touch targets)

**Technical Notes:**
- Use PrimeVue Button or ToggleButton component
- Store variant selection in component state per step
- CSS active state for selected variant

---

### Story 2.7: Ingredient Substitution Library
**As an** admin
**I want** to configure ingredient substitutions
**So that** users can easily swap ingredients

**Prerequisites:** Epic 1 complete (database)

**Acceptance Criteria:**
1. IngredientSubstitutions table created (ingredient_name, substitute_name, ratio, notes)
2. Seed script loads common substitutions:
   - Butter → Olive oil (0.75 ratio), Coconut oil (1.0), Margarine (1.0)
   - Milk → Almond milk (1.0), Oat milk (1.0), Soy milk (1.0)
   - Eggs → Flax eggs (1.0), Applesauce (0.25 cup per egg), Aquafaba (3 tbsp per egg)
   - Sugar → Honey (0.75), Maple syrup (0.75), Agave (0.75)
3. Admin UI to manage substitutions (add, edit, delete)
4. Substitutions queryable via API
5. Case-insensitive ingredient matching

**Technical Notes:**
- Ratio field: decimal representing amount adjustment (0.75 = use 75% of original amount)
- Fuzzy matching on ingredient names for robustness

---

### Story 2.8: Ingredient Substitution UI
**As a** user
**I want** to replace ingredients with alternatives
**So that** I can adapt recipes to what I have

**Prerequisites:** Story 2.7 (substitution library)

**Acceptance Criteria:**
1. Each ingredient has "Replace" button/icon
2. Clicking Replace shows substitution modal/dropdown
3. Modal lists available substitutes for that ingredient
4. Selecting substitute updates ingredient display
5. Amount automatically adjusted based on substitution ratio
6. Nutrition recalculates with new ingredient (if nutrition data available)
7. "Undo" or "Reset" option to revert to original
8. Substitutions apply to current session only (don't alter base recipe)
9. Visual indicator shows ingredient was substituted (e.g., strikethrough original, show new)
10. If no substitutes available, "Replace" button disabled

**Technical Notes:**
- Session-based state (Vue component reactive data)
- Nutrition recalculation requires ingredient nutrition lookup
- Graceful handling if substitute nutrition data unavailable

---

## Epic 3: Search, Filtering & Multi-Lingual

### Epic Goal
Enable recipe discoverability through comprehensive search/filtering and support 7 languages with authentic translations.

### User Value
Users find recipes matching exact needs (nutrition, dietary restrictions, time, cuisine). Non-English speakers access authentic recipes in native language.

### Success Criteria
- Fuzzy text search across recipe names, aliases, ingredients
- Multi-dimensional filtering: nutrition, dietary tags, time, cuisine, dish type, recipe type
- Filter combinations work together (AND logic)
- Real-time filter results (<500ms)
- 7 languages supported with culturally accurate translations
- Progressive nutrition database operational (API → cache → database)
- 50+ recipes fully translated and filterable

---

### Story 3.1: Fuzzy Text Search
**As a** user
**I want** to search recipes by name or ingredient
**So that** I can quickly find what I'm looking for

**Prerequisites:** Epic 1 complete (recipe data)

**Acceptance Criteria:**
1. Search bar on recipe browse page
2. Search queries recipe names and aliases (case-insensitive)
3. Fuzzy matching tolerates typos (e.g., "pad thai" matches "Pad Thai", "phad thai")
4. Search includes ingredient names
5. Results update in real-time as user types (debounced 300ms)
6. Displays "No results" if no matches
7. Search persists in URL query param (shareable link)
8. Clear search button

**Technical Notes:**
- Use PostgreSQL `ILIKE` or full-text search (pg_search gem)
- Fuzzy matching via trigram similarity (pg_trgm extension)
- Search across: recipe.name, recipe.aliases, ingredient_groups.items.name

---

### Story 3.2: Filter Toolbar UI
**As a** user
**I want** comprehensive filters for recipes
**So that** I can narrow results to my exact needs

**Prerequisites:** Epic 1 complete (recipe data, reference data seeded)

**Acceptance Criteria:**
1. Filter toolbar visible on recipe browse page
2. Filters include:
   - Dietary tags (multi-select: vegetarian, vegan, gluten-free, etc.)
   - Cuisines (multi-select: Japanese, Italian, Mexican, etc.)
   - Dish types (multi-select: main course, soup, dessert, etc.)
   - Recipe types (multi-select: baking, stir-fry, quick weeknight, etc.)
   - Max calories (number input)
   - Min protein (number input)
   - Max total time (number input in minutes)
   - Calorie-to-protein ratio (number input, optional)
3. All filters use large, accessible UI components (no tiny sliders)
4. Filters collapsible to save screen space
5. "Clear All Filters" button
6. Active filter count indicator (e.g., "3 filters active")
7. Mobile-responsive (stacks vertically on small screens)

**Technical Notes:**
- Use PrimeVue MultiSelect, InputNumber components
- No range sliders (difficult on mobile)
- Toolbar starts collapsed on mobile, expanded on desktop

---

### Story 3.3: Filter Query Logic
**As a** user
**I want** filters to combine logically
**So that** results match ALL my criteria

**Prerequisites:** Story 3.2 (filter UI)

**Acceptance Criteria:**
1. Multiple dietary tags use OR logic within category ("vegetarian OR vegan")
2. Different filter types use AND logic between categories ("vegetarian AND Japanese AND <500 calories")
3. Nutrition filters: calories ≤ max, protein ≥ min, calorie-to-protein ratio ≤ max
4. Time filter: total_minutes ≤ max
5. Results update in real-time as filters change
6. Results display count ("24 recipes found")
7. Filters persist in URL query params (shareable link)
8. Performance: query executes <500ms even with multiple filters

**Technical Notes:**
- Build WHERE clause dynamically based on active filters
- Use JSONB containment for array filters: `WHERE dietary_tags @> ARRAY['vegetarian']`
- Index on JSONB fields critical for performance (GIN indexes)

---

### Story 3.4: Ingredients Table & Nutrition Schema
**As a** developer
**I want** ingredient and nutrition database tables
**So that** we can build progressive nutrition database

**Prerequisites:** Epic 1 complete (database foundation)

**Acceptance Criteria:**
1. Ingredients table created (id, canonical_name, category)
2. IngredientNutrition table created (ingredient_id, calories, protein_g, carbs_g, fat_g, fiber_g per 100g, data_source, confidence_score)
3. IngredientAliases table created (ingredient_id, alias, language, alias_type)
4. Foreign key constraints in place
5. Indexes on ingredient canonical_name, alias
6. Seed script loads common ingredients (initially empty, built progressively)

**Technical Notes:**
- canonical_name normalized (lowercase, singular)
- data_source: 'nutritionix', 'usda', 'ai'
- confidence_score: 0.0-1.0 (track data quality)

---

### Story 3.5: Nutrition Lookup Service
**As a** developer
**I want** nutrition lookup service with API fallback
**So that** we get nutrition data efficiently

**Prerequisites:** Story 3.4 (nutrition tables), Nutritionix API configured

**Acceptance Criteria:**
1. NutritionLookupService class created
2. Service checks database first (ingredient match via canonical name or alias)
3. If not in database, calls Nutritionix API
4. If Nutritionix fails, calls USDA FoodData Central API
5. If both APIs fail, calls Claude API for estimation (low confidence)
6. All API responses cached in database (progressive build)
7. Fuzzy ingredient matching (handle plurals, typos)
8. Returns nutrition per 100g: calories, protein, carbs, fat, fiber
9. Returns data source and confidence score
10. Handles API rate limits gracefully

**Technical Notes:**
- Normalize ingredient names before lookup (lowercase, remove plurals)
- Levenshtein distance for fuzzy matching
- Cache all results permanently (never re-query same ingredient)
- Log API calls for cost monitoring

---

### Story 3.6: Recipe Nutrition Calculation
**As a** user
**I want** to see nutrition info for each recipe
**So that** I can make informed dietary choices

**Prerequisites:** Story 3.5 (nutrition lookup), Epic 1 complete (recipe viewing)

**Acceptance Criteria:**
1. When recipe created/updated, NutritionLookupJob queued
2. Job looks up nutrition for each ingredient
3. Job calculates total nutrition by summing (ingredient amount × nutrition per 100g)
4. Job divides by servings to get per-serving nutrition
5. Job stores in recipe.nutrition JSONB: `{ per_serving: { calories, protein_g, carbs_g, fat_g, fiber_g } }`
6. Recipe view displays nutrition per serving
7. Nutrition recalculates when recipe scaled
8. Missing ingredient nutrition handled gracefully (estimate or omit)
9. Confidence indicator shown if low-quality data

**Technical Notes:**
- Unit conversion needed (convert all to grams before calculation)
- Handle missing data: if ingredient nutrition unavailable, estimate from similar ingredients or omit

---

### Story 3.7: Translation Job Infrastructure
**As an** admin
**I want** recipes translated to 7 languages
**So that** non-English users can access content

**Prerequisites:** Story 2.4 (AI prompts), Story 2.3 (Sidekiq), Claude API configured

**Acceptance Criteria:**
1. TranslateRecipeJob created
2. Job triggered when recipe saved/updated
3. Job translates to 6 languages: ja, ko, zh-tw, zh-cn, es, fr (original is 'en')
4. For each language, calls Claude API with recipe_translation_user prompt
5. Translates: name, aliases, ingredient names, step instructions (all 3 variants), equipment names
6. Stores translations in recipe.translations JSONB: `{ ja: {...}, ko: {...}, ... }`
7. Maintains recipe structure in translations (same JSON schema)
8. Culturally accurate ingredient translations (e.g., "negi" stays "ネギ" in Japanese, not "green onion")
9. Sets translations_completed=true when done
10. Handles API failures gracefully (retries, logs errors)
11. Admin can manually trigger re-translation

**Technical Notes:**
- Use Claude API for quality translations
- Max tokens: 4096 per translation (recipes can be long)
- Batch translations to reduce API calls (translate all 6 languages in sequence)
- Reference Technical Specification translation prompts

---

### Story 3.8: Language Selector UI
**As a** user
**I want** to select my preferred language
**So that** I can view recipes in my native language

**Prerequisites:** Story 3.7 (translations exist)

**Acceptance Criteria:**
1. Language selector in navigation bar
2. Dropdown shows 7 languages: English, 日本語, 한국어, 繁體中文, 简体中文, Español, Français
3. Selecting language updates entire UI and recipe content
4. Language preference stored in localStorage (persists across sessions)
5. Language preference stored in user profile if authenticated
6. Recipe view shows translated name, ingredients, steps
7. If translation missing, fallback to English with indicator
8. Language code visible in URL (e.g., `/recipes/123?lang=ja`)
9. Mobile-friendly language selector

**Technical Notes:**
- Vue i18n for UI text translations (buttons, labels, etc.)
- Recipe content translations stored in recipe.translations JSONB
- Fallback chain: selected language → English → original

---

### Story 3.9: Multi-Lingual Search & Filtering
**As a** user
**I want** search and filters to work in my language
**So that** I can find recipes using native terms

**Prerequisites:** Story 3.8 (language selector), Story 3.1 (search), Story 3.3 (filters)

**Acceptance Criteria:**
1. Search queries translated recipe names and aliases in selected language
2. Filter dropdown options translated (dietary tags, cuisines, dish types)
3. Results show recipes in selected language
4. Search "親子丼" (Japanese) finds Oyakodon recipes when language=ja
5. Fallback to English if translation unavailable
6. URL query params language-aware

**Technical Notes:**
- Search against recipe.translations[lang].name and recipe.translations[lang].aliases
- Fallback to English if selected language translation missing
- Reference data (tags, cuisines) need i18n translations

---

### Story 3.10: Progressive Database Monitoring
**As an** admin
**I want** to monitor nutrition database growth
**So that** I can track API cost reduction

**Prerequisites:** Story 3.5 (nutrition lookup)

**Acceptance Criteria:**
1. Admin dashboard shows:
   - Total ingredients in database
   - Database hit rate (% of lookups resolved from DB vs API)
   - API calls this month (Nutritionix, USDA, Claude)
   - Estimated cost savings
2. Goal: 95% hit rate by month 12
3. Trending chart of hit rate over time
4. Breakdown by data source (Nutritionix, USDA, AI)
5. Low-confidence ingredients flagged for manual review

**Technical Notes:**
- Log every nutrition lookup (source: db, nutritionix, usda, ai)
- Calculate hit rate: db_lookups / total_lookups
- Cost calculation: avoided API calls × per-call cost

---

## Epic 4: User Features & Admin Tools

### Epic Goal
Complete user experience with personalization features and provide admin operational tools.

### User Value
Users save favorites, add notes, customize recipes via AI chat. Admins have full control over content, prompts, and system monitoring.

### Success Criteria
- Users can favorite recipes and add notes (recipe/step/ingredient level)
- AI chat interface allows recipe customization (substitutions, technique questions, dietary adaptations)
- Session-based AI modifications with option to save personal variants
- Admin recipe management (list, create, edit, delete, preview, bulk actions)
- Admin data reference management (tags, cuisines, types, units)
- Admin prompt management (edit AI prompts without code deployment)
- Admin system monitoring (job queue, API usage, errors, performance)
- Duplicate recipe detection prevents duplicates

---

### Story 4.1: User Favorites
**As a** user
**I want** to save favorite recipes
**So that** I can easily find them later

**Prerequisites:** Epic 1 complete (user authentication, recipes)

**Acceptance Criteria:**
1. UserFavorites table created (user_id, recipe_id, created_at)
2. Foreign keys enforce referential integrity
3. Unique constraint on (user_id, recipe_id) prevents duplicates
4. Favorite heart icon on recipe card and recipe detail page
5. Clicking heart toggles favorite on/off
6. Heart filled when favorited, outline when not
7. API endpoint: POST /api/v1/recipes/:id/favorite, DELETE /api/v1/recipes/:id/favorite
8. User dashboard shows favorited recipes
9. Favorite count displayed on recipe (optional)

**Technical Notes:**
- Require authentication for favorite actions
- Optimistic UI update (instant feedback, rollback on API error)

---

### Story 4.2: User Notes
**As a** user
**I want** to add notes to recipes, steps, or ingredients
**So that** I can remember my modifications

**Prerequisites:** Epic 1 complete (user authentication, recipes)

**Acceptance Criteria:**
1. UserRecipeNotes table created (user_id, recipe_id, note_type, note_target_id, note_text)
2. note_type: 'recipe', 'step', 'ingredient'
3. note_target_id: 'step-001', 'ing-005', null for recipe-level
4. Foreign keys enforce referential integrity
5. Notes displayed inline at recipe/step/ingredient level
6. "Add Note" button at each level
7. Note modal/textarea for input
8. Save/Cancel buttons
9. Edit and delete existing notes
10. Notes private to user (not visible to others)
11. Visual indicator when note exists

**Technical Notes:**
- Notes stored as plain text (markdown support future enhancement)
- API endpoints: POST /api/v1/recipes/:id/notes, PUT /api/v1/notes/:id, DELETE /api/v1/notes/:id

---

### Story 4.3: User Dashboard
**As a** user
**I want** a dashboard showing my activity
**So that** I can see my favorites and recent recipes

**Prerequisites:** Story 4.1 (favorites), Story 4.2 (notes)

**Acceptance Criteria:**
1. Dashboard route `/dashboard` (authenticated users only)
2. Displays favorited recipes (grid/list)
3. Displays recently viewed recipes (last 10)
4. Displays recipes with notes
5. Quick links to browse, search
6. User profile info (email, preferred language)
7. "Edit Profile" link
8. Mobile-responsive layout

**Technical Notes:**
- Recent recipes tracked via browser localStorage or server-side (optional)
- Use PrimeVue Card, DataView components

---

### Story 4.4: AI Chat Interface
**As a** user
**I want** to ask questions about a recipe via chat
**So that** I can get help with substitutions and techniques

**Prerequisites:** Epic 2 complete (AI infrastructure), Claude API configured

**Acceptance Criteria:**
1. Chat panel on recipe page (collapsible sidebar or modal)
2. Text input for user message
3. Send button triggers Claude API call
4. Chat history displayed (user messages and AI responses)
5. AI has full recipe context (ingredients, steps, equipment, dietary tags)
6. AI can answer:
   - Ingredient substitution questions ("Can I use honey instead of sugar?")
   - Technique explanations ("What does 'fold' mean?")
   - Equipment alternatives ("I don't have a stand mixer")
   - Dietary adaptations ("Make this vegan")
   - Scaling questions ("Double just the sauce")
   - Timing questions ("Can I prep this ahead?")
7. Streaming responses for natural conversation feel (optional for MVP)
8. Chat history persists during session (not across sessions for MVP)
9. Clear chat button
10. Rate limiting: max 10 messages per session

**Technical Notes:**
- Use Claude API with recipe context in system prompt
- Session-based chat (not multi-turn conversation across sessions for MVP)
- Cost management: count tokens, limit message length
- Consider Claude streaming API for better UX

---

### Story 4.5: AI Session-Based Recipe Modifications
**As a** user
**I want** AI chat to modify the recipe based on my questions
**So that** I can see customized ingredient/step changes

**Prerequisites:** Story 4.4 (AI chat)

**Acceptance Criteria:**
1. When AI suggests modifications (e.g., "replace butter with oil"), option to apply changes
2. "Apply Changes" button in chat message
3. Clicking applies modifications to recipe view (ingredients/steps updated)
4. Modifications session-based (don't alter database recipe)
5. "Reset to Original" button undoes all modifications
6. Visual indicator shows recipe has been modified
7. Modified recipe still scalable
8. Nutrition recalculates if ingredients changed

**Technical Notes:**
- Store modifications in component state (Vue reactive data)
- Parse AI response for structured changes (JSON format)
- Apply changes client-side to displayed recipe

---

### Story 4.6: Save Personal Recipe Variants
**As a** user
**I want** to save my modified recipe as a personal variant
**So that** I can use it again later

**Prerequisites:** Story 4.5 (session modifications)

**Acceptance Criteria:**
1. "Save as Personal Variant" button when recipe modified
2. Modal asks for variant name
3. Saves modified recipe to user's account
4. PersonalRecipeVariants table created (user_id, base_recipe_id, variant_name, modifications_json)
5. User dashboard shows personal variants
6. Opening variant loads base recipe + applies modifications
7. Can edit/delete personal variants
8. Personal variants not publicly visible

**Technical Notes:**
- Store modifications as JSON diff or full modified recipe
- Base recipe updates don't affect saved variants (snapshot approach)

---

### Story 4.7: Admin Recipe Edit
**As an** admin
**I want** to edit existing recipes
**So that** I can correct errors or update content

**Prerequisites:** Epic 1 Story 1.3 (admin recipe form)

**Acceptance Criteria:**
1. Edit button on admin recipe list navigates to edit form
2. Edit form pre-populated with existing recipe data
3. All fields editable (name, ingredients, steps, metadata)
4. Submit updates recipe in database
5. Triggers background jobs (regenerate variants, retranslate)
6. Option to skip job re-triggering (checkbox: "Keep existing variants/translations")
7. Success message shown
8. Redirects to recipe list

**Technical Notes:**
- Use same form component as create (edit mode flag)
- Handle JSONB updates carefully (full replace or merge)

---

### Story 4.8: Admin Duplicate Detection
**As an** admin
**I want** warnings when creating duplicate recipes
**So that** I don't add the same recipe twice

**Prerequisites:** Epic 1 complete (admin recipe form)

**Acceptance Criteria:**
1. When admin enters recipe name, check for duplicates (debounced 500ms)
2. Fuzzy matching on recipe name and aliases (>85% similarity threshold)
3. Warning modal shows similar recipes found
4. Lists similar recipes with names, similarity %, view links
5. Options: "Continue Anyway" or "Cancel"
6. View link opens existing recipe in new tab
7. Duplicate check runs on blur or after typing pauses
8. Only checks same language (English recipe doesn't match Japanese)

**Technical Notes:**
- Use Levenshtein distance for similarity calculation
- Endpoint: POST /admin/recipes/check_duplicates
- Modal uses PrimeVue Dialog component

---

### Story 4.9: Admin Bulk Actions
**As an** admin
**I want** bulk actions on recipes
**So that** I can efficiently manage multiple recipes

**Prerequisites:** Epic 1 Story 1.4 (admin recipe list)

**Acceptance Criteria:**
1. Checkboxes on recipe list for multi-select
2. "Select All" checkbox
3. Bulk action dropdown when recipes selected:
   - Bulk Delete (with confirmation)
   - Bulk Regenerate Variants
   - Bulk Retranslate
   - Bulk Publish/Unpublish (if publish status added)
4. Action applies to all selected recipes
5. Progress indicator for long-running operations
6. Success/failure summary shown
7. Deselect all after action completes

**Technical Notes:**
- Use Sidekiq batch jobs for bulk operations
- Limit bulk actions to reasonable count (e.g., max 50 recipes at once)

---

### Story 4.10: Admin Data Reference Manager
**As an** admin
**I want** to manage reference data (tags, cuisines, types)
**So that** I can add/edit options without code changes

**Prerequisites:** Epic 1 Story 1.10 (data references seeded)

**Acceptance Criteria:**
1. Admin route `/admin/data_references`
2. Tabs for each reference type: Dietary Tags, Dish Types, Cuisines, Recipe Types, Units, Equipment
3. Each tab shows DataTable with: key, display_name, sort_order, active status
4. Inline editing for display_name, sort_order
5. Add new reference button
6. Deactivate (soft delete) reference
7. Changes apply immediately to recipe forms and filters
8. Cannot delete references in use by recipes (integrity check)

**Technical Notes:**
- Use PrimeVue DataTable with row editing
- Soft delete: set active=false rather than hard delete
- Validation: unique keys per reference type

---

### Story 4.11: Admin System Monitoring Dashboard
**As an** admin
**I want** system health and metrics dashboard
**So that** I can monitor the platform

**Prerequisites:** Epic 2 (Sidekiq), Epic 3 (nutrition lookup), Claude API, Nutritionix API

**Acceptance Criteria:**
1. Admin dashboard route `/admin/dashboard`
2. Displays key metrics:
   - Total recipes
   - Total users
   - Recipe views (last 7 days)
   - Favorite count
3. Job queue stats:
   - Pending jobs count
   - Failed jobs count (last 24h)
   - Link to Sidekiq Web UI
4. API usage:
   - Claude API calls (this month)
   - Nutritionix API calls (this month)
   - Estimated costs
5. System health:
   - Database size
   - Recipe count per language
   - Nutrition database hit rate
6. Error summary (last 10 errors with timestamps, messages)
7. Performance metrics (optional for MVP):
   - Average page load time
   - Average API response time

**Technical Notes:**
- Use charting library for trends (Chart.js or similar)
- Cache metrics (refresh every 5 minutes, not real-time)
- Link to Sidekiq Web for detailed job inspection

---

### Story 4.12: Admin Job Retry & Management
**As an** admin
**I want** to retry failed background jobs
**So that** I can fix temporary failures

**Prerequisites:** Epic 2 Story 2.3 (Sidekiq)

**Acceptance Criteria:**
1. Sidekiq Web UI accessible at `/admin/sidekiq` (admin only)
2. Failed jobs list shows: job class, error message, failed_at timestamp
3. Retry button on each failed job
4. Retry all failed jobs button
5. Delete failed job (give up)
6. View job payload and error backtrace
7. Filter failed jobs by queue

**Technical Notes:**
- Sidekiq Web provides most of this out-of-box
- Mount Sidekiq::Web in routes with admin authorization

---

## Epic Dependencies Summary

**Epic 1 → Epic 2:** Recipe data model must exist before adding scaling/variants
**Epic 1 → Epic 3:** Recipes must exist before search/filter/translation
**Epic 1 → Epic 4:** Recipes must exist for favorites/notes/chat
**Epic 2 → Epic 3:** AI infrastructure (Sidekiq, prompts) from Epic 2 used in Epic 3 translations
**Epic 3 → Epic 4:** Full feature set (search, filter, multi-lingual) enhances user experience in Epic 4

**Recommended Sequence:** 1 → 2 → 3 → 4 (linear dependency chain)

---

## Implementation Notes

### Development Approach
- **Solo Developer:** Stories sized for 1-2 day completion
- **Sprint Cadence:** 2-week sprints aligned with epics
- **Testing:** Focus on critical business logic (scaling, nutrition calculation, duplicate detection)
- **Dogfooding:** V uses platform daily to catch bugs and UX issues

### Technical Debt Accepted
- Limited test coverage (RSpec for critical logic only, no E2E tests)
- Basic error handling (Rails defaults, Sidekiq retries)
- No horizontal scaling (single server sufficient for MVP)
- No advanced security (2FA, OAuth deferred to Phase 2)

### Sprint Plan
- **Sprint 1 (Weeks 1-2):** Epic 1 - Foundation (10 stories)
- **Sprint 2 (Weeks 3-4):** Epic 2 - Adaptation (8 stories)
- **Sprint 3 (Weeks 5-6):** Epic 3 - Search/Multi-lingual (10 stories)
- **Sprint 4 (Weeks 7-8):** Epic 4 - User/Admin (12 stories)

### Total Story Count: 40 stories (fits Level 3 scope: 12-40 stories)

---

**Next Step:** Begin Sprint 1 with database schema and recipe model (Story 1.1)
