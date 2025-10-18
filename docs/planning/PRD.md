# recipe Product Requirements Document (PRD)

**Author:** V
**Date:** 2025-10-07
**Project Level:** Level 3 (Full Product)
**Project Type:** Web Application
**Target Scale:** 12-40 stories, 2-5 epics, 8-week MVP timeline

---

## Description, Context and Goals

### Product Description

The recipe platform is a flexible, intelligent web application that adapts to each cook's unique context—their skill level, available ingredients, equipment, dietary needs, and native language—rather than forcing cooks to adapt to rigid recipes.

**Core Value Proposition:**
Unlike existing recipe platforms that assume one skill level, one language, and exact ingredient quantities, our platform provides:

1. **Smart Scaling System** - Scale recipes by servings OR by a single ingredient amount ("I have 200g chicken instead of 500g" → entire recipe auto-adjusts)
2. **Adaptive Instruction Variants** - Three pre-generated versions of every step: Original (standard technique), Easier (simplified for beginners), No Equipment (household item alternatives)
3. **True Multi-Lingual Support** - Seven languages (EN, JA, KO, ZH-TW, ZH-CN, ES, FR) with culturally accurate translations, pre-translated for instant UX
4. **Comprehensive Search & Filtering** - Fuzzy text search across recipe names and ingredients, filter by nutrition (calories, protein, macros, calorie-to-protein ratios), dietary restrictions (vegetarian, gluten-free, keto, etc.), cooking time, cuisine type, dish type (main course, soup, dessert), and recipe type (baking, stir-fry, quick weeknight). Progressive nutrition database strategy ensures cost efficiency.
5. **AI-Powered Flexibility** - Recipe discovery, variant generation, and translations powered by AI, with cost-efficient pre-computation approach

**Target Users:**
Intentionally broad—anyone who cooks—because the platform adapts to users rather than targeting a narrow niche. Key segments include serious home cooks, fitness-conscious cooks tracking macros, beginners needing simpler instructions, and multi-lingual cooks seeking authentic recipes in their native language.

**Strategic Approach:**
Dogfooding-first development where the creator (V) uses the platform daily for actual cooking. MVP success = tool solves real friction in personal cooking workflow, validated with friends' feedback, while demonstrating full-stack product development skills (Rails + Vue.js + AI integration).

### Deployment Intent

**Production SaaS/Application** - Public web application deployed for real-world use

**MVP Launch Strategy:**
- 8-week development timeline (solo developer)
- Launch with 50+ curated recipes
- Target 100+ active users in first month (friends, family, early adopters)
- Operating costs <$100/month
- Web-first, mobile-responsive (no native apps for MVP)

**Technical Foundation:**
- Backend: Ruby on Rails, PostgreSQL with JSONB, Sidekiq + Redis
- Frontend: Vue.js 3, Volt PrimeVue, Pinia state management
- AI: Anthropic Claude API for translations, variants, recipe discovery
- Nutrition: Nutritionix API → progressive proprietary database
- Infrastructure: Railway/Render/Heroku, managed PostgreSQL, Cloudflare CDN

**Post-MVP Vision:**
- Phase 2: AI chat integration, social features, meal planning, shopping lists
- Year 1-2: 10,000+ users across 7 language regions, 2,000+ recipes
- Year 2-3: Creator economy (open platform for recipe creators, monetization)
- Year 3+: Cooking intelligence platform (personalized recommendations, computer vision, smart kitchen integrations)

### Context

**The Problem:**
Recipe websites and apps force users into rigid, one-size-fits-all experiences. They assume all cooks have the same skill level, speak the same language, work with exact ingredient quantities, and don't need nutritional information for meal planning. This creates friction for everyone—from beginners who need simpler instructions to experienced cooks scaling recipes, to fitness-conscious users tracking macros, to non-English speakers seeking authentic recipes in their native language.

**Current State Failures:**
- **AllRecipes, Food Network, NYT Cooking:** Only basic serving multiplication, no single-ingredient scaling
- **MyFitnessPal:** Nutrition tracking divorced from recipe discovery and cooking experience
- **Google Translate on recipe sites:** Loses cultural context, produces awkward ingredient translations
- **Recipe blogs:** No standardization, inconsistent nutrition data, overwhelming ads

**Quantifiable Pain Points:**
- Users waste time converting measurements manually or using separate calculator apps
- Non-English speakers miss authentic recipes or suffer poor machine translations
- Fitness-conscious cooks can't efficiently filter by calorie-to-protein ratios
- Beginners struggle with technical cooking terminology and specialized equipment requirements
- Experienced cooks lack flexibility to scale by "what they have on hand" rather than fixed serving sizes

**Why Now:**
Three converging trends make this urgent:
1. **Fitness culture growth** - More people tracking macros and optimizing nutrition
2. **Global cooking interest** - Demand for authentic recipes from diverse cuisines in native languages
3. **AI maturity** - Natural language processing can now handle nuanced translation and instruction adaptation at scale, cost-effectively

