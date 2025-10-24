<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PageHeader from '@/components/shared/PageHeader.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail } from '@/services/types'
import { formatAmount } from '@/utils/ingredientFormatters'

const route = useRoute()
const router = useRouter()

const recipe = ref<RecipeDetail | null>(null)
const loading = ref(true)
const error = ref<Error | null>(null)
const selectedLanguage = ref<string>('')

const recipeId = computed(() => route.params.id as string)

// Available languages for translation
const availableLanguages = [
  { code: 'en', name: 'English' },
  { code: 'ja', name: '日本語 (Japanese)' },
  { code: 'ko', name: '한국어 (Korean)' },
  { code: 'zh-tw', name: '繁體中文 (Traditional Chinese)' },
  { code: 'zh-cn', name: '简体中文 (Simplified Chinese)' },
  { code: 'es', name: 'Español (Spanish)' },
  { code: 'fr', name: 'Français (French)' }
]

// Get the currently displayed recipe data (translated or original)
const displayedRecipe = computed(() => {
  if (!recipe.value) return null

  // If no language selected or base language selected, return original
  if (!selectedLanguage.value || selectedLanguage.value === (recipe.value as any).language) {
    return recipe.value
  }

  // Check if translation exists
  const translations = (recipe.value as any).translations
  if (translations && translations[selectedLanguage.value]) {
    // Merge translation with original recipe data
    return {
      ...recipe.value,
      name: translations[selectedLanguage.value].name || (recipe.value as any).name,
      ingredient_groups: translations[selectedLanguage.value].ingredient_groups || (recipe.value as any).ingredient_groups,
      steps: translations[selectedLanguage.value].steps || (recipe.value as any).steps
    }
  }

  // No translation available, return original
  return recipe.value
})

async function fetchRecipe() {
  loading.value = true
  error.value = null

  try {
    const response = await adminApi.getRecipe(recipeId.value)

    if (response.success && response.data) {
      recipe.value = response.data.recipe as any
      // Initialize selected language to the recipe's base language
      selectedLanguage.value = (recipe.value as any).language || 'en'
    }
  } catch (e) {
    error.value = e instanceof Error ? e : new Error('Failed to fetch recipe')
  } finally {
    loading.value = false
  }
}

function goBack() {
  router.push('/admin/recipes')
}

function editRecipe() {
  if (!recipe.value) return
  router.push(`/admin/recipes/${recipe.value.id}/edit`)
}

async function deleteRecipe() {
  if (!recipe.value || !confirm('Are you sure you want to delete this recipe?')) {
    return
  }

  try {
    await adminApi.deleteRecipe(recipe.value.id)
    router.push('/admin/recipes')
  } catch (e) {
    error.value = e instanceof Error ? e : new Error('Failed to delete recipe')
  }
}

async function regenerateVariants() {
  if (!recipe.value) return

  try {
    const response = await adminApi.regenerateVariants(recipe.value.id)
    if (response.success) {
      recipe.value = response.data.recipe as any
    }
  } catch (e) {
    error.value = e instanceof Error ? e : new Error('Failed to regenerate variants')
  }
}

async function regenerateTranslations() {
  if (!recipe.value) return

  try {
    const response = await adminApi.regenerateTranslations(recipe.value.id)
    if (response.success) {
      recipe.value = response.data.recipe as any
    }
  } catch (e) {
    error.value = e instanceof Error ? e : new Error('Failed to regenerate translations')
  }
}

onMounted(() => {
  fetchRecipe()
})
</script>

