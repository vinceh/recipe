<script setup lang="ts">
import { computed } from 'vue'
import type { RecipeDetail } from '@/services/types'

interface Props {
  recipe: Partial<RecipeDetail>
}

const props = defineProps<Props>()

const hasBasicInfo = computed(() => {
  return props.recipe.name ||
         props.recipe.servings?.original ||
         props.recipe.timing?.prep_minutes ||
         props.recipe.timing?.cook_minutes ||
         props.recipe.timing?.total_minutes ||
         props.recipe.aliases?.length ||
         props.recipe.source_url ||
         props.recipe.recipe_types?.length ||
         props.recipe.cuisines?.length ||
         props.recipe.dietary_tags?.length ||
         props.recipe.dish_types?.length
})

const hasIngredients = computed(() => {
  return props.recipe.ingredient_groups?.some(g => g.items?.some(i => i && i.name))
})

const hasEquipment = computed(() => {
  return props.recipe.equipment?.length
})

const hasSteps = computed(() => {
  return props.recipe.steps?.some(s => s.instruction?.trim().length > 0)
})

const formattedServings = computed(() => {
  if (!props.recipe.servings) return null
  if (typeof props.recipe.servings === 'object') {
    const s = props.recipe.servings as any
    if (s.min && s.max && s.min !== s.max) {
      return `${s.min}-${s.max}`
    }
    return s.original || s.min || s.max
  }
  return props.recipe.servings
})

const formattedTiming = computed(() => {
  if (!props.recipe.timing) return null
  const timing = props.recipe.timing as any
  return {
    prep: timing.prep_minutes,
    cook: timing.cook_minutes,
    total: timing.total_minutes
  }
})

function formatIngredient(item: any): string {
  const parts = []
  if (item.amount) parts.push(item.amount)
  if (item.unit) parts.push(item.unit)
  if (item.name) parts.push(item.name)
  let result = parts.join(' ')
  if (item.preparation) result += ` (${item.preparation})`
  if (item.optional) result += ' (optional)'
  return result
}
</script>

<template>
  <div class="view-recipe">
    <div class="recipe-content">
      <!-- Basic Information / Header -->
      <div v-if="hasBasicInfo" class="recipe-header">
        <h1 class="recipe-title">{{ recipe.name || $t('recipe.view.defaultTitle') }}</h1>

        <div v-if="recipe.aliases && recipe.aliases.length" class="recipe-aliases">
          <span v-for="alias in recipe.aliases" :key="alias" class="alias">{{ alias }}</span>
        </div>

        <div class="recipe-meta">
          <div v-if="formattedServings" class="meta-item">
            <i class="pi pi-users"></i>
            <span>{{ formattedServings }} {{ $t('recipe.view.servings') }}</span>
          </div>
          <div v-if="formattedTiming?.prep" class="meta-item">
            <i class="pi pi-clock"></i>
            <span>{{ $t('recipe.view.prep') }}: {{ formattedTiming.prep }}m</span>
          </div>
          <div v-if="formattedTiming?.cook" class="meta-item">
            <i class="pi pi-clock"></i>
            <span>{{ $t('recipe.view.cook') }}: {{ formattedTiming.cook }}m</span>
          </div>
          <div v-if="formattedTiming?.total" class="meta-item">
            <i class="pi pi-clock"></i>
            <span>{{ $t('recipe.view.total') }}: {{ formattedTiming.total }}m</span>
          </div>
        </div>

        <div v-if="recipe.cuisines?.length || recipe.dietary_tags?.length || recipe.dish_types?.length || recipe.recipe_types?.length" class="recipe-tags">
          <span v-for="cuisine in recipe.cuisines" :key="cuisine" class="tag tag-cuisine">{{ cuisine }}</span>
          <span v-for="tag in recipe.dietary_tags" :key="tag" class="tag tag-dietary">{{ tag }}</span>
          <span v-for="type in recipe.dish_types" :key="type" class="tag tag-dish">{{ type }}</span>
          <span v-for="rtype in recipe.recipe_types" :key="rtype" class="tag tag-recipe-type">{{ rtype }}</span>
        </div>

        <div v-if="recipe.source_url" class="recipe-source">
          <i class="pi pi-link"></i>
          <a :href="recipe.source_url" target="_blank" rel="noopener noreferrer">{{ recipe.source_url }}</a>
        </div>
      </div>
      <div v-else class="section-placeholder">
        <span>{{ $t('forms.recipe.sections.basicInfo') }}</span>
      </div>

      <!-- Equipment -->
      <div v-if="hasEquipment" class="recipe-section">
        <h2>{{ $t('recipe.view.equipment') }}</h2>
        <ul class="equipment-list">
          <li v-for="item in recipe.equipment" :key="item" class="equipment-item">{{ item }}</li>
        </ul>
      </div>
      <div v-else class="section-placeholder">
        <span>{{ $t('forms.recipe.sections.equipment') }}</span>
      </div>

      <!-- Ingredients -->
      <div v-if="hasIngredients" class="recipe-section">
        <h2>{{ $t('recipe.view.ingredients') }}</h2>
        <div v-for="(group, index) in recipe.ingredient_groups" :key="index" class="ingredient-group">
          <h3 v-if="group.name">{{ group.name }}</h3>
          <ul class="ingredient-list">
            <template v-for="(item, idx) in group.items" :key="idx">
              <li v-if="item && item.name">
                {{ formatIngredient(item) }}
              </li>
            </template>
          </ul>
        </div>
      </div>
      <div v-else class="section-placeholder">
        <span>{{ $t('forms.recipe.sections.ingredients') }}</span>
      </div>

      <!-- Instructions -->
      <div v-if="hasSteps" class="recipe-section">
        <h2>{{ $t('recipe.view.instructions') }}</h2>
        <ol class="steps-list">
          <li v-for="(step, index) in recipe.steps" :key="index">
            {{ step.instruction }}
          </li>
        </ol>
      </div>
      <div v-else class="section-placeholder">
        <span>{{ $t('forms.recipe.sections.steps') }}</span>
      </div>

      <!-- Nutrition -->
      <div v-if="recipe.nutrition?.per_serving" class="recipe-section">
        <h2>{{ $t('recipe.view.nutrition') }}</h2>
        <div class="nutrition-grid">
          <div v-if="recipe.nutrition.per_serving.calories" class="nutrition-item">
            <span class="nutrition-value">{{ recipe.nutrition.per_serving.calories }}</span>
            <span class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.calories') }}</span>
          </div>
          <div v-if="recipe.nutrition.per_serving.protein_g" class="nutrition-item">
            <span class="nutrition-value">{{ recipe.nutrition.per_serving.protein_g }}g</span>
            <span class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.protein') }}</span>
          </div>
          <div v-if="recipe.nutrition.per_serving.carbs_g" class="nutrition-item">
            <span class="nutrition-value">{{ recipe.nutrition.per_serving.carbs_g }}g</span>
            <span class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.carbs') }}</span>
          </div>
          <div v-if="recipe.nutrition.per_serving.fat_g" class="nutrition-item">
            <span class="nutrition-value">{{ recipe.nutrition.per_serving.fat_g }}g</span>
            <span class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.fat') }}</span>
          </div>
        </div>
        <p class="nutrition-note">{{ $t('admin.recipes.detail.nutrition.perServing') }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.view-recipe {
  width: 100%;
  height: 100%;
  overflow-y: auto;
}

.recipe-content {
  padding: var(--spacing-xl);
}

.section-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-2xl);
  margin-bottom: var(--spacing-xl);
  background: var(--color-gray-100);
  border-radius: var(--border-radius-md);
  min-height: 120px;
}

