<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useI18n } from 'vue-i18n'

interface Props {
  size?: 'sm' | 'md' | 'lg' | 'xl'
  fullscreen?: boolean
  label?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'lg',
  fullscreen: false,
  label: 'Loading...'
})

const { t } = useI18n()

const cookingPunKeys = [
  'admin.recipes.urlImportDialog.loadingPuns.preppingIngredients',
  'admin.recipes.urlImportDialog.loadingPuns.simmeringRecipe',
  'admin.recipes.urlImportDialog.loadingPuns.seasoningPerfection',
  'admin.recipes.urlImportDialog.loadingPuns.reducingSauce',
  'admin.recipes.urlImportDialog.loadingPuns.lettingMarinate',
  'admin.recipes.urlImportDialog.loadingPuns.whiskingAway',
  'admin.recipes.urlImportDialog.loadingPuns.bringingToBoil',
  'admin.recipes.urlImportDialog.loadingPuns.addingMagic'
]

const currentPunIndex = ref(0)
const currentPunKey = computed((): string => cookingPunKeys[currentPunIndex.value]!)
let intervalId: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  intervalId = setInterval(() => {
    currentPunIndex.value = (currentPunIndex.value + 1) % cookingPunKeys.length
  }, 2000)
})

onUnmounted(() => {
  if (intervalId) {
    clearInterval(intervalId)
  }
})
</script>

<template>
  <div
    :class="[
      'playful-loading-spinner',
      `playful-loading-spinner--${size}`,
      { 'playful-loading-spinner--fullscreen': fullscreen }
    ]"
    role="status"
    :aria-label="label"
  >
    <div class="playful-loading-spinner__content">
      <div class="playful-loading-spinner__spinner">
        <i class="pi pi-spin pi-spinner"></i>
      </div>
      <div class="playful-loading-spinner__text">
        <p class="playful-loading-spinner__pun">
          {{ t(currentPunKey) }}
        </p>
        <p class="playful-loading-spinner__subtitle">
          {{ t('admin.recipes.urlImportDialog.loadingSubtitle') }}
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.playful-loading-spinner {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-xl);
}

.playful-loading-spinner--fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: var(--z-index-modal, 9999);
}

.playful-loading-spinner__content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-lg);
}

.playful-loading-spinner__spinner {
  color: var(--color-primary);
  font-size: var(--font-size-4xl);
}

.playful-loading-spinner--sm .playful-loading-spinner__spinner {
  font-size: var(--font-size-lg);
}

.playful-loading-spinner--md .playful-loading-spinner__spinner {
  font-size: var(--font-size-2xl);
}

.playful-loading-spinner--lg .playful-loading-spinner__spinner {
  font-size: var(--font-size-4xl);
}

.playful-loading-spinner--xl .playful-loading-spinner__spinner {
  font-size: var(--font-size-5xl);
}

.playful-loading-spinner__text {
  text-align: center;
  max-width: 400px;
}

.playful-loading-spinner__pun {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-sm) 0;
  min-height: 28px;
  transition: opacity 0.3s ease-in-out;
}

.playful-loading-spinner__subtitle {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  font-style: italic;
  margin: 0;
}

.playful-loading-spinner--fullscreen .playful-loading-spinner__pun,
.playful-loading-spinner--fullscreen .playful-loading-spinner__subtitle {
  color: white;
}
</style>
