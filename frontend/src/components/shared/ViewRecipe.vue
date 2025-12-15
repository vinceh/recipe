<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import type { RecipeDetail } from '@/services/types'

interface Props {
  recipe: Partial<RecipeDetail>
}

const props = defineProps<Props>()
const { t } = useI18n()

const hasIngredients = computed(() => {
  return props.recipe.ingredient_groups?.some(g => g.items?.some(i => i && i.name))
})

const hasSteps = computed(() => {
  return props.recipe.steps?.some(s => s.instruction?.trim().length > 0)
})

const hasNutrition = computed(() => {
  const n = props.recipe.nutrition?.per_serving
  return n && (n.calories || n.protein_g || n.carbs_g || n.fat_g)
})
</script>

<template>
  <div class="view-recipe recipe-display">
    <!-- Recipe Image -->
    <div v-if="recipe.image_url" class="recipe-image">
      <img :src="recipe.image_url" :alt="recipe.name" class="recipe-image__img" />
    </div>
    <div v-else class="recipe-image recipe-image--placeholder">
      <span>{{ $t('forms.recipe.sections.image') }}</span>
    </div>

    <!-- Recipe Info -->
    <div class="recipe-info">
      <h1 class="recipe-info__title">{{ recipe.name || $t('recipe.view.defaultTitle') }}</h1>

      <p class="recipe-info__meta">
        <span v-if="recipe.timing?.total_minutes">{{ recipe.timing.total_minutes }}{{ $t('admin.recipes.table.minutes') }}</span>
        <span v-if="recipe.servings?.original">{{ recipe.servings.original }} {{ $t('common.labels.servings') }}</span>
        <span v-if="recipe.difficulty_level">{{ $t(`forms.recipe.difficultyLevels.${recipe.difficulty_level}`) }}</span>
        <span v-if="recipe.cuisines?.length">{{ recipe.cuisines.join(', ') }}</span>
        <span v-if="recipe.dietary_tags?.length">{{ recipe.dietary_tags.join(', ') }}</span>
      </p>

      <div v-if="recipe.tags?.length" class="recipe-info__tags">
        <span v-for="tag in recipe.tags" :key="tag" class="recipe-tag">{{ tag }}</span>
      </div>

      <p v-if="recipe.description" class="recipe-info__description">{{ recipe.description }}</p>

      <!-- Nutrition Info -->
      <div v-if="hasNutrition" class="nutrition-info">
        <div v-if="recipe.nutrition?.per_serving?.calories" class="nutrition-info__item">
          <span class="nutrition-info__label">{{ $t('recipe.view.cals') }}</span>
          <span class="nutrition-info__value">{{ recipe.nutrition.per_serving.calories }}</span>
        </div>
        <div v-if="recipe.nutrition?.per_serving?.carbs_g" class="nutrition-info__item">
          <span class="nutrition-info__label">{{ $t('recipe.view.carbs') }}</span>
          <span class="nutrition-info__value">{{ recipe.nutrition.per_serving.carbs_g }}g</span>
        </div>
        <div v-if="recipe.nutrition?.per_serving?.protein_g" class="nutrition-info__item">
          <span class="nutrition-info__label">{{ $t('recipe.view.protein') }}</span>
          <span class="nutrition-info__value">{{ recipe.nutrition.per_serving.protein_g }}g</span>
        </div>
        <div v-if="recipe.nutrition?.per_serving?.fat_g" class="nutrition-info__item">
          <span class="nutrition-info__label">{{ $t('recipe.view.fat') }}</span>
          <span class="nutrition-info__value">{{ recipe.nutrition.per_serving.fat_g }}g</span>
        </div>
      </div>

      <!-- Ingredients -->
      <div v-if="hasIngredients" class="recipe-ingredients">
        <h2 class="recipe-section__title">{{ $t('recipe.view.ingredients') }}</h2>
        <div v-for="(group, groupIndex) in recipe.ingredient_groups" :key="groupIndex" class="ingredient-group">
          <h3 v-if="group.name" class="ingredient-group__name">{{ group.name }}</h3>
          <ul class="ingredient-list">
            <template v-for="(item, itemIndex) in group.items" :key="itemIndex">
              <li v-if="item && item.name" class="ingredient-item">
                <span v-if="item.amount" class="ingredient-item__amount">{{ item.amount }} {{ item.unit }} </span>
                <span class="ingredient-item__name">{{ item.name }}</span>
                <span v-if="item.preparation" class="ingredient-item__prep"> ({{ item.preparation }})</span>
                <span v-if="item.optional" class="ingredient-item__optional"> ({{ $t('recipe.view.optional') }})</span>
              </li>
            </template>
          </ul>
        </div>
      </div>
      <div v-else class="section-placeholder">
        <span>{{ $t('forms.recipe.sections.ingredients') }}</span>
      </div>
    </div>

    <!-- Steps -->
    <div v-if="hasSteps" class="recipe-steps">
      <h2 class="recipe-section__title">{{ $t('recipe.view.steps') }}</h2>
      <div class="steps-list">
        <template v-for="(step, index) in recipe.steps" :key="index">
          <div v-if="step.instruction?.trim()" class="step-item">
            <h3 v-if="step.section_heading" class="step-section-heading">{{ step.section_heading }}</h3>
            <p class="step-item__text">{{ step.instruction }}</p>
          </div>
        </template>
      </div>
    </div>
    <div v-else class="recipe-steps section-placeholder">
      <span>{{ $t('forms.recipe.sections.steps') }}</span>
    </div>
  </div>
</template>

<style>
@import '@/assets/styles/recipe-display.css';
</style>

<style scoped>
.view-recipe {
  width: 100%;
  height: 100%;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  background: var(--color-provisions-bg);
  font-size: 16px;
}
</style>