.section-placeholder span {
  font-size: var(--font-size-lg);
  color: var(--color-text-muted);
  opacity: 0.4;
}

.recipe-header {
  margin-bottom: var(--spacing-xl);
  padding-bottom: var(--spacing-xl);
  border-bottom: 2px solid var(--color-border);
}

.recipe-title {
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0 0 var(--spacing-md) 0;
}

.recipe-aliases {
  display: flex;
  gap: var(--spacing-xs);
  margin-bottom: var(--spacing-md);
  flex-wrap: wrap;
}

.alias {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  font-style: italic;
}

.alias::before {
  content: '"';
}

.alias::after {
  content: '"';
}

.recipe-source {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  margin-top: var(--spacing-md);
  font-size: var(--font-size-sm);
}

.recipe-source i {
  color: var(--color-primary);
}

.recipe-source a {
  color: var(--color-primary);
  text-decoration: none;
  word-break: break-all;
}

.recipe-source a:hover {
  text-decoration: underline;
}

.recipe-meta {
  display: flex;
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-md);
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-text-secondary);
  font-size: var(--font-size-sm);
}

.meta-item i {
  color: var(--color-primary);
}

.recipe-tags {
  display: flex;
  gap: var(--spacing-xs);
  flex-wrap: wrap;
}

.tag {
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
}

.tag-cuisine {
  background: var(--color-primary);
  color: white;
}

.tag-dietary {
  background: var(--color-success);
  color: white;
}

.tag-dish {
  background: var(--color-gray-200);
  color: var(--color-text);
}

.tag-recipe-type {
  background: var(--color-warning);
  color: white;
}

.recipe-section {
  margin-bottom: var(--spacing-xl);
  padding-bottom: var(--spacing-xl);
  border-bottom: 1px solid var(--color-border);
}

.recipe-section:last-child {
  border-bottom: none;
}

.recipe-section h2 {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin: 0 0 var(--spacing-md) 0;
}

.ingredient-group {
  margin-bottom: var(--spacing-lg);
}

.ingredient-group:last-child {
  margin-bottom: 0;
}

.ingredient-group h3 {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-secondary);
  margin: 0 0 var(--spacing-sm) 0;
}

.ingredient-list,
.equipment-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.ingredient-list li,
.equipment-list li {
  padding: var(--spacing-sm) 0;
  color: var(--color-text);
  line-height: 1.6;
}

.equipment-item {
  text-transform: capitalize;
}

.steps-list {
  list-style: decimal;
  padding-left: var(--spacing-xl);
  margin: 0;
}

.steps-list li {
  padding: var(--spacing-md) 0;
  color: var(--color-text);
  line-height: 1.6;
}

.nutrition-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.nutrition-item {
  text-align: center;
  padding: var(--spacing-md);
  background: var(--color-gray-100);
  border-radius: var(--border-radius-md);
}

.nutrition-value {
  display: block;
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-primary);
  margin-bottom: var(--spacing-xs);
}

.nutrition-label {
  display: block;
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  text-transform: uppercase;
}

.nutrition-note {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  font-style: italic;
  margin: 0;
}
</style>
