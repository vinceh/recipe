<template>
  <router-link :to="`/recipes/${recipe.id}`" class="recipe-card">
    <div class="recipe-card__image-container">
      <img
        v-if="recipe.image_url"
        :src="recipe.image_url"
        :alt="recipe.name"
        class="recipe-card__image"
      />
      <div v-else class="recipe-card__image-placeholder">
        <i class="pi pi-image"></i>
      </div>
    </div>
    <div class="recipe-card__content">
      <div class="recipe-card__header">
        <h3 class="recipe-card__title">{{ recipe.name }}</h3>
        <span v-if="recipe.difficulty_level" class="recipe-card__difficulty" :class="`difficulty-${recipe.difficulty_level}`">
          {{ $t(`forms.recipe.difficultyLevels.${recipe.difficulty_level}`) }}
        </span>
      </div>

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

.recipe-card__image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
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

.recipe-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--spacing-sm);
}

.recipe-card__title {
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  margin: 0;
  color: #383630;
  line-height: 1.3;
  flex: 1;
}

.recipe-card__difficulty {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: capitalize;
  white-space: nowrap;
  flex-shrink: 0;
}

.recipe-card__difficulty.difficulty-easy {
  background: #d4f4dd;
  color: #1b5e20;
}

.recipe-card__difficulty.difficulty-medium {
  background: #fff3cd;
  color: #856404;
}

.recipe-card__difficulty.difficulty-hard {
  background: #f8d7da;
  color: #721c24;
}

.recipe-card__meta {
  display: flex;
  gap: 6px;
  font-size: 13px;
  color: #383630;
  margin: 0;
  font-family: var(--font-family-base);
  font-weight: 300;
}

.recipe-card__meta-item {
  display: inline;
}

.recipe-card__meta-item:not(:last-child)::after {
  content: '  ·  ';
  margin-left: 0;
}

.recipe-card__description {
  font-size: 14px;
  color: #383630;
  margin: 0 0 15px 0;
  line-height: 1.4;
  font-family: var(--font-family-heading);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
