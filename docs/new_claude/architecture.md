# System Architecture

**Last Updated:** 2025-10-19
**Version:** 2.0
**Status:** Living Document - **MUST BE KEPT UP-TO-DATE**
**Purpose:** Define backend and frontend architecture patterns, organization principles, and design systems

---

## Document Organization

This document is divided into two main sections:

1. **[Backend Architecture](#backend-architecture)** - Database, models, API structure, services
2. **[Frontend Architecture](#frontend-architecture)** - Components, design system, state management, i18n

---

## ⚠️ CRITICAL: Keeping This Document Updated

**UPDATE THIS DOCUMENT WHENEVER:**

### Backend Changes:
- New models or associations added
- Database schema changes
- New API endpoints created
- New services or background jobs added
- New patterns or conventions emerge

### Frontend Changes:
- New CSS files or styles added
- New folders or organizational changes
- New composables created
- Design system values change (colors, spacing, fonts)
- New component patterns emerge

---

# Backend Architecture

## Table of Contents (Backend)

1. [Technology Stack](#technology-stack)
2. [Database Design](#database-design)
3. [Models & Associations](#models--associations)
4. [API Structure](#api-structure)
5. [Services Layer](#services-layer)
6. [Background Jobs](#background-jobs)

---

## Technology Stack

### Core Technologies
- **Ruby on Rails 8.0.3** - API-only mode
- **PostgreSQL 14+** - Primary database
- **Redis 7+** - Session storage, caching, background jobs
- **Sidekiq** - Background job processing

### Key Extensions & Gems
- **Devise + Devise-JWT** - Authentication with JWT tokens
- **pg_trgm** - Trigram-based fuzzy search
- **pgcrypto** - UUID generation
- **RSpec** - Testing framework

---

## Database Design

### Design Principles
1. **UUID Primary Keys** - All tables use UUIDs for security and scalability
2. **JSONB for Flexibility** - Recipes, ingredients use JSONB for structured data
3. **GIN Indexes** - Fast JSONB and array searching
4. **Polymorphic Patterns** - DataReference handles multiple reference types
5. **Internationalization** - Support for 7 languages (en, ja, ko, zh-tw, zh-cn, es, fr)

### Core Tables

#### users
- Authentication via Devise
- Role-based access (`role` enum: user/admin)
- `preferred_language` for user's locale

#### recipes
- **UUID primary key**
- **JSONB fields:**
  - `servings` - serving information
  - `timing` - prep/cook/total time
  - `nutrition` - per-serving nutrition data
  - `ingredient_groups` - organized ingredient lists
  - `steps` - cooking instructions with variants
  - `equipment` - required tools
  - `translations` - recipe translations
- **Arrays (JSONB):**
  - `aliases` - alternative recipe names
  - `dietary_tags` - vegan, gluten-free, etc.
  - `dish_types` - breakfast, dinner, dessert
  - `recipe_types` - baking, grilling, etc.
  - `cuisines` - Italian, Japanese, etc.
- **GIN indexes** on JSONB arrays for fast filtering
- `requires_precision` boolean for baking vs cooking

#### ingredients
- Canonical ingredient database
- `canonical_name` - standardized ingredient name (unique)
- `category` - protein, vegetable, grain, etc.

#### ingredient_nutrition
- Nutrition data per ingredient
- Decimal precision for accuracy
- `data_source` - Nutritionix API, manual entry, etc.
- `confidence_score` - data quality indicator

#### ingredient_aliases
- Alternative names and translations
- `alias` + `language` unique constraint
- Supports fuzzy matching for ingredient discovery

#### data_references
- **Polymorphic reference data table**
- `reference_type` - dietary_tags, cuisines, dish_types, recipe_types
- `key` - unique identifier within type
- `display_name` - human-readable name
- `metadata` (JSONB) - additional attributes
- `active` flag for soft deletion
- `sort_order` for display ordering

#### user_favorites
- User's saved recipes
- Unique constraint on (user_id, recipe_id)

#### user_recipe_notes
- User's notes on recipes
- `note_type` - general, ingredient, step, timing
- `note_target_id` - references specific step/ingredient

#### ai_prompts
- Versioned AI prompt templates
- `prompt_key` - unique identifier
- `prompt_type` - system, user, assistant
- `feature_area` - translation, variants, parsing
- `variables` (JSONB) - template variable definitions
- `active` flag + `version` for A/B testing

#### jwt_denylists
- Blacklisted JWT tokens (for logout)
- `jti` - JWT ID
- `exp` - expiration timestamp

---

## Models & Associations

### Recipe Model
```ruby
class Recipe < ApplicationRecord
  # Associations
  has_many :user_favorites, dependent: :destroy
  has_many :user_recipe_notes, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :language, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }

  # JSONB validations
  validate :servings_structure
  validate :timing_structure
  validate :ingredient_groups_structure
  validate :steps_structure
end
```

### User Model
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum role: { user: 0, admin: 1 }

  has_many :user_favorites, dependent: :destroy
  has_many :favorite_recipes, through: :user_favorites, source: :recipe
  has_many :user_recipe_notes, dependent: :destroy
end
```

### DataReference Model
```ruby
class DataReference < ApplicationRecord
  VALID_TYPES = %w[dietary_tag cuisine dish_type recipe_type].freeze

  validates :reference_type, presence: true, inclusion: { in: VALID_TYPES }
  validates :key, presence: true, uniqueness: { scope: :reference_type }
  validates :display_name, presence: true

  scope :dietary_tags, -> { where(reference_type: 'dietary_tag') }
  scope :cuisines, -> { where(reference_type: 'cuisine') }
  scope :dish_types, -> { where(reference_type: 'dish_type') }
  scope :recipe_types, -> { where(reference_type: 'recipe_type') }
  scope :active, -> { where(active: true) }
end
```

### Ingredient Models
```ruby
class Ingredient < ApplicationRecord
  has_one :nutrition, class_name: 'IngredientNutrition', dependent: :destroy
  has_many :aliases, class_name: 'IngredientAlias', dependent: :destroy

  validates :canonical_name, presence: true, uniqueness: true
end

class IngredientNutrition < ApplicationRecord
  belongs_to :ingredient
end

class IngredientAlias < ApplicationRecord
  belongs_to :ingredient
  validates :alias, presence: true, uniqueness: { scope: :language }
end
```

---

## API Structure

### Authentication Flow
1. **Sign Up:** `POST /api/v1/auth/sign_up`
2. **Sign In:** `POST /api/v1/auth/sign_in` → Returns JWT token
3. **Sign Out:** `DELETE /api/v1/auth/sign_out` → Revokes JWT token

### API Organization

```
app/controllers/api/v1/
├── auth/                      # Authentication (3 endpoints)
│   └── authentication_controller.rb
├── admin/                     # Admin-only endpoints
│   ├── recipes_controller.rb  # Admin recipe management (12 endpoints)
│   ├── data_references_controller.rb  # CRUD for reference data (7 endpoints)
│   ├── ai_prompts_controller.rb       # Manage AI prompts (7 endpoints)
│   └── ingredients_controller.rb       # Ingredient database (6 endpoints)
└── recipes_controller.rb      # Public recipes API (3 endpoints)
    favorites_controller.rb    # User favorites (3 endpoints)
    notes_controller.rb        # User notes (4 endpoints)
```

**See [api-reference.md](api-reference.md) for complete endpoint documentation (50+ endpoints).**

### API Conventions
- **Versioning:** `/api/v1/...`
- **Authentication:** JWT Bearer token in `Authorization` header
- **Error Format:** `{ error: "message" }` with appropriate HTTP status
- **i18n:** `Accept-Language` header for localized error messages
- **Filtering:** Query params (`?dietary_tags[]=vegan&cuisines[]=italian`)
- **Pagination:** `page` and `per_page` params (default: 20 per page)

---

## Services Layer

### RecipeScaler Service
```ruby
# app/services/recipe_scaler.rb
class RecipeScaler
  def initialize(recipe)
    @recipe = recipe
  end

  def scale(new_servings: nil, ingredient_target: nil)
    # Smart scaling logic
    # See acceptance-criteria.md: AC-SCALE-001 to AC-SCALE-012
  end
end
```

### NutritionCalculator Service
```ruby
# app/services/nutrition_calculator.rb
class NutritionCalculator
  def calculate(recipe, servings)
    # Calculate per-serving nutrition
  end
end
```

**Principle:** Complex business logic lives in services, not controllers or models.

---

## Background Jobs

### Using Sidekiq

```ruby
# app/jobs/generate_recipe_variants_job.rb
class GenerateRecipeVariantsJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    # Call AI to generate step variants
  end
end
```

**Queues:**
- `default` - general background tasks
- `high_priority` - user-facing operations
- `low_priority` - cleanup, analytics

---

# Frontend Architecture

## Table of Contents (Frontend)

1. [Core Principles](#core-principles)
2. [Project Structure](#project-structure)
3. [Design System Setup](#design-system-setup)
4. [Component Organization](#component-organization)
5. [Styling Architecture](#styling-architecture)
6. [Internationalization (i18n)](#internationalization-i18n)
7. [Customization Guide](#customization-guide)
8. [PrimeVue Integration](#primevue-integration)
9. [Best Practices](#best-practices)

---

## Core Principles

### 1. **Separation of Concerns**
- **Logic** (TypeScript/Pinia stores) separated from **Presentation** (Vue components)
- **Structure** (HTML) separated from **Style** (CSS)
- **Data** (API calls) separated from **UI** (components)

### 2. **Easy Customization**
- All visual styles centralized in design tokens
- Layout spacing and sizing use CSS custom properties (variables)
- Colors, fonts, and spacing defined once, used everywhere
- Component props for positioning and sizing, NOT hardcoded values

### 3. **Consistent Patterns**
- Reusable components for common UI patterns
- Consistent naming conventions
- Predictable file locations

### 4. **Mobile-First Responsive**
- All components designed mobile-first
- Responsive breakpoints defined globally
- Touch-friendly interactions

---

## Project Structure

```
frontend/src/
├── assets/
│   ├── styles/
│   │   ├── main.css           # Global styles, imports everything
│   │   ├── variables.css      # Design tokens (colors, spacing, fonts)
│   │   ├── typography.css     # Font styles and text utilities
│   │   ├── layout.css         # Layout utilities (spacing, grid, flex)
│   │   ├── components.css     # Global component styles
│   │   └── utilities.css      # Utility classes (mb-4, text-center, etc.)
│   ├── images/                # Static images
│   └── icons/                 # Custom SVG icons
│
├── components/
│   ├── admin/                 # Admin-specific components
│   │   ├── layout/
│   │   │   ├── AdminLayout.vue
│   │   │   ├── AdminNavBar.vue
│   │   │   ├── AdminSidebar.vue
│   │   │   └── AdminBreadcrumbs.vue
│   │   ├── recipes/
│   │   │   ├── RecipeForm.vue
│   │   │   ├── RecipeListAdmin.vue
│   │   │   ├── RecipeImportModal.vue
│   │   │   └── RecipeImportTabs/
│   │   │       ├── ManualTab.vue
│   │   │       ├── TextImportTab.vue
│   │   │       ├── UrlImportTab.vue
│   │   │       └── ImageImportTab.vue
│   │   ├── data/
│   │   │   ├── DataReferenceManager.vue
│   │   │   ├── DataReferenceForm.vue
│   │   │   └── DataReferenceList.vue
│   │   ├── prompts/
│   │   │   ├── PromptManagement.vue
│   │   │   ├── PromptEditor.vue
│   │   │   └── PromptTester.vue
│   │   └── ingredients/
│   │       ├── IngredientDatabaseManager.vue
│   │       ├── IngredientForm.vue
│   │       └── IngredientList.vue
│   │
│   ├── user/                  # User-facing components
│   │   ├── layout/
│   │   │   ├── UserLayout.vue
│   │   │   ├── UserNavBar.vue
│   │   │   ├── UserFooter.vue
│   │   │   └── MobileMenu.vue
│   │   ├── recipes/
│   │   │   ├── RecipeCard.vue
│   │   │   ├── RecipeDetail.vue
│   │   │   ├── RecipeList.vue
│   │   │   ├── IngredientList.vue
│   │   │   ├── StepList.vue
│   │   │   ├── NutritionInfo.vue
│   │   │   ├── ScalingControls.vue
│   │   │   └── StepVariantToggle.vue
│   │   ├── search/
│   │   │   ├── SearchBar.vue
│   │   │   ├── FilterPanel.vue
│   │   │   ├── FilterToolbar.vue
│   │   │   └── SearchResults.vue
│   │   ├── user/
│   │   │   ├── LoginForm.vue
│   │   │   ├── RegistrationForm.vue
│   │   │   ├── UserDashboard.vue
│   │   │   ├── FavoriteButton.vue
│   │   │   └── NoteEditor.vue
│   │   └── common/
│   │       └── LanguageSelector.vue
│   │
│   └── shared/                # Shared components (used by both admin and user)
│       ├── LoadingSpinner.vue
│       ├── ErrorMessage.vue
│       ├── ConfirmDialog.vue
│       ├── EmptyState.vue
│       ├── PageHeader.vue
│       └── Badge.vue
│
├── composables/               # Reusable Vue composition functions
│   ├── useBreakpoints.ts     # Responsive breakpoint detection
│   ├── useDebounce.ts        # Debounced input handling
│   ├── useToast.ts           # Toast notifications
│   └── useAuth.ts            # Authentication helpers
│
├── router/
│   ├── index.ts              # Route definitions
│   ├── guards.ts             # Navigation guards (auth, admin)
│   └── routes/
│       ├── admin.ts          # Admin routes
│       └── user.ts           # User routes
│
├── services/                  # API services (already created)
│   ├── api.ts
│   ├── types.ts
│   ├── recipeApi.ts
│   ├── authApi.ts
│   ├── dataReferenceApi.ts
│   └── adminApi.ts
│
├── stores/                    # Pinia stores (already created)
│   ├── recipeStore.ts
│   ├── userStore.ts
│   ├── uiStore.ts
│   ├── dataReferenceStore.ts
│   └── adminStore.ts
│
├── views/                     # Page-level views
│   ├── admin/
│   │   ├── AdminDashboard.vue
│   │   ├── RecipeManagement.vue
│   │   ├── DataReferences.vue
│   │   ├── PromptManagement.vue
│   │   └── IngredientDatabase.vue
│   └── user/
│       ├── Home.vue
│       ├── RecipeListView.vue
│       ├── RecipeDetailView.vue
│       ├── UserDashboard.vue
│       ├── Login.vue
│       └── Register.vue
│
├── App.vue                    # Root component
└── main.ts                    # Application entry point
```

---

## Design System Setup

### Design Tokens (CSS Custom Properties)

All design values defined in `assets/styles/variables.css`:

```css
:root {
  /* === COLORS === */
  /* Primary Brand Colors */
  --color-primary: #4F46E5;         /* Indigo - main brand color */
  --color-primary-light: #6366F1;
  --color-primary-dark: #4338CA;

  /* Secondary Colors */
  --color-secondary: #10B981;       /* Emerald - success/healthy */
  --color-secondary-light: #34D399;
  --color-secondary-dark: #059669;

  /* Semantic Colors */
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-error: #EF4444;
  --color-info: #3B82F6;

  /* Neutral Colors (Light Mode) */
  --color-background: #FFFFFF;
  --color-surface: #F9FAFB;
  --color-border: #E5E7EB;
  --color-text: #111827;
  --color-text-secondary: #6B7280;
  --color-text-muted: #9CA3AF;

  /* === SPACING === */
  --spacing-xs: 0.25rem;    /* 4px */
  --spacing-sm: 0.5rem;     /* 8px */
  --spacing-md: 1rem;       /* 16px */
  --spacing-lg: 1.5rem;     /* 24px */
  --spacing-xl: 2rem;       /* 32px */
  --spacing-2xl: 3rem;      /* 48px */
  --spacing-3xl: 4rem;      /* 64px */

  /* === TYPOGRAPHY === */
  --font-family-base: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-family-heading: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-family-mono: 'JetBrains Mono', 'Fira Code', 'Courier New', monospace;

  --font-size-xs: 0.75rem;    /* 12px */
  --font-size-sm: 0.875rem;   /* 14px */
  --font-size-base: 1rem;     /* 16px */
  --font-size-lg: 1.125rem;   /* 18px */
  --font-size-xl: 1.25rem;    /* 20px */
  --font-size-2xl: 1.5rem;    /* 24px */
  --font-size-3xl: 1.875rem;  /* 30px */
  --font-size-4xl: 2.25rem;   /* 36px */

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;

  /* === LAYOUT === */
  --max-width-sm: 640px;
  --max-width-md: 768px;
  --max-width-lg: 1024px;
  --max-width-xl: 1280px;
  --max-width-2xl: 1536px;

  --container-padding: var(--spacing-md);

  /* === BORDERS === */
  --border-radius-sm: 0.25rem;   /* 4px */
  --border-radius-md: 0.5rem;    /* 8px */
  --border-radius-lg: 0.75rem;   /* 12px */
  --border-radius-xl: 1rem;      /* 16px */
  --border-radius-full: 9999px;

  --border-width: 1px;
  --border-width-thick: 2px;

  /* === SHADOWS === */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);

  /* === TRANSITIONS === */
  --transition-fast: 150ms ease-in-out;
  --transition-base: 200ms ease-in-out;
  --transition-slow: 300ms ease-in-out;

  /* === Z-INDEX === */
  --z-dropdown: 1000;
  --z-sticky: 1020;
  --z-fixed: 1030;
  --z-modal-backdrop: 1040;
  --z-modal: 1050;
  --z-popover: 1060;
  --z-tooltip: 1070;

  /* === BREAKPOINTS (for reference, use in composables) === */
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
  --breakpoint-2xl: 1536px;
}

/* Dark Mode Overrides */
[data-theme="dark"] {
  --color-background: #111827;
  --color-surface: #1F2937;
  --color-border: #374151;
  --color-text: #F9FAFB;
  --color-text-secondary: #D1D5DB;
  --color-text-muted: #9CA3AF;
}
```

---

## Component Organization

### Component File Structure

Every component follows this structure:

```vue
<script setup lang="ts">
// 1. Imports
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useRecipeStore } from '@/stores'

// 2. Props & Emits
interface Props {
  title: string
  size?: 'sm' | 'md' | 'lg'
  variant?: 'primary' | 'secondary'
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  variant: 'primary'
})

const emit = defineEmits<{
  click: []
  change: [value: string]
}>()

// 3. State
const isLoading = ref(false)

// 4. Computed
const classes = computed(() => ({
  [`size-${props.size}`]: true,
  [`variant-${props.variant}`]: true
}))

// 5. Methods
function handleClick() {
  emit('click')
}

// 6. Lifecycle hooks
onMounted(() => {
  // initialization
})
</script>

<template>
  <div :class="['component-name', classes]">
    <h2 class="component-name__title">{{ title }}</h2>
    <slot />
  </div>
</template>

<style scoped>
/* Use CSS custom properties for all values */
.component-name {
  padding: var(--spacing-md);
  background: var(--color-surface);
  border-radius: var(--border-radius-md);
  border: var(--border-width) solid var(--color-border);
  transition: all var(--transition-base);
}

.component-name__title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
}

/* Size variants */
.size-sm {
  padding: var(--spacing-sm);
}

.size-md {
  padding: var(--spacing-md);
}

.size-lg {
  padding: var(--spacing-lg);
}

/* Color variants */
.variant-primary {
  background: var(--color-primary);
  color: white;
}

.variant-secondary {
  background: var(--color-secondary);
  color: white;
}

/* Responsive */
@media (max-width: 768px) {
  .component-name {
    padding: var(--spacing-sm);
  }
}
</style>
```

### Component Naming Conventions

- **PascalCase** for component names: `RecipeCard.vue`, `UserNavBar.vue`
- **BEM-style** for CSS classes: `recipe-card`, `recipe-card__title`, `recipe-card--featured`
- **Prefix by feature**: Admin components start with `Admin`, User components with `User`

---

## Styling Architecture

### 1. **No Hardcoded Values**

❌ **BAD:**
```vue
<style scoped>
.card {
  padding: 16px;
  margin-bottom: 20px;
  color: #333333;
}
</style>
```

✅ **GOOD:**
```vue
<style scoped>
.card {
  padding: var(--spacing-md);
  margin-bottom: var(--spacing-lg);
  color: var(--color-text);
}
</style>
```

### 2. **Utility Classes for Common Patterns**

Create utility classes in `assets/styles/utilities.css`:

```css
/* Spacing Utilities */
.mt-sm { margin-top: var(--spacing-sm); }
.mt-md { margin-top: var(--spacing-md); }
.mt-lg { margin-top: var(--spacing-lg); }
.mb-sm { margin-bottom: var(--spacing-sm); }
.mb-md { margin-bottom: var(--spacing-md); }
.mb-lg { margin-bottom: var(--spacing-lg); }

.p-sm { padding: var(--spacing-sm); }
.p-md { padding: var(--spacing-md); }
.p-lg { padding: var(--spacing-lg); }

/* Text Utilities */
.text-center { text-align: center; }
.text-right { text-align: right; }
.text-bold { font-weight: var(--font-weight-bold); }
.text-muted { color: var(--color-text-muted); }

/* Flex Utilities */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.flex-center { align-items: center; justify-content: center; }
.gap-sm { gap: var(--spacing-sm); }
.gap-md { gap: var(--spacing-md); }
```

### 3. **Responsive Design**

Use mobile-first approach:

```vue
<style scoped>
/* Mobile first (default) */
.recipe-card {
  width: 100%;
  padding: var(--spacing-sm);
}

/* Tablet and up */
@media (min-width: 768px) {
  .recipe-card {
    width: 50%;
    padding: var(--spacing-md);
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .recipe-card {
    width: 33.333%;
    padding: var(--spacing-lg);
  }
}
</style>
```

---

## Internationalization (i18n)

### Overview

The Recipe App supports 7 languages with 100% translation coverage using Vue I18n v9:

| Language | Code | Native Name | Flag |
|----------|------|-------------|------|
| English | `en` | English | 🇬🇧 |
| Japanese | `ja` | 日本語 | 🇯🇵 |
| Korean | `ko` | 한국어 | 🇰🇷 |
| Traditional Chinese | `zh-tw` | 繁體中文 | 🇹🇼 |
| Simplified Chinese | `zh-cn` | 简体中文 | 🇨🇳 |
| Spanish | `es` | Español | 🇪🇸 |
| French | `fr` | Français | 🇫🇷 |

### Locale File Structure

**Location:** `frontend/src/locales/`

Each locale file (`en.json`, `ja.json`, etc.) follows this structure:

```json
{
  "common": {
    "buttons": {
      "save": "Save",
      "cancel": "Cancel",
      "delete": "Delete"
    },
    "labels": {
      "name": "Name",
      "email": "Email",
      "password": "Password"
    },
    "messages": {
      "success": "Operation completed successfully",
      "error": "An error occurred",
      "loading": "Loading...",
      "welcome": "Welcome to Ember",
      "subtitle": "Your recipe management platform"
    }
  },
  "navigation": {
    "home": "Home",
    "recipes": "Recipes",
    "favorites": "Favorites",
    "admin": "Admin",
    "dashboard": "Dashboard"
  },
  "forms": {
    "recipe": {
      "title": "Recipe Title",
      "servings": "Servings",
      "prepTime": "Prep Time (minutes)"
    },
    "user": {
      "email": "Email Address",
      "password": "Password",
      "rememberMe": "Remember Me"
    }
  },
  "errors": {
    "validation": {
      "required": "This field is required",
      "invalidEmail": "Invalid email address",
      "passwordTooShort": "Password is too short"
    }
  }
}
```

### Translation Key Naming Conventions

- Use **camelCase** for JSON keys
- Organize by **feature/domain** (recipe, user, navigation)
- Use **hierarchical structure** (common.buttons.save)
- Keep keys **descriptive and specific**

✅ **Good Examples:**
```json
{
  "forms.recipe.validation.titleRequired": "...",
  "common.buttons.saveAndContinue": "...",
  "errors.validation.passwordsDontMatch": "..."
}
```

❌ **Bad Examples:**
```json
{
  "msg1": "...",
  "error": "...",
  "btn": "..."
}
```

### Using Translations in Components

#### In Templates:

```vue
<template>
  <!-- Basic usage -->
  <h1>{{ $t('common.messages.welcome') }}</h1>

  <!-- With interpolation -->
  <p>{{ $t('recipe.servings', { count: 4 }) }}</p>

  <!-- For attributes -->
  <input :placeholder="$t('forms.recipe.title')" />

  <!-- For aria labels -->
  <button :aria-label="$t('common.buttons.close')">×</button>
</template>
```

#### In Script (Composition API):

```vue
<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t, locale } = useI18n()

// Use t() function for translations
const successMessage = t('common.messages.success')

// Get current locale
console.log(locale.value) // 'en', 'ja', etc.

// Check if specific locale
const isJapanese = locale.value === 'ja'
</script>
```

### Language Switching

Users can switch languages via the **LanguageSwitcher** component:

```vue
<template>
  <!-- Add to navbar/header -->
  <LanguageSwitcher />
</template>

<script setup lang="ts">
import LanguageSwitcher from '@/components/shared/LanguageSwitcher.vue'
</script>
```

**How it works:**
1. User selects language from dropdown
2. `uiStore.setLanguage(code)` is called
3. Vue I18n `locale` updates
4. Language saved to `localStorage` (key: `locale`)
5. All UI text updates immediately
6. Subsequent API requests include `Accept-Language` header

### Locale Detection

On app initialization, the locale is detected in this order:

1. **localStorage** (`localStorage.getItem('locale')`)
2. **Browser language** (`navigator.language.split('-')[0]`)
3. **Default fallback** (`'en'`)

Configured in `main.ts`:
```typescript
const i18n = createI18n({
  legacy: false,
  locale: localStorage.getItem('locale') ||
          navigator.language.split('-')[0] ||
          'en',
  fallbackLocale: 'en',
  messages: { en, ja, ko, 'zh-tw': zhTw, 'zh-cn': zhCn, es, fr }
})
```

### Missing Translation Detection

In development mode, missing translations are automatically detected:

**Console Warnings:**
```
[i18n] Missing translation: "recipe.newKey" for locale "ja"
```

**Visual Indicators:**
```
[recipe.newKey]  // Displays in brackets in the UI
```

**Configuration** (in `main.ts`):
```typescript
const i18n = createI18n({
  // ... other config
  missing: (locale, key) => {
    if (import.meta.env.DEV) {
      console.warn(`[i18n] Missing translation: "${key}" for locale "${locale}"`)
      return `[${key}]`
    }
    return key
  }
})
```

### API Integration

The Axios API client automatically sends the `Accept-Language` header:

**Configuration** (`services/api.ts`):
```typescript
apiClient.interceptors.request.use((config) => {
  // Add Accept-Language header from current locale
  const locale = localStorage.getItem('locale') || 'en'
  config.headers['Accept-Language'] = locale

  return config
})
```

Backend receives this header and returns localized error messages.

### Adding New Translations

**CRITICAL:** All user-facing text must be translated into ALL 7 languages.

#### Step-by-Step Process:

1. **Add English first** (`locales/en.json`):
   ```json
   {
     "recipe": {
       "actions": {
         "duplicate": "Duplicate Recipe"
       }
     }
   }
   ```

2. **Add to ALL 6 other languages:**
   - `ja.json`: `"duplicate": "レシピを複製"`
   - `ko.json`: `"duplicate": "레시피 복제"`
   - `zh-tw.json`: `"duplicate": "複製食譜"`
   - `zh-cn.json`: `"duplicate": "复制食谱"`
   - `es.json`: `"duplicate": "Duplicar receta"`
   - `fr.json`: `"duplicate": "Dupliquer la recette"`

3. **Verify in browser:**
   - Switch through all 7 languages
   - Check for `[missing.key]` brackets
   - Check console for warnings

#### See Also:
- **Detailed workflow:** `docs/i18n-workflow.md`
- **Documentation requirements:** `docs/DOCUMENTATION-WORKFLOW.md` Rule #3

### Best Practices

#### 1. Never Hardcode Text

❌ **Bad:**
```vue
<button>Save Recipe</button>
```

✅ **Good:**
```vue
<button>{{ $t('recipe.actions.save') }}</button>
```

#### 2. Use Interpolation for Dynamic Content

❌ **Bad:**
```typescript
const msg = t('recipe.created') + ' ' + recipeName
```

✅ **Good:**
```typescript
const msg = t('recipe.createdWithName', { name: recipeName })
```

```json
{
  "recipe": {
    "createdWithName": "Recipe '{name}' created successfully"
  }
}
```

#### 3. Avoid String Concatenation

Different languages have different word order and grammar.

#### 4. Keep Text Concise

Shorter text is easier to translate and fits better in UI layouts across languages.

#### 5. Test in All Languages

Before committing:
- Switch through all 7 languages in browser
- Verify layouts don't break (especially CJK characters)
- Check that all text is translated

### Troubleshooting

**Problem:** Translation not updating after editing locale file

**Solution:** Restart dev server (`npm run dev`)

---

**Problem:** Missing key warning but key exists

**Solution:** Check for:
- Typo in key path
- JSON syntax errors (trailing commas)
- Locale file structure matches exactly across all languages

---

**Problem:** Chinese variants not working

**Solution:** Ensure locale codes match exactly:
- Traditional Chinese: `'zh-tw'` (not `'zh-TW'` or `'zh_tw'`)
- Simplified Chinese: `'zh-cn'` (not `'zh-CN'` or `'zh_cn'`)

### Reference Documentation

- **Complete i18n workflow:** `docs/i18n-workflow.md`
- **LanguageSwitcher component:** `docs/component-library.md#languageswitcher`
- **Vue I18n official docs:** https://vue-i18n.intlify.dev/

---

## Customization Guide

### How to Change Colors

1. Open `frontend/src/assets/styles/variables.css`
2. Update the color values in `:root`
3. Changes apply globally to all components

Example: Change primary brand color from indigo to teal:
```css
:root {
  --color-primary: #14B8A6;         /* Teal */
  --color-primary-light: #2DD4BF;
  --color-primary-dark: #0D9488;
}
```

### How to Change Spacing

Update spacing scale in `variables.css`:
```css
:root {
  --spacing-md: 1.25rem;  /* Change from 16px to 20px */
}
```

### How to Change Fonts

1. Add font to `index.html` or install via npm
2. Update font variables in `variables.css`:
```css
:root {
  --font-family-base: 'Poppins', sans-serif;
  --font-family-heading: 'Montserrat', sans-serif;
}
```

### How to Change Layout Width

```css
:root {
  --max-width-lg: 1200px;  /* Change from 1024px */
}
```

### How to Rearrange Component Sections

Each component uses named slots and props for positioning:

```vue
<!-- RecipeDetail.vue -->
<template>
  <div class="recipe-detail">
    <!-- Easily reorder these sections by changing order in template -->
    <RecipeHeader :recipe="recipe" />
    <NutritionInfo :nutrition="recipe.nutrition" />
    <IngredientList :ingredients="recipe.ingredients" />
    <StepList :steps="recipe.steps" />
  </div>
</template>
```

---

## PrimeVue Integration

### Theme Customization

PrimeVue uses Aura theme by default. Customize in `main.ts`:

```typescript
app.use(PrimeVue, {
  theme: {
    preset: Aura,
    options: {
      darkModeSelector: '[data-theme="dark"]',
      cssLayer: {
        name: 'primevue',
        order: 'tailwind-base, primevue, tailwind-utilities'
      }
    }
  }
})
```

### Override PrimeVue Styles

Create `assets/styles/primevue-overrides.css`:

```css
/* Override PrimeVue button */
.p-button {
  border-radius: var(--border-radius-md) !important;
  font-weight: var(--font-weight-medium) !important;
  transition: all var(--transition-base) !important;
}

/* Override PrimeVue card */
.p-card {
  box-shadow: var(--shadow-md) !important;
  border: var(--border-width) solid var(--color-border) !important;
}
```

---

## Best Practices

### 1. **Props for Customization**

Always provide props for positioning and styling:

```vue
<RecipeCard
  :size="'lg'"
  :variant="'featured'"
  :show-nutrition="true"
/>
```

### 2. **Composables for Reusable Logic**

Extract reusable logic to composables:

```typescript
// composables/useBreakpoints.ts
import { ref, onMounted, onUnmounted } from 'vue'

export function useBreakpoints() {
  const isMobile = ref(window.innerWidth < 768)
  const isTablet = ref(window.innerWidth >= 768 && window.innerWidth < 1024)
  const isDesktop = ref(window.innerWidth >= 1024)

  function updateBreakpoints() {
    isMobile.value = window.innerWidth < 768
    isTablet.value = window.innerWidth >= 768 && window.innerWidth < 1024
    isDesktop.value = window.innerWidth >= 1024
  }

  onMounted(() => {
    window.addEventListener('resize', updateBreakpoints)
  })

  onUnmounted(() => {
    window.removeEventListener('resize', updateBreakpoints)
  })

  return { isMobile, isTablet, isDesktop }
}
```

### 3. **Slots for Content Injection**

Use slots for flexible content:

```vue
<Card>
  <template #header>
    <h2>Custom Header</h2>
  </template>

  <template #default>
    <p>Main content</p>
  </template>

  <template #footer>
    <button>Action</button>
  </template>
</Card>
```

### 4. **Scoped Styles**

Always use scoped styles to prevent CSS leakage:

```vue
<style scoped>
/* These styles only apply to this component */
.recipe-card {
  /* ... */
}
</style>
```

### 5. **Component Documentation**

Add JSDoc comments to components:

```typescript
/**
 * RecipeCard component displays a recipe in card format
 *
 * @example
 * <RecipeCard
 *   :recipe="recipe"
 *   :size="'lg'"
 *   @click="handleClick"
 * />
 */
```

---

## Quick Reference

### Common Tasks

| Task | File to Edit | What to Change |
|------|-------------|----------------|
| Change primary color | `variables.css` | `--color-primary` |
| Change spacing scale | `variables.css` | `--spacing-*` values |
| Change fonts | `variables.css` | `--font-family-*` |
| Add utility class | `utilities.css` | New utility class |
| Change breakpoints | `variables.css` | `--breakpoint-*` (reference only) |
| Rearrange page sections | Component `.vue` file | Reorder elements in `<template>` |
| Change component spacing | Component `.vue` file | Update padding/margin classes or styles |
| Override PrimeVue styles | `primevue-overrides.css` | Add CSS overrides with `!important` |

---

## Summary

This architecture ensures:
- ✅ **Easy customization** - Change colors, spacing, fonts in one place
- ✅ **Consistent design** - All components use same design tokens
- ✅ **Maintainable code** - Clear organization and naming conventions
- ✅ **Flexible layouts** - Props and slots for positioning
- ✅ **Responsive design** - Mobile-first with defined breakpoints
- ✅ **Developer-friendly** - Clear patterns and documentation

**Golden Rule**: Never hardcode values. Always use CSS custom properties or props.

---

**Last Updated:** 2025-10-08
