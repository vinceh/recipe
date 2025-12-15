<template>
  <div class="recipe-grid">
    <div
      v-for="recipe in recipes"
      :key="recipe.id"
      class="recipe-item"
      @click="$emit('recipe-click', recipe)"
    >
      <div class="recipe-item__image">
        <img
          v-if="recipe.image_url"
          :src="recipe.image_url"
          :alt="recipe.name"
          class="recipe-item__image-img"
        />
        <div v-else class="recipe-item__image-placeholder">
          <i class="pi pi-image"></i>
        </div>
      </div>
      <div class="recipe-item__info">
        <div class="recipe-item__title-row">
          <h3 class="recipe-item__title">{{ recipe.name }}</h3>
          <FavoriteButton
            :recipe-id="recipe.id"
            :is-favorite="recipe.favorite || false"
            size="small"
            @update:is-favorite="$emit('update:favorite', recipe, $event)"
            @require-login="$emit('require-login')"
          />
        </div>
        <p class="recipe-item__meta">
          <span v-if="recipe.timing?.total_minutes">{{ formatTime(recipe.timing.total_minutes) }}</span>
          <span v-if="recipe.servings?.original">{{ recipe.servings.original }} {{ $t('common.labels.servings') }}</span>
          <span v-if="recipe.difficulty_level">{{ $t(`forms.recipe.difficultyLevels.${recipe.difficulty_level}`) }}</span>
        </p>
        <template v-if="recipe.cuisines?.length && recipe.dietary_tags?.length">
          <p v-if="canFitOneLine(recipe.cuisines, recipe.dietary_tags)" class="recipe-item__meta">
            <span>{{ recipe.cuisines.join(', ') }}</span>
            <span>{{ recipe.dietary_tags.join(', ') }}</span>
          </p>
          <template v-else>
            <p class="recipe-item__meta">
              <span>{{ recipe.cuisines.join(', ') }}</span>
            </p>
            <p class="recipe-item__meta">
              <span>{{ recipe.dietary_tags.join(', ') }}</span>
            </p>
          </template>
        </template>
        <p v-else-if="recipe.cuisines?.length" class="recipe-item__meta">
          <span>{{ recipe.cuisines.join(', ') }}</span>
        </p>
        <p v-else-if="recipe.dietary_tags?.length" class="recipe-item__meta">
          <span>{{ recipe.dietary_tags.join(', ') }}</span>
        </p>
        <p class="recipe-item__description">{{ recipe.description }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Recipe } from '@/services/types'
import { useTimeFormatter } from '@/composables/useTimeFormatter'
import FavoriteButton from '@/components/shared/FavoriteButton.vue'

interface Props {
  recipes: Recipe[]
}

defineProps<Props>()

defineEmits<{
  (e: 'recipe-click', recipe: Recipe): void
  (e: 'update:favorite', recipe: Recipe, isFavorite: boolean): void
  (e: 'require-login'): void
}>()

const { formatTime } = useTimeFormatter()

function canFitOneLine(cuisines: string[] | undefined, dietaryTags: string[] | undefined): boolean {
  if (!cuisines?.length || !dietaryTags?.length) {
    return true
  }
  const cuisinesText = cuisines.join(', ')
  const dietaryTagsText = dietaryTags.join(', ')
  const combinedText = `${cuisinesText} · ${dietaryTagsText}`
  return combinedText.length <= 40
}
</script>

<style scoped>
.recipe-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0;
  border-top: 1px solid var(--color-provisions-border);
}

.recipe-item {
  display: flex;
  flex-direction: column;
  border-right: 1px solid var(--color-provisions-border);
  border-bottom: 1px solid var(--color-provisions-border);
  cursor: pointer;
  transition: background 0.15s;
  min-width: 0;
}

.recipe-item:hover {
  background: rgba(0, 0, 0, 0.02);
}

.recipe-item:nth-child(2n) {
  border-right: none;
}

.recipe-item__image {
  width: 100%;
  height: 350px;
  overflow: hidden;
  background: var(--color-provisions-card-bg);
  border-bottom: 1px solid var(--color-provisions-border);
}

.recipe-item__image-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
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
  overflow: hidden;
  min-width: 0;
}

.recipe-item__title-row {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.recipe-item__title {
  font-family: var(--font-family-heading);
  font-size: 16px;
  font-weight: 600;
  margin: 0;
  color: var(--color-provisions-text-dark);
  line-height: 1.3;
  flex: 1;
}

.recipe-item__meta {
  font-size: 13px;
  color: var(--color-provisions-border);
  margin: 3px 0 0 0;
  font-family: var(--font-family-base);
  font-weight: 300;
  line-height: 1.4;
}

.recipe-item__meta + .recipe-item__meta {
  margin-top: 0;
}

.recipe-item__meta:last-of-type {
  margin-bottom: 10px;
}

.recipe-item__meta span:not(:last-child)::after {
  content: "  ·   ";
  margin-left: 0;
}

.recipe-item__description {
  font-size: 14px;
  color: var(--color-provisions-text-dark);
  margin: 15px 0 15px 0;
  line-height: 1.4;
  font-family: var(--font-family-heading);
  font-weight: normal;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

@media (max-width: 1000px) {
  .recipe-grid {
    grid-template-columns: 1fr;
  }

  .recipe-item {
    border-right: none;
  }
}
</style>
