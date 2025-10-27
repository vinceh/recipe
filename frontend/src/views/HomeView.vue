<template>
  <div class="home">
    <!-- Top Navigation Bar with Search -->
    <nav class="navbar navbar--top">
      <div class="navbar-left">
        <h1 class="navbar__title">Provisions</h1>
      </div>
      <div class="navbar-center">
        <input
          v-model="searchQuery"
          type="text"
          class="navbar__search"
          :placeholder="$t('home.searchPlaceholder')"
          @input="handleSearch"
        />
      </div>
      <div class="navbar-right">
        <LanguageSwitcher />
        <router-link to="/about" class="navbar__link">about</router-link>
        <router-link to="/contact" class="navbar__link">contact</router-link>
      </div>
    </nav>

    <!-- Main Container -->
    <div class="container main-container">
      <!-- Left Sidebar -->
      <div class="sidebar sidebar--left">
      </div>

      <!-- Center Content Area -->
      <div class="content center-content">
        <LoadingSpinner v-if="loading" :center="true" />
        <ErrorMessage v-else-if="error" :message="error" severity="error" />
        <div v-else class="featured-section">
          <h2 class="featured-section__title">Recipes</h2>

          <div class="recipe-grid">
            <div
              v-for="(recipe, idx) in recipes.slice(0, 14)"
              :key="recipe.id"
              class="recipe-item"
            >
              <div class="recipe-item__image">
                <div class="recipe-item__image-placeholder">
                  <i class="pi pi-image"></i>
                </div>
              </div>
              <div class="recipe-item__info">
                <h3 class="recipe-item__title">{{ recipe.name }}</h3>
                <p class="recipe-item__meta">
                  <span v-if="recipe.timing?.total_minutes">{{
                    formatTime(recipe.timing.total_minutes)
                  }}</span>
                  <span v-if="recipe.cuisines?.length">{{ recipe.cuisines[0] }}</span>
                  <span v-if="recipe.servings?.original"
                    >{{ recipe.servings.original }} Servings</span
                  >
                </p>
                <p class="recipe-item__description">{{ getPreviewText(recipe) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Sidebar -->
      <div class="sidebar sidebar--right">
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useI18n } from "vue-i18n";
import { recipeApi } from "@/services/recipeApi";
import type { Recipe } from "@/services/types";
import LanguageSwitcher from "@/components/shared/LanguageSwitcher.vue";
import LoadingSpinner from "@/components/shared/LoadingSpinner.vue";
import ErrorMessage from "@/components/shared/ErrorMessage.vue";

const { t } = useI18n();

const recipes = ref<Recipe[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);
const searchQuery = ref("");

async function loadRecipes() {
  try {
    loading.value = true;
    error.value = null;
    const response = await recipeApi.getRecipes({
      q: searchQuery.value || undefined,
      per_page: 100,
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

function handleSearch() {
  loadRecipes();
}

function formatTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}min`;
  }
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins > 0 ? `${hours}h ${mins}min` : `${hours}h`;
}

function getPreviewText(recipe: Recipe): string {
  return recipe.description || "";
}

onMounted(() => {
  loadRecipes();
});
</script>

<style scoped>

.center-content {
  border-left: 1px solid var(--color-provisions-border);
  border-right: 1px solid var(--color-provisions-border); 
}

.main-container {
  padding: 0;
}

.home {
  min-height: 100vh;
  background: var(--color-provisions-bg);
  display: flex;
  flex-direction: column;
}

/* Top Navbar */
.navbar--top {
  height: 60px;
  background: var(--color-provisions-bg);
  border-bottom: 1px solid var(--color-provisions-border);
  display: flex;
  align-items: center;
  gap: 0;
  position: sticky;
  top: 0;
  z-index: 20;
  flex-shrink: 0;
}

.navbar-left {
  flex: 1;
  padding: 0 var(--spacing-lg);
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.navbar-center {
  flex: 0 0 600px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: stretch;
  border-right: 1px solid var(--color-provisions-border);
  border-left: 1px solid var(--color-provisions-border);
  height: 100%;
}

.navbar-right {
  flex: 1;
  padding: 0 var(--spacing-lg);
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: var(--spacing-lg);
}

/* Container Layout */
.container {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.sidebar {
  flex: 1;
  background: var(--color-provisions-bg);
  display: flex;
  flex-direction: column;
}

.content {
  flex: 0 0 600px;
  background: var(--color-provisions-bg);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
}

/* Navigation Bar */
.navbar {
  height: 60px;
  background: var(--color-provisions-bg);
  border-bottom: 1px solid var(--color-provisions-border);
  display: flex;
  align-items: center;
  flex-shrink: 0;
  position: sticky;
  top: 0;
  z-index: 10;
}

.navbar--left {
  padding: 0 var(--spacing-lg);
  justify-content: flex-end;
}

.navbar--center {
  padding: 0;
  justify-content: stretch;
}


.navbar--right {
  font-size: 20px;
  padding: 0 var(--spacing-lg);
  justify-content: flex-start;
  gap: var(--spacing-lg);
}

.navbar__title {
  font-family: var(--font-family-heading);
  font-size: 20px;
  font-weight: 700;
  margin: 0;
  color: var(--color-provisions-border);
  letter-spacing: -0.5px;
}

.navbar__search {
  width: 100%;
  height: 100%;
  padding: 0 25px;
  border: none;
  background: transparent;
  font-family: var(--font-family-heading);
  font-size: 20px;
  font-weight: 600;
  line-height: 1em;
  color: var(--color-provisions-text-muted);
  outline: none;
}

.language-select {
  background: none !important;
}

.navbar__search:focus {
  outline: none;
}

.navbar__search::placeholder {
  color: var(--color-provisions-placeholder);
}

.navbar__language {
  display: flex;
  align-items: center;
}

.navbar__link {
  font-family: var(--font-family-heading);
  font-weight: 600;
  color: var(--color-provisions-border);
  text-decoration: none;
  cursor: pointer;
  font-size: 16px;
}

/* Featured Section */
.featured-section {
  flex: 1;
  padding: 0;
  overflow-y: auto;
}

.featured-section__title {
  font-family: var(--font-family-heading);
  font-size: 20px;
  font-weight: 600;
  color: var(--color-provisions-border);
  margin: 25px 0 25px 25px;
  padding: 0;
}

.recipe-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0;
  border-top: 1px solid var(--color-provisions-border);
}

/* Recipe Items */
.recipe-item {
  display: flex;
  flex-direction: column;
  border-right: 1px solid var(--color-provisions-border);
  border-bottom: 1px solid var(--color-provisions-border);
}

.recipe-item:nth-child(2n) {
  border-right: none;
}

.recipe-item:nth-child(odd):last-of-type {
  border-right: none;
}

.recipe-item__image {
  width: 100%;
  height: 350px;
  overflow: hidden;
  background: var(--color-provisions-card-bg);
  border-bottom: 1px solid var(--color-provisions-border);
}

.recipe-item__image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
  color: var(--color-provisions-placeholder);
}

.recipe-item__info {
  padding: var(--spacing-lg);
}

.recipe-item__title {
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  margin: 0;
  color: var(--color-provisions-text-dark);
  line-height: 1.3;
}

.recipe-item__meta {
  display: flex;
  gap: 6px;
  font-size: 11px;
  color: var(--color-provisions-border);
  margin: 3px 0 10px 0;
  font-family: var(--font-family-base);
  font-weight: 300;
}

.recipe-item__meta span:not(:last-child)::after {
  content: " · ";
  margin-left: 6px;
}

.recipe-item__description {
  font-size: 12px;
  color: var(--color-provisions-text-dark);
  margin: 0;
  line-height: 1.4;
  font-family: var(--font-family-heading);
  font-weight: normal;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Responsive */
@media (max-width: 1200px) {
  .sidebar {
    display: none;
  }

  .container {
    flex-direction: column;
  }

  .content {
    flex: 1;
  }
}
</style>