<template>
  <div class="admin-recipe-detail">
    <PageHeader
      :title="(recipe as any)?.name || $t('admin.recipes.detail.title')"
      :subtitle="$t('admin.recipes.detail.subtitle')"
    >
      <template #actions>
        <button class="btn btn-outline btn-sm" @click="goBack">
          <i class="pi pi-arrow-left"></i>
          {{ $t('common.buttons.back') }}
        </button>
        <button class="btn btn-primary btn-sm" @click="editRecipe">
          <i class="pi pi-pencil"></i>
          {{ $t('common.buttons.edit') }}
        </button>
        <button class="btn btn-error btn-sm" @click="deleteRecipe">
          <i class="pi pi-trash"></i>
          {{ $t('common.buttons.delete') }}
        </button>
      </template>
    </PageHeader>

    <!-- Loading state -->
    <div v-if="loading" class="loading-state">
      <i class="pi pi-spinner pi-spin"></i>
      <p>{{ $t('common.messages.loading') }}</p>
    </div>

    <!-- Error state -->
    <ErrorMessage v-else-if="error" :error="error" />

    <!-- Recipe content -->
    <div v-else-if="recipe" class="recipe-content">
      <!-- Language Selector -->
      <div class="language-selector-bar">
        <div class="language-selector-label">
          <i class="pi pi-globe"></i>
          <span>View in:</span>
        </div>
        <select v-model="selectedLanguage" class="language-select">
          <option v-for="lang in availableLanguages" :key="lang.code" :value="lang.code">
            {{ lang.name }}
            <span v-if="lang.code === (recipe as any).language">(Original)</span>
          </option>
        </select>
        <div v-if="selectedLanguage !== (recipe as any).language" class="translation-indicator">
          <i class="pi pi-info-circle"></i>
          <span v-if="(recipe as any).translations?.[selectedLanguage]">Showing translation</span>
          <span v-else class="warning">Translation not available - showing original</span>
        </div>
      </div>
      <!-- Nutrition Card -->
      <div v-if="(recipe as any).nutrition && (recipe as any).nutrition.per_serving" class="card">
        <div class="card-header">
          <h3>{{ $t('admin.recipes.detail.sections.nutrition') }}</h3>
        </div>
        <div class="card-body">
          <div class="nutrition-grid">
            <div class="nutrition-item">
              <div class="nutrition-value">{{ (recipe as any).nutrition.per_serving.calories }}</div>
              <div class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.calories') }}</div>
            </div>
            <div class="nutrition-item">
              <div class="nutrition-value">{{ (recipe as any).nutrition.per_serving.protein_g }}g</div>
              <div class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.protein') }}</div>
            </div>
            <div class="nutrition-item">
              <div class="nutrition-value">{{ (recipe as any).nutrition.per_serving.carbs_g }}g</div>
              <div class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.carbs') }}</div>
            </div>
            <div class="nutrition-item">
              <div class="nutrition-value">{{ (recipe as any).nutrition.per_serving.fat_g }}g</div>
              <div class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.fat') }}</div>
            </div>
            <div class="nutrition-item">
              <div class="nutrition-value">{{ (recipe as any).nutrition.per_serving.fiber_g }}g</div>
              <div class="nutrition-label">{{ $t('admin.recipes.detail.nutrition.fiber') }}</div>
            </div>
          </div>
          <div class="nutrition-note">
            <i class="pi pi-info-circle"></i>
            {{ $t('admin.recipes.detail.nutrition.perServing') }}
          </div>
        </div>
      </div>

      <!-- Basic Info Card -->
      <div class="card">
        <div class="card-header">
          <h3>{{ $t('admin.recipes.detail.sections.basicInfo') }}</h3>
        </div>
        <div class="card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.name') }}</label>
              <p>{{ (displayedRecipe as any).name }}</p>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.language') }}</label>
              <p>{{ recipe.language?.toUpperCase() }}</p>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.servings') }}</label>
              <p>{{ (recipe as any).servings?.original || recipe.servings || '-' }}</p>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.timing') }}</label>
              <p v-if="recipe.timing?.total_minutes">
                {{ recipe.timing.total_minutes }} {{ $t('admin.recipes.table.minutes') }}
              </p>
              <p v-else>-</p>
            </div>
          </div>

          <div class="info-grid">
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.cuisines') }}</label>
              <div class="tags">
                <span
                  v-for="cuisine in recipe.cuisines"
                  :key="cuisine"
                  class="tag"
                >
                  {{ cuisine }}
                </span>
                <span v-if="!recipe.cuisines || recipe.cuisines.length === 0">-</span>
              </div>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.dishTypes') }}</label>
              <div class="tags">
                <span
                  v-for="type in recipe.dish_types"
                  :key="type"
                  class="tag"
                >
                  {{ type }}
                </span>
                <span v-if="!recipe.dish_types || recipe.dish_types.length === 0">-</span>
              </div>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.dietaryTags') }}</label>
              <div class="tags">
                <span
                  v-for="tag in recipe.dietary_tags"
                  :key="tag"
                  class="tag"
                >
                  {{ tag }}
                </span>
                <span v-if="!recipe.dietary_tags || recipe.dietary_tags.length === 0">-</span>
              </div>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.aliases') }}</label>
              <div class="tags">
                <span
                  v-for="alias in (recipe as any).aliases"
                  :key="alias"
                  class="tag"
                >
                  {{ alias }}
                </span>
                <span v-if="!(recipe as any).aliases || (recipe as any).aliases.length === 0">-</span>
              </div>
            </div>
          </div>

          <div class="info-grid">
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.sourceUrl') }}</label>
              <p v-if="(recipe as any).source_url">
                <a :href="(recipe as any).source_url" target="_blank" rel="noopener noreferrer">
                  {{ (recipe as any).source_url }}
                </a>
              </p>
              <p v-else>-</p>
            </div>
            <div class="info-item">
              <label>{{ $t('admin.recipes.detail.fields.requiresPrecision') }}</label>
              <p>{{ (recipe as any).requires_precision ? $t('common.labels.yes') : $t('common.labels.no') }}</p>
            </div>
          </div>

          <div v-if="(recipe as any).admin_notes" class="info-item">
            <label>{{ $t('admin.recipes.detail.fields.adminNotes') }}</label>
            <p>{{ (recipe as any).admin_notes }}</p>
          </div>
        </div>
      </div>

      <!-- Ingredients Card -->
      <div v-if="(displayedRecipe as any).ingredient_groups && (displayedRecipe as any).ingredient_groups.length > 0" class="card">
        <div class="card-header">
          <h3>{{ $t('admin.recipes.detail.sections.ingredients') }}</h3>
        </div>
        <div class="card-body">
          <div
            v-for="(group, index) in (displayedRecipe as any).ingredient_groups"
            :key="index"
            class="ingredient-group"
          >
            <h4 v-if="group.name">{{ group.name }}</h4>
            <ul class="ingredient-list">
              <li v-for="(item, idx) in group.items" :key="idx">
                {{ formatAmount(item.amount, item.unit, item.name) }} {{ item.name }}
                <span v-if="item.preparation" class="preparation">({{ item.preparation }})</span>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Steps Card -->
      <div v-if="(displayedRecipe as any).steps && (displayedRecipe as any).steps.length > 0" class="card">
        <div class="card-header">
          <h3>{{ $t('admin.recipes.detail.sections.steps') }}</h3>
        </div>
        <div class="card-body">
          <ol class="steps-list">
            <li v-for="(step, index) in (displayedRecipe as any).steps" :key="index">
              <div class="step-content">
                <p class="step-instruction">{{ step.instruction }}</p>
                <div v-if="step.equipment && step.equipment.length > 0" class="step-meta">
                  <span class="step-equipment">
                    <i class="pi pi-wrench"></i>
                    {{ step.equipment.join(', ') }}
                  </span>
                </div>
              </div>
            </li>
          </ol>
        </div>
      </div>

      <!-- Equipment Card -->
      <div v-if="(recipe as any).equipment && (recipe as any).equipment.length > 0" class="card">
        <div class="card-header">
          <h3>{{ $t('admin.recipes.detail.sections.equipment') }}</h3>
        </div>
        <div class="card-body">
          <div class="tags">
            <span
              v-for="item in (recipe as any).equipment"
              :key="item"
              class="tag"
            >
              {{ item }}
            </span>
          </div>
        </div>
      </div>

      <!-- Actions Card -->
      <div class="card">
        <div class="card-header">
          <h3>{{ $t('admin.recipes.detail.sections.actions') }}</h3>
        </div>
        <div class="card-body">
          <div class="action-buttons">
            <button class="btn btn-secondary" @click="regenerateVariants">
              <i class="pi pi-refresh"></i>
              {{ $t('admin.recipes.detail.actions.regenerateVariants') }}
            </button>
            <button class="btn btn-secondary" @click="regenerateTranslations">
              <i class="pi pi-refresh"></i>
              {{ $t('admin.recipes.detail.actions.regenerateTranslations') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-recipe-detail {
  width: 100%;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-2xl);
  color: var(--color-text-muted);
  gap: var(--spacing-md);
}

.loading-state i {
  font-size: 2rem;
}

.recipe-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.card {
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  overflow: hidden;
}

.card-header {
  background: var(--color-background-secondary);
  padding: var(--spacing-md) var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
}

.card-header h3 {
  margin: 0;
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.card-body {
  padding: var(--spacing-lg);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.info-grid:last-child {
  margin-bottom: 0;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.info-item label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-item p {
  margin: 0;
  color: var(--color-text);
}

.info-item a {
  color: var(--color-primary);
  text-decoration: none;
}

.info-item a:hover {
  text-decoration: underline;
}

.tags {
  display: flex;
  gap: var(--spacing-xs);
  flex-wrap: wrap;
}

.tag {
  display: inline-block;
  padding: var(--spacing-xs) var(--spacing-sm);
  background: var(--color-background-secondary);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}

.ingredient-group {
  margin-bottom: var(--spacing-lg);
}

.ingredient-group:last-child {
  margin-bottom: 0;
}

.ingredient-group h4 {
  margin: 0 0 var(--spacing-md) 0;
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.ingredient-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.ingredient-list li {
  padding: var(--spacing-sm) 0;
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text);
}

.ingredient-list li:last-child {
  border-bottom: none;
}

.preparation {
  color: var(--color-text-muted);
  font-style: italic;
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

.step-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
}

.step-instruction {
  margin: 0;
}

.step-meta {
  display: flex;
  gap: var(--spacing-md);
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.step-timing,
.step-equipment {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.step-timing i,
.step-equipment i {
  font-size: var(--font-size-xs);
}

.action-buttons {
  display: flex;
  gap: var(--spacing-md);
  flex-wrap: wrap;
}

.nutrition-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-md);
}

.nutrition-item {
  text-align: center;
  padding: var(--spacing-md);
  background: var(--color-background-secondary);
  border-radius: var(--border-radius-md);
}

.nutrition-value {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-primary);
  margin-bottom: var(--spacing-xs);
}

.nutrition-label {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.nutrition-note {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-sm);
  background: var(--color-background-secondary);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.nutrition-note i {
  color: var(--color-primary);
}

.language-selector-bar {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md) var(--spacing-lg);
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  margin-bottom: var(--spacing-lg);
}

.language-selector-label {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.language-selector-label i {
  color: var(--color-primary);
  font-size: var(--font-size-lg);
}

.language-select {
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-sm);
  background: var(--color-background);
  color: var(--color-text);
  font-size: var(--font-size-sm);
  cursor: pointer;
  transition: var(--transition-base);
  min-width: 250px;
}

.language-select:hover {
  border-color: var(--color-primary);
}

.language-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(var(--color-primary-rgb), 0.1);
}

.translation-indicator {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-xs) var(--spacing-md);
  background: var(--color-background-secondary);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  margin-left: auto;
}

.translation-indicator i {
  color: var(--color-primary);
}

.translation-indicator .warning {
  color: var(--color-warning);
}
</style>
