<template>
  <PageLayout class="home">
    <template #navbar>
      <MainNavBar :show-search="true" @search="handleSearch" ref="navbarRef" />
    </template>

    <LoadingSpinner v-if="loading" :center="true" />
    <ErrorMessage v-else-if="error" :message="error" severity="error" />
    <div v-else-if="recipes.length === 0" class="empty-state">
      <p class="empty-state__text">{{ $t('home.noRecipes') }}</p>
    </div>

    <div v-else class="featured-section">
      <div class="featured-section__header">
        <h2 class="featured-section__title">{{ sectionTitle }}</h2>
        <router-link v-if="!isSearching && isAuthenticated" to="/favorites" class="favorites-link">
          <i class="pi pi-heart-fill favorites-link__icon"></i> {{ $t('home.favorites') }}
        </router-link>
      </div>

      <RecipeCardGrid
        :recipes="recipes.slice(0, 14)"
        @recipe-click="goToRecipe"
        @update:favorite="handleFavoriteUpdate"
        @require-login="showLoginModal = true"
      />
    </div>

    <LoginModal
      :show="showLoginModal"
      :initial-mode="loginModalMode"
      :reset-token="resetToken"
      @close="handleLoginModalClose"
    />
  </PageLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from "vue-i18n";
import { useRouter, useRoute } from "vue-router";
import { recipeApi } from "@/services/recipeApi";
import type { Recipe } from "@/services/types";
import { useAuth } from "@/composables/useAuth";
import PageLayout from "@/components/layout/PageLayout.vue";
import MainNavBar from "@/components/shared/MainNavBar.vue";
import LoadingSpinner from "@/components/shared/LoadingSpinner.vue";
import ErrorMessage from "@/components/shared/ErrorMessage.vue";
import LoginModal from "@/components/shared/LoginModal.vue";
import RecipeCardGrid from "@/components/recipe/RecipeCardGrid.vue";

const router = useRouter();
const route = useRoute();
const { t, locale } = useI18n();
const { isAuthenticated } = useAuth();

const recipes = ref<Recipe[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);
const navbarRef = ref<InstanceType<typeof MainNavBar> | null>(null);
const showLoginModal = ref(false);
const loginModalMode = ref<'login' | 'signup' | 'forgot' | 'resetSent' | 'reset'>('login');
const resetToken = ref<string | undefined>(undefined);

const isSearching = computed(() => !!route.query.q);
const sectionTitle = computed(() => {
  if (isSearching.value) {
    return `${t('home.results')} - ${recipes.value.length} ${t('home.recipesCount')}`;
  }
  return t('home.featured');
});

async function loadRecipes() {
  try {
    loading.value = true;
    error.value = null;
    const q = (route.query.q as string) || undefined;
    const response = await recipeApi.getRecipes({
      q,
      per_page: 100,
      lang: locale.value as any,
    });

    if (response.success) {
      recipes.value = response.data.recipes;
    } else {
      error.value = response.message || t("common.messages.error");
    }
  } catch (err) {
    error.value = err instanceof Error ? err.message : t("common.messages.error");
  } finally {
    loading.value = false;
  }
}

function handleSearch(query: string) {
  const searchParams: Record<string, string> = {};
  if (query) {
    searchParams.q = query;
  }
  router.replace({ query: searchParams });
}

function goToRecipe(recipe: Recipe) {
  router.push({ name: 'recipe-detail', params: { id: recipe.id } });
}

function handleFavoriteUpdate(recipe: Recipe, isFavorite: boolean) {
  recipe.favorite = isFavorite;
}

function handleLoginModalClose() {
  showLoginModal.value = false;
  if (resetToken.value) {
    resetToken.value = undefined;
    loginModalMode.value = 'login';
    router.replace({ query: {} });
  }
}

onMounted(() => {
  if (navbarRef.value) {
    navbarRef.value.searchQuery = (route.query.q as string) || '';
  }

  const token = route.query.reset_password_token as string;
  if (token) {
    resetToken.value = token;
    loginModalMode.value = 'reset';
    showLoginModal.value = true;
  }
});

watch(() => route.query.q, (newQuery) => {
  if (navbarRef.value) {
    navbarRef.value.searchQuery = (newQuery as string) || '';
  }
  loadRecipes();
}, { immediate: true });

watch(locale, () => {
  loadRecipes();
});
</script>

<style scoped>
/* Empty State */
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 80px 40px;
}

.empty-state__text {
  font-family: var(--font-family-heading);
  font-size: 18px;
  color: var(--color-provisions-text-muted);
  margin: 0;
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

.favorites-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-family: var(--font-family-heading);
  font-size: 14px;
  font-weight: 600;
  color: var(--color-provisions-border);
  text-decoration: none;
  border: 1px solid var(--color-provisions-border);
  padding: 6px 12px;
  border-radius: 4px;
  transition: background 0.15s, color 0.15s;
}

.favorites-link:hover {
  background: var(--color-provisions-border);
  color: var(--color-provisions-bg);
}

.favorites-link__icon {
  color: var(--color-error);
}
</style>
