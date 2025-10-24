# System Architecture

Backend and frontend architecture patterns, organization, design systems.

---

## Backend Architecture

1. Technology Stack
2. Database Design
3. Models & Associations
4. Mobility Translation System
5. API Structure
6. Services Layer
7. Background Jobs

---

## Technology Stack

**Core:**
- Ruby on Rails 8.0.3 (API-only)
- PostgreSQL 14+
- Redis 7+
- Sidekiq (background jobs)

**Auth & Security:**
- Devise + Devise-JWT
- pgcrypto (UUID generation)

**Search & Optimization:**
- pg_trgm (fuzzy search)

**Translation:**
- Mobility ~1.3.2 (dynamic translation via Table backend, UUID foreign keys)

**Testing:**
- RSpec

---

## Database Design

See: [../database-architecture.md](../database-architecture.md)

---

## Models & Associations

### Recipe Model

**Translatable fields:** `name` (via Mobility)

```ruby
class Recipe < ApplicationRecord
  extend Mobility

  translates :name, backend: :table

  # User associations
  has_many :user_favorites, dependent: :destroy
  has_many :user_recipe_notes, dependent: :destroy

  # Normalized schema
  has_many :ingredient_groups, -> { order(:position) }, dependent: :destroy
  has_many :recipe_ingredients, through: :ingredient_groups
  has_many :recipe_steps, -> { order(:step_number) }, dependent: :destroy
  has_one :recipe_nutrition, dependent: :destroy
  has_many :recipe_equipment, dependent: :destroy
  has_many :equipment, through: :recipe_equipment

  # Reference data
  has_many :recipe_dietary_tags, dependent: :destroy
  has_many :dietary_tags, through: :recipe_dietary_tags, source: :data_reference
  has_many :recipe_dish_types, dependent: :destroy
  has_many :dish_types, through: :recipe_dish_types, source: :data_reference
  has_many :recipe_cuisines, dependent: :destroy
  has_many :cuisines, through: :recipe_cuisines, source: :data_reference
  has_many :recipe_recipe_types, dependent: :destroy
  has_many :recipe_types, through: :recipe_recipe_types, source: :data_reference

  # Other
  has_many :recipe_aliases, dependent: :destroy

  accepts_nested_attributes_for :ingredient_groups, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true, reject_if: proc { |attrs| attrs['instruction_original'].blank? }
  accepts_nested_attributes_for :recipe_nutrition, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :recipe_equipment, allow_destroy: true, reject_if: proc { |attrs| attrs['equipment_id'].blank? }
  accepts_nested_attributes_for :recipe_dietary_tags, allow_destroy: true, reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_dish_types, allow_destroy: true, reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_cuisines, allow_destroy: true, reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_recipe_types, allow_destroy: true, reject_if: proc { |attrs| attrs['data_reference_id'].blank? }
  accepts_nested_attributes_for :recipe_aliases, allow_destroy: true, reject_if: proc { |attrs| attrs['alias_name'].blank? }

  validates :name, presence: true
  validates :source_language, presence: true, inclusion: { in: %w[en ja ko zh-tw zh-cn es fr] }
  validates :servings_original, numericality: { greater_than: 0, allow_nil: true }
  validates :servings_min, numericality: { greater_than_or_equal_to: 1, allow_nil: true }
  validates :servings_max, numericality: { greater_than_or_equal_to: 1, allow_nil: true }
  validates :prep_minutes, :cook_minutes, :total_minutes, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
end
```

### IngredientGroup Model

**Translatable fields:** `name`

```ruby
class IngredientGroup < ApplicationRecord
  extend Mobility

  translates :name, backend: :table

  belongs_to :recipe
  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy, inverse_of: :ingredient_group

  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :recipe_id, presence: true
  validates :position, uniqueness: { scope: :recipe_id }
end
```

### RecipeIngredient Model

**Translatable fields:** `ingredient_name`, `preparation_notes`

```ruby
class RecipeIngredient < ApplicationRecord
  extend Mobility

  translates :ingredient_name, :preparation_notes, backend: :table

  belongs_to :ingredient_group, inverse_of: :recipe_ingredients
  belongs_to :ingredient, optional: true

  validates :ingredient_name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :ingredient_group, presence: true
  validates :amount, numericality: { greater_than: 0, allow_nil: true }
end
```

### RecipeStep Model

**Translatable fields:** `instruction_original`, `instruction_easier`, `instruction_no_equipment`

```ruby
class RecipeStep < ApplicationRecord
  extend Mobility

  translates :instruction_original, :instruction_easier, :instruction_no_equipment, backend: :table

  belongs_to :recipe

  validates :recipe_id, presence: true
  validates :step_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :step_number, uniqueness: { scope: :recipe_id }

  default_scope { order(:step_number) }
end
```

### Equipment Model

**Translatable fields:** `canonical_name`