**Market Opportunity:**
Low financial risk (~$2,600/year operating costs), high learning value (full-stack Rails + Vue.js + AI integration), personal utility (solve real cooking friction), portfolio demonstration of product thinking and end-to-end execution.

### Goals

**Primary Goal: Dogfooding Validation**
Build a useful tool for personal cooking that V uses daily. Success means the tool solves real friction V experiences, saves time vs current workflow (manual scaling, multiple apps), and features work reliably.

**MVP Success Criteria (8 weeks):**

1. **Technical Success**
   - All 7 core features functional and tested
   - 95%+ uptime in first month
   - <2 second page load times
   - Mobile-responsive design works on phones/tablets
   - 50+ curated recipes in database at launch
   - Deployed and publicly accessible
   - Operating costs <$100/month

2. **Learning Objectives**
   - Master full-stack Rails + Vue.js development
   - Build production-ready AI integrations (Claude API)
   - Implement progressive database strategy successfully
   - Deploy and maintain real-world application

**Strategic Goals:**

1. **Build Strategic Assets**
   - Proprietary nutrition database (reduces dependency, lowers costs to ~$50/month by month 12)
   - Multi-lingual recipe corpus (competitive moat)
   - User behavior data (informs feature priorities)

2. **Data-Driven Development**
   - Log all AI chat questions to identify feature gaps (Phase 2)
   - Track feature usage to validate assumptions
   - User feedback loop for continuous improvement

3. **Quality Over Quantity**
   - Start with curated, high-quality recipes
   - Focus on core features working excellently
   - Expand breadth after depth is proven

## Requirements

### Functional Requirements

**FR1: Recipe Viewing System**
- Display recipes with clean, distraction-free reading experience
- JSON-based recipe structure stored in PostgreSQL JSONB
- Recipe schema includes: servings, timing, nutrition, dietary tags, dish types, recipe types, cuisines, ingredient groups, cooking steps, equipment
- Support recipe aliases for search discoverability
- **Three Instruction Variants per Step:**
  - **Original:** Standard cooking technique for experienced cooks (admin-authored or imported)
  - **Easier:** Simplified for beginners - removes jargon, adds guidance, breaks down complex actions, includes time estimates and sensory cues
  - **No Equipment:** Household item alternatives when specialized tools unavailable (whisk → fork, food processor → knife, etc.)
- Pre-generated variants created by AI at recipe save time for instant user access (no waiting during cooking)
- User can toggle between variants per step independently (mix and match)
- Variants maintain same end result, only approach differs

**FR2: Smart Scaling**
- **Scale by Servings:** Multiply/divide all ingredient amounts proportionally (e.g., 2x, 4x, 0.5x)
- **Scale by Single Ingredient:** User specifies target amount for one ingredient ("I have 200g chicken"), system calculates scaling factor and adjusts entire recipe
- Context-aware precision: Baking recipes maintain precise measurements (grams), cooking recipes use friendly fractions
- Intelligent unit conversion with friendly rounding (0.66 cups → 2/3 cup)
- Unit step-down when appropriate (1.5 tbsp → 1 tbsp + 1.5 tsp)
- Nutrition automatically recalculates based on scaling factor
- Real-time client-side scaling for instant feedback (<100ms)

**FR3: Multi-Lingual Support**
- Seven languages supported: English, Japanese, Korean, Chinese (Traditional), Chinese (Simplified), Spanish, French
- Pre-translation at recipe save time (not real-time) for optimal UX
- Culturally accurate ingredient translations (preserve authenticity over literal translation)
- All recipe fields translatable: name, aliases, ingredient names, cooking steps, equipment
- Language selector in UI, persists user preference
- Background job pipeline for translation processing

**FR4: Comprehensive Search & Filtering**
- **Fuzzy Text Search:** Search across recipe names, aliases, and ingredient names with tolerance for typos
- **Nutrition Filters:** Filter by calories (range), protein (range), carbs (range), fat (range), calorie-to-protein ratio
- **Dietary Tags:** Filter by dietary restrictions (vegetarian, vegan, gluten-free, dairy-free, keto, paleo, etc.) - supports multiple selections
- **Cooking Time:** Filter by prep time, cook time, total time (range sliders or input fields)
- **Cuisine Type:** Filter by cuisine (Japanese, Italian, Mexican, Thai, Chinese, etc.)
- **Dish Type:** Filter by category (main course, soup, dessert, side dish, appetizer, breakfast, etc.)
- **Recipe Type:** Filter by cooking method or style (baking, stir-fry, grilling, one-pot, quick weeknight, etc.)
- **Combined Filters:** All filters work together (AND logic) to narrow results
- Large filter toolbar UI with no range sliders—use number inputs and multi-select dropdowns
- Real-time result updates as filters change
- Filter state persists across sessions

