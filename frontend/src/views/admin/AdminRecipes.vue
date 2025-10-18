<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import PageHeader from '@/components/shared/PageHeader.vue'
import EmptyState from '@/components/shared/EmptyState.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail, PaginationMeta } from '@/services/types'

const router = useRouter()

const recipes = ref<RecipeDetail[]>([])
const pagination = ref<PaginationMeta | null>(null)
const loading = ref(true)
const error = ref<Error | null>(null)

const currentPage = ref(1)
const perPage = ref(20)

// Filter states
const searchQuery = ref('')
const selectedCuisines = ref<string[]>([])
const selectedDishTypes = ref<string[]>([])
const maxPrepTime = ref<number | null>(null)

// Available filter options
const availableCuisines = ref<string[]>([])
const availableDishTypes = ref<string[]>([])

const hasRecipes = computed(() => recipes.value.length > 0)
const hasActiveFilters = computed(() =>
  searchQuery.value !== '' ||
  selectedCuisines.value.length > 0 ||
  selectedDishTypes.value.length > 0 ||
  maxPrepTime.value !== null
)

async function fetchRecipes() {
  loading.value = true
  error.value = null

  try {
    const params: any = {
      page: currentPage.value,
      per_page: perPage.value
    }

    // Add filters if they're set
    if (searchQuery.value) {
      params.q = searchQuery.value
    }
    if (selectedCuisines.value.length > 0) {
      params.cuisines = selectedCuisines.value
    }
    if (selectedDishTypes.value.length > 0) {
      params.dish_types = selectedDishTypes.value
    }
    if (maxPrepTime.value !== null) {
      params.max_prep_time = maxPrepTime.value
    }

    const response = await adminApi.getRecipes(params)

    if (response.success && response.data) {
      recipes.value = response.data.recipes
      pagination.value = response.data.pagination
    }
  } catch (e) {
    console.error('Fetch error:', e)
    error.value = e instanceof Error ? e : new Error('Failed to fetch recipes')
  } finally {
    loading.value = false
  }
}

async function fetchFilterOptions() {
  try {
    const response = await adminApi.getDataReferences()
    if (response.success && response.data) {
      // Extract unique cuisines and dish types
      const dataRefs = response.data.data_references
      availableCuisines.value = dataRefs
        .filter((ref: any) => ref.reference_type === 'cuisine' && ref.active)
        .map((ref: any) => ref.key)
        .sort()

      availableDishTypes.value = dataRefs
        .filter((ref: any) => ref.reference_type === 'dish_type' && ref.active)
        .map((ref: any) => ref.key)
        .sort()
    }
  } catch (e) {
    console.error('Failed to fetch filter options:', e)
  }
}

function applyFilters() {
  currentPage.value = 1 // Reset to first page when filters change
  fetchRecipes()
}

function clearFilters() {
  searchQuery.value = ''
  selectedCuisines.value = []
  selectedDishTypes.value = []
  maxPrepTime.value = null
  applyFilters()
}

function viewRecipe(id: string | number) {
  router.push(`/admin/recipes/${id}`)
}

function createRecipe() {
  router.push('/admin/recipes/new')
}

onMounted(() => {
  fetchFilterOptions()
  fetchRecipes()
})
</script>

