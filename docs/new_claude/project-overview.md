# Project Overview

**Project:** Recipe App (Ember)

---

## Core Features

- **Smart Scaling** - Adjust servings or scale by specific ingredients with context-aware precision
- **Adaptive Instructions** - Each step has 3 pre-generated variants (Original, Easier, No Equipment)
- **Multi-lingual** - 7 languages (en, ja, ko, zh-tw, zh-cn, es, fr)
- **Nutrition-First Search** - Filter by dietary needs, nutrition values, cuisines

---

## Technology Stack

### Backend
- **Ruby on Rails 8.0.3** (API-only mode)
- **PostgreSQL 14+** with JSONB and full-text search
- **Redis 7+** for caching and background jobs
- **Sidekiq** for async processing
- **Devise + JWT** for authentication
- **RSpec** for testing

### Frontend
- **Vue.js 3** with Composition API and TypeScript
- **PrimeVue** (Aura theme) for UI components
- **Pinia** for state management
- **Vue Router** for navigation
- **Vue I18n** for internationalization
- **Axios** for API calls

### External Services
- **Anthropic Claude API** - AI-powered recipe parsing, translation, and variant generation
- **Nutritionix API** - Ingredient nutrition data (progressive migration to proprietary database)

### Infrastructure (Planned)
- **Railway/Render/Heroku** - Backend hosting
- **Vercel/Netlify** - Frontend hosting
- **Managed PostgreSQL** - Database
- **Cloudflare CDN** - Asset delivery

---

## Key Features

### 1. Smart Scaling System
- Scale by servings (4 → 8 servings)
- Scale by ingredient (200g chicken → 500g chicken, auto-adjust everything else)
- Context-aware precision (baking vs cooking)
- Unit step-down (1 tbsp → 3 tsp when scaling down)
- Whole item rounding (2.4 eggs → 2 eggs)

**Acceptance Criteria:** AC-SCALE-001 to AC-SCALE-012

### 2. Adaptive Step Instructions
- Each step has 3 AI-generated variants:
  - **Original** - As written by recipe author
  - **Easier** - Simplified for beginners
  - **No Equipment** - Alternative for limited kitchen tools
- Pre-generated (not real-time AI) for instant UX
- User can toggle between variants while cooking

**Acceptance Criteria:** AC-VARIANT-001 to AC-VARIANT-008

### 3. Dynamic Recipe Translation (Mobility)
- 6 non-English languages (ja, ko, zh-tw, zh-cn, es, fr)
- Entire recipe content translated via AI (Claude API)
  - Recipe names, ingredient names, step instructions
  - Preparation notes, equipment names
- Stored in dedicated translation tables (not JSONB)
- TranslateRecipeJob enqueued automatically on recipe creation
- translations_completed flag tracks completion

### 4. Internationalization (i18n) - UI Text
- 7 supported languages (en, ja, ko, zh-tw, zh-cn, es, fr)
- UI text translations via Rails I18n (backend) + Vue I18n (frontend)
- 100% translation coverage requirement (all 7 languages)
- Language switcher in UI (top-right navbar)
- `Accept-Language` header for API localization
- User language preference saved and persists

### 5. Nutrition-First Search
- Filter by dietary tags (vegan, gluten-free, dairy-free, etc.)
- Filter by dish type (breakfast, dinner, dessert)
- Filter by cuisine (Italian, Japanese, Mexican, etc.)
- Filter by nutrition (calories < 300, protein > 20g)
- Full-text search with fuzzy matching

**Acceptance Criteria:** AC-SEARCH-001 to AC-SEARCH-012

### 6. User Personalization
- Save favorite recipes
- Add personal notes to recipes (general, per-ingredient, per-step)
- User-specific scaling preferences
- Preferred language setting

**Acceptance Criteria:** AC-USER-001 to AC-USER-008

### 7. Admin Recipe Management
- Create recipes manually with image upload
- Upload recipe display images (PNG/JPG/GIF/WebP, max 10MB)
- Active Storage support (local disk + AWS S3)
- Import recipes from URLs (AI parsing)
- Import recipes from text (AI parsing)
- Import recipes from images (Vision AI parsing for text extraction)
- Generate step variants (AI)
- Translate recipes to all 7 languages (AI)
- Manage ingredient database
- Manage reference data (dietary tags, cuisines, dish types)

**Acceptance Criteria:** AC-ADMIN-001 to AC-ADMIN-025

---

## Project Structure

```
recipe/
├── backend/                  # Rails API
│   ├── app/
│   │   ├── controllers/     # API endpoints
│   │   ├── models/          # ActiveRecord models
│   │   ├── services/        # Business logic
│   │   └── jobs/            # Background jobs
│   ├── db/
│   │   ├── migrate/         # Database migrations
│   │   └── schema.rb        # Current schema
│   ├── spec/                # RSpec tests
│   └── config/
│       └── locales/         # Backend i18n files (7 languages)
│
├── frontend/                # Vue.js SPA
│   ├── src/
│   │   ├── components/      # Vue components
│   │   │   ├── admin/      # Admin-only components
│   │   │   ├── user/       # User-facing components
│   │   │   └── shared/     # Shared components
│   │   ├── views/           # Page-level views
│   │   ├── stores/          # Pinia stores
│   │   ├── services/        # API clients
│   │   ├── composables/     # Reusable composition functions
│   │   ├── locales/         # Frontend i18n files (7 languages)
│   │   └── assets/
│   │       └── styles/      # CSS (design system)
│   └── public/
│
└── docs/                    # Documentation
    ├── new_claude/          # AI context (streamlined)
    ├── reference/           # Reference data
    └── planning/            # Historical planning docs
```

---

## Current Status

**Phase 0: Project Setup** - Complete
- Rails API, Vue.js frontend, PostgreSQL, Redis configured
- Authentication (Devise + JWT) working

**Phase 1: Database & Models** - Complete
- 9 migrations, all models with validations
- Seeded: 40 dietary tags, 99 cuisines, 16 dish types, 74 recipe types

**Phase 2-5: Feature Development** - In Progress

---

## Key Documents

- **[entry.md](entry.md)** - Development workflow
- **[architecture.md](architecture.md)** - Backend + frontend architecture
- **[acceptance-criteria.md](acceptance-criteria.md)** - All ACs
- **[api-reference.md](api-reference.md)** - API documentation
- **[component-library.md](component-library.md)** - Vue component catalog
- **[database-architecture.md](database-architecture.md)** - Database schema
- **[i18n-workflow.md](i18n-workflow.md)** - Translation workflow