**FR5: Nutrition Integration**
- Display nutrition per serving (calories, protein, carbs, fat, fiber)
- Nutritionix API integration as primary data source
- Progressive nutrition database: Cache all API responses permanently, build proprietary ingredient database over time
- Fuzzy ingredient matching system to reduce API calls
- Target 95% database hit rate by month 12
- Fallback to USDA FoodData Central for free tier
- AI estimation for ingredients not found in APIs (low confidence flagged)
- Auto-adjust nutrition display when recipe is scaled

**FR6: User System**
- User authentication via Devise (email/password)
- User roles: Standard User, Admin
- Favorite recipes: Users can save recipes to favorites list
- User notes: Attach notes at recipe level, step level, or ingredient level
- Notes are private to user, not shared publicly
- User dashboard showing favorites and recent activity
- Preferred language setting per user

**FR7: Admin Recipe Management**
- **Recipe CRUD:** Create, Read, Update, Delete operations on recipes
- **Multiple Recipe Input Methods:**
  1. **Manual Entry:** Admin-only form for creating recipes with all fields (ingredients, steps, metadata)
  2. **Text Block Import:** Paste large recipe text, AI parses and extracts structured data (ingredients, steps, metadata), admin reviews and edits before saving
  3. **URL Import:** Enter recipe URL, AI scrapes page and extracts recipe data, admin reviews and edits before saving
  4. **Image Import:** Upload recipe image (cookbook photo, handwritten note, screenshot), AI uses vision to extract recipe, admin reviews and edits before saving
- **AI Import Review Flow:** All AI-imported recipes open in edit form pre-filled with extracted data, admin makes corrections/adjustments, then saves
- **Duplicate Detection:** Fuzzy matching on recipe names and aliases, warn admin if similar recipe exists (>85% similarity) before saving
- **Background Job Triggers:** Manually trigger variant generation or translation jobs for recipes (useful for regenerating after prompt changes)
- **Recipe List View:** Paginated table with search, filters (cuisine, dietary tags, published status), sort by created/updated date
- **Bulk Actions:** Bulk delete, bulk regenerate variants, bulk retranslate
- Recipe versioning and audit trail (created_at, updated_at, source_url, admin_notes, import_method)
- **Recipe Preview:** Preview recipe as users see it before publishing

**FR8: Admin Data Reference Management**
- **Dietary Tags Manager:** View, create, edit, deactivate dietary tags (vegetarian, vegan, gluten-free, etc.)
- **Dish Types Manager:** Manage dish type categories (main course, soup, dessert, etc.)
- **Cuisines Manager:** Manage cuisine list (Japanese, Italian, Mexican, etc.) with regional groupings
- **Recipe Types Manager:** Manage recipe type classifications (baking, stir-fry, quick weeknight, etc.)
- **Units & Conversions Manager:** Manage measurement units and conversion rates
- **Equipment Manager:** Manage equipment list and household alternatives
- All reference data stored in database, editable via admin UI (no code changes needed)
- Sort order, active/inactive status, display names customizable
- Changes apply immediately to all recipes using those references

**FR9: Admin Prompt Management**
- **AI Prompts Database:** All AI prompts stored in database (step variants, translations, recipe discovery, nutrition estimation)
- **Prompt Editor:** View and edit prompt text, description, variables used
- **Prompt Testing:** Test prompts with sample data, see rendered output and estimated token count
- **Version Control:** Create new prompt versions without breaking active prompts
- **Activate/Deactivate:** Switch between prompt versions, only active prompts used by system
- **Feature Grouping:** Prompts organized by feature area (step variants, translation, recipe discovery, nutrition)
- **Variable System:** Template variables like `{{recipe_name}}` get replaced at runtime
- No code deployment needed to modify AI behavior—all editable via admin UI

**FR10: Admin System Monitoring**
- **Job Queue Dashboard:** View Sidekiq job queue status, pending jobs, failed jobs
- **Job Retry:** Manually retry failed background jobs
- **API Usage Tracking:** Monitor Claude API and Nutritionix API usage, costs, rate limits
- **System Health:** Database size, recipe count, user count, storage usage
- **Error Logs:** View recent errors with stack traces and context
- **Performance Metrics:** Page load times, database query times, API response times
- **User Activity:** Recent user signups, active users, popular recipes

**FR11: Background Job Processing**
- **Generate Step Variants Job:** For each step, call Claude API to generate "Easier" and "No Equipment" variants, store in recipe JSONB
- **Translate Recipe Job:** For each of 6 non-English languages, call Claude API to translate recipe fields, store in recipe.translations JSONB
- **Nutrition Lookup Job:** For each ingredient, query NutritionLookupService (API or database), aggregate nutrition totals, calculate per-serving values
- Sidekiq + Redis for job queue management
- Retry logic with exponential backoff for API failures
- Job status tracking (variants_generated, translations_completed flags on recipe)
- Admin dashboard to monitor job queue and failures

