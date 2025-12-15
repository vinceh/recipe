<template>
  <button
    class="favorite-btn"
    :class="{
      'favorite-btn--active': isFavorite,
      'favorite-btn--animating': isAnimating,
      [`favorite-btn--${size}`]: true
    }"
    @click.stop="handleClick"
    :aria-label="isFavorite ? $t('recipe.view.unfavorite') : $t('recipe.view.favorite')"
  >
    <i :class="isFavorite ? 'pi pi-heart-fill' : 'pi pi-heart'"></i>
    <span v-if="isAnimating" class="favorite-burst">
      <span class="favorite-burst__particle"></span>
      <span class="favorite-burst__particle"></span>
      <span class="favorite-burst__particle"></span>
      <span class="favorite-burst__particle"></span>
      <span class="favorite-burst__particle"></span>
      <span class="favorite-burst__particle"></span>
    </span>
  </button>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { recipeApi } from '@/services/recipeApi'
import { useAuth } from '@/composables/useAuth'

const { t } = useI18n()
const { isAuthenticated } = useAuth()

const props = defineProps<{
  recipeId: number
  isFavorite: boolean
  size?: 'small' | 'medium'
}>()

const emit = defineEmits<{
  (e: 'update:isFavorite', value: boolean): void
  (e: 'requireLogin'): void
}>()

const isAnimating = ref(false)

async function handleClick() {
  if (!isAuthenticated.value) {
    emit('requireLogin')
    return
  }

  try {
    const response = props.isFavorite
      ? await recipeApi.unfavoriteRecipe(props.recipeId)
      : await recipeApi.favoriteRecipe(props.recipeId)

    if (response.success) {
      emit('update:isFavorite', !props.isFavorite)

      if (!props.isFavorite) {
        isAnimating.value = true
        setTimeout(() => {
          isAnimating.value = false
        }, 600)
      }
    }
  } catch (err) {
    console.error('Error toggling favorite:', err)
  }
}
</script>

<style scoped>
.favorite-btn {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  cursor: pointer;
  padding: 2px;
  color: var(--color-provisions-border);
  transition: color 0.15s, transform 0.15s;
  flex-shrink: 0;
}

.favorite-btn:hover {
  color: var(--color-error);
  transform: scale(1.1);
}

.favorite-btn--active {
  color: var(--color-error);
}

.favorite-btn--small i {
  font-size: 18px;
}

.favorite-btn--medium i {
  font-size: 22px;
}

.favorite-btn--animating {
  animation: heart-throb 0.5s ease-out;
}

.favorite-btn--animating i {
  color: var(--color-error);
}

@keyframes heart-throb {
  0% { transform: scale(1); }
  15% { transform: scale(1.3); }
  30% { transform: scale(0.95); }
  45% { transform: scale(1.15); }
  60% { transform: scale(1); }
  100% { transform: scale(1); }
}

.favorite-burst {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  pointer-events: none;
}

.favorite-burst__particle {
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 4px;
  margin-left: -2px;
  margin-top: -2px;
  background-color: var(--color-error);
  border-radius: 50%;
  animation: burst-particle 0.5s ease-out forwards;
}

.favorite-burst__particle:nth-child(1) { --angle: 0deg; }
.favorite-burst__particle:nth-child(2) { --angle: 60deg; }
.favorite-burst__particle:nth-child(3) { --angle: 120deg; }
.favorite-burst__particle:nth-child(4) { --angle: 180deg; }
.favorite-burst__particle:nth-child(5) { --angle: 240deg; }
.favorite-burst__particle:nth-child(6) { --angle: 300deg; }

@keyframes burst-particle {
  0% {
    opacity: 1;
    transform: rotate(var(--angle)) translateY(0);
  }
  100% {
    opacity: 0;
    transform: rotate(var(--angle)) translateY(-18px);
  }
}
</style>
