<template>
  <router-link :to="{ name: 'recipe-detail', params: { id: recipe.id } }" class="recipe-card">
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

      <div v-if="recipe.tags?.length" class="recipe-card__tags">
        <span v-for="tag in recipe.tags.slice(0, 3)" :key="tag" class="recipe-card__tag">
          {{ tag }}
        </span>
        <span v-if="recipe.tags.length > 3" class="recipe-card__tag recipe-card__tag--more">
          +{{ recipe.tags.length - 3 }}
        </span>
      </div>
    </div>
  </router-link>
</template>

<script setup lang="ts">
import type { Recipe } from '@/services/types'
import { useTimeFormatter } from '@/composables/useTimeFormatter'

interface Props {
  recipe: Recipe
}

const props = defineProps<Props>()
const { formatTime } = useTimeFormatter()

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
  color: var(--color-provisions-placeholder);
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
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  margin: 0;
  color: var(--color-provisions-border);
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
  background: var(--color-difficulty-easy-bg);
  color: var(--color-difficulty-easy-text);
}

.recipe-card__difficulty.difficulty-medium {
  background: var(--color-difficulty-medium-bg);
  color: var(--color-difficulty-medium-text);
}

.recipe-card__difficulty.difficulty-hard {
  background: var(--color-difficulty-hard-bg);
  color: var(--color-difficulty-hard-text);
}

.recipe-card__meta {
  font-size: var(--font-size-sm);
  color: var(--color-provisions-border);
  margin: 0;
  font-family: var(--font-family-base);
  font-weight: var(--font-weight-normal);
  line-height: 1.4;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.recipe-card__meta-item:not(:last-child)::after {
  content: ' · ';
}

.recipe-card__description {
  font-size: var(--font-size-sm);
  color: var(--color-provisions-border);
  margin: 0 0 var(--spacing-md) 0;
  line-height: 1.4;
  font-family: var(--font-family-heading);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.recipe-card__tags {
  display: flex;
  gap: var(--spacing-xs);
  flex-wrap: wrap;
  margin-top: auto;
}

.recipe-card__tag {
  display: inline-block;
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  background: var(--color-gray-100);
  color: var(--color-text-secondary);
}

.recipe-card__tag--more {
  background: transparent;
  color: var(--color-text-tertiary);
}
</style>