**FR12: Progressive Nutrition Database**
- Ingredients table with canonical names and categories
- Ingredient nutrition table (per 100g values: calories, protein, carbs, fat, fiber)
- Data source tracking (Nutritionix, USDA, AI) with confidence scores
- Ingredient aliases table supporting multi-lingual synonyms and misspellings
- Fuzzy matching algorithm to find existing ingredients before API calls
- Admin tools to review and correct nutrition data
- Database-first lookup, API fallback, AI estimation as last resort

**FR13: Ingredient Substitution (Quick Replace)**
- **One-Click Ingredient Swap:** Each ingredient has a "Replace" button/icon for quick substitution
- **Substitution UI:** Click ingredient → modal/dropdown shows common substitutions for that ingredient
- **Smart Suggestions:** System suggests appropriate substitutions based on ingredient type:
  - Butter → Olive oil, coconut oil, margarine
  - Milk → Almond milk, oat milk, soy milk
  - Eggs → Flax eggs, applesauce, aquafaba
  - Sugar → Honey, maple syrup, agave
- **Quantity Adjustment:** Substitution ratios automatically applied (e.g., 1 cup butter → 3/4 cup oil)
- **Session-Based:** Substitutions apply to current session only, don't alter base recipe
- **Nutrition Recalculation:** Nutrition values automatically update when ingredients are substituted
- **Save Substitutions:** Users can save their substituted version as a personal recipe variant
- **Substitution Library:** Admin-configurable substitution mappings in database (ingredient → [substitutes with ratios])

**FR14: AI Recipe Customization (Session-Based Chat)**
- **AI Chat Interface:** Users can ask questions and request modifications to recipes via natural language
- **Session-Based Modifications:** Changes apply only to current viewing session, don't alter base recipe
- **Supported Customizations:**
  - Advanced ingredient substitutions ("Can I use honey instead of sugar?" - beyond quick replace options)
  - Technique explanations ("What does 'fold' mean?")
  - Equipment alternatives ("I don't have a stand mixer")
  - Dietary adaptations ("Make this vegan")
  - Scaling adjustments ("Double just the sauce")
  - Timing questions ("Can I prep this ahead?")
- **Save Personal Versions:** Users can save AI-modified recipes to their account as personal variants
- **Prompt Logging:** All AI chat prompts logged for feature discovery (identify common requests → build into core features)
- **Context Awareness:** AI has access to full recipe context (ingredients, steps, equipment, dietary tags)
- **Claude API Integration:** Real-time streaming responses for natural conversation feel
- **Cost Management:** Rate limiting per user session, clear usage indicators

**FR15: Recipe Viewing Features**
- Toggle instruction variants (Original / Easier / No Equipment) per step with instant switching
- Collapsible ingredient groups for better organization
- Equipment list display with icons
- Timing information (prep, cook, total) prominently shown
- Dietary tags displayed as chips/badges
- Print-friendly view (deferred to Phase 2, but structure supports it)
- Mobile-responsive layout optimized for phone use while cooking

### Non-Functional Requirements

**NFR1: Performance**
- Page load time <2 seconds for recipe pages
- Recipe scaling updates <100ms (instant feedback)
- Search and filter results <500ms
- Background jobs process recipes within 5 minutes of creation
- Database queries optimized with GIN indexes on JSONB fields
- CDN for static assets (Cloudflare)

**NFR2: Reliability**
- 95%+ uptime target
- Graceful degradation if background jobs fail (show recipe without variants/translations)
- Database backups daily with point-in-time recovery
- Error logging and monitoring (Rails logger + external service)
- API rate limiting to prevent quota exhaustion

**NFR3: Scalability**
- Support 100-1000 concurrent users (MVP scale)
- Database connection pooling for concurrent requests
- Horizontal scaling possible with Rails architecture (future)
- JSONB indexing for efficient queries at 10K+ recipe scale
- Background job workers scale independently from web processes

**NFR4: Security**
- HTTPS only (SSL/TLS)
- Authentication required for user features (favorites, notes)
- Admin role authorization for recipe management and system config
- CSRF protection (Rails default)
- SQL injection prevention via ActiveRecord ORM
- API keys stored in environment variables, never committed to git
- Rate limiting on public API endpoints

**NFR5: Usability**
- Mobile-first responsive design (works on phones, tablets, desktops)
- Intuitive UI using Volt PrimeVue component library
- Accessibility: Keyboard navigation, screen reader friendly, sufficient color contrast (WCAG 2.1 AA where feasible)
- Consistent UI patterns across all pages
- Clear error messages and validation feedback
- No user manual required—self-explanatory interface

**NFR6: Maintainability**
- Clean codebase following Rails conventions
- AI prompts stored in database, editable via admin UI (no code changes needed)
- Data references (tags, types, cuisines) stored in database, editable via admin UI
- Comprehensive inline comments for complex logic (scaling algorithm, nutrition calculation)
- RSpec tests for critical business logic (scaling, nutrition calculation, duplicate detection)
- Version control with Git, hosted on GitHub

