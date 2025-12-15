<template>
  <PageLayout class="favorites">
    <template #navbar>
      <MainNavBar
        :show-search="true"
        :search-placeholder="$t('favorites.searchPlaceholder')"
        @search="handleSearch"
      />
    </template>

    <LoadingSpinner v-if="loading" :center="true" />
    <ErrorMessage v-else-if="error" :message="error" severity="error" />

    <div v-else-if="favorites.length === 0" class="empty-state">
      <i class="pi pi-heart empty-state__icon"></i>
      <h2 class="empty-state__title">{{ $t('favorites.empty.title') }}</h2>
      <p class="empty-state__description">{{ $t('favorites.empty.description') }}</p>
      <router-link to="/" class="empty-state__link">
        {{ $t('favorites.empty.browseRecipes') }}
      </router-link>
    </div>

    <div v-else class="featured-section">
      <div class="featured-section__header">
        <h2 class="featured-section__title">{{ $t('favorites.title') }}</h2>
      </div>

      <div v-if="filteredFavorites.length === 0 && searchQuery.trim()" class="no-results">
        <p class="no-results__text">{{ $t('favorites.noSearchResults') }}</p>
      </div>

      <RecipeCardGrid
        v-else
        :recipes="filteredFavorites"
        @recipe-click="goToRecipe"
        @update:favorite="handleFavoriteUpdate"
      />
    </div>
  </PageLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useUserStore } from '@/stores'
import type { Recipe } from '@/services/types'
import PageLayout from '@/components/layout/PageLayout.vue'
import MainNavBar from '@/components/shared/MainNavBar.vue'
import LoadingSpinner from '@/components/shared/LoadingSpinner.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import RecipeCardGrid from '@/components/recipe/RecipeCardGrid.vue'

const router = useRouter()
const { locale } = useI18n()
const userStore = useUserStore()
const { favorites, loading, error } = storeToRefs(userStore)

const searchQuery = ref('')

const filteredFavorites = computed(() => {
  if (!searchQuery.value.trim()) {
    return favorites.value
  }
  const query = searchQuery.value.toLowerCase()
  return favorites.value.filter(recipe => {
    return (
      recipe.name?.toLowerCase().includes(query) ||
      recipe.description?.toLowerCase().includes(query) ||
      recipe.cuisines?.some(c => c.toLowerCase().includes(query)) ||
      recipe.dietary_tags?.some(t => t.toLowerCase().includes(query))
    )
  })
})

function handleSearch(query: string) {
  searchQuery.value = query
}

function goToRecipe(recipe: Recipe) {
  router.push({ name: 'recipe-detail', params: { id: recipe.id } })
}

function handleFavoriteUpdate(recipe: Recipe, isFavorite: boolean) {
  if (!isFavorite) {
    userStore.removeFromFavorites(recipe.id)
  }
}

onMounted(async () => {
  await userStore.fetchFavorites()
})

watch(locale, () => {
  userStore.fetchFavorites()
})
</script>

<style scoped>
/* Empty State */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 40px;
  text-align: center;
}

.empty-state__icon {
  font-size: 48px;
  color: var(--color-provisions-border);
  margin-bottom: 24px;
}

.empty-state__title {
  font-family: var(--font-family-heading);
  font-size: 24px;
  font-weight: 600;
  color: var(--color-provisions-text-dark);
  margin: 0 0 12px 0;
}

.empty-state__description {
  font-size: 16px;
  color: var(--color-provisions-text-muted);
  margin: 0 0 24px 0;
  max-width: 300px;
}

.empty-state__link {
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  color: var(--color-error);
  text-decoration: none;
}

.empty-state__link:hover {
  text-decoration: underline;
}

/* Featured Section */
.featured-section {
  flex: 1;
  padding: 0;
  overflow-y: auto;
}

.featured-section__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 25px 25px;
}

.featured-section__title {
  font-family: var(--font-family-heading);
  font-size: 18px;
  font-weight: 600;
  color: var(--color-provisions-border);
  margin: 0;
  padding: 0;
}

/* No Search Results */
.no-results {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 40px;
  text-align: center;
}

.no-results__text {
  font-family: var(--font-family-heading);
  font-size: 16px;
  color: var(--color-provisions-text-muted);
  margin: 0;
}
</style>