```ruby
class Equipment < ApplicationRecord
  extend Mobility

  translates :canonical_name, backend: :table

  validates :canonical_name, presence: true, uniqueness: true
end
```

### DataReference Model

**Translatable fields:** `display_name`

```ruby
class DataReference < ApplicationRecord
  extend Mobility

  translates :display_name, backend: :table

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

---

## Mobility Translation System

**Purpose:** Store dynamic recipe content translations across 6 non-English languages via dedicated database tables.

### Translation Tables

**Pattern:** Each translatable model has dedicated translation table

```
Recipe → RecipeTranslation (recipe_id, locale, name)
IngredientGroup → IngredientGroupTranslation (ingredient_group_id, locale, name)
RecipeIngredient → RecipeIngredientTranslation (recipe_ingredient_id, locale, ingredient_name, preparation_notes)
RecipeStep → RecipeStepTranslation (recipe_step_id, locale, instruction_original, instruction_easier, instruction_no_equipment)
Equipment → EquipmentTranslation (equipment_id, locale, canonical_name)
DataReference → DataReferenceTranslation (data_reference_id, locale, display_name)
```

**Constraint:** `UNIQUE(entity_id, locale)` for each table

**Foreign Keys:** UUID primary keys with ON DELETE CASCADE

### Mobility Configuration

**Location:** `config/initializers/mobility.rb`

**Backend:** Table (UUID foreign key support)

**Plugins:** active_record, reader, writer, query, fallbacks, locale_accessors, presence, dirty, cache, backend_reader

**Fallback Chain:**
```
ja → en
ko → en
zh-tw → zh-cn → en
zh-cn → zh-tw → en
es → en
fr → en
```

### Reading Translations

**In specific locale:**
```ruby
recipe = Recipe.find(id)
I18n.with_locale(:ja) { recipe.name }  # Japanese translation
```

**With fallback:**
```ruby
I18n.with_locale(:ja) { recipe.name }
# Returns Japanese if exists, else fallback chain
```

### Writing Translations

**In code:**
```ruby
recipe = Recipe.find(id)
I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
```

**Via TranslateRecipeJob (automatic on recipe creation):**
Enqueues background job that translates all 6 non-English languages via AI (Claude API).

### Querying Translations

**Query in specific locale:**
```ruby
I18n.with_locale(:ja) do
  Recipe.i18n.where(name: 'レシピ')
end
```

### API Integration

**Query parameter:** `?lang=ja`

**Response:** All translatable fields contain translations for that locale (with fallbacks)

**Example:**
```
GET /api/v1/recipes/:id?lang=ja

{
  "id": "...",
  "name": "レシピ",
  "ingredient_groups": [
    { "name": "メイン材料", "items": [...] }
  ],
  "steps": [...],
  "equipment": [...]
}
```

### N+1 Query Prevention

Always eager-load translations when fetching multiple recipes:

```ruby
recipes = Recipe
  .includes(ingredient_groups: :recipe_ingredients)
  .includes(:recipe_steps, :equipment)
  .all
```

---

## API Structure

**Auth:**
```
POST /api/v1/auth/sign_up
POST /api/v1/auth/sign_in → JWT token
DELETE /api/v1/auth/sign_out
```

**Organization:**
```
app/controllers/api/v1/
├── auth/ (auth)
├── admin/ (admin-only)
│   ├── recipes_controller.rb
│   ├── data_references_controller.rb
│   ├── ai_prompts_controller.rb
│   └── ingredients_controller.rb
└── recipes_controller.rb (public)
   favorites_controller.rb
   notes_controller.rb
