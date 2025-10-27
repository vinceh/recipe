<template>
  <div class="recipe-grid">
    <RecipeCard v-for="recipe in recipes" :key="recipe.id" :recipe="recipe" />
  </div>
</template>

<script setup lang="ts">
import type { Recipe } from '@/services/types'
import RecipeCard from './RecipeCard.vue'

interface Props {
  recipes: Recipe[]
}

defineProps<Props>()
</script>

<style scoped>
.recipe-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-lg);
  width: 100%;
}

@media (max-width: 768px) {
  .recipe-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: var(--spacing-md);
  }
}

@media (max-width: 480px) {
  .recipe-grid {
    grid-template-columns: 1fr;
  }
}
</style>
