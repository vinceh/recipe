/**
 * useRecipeScaling Composable
 *
 * Provides reactive recipe scaling with smart ingredient formatting.
 * Handles 0.5 serving increments, unit stepping, and indivisible items.
 */

import { ref, computed, watch, type Ref } from 'vue'
import type { RecipeDetail } from '@/services/types'
import {
  scaleIngredients,
  getScaleFactor,
  formatScaleFactor,
  type ScaledIngredientGroup,
  type ScaleOptions,
} from '@/utils/recipeScaler'

export interface UseRecipeScalingReturn {
  currentServings: Ref<number>
  originalServings: Ref<number>
  scaleFactor: Ref<number>
  scaleFactorDisplay: Ref<string>
  scaledIngredientGroups: Ref<ScaledIngredientGroup[]>
  isScaled: Ref<boolean>
  increment: () => void
  decrement: () => void
  reset: () => void
  setServings: (servings: number) => void
}

export function useRecipeScaling(
  recipe: Ref<RecipeDetail | null>
): UseRecipeScalingReturn {
  const currentServings = ref(1)
  const originalServings = ref(1)

  watch(
    recipe,
    (newRecipe) => {
      if (newRecipe?.servings?.original) {
        originalServings.value = newRecipe.servings.original
        currentServings.value = newRecipe.servings.original
      }
    },
    { immediate: true }
  )

  const scaleFactor = computed(() =>
    getScaleFactor(originalServings.value, currentServings.value)
  )

  const scaleFactorDisplay = computed(() =>
    formatScaleFactor(scaleFactor.value)
  )

  const isScaled = computed(() =>
    currentServings.value !== originalServings.value
  )

  const scaledIngredientGroups = computed<ScaledIngredientGroup[]>(() => {
    if (!recipe.value?.ingredient_groups) {
      return []
    }

    const options: ScaleOptions = {
      requiresPrecision: recipe.value.requires_precision || false,
      originalServings: originalServings.value,
      targetServings: currentServings.value,
    }

    return scaleIngredients(recipe.value.ingredient_groups, options)
  })

  function increment() {
    currentServings.value = Math.min(currentServings.value + 0.5, 99)
  }

  function decrement() {
    currentServings.value = Math.max(currentServings.value - 0.5, 0.5)
  }

  function reset() {
    currentServings.value = originalServings.value
  }

  function setServings(servings: number) {
    currentServings.value = Math.max(0.5, Math.min(99, servings))
  }

  return {
    currentServings,
    originalServings,
    scaleFactor,
    scaleFactorDisplay,
    scaledIngredientGroups,
    isScaled,
    increment,
    decrement,
    reset,
    setServings,
  }
}