```

**Conventions:**
- Versioning: `/api/v1/...`
- Auth: JWT Bearer token in `Authorization` header
- Errors: `{ error: "message" }` with HTTP status
- i18n: `Accept-Language` header for localized messages
- Filtering: Query params (`?dietary_tags[]=vegan`)
- Pagination: `page`, `per_page` (default: 20)
- Locale: `?lang=ja` query param for translated responses

**See:** [api-reference.md](api-reference.md) for complete endpoint documentation (50+ endpoints)

---

## Services Layer

### RecipeScaler Service
Handles recipe scaling by servings with ingredient adjustments. See: acceptance-criteria.md (AC-SCALE-001 to AC-SCALE-012)

### NutritionCalculator Service
Calculates nutritional content from ingredients.

### RecipeTranslator Service
Generates translations for recipe content via Claude API. Used by TranslateRecipeJob.

---

## Background Jobs

### TranslateRecipeJob
**Trigger:** Recipe creation

**Process:**
1. Load recipe with eager-loaded associations
2. Instantiate RecipeTranslator
3. For each language [ja, ko, zh-tw, zh-cn, es, fr]:
   - Translate via Claude API
   - Store in Mobility translation tables via I18n.with_locale
4. Set recipe.translations_completed = true

**Queue:** default (Sidekiq)

**Retry:** On error, logs and re-raises for Sidekiq retry

---

# Frontend Architecture

## Vue 3 + Composition API + Vite

**Tech Stack:**
- Vue 3.5+ (Composition API, script setup syntax)
- TypeScript
- Vite (build tool)
- Vue Router (navigation)
- Pinia (state management)
- Vitest (unit testing)
- Playwright (E2E testing)
- Vue I18n v9 (static i18n)
- TailwindCSS (styling)

---

## Static UI Translation (Vue I18n)

### Overview

**System:** Vue I18n v9 (static YAML translations)

**Languages:** 7 (en, ja, ko, zh-tw, zh-cn, es, fr)

**Location:** `frontend/src/locales/` (JSON files)

### Supported Languages

| Language | Code | Native | UI |
|----------|------|--------|-----|
| English | `en` | English | Yes |
| Japanese | `ja` | 日本語 | Yes |
| Korean | `ko` | 한국어 | Yes |
| Traditional Chinese | `zh-tw` | 繁體中文 | Yes |
| Simplified Chinese | `zh-cn` | 简体中文 | Yes |
| Spanish | `es` | Español | Yes |
| French | `fr` | Français | Yes |

### Locale File Structure

**Pattern:** Hierarchical JSON by feature/domain

**Example (`frontend/src/locales/en.json`):**
```json
{
  "common": {
    "buttons": { "save": "Save", "cancel": "Cancel" },
    "labels": { "name": "Name", "email": "Email" }
  },
  "navigation": { "home": "Home", "recipes": "Recipes" },
  "forms": {
    "recipe": { "title": "Recipe Title", "servings": "Servings" },
    "user": { "email": "Email", "password": "Password" }
  },
  "errors": {
    "validation": { "required": "This field is required", "invalid": "Invalid value" }
  }
}
```

### Key Naming

**Format:** camelCase

**Organization:**
- Group by feature/domain (recipe, user, navigation, etc.)
- Use hierarchical keys: `domain.category.specific`
- Reuse keys (don't duplicate same text)

**Good:** `forms.recipe.validation.titleRequired`
**Bad:** `msg1`, `error`, `btn`

### Using Translations

**In templates:**
```vue
{{ $t('common.buttons.save') }}
{{ $t('recipe.servings', { count: 4 }) }}
<input :placeholder="$t('forms.recipe.title')" />
```

**In script (Composition API):**
```typescript
import { useI18n } from 'vue-i18n'
const { t, locale } = useI18n()
const message = t('common.messages.success')
const isJapanese = locale.value === 'ja'
```

### Language Switching

**Component:** `LanguageSwitcher` (top-right of navbar)

**Flow:**
1. User selects language
2. Vue I18n `locale` updates
3. localStorage saved (key: `locale`)
4. All UI text updates immediately
5. Subsequent API requests include `Accept-Language` header

### Locale Detection

**On app init, in order:**
1. localStorage (`locale` key)
2. Browser language (`navigator.language`)
3. Default fallback (`en`)

**Configuration (`main.ts`):**
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

**Console warning (dev mode):**
```
[i18n] Missing translation: "recipe.newKey" for locale "ja"
```

**Visual indicator:**
```
[recipe.newKey]  // Displays in brackets
```

### API Integration

**Axios client automatically sends `Accept-Language` header:**
```typescript
apiClient.interceptors.request.use((config) => {
  const locale = localStorage.getItem('locale') || 'en'
  config.headers['Accept-Language'] = locale
  return config
})
```

Backend receives header, returns localized error messages.

---

## Component Organization

**Location:** `frontend/src/components/`

**Pattern:**
```
components/
├── shared/           # Reusable components
│   ├── LoadingSpinner.vue
│   ├── ErrorMessage.vue
│   ├── ConfirmDialog.vue
│   └── ...
├── admin/            # Admin-only components
├── layout/           # Layout components
├── recipe/           # Recipe-specific components
└── user/             # User-specific components
```

**See:** [component-library.md](component-library.md) for complete documentation

---

## State Management (Pinia)

**Location:** `frontend/src/stores/`

**Pattern:** Feature-based stores

```
stores/
├── ui.ts             # UI state (language, theme, modal states)
├── recipe.ts         # Recipe state (list, current, edit)
├── user.ts           # User state (auth, profile)
└── ...
```

---

## Design System

**Token sources:** `frontend/src/styles/variables.css`

**Colors, spacing, fonts, breakpoints:** CSS variables

**Styling:** TailwindCSS + custom variables

---

## References

- **API Endpoints:** [api-reference.md](api-reference.md)
- **i18n Workflow:** [i18n-workflow.md](i18n-workflow.md)
- **Component Library:** [component-library.md](component-library.md)
- **Development Checklist:** [development-checklist.md](development-checklist.md)
