<script setup lang="ts">
import { ref, onMounted, computed, watch, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { useUiStore } from '@/stores'
import PageHeader from '@/components/shared/PageHeader.vue'
import EmptyState from '@/components/shared/EmptyState.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail, PaginationMeta } from '@/services/types'

const router = useRouter()
const uiStore = useUiStore()

const recipes = ref<RecipeDetail[]>([])
const pagination = ref<PaginationMeta | null>(null)
const loading = ref(true)
const error = ref<Error | null>(null)
const isComponentMounted = ref(true)

const currentPage = ref(1)
const perPage = ref(20)

// Filter states
const searchQuery = ref('')

const hasRecipes = computed(() => recipes.value.length > 0)

async function fetchRecipes() {
  if (!isComponentMounted.value) return

  loading.value = true
  error.value = null

  try {
    const params: any = {
      page: currentPage.value,
      per_page: perPage.value,
      lang: uiStore.language
    }

    // Add search filter if set
    if (searchQuery.value) {
      params.q = searchQuery.value
    }

    const response = await adminApi.getRecipes(params)

    if (!isComponentMounted.value) return

    if (response.success && response.data) {
      recipes.value = response.data.recipes
      pagination.value = response.data.pagination
    }
  } catch (e) {
    if (!isComponentMounted.value) return
    error.value = e instanceof Error ? e : new Error('Failed to fetch recipes')
  } finally {
    if (isComponentMounted.value) {
      loading.value = false
    }
  }
}

// Debounce search to avoid too many API calls
let searchTimeout: ReturnType<typeof setTimeout> | null = null

function onSearchInput() {
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }

  searchTimeout = setTimeout(() => {
    currentPage.value = 1 // Reset to first page on new search
    fetchRecipes()
  }, 300)
}

function viewRecipe(id: string | number) {
  router.push(`/admin/recipes/${id}`)
}

function createRecipe() {
  router.push('/admin/recipes/new')
}

// Debounce language changes to prevent race conditions from rapid switching
let languageChangeTimeout: ReturnType<typeof setTimeout> | null = null

watch(() => uiStore.language, () => {
  if (languageChangeTimeout) {
    clearTimeout(languageChangeTimeout)
  }

  // Clear any pending search timeout
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }

  languageChangeTimeout = setTimeout(() => {
    currentPage.value = 1 // Reset to first page
    fetchRecipes()
  }, 300)
})

onMounted(() => {
  isComponentMounted.value = true
  fetchRecipes()
})

onBeforeUnmount(() => {
  isComponentMounted.value = false
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }
  if (languageChangeTimeout) {
    clearTimeout(languageChangeTimeout)
  }
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

    <!-- Search Bar -->
    <div class="search-bar">
      <div class="search-container">
        <i class="pi pi-search"></i>
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="$t('admin.recipes.searchPlaceholder')"
          class="search-input"
          @input="onSearchInput"
        />
        <button
          v-if="searchQuery"
          class="clear-search"
          @click="searchQuery = ''; fetchRecipes()"
          :title="$t('common.buttons.clear')"
        >
          <i class="pi pi-times"></i>
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
              <td class="recipe-name">{{ recipe.name }}</td>
              <td>
                <span class="badge badge-secondary">{{ recipe.language?.toUpperCase() }}</span>
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
                <span v-if="recipe.timing?.total_minutes">
                  {{ recipe.timing.total_minutes }} {{ $t('admin.recipes.table.minutes') }}
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

.search-bar {
  margin-bottom: var(--spacing-lg);
}

.search-container {
  position: relative;
  max-width: 600px;
}

.search-container i.pi-search {
  position: absolute;
  left: var(--spacing-md);
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-muted);
  font-size: var(--font-size-base);
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: var(--spacing-md) var(--spacing-3xl) var(--spacing-md) var(--spacing-3xl);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius-md);
  background: var(--color-background);
  color: var(--color-text);
  font-size: var(--font-size-base);
  transition: var(--transition-base);
}

.search-input:hover {
  border-color: var(--color-primary-light);
}

.search-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.search-input::placeholder {
  color: var(--color-text-muted);
}

.clear-search {
  position: absolute;
  right: var(--spacing-md);
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  padding: 0;
  background: transparent;
  border: none;
  color: var(--color-text-muted);
  cursor: pointer;
  border-radius: var(--border-radius-sm);
  transition: var(--transition-base);
}

.clear-search:hover {
  background: var(--color-background-secondary);
  color: var(--color-text);
}

.clear-search i {
  font-size: var(--font-size-sm);
}
</style>
