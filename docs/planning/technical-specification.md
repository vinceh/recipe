# Recipe App - Technical Specification

**Date:** 2025-10-07
**Author:** V
**Status:** Implementation Guide

---

## Overview

This document provides detailed technical specifications for implementing the Recipe App MVP. It covers database schema, API endpoints, background jobs, frontend architecture, and AI integrations.

**Reference Documents:**
- [Product Brief (Concise)](product-brief-recipe-CONCISE.md)
- [Product Brief (Full)](product-brief-recipe-2025-10-07.md)
- [Brainstorming Session](brainstorming-session-results-2025-10-06.md)

---

## Table of Contents

1. [Database Schema](#database-schema)
2. [API Endpoints](#api-endpoints)
3. [Background Jobs](#background-jobs)
4. [Frontend Architecture](#frontend-architecture)
5. [AI Integrations](#ai-integrations)
6. [Smart Scaling Implementation](#smart-scaling-implementation)
7. [Multi-lingual Implementation](#multi-lingual-implementation)
8. [Nutrition System](#nutrition-system)
9. [Admin Tools](#admin-tools)
10. [Development Setup](#development-setup)

---

## Database Schema

### Core Tables

```ruby
# db/migrate/001_create_recipes.rb
create_table :recipes, id: :uuid do |t|
  t.string :name, null: false
  t.string :language, default: 'en'
  t.boolean :requires_precision, default: false
  t.string :precision_reason # 'baking', 'confectionery', 'fermentation', 'molecular'

  # JSONB fields
  t.jsonb :servings, default: {} # { original: 4, min: 1, max: 12 }
  t.jsonb :timing, default: {} # { prep_minutes: 15, cook_minutes: 30, total_minutes: 45 }
  t.jsonb :nutrition, default: {} # per_serving: { calories, protein_g, carbs_g, fat_g, fiber_g }
  t.jsonb :aliases, default: [] # ['Phad Thai', 'Thai Fried Noodles'] - same language as recipe.language only
  t.jsonb :dietary_tags, default: [] # Edamam health labels: ['vegetarian', 'gluten-free', 'dairy-free']
  t.jsonb :dish_types, default: [] # ['main-course', 'soup', 'desserts', 'side-dish']
  t.jsonb :recipe_types, default: [] # ['baking', 'stir-fry', 'chicken', 'quick-weeknight']
  t.jsonb :cuisines, default: [] # ['japanese'] or ['japanese', 'fusion']
  t.jsonb :ingredient_groups, default: [] # [{ name: 'Main', items: [...] }]
  t.jsonb :steps, default: [] # [{ id, instructions: { original, easier, no_equipment }, ... }]
  t.jsonb :equipment, default: [] # ['wok', 'rice_cooker']
  t.jsonb :translations, default: {} # { ja: {...}, ko: {...}, ... }

  # Generation status
  t.boolean :variants_generated, default: false
  t.datetime :variants_generated_at
  t.boolean :translations_completed, default: false

  # Admin metadata
  t.string :source_url # if imported via AI discovery
  t.text :admin_notes

  t.timestamps
end

add_index :recipes, :name
add_index :recipes, :language
add_index :recipes, [:aliases], using: :gin
add_index :recipes, [:dietary_tags], using: :gin
add_index :recipes, [:dish_types], using: :gin
add_index :recipes, [:recipe_types], using: :gin
add_index :recipes, [:cuisines], using: :gin

# db/migrate/002_create_users.rb
create_table :users, id: :uuid do |t|
  # Devise fields
  t.string :email, null: false
  t.string :encrypted_password, null: false
  t.string :reset_password_token
  t.datetime :reset_password_sent_at
  t.datetime :remember_created_at

  # Role
  t.integer :role, default: 0 # enum: 0=user, 1=admin

  # Preferences
  t.string :preferred_language, default: 'en'

  t.timestamps
end

add_index :users, :email, unique: true
add_index :users, :reset_password_token, unique: true

# db/migrate/003_create_user_recipe_notes.rb
create_table :user_recipe_notes, id: :uuid do |t|
  t.uuid :user_id, null: false
  t.uuid :recipe_id, null: false
  t.string :note_type, null: false # 'recipe', 'step', 'ingredient'
  t.string :note_target_id # 'step-001', 'ing-005', null for recipe-level
  t.text :note_text

  t.timestamps
end

add_foreign_key :user_recipe_notes, :users
add_foreign_key :user_recipe_notes, :recipes
add_index :user_recipe_notes, [:user_id, :recipe_id]

# db/migrate/004_create_user_favorites.rb
create_table :user_favorites, id: :uuid do |t|
  t.uuid :user_id, null: false
  t.uuid :recipe_id, null: false

  t.timestamps
end

add_foreign_key :user_favorites, :users
add_foreign_key :user_favorites, :recipes
add_index :user_favorites, [:user_id, :recipe_id], unique: true

# db/migrate/005_create_ingredients.rb
create_table :ingredients, id: :uuid do |t|
  t.string :canonical_name, null: false
  t.string :category # 'vegetable', 'protein', 'grain', 'spice', 'dairy'

  t.timestamps
end

add_index :ingredients, :canonical_name, unique: true

# db/migrate/006_create_ingredient_nutrition.rb
create_table :ingredient_nutrition, id: :uuid do |t|
  t.uuid :ingredient_id, null: false

  # Per 100g values
  t.decimal :calories, precision: 8, scale: 2
  t.decimal :protein_g, precision: 6, scale: 2
  t.decimal :carbs_g, precision: 6, scale: 2
  t.decimal :fat_g, precision: 6, scale: 2
  t.decimal :fiber_g, precision: 6, scale: 2

  # Metadata
  t.string :data_source # 'nutritionix', 'usda', 'ai'
  t.decimal :confidence_score, precision: 3, scale: 2 # 0.0-1.0

  t.timestamps
end

add_foreign_key :ingredient_nutrition, :ingredients
add_index :ingredient_nutrition, :ingredient_id

# db/migrate/007_create_ingredient_aliases.rb
create_table :ingredient_aliases, id: :uuid do |t|
  t.uuid :ingredient_id, null: false
  t.string :alias, null: false
  t.string :language # 'en', 'ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr'
  t.string :alias_type # 'synonym', 'translation', 'misspelling'

  t.timestamps
end

add_foreign_key :ingredient_aliases, :ingredients
add_index :ingredient_aliases, [:alias, :language], unique: true
add_index :ingredient_aliases, :ingredient_id

# db/migrate/008_create_background_jobs.rb
# Note: Sidekiq uses Redis, no migration needed
# But we track job status in recipes table (variants_generated, translations_completed)

# db/migrate/009_create_data_references.rb
create_table :data_references, id: :uuid do |t|
  t.string :reference_type, null: false # 'dietary_tag', 'recipe_type', 'cuisine', 'unit'
  t.string :key, null: false # 'vegetarian', 'main_course', 'japanese', 'cup'
  t.string :display_name, null: false
  t.jsonb :metadata, default: {} # Additional data (conversion rates for units, etc.)
  t.integer :sort_order, default: 0
  t.boolean :active, default: true

  t.timestamps
end

add_index :data_references, [:reference_type, :key], unique: true
add_index :data_references, :reference_type
```

### Recipe JSON Schema

```json
{
  "name": "Oyakodon (Chicken and Egg Rice Bowl)",
  "language": "en",
  "requires_precision": false,
  "servings": {
    "original": 2,
    "min": 1,
    "max": 4
  },
  "timing": {
    "prep_minutes": 10,
    "cook_minutes": 15,
    "total_minutes": 25
  },
  "nutrition": {
    "per_serving": {
      "calories": 520,
      "protein_g": 35,
      "carbs_g": 62,
      "fat_g": 12,
      "fiber_g": 2
    }
  },
  "aliases": ["Oyako Donburi", "Parent-Child Bowl"],
  "dietary_tags": ["gluten-free"],
  "dish_types": ["main-course"],
  "recipe_types": ["rice-bowl", "quick-weeknight"],
  "cuisines": ["japanese"],
  "ingredient_groups": [
    {
      "name": "Main Ingredients",
      "items": [
        {
          "id": "ing-001",
          "name": "boneless chicken thigh",
          "amount": 300,
          "unit": "g",
          "preparation": "cut into bite-sized pieces"
        },
        {
          "id": "ing-002",
          "name": "eggs",
          "amount": 3,
          "unit": "whole"
        }
      ]
    }
  ],
  "steps": [
    {
      "id": "step-001",
      "order": 1,
      "instructions": {
        "original": "In a small pan, combine dashi, soy sauce, mirin, and sugar. Bring to a simmer.",
        "easier": "Put the broth ingredients in a small pan and heat until bubbling gently.",
        "no_equipment": "Mix broth ingredients in any small pot and heat on stove."
      },
      "timing_minutes": 2
    }
  ],
  "equipment": ["small_pan", "rice_cooker"],
  "translations": {
    "ja": {
      "name": "親子丼",
      "ingredient_groups": [...],
      "steps": [...]
    }
  },
  "source_url": "https://example.com/oyakodon-recipe",
  "admin_notes": "Imported via AI discovery 2025-10-07"
}
```

---

## API Endpoints

### Public Routes (User-facing)

```ruby
# config/routes.rb

# Authentication
devise_for :users

# Recipe browsing
GET    /api/v1/recipes                    # List/search recipes
GET    /api/v1/recipes/:id                # Get single recipe
POST   /api/v1/recipes/:id/scale          # Scale recipe (returns scaled JSON, doesn't save)

# User features (requires auth)
POST   /api/v1/recipes/:id/favorite       # Add to favorites
DELETE /api/v1/recipes/:id/favorite       # Remove from favorites
GET    /api/v1/users/me/favorites         # Get user's favorites

POST   /api/v1/recipes/:id/notes          # Create note
PUT    /api/v1/notes/:id                  # Update note
DELETE /api/v1/notes/:id                  # Delete note
GET    /api/v1/recipes/:id/notes          # Get notes for recipe

# Data references (public read)
GET    /api/v1/data_references            # Get all references (grouped by type)
```

### Admin Routes

```ruby
namespace :admin do
  # Recipe management
  resources :recipes do
    member do
      post :regenerate_variants          # Trigger variant regeneration
      post :regenerate_translations      # Trigger translation job
    end
  end

  # AI Recipe Discovery
  post   '/recipes/discover'             # Search for recipes via AI
  post   '/recipes/extract'              # Extract recipe from selected URL

  # Data reference management
  resources :data_references

  # Nutrition database
  resources :ingredients do
    resources :aliases
  end
end
```

### API Response Examples

**GET /api/v1/recipes?cuisine=japanese&dietary_tags=gluten_free&max_calories=600**

```json
{
  "recipes": [
    {
      "id": "uuid-here",
      "name": "Oyakodon",
      "cuisines": ["japanese"],
      "nutrition": {
        "per_serving": {
          "calories": 520,
          "protein_g": 35
        }
      },
      "timing": {
        "total_minutes": 25
      },
      "dietary_tags": ["gluten_free"]
    }
  ],
  "meta": {
    "total": 15,
    "page": 1,
    "per_page": 20
  }
}
```

**POST /api/v1/recipes/:id/scale**

Request:
```json
{
  "scale_type": "by_ingredient",
  "ingredient_id": "ing-001",
  "target_amount": 200,
  "target_unit": "g"
}
```

Response:
```json
{
  "scaled_recipe": {
    "servings": { "scaled": 1.33 },
    "ingredient_groups": [
      {
        "items": [
          {
            "id": "ing-001",
            "name": "boneless chicken thigh",
            "amount": 200,
            "unit": "g"
          },
          {
            "id": "ing-002",
            "name": "eggs",
            "amount": 2,
            "unit": "whole"
          }
        ]
      }
    ]
  }
}
```

---

## Background Jobs

### Job Classes

```ruby
# app/jobs/generate_step_variants_job.rb
class GenerateStepVariantsJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)

    recipe.steps.each do |step|
      # Generate "Easier" variant
      easier_variant = generate_easier_variant(recipe, step)
      step['instructions']['easier'] = easier_variant

      # Generate "No Equipment" variant
      no_equipment_variant = generate_no_equipment_variant(recipe, step)
      step['instructions']['no_equipment'] = no_equipment_variant
    end

    recipe.update!(
      steps: recipe.steps,
      variants_generated: true,
      variants_generated_at: Time.current
    )
  end

  private

  def generate_easier_variant(recipe, step)
    # Call Claude API with prompt from ai-prompts/generate-step-variants.md
    # See AI Integrations section
  end

  def generate_no_equipment_variant(recipe, step)
    # Call Claude API with prompt from ai-prompts/generate-step-variants.md
  end
end

# app/jobs/translate_recipe_job.rb
class TranslateRecipeJob < ApplicationJob
  queue_as :default

  LANGUAGES = ['ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr']

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    translations = {}

    LANGUAGES.each do |target_lang|
      translations[target_lang] = translate_to_language(recipe, target_lang)
    end

    recipe.update!(
      translations: translations,
      translations_completed: true
    )
  end

  private

  def translate_to_language(recipe, target_lang)
    # Call Claude API with translation prompt
    # Maintains structure, culturally accurate ingredient names
  end
end

# app/jobs/nutrition_lookup_job.rb
class NutritionLookupJob < ApplicationJob
  queue_as :nutrition

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    total_nutrition = calculate_recipe_nutrition(recipe)

    recipe.update!(
      nutrition: {
        per_serving: divide_by_servings(total_nutrition, recipe.servings['original'])
      }
    )
  end

  private

  def calculate_recipe_nutrition(recipe)
    # For each ingredient, lookup nutrition via NutritionLookupService
    # Aggregate totals
  end
end
```

---

## Frontend Architecture

### Vue.js 3 Component Structure

```
frontend/
├── src/
│   ├── main.js
│   ├── App.vue
│   ├── router/
│   │   └── index.js
│   ├── stores/
│   │   ├── recipeStore.js      # Pinia store for recipes
│   │   ├── userStore.js         # User auth state
│   │   └── uiStore.js           # UI state (language, filters)
│   ├── components/
│   │   ├── layout/
│   │   │   ├── NavBar.vue
│   │   │   ├── Footer.vue
│   │   │   └── LanguageSelector.vue
│   │   ├── recipe/
│   │   │   ├── RecipeCard.vue
│   │   │   ├── RecipeDetail.vue
│   │   │   ├── IngredientList.vue
│   │   │   ├── StepList.vue
│   │   │   ├── StepVariantToggle.vue
│   │   │   ├── ScalingControls.vue
│   │   │   └── NutritionInfo.vue
│   │   ├── search/
│   │   │   ├── SearchBar.vue
│   │   │   ├── FilterToolbar.vue
│   │   │   └── FilterPanel.vue
│   │   └── admin/
│   │       ├── RecipeForm.vue
│   │       ├── AIRecipeDiscovery.vue
│   │       └── DataReferenceManager.vue
│   ├── views/
│   │   ├── Home.vue
│   │   ├── RecipeList.vue
│   │   ├── RecipeShow.vue
│   │   ├── UserDashboard.vue
│   │   └── admin/
│   │       ├── AdminDashboard.vue
│   │       ├── RecipeManagement.vue
│   │       └── DataReferences.vue
│   └── services/
│       ├── api.js               # Axios instance
│       ├── recipeService.js     # Recipe API calls
│       ├── authService.js       # Authentication
│       └── scalingService.js    # Client-side scaling logic
```

### Volt PrimeVue Integration

**What is Volt PrimeVue?**
Volt is a premium Vue.js 3 admin template built on PrimeVue - a comprehensive UI component library. It provides pre-built, professionally designed components that are easy to customize.

**Why Volt PrimeVue?**
- **Pre-built components:** No need to design from scratch (saves time for solo dev)
- **Easy to adjust:** Simple props and slots pattern, straightforward to customize
- **Comprehensive:** Has everything needed (forms, tables, modals, navigation)
- **Responsive out of the box:** Mobile-friendly by default
- **Clean code:** Well-structured, easy to understand and modify

**Key PrimeVue Components We'll Use:**

```javascript
// Main components for the recipe app
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Dropdown from 'primevue/dropdown'
import MultiSelect from 'primevue/multiselect'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Card from 'primevue/card'
import Dialog from 'primevue/dialog'
import Tabs from 'primevue/tabs'
import TabPanel from 'primevue/tabpanel'
import Chip from 'primevue/chip'
import Tag from 'primevue/tag'
import Slider from 'primevue/slider'
import Textarea from 'primevue/textarea'
import Toast from 'primevue/toast'
```

**Setup (main.js):**

```javascript
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import ToastService from 'primevue/toastservice'

// Import Volt theme CSS
import 'primevue/resources/themes/lara-light-blue/theme.css'
import 'primevue/resources/primevue.min.css'
import 'primeicons/primeicons.css'

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(PrimeVue)
app.use(ToastService)
app.mount('#app')
```

**Easy Customization Examples:**

```vue
<!-- Simple prop adjustments -->
<Button
  label="Save Recipe"
  icon="pi pi-check"
  severity="success"
  @click="saveRecipe"
/>

<!-- Easy styling override -->
<Button
  label="Delete"
  severity="danger"
  class="custom-delete-btn"
/>

<style scoped>
.custom-delete-btn {
  background-color: #ff0000 !important;
  border: none !important;
}
</style>

<!-- Flexible slot usage -->
<Card>
  <template #header>
    <img src="/recipe-image.jpg" />
  </template>
  <template #title>
    Recipe Title
  </template>
  <template #content>
    Recipe content here - fully customizable
  </template>
</Card>
```

**Filter Toolbar Example (Easy to Adjust):**

```vue
<template>
  <div class="filter-toolbar">
    <MultiSelect
      v-model="selectedCuisines"
      :options="cuisines"
      optionLabel="label"
      placeholder="Select Cuisines"
      :maxSelectedLabels="3"
      class="w-full md:w-20rem"
    />

    <MultiSelect
      v-model="selectedDietaryTags"
      :options="dietaryTags"
      optionLabel="label"
      placeholder="Dietary Restrictions"
      class="w-full md:w-20rem"
    />

    <InputNumber
      v-model="maxCalories"
      placeholder="Max Calories"
      :min="0"
      :max="2000"
      :step="50"
    />

    <Button
      label="Search"
      icon="pi pi-search"
      @click="applyFilters"
    />
  </div>
</template>

<style scoped>
.filter-toolbar {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

/* Easy to adjust spacing, colors, sizes */
.filter-toolbar .p-button {
  height: 48px; /* Match input height */
}
</style>
```

**DataTable for Admin (Powerful but Simple):**

```vue
<template>
  <DataTable
    :value="recipes"
    :paginator="true"
    :rows="20"
    filterDisplay="row"
    responsiveLayout="scroll"
  >
    <Column field="name" header="Recipe Name" sortable :filter="true"></Column>
    <Column field="cuisines" header="Cuisine">
      <template #body="slotProps">
        <Chip
          v-for="cuisine in slotProps.data.cuisines"
          :key="cuisine"
          :label="cuisine"
          class="mr-2"
        />
      </template>
    </Column>
    <Column header="Actions">
      <template #body="slotProps">
        <Button
          icon="pi pi-pencil"
          class="p-button-sm p-button-text"
          @click="editRecipe(slotProps.data)"
        />
        <Button
          icon="pi pi-trash"
          class="p-button-sm p-button-text p-button-danger"
          @click="deleteRecipe(slotProps.data)"
        />
      </template>
    </Column>
  </DataTable>
</template>
```

**Key Advantages for Solo Dev:**
1. **No design skills needed** - Components look professional by default
2. **Easy to modify** - Change colors, sizes, spacing with simple CSS
3. **Props are intuitive** - `severity="success"` makes button green, that's it
4. **Good docs** - PrimeVue docs are comprehensive with live examples
5. **Consistent** - All components follow same patterns (v-model, props, events)

### Key Components

**RecipeDetail.vue**
```vue
<template>
  <div class="recipe-detail">
    <h1>{{ currentRecipe.name }}</h1>

    <ScalingControls
      :recipe="currentRecipe"
      @scale="handleScale"
    />

    <IngredientList
      :ingredients="scaledRecipe.ingredient_groups"
    />

    <StepList
      :steps="scaledRecipe.steps"
      :variant="selectedVariant"
      @variant-change="handleVariantChange"
    />

    <NutritionInfo
      :nutrition="scaledRecipe.nutrition"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRecipeStore } from '@/stores/recipeStore'

const recipeStore = useRecipeStore()
const selectedVariant = ref('original')
const scalingFactor = ref(1.0)

const currentRecipe = computed(() => recipeStore.currentRecipe)
const scaledRecipe = computed(() => {
  // Apply scaling logic client-side for instant feedback
  return scaleRecipe(currentRecipe.value, scalingFactor.value)
})
</script>
```

**StepVariantToggle.vue**
```vue
<template>
  <div class="variant-toggle">
    <Button
      :class="{ active: variant === 'original' }"
      @click="$emit('change', 'original')"
    >
      Original
    </Button>
    <Button
      :class="{ active: variant === 'easier' }"
      @click="$emit('change', 'easier')"
    >
      Easier
    </Button>
    <Button
      :class="{ active: variant === 'no_equipment' }"
      @click="$emit('change', 'no_equipment')"
    >
      No Equipment
    </Button>
  </div>
</template>
```

---

## Admin Tools

### Duplicate Recipe Detection

**Purpose:** Prevent duplicate recipes from being added to the system by checking name and aliases.

**Implementation:**

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  # Fuzzy search for similar recipe names and aliases
  def self.find_duplicates(name, language = 'en')
    return [] if name.blank?

    normalized_name = normalize_for_search(name)

    where(language: language).select do |recipe|
      # Check recipe name
      similarity = string_similarity(normalized_name, normalize_for_search(recipe.name))
      return true if similarity > 0.85

      # Check aliases
      recipe.aliases.any? do |alias_name|
        string_similarity(normalized_name, normalize_for_search(alias_name)) > 0.85
      end
    end
  end

  private

  def self.normalize_for_search(str)
    str.downcase
       .gsub(/[^\w\s]/, '') # Remove punctuation
       .gsub(/\s+/, ' ')     # Normalize whitespace
       .strip
  end

  def self.string_similarity(str1, str2)
    # Levenshtein distance ratio
    # Returns 0.0 (no match) to 1.0 (exact match)
    require 'levenshtein'
    max_len = [str1.length, str2.length].max
    return 1.0 if max_len.zero?

    distance = Levenshtein.distance(str1, str2)
    1.0 - (distance.to_f / max_len)
  end
end
```

**Admin UI Flow:**

1. Admin enters recipe name in form
2. On blur or after 500ms debounce, check for duplicates:
   ```javascript
   // Vue component
   async checkDuplicates() {
     const response = await api.post('/admin/recipes/check_duplicates', {
       name: this.recipe.name,
       language: this.recipe.language
     })

     if (response.data.similar_recipes.length > 0) {
       this.showDuplicateWarning = true
       this.similarRecipes = response.data.similar_recipes
     }
   }
   ```

3. Show warning modal if duplicates found:
   ```
   ⚠️ Similar recipes found:

   - Pad Thai (95% match) [View]
   - Thai Fried Noodles (88% match) [View]

   [Continue Anyway]  [Cancel]
   ```

4. Admin decides:
   - **Continue Anyway** - Proceeds with creation (different recipe)
   - **Cancel** - Returns to recipe list to edit existing
   - **View** - Opens similar recipe in new tab for comparison

**Controller:**

```ruby
# app/controllers/admin/recipes_controller.rb
class Admin::RecipesController < Admin::BaseController
  def check_duplicates
    similar = Recipe.find_duplicates(
      params[:name],
      params[:language] || 'en'
    )

    render json: {
      similar_recipes: similar.map do |recipe|
        {
          id: recipe.id,
          name: recipe.name,
          aliases: recipe.aliases,
          similarity: calculate_similarity(params[:name], recipe)
        }
      end
    }
  end

  private

  def calculate_similarity(input_name, recipe)
    # Return highest similarity between name and all aliases
    similarities = [recipe.name] + recipe.aliases.map do |candidate|
      Recipe.string_similarity(
        Recipe.normalize_for_search(input_name),
        Recipe.normalize_for_search(candidate)
      )
    end

    (similarities.max * 100).round
  end
end
```

### Data Reference Management

**Purpose:** Admin can view and edit all system data references (dietary tags, dish types, cuisines, units).

**Database seed code:**

See complete seed code in the updated reference documents:
- [dietary-tags.md](data-references/dietary-tags.md) - 42 tags (merged Edamam + our original list)
- [dish-types.md](data-references/dish-types.md) - 16 Edamam standard dish types
- [cuisines.md](data-references/cuisines.md) - 100+ cuisines covering all Edamam's 20
- [recipe-types.md](data-references/recipe-types.md) - 70+ types for cooking methods, proteins, styles

Each reference document includes complete Ruby seed code ready to use.

**Admin UI:**

```vue
<!-- Admin Data Reference Manager -->
<template>
  <div class="data-reference-manager">
    <Tabs v-model:activeIndex="activeTab">
      <TabPanel header="Dietary Tags">
        <DataTable :value="dietaryTags" editMode="row">
          <Column field="key" header="Key"></Column>
          <Column field="display_name" header="Display Name" :editor="textEditor"></Column>
          <Column field="active" header="Active" :editor="checkboxEditor"></Column>
          <Column :rowEditor="true"></Column>
        </DataTable>
        <Button label="Add New" @click="addDietaryTag" />
      </TabPanel>

      <TabPanel header="Dish Types">
        <!-- Similar table -->
      </TabPanel>

      <TabPanel header="Cuisines">
        <!-- Similar table -->
      </TabPanel>

      <TabPanel header="Recipe Types">
        <!-- Similar table -->
      </TabPanel>
    </Tabs>
  </div>
</template>
```

### Prompt Management

**Purpose:** Admin can review and edit all AI prompts used throughout the system for step variants, translations, and recipe discovery.

**Database Schema:**

```ruby
# db/migrate/010_create_ai_prompts.rb
create_table :ai_prompts, id: :uuid do |t|
  t.string :prompt_key, null: false # 'step_variant_easier', 'step_variant_no_equipment', etc.
  t.string :prompt_type, null: false # 'system', 'user'
  t.string :feature_area, null: false # 'step_variants', 'translation', 'recipe_discovery'
  t.text :prompt_text, null: false
  t.text :description # What this prompt does
  t.jsonb :variables, default: [] # List of variables used: ['recipe_name', 'step_order', ...]
  t.boolean :active, default: true
  t.integer :version, default: 1

  t.timestamps
end

add_index :ai_prompts, :prompt_key, unique: true
add_index :ai_prompts, :feature_area
```

**Model:**

```ruby
# app/models/ai_prompt.rb
class AiPrompt < ApplicationRecord
  FEATURE_AREAS = %w[step_variants translation recipe_discovery nutrition_estimation].freeze
  PROMPT_TYPES = %w[system user].freeze

  validates :prompt_key, presence: true, uniqueness: true
  validates :prompt_type, inclusion: { in: PROMPT_TYPES }
  validates :feature_area, inclusion: { in: FEATURE_AREAS }
  validates :prompt_text, presence: true

  scope :active, -> { where(active: true) }
  scope :by_feature, ->(feature) { where(feature_area: feature) }

  # Get prompt text with variable substitution
  def render(variables = {})
    text = prompt_text.dup

    # Replace all {{variable}} placeholders
    variables.each do |key, value|
      text.gsub!("{{#{key}}}", value.to_s)
    end

    text
  end

  # Create new version when editing
  def create_new_version!(new_text)
    self.class.create!(
      prompt_key: "#{prompt_key}_v#{version + 1}",
      prompt_type: prompt_type,
      feature_area: feature_area,
      prompt_text: new_text,
      description: description,
      variables: variables,
      version: version + 1,
      active: false
    )
  end
end
```

**Seed Prompts:**

```ruby
# db/seeds.rb (add to existing seeds)

# Step Variant Prompts
AiPrompt.find_or_create_by!(prompt_key: 'step_variant_easier_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'step_variants'
  p.description = 'System prompt for generating easier step variants'
  p.variables = []
  p.prompt_text = <<~PROMPT
    You are a professional cooking instructor specializing in making recipes accessible to all skill levels.
    Your goal is to rewrite cooking instructions to be easier while maintaining the same end result.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'step_variant_easier_user') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'step_variants'
  p.description = 'User prompt for generating easier step variants'
  p.variables = ['recipe_name', 'cuisines', 'recipe_types', 'step_order', 'step_title',
                 'original_instruction', 'equipment', 'ingredients']
  p.prompt_text = <<~PROMPT
    Recipe Name: {{recipe_name}}
    Cuisine: {{cuisines}}
    Recipe Type: {{recipe_types}}

    Step {{step_order}}: {{step_title}}

    Original Instruction:
    {{original_instruction}}

    Equipment Required: {{equipment}}
    Ingredients Used in This Step: {{ingredients}}

    ---

    Rewrite this instruction to be EASIER for:
    - Someone with limited cooking experience
    - Someone with physical limitations (shaky hands, weak grip, poor vision)
    - Someone who needs more guidance and reassurance

    Guidelines:
    1. Break down complex actions into smaller, sequential parts
    2. Replace technical terms with everyday language
    3. Add time estimates ("about 2 minutes", "30 seconds")
    4. Include visual/sensory cues ("when you see bubbles", "feels like soft butter")
    5. Add reassuring language ("It's okay if...", "Don't worry about...")
    6. Keep the same end goal - result should be identical
    7. Maintain food safety

    Output Format (JSON):
    {
      "text": "The rewritten easier instruction"
    }
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'step_variant_no_equipment_user') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'step_variants'
  p.description = 'User prompt for generating no-equipment step variants'
  p.variables = ['recipe_name', 'step_order', 'step_title', 'original_instruction', 'equipment']
  p.prompt_text = <<~PROMPT
    Recipe Name: {{recipe_name}}
    Step {{step_order}}: {{step_title}}

    Original Instruction:
    {{original_instruction}}

    Equipment Required: {{equipment}}

    ---

    Suggest alternatives using COMMON HOUSEHOLD ITEMS for any specialized equipment.

    Guidelines:
    1. Chopsticks → fork → knife → hands (in order of preference)
    2. Whisk → fork vigorously
    3. Food processor → knife and cutting board
    4. Stand mixer → hand whisk or wooden spoon
    5. Rice cooker → pot on stove
    6. Be honest about tradeoffs ("takes longer", "requires more effort")
    7. If no equipment alternative exists, explain the workaround clearly

    Output Format (JSON):
    {
      "text": "The instruction with household item alternatives"
    }
  PROMPT
end

# Translation Prompts
AiPrompt.find_or_create_by!(prompt_key: 'recipe_translation_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'translation'
  p.description = 'System prompt for recipe translation'
  p.variables = []
  p.prompt_text = <<~PROMPT
    You are a professional culinary translator specializing in recipe localization.
    Your goal is to translate recipes while preserving cultural authenticity of ingredients.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_translation_user') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'translation'
  p.description = 'User prompt for recipe translation'
  p.variables = ['target_language', 'recipe_json']
  p.prompt_text = <<~PROMPT
    Translate this recipe to {{target_language}}.

    Recipe (JSON):
    {{recipe_json}}

    Translation Rules:
    1. Translate recipe name
    2. Translate all step instructions (original, easier, no_equipment)
    3. For ingredients:
       - Use culturally appropriate names
       - Example: "negi" in Japanese = "ネギ", in English = "negi (Japanese green onion)"
       - Preserve authenticity over literal translation
    4. Maintain JSON structure exactly
    5. Keep all IDs, amounts, units unchanged
    6. Translate equipment names

    Output Format: Complete recipe JSON with translated text fields.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'step_variant_no_equipment_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'step_variants'
  p.description = 'System prompt for generating no-equipment step variants'
  p.variables = []
  p.prompt_text = <<~PROMPT
    You are a creative cooking expert who helps people cook without specialized equipment.
    Your goal is to suggest alternative methods using common household items.
  PROMPT
end

# Recipe Discovery Prompts
AiPrompt.find_or_create_by!(prompt_key: 'recipe_discovery_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'recipe_discovery'
  p.description = 'System prompt for recipe discovery'
  p.variables = []
  p.prompt_text = <<~PROMPT
    You are a recipe research assistant. When given a recipe name, search your knowledge
    for authentic, high-quality recipes and return multiple options with source details.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_discovery_search') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'recipe_discovery'
  p.description = 'Prompt for searching recipe options'
  p.variables = ['search_query']
  p.prompt_text = <<~PROMPT
    Find 5-10 high-quality recipes for: "{{search_query}}"

    For each recipe, provide:
    1. Recipe name
    2. Brief description (1-2 sentences)
    3. Estimated source/origin (cookbook, chef, region)
    4. Why this version is notable

    Output Format (JSON):
    {
      "recipes": [
        {
          "name": "Recipe Name",
          "description": "Brief description",
          "source": "Origin/source information",
          "notable_for": "What makes this version special"
        }
      ]
    }
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'recipe_discovery_extract') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'recipe_discovery'
  p.description = 'Prompt for extracting recipe details into structured format'
  p.variables = ['recipe_description']
  p.prompt_text = <<~PROMPT
    Extract this recipe into structured JSON format:

    {{recipe_description}}

    Output Format (match our recipe schema):
    {
      "name": "Recipe Name",
      "servings": { "original": 4, "min": 1, "max": 8 },
      "timing": { "prep_minutes": 10, "cook_minutes": 15, "total_minutes": 25 },
      "ingredient_groups": [
        {
          "name": "Main Ingredients",
          "items": [
            { "name": "ingredient", "amount": 100, "unit": "g", "preparation": "diced" }
          ]
        }
      ],
      "steps": [
        {
          "order": 1,
          "instructions": { "original": "Step instruction here" }
        }
      ],
      "dietary_tags": [],
      "dish_types": [],
      "recipe_types": [],
      "cuisines": []
    }
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'nutrition_estimation_system') do |p|
  p.prompt_type = 'system'
  p.feature_area = 'nutrition_estimation'
  p.description = 'System prompt for nutrition estimation'
  p.variables = []
  p.prompt_text = <<~PROMPT
    You are a nutrition expert. Provide accurate nutrition estimates based on similar foods.
  PROMPT
end

AiPrompt.find_or_create_by!(prompt_key: 'nutrition_estimation') do |p|
  p.prompt_type = 'user'
  p.feature_area = 'nutrition_estimation'
  p.description = 'AI fallback for nutrition estimation when API fails'
  p.variables = ['ingredient_name']
  p.prompt_text = <<~PROMPT
    Estimate nutrition data per 100g for: {{ingredient_name}}

    Provide your best estimate based on similar foods.
    Output format (JSON):
    {
      "calories": 150,
      "protein_g": 5.2,
      "carbs_g": 20.1,
      "fat_g": 3.5,
      "fiber_g": 2.0
    }
  PROMPT
end
```

**Updated AI Services to Use Database Prompts:**

```ruby
# app/services/step_variant_generator.rb (updated)
class StepVariantGenerator < AiService
  def generate_easier_variant(recipe, step)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_easier_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_easier_user')

    rendered_user_prompt = user_prompt.render(
      recipe_name: recipe.name,
      cuisines: recipe.cuisines.join(', '),
      recipe_types: recipe.recipe_types.join(', '),
      step_order: step['order'],
      step_title: step['title'] || "Step #{step['order']}",
      original_instruction: step.dig('instructions', 'original'),
      equipment: step['equipment']&.join(', ') || 'None specified',
      ingredients: extract_step_ingredients(recipe, step).join(', ')
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 1024
    )

    parse_variant_response(response)
  end

  # Similar updates for generate_no_equipment_variant
end

# app/services/recipe_translator.rb (updated)
class RecipeTranslator < AiService
  def translate_recipe(recipe, target_language)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_translation_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_translation_user')

    lang_name = LANGUAGES[target_language]

    rendered_user_prompt = user_prompt.render(
      target_language: lang_name,
      recipe_json: recipe.to_json
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_translation_response(response, target_language)
  end
end
```

**Admin Routes:**

```ruby
# config/routes.rb
namespace :admin do
  resources :ai_prompts do
    member do
      post :activate
      post :test
    end
  end
end
```

**Admin Controller:**

```ruby
# app/controllers/admin/ai_prompts_controller.rb
class Admin::AiPromptsController < Admin::BaseController
  before_action :set_prompt, only: [:show, :edit, :update, :activate, :test]

  def index
    @prompts = AiPrompt.order(:feature_area, :prompt_key)
    render json: @prompts
  end

  def show
    render json: @prompt
  end

  def update
    if @prompt.update(prompt_params)
      render json: @prompt
    else
      render json: { errors: @prompt.errors }, status: :unprocessable_entity
    end
  end

  def activate
    # Deactivate other versions
    AiPrompt.where(
      prompt_key: @prompt.prompt_key.gsub(/_v\d+$/, '')
    ).update_all(active: false)

    @prompt.update!(active: true)
    render json: { message: 'Prompt activated' }
  end

  def test
    # Test prompt with sample data
    variables = JSON.parse(params[:test_variables] || '{}')
    rendered = @prompt.render(variables)

    render json: {
      rendered_prompt: rendered,
      character_count: rendered.length,
      estimated_tokens: (rendered.length / 4).round
    }
  end

  private

  def set_prompt
    @prompt = AiPrompt.find(params[:id])
  end

  def prompt_params
    params.require(:ai_prompt).permit(:prompt_text, :description, :active)
  end
end
```

**Admin UI:**

```vue
<!-- src/views/admin/PromptManagement.vue -->
<template>
  <div class="prompt-management">
    <h1>AI Prompt Management</h1>

    <Tabs v-model:activeIndex="activeTab">
      <TabPanel header="Step Variants">
        <PromptEditor
          :prompts="stepVariantPrompts"
          @update="updatePrompt"
          @test="testPrompt"
        />
      </TabPanel>

      <TabPanel header="Translation">
        <PromptEditor
          :prompts="translationPrompts"
          @update="updatePrompt"
          @test="testPrompt"
        />
      </TabPanel>

      <TabPanel header="Recipe Discovery">
        <PromptEditor
          :prompts="discoveryPrompts"
          @update="updatePrompt"
          @test="testPrompt"
        />
      </TabPanel>

      <TabPanel header="Nutrition">
        <PromptEditor
          :prompts="nutritionPrompts"
          @update="updatePrompt"
          @test="testPrompt"
        />
      </TabPanel>
    </Tabs>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const prompts = ref([])
const activeTab = ref(0)

const stepVariantPrompts = computed(() =>
  prompts.value.filter(p => p.feature_area === 'step_variants')
)

const translationPrompts = computed(() =>
  prompts.value.filter(p => p.feature_area === 'translation')
)

const discoveryPrompts = computed(() =>
  prompts.value.filter(p => p.feature_area === 'recipe_discovery')
)

const nutritionPrompts = computed(() =>
  prompts.value.filter(p => p.feature_area === 'nutrition_estimation')
)

onMounted(async () => {
  const response = await api.get('/admin/ai_prompts')
  prompts.value = response.data
})

const updatePrompt = async (promptId, updates) => {
  await api.put(`/admin/ai_prompts/${promptId}`, { ai_prompt: updates })
  // Refresh
  const response = await api.get('/admin/ai_prompts')
  prompts.value = response.data
}

const testPrompt = async (promptId, testVariables) => {
  const response = await api.post(`/admin/ai_prompts/${promptId}/test`, {
    test_variables: JSON.stringify(testVariables)
  })
  return response.data
}
</script>
```

```vue
<!-- src/components/admin/PromptEditor.vue -->
<template>
  <div class="prompt-editor">
    <DataTable :value="prompts" dataKey="id">
      <Column field="prompt_key" header="Prompt Key" style="width: 250px">
        <template #body="slotProps">
          <div class="prompt-key-cell">
            <span class="key">{{ slotProps.data.prompt_key }}</span>
            <Tag
              v-if="slotProps.data.active"
              severity="success"
              value="Active"
              class="ml-2"
            />
          </div>
        </template>
      </Column>

      <Column field="prompt_type" header="Type" style="width: 100px">
        <template #body="slotProps">
          <Tag :severity="slotProps.data.prompt_type === 'system' ? 'info' : 'warning'">
            {{ slotProps.data.prompt_type }}
          </Tag>
        </template>
      </Column>

      <Column field="description" header="Description"></Column>

      <Column field="variables" header="Variables" style="width: 200px">
        <template #body="slotProps">
          <div class="variables-list">
            <Chip
              v-for="variable in slotProps.data.variables"
              :key="variable"
              :label="variable"
              class="mr-1 mb-1"
            />
          </div>
        </template>
      </Column>

      <Column header="Actions" style="width: 150px">
        <template #body="slotProps">
          <Button
            icon="pi pi-pencil"
            label="Edit"
            class="p-button-sm p-button-text"
            @click="editPrompt(slotProps.data)"
          />
          <Button
            icon="pi pi-play"
            label="Test"
            class="p-button-sm p-button-text"
            @click="testPrompt(slotProps.data)"
          />
        </template>
      </Column>
    </DataTable>

    <!-- Edit Dialog -->
    <Dialog
      v-model:visible="showEditDialog"
      :header="`Edit: ${selectedPrompt?.prompt_key}`"
      :style="{ width: '70vw' }"
      modal
    >
      <div class="edit-prompt-form">
        <div class="field">
          <label>Description</label>
          <InputText v-model="editForm.description" class="w-full" />
        </div>

        <div class="field">
          <label>Prompt Text</label>
          <Textarea
            v-model="editForm.prompt_text"
            :autoResize="true"
            rows="20"
            class="w-full"
            style="font-family: monospace"
          />
          <small class="text-muted">
            Variables available: {{ selectedPrompt?.variables?.join(', ') }}
          </small>
        </div>

        <div class="field">
          <label>Character Count: {{ editForm.prompt_text?.length || 0 }}</label>
          <label class="ml-4">Estimated Tokens: {{ estimatedTokens }}</label>
        </div>
      </div>

      <template #footer>
        <Button label="Cancel" @click="showEditDialog = false" class="p-button-text" />
        <Button label="Save" @click="savePrompt" />
      </template>
    </Dialog>

    <!-- Test Dialog -->
    <Dialog
      v-model:visible="showTestDialog"
      header="Test Prompt"
      :style="{ width: '60vw' }"
      modal
    >
      <div class="test-prompt-form">
        <h3>Input Variables</h3>
        <div
          v-for="variable in selectedPrompt?.variables"
          :key="variable"
          class="field"
        >
          <label>{{ variable }}</label>
          <InputText v-model="testVariables[variable]" class="w-full" />
        </div>

        <Button label="Render Preview" @click="renderPreview" class="mb-3" />

        <div v-if="renderedPreview" class="rendered-preview">
          <h3>Rendered Output</h3>
          <pre>{{ renderedPreview }}</pre>
        </div>
      </div>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  prompts: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update', 'test'])

const showEditDialog = ref(false)
const showTestDialog = ref(false)
const selectedPrompt = ref(null)
const editForm = ref({})
const testVariables = ref({})
const renderedPreview = ref('')

const estimatedTokens = computed(() => {
  return Math.round((editForm.value.prompt_text?.length || 0) / 4)
})

const editPrompt = (prompt) => {
  selectedPrompt.value = prompt
  editForm.value = {
    description: prompt.description,
    prompt_text: prompt.prompt_text
  }
  showEditDialog.value = true
}

const savePrompt = async () => {
  await emit('update', selectedPrompt.value.id, editForm.value)
  showEditDialog.value = false
}

const testPrompt = (prompt) => {
  selectedPrompt.value = prompt
  testVariables.value = {}
  renderedPreview.value = ''
  showTestDialog.value = true
}

const renderPreview = async () => {
  const result = await emit('test', selectedPrompt.value.id, testVariables.value)
  renderedPreview.value = result.rendered_prompt
}
</script>

<style scoped>
.prompt-key-cell {
  display: flex;
  align-items: center;
}

.variables-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem;
}

.rendered-preview {
  margin-top: 1rem;
  padding: 1rem;
  background: #f5f5f5;
  border-radius: 4px;
}

.rendered-preview pre {
  white-space: pre-wrap;
  word-wrap: break-word;
  font-family: monospace;
  font-size: 0.9rem;
}
</style>
```

**Key Features:**

1. **Database-Driven Prompts:** All AI prompts stored in database, editable via admin panel
2. **Version Control:** Create new versions without breaking active prompts
3. **Variable System:** Template variables like `{{recipe_name}}` get replaced at runtime
4. **Test Mode:** Preview rendered prompts with sample data before activating
5. **Feature Grouping:** Organized by feature area (step variants, translation, etc.)
6. **Active/Inactive States:** Only active prompts are used by services
7. **Audit Trail:** Track changes via `updated_at` timestamps

**Migration Path:**

Move all hardcoded prompts from service classes to database seeds, making them editable without code changes.

---

## Testing Strategy (Light for MVP)

**Philosophy:** Dogfooding approach means you'll catch bugs immediately. Focus tests on critical business logic, not comprehensive coverage.

### What to Test

**Critical Business Logic (RSpec):**

```ruby
# spec/services/recipe_scaler_spec.rb
RSpec.describe RecipeScaler do
  describe '#scale_by_servings' do
    it 'scales all ingredients proportionally' do
      recipe = build(:recipe, servings: { original: 4 })
      scaled = RecipeScaler.scale_by_servings(recipe, 2)

      expect(scaled.servings[:scaled]).to eq(2)
      # Test ingredient amounts scaled by 0.5
    end

    it 'rounds to friendly fractions in cooking context' do
      recipe = build(:recipe, requires_precision: false)
      scaled = RecipeScaler.scale_by_servings(recipe, 3)

      # 0.66 cups should become "2/3 cup"
      expect(scaled.ingredients.first.amount_display).to eq("2/3")
    end

    it 'preserves precision in baking context' do
      recipe = build(:recipe, requires_precision: true)
      scaled = RecipeScaler.scale_by_servings(recipe, 3)

      # Baking should use grams, not rounded fractions
      expect(scaled.ingredients.first.unit).to eq("g")
    end
  end

  describe '#scale_by_ingredient' do
    it 'calculates correct scaling factor from target ingredient' do
      recipe = build(:recipe)
      scaled = RecipeScaler.scale_by_ingredient(
        recipe,
        ingredient_id: 'ing-001',
        target_amount: 200,
        target_unit: 'g'
      )

      # Original was 300g, target is 200g, factor should be 0.666...
      expect(scaled.scaling_factor).to be_within(0.01).of(0.67)
    end
  end
end

# spec/services/nutrition_calculator_spec.rb
RSpec.describe NutritionCalculator do
  it 'calculates recipe nutrition from ingredient data' do
    recipe = build(:recipe_with_ingredients)
    nutrition = NutritionCalculator.calculate(recipe)

    expect(nutrition[:calories]).to be > 0
    expect(nutrition[:protein_g]).to be > 0
  end

  it 'divides by servings correctly' do
    recipe = build(:recipe, servings: { original: 4 })
    per_serving = NutritionCalculator.per_serving(recipe)

    expect(per_serving[:calories]).to eq(recipe.nutrition[:total_calories] / 4.0)
  end
end

# spec/models/recipe_spec.rb
RSpec.describe Recipe do
  describe '.find_duplicates' do
    it 'finds recipes with similar names' do
      create(:recipe, name: 'Pad Thai', language: 'en')

      duplicates = Recipe.find_duplicates('Phad Thai', 'en')
      expect(duplicates.size).to eq(1)
    end

    it 'checks aliases for matches' do
      create(:recipe, name: 'Oyakodon', aliases: ['Chicken and Egg Bowl'], language: 'en')

      duplicates = Recipe.find_duplicates('chicken egg bowl', 'en')
      expect(duplicates.size).to eq(1)
    end

    it 'only checks same language' do
      create(:recipe, name: 'Pad Thai', language: 'en')

      duplicates = Recipe.find_duplicates('Pad Thai', 'ja')
      expect(duplicates).to be_empty
    end
  end
end
```

**API Authentication (RSpec Requests):**

```ruby
# spec/requests/api/v1/recipes_spec.rb
RSpec.describe 'Recipes API' do
  describe 'GET /api/v1/recipes' do
    it 'returns public recipes without authentication' do
      create_list(:recipe, 5)
      get '/api/v1/recipes'

      expect(response).to have_http_status(:success)
      expect(json_response['recipes'].size).to eq(5)
    end

    it 'filters by dietary tags' do
      create(:recipe, dietary_tags: ['vegan'])
      create(:recipe, dietary_tags: ['gluten-free'])

      get '/api/v1/recipes', params: { dietary_tags: ['vegan'] }

      expect(json_response['recipes'].size).to eq(1)
    end
  end

  describe 'POST /api/v1/recipes/:id/favorite' do
    it 'requires authentication' do
      recipe = create(:recipe)
      post "/api/v1/recipes/#{recipe.id}/favorite"

      expect(response).to have_http_status(:unauthorized)
    end

    it 'creates favorite when authenticated' do
      user = create(:user)
      recipe = create(:recipe)

      post "/api/v1/recipes/#{recipe.id}/favorite",
           headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      expect(user.favorites.count).to eq(1)
    end
  end
end
```

### What NOT to Test (Skip for MVP)

- ❌ **E2E tests** - Manual testing faster for small app
- ❌ **Background job tests** - Check Sidekiq dashboard instead
- ❌ **Frontend unit tests** - Browser testing sufficient
- ❌ **Integration tests beyond auth** - Core business logic covered above
- ❌ **Edge cases** - Add tests when bugs discovered

### Testing Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/services/recipe_scaler_spec.rb

# Run tests with coverage report (optional)
COVERAGE=true bundle exec rspec
```

---

---

## AI Integrations

### Anthropic Claude API Setup

**Installation:**
```bash
bundle add anthropic-rb
# or
gem 'anthropic', '~> 0.3'
```

**Configuration:**
```ruby
# config/initializers/anthropic.rb
Anthropic.configure do |config|
  config.api_key = ENV['ANTHROPIC_API_KEY']
  config.api_version = '2023-06-01'
end
```

**Environment Variables:**
```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022
```

### AI Service Patterns

**Base AI Service:**
```ruby
# app/services/ai_service.rb
class AiService
  def initialize
    @client = Anthropic::Client.new
  end

  def call_claude(system_prompt:, user_prompt:, max_tokens: 2048)
    response = @client.messages(
      parameters: {
        model: ENV.fetch('ANTHROPIC_MODEL', 'claude-3-5-sonnet-20241022'),
        max_tokens: max_tokens,
        system: system_prompt,
        messages: [
          {
            role: 'user',
            content: user_prompt
          }
        ]
      }
    )

    response.dig('content', 0, 'text')
  rescue Anthropic::Error => e
    Rails.logger.error("Claude API Error: #{e.message}")
    raise
  end
end
```

### Generate Step Variants

**Implementation:** Uses database-driven prompts from [Prompt Management](#prompt-management) section.

```ruby
# app/services/step_variant_generator.rb
class StepVariantGenerator < AiService
  def generate_easier_variant(recipe, step)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_easier_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_easier_user')

    rendered_user_prompt = user_prompt.render(
      recipe_name: recipe.name,
      cuisines: recipe.cuisines.join(', '),
      recipe_types: recipe.recipe_types.join(', '),
      step_order: step['order'],
      step_title: step['title'] || "Step #{step['order']}",
      original_instruction: step.dig('instructions', 'original'),
      equipment: step['equipment']&.join(', ') || 'None specified',
      ingredients: extract_step_ingredients(recipe, step).join(', ')
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 1024
    )

    parse_variant_response(response)
  end

  def generate_no_equipment_variant(recipe, step)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_no_equipment_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'step_variant_no_equipment_user')

    rendered_user_prompt = user_prompt.render(
      recipe_name: recipe.name,
      step_order: step['order'],
      step_title: step['title'] || "Step #{step['order']}",
      original_instruction: step.dig('instructions', 'original'),
      equipment: step['equipment']&.join(', ') || 'None'
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 1024
    )

    parse_variant_response(response)
  end

  private

  def extract_step_ingredients(recipe, step)
    # Extract ingredient names mentioned in this step
    step_text = step.dig('instructions', 'original')

    recipe.ingredient_groups.flat_map do |group|
      group['items'].select do |ing|
        step_text.include?(ing['name'])
      end.map { |ing| "#{ing['amount']} #{ing['unit']} #{ing['name']}" }
    end
  end

  def parse_variant_response(response)
    json_match = response.match(/\{[^}]+\}/)
    return response unless json_match

    parsed = JSON.parse(json_match[0])
    parsed['text']
  rescue JSON::ParserError
    response # Return raw text if JSON parsing fails
  end
end
```

**Note:** All prompts are stored in the `ai_prompts` table and editable via admin panel (see [Prompt Management](#prompt-management)).

### Recipe Translation

**Implementation:** Uses database-driven prompts from [Prompt Management](#prompt-management) section.

```ruby
# app/services/recipe_translator.rb
class RecipeTranslator < AiService
  LANGUAGES = {
    'ja' => 'Japanese',
    'ko' => 'Korean',
    'zh-tw' => 'Traditional Chinese (Taiwan)',
    'zh-cn' => 'Simplified Chinese (China)',
    'es' => 'Spanish',
    'fr' => 'French'
  }

  def translate_recipe(recipe, target_language)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_translation_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_translation_user')

    lang_name = LANGUAGES[target_language]

    rendered_user_prompt = user_prompt.render(
      target_language: lang_name,
      recipe_json: recipe.to_json
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_translation_response(response, target_language)
  end

  private

  def parse_translation_response(response, language)
    # Extract JSON from response
    json_match = response.match(/\{.*\}/m)
    return nil unless json_match

    JSON.parse(json_match[0])
  rescue JSON::ParserError => e
    Rails.logger.error("Translation parsing failed for #{language}: #{e.message}")
    nil
  end
end
```

**Note:** All prompts are stored in the `ai_prompts` table and editable via admin panel (see [Prompt Management](#prompt-management)).

### AI Recipe Discovery

**Implementation:** Uses database-driven prompts from [Prompt Management](#prompt-management) section.

```ruby
# app/services/recipe_discovery_service.rb
class RecipeDiscoveryService < AiService
  def search_recipes(query)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_discovery_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_discovery_search')

    rendered_user_prompt = user_prompt.render(search_query: query)

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 2048
    )

    parse_discovery_response(response)
  end

  def extract_recipe(selected_recipe_description)
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_discovery_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'recipe_discovery_extract')

    rendered_user_prompt = user_prompt.render(
      recipe_description: selected_recipe_description
    )

    response = call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 4096
    )

    parse_extraction_response(response)
  end

  private

  def parse_discovery_response(response)
    json_match = response.match(/\{.*\}/m)
    return [] unless json_match

    result = JSON.parse(json_match[0])
    result['recipes'] || []
  rescue JSON::ParserError
    []
  end

  def parse_extraction_response(response)
    json_match = response.match(/\{.*\}/m)
    return nil unless json_match

    JSON.parse(json_match[0])
  rescue JSON::ParserError
    nil
  end
end
```

**Note:** All prompts are stored in the `ai_prompts` table and editable via admin panel (see [Prompt Management](#prompt-management)).

### Background Job Integration

```ruby
# app/jobs/generate_step_variants_job.rb
class GenerateStepVariantsJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    generator = StepVariantGenerator.new

    recipe.steps.each do |step|
      # Only generate if original exists
      next unless step.dig('instructions', 'original')

      step['instructions']['easier'] = generator.generate_easier_variant(recipe, step)
      step['instructions']['no_equipment'] = generator.generate_no_equipment_variant(recipe, step)
    end

    recipe.update!(
      steps: recipe.steps,
      variants_generated: true,
      variants_generated_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("Variant generation failed for recipe #{recipe_id}: #{e.message}")
    # Optionally: Set error flag on recipe
  end
end

# app/jobs/translate_recipe_job.rb
class TranslateRecipeJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    translator = RecipeTranslator.new
    translations = {}

    RecipeTranslator::LANGUAGES.keys.each do |lang|
      translations[lang] = translator.translate_recipe(recipe, lang)
    end

    recipe.update!(
      translations: translations,
      translations_completed: true
    )
  rescue StandardError => e
    Rails.logger.error("Translation failed for recipe #{recipe_id}: #{e.message}")
  end
end
```

### Rate Limiting & Cost Management

```ruby
# app/services/ai_service.rb (enhanced)
class AiService
  MAX_RETRIES = 3
  RATE_LIMIT_DELAY = 1.second

  def call_claude(system_prompt:, user_prompt:, max_tokens: 2048)
    retries = 0

    begin
      sleep(RATE_LIMIT_DELAY) # Basic rate limiting

      response = @client.messages(
        parameters: {
          model: ENV.fetch('ANTHROPIC_MODEL', 'claude-3-5-sonnet-20241022'),
          max_tokens: max_tokens,
          system: system_prompt,
          messages: [{ role: 'user', content: user_prompt }]
        }
      )

      # Log usage for cost tracking
      log_api_usage(response)

      response.dig('content', 0, 'text')

    rescue Anthropic::RateLimitError => e
      retries += 1
      if retries <= MAX_RETRIES
        sleep(retries * 2) # Exponential backoff
        retry
      else
        raise
      end
    rescue Anthropic::Error => e
      Rails.logger.error("Claude API Error: #{e.message}")
      raise
    end
  end

  private

  def log_api_usage(response)
    usage = response['usage']
    Rails.logger.info(
      "Claude API Usage - Input: #{usage['input_tokens']}, " \
      "Output: #{usage['output_tokens']}, " \
      "Total: #{usage['input_tokens'] + usage['output_tokens']}"
    )
  end
end
```

---

## Multi-lingual Implementation

**Supported Languages:** English (en), Japanese (ja), Korean (ko), Traditional Chinese (zh-tw), Simplified Chinese (zh-cn), Spanish (es), French (fr)

**Strategy:** Pre-translate recipes at save time (not real-time translation). All translations are stored in the `translations` JSONB field.

### Language Detection in Frontend

```vue
<!-- components/layout/LanguageSelector.vue -->
<template>
  <Dropdown
    v-model="selectedLanguage"
    :options="languages"
    optionLabel="label"
    optionValue="code"
    @change="handleLanguageChange"
    class="language-selector"
  >
    <template #value="slotProps">
      <div class="language-option">
        <span class="flag-icon" :class="`fi fi-${getFlagCode(slotProps.value)}`"></span>
        <span>{{ getLanguageLabel(slotProps.value) }}</span>
      </div>
    </template>
    <template #option="slotProps">
      <div class="language-option">
        <span class="flag-icon" :class="`fi fi-${getFlagCode(slotProps.option.code)}`"></span>
        <span>{{ slotProps.option.label }}</span>
      </div>
    </template>
  </Dropdown>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useUiStore } from '@/stores/uiStore'

const uiStore = useUiStore()
const { locale } = useI18n()

const languages = [
  { code: 'en', label: 'English', flag: 'us' },
  { code: 'ja', label: '日本語', flag: 'jp' },
  { code: 'ko', label: '한국어', flag: 'kr' },
  { code: 'zh-tw', label: '繁體中文', flag: 'tw' },
  { code: 'zh-cn', label: '简体中文', flag: 'cn' },
  { code: 'es', label: 'Español', flag: 'es' },
  { code: 'fr', label: 'Français', flag: 'fr' }
]

const selectedLanguage = ref('en')

onMounted(() => {
  // Detect browser language or use stored preference
  const browserLang = navigator.language.split('-')[0]
  const storedLang = localStorage.getItem('preferredLanguage')

  selectedLanguage.value = storedLang || browserLang || 'en'
  uiStore.setLanguage(selectedLanguage.value)
  locale.value = selectedLanguage.value
})

const handleLanguageChange = (event) => {
  const lang = event.value
  uiStore.setLanguage(lang)
  locale.value = lang
  localStorage.setItem('preferredLanguage', lang)

  // Reload current recipe in new language
  if (window.location.pathname.includes('/recipes/')) {
    window.location.reload()
  }
}

const getFlagCode = (langCode) => {
  return languages.find(l => l.code === langCode)?.flag || 'us'
}

const getLanguageLabel = (langCode) => {
  return languages.find(l => l.code === langCode)?.label || 'English'
}
</script>

<style scoped>
.language-selector {
  min-width: 150px;
}

.language-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.flag-icon {
  width: 20px;
  height: 15px;
  border-radius: 2px;
}
</style>
```

### Translation Workflow (Pre-translate at Save)

**When a recipe is saved:**

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  after_create :enqueue_translation_job
  after_update :enqueue_translation_job, if: :content_changed?

  private

  def enqueue_translation_job
    TranslateRecipeJob.perform_later(id)
  end

  def content_changed?
    saved_change_to_name? ||
    saved_change_to_ingredient_groups? ||
    saved_change_to_steps?
  end
end
```

**Background Job (already implemented in AI Integrations section):**

```ruby
# app/jobs/translate_recipe_job.rb
class TranslateRecipeJob < ApplicationJob
  queue_as :default

  LANGUAGES = ['ja', 'ko', 'zh-tw', 'zh-cn', 'es', 'fr']

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    translator = RecipeTranslator.new
    translations = {}

    LANGUAGES.each do |target_lang|
      translations[target_lang] = translator.translate_recipe(recipe, target_lang)
    end

    recipe.update!(
      translations: translations,
      translations_completed: true
    )
  end
end
```

### Culturally-Aware Ingredient Handling

**Problem:** Some ingredients have culturally-specific names that shouldn't be literally translated.

**Solution:** RecipeTranslator preserves authenticity over literal translation.

**Example:**

Original (English):
```json
{
  "name": "Oyakodon",
  "ingredients": [
    { "name": "negi (Japanese green onion)", "amount": 2, "unit": "stalks" }
  ]
}
```

Japanese Translation:
```json
{
  "name": "親子丼",
  "ingredients": [
    { "name": "ネギ", "amount": 2, "unit": "本" }
  ]
}
```

Korean Translation:
```json
{
  "name": "오야코동",
  "ingredients": [
    { "name": "네기 (일본식 파)", "amount": 2, "unit": "대" }
  ]
}
```

**Key Points:**
- In Japanese: Use native term "ネギ" (negi)
- In Korean: Use transliteration "네기" with explanation in Korean "(일본식 파)"
- In English: Keep "negi" with English explanation "(Japanese green onion)"

This is handled automatically by the AI translation prompts in `RecipeTranslator` service.

### Recipe Data Structure with Translations

```json
{
  "id": "uuid",
  "name": "Oyakodon",
  "language": "en",
  "ingredient_groups": [...],
  "steps": [...],
  "translations": {
    "ja": {
      "name": "親子丼",
      "ingredient_groups": [
        {
          "name": "主な材料",
          "items": [
            {
              "id": "ing-001",
              "name": "鶏もも肉",
              "amount": 300,
              "unit": "g",
              "preparation": "一口大に切る"
            }
          ]
        }
      ],
      "steps": [
        {
          "id": "step-001",
          "order": 1,
          "instructions": {
            "original": "小さな鍋に出汁、醤油、みりん、砂糖を入れて中火にかけます。",
            "easier": "材料を小さな鍋に入れて、優しく沸騰させます。",
            "no_equipment": "どんな小さな鍋でも大丈夫です。コンロで温めます。"
          }
        }
      ]
    },
    "ko": {
      "name": "오야코동",
      "ingredient_groups": [...],
      "steps": [...]
    }
  },
  "translations_completed": true
}
```

### API Endpoint for Language Selection

```ruby
# config/routes.rb
GET /api/v1/recipes/:id?lang=ja

# app/controllers/api/v1/recipes_controller.rb
class Api::V1::RecipesController < ApplicationController
  def show
    recipe = Recipe.find(params[:id])

    # Get requested language or default to recipe's original language
    requested_lang = params[:lang] || recipe.language

    if requested_lang == recipe.language
      # Return original recipe
      render json: recipe
    elsif recipe.translations[requested_lang].present?
      # Return translated version
      translated = recipe.translations[requested_lang]

      render json: {
        id: recipe.id,
        language: requested_lang,
        name: translated['name'],
        ingredient_groups: translated['ingredient_groups'],
        steps: translated['steps'],
        servings: recipe.servings,
        timing: recipe.timing,
        nutrition: recipe.nutrition,
        dietary_tags: recipe.dietary_tags,
        dish_types: recipe.dish_types,
        recipe_types: recipe.recipe_types,
        cuisines: recipe.cuisines
      }
    else
      # Translation not available, return original with warning
      render json: {
        recipe: recipe,
        warning: "Translation to #{requested_lang} not available"
      }, status: 200
    end
  end
end
```

### Frontend Language Switching

```javascript
// stores/uiStore.js
import { defineStore } from 'pinia'

export const useUiStore = defineStore('ui', {
  state: () => ({
    language: 'en'
  }),

  actions: {
    setLanguage(lang) {
      this.language = lang
    }
  }
})

// services/recipeService.js
export const getRecipe = async (recipeId, language) => {
  const response = await api.get(`/api/v1/recipes/${recipeId}`, {
    params: { lang: language }
  })
  return response.data
}

// Component usage
import { watch } from 'vue'
import { useUiStore } from '@/stores/uiStore'

const uiStore = useUiStore()
const recipe = ref(null)

// Watch for language changes and reload recipe
watch(() => uiStore.language, async (newLang) => {
  recipe.value = await getRecipe(route.params.id, newLang)
})
```

### Translation Status Indicator

```vue
<!-- components/recipe/TranslationStatus.vue -->
<template>
  <div class="translation-status">
    <Tag
      v-if="!recipe.translations_completed"
      severity="warning"
      icon="pi pi-spin pi-spinner"
    >
      Translations in progress...
    </Tag>

    <div v-else class="available-languages">
      <span class="label">Available in:</span>
      <Chip
        v-for="lang in availableLanguages"
        :key="lang"
        :label="getLanguageName(lang)"
        @click="switchLanguage(lang)"
        class="language-chip"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useUiStore } from '@/stores/uiStore'

const props = defineProps({
  recipe: {
    type: Object,
    required: true
  }
})

const uiStore = useUiStore()

const availableLanguages = computed(() => {
  const languages = [props.recipe.language]

  if (props.recipe.translations) {
    languages.push(...Object.keys(props.recipe.translations))
  }

  return languages
})

const getLanguageName = (code) => {
  const names = {
    'en': 'EN',
    'ja': '日本語',
    'ko': '한국어',
    'zh-tw': '繁體',
    'zh-cn': '简体',
    'es': 'ES',
    'fr': 'FR'
  }
  return names[code] || code
}

const switchLanguage = (lang) => {
  uiStore.setLanguage(lang)
}
</script>

<style scoped>
.translation-status {
  margin: 1rem 0;
}

.available-languages {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.language-chip {
  cursor: pointer;
  transition: transform 0.2s;
}

.language-chip:hover {
  transform: scale(1.05);
}
</style>
```

### Admin Translation Management

```vue
<!-- Admin panel for translation oversight -->
<template>
  <div class="translation-management">
    <h2>Translation Status</h2>

    <DataTable :value="recipes" filterDisplay="row">
      <Column field="name" header="Recipe" sortable></Column>
      <Column field="language" header="Original Language"></Column>
      <Column header="Translation Status">
        <template #body="slotProps">
          <ProgressBar
            :value="getTranslationProgress(slotProps.data)"
            :showValue="true"
          />
        </template>
      </Column>
      <Column header="Actions">
        <template #body="slotProps">
          <Button
            icon="pi pi-refresh"
            label="Regenerate"
            @click="regenerateTranslations(slotProps.data.id)"
            class="p-button-sm"
          />
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<script setup>
const getTranslationProgress = (recipe) => {
  if (!recipe.translations_completed) return 0

  const expected = 6 // 6 target languages
  const actual = Object.keys(recipe.translations || {}).length

  return (actual / expected) * 100
}

const regenerateTranslations = async (recipeId) => {
  await api.post(`/admin/recipes/${recipeId}/regenerate_translations`)
  // Refresh table
}
</script>
```

### Key Implementation Notes

1. **Pre-translation Strategy:**
   - Translations happen in background job after recipe save
   - No real-time translation delay for users
   - All translations stored in single JSONB field

2. **Language Detection:**
   - Browser language detection on first visit
   - Stored in localStorage for persistence
   - User can manually switch anytime

3. **Ingredient Cultural Awareness:**
   - AI prompts preserve ingredient authenticity
   - "negi" stays as "ネギ" in Japanese (native term)
   - "negi (일본식 파)" in Korean (transliteration + explanation)

4. **API Design:**
   - Single endpoint with `?lang=` parameter
   - Falls back to original language if translation unavailable
   - Returns complete recipe structure in requested language

5. **Translation Completeness:**
   - `translations_completed` flag tracks status
   - Admin can regenerate if translations fail
   - Progress indicator shows completion percentage

---

## Nutrition System

**Chosen Strategy:** Hybrid Approach (Progressive Self-Built Database + Nutritionix API Fallback)

**Based on:** [nutrition-data-strategy.md](technical-designs/nutrition-data-strategy.md)

### Overview

Start with Nutritionix API for immediate accuracy, cache all results, and progressively build proprietary database.

**Key Benefits:**
- **Year 1 Cost:** $840 (Nutritionix Basic + Database hosting)
- **Year 2+ Cost:** $636/year (95% database hit rate)
- **Savings vs Pure API:** $5,364/year
- **Performance:** <50ms average (database <10ms, API fallback 200-500ms)

### Database Schema (Already Created)

```ruby
# db/migrate/005_create_ingredients.rb
create_table :ingredients, id: :uuid do |t|
  t.string :canonical_name, null: false
  t.string :category # 'vegetable', 'protein', 'grain', 'spice', 'dairy'
  t.timestamps
end

# db/migrate/006_create_ingredient_nutrition.rb
create_table :ingredient_nutrition, id: :uuid do |t|
  t.uuid :ingredient_id, null: false

  # Per 100g values
  t.decimal :calories, precision: 8, scale: 2
  t.decimal :protein_g, precision: 6, scale: 2
  t.decimal :carbs_g, precision: 6, scale: 2
  t.decimal :fat_g, precision: 6, scale: 2
  t.decimal :fiber_g, precision: 6, scale: 2

  # Metadata
  t.string :data_source # 'nutritionix', 'usda', 'ai'
  t.decimal :confidence_score, precision: 3, scale: 2 # 0.0-1.0

  t.timestamps
end

# db/migrate/007_create_ingredient_aliases.rb
create_table :ingredient_aliases, id: :uuid do |t|
  t.uuid :ingredient_id, null: false
  t.string :alias, null: false
  t.string :language # 'en', 'ja', 'ko', etc.
  t.string :alias_type # 'synonym', 'translation', 'misspelling'
  t.timestamps
end
```

### Nutrition Lookup Service

```ruby
# app/services/nutrition_lookup_service.rb
class NutritionLookupService
  def initialize
    @nutritionix_client = NutritionixClient.new
  end

  def lookup_ingredient(ingredient_name, language = 'en')
    # 1. Check database first
    ingredient = find_in_database(ingredient_name, language)
    return ingredient.nutrition if ingredient&.nutrition

    # 2. Fallback to Nutritionix API
    nutrition_data = fetch_from_nutritionix(ingredient_name)

    # 3. Store in database for future use
    if nutrition_data
      ingredient = store_ingredient(ingredient_name, nutrition_data, language, 'nutritionix')
      nutrition_data
    else
      # 4. Last resort: AI estimation (for obscure ingredients)
      ai_nutrition_data = estimate_with_ai(ingredient_name)
      store_ingredient(ingredient_name, ai_nutrition_data, language, 'ai', confidence: 0.7)
      ai_nutrition_data
    end
  end

  private

  def find_in_database(name, language)
    # Normalize input
    normalized = normalize_ingredient_name(name)

    # Try exact match first
    ingredient = Ingredient.find_by(canonical_name: normalized)
    return ingredient if ingredient

    # Try fuzzy match via aliases
    alias_match = IngredientAlias
      .where(language: language)
      .where('LOWER(alias) = ?', normalized.downcase)
      .first

    return alias_match.ingredient if alias_match

    # Try Levenshtein fuzzy match
    fuzzy_match_ingredient(normalized, language)
  end

  def fuzzy_match_ingredient(name, language)
    # Get all ingredients and aliases in the same language
    candidates = Ingredient
      .joins(:aliases)
      .where(ingredient_aliases: { language: language })
      .select('ingredients.*, ingredient_aliases.alias')

    # Calculate similarity for each candidate
    best_match = nil
    best_score = 0.0

    candidates.each do |candidate|
      similarity = calculate_similarity(name, candidate.alias)

      if similarity > 0.85 && similarity > best_score
        best_match = candidate
        best_score = similarity
      end
    end

    best_match
  end

  def fetch_from_nutritionix(ingredient_name)
    response = @nutritionix_client.natural_language_search(ingredient_name)

    return nil unless response['foods']&.any?

    food = response['foods'].first

    {
      calories: food['nf_calories'],
      protein_g: food['nf_protein'],
      carbs_g: food['nf_total_carbohydrate'],
      fat_g: food['nf_total_fat'],
      fiber_g: food['nf_dietary_fiber']
    }
  rescue NutritionixClient::Error => e
    Rails.logger.error("Nutritionix API Error: #{e.message}")
    nil
  end

  def estimate_with_ai(ingredient_name)
    # Use Claude API to estimate nutrition
    # This is a FALLBACK for rare ingredients not in Nutritionix
    system_prompt = AiPrompt.active.find_by!(prompt_key: 'nutrition_estimation_system')
    user_prompt = AiPrompt.active.find_by!(prompt_key: 'nutrition_estimation')

    rendered_user_prompt = user_prompt.render(ingredient_name: ingredient_name)

    ai_service = AiService.new
    response = ai_service.call_claude(
      system_prompt: system_prompt.prompt_text,
      user_prompt: rendered_user_prompt,
      max_tokens: 512
    )

    JSON.parse(response)
  rescue JSON::ParserError
    # Fallback defaults
    { calories: 100, protein_g: 2, carbs_g: 15, fat_g: 2, fiber_g: 1 }
  end

  def store_ingredient(name, nutrition_data, language, source, confidence: 1.0)
    normalized = normalize_ingredient_name(name)

    ingredient = Ingredient.find_or_create_by!(canonical_name: normalized) do |i|
      i.category = guess_category(name)
    end

    # Store nutrition data
    ingredient.create_nutrition!(
      calories: nutrition_data[:calories],
      protein_g: nutrition_data[:protein_g],
      carbs_g: nutrition_data[:carbs_g],
      fat_g: nutrition_data[:fat_g],
      fiber_g: nutrition_data[:fiber_g],
      data_source: source,
      confidence_score: confidence
    )

    # Create alias for the input name (if different from canonical)
    unless normalized == name.downcase
      ingredient.aliases.find_or_create_by!(
        alias: name,
        language: language,
        alias_type: 'synonym'
      )
    end

    ingredient
  end

  def normalize_ingredient_name(name)
    name.downcase
        .gsub(/[^\w\s]/, '')  # Remove punctuation
        .gsub(/\s+/, ' ')      # Normalize whitespace
        .strip
        .singularize           # "tomatoes" → "tomato"
  end

  def guess_category(name)
    # Simple heuristic-based categorization
    vegetables = ['carrot', 'tomato', 'onion', 'pepper', 'lettuce']
    proteins = ['chicken', 'beef', 'pork', 'fish', 'tofu', 'egg']
    grains = ['rice', 'wheat', 'oat', 'quinoa', 'pasta']
    dairy = ['milk', 'cheese', 'yogurt', 'cream', 'butter']

    normalized = name.downcase

    return 'vegetable' if vegetables.any? { |v| normalized.include?(v) }
    return 'protein' if proteins.any? { |p| normalized.include?(p) }
    return 'grain' if grains.any? { |g| normalized.include?(g) }
    return 'dairy' if dairy.any? { |d| normalized.include?(d) }

    'other'
  end

  def calculate_similarity(str1, str2)
    # Levenshtein distance ratio
    require 'levenshtein'
    max_len = [str1.length, str2.length].max
    return 1.0 if max_len.zero?

    distance = Levenshtein.distance(str1, str2)
    1.0 - (distance.to_f / max_len)
  end
end
```

### Nutritionix API Client

```ruby
# app/clients/nutritionix_client.rb
class NutritionixClient
  API_BASE_URL = 'https://trackapi.nutritionix.com/v2'

  class Error < StandardError; end

  def initialize
    @app_id = ENV.fetch('NUTRITIONIX_APP_ID')
    @app_key = ENV.fetch('NUTRITIONIX_APP_KEY')
  end

  def natural_language_search(query)
    response = Faraday.post("#{API_BASE_URL}/natural/nutrients") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['x-app-id'] = @app_id
      req.headers['x-app-key'] = @app_key
      req.body = { query: query }.to_json
    end

    if response.success?
      JSON.parse(response.body)
    else
      raise Error, "Nutritionix API returned #{response.status}: #{response.body}"
    end
  end

  def search_item(query)
    response = Faraday.get("#{API_BASE_URL}/search/instant") do |req|
      req.headers['x-app-id'] = @app_id
      req.headers['x-app-key'] = @app_key
      req.params['query'] = query
    end

    if response.success?
      JSON.parse(response.body)
    else
      raise Error, "Nutritionix API returned #{response.status}"
    end
  end
end
```

**Environment Variables:**

```bash
# .env
NUTRITIONIX_APP_ID=your_app_id
NUTRITIONIX_APP_KEY=your_app_key
```

**Nutritionix Setup:**
1. Sign up at https://www.nutritionix.com/business/api
2. Free tier: 15,000 calls/month
3. Basic plan: $39/month for 50,000 calls
4. Get API credentials (App ID + App Key)

### Recipe Nutrition Calculator

```ruby
# app/services/recipe_nutrition_calculator.rb
class RecipeNutritionCalculator
  def initialize(recipe)
    @recipe = recipe
    @lookup_service = NutritionLookupService.new
  end

  def calculate
    total_nutrition = {
      calories: 0,
      protein_g: 0,
      carbs_g: 0,
      fat_g: 0,
      fiber_g: 0
    }

    @recipe.ingredient_groups.each do |group|
      group['items'].each do |ingredient|
        ingredient_nutrition = calculate_ingredient_nutrition(ingredient)

        total_nutrition[:calories] += ingredient_nutrition[:calories]
        total_nutrition[:protein_g] += ingredient_nutrition[:protein_g]
        total_nutrition[:carbs_g] += ingredient_nutrition[:carbs_g]
        total_nutrition[:fat_g] += ingredient_nutrition[:fat_g]
        total_nutrition[:fiber_g] += ingredient_nutrition[:fiber_g]
      end
    end

    # Calculate per serving
    servings = @recipe.servings['original']
    per_serving = {
      calories: (total_nutrition[:calories] / servings).round,
      protein_g: (total_nutrition[:protein_g] / servings).round(1),
      carbs_g: (total_nutrition[:carbs_g] / servings).round(1),
      fat_g: (total_nutrition[:fat_g] / servings).round(1),
      fiber_g: (total_nutrition[:fiber_g] / servings).round(1)
    }

    {
      total: total_nutrition,
      per_serving: per_serving
    }
  end

  private

  def calculate_ingredient_nutrition(ingredient)
    name = ingredient['name']
    amount = ingredient['amount'].to_f
    unit = ingredient['unit']

    # Lookup nutrition data (database → API → AI)
    nutrition_per_100g = @lookup_service.lookup_ingredient(name, @recipe.language)

    # Convert ingredient amount to grams
    grams = convert_to_grams(amount, unit, name)

    # Calculate nutrition for this specific amount
    {
      calories: (nutrition_per_100g[:calories] * grams / 100).round(1),
      protein_g: (nutrition_per_100g[:protein_g] * grams / 100).round(1),
      carbs_g: (nutrition_per_100g[:carbs_g] * grams / 100).round(1),
      fat_g: (nutrition_per_100g[:fat_g] * grams / 100).round(1),
      fiber_g: (nutrition_per_100g[:fiber_g] * grams / 100).round(1)
    }
  end

  def convert_to_grams(amount, unit, ingredient_name)
    # Use UnitConverter for volume → weight conversions
    # Some ingredients need specific density conversions
    case unit
    when 'g', 'gram', 'grams'
      amount
    when 'kg', 'kilogram', 'kilograms'
      amount * 1000
    when 'oz', 'ounce', 'ounces'
      amount * 28.35
    when 'lb', 'pound', 'pounds'
      amount * 453.592
    when 'cup', 'cups'
      estimate_grams_from_volume(ingredient_name, amount, 'cup')
    when 'tbsp', 'tablespoon', 'tablespoons'
      estimate_grams_from_volume(ingredient_name, amount, 'tbsp')
    when 'tsp', 'teaspoon', 'teaspoons'
      estimate_grams_from_volume(ingredient_name, amount, 'tsp')
    when 'whole', 'piece', 'pieces'
      estimate_grams_from_count(ingredient_name, amount)
    else
      # Default assumption
      amount
    end
  end

  def estimate_grams_from_volume(ingredient_name, amount, unit)
    # Common ingredient densities
    densities = {
      'flour' => { 'cup' => 120, 'tbsp' => 8, 'tsp' => 2.5 },
      'sugar' => { 'cup' => 200, 'tbsp' => 12.5, 'tsp' => 4 },
      'water' => { 'cup' => 240, 'tbsp' => 15, 'tsp' => 5 },
      'oil' => { 'cup' => 220, 'tbsp' => 14, 'tsp' => 4.5 },
      'butter' => { 'cup' => 227, 'tbsp' => 14, 'tsp' => 4.7 },
      'rice' => { 'cup' => 185, 'tbsp' => 12, 'tsp' => 4 }
    }

    # Find matching density
    density_key = densities.keys.find { |key| ingredient_name.downcase.include?(key) }

    if density_key && densities[density_key][unit]
      amount * densities[density_key][unit]
    else
      # Default to water density
      amount * densities['water'][unit]
    end
  end

  def estimate_grams_from_count(ingredient_name, count)
    # Common whole item weights
    weights = {
      'egg' => 50,
      'onion' => 150,
      'potato' => 200,
      'carrot' => 60,
      'tomato' => 120,
      'apple' => 180,
      'banana' => 120
    }

    weight_key = weights.keys.find { |key| ingredient_name.downcase.include?(key) }

    if weight_key
      count * weights[weight_key]
    else
      count * 100 # Default assumption
    end
  end
end
```

### Background Job Integration

```ruby
# app/jobs/nutrition_lookup_job.rb
class NutritionLookupJob < ApplicationJob
  queue_as :nutrition

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    calculator = RecipeNutritionCalculator.new(recipe)

    nutrition_data = calculator.calculate

    recipe.update!(
      nutrition: {
        per_serving: nutrition_data[:per_serving],
        total: nutrition_data[:total]
      }
    )
  rescue StandardError => e
    Rails.logger.error("Nutrition calculation failed for recipe #{recipe_id}: #{e.message}")
    # Set default nutrition values
    recipe.update!(
      nutrition: {
        per_serving: { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0, fiber_g: 0 }
      }
    )
  end
end
```

**Trigger nutrition calculation:**

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  after_create :enqueue_nutrition_calculation
  after_update :enqueue_nutrition_calculation, if: :ingredients_changed?

  private

  def enqueue_nutrition_calculation
    NutritionLookupJob.perform_later(id)
  end

  def ingredients_changed?
    saved_change_to_ingredient_groups?
  end
end
```

### Admin Nutrition Database Management

```vue
<!-- Admin panel for nutrition database -->
<template>
  <div class="nutrition-database-manager">
    <div class="stats-panel">
      <Card>
        <template #title>Database Statistics</template>
        <template #content>
          <div class="stat-grid">
            <div class="stat">
              <span class="label">Total Ingredients:</span>
              <span class="value">{{ stats.total_ingredients }}</span>
            </div>
            <div class="stat">
              <span class="label">Coverage Rate:</span>
              <ProgressBar :value="stats.coverage_rate" />
            </div>
            <div class="stat">
              <span class="label">API Calls This Month:</span>
              <span class="value">{{ stats.api_calls }}</span>
            </div>
            <div class="stat">
              <span class="label">Cost Savings:</span>
              <span class="value">${{ stats.cost_savings }}</span>
            </div>
          </div>
        </template>
      </Card>
    </div>

    <DataTable :value="ingredients" filterDisplay="row">
      <Column field="canonical_name" header="Ingredient" sortable></Column>
      <Column field="category" header="Category"></Column>
      <Column field="nutrition.calories" header="Calories (per 100g)"></Column>
      <Column field="nutrition.data_source" header="Source">
        <template #body="slotProps">
          <Tag :severity="getSourceSeverity(slotProps.data.nutrition.data_source)">
            {{ slotProps.data.nutrition.data_source }}
          </Tag>
        </template>
      </Column>
      <Column field="nutrition.confidence_score" header="Confidence">
        <template #body="slotProps">
          {{ (slotProps.data.nutrition.confidence_score * 100).toFixed(0) }}%
        </template>
      </Column>
      <Column header="Actions">
        <template #body="slotProps">
          <Button
            icon="pi pi-pencil"
            class="p-button-sm p-button-text"
            @click="editNutrition(slotProps.data)"
          />
          <Button
            icon="pi pi-refresh"
            class="p-button-sm p-button-text"
            @click="refreshFromAPI(slotProps.data)"
          />
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<script setup>
const getSourceSeverity = (source) => {
  if (source === 'nutritionix') return 'success'
  if (source === 'usda') return 'info'
  if (source === 'ai') return 'warning'
  return 'secondary'
}

const refreshFromAPI = async (ingredient) => {
  await api.post(`/admin/ingredients/${ingredient.id}/refresh_nutrition`)
  // Refresh table
}
</script>
```

### Caching Strategy

```ruby
# config/initializers/redis.rb
REDIS_CLIENT = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
)

# Nutrition cache (separate from Sidekiq)
NUTRITION_CACHE = Redis::Namespace.new('nutrition', redis: REDIS_CLIENT)

# app/services/nutrition_lookup_service.rb (enhanced with cache)
def lookup_ingredient(ingredient_name, language = 'en')
  # 1. Check Redis cache (fastest)
  cache_key = "#{language}:#{normalize_ingredient_name(ingredient_name)}"
  cached = NUTRITION_CACHE.get(cache_key)
  return JSON.parse(cached, symbolize_names: true) if cached

  # 2. Check database
  ingredient = find_in_database(ingredient_name, language)

  if ingredient&.nutrition
    # Cache for 1 week
    NUTRITION_CACHE.setex(cache_key, 1.week.to_i, ingredient.nutrition.to_json)
    return ingredient.nutrition.attributes.symbolize_keys
  end

  # 3. Fetch from API / AI (same as before)
  # ...
end
```

### Key Implementation Notes

1. **Progressive Database Build:**
   - Month 1-3: Rely heavily on Nutritionix API (cache everything)
   - Month 4-6: Database covers 80-95% of lookups
   - Month 7+: API usage drops to <5%, cost savings kick in

2. **Fuzzy Matching:**
   - Levenshtein distance with 85% threshold
   - Handles "tomato" / "tomatoes", "chicken breast" / "chicken"
   - Multi-language alias support

3. **Data Sources Priority:**
   - Database (confidence: 1.0, source: nutritionix/usda)
   - Nutritionix API (confidence: 1.0)
   - AI estimation (confidence: 0.7) - last resort only

4. **Performance:**
   - Redis cache: <1ms
   - Database query: <10ms
   - Nutritionix API: 200-500ms
   - Target: 95% cache/database hit rate = <10ms average

5. **Cost Management:**
   - Free tier: 15K calls/month (covers MVP)
   - Basic plan: $39/month for 50K calls (Month 4-6)
   - Database reduces API usage by 95% after 12 months

---

## Development Setup

### Prerequisites

```bash
# Required versions
ruby 3.2.0
node 18.x or later
postgresql 14+
redis 7+
```

### Initial Rails Setup

```bash
# 1. Create new Rails API project
rails new recipe-app --api --database=postgresql --skip-test

cd recipe-app

# 2. Add required gems
cat >> Gemfile <<'EOF'

# Authentication
gem 'devise'
gem 'devise-jwt'

# Background jobs
gem 'sidekiq'
gem 'redis', '~> 5.0'

# CORS
gem 'rack-cors'

# External APIs
gem 'faraday'
gem 'anthropic', '~> 0.3'

# Utilities
gem 'levenshtein-ffi'

# Development/Test
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
end

group :development do
  gem 'annotate'
end
EOF

bundle install

# 3. Setup database
bin/rails db:create

# 4. Generate Devise user model
rails generate devise:install
rails generate devise User
rails generate migration AddRoleToUsers role:integer

# 5. Create all migrations from Database Schema section
# Copy migration files from technical-specification.md

# 6. Run migrations
bin/rails db:migrate

# 7. Setup environment variables
cat > .env <<'EOF'
# Database
DATABASE_URL=postgresql://localhost/recipe_app_development

# Redis
REDIS_URL=redis://localhost:6379/0

# Anthropic Claude API
ANTHROPIC_API_KEY=sk-ant-your-key-here
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022

# Nutritionix API
NUTRITIONIX_APP_ID=your-app-id
NUTRITIONIX_APP_KEY=your-app-key

# JWT
DEVISE_JWT_SECRET_KEY=your-secret-key-here
EOF

# 8. Create services directory
mkdir -p app/services
mkdir -p app/clients
mkdir -p app/jobs
```

### Vue.js 3 + Volt PrimeVue Setup

```bash
# 1. Create Vue project in frontend directory
npm create vue@latest frontend

# Follow prompts:
# ✔ Project name: frontend
# ✔ Add TypeScript? No
# ✔ Add JSX Support? No
# ✔ Add Vue Router? Yes
# ✔ Add Pinia? Yes
# ✔ Add Vitest? No
# ✔ Add ESLint? Yes

cd frontend

# 2. Install PrimeVue and dependencies
npm install primevue@latest
npm install primeicons
npm install @primevue/themes

# 3. Install additional dependencies
npm install axios
npm install vue-i18n@9

# 4. Configure PrimeVue in main.js
cat > src/main.js <<'EOF'
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import PrimeVue from 'primevue/config'
import ToastService from 'primevue/toastservice'
import Aura from '@primevue/themes/aura'

import App from './App.vue'
import router from './router'

// PrimeVue CSS
import 'primevue/resources/themes/lara-light-blue/theme.css'
import 'primevue/resources/primevue.min.css'
import 'primeicons/primeicons.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(PrimeVue, {
  theme: {
    preset: Aura
  }
})
app.use(ToastService)

app.mount('#app')
EOF

# 5. Setup API client
mkdir -p src/services
cat > src/services/api.js <<'EOF'
import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1',
  headers: {
    'Content-Type': 'application/json'
  }
})

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default api
EOF

# 6. Create .env for frontend
cat > .env <<'EOF'
VITE_API_BASE_URL=http://localhost:3000/api/v1
EOF

# 7. Setup folder structure
mkdir -p src/components/layout
mkdir -p src/components/recipe
mkdir -p src/components/search
mkdir -p src/components/admin
mkdir -p src/stores
mkdir -p src/views
mkdir -p src/views/admin
```

### Database Seeding

```bash
# Create seed file with data references
cat > db/seeds.rb <<'EOF'
# Load dietary tags
DIETARY_TAGS = {
  'vegetarian' => 'Vegetarian',
  'vegan' => 'Vegan',
  'gluten-free' => 'Gluten-Free',
  # ... (copy from dietary-tags.md)
}

DIETARY_TAGS.each do |key, display_name|
  DataReference.find_or_create_by!(
    reference_type: 'dietary_tag',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.active = true
  end
end

# Load dish types
DISH_TYPES = {
  'main-course' => 'Main Course',
  'desserts' => 'Desserts',
  # ... (copy from dish-types.md)
}

DISH_TYPES.each do |key, display_name|
  DataReference.find_or_create_by!(
    reference_type: 'dish_type',
    key: key
  ) do |ref|
    ref.display_name = display_name
  end
end

# Load cuisines
CUISINES = {
  'japanese' => 'Japanese',
  'korean' => 'Korean',
  # ... (copy from cuisines.md)
}

CUISINES.each do |key, display_name|
  DataReference.find_or_create_by!(
    reference_type: 'cuisine',
    key: key
  ) do |ref|
    ref.display_name = display_name
  end
end

# Create admin user
User.create!(
  email: 'admin@recipe.app',
  password: 'password123',
  role: 1 # admin
)

puts "✅ Seeded #{DataReference.count} data references"
puts "✅ Created admin user (admin@recipe.app / password123)"
EOF

# Run seeds
bin/rails db:seed
```

### Running the Application

**Terminal 1 - Rails API Server:**
```bash
cd recipe-app
bin/rails server -p 3000
```

**Terminal 2 - Sidekiq (Background Jobs):**
```bash
cd recipe-app
bundle exec sidekiq
```

**Terminal 3 - Redis:**
```bash
redis-server
```

**Terminal 4 - Vue.js Dev Server:**
```bash
cd frontend
npm run dev
```

### First Steps After Setup

1. **Create your first recipe (via Rails console):**

```bash
bin/rails console

recipe = Recipe.create!(
  name: "Simple Scrambled Eggs",
  language: "en",
  servings: { original: 2, min: 1, max: 4 },
  timing: { prep_minutes: 2, cook_minutes: 5, total_minutes: 7 },
  ingredient_groups: [
    {
      name: "Ingredients",
      items: [
        { id: "ing-001", name: "eggs", amount: 4, unit: "whole" },
        { id: "ing-002", name: "butter", amount: 1, unit: "tbsp" },
        { id: "ing-003", name: "salt", amount: 0.25, unit: "tsp" }
      ]
    }
  ],
  steps: [
    {
      id: "step-001",
      order: 1,
      instructions: {
        original: "Crack eggs into a bowl and whisk until combined."
      }
    },
    {
      id: "step-002",
      order: 2,
      instructions: {
        original: "Heat butter in a non-stick pan over medium heat."
      }
    },
    {
      id: "step-003",
      order: 3,
      instructions: {
        original: "Pour eggs into pan and gently stir until just set."
      }
    }
  ],
  dietary_tags: ["vegetarian", "gluten-free"],
  dish_types: ["main-course"],
  recipe_types: ["quick-weeknight", "breakfast"],
  cuisines: ["american"]
)

# Check background jobs
# Sidekiq should automatically:
# - Generate step variants (easier, no equipment)
# - Translate to 6 languages
# - Calculate nutrition
```

2. **Test API endpoints:**

```bash
# List recipes
curl http://localhost:3000/api/v1/recipes

# Get specific recipe
curl http://localhost:3000/api/v1/recipes/:id

# Scale recipe
curl -X POST http://localhost:3000/api/v1/recipes/:id/scale \
  -H "Content-Type: application/json" \
  -d '{"scale_type":"by_servings","target_servings":4}'
```

3. **Test frontend:**

Visit http://localhost:5173 (Vite dev server)

### Development Workflow

**1. Adding a new feature:**

```bash
# 1. Create feature branch
git checkout -b feature/recipe-favorites

# 2. Generate migration if needed
rails generate migration AddFavoritesCountToRecipes favorites_count:integer

# 3. Update model
# Edit app/models/recipe.rb

# 4. Add API endpoint
# Edit config/routes.rb and app/controllers/api/v1/recipes_controller.rb

# 5. Create Vue component
# Create src/components/recipe/FavoriteButton.vue

# 6. Test manually via browser + Sidekiq dashboard

# 7. Commit
git add .
git commit -m "Add recipe favorites feature"
```

**2. Monitoring background jobs:**

- Sidekiq Dashboard: http://localhost:3000/sidekiq (requires mounting in routes)
- Redis CLI: `redis-cli` → `KEYS *` to see cached data

**3. Debugging:**

```bash
# Rails console
bin/rails console

# Check recipe status
Recipe.last.variants_generated?
Recipe.last.translations_completed?

# Manually trigger jobs
GenerateStepVariantsJob.perform_now(recipe.id)
TranslateRecipeJob.perform_now(recipe.id)

# Check nutrition database
Ingredient.count
IngredientAlias.count
```

### Testing

```bash
# Setup RSpec
rails generate rspec:install

# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/services/recipe_scaler_spec.rb

# Run with coverage (optional)
COVERAGE=true bundle exec rspec
```

### Deployment Preparation

**1. Environment variables for production:**

```bash
# .env.production
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
ANTHROPIC_API_KEY=sk-ant-...
NUTRITIONIX_APP_ID=...
NUTRITIONIX_APP_KEY=...
SECRET_KEY_BASE=...  # Generate with: rails secret
DEVISE_JWT_SECRET_KEY=...  # Generate with: rails secret
```

**2. Build frontend for production:**

```bash
cd frontend
npm run build
# Output goes to frontend/dist/
```

**3. Precompile Rails assets (if serving frontend from Rails):**

```bash
# Copy Vue build to Rails public directory
cp -r frontend/dist/* public/

# Or use separate deployment (recommended)
# - Deploy Rails API to Heroku/Render
# - Deploy Vue frontend to Vercel/Netlify
```

### Recommended Next Steps After Setup

1. ✅ **Verify all background jobs work** - Create a recipe and check Sidekiq dashboard
2. ✅ **Test smart scaling** - Scale a recipe by servings and by ingredient
3. ✅ **Test multi-lingual** - Create a recipe, wait for translations, switch languages in UI
4. ✅ **Test nutrition lookup** - Add ingredients, verify database/API lookup works
5. ✅ **Create admin user** - Test admin panel for data references management
6. ✅ **Test AI recipe discovery** - Use admin panel to search and import a recipe

### Useful Commands Reference

```bash
# Rails
bin/rails routes                    # List all routes
bin/rails db:migrate:status         # Check migration status
bin/rails db:rollback               # Rollback last migration
bin/rails db:reset                  # Drop, create, migrate, seed

# Sidekiq
bundle exec sidekiq                 # Start Sidekiq worker
bundle exec sidekiq -q default -q nutrition  # Specify queues

# Vue.js
npm run dev                         # Start dev server
npm run build                       # Build for production
npm run lint                        # Run ESLint

# Redis
redis-cli                           # Open Redis CLI
redis-cli FLUSHALL                  # Clear all Redis data
redis-cli KEYS 'nutrition:*'        # Find nutrition cache keys

# Database
psql recipe_app_development         # Connect to database
\dt                                 # List tables
\d recipes                          # Describe recipes table
```

---

## Data Reference Documents

The following reference documents in `/docs/data-references/` provide standardized values for the system.

### Data References (Complete)

1. **[dietary-tags.md](data-references/dietary-tags.md)** ✅
   - **Status:** Updated and complete
   - **Contains:** 42 dietary tags (merged Edamam Health Labels + our original list)
   - **Format:** Lowercase with hyphens (e.g., gluten-free, tree-nut-free)
   - **Includes:** Complete seed code, UI labels, AI prompt integration, validation rules

2. **[dish-types.md](data-references/dish-types.md)** ✅
   - **Status:** Newly created
   - **Contains:** 16 Edamam standard dish types
   - **Examples:** main-course, desserts, soup, side-dish, starter
   - **Includes:** Complete seed code, UI labels, examples, relationship to recipe_types

3. **[recipe-types.md](data-references/recipe-types.md)** ✅
   - **Status:** Complete (no changes needed)
   - **Contains:** ~70 tags for cooking methods, proteins, styles
   - **Examples:** baking, stir-fry, chicken, quick-weeknight, slow-cooked
   - **Note:** Separate from dish_types (answers "how cooked?" not "what course?")

4. **[cuisines.md](data-references/cuisines.md)** ✅
   - **Status:** Updated with Edamam compatibility note
   - **Contains:** 100+ cuisines with regional groupings
   - **Coverage:** All 20 Edamam cuisines map to our more granular list
   - **Format:** Lowercase with underscores (e.g., japanese, north_indian, tex_mex)

5. **[units-and-conversions.md](data-references/units-and-conversions.md)** ✅
   - **Status:** Complete
   - **Referenced by:** Smart Scaling System
   - **Contains:** Unit conversion tables, friendly fractions, step-down rules

### AI Prompt References

6. **[generate-step-variants.md](ai-prompts/generate-step-variants.md)** ✅
   - **Contains:** Complete AI prompts for Easier and No Equipment variants
   - **Referenced in:** GenerateStepVariantsJob implementation
   - **Implementation:** Use exact prompts from this file in background job

### Technical Design References

7. **[smart-scaling-system.md](technical-designs/smart-scaling-system.md)** ✅
   - **Contains:** Complete pseudo-code for scaling engine
   - **Implementation:** Use this spec for RecipeScaler service
   - **Covers:** Scale by servings, scale by ingredient, context-aware precision

8. **[nutrition-data-strategy.md](technical-designs/nutrition-data-strategy.md)** ✅
   - **Contains:** API comparison, database schema, implementation roadmap
   - **Approach:** Hybrid (Nutritionix API + progressive database)
   - **Status:** Ingredient tables in schema above match this doc

---


## Smart Scaling Implementation

**Based on:** [smart-scaling-system.md](technical-designs/smart-scaling-system.md)

### Core Service

```ruby
# app/services/recipe_scaler.rb
class RecipeScaler
  FRIENDLY_FRACTIONS = {
    0.125 => '1/8',
    0.25 => '1/4',
    0.33 => '1/3',
    0.5 => '1/2',
    0.66 => '2/3',
    0.75 => '3/4'
  }.freeze

  def initialize(recipe)
    @recipe = recipe
    @context = detect_cooking_context(recipe)
  end

  def scale_by_servings(target_servings)
    scaling_factor = target_servings.to_f / @recipe.servings['original']
    scale_all_ingredients(scaling_factor)
  end

  def scale_by_ingredient(ingredient_id, target_amount, target_unit)
    base_ingredient = find_ingredient_by_id(ingredient_id)
    return nil unless base_ingredient

    # Convert target to same unit as base
    converted_amount = UnitConverter.convert(
      target_amount,
      target_unit,
      base_ingredient['unit']
    )

    scaling_factor = converted_amount / base_ingredient['amount'].to_f
    scale_all_ingredients(scaling_factor)
  end

  private

  def scale_all_ingredients(factor)
    scaled_recipe = @recipe.deep_dup

    scaled_recipe.ingredient_groups.each do |group|
      group['items'].each do |ingredient|
        scale_ingredient!(ingredient, factor)
      end
    end

    scaled_recipe['servings']['scaled'] = (@recipe.servings['original'] * factor).round(1)
    scaled_recipe
  end

  def scale_ingredient!(ingredient, factor)
    raw_amount = ingredient['amount'].to_f * factor

    if @context == 'baking'
      ingredient['amount'] = preserve_precision(raw_amount, ingredient['unit'])
    else
      ingredient['amount'] = round_to_friendly_fraction(raw_amount)
      check_unit_step_down!(ingredient)
    end

    ingredient
  end

  def round_to_friendly_fraction(amount)
    # Try whole number first
    return amount.round if (amount - amount.round).abs < 0.1

    # Try simple fraction
    FRIENDLY_FRACTIONS.each do |decimal, fraction|
      return fraction if (amount - decimal).abs < 0.05
    end

    # Try mixed number (e.g., 1 1/2)
    if amount > 1
      whole_part = amount.floor
      fractional_part = amount - whole_part

      FRIENDLY_FRACTIONS.each do |decimal, fraction|
        if (fractional_part - decimal).abs < 0.05
          return "#{whole_part} #{fraction}"
        end
      end
    end

    # Fallback to 1 decimal place
    amount.round(1)
  end

  def preserve_precision(amount, unit)
    # For baking, convert to grams if needed
    if unit.in?(['cups', 'tbsp', 'tsp']) && amount < 0.25
      # Convert small amounts to grams for precision
      grams = UnitConverter.to_grams(amount, unit)
      return { amount: grams.round(1), unit: 'g' }
    end

    amount.round(2) # Keep 2 decimal places for baking
  end

  def check_unit_step_down!(ingredient)
    amount = ingredient['amount']
    unit = ingredient['unit']

    # Step down tbsp to tsp if amount is small
    if unit == 'tbsp' && amount < 1
      ingredient['amount'] = (amount * 3).round(1)
      ingredient['unit'] = 'tsp'
    end

    # Step down cups to tbsp if amount is small
    if unit == 'cup' && amount < 0.25
      ingredient['amount'] = (amount * 16).round(1)
      ingredient['unit'] = 'tbsp'
    end
  end

  def detect_cooking_context(recipe)
    # Check if recipe requires precision (baking, confectionery, etc.)
    return 'baking' if recipe.requires_precision

    precision_types = ['baking', 'confectionery', 'fermentation', 'molecular']
    recipe.recipe_types.any? { |type| precision_types.include?(type) } ? 'baking' : 'cooking'
  end

  def find_ingredient_by_id(ingredient_id)
    @recipe.ingredient_groups.each do |group|
      ingredient = group['items'].find { |i| i['id'] == ingredient_id }
      return ingredient if ingredient
    end
    nil
  end
end
```

### Unit Converter

```ruby
# app/services/unit_converter.rb
class UnitConverter
  CONVERSIONS = {
    # Volume
    'cup' => { 'tbsp' => 16, 'tsp' => 48, 'ml' => 240 },
    'tbsp' => { 'tsp' => 3, 'ml' => 15 },
    'tsp' => { 'ml' => 5 },
    
    # Weight
    'kg' => { 'g' => 1000 },
    'lb' => { 'oz' => 16, 'g' => 453.592 },
    'oz' => { 'g' => 28.3495 }
  }.freeze

  def self.convert(amount, from_unit, to_unit)
    return amount if from_unit == to_unit

    # Direct conversion
    if CONVERSIONS.dig(from_unit, to_unit)
      return amount * CONVERSIONS[from_unit][to_unit]
    end

    # Reverse conversion
    if CONVERSIONS.dig(to_unit, from_unit)
      return amount / CONVERSIONS[to_unit][from_unit]
    end

    # Multi-hop conversion via common unit
    # (e.g., cup -> ml -> tbsp)
    common_unit = find_common_unit(from_unit, to_unit)
    if common_unit
      intermediate = convert(amount, from_unit, common_unit)
      return convert(intermediate, common_unit, to_unit)
    end

    # No conversion found
    amount
  end

  def self.to_grams(amount, unit)
    convert(amount, unit, 'g')
  end

  private

  def self.find_common_unit(from_unit, to_unit)
    # Find a unit that both can convert to
    from_targets = CONVERSIONS[from_unit]&.keys || []
    to_sources = CONVERSIONS.select { |_, v| v.key?(to_unit) }.keys

    (from_targets & to_sources).first
  end
end
```

### Whole Item Handler

```ruby
# app/services/whole_item_handler.rb
class WholeItemHandler
  WHOLE_ITEMS = ['egg', 'eggs', 'onion', 'onions', 'clove', 'cloves'].freeze

  def self.scale_whole_item(item_name, amount, factor, context)
    return amount * factor unless is_whole_item?(item_name)

    scaled = amount * factor

    if context == 'baking' && scaled < 1
      # In baking, convert to grams
      { amount: (scaled * egg_weight_grams).round(1), unit: 'g', note: 'beaten egg' }
    elsif scaled < 0.3
      # Very small amounts
      { amount: 0, unit: 'whole', note: 'omit' }
    else
      # Round to nearest 0.5
      { amount: (scaled * 2).round / 2.0, unit: 'whole' }
    end
  end

  def self.is_whole_item?(name)
    WHOLE_ITEMS.any? { |item| name.downcase.include?(item) }
  end

  private

  def self.egg_weight_grams
    50 # Average large egg
  end
end
```

### Controller Integration

```ruby
# app/controllers/api/v1/recipes_controller.rb
class Api::V1::RecipesController < ApplicationController
  def scale
    recipe = Recipe.find(params[:id])
    scaler = RecipeScaler.new(recipe)

    scaled_recipe = if params[:scale_type] == 'by_servings'
      scaler.scale_by_servings(params[:target_servings])
    elsif params[:scale_type] == 'by_ingredient'
      scaler.scale_by_ingredient(
        params[:ingredient_id],
        params[:target_amount],
        params[:target_unit]
      )
    end

    render json: { scaled_recipe: scaled_recipe }
  end
end
```

### Frontend Integration

```javascript
// services/scalingService.js
export const scaleRecipe = async (recipeId, scaleParams) => {
  const response = await api.post(`/api/v1/recipes/${recipeId}/scale`, scaleParams)
  return response.data.scaled_recipe
}

// Example usage in component
const handleScaleByServings = async (targetServings) => {
  const scaled = await scaleRecipe(recipe.id, {
    scale_type: 'by_servings',
    target_servings: targetServings
  })
  currentRecipe.value = scaled
}

const handleScaleByIngredient = async (ingredientId, amount, unit) => {
  const scaled = await scaleRecipe(recipe.id, {
    scale_type: 'by_ingredient',
    ingredient_id: ingredientId,
    target_amount: amount,
    target_unit: unit
  })
  currentRecipe.value = scaled
}
```

---