<template>
  <div class="admin-recipes">
    <PageHeader
      :title="$t('admin.recipes.title')"
      :subtitle="$t('admin.recipes.subtitle')"
    >
      <template #actions>
        <button class="btn btn-primary" @click="createRecipe">
          <i class="pi pi-plus"></i>
          {{ $t('common.buttons.createRecipe') }}
        </button>
      </template>
    </PageHeader>

    <!-- Filter Bar -->
    <div class="filter-bar">
      <div class="filter-search">
        <i class="pi pi-search"></i>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search recipes..."
          class="search-input"
          @keyup.enter="applyFilters"
        />
      </div>

      <div class="filter-group">
        <label>Cuisines:</label>
        <select v-model="selectedCuisines" multiple class="filter-select">
          <option v-for="cuisine in availableCuisines" :key="cuisine" :value="cuisine">
            {{ cuisine }}
          </option>
        </select>
      </div>

      <div class="filter-group">
        <label>Dish Types:</label>
        <select v-model="selectedDishTypes" multiple class="filter-select">
          <option v-for="type in availableDishTypes" :key="type" :value="type">
            {{ type }}
          </option>
        </select>
      </div>

      <div class="filter-group">
        <label>Max Prep Time:</label>
        <select v-model="maxPrepTime" class="filter-select">
          <option :value="null">Any</option>
          <option :value="15">15 min</option>
          <option :value="30">30 min</option>
          <option :value="45">45 min</option>
          <option :value="60">1 hour</option>
          <option :value="120">2 hours</option>
        </select>
      </div>

      <div class="filter-actions">
        <button class="btn btn-primary btn-sm" @click="applyFilters">
          <i class="pi pi-filter"></i>
          Apply
        </button>
        <button v-if="hasActiveFilters" class="btn btn-outline btn-sm" @click="clearFilters">
          <i class="pi pi-times"></i>
          Clear
        </button>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="loading-state">
      <i class="pi pi-spinner pi-spin"></i>
      <p>{{ $t('common.messages.loading') }}</p>
    </div>

    <!-- Error state -->
    <ErrorMessage v-else-if="error" :error="error" />

    <!-- Empty state -->
    <EmptyState
      v-else-if="!hasRecipes"
      icon="book"
      :title="$t('admin.recipes.noRecipes')"
      :description="$t('admin.recipes.noRecipesDescription')"
    >
      <template #actions>
        <button class="btn btn-primary" @click="createRecipe">
          {{ $t('common.buttons.createRecipe') }}
        </button>
      </template>
    </EmptyState>

    <!-- Recipe list -->
    <div v-else class="recipe-list">
      <div class="recipe-table">
        <table>
          <thead>
            <tr>
              <th>{{ $t('admin.recipes.table.name') }}</th>
              <th>{{ $t('admin.recipes.table.language') }}</th>
              <th>{{ $t('admin.recipes.table.cuisines') }}</th>
              <th>{{ $t('admin.recipes.table.dishTypes') }}</th>
              <th>{{ $t('admin.recipes.table.servings') }}</th>
              <th>{{ $t('admin.recipes.table.timing') }}</th>
              <th>{{ $t('common.labels.actions') }}</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="recipe in recipes"
              :key="recipe.id"
              @click="viewRecipe(recipe.id)"
              class="recipe-row"
            >
              <td class="recipe-name">{{ (recipe as any).name || recipe.title }}</td>
              <td>
                <span class="badge badge-secondary">{{ ((recipe as any).language || recipe.base_language)?.toUpperCase() }}</span>
              </td>
              <td>
                <div class="tags">
                  <span
                    v-for="cuisine in recipe.cuisines?.slice(0, 2)"
                    :key="cuisine"
                    class="tag"
                  >
                    {{ cuisine }}
                  </span>
                  <span v-if="recipe.cuisines && recipe.cuisines.length > 2" class="tag-more">
                    +{{ recipe.cuisines.length - 2 }}
                  </span>
                </div>
              </td>
              <td>
                <div class="tags">
                  <span
                    v-for="type in recipe.dish_types?.slice(0, 2)"
                    :key="type"
                    class="tag"
                  >
                    {{ type }}
                  </span>
                  <span v-if="recipe.dish_types && recipe.dish_types.length > 2" class="tag-more">
                    +{{ recipe.dish_types.length - 2 }}
                  </span>
                </div>
              </td>
              <td>{{ (recipe as any).servings?.original || recipe.servings || '-' }}</td>
              <td>
                <span v-if="(recipe as any).timing?.total_minutes || recipe.total_time_minutes">
                  {{ (recipe as any).timing?.total_minutes || recipe.total_time_minutes }} {{ $t('admin.recipes.table.minutes') }}
                </span>
                <span v-else>-</span>
              </td>
              <td class="actions">
                <button
                  class="btn-icon"
                  @click.stop="viewRecipe(recipe.id)"
                  :title="$t('common.buttons.edit')"
                >
                  <i class="pi pi-pencil"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="pagination && pagination.total_pages > 1" class="pagination">
        <button
          class="btn btn-outline btn-sm"
          :disabled="currentPage === 1"
          @click="currentPage--; fetchRecipes()"
        >
          {{ $t('common.buttons.previous') }}
        </button>

        <span class="pagination-info">
          {{ $t('admin.recipes.pagination.page') }} {{ pagination.current_page }} {{ $t('admin.recipes.pagination.of') }} {{ pagination.total_pages }}
        </span>

        <button
          class="btn btn-outline btn-sm"
          :disabled="currentPage === pagination.total_pages"
          @click="currentPage++; fetchRecipes()"
        >
          {{ $t('common.buttons.next') }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-recipes {
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

.recipe-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.recipe-table {
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: var(--color-background-secondary);
  border-bottom: 2px solid var(--color-border);
}

th {
  padding: var(--spacing-md);
  text-align: left;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  font-size: var(--font-size-sm);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

tbody tr {
  border-bottom: 1px solid var(--color-border);
  transition: background-color 0.2s;
}

tbody tr:hover {
  background: var(--color-background-hover);
  cursor: pointer;
}

tbody tr:last-child {
  border-bottom: none;
}

td {
  padding: var(--spacing-md);
  color: var(--color-text);
}

.recipe-name {
  font-weight: var(--font-weight-medium);
  color: var(--color-primary);
}

.badge {
  display: inline-block;
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-semibold);
}

.badge-secondary {
  background: var(--color-background-secondary);
  color: var(--color-text);
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

.tag-more {
  display: inline-block;
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
  font-weight: var(--font-weight-medium);
}

.actions {
  text-align: right;
}

.btn-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  padding: 0;
  background: transparent;
  border: none;
  color: var(--color-text-muted);
  cursor: pointer;
  border-radius: var(--border-radius-sm);
  transition: var(--transition-base);
}

.btn-icon:hover {
  background: var(--color-background-secondary);
  color: var(--color-primary);
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md);
}

.pagination-info {
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-md);
  padding: var(--spacing-lg);
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  margin-bottom: var(--spacing-lg);
  align-items: flex-end;
}

.filter-search {
  position: relative;
  flex: 1;
  min-width: 250px;
}

.filter-search i {
  position: absolute;
  left: var(--spacing-sm);
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}

.search-input {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md) var(--spacing-sm) var(--spacing-xl);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-sm);
  background: var(--color-background);
  color: var(--color-text);
  font-size: var(--font-size-sm);
  transition: var(--transition-base);
}

.search-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(var(--color-primary-rgb), 0.1);
}

.search-input::placeholder {
  color: var(--color-text-muted);
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xs);
  min-width: 150px;
}

.filter-group label {
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.filter-select {
  padding: var(--spacing-sm) var(--spacing-md);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-sm);
  background: var(--color-background);
  color: var(--color-text);
  font-size: var(--font-size-sm);
  cursor: pointer;
  transition: var(--transition-base);
}

.filter-select[multiple] {
  height: 80px;
}

.filter-select:hover {
  border-color: var(--color-primary);
}

.filter-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(var(--color-primary-rgb), 0.1);
}

.filter-actions {
  display: flex;
  gap: var(--spacing-sm);
  align-items: flex-end;
}

.filter-actions button {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}
</style>