**NFR7: Cost Efficiency**
- Operating costs <$100/month for MVP
- Progressive nutrition database reduces API costs over time (target <$50/month by month 12)
- Pre-generated variants avoid real-time AI costs during user sessions
- Free tier usage for APIs where possible (Nutritionix free tier, USDA FoodData free)
- Efficient database design minimizes storage costs
- Self-hosted deployment (Railway/Render) to avoid SaaS markups

**NFR8: Internationalization**
- UTF-8 encoding throughout system
- Support for non-Latin scripts (Japanese, Korean, Chinese)
- Right-to-left language support (deferred, but architecture supports it)
- Timezone-aware timestamps (UTC storage, local display)
- Currency and measurement unit localization (future)

**NFR9: Browser Compatibility**
- Last 2 versions of major browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers (iOS Safari, Chrome Android)
- No IE11 support required
- Progressive enhancement approach (core functionality works without JavaScript)

**NFR10: Data Integrity**
- Foreign key constraints on user-recipe relationships (favorites, notes)
- JSON schema validation for recipe JSONB fields
- Unique constraints on recipe names per language
- Ingredient canonical names unique across system
- Database transactions for multi-step operations
- Audit trail for recipe changes (timestamps, admin notes)

## User Journeys

### Journey 1: Fitness-Conscious Cook - Finding and Scaling High-Protein Recipe

**Persona:** Sarah, 28, fitness enthusiast who tracks macros and needs recipes that fit her daily targets (500 calories, 40g+ protein per meal).

**Goal:** Find a high-protein dinner recipe and scale it to her available ingredients.

**Journey Steps:**

1. **Search & Filter**
   - Sarah visits recipe platform on her phone
   - Opens filter toolbar
   - Sets nutrition filters: Max calories 600, Min protein 35g, Calorie-to-protein ratio < 15
   - Selects dietary tag: "gluten-free" (she has celiac)
   - Filters by cooking time: < 30 minutes (busy weeknight)
   - Views filtered results: 12 recipes match her criteria

2. **Recipe Discovery**
   - Browses recipe cards showing nutrition highlights (520 cal, 38g protein)
   - Selects "Chicken Teriyaki Bowl" - looks promising
   - Recipe page loads with clear nutrition display per serving

3. **Smart Scaling Decision Point**
   - Recipe calls for 300g chicken thigh, but Sarah only has 250g in her fridge
   - She doesn't want to scale by servings (original is 2 servings, she needs 1.5 servings worth)
   - Clicks "Scale by Ingredient" → selects chicken thigh → enters "250g"
   - System calculates 0.83x scaling factor, adjusts all ingredients proportionally
   - Nutrition automatically recalculates: 433 calories, 31.5g protein
   - Perfect fit for her macros!

4. **Cooking with Adaptive Instructions**
   - Starts cooking, follows "Original" instructions for first few steps
   - Step 4: "Julienne the vegetables" - Sarah isn't confident with knife skills
   - Toggles to "Easier" variant: "Cut vegetables into thin strips about matchstick size, don't worry if they're not perfect"
   - Continues cooking with confidence

5. **Save for Future**
   - Meal turns out great
   - Clicks "Favorite" to save to her account
   - Adds personal note: "Great with broccoli instead of bell peppers"
   - Next time she cooks it, her note appears as a reminder

**Value Delivered:**
- Found recipe matching exact nutrition needs in <2 minutes
- Scaled recipe to available ingredients without math
- Adaptive instructions prevented intimidation
- Saved time vs using multiple apps (recipe site + MyFitnessPal + calculator)

---

### Journey 2: Beginner Cook - Learning to Make Pasta Carbonara

**Persona:** Alex, 22, recent college grad living alone, limited cooking experience, wants to learn beyond instant ramen.

**Goal:** Cook an impressive pasta dish without expensive equipment or getting overwhelmed by technique jargon.

**Journey Steps:**

1. **Discovery Through Search**
   - Alex searches "easy pasta" in recipe search bar
   - Filters by: Recipe type "quick weeknight", Max cook time 30 min
   - Finds "Classic Carbonara" - 25 minutes, looks manageable
   - Opens recipe

2. **Initial Overwhelm → Adaptive Solution**
   - Reads ingredients: looks okay
   - Step 1 instruction (Original): "Temper the eggs by slowly whisking in pasta water to prevent curdling"
   - Alex thinks: "What does 'temper' mean? How do I know if it's curdling?"
   - Notices toggle buttons: Original / Easier / No Equipment
   - Switches ALL steps to "Easier" mode

