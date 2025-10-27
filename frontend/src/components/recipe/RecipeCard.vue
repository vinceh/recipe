<template>
  <router-link :to="`/recipes/${recipe.id}`" class="recipe-card">
    <div class="recipe-card__image-container">
      <div class="recipe-card__image-placeholder">
        <i class="pi pi-image"></i>
      </div>
    </div>
    <div class="recipe-card__content">
      <h3 class="recipe-card__title">{{ recipe.name }}</h3>

      <p class="recipe-card__meta">
        <span v-if="recipe.timing?.total_minutes" class="recipe-card__meta-item">
          {{ formatTime(recipe.timing.total_minutes) }}
        </span>
        <span v-if="recipe.cuisines?.length" class="recipe-card__meta-item">
          {{ recipe.cuisines[0] }}
        </span>
        <span v-if="recipe.servings?.original" class="recipe-card__meta-item">
          {{ recipe.servings.original }} {{ $t('common.labels.servings') }}
        </span>
      </p>

      <p v-if="recipe.ingredient_groups?.[0]?.items" class="recipe-card__description">
        {{ getPreviewText() }}
      </p>
    </div>
  </router-link>
</template>

<script setup lang="ts">
import type { Recipe } from '@/services/types'
import { useI18n } from 'vue-i18n'

interface Props {
  recipe: Recipe
}

const props = defineProps<Props>()
const { t } = useI18n()

function formatTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}min`
  }
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return mins > 0 ? `${hours}h ${mins}min` : `${hours}h`
}

function getPreviewText(): string {
  return props.recipe.description
}
</script>

<style scoped>
.recipe-card {
  display: flex;
  flex-direction: column;
  height: 100%;
  text-decoration: none;
  color: inherit;
  background: var(--color-background);
}

.recipe-card__image-container {
  width: 100%;
  aspect-ratio: 1;
  overflow: hidden;
  background: var(--color-background-secondary);
  margin-bottom: var(--spacing-md);
}

.recipe-card__image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
  color: #b3b1ac;
}

.recipe-card__content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm);
  flex: 1;
}

.recipe-card__title {
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  margin: 0;
  color: #383630;
  line-height: 1.3;
}

.recipe-card__meta {
  display: flex;
  gap: 6px;
  font-size: 11px;
  color: #383630;
  margin: 0;
  font-family: var(--font-family-base);
  font-weight: 300;
}

.recipe-card__meta-item {
  display: inline;
}

.recipe-card__meta-item:not(:last-child)::after {
  content: ' · ';
  margin-left: 6px;
}

.recipe-card__description {
  font-size: 14px;
  color: #383630;
  margin: 0 0 30px 0;
  line-height: 1.4;
  font-family: var(--font-family-heading);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
