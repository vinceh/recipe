# Project Overview

**Last Updated:** 2025-10-19
**Project:** Recipe App (Ember)
**Developer:** V
**Timeline:** 8 weeks MVP

---

## What Is This Project?

**Ember** is a flexible, intelligent recipe platform designed to make cooking easier through smart technology. Unlike traditional recipe apps that display static instructions, Ember provides dynamic scaling, adaptive instructions, multi-lingual support, and nutrition-first search capabilities.

### Core Concept

Recipes in Ember are structured data (not just text) with built-in intelligence:
- **Smart Scaling** - Adjust servings or scale by specific ingredients with context-aware precision
- **Adaptive Instructions** - Each step has 3 pre-generated variants (Original, Easier, No Equipment)
- **Multi-lingual** - Full support for 7 languages (English, Japanese, Korean, Traditional Chinese, Simplified Chinese, Spanish, French)
- **Nutrition-First** - Search and filter by dietary needs, not just keywords

### Target Users

1. **Home Cooks** - Anyone who cooks regularly and wants flexibility
2. **Dietary-Conscious Users** - People with dietary restrictions (vegan, gluten-free, keto, etc.)
3. **International Users** - Non-English speakers who need recipes in their language
4. **Recipe Creators** - Content creators and food bloggers who want to publish flexible recipes

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

### 3. Multi-lingual Translation
- 7 supported languages (en, ja, ko, zh-tw, zh-cn, es, fr)
- Entire recipe translated (name, ingredients, steps, equipment)
- AI-powered translation with Claude API
- User's preferred language saved and persists

**Acceptance Criteria:** AC-TRANS-001 to AC-TRANS-010

### 4. Internationalization (i18n)
- 100% translation coverage requirement
- Both frontend (Vue I18n) and backend (Rails I18n)
- Language switcher in UI
- `Accept-Language` header for API localization

**Acceptance Criteria:** AC-I18N-001 to AC-I18N-006

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
- Create recipes manually
- Import recipes from URLs (AI parsing)
- Import recipes from text (AI parsing)
- Import recipes from images (AI parsing)
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

## Development Approach

### Test-Driven Development (Backend)
1. Write Acceptance Criteria (GIVEN-WHEN-THEN format)
2. Write RSpec tests for each AC
3. Implement feature to make tests pass
4. 100% test pass required before commit

### Component-Driven Development (Frontend)
1. Check for existing components before creating new ones
2. Document components while building
3. Use design tokens (CSS variables) for all styling
4. 100% i18n coverage required before commit

### Documentation-First
- All API endpoints documented in [api-reference.md](api-reference.md)
- All components documented in [component-library.md](component-library.md)
- All ACs documented in [acceptance-criteria.md](acceptance-criteria.md)
- Documentation updated AS YOU BUILD, not after

---

## Current Status

**Phase 0: Project Setup** ✅ COMPLETE
- Rails API created
- Vue.js frontend created
- PostgreSQL database configured
- Redis configured
- Authentication (Devise + JWT) working
- Both servers tested and running

**Phase 1: Database & Models** ✅ COMPLETE
- All 9 migrations created and run
- All models created with validations
- Database seeded with reference data:
  - 40 dietary tags
  - 99 cuisines
  - 16 dish types
  - 74 recipe types

**Phase 2-5: Feature Development** 🚧 IN PROGRESS
- See [development-checklist.md](development-checklist.md) for detailed task breakdown

---

## Key Documents

### For AI Context
- **[00-START-HERE.md](00-START-HERE.md)** - Quick navigation guide
- **[development-workflow.md](development-workflow.md)** - MANDATORY workflows
- **[architecture.md](architecture.md)** - Backend + frontend architecture
- **[acceptance-criteria.md](acceptance-criteria.md)** - All ACs (127+ criteria)
- **[api-reference.md](api-reference.md)** - Complete API documentation (50+ endpoints)
- **[component-library.md](component-library.md)** - Component catalog

### For Planning
- **[../planning/PRD.md](../planning/PRD.md)** - Product Requirements Document
- **[../planning/technical-specification.md](../planning/technical-specification.md)** - Detailed tech spec
- **[../planning/epics.md](../planning/epics.md)** - Epic breakdown

### For Reference
- **[../reference/data/](../reference/data/)** - Dietary tags, cuisines, dish types, recipe types
- **[../reference/technical-designs/](../reference/technical-designs/)** - Nutrition strategy, scaling system

---

## Design Philosophy

### Backend
- **JSONB for flexibility** - Recipes as structured data, not rigid schema
- **UUID primary keys** - Security and scalability
- **Service objects** - Complex logic outside controllers
- **Background jobs** - AI operations don't block requests
- **Test-driven** - Every AC has RSpec tests

### Frontend
- **Component reuse** - Check component-library.md before creating new components
- **Design tokens** - All colors/spacing/fonts in CSS variables
- **Mobile-first** - Responsive from the start
- **i18n-first** - No hardcoded text allowed
- **Type-safe** - TypeScript for reliability

### User Experience
- **Pre-compute alternatives** - Instant UX (no waiting for AI during cooking)
- **AI as safety net** - For edge cases (~10% of users need this)
- **Separation of concerns** - Base recipe vs user customizations
- **90%+ coverage** - 2 pre-generated alternatives per step cover most use cases

---

## Timeline

- **Week 1-2:** Project setup, database, models ✅
- **Week 3-4:** Core recipe features (CRUD, scaling, search)
- **Week 5-6:** User features (favorites, notes), AI integration
- **Week 7:** Admin features, recipe import
- **Week 8:** Polish, testing, deployment

---

## Notes for AI Development

When starting a new AI session:
1. Read [00-START-HERE.md](00-START-HERE.md) for quick orientation
2. Check [development-checklist.md](development-checklist.md) for current tasks
3. Review [development-workflow.md](development-workflow.md) for MANDATORY processes
4. Reference [architecture.md](architecture.md) for system understanding

**Remember:**
- Backend: ACs → Tests → Code
- Frontend: Check components → Build + i18n → Document
- No hardcoded text allowed (backend or frontend)
- 100% test coverage (backend) and 100% i18n coverage (frontend) required

---

**Last Updated:** 2025-10-19