3. **Easier Instructions Walkthrough**
   - Step 1 (Easier): "Beat the eggs in a bowl. When your pasta water is ready, add 2 tablespoons of the hot water very slowly to the eggs while stirring constantly. This warms the eggs gently so they don't scramble. If you see any solid bits forming, you're adding water too fast."
   - Alex: "Okay, I can do that. That makes sense."
   - Continues through recipe with Easier variants, feels supported

4. **Equipment Challenge**
   - Step 3 calls for "whisk" - Alex doesn't own one
   - Switches just this step to "No Equipment" variant
   - "No Equipment" version: "Use a fork to vigorously beat the eggs - it takes a bit more effort but works fine"
   - Alex uses fork, continues cooking

5. **Success & Learning**
   - Carbonara turns out delicious
   - Alex gained confidence, learned new techniques
   - Clicks favorite, adds note: "First time cooking pasta from scratch - turned out great!"
   - Feels motivated to try more recipes

**Value Delivered:**
- Didn't give up due to confusing terminology
- Equipment limitations didn't block cooking
- Built confidence through clear, reassuring guidance
- Learned actual cooking skills vs just following rigid steps

---

### Journey 3: Multi-Lingual User - Finding Authentic Japanese Recipe

**Persona:** Yuki, 35, Japanese native living in the US, wants authentic Japanese recipes in Japanese language with proper ingredient names.

**Goal:** Find authentic Oyakodon recipe with Japanese instructions and ingredient names she can actually find in Japanese grocery stores.

**Journey Steps:**

1. **Language Preference**
   - Yuki visits platform, sees language selector in navigation
   - Switches from English to Japanese (日本語)
   - Entire UI updates to Japanese

2. **Search in Native Language**
   - Searches: "親子丼" (Oyakodon)
   - Filter by cuisine: 日本料理 (Japanese cuisine)
   - Finds multiple Oyakodon variations

3. **Reviewing Authentic Recipe**
   - Opens recipe: "親子丼（鶏と卵の丼）"
   - Ingredients show proper Japanese names:
     - "鶏もも肉" (chicken thigh) not awkward translation like "親鳥肉"
     - "長ネギ" (negi) not "green onion"
     - "出汁" (dashi) not "Japanese soup stock"
   - Instructions fully in Japanese, natural phrasing
   - Yuki recognizes this as authentic recipe, not machine-translated

4. **Scaling for Family Dinner**
   - Original recipe: 2人前 (2 servings)
   - Yuki needs to feed family of 4
   - Clicks "スケール" (Scale) → selects "4人前" (4 servings)
   - All ingredients double: 300g → 600g chicken, etc.

5. **Sharing Discovery**
   - Excited to find platform with proper Japanese recipes
   - Shares link with Japanese friends in the US
   - Adds to favorites for weekly cooking rotation

**Value Delivered:**
- Authentic Japanese recipe with culturally accurate ingredient names
- No awkward machine translation destroying cooking context
- Feels like using Japanese recipe site, but with smart features
- Solves major pain point: finding authentic recipes in native language abroad

## UX Design Principles

**1. Mobile-First, Always Accessible**
- Design for phone use while cooking (hands may be messy, screen at distance)
- Large touch targets (min 44x44px), high contrast text
- Minimal scrolling required during active cooking
- Sticky ingredient list/step navigation
- Works offline for viewed recipes (future enhancement)

**2. Instant Feedback, No Waiting**
- Recipe scaling updates <100ms (client-side calculation)
- Instruction variant toggles instant (pre-generated, no API calls)
- Filter results update in real-time as user adjusts
- Progress indicators for background operations (translations, variant generation)
- Optimistic UI updates (assume success, rollback on failure)

**3. Clarity Over Cleverness**
- Plain language, no unnecessary jargon
- Clear visual hierarchy (ingredients → steps → nutrition)
- Consistent iconography throughout (scale, favorite, notes, etc.)
- Error messages explain what happened and how to fix it
- No hidden features—discoverability through clear UI patterns

**4. Smart Defaults, Powerful Overrides**
- Defaults work for 80% of users (metric units in EU, imperial in US based on locale)
- Advanced options available but not blocking
- Filter toolbar starts collapsed, expands when needed
- "Easier" variant suggested for first-time users, preference saved
- Undo/reset always available

**5. Respect User Context**
- Remember language preference across sessions
- Persist filter state (don't make user re-filter every visit)
- Save scroll position when navigating back to recipe list
- User notes visible inline where they matter (at that step/ingredient)
- Adaptive instruction variants respect user's skill level choice

**6. Minimize Cognitive Load**
- One primary action per screen (cooking a recipe, browsing recipes, filtering)
- Progressive disclosure (show essentials, hide details until needed)
- Collapsible sections reduce visual clutter
- Clear section separation (ingredients ≠ instructions ≠ nutrition)
- No popups or interstitials while cooking

**7. Build Trust Through Transparency**
- Nutrition data source indicated (Nutritionix/USDA/AI estimation)
- AI-generated content clearly marked (step variants, translations)
- Confidence scores shown for low-quality data
- Recipe source attribution visible (imported from URL, admin-created)
- Clear privacy: user notes are private, not shared

**8. Delight in Details**
- Smooth animations (ingredient scaling numbers count up/down)
- Subtle success feedback (favorite heart fills, note saved checkmark)
- Empty states guide next action ("No favorites yet—browse recipes!")
- Celebrate milestones (first recipe cooked, 10 favorites saved)
- Clean, appetizing recipe photography (when available)

**9. Accessibility by Default**
- Keyboard navigation works for all features
- Screen reader announcements for dynamic updates (scaled ingredients)
- Sufficient color contrast (WCAG AA minimum)
- Text resizable without breaking layout
- Focus indicators clearly visible

**10. Performance as Feature**
- Fast page loads (<2s) feel responsive
- Lazy load recipe images (prioritize text/functionality)
- CDN for static assets
- Database query optimization visible in snappy filtering
- Background jobs don't block user actions

## Epics

### Epic Overview

The recipe platform MVP is organized into **4 core epics** delivering value incrementally over 8 weeks. Each epic represents a complete vertical slice of functionality that can be developed, tested, and validated independently.

**Epic 1: Recipe Foundation & Viewing** (Weeks 1-2)
- Core recipe data model, display system, and basic viewing features
- Enables admin to create recipes and users to view them
- Foundation for all subsequent features

**Epic 2: Smart Recipe Adaptation** (Weeks 3-4)
- Smart scaling (by servings and by ingredient)
- Three instruction variants (Original/Easier/No Equipment)
- Ingredient substitution system
- Makes recipes flexible and adaptive to user needs

**Epic 3: Search, Filtering & Multi-Lingual** (Weeks 5-6)
- Comprehensive search and filtering system
- Multi-lingual support (7 languages)
- Nutrition integration and database
- Enables discoverability and accessibility

**Epic 4: User Features & Admin Tools** (Weeks 7-8)
- User authentication, favorites, notes
- AI recipe customization (chat interface)
- Admin management tools and monitoring
- Completes full user experience and operational capabilities

---

### Epic 1: Recipe Foundation & Viewing
**Goal:** Establish core recipe data model and basic viewing capabilities to enable recipe creation and consumption.

**User Value:** Users can browse and view recipes with clean, mobile-optimized interface. Admins can create and manage recipe content.

**Success Criteria:**
- Admin can create recipes with full schema (ingredients, steps, metadata)
- Users can view recipes with clear layout (ingredients, steps, timing, nutrition)
- Mobile-responsive design works on phones and tablets
- Recipe data stored in PostgreSQL JSONB with proper indexing
- 10+ recipes created and viewable by end of epic

**Technical Foundation:**
- Rails backend with Recipe model (JSONB fields)
- Vue.js frontend with PrimeVue components
- PostgreSQL database with GIN indexes
- Basic routing and API endpoints
- Devise authentication (user roles: user, admin)

---

### Epic 2: Smart Recipe Adaptation
**Goal:** Make recipes flexible and adaptable through smart scaling, instruction variants, and ingredient substitution.

**User Value:** Recipes adjust to what users have on hand (ingredients, equipment, skill level) rather than forcing exact adherence.

**Success Criteria:**
- Users can scale recipes by servings with real-time UI updates (<100ms)
- Users can scale by single ingredient amount ("I have 200g chicken")
- All recipes have 3 instruction variants per step (Original/Easier/No Equipment) generated by AI
- Users can toggle variants per step independently
- Users can substitute ingredients with smart suggestions and nutrition recalculation
- Background jobs generate variants and handle API failures gracefully

**Technical Components:**
- Client-side scaling algorithm (RecipeScaler service)
- Sidekiq + Redis for background jobs
- Claude API integration for variant generation
- AI prompt management system (database-driven)
- Ingredient substitution library and UI

---

### Epic 3: Search, Filtering & Multi-Lingual
**Goal:** Enable recipe discoverability through comprehensive search/filtering and support 7 languages with authentic translations.

**User Value:** Users find recipes matching exact needs (nutrition, dietary restrictions, time, cuisine). Non-English speakers access authentic recipes in native language.

**Success Criteria:**
- Fuzzy text search across recipe names, aliases, ingredients
- Multi-dimensional filtering: nutrition, dietary tags, time, cuisine, dish type, recipe type
- Filter combinations work together (AND logic)
- Real-time filter results (<500ms)
- 7 languages supported with culturally accurate translations
- Progressive nutrition database operational (API → cache → database)
- 50+ recipes fully translated and filterable

**Technical Components:**
- PostgreSQL full-text search with GIN indexes
- Filter query builder (complex WHERE clauses)
- Translation background jobs (Claude API)
- Nutrition lookup service (Nutritionix → USDA → AI fallback)
- Ingredient matching algorithm (fuzzy search)

---

### Epic 4: User Features & Admin Tools
**Goal:** Complete user experience with personalization features and provide admin operational tools.

**User Value:** Users save favorites, add notes, customize recipes via AI chat. Admins have full control over content, prompts, and system monitoring.

**Success Criteria:**
- Users can favorite recipes and add notes (recipe/step/ingredient level)
- AI chat interface allows recipe customization (substitutions, technique questions, dietary adaptations)
- Session-based AI modifications with option to save personal variants
- Admin recipe management (list, create, edit, delete, preview, bulk actions)
- Admin data reference management (tags, cuisines, types, units)
- Admin prompt management (edit AI prompts without code deployment)
- Admin system monitoring (job queue, API usage, errors, performance)
- Duplicate recipe detection prevents duplicates

**Technical Components:**
- User favorites and notes tables with foreign keys
- AI chat integration (Claude API streaming)
- Session state management for recipe modifications
- Admin UI (PrimeVue DataTable, forms, modals)
- Prompt versioning system
- System monitoring dashboard (Sidekiq, API metrics)

---

**Epic Dependencies:**
- Epic 1 → Epic 2 (scaling needs recipe data model)
- Epic 1 → Epic 3 (search/filter needs recipe data)
- Epic 1 → Epic 4 (user features need recipes to favorite/note)
- Epic 2 → Epic 3 (variants need AI infrastructure from Epic 2)
- Epic 3 → Epic 4 (admin tools benefit from full feature set)

**Recommended Sequence:** 1 → 2 → 3 → 4 (linear dependency chain, each builds on previous)

---

**Note:** Detailed epic breakdown with user stories and acceptance criteria available in [epics.md](epics.md)

## Next Steps

### Immediate Actions (Post-PRD Approval)

1. **Architecture Design** ⚠️ REQUIRED BEFORE DEVELOPMENT
   - Create architecture.md covering system design, data flow, API design
   - Database schema detailed design with migrations plan
   - Frontend component architecture and state management
   - Background job architecture and error handling strategies
   - AI integration patterns and cost management approach
   - **Start new chat with architect** or **run architecture workflow**

2. **UX/UI Specification** (Recommended for UI-heavy project)
   - Information architecture and navigation design
   - User flows for all major features
   - Component library setup (PrimeVue configuration)
   - Wireframes for key screens (recipe view, recipe list, filter toolbar, admin dashboard)
   - Optional: Generate AI Frontend Prompt for rapid prototyping

3. **Detailed Story Generation**
   - Break down each epic into granular user stories with acceptance criteria
   - Estimate story points and sprint allocation
   - Identify technical spikes needed (e.g., JSONB query performance testing)

### Development Preparation

4. **Environment Setup**
   - Initialize Rails project with PostgreSQL
   - Set up Vue.js 3 + Vite frontend
   - Configure Sidekiq + Redis
   - Set up development database with seed data
   - Configure Claude API and Nutritionix API keys

5. **Repository & CI/CD**
   - GitHub repository initialization
   - Basic CI pipeline (RSpec tests, linting)
   - Deployment pipeline to Railway/Render/Heroku
   - Environment variable management (.env setup)

6. **Sprint Planning**
   - 8 weeks = 4 sprints of 2 weeks each (aligns with epic timeline)
   - Sprint 1: Epic 1 (Foundation)
   - Sprint 2: Epic 2 (Adaptation)
   - Sprint 3: Epic 3 (Search/Multi-lingual)
   - Sprint 4: Epic 4 (User Features/Admin)
   - Buffer time in each sprint for testing and bug fixes

### Validation Checkpoints

7. **Milestone Reviews**
   - End of Epic 1: Recipe viewing works, admin can create recipes
   - End of Epic 2: Scaling and variants functional, dogfood test
   - End of Epic 3: Search/filter works, multi-lingual tested by native speakers
   - End of Epic 4: Full system functional, ready for beta users

8. **Pre-Launch**
   - Load 50+ curated recipes with translations and variants
   - Test on multiple devices (phone, tablet, desktop)
   - Share with friends for beta testing feedback
   - Monitor API costs and system performance
   - Fix critical bugs

9. **Launch & Iterate**
   - Deploy to production
   - Share with target user groups
   - Collect feedback via in-app form or email
   - Monitor usage analytics (which features used most?)
   - Prioritize Phase 2 features based on real user behavior

## Document Status

- [x] Goals and context validated with stakeholder (V)
- [x] All functional requirements reviewed (FR1-FR15)
- [x] All non-functional requirements reviewed (NFR1-NFR10)
- [x] User journeys cover major personas (3 comprehensive journeys)
- [x] UX principles established (10 principles)
- [x] Epic structure approved for phased delivery (4 epics, 8 weeks)
- [ ] Ready for architecture phase → **Next: Start architecture workflow**

---

_This PRD adapts to project level 3 - providing appropriate detail for a full product without overwhelming a solo developer._

