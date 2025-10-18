<template>
  <div :class="spinnerClasses" role="status" :aria-label="label">
    <div class="spinner" :class="sizeClass"></div>
    <span v-if="text" class="loading-text">{{ text }}</span>
    <span v-else class="sr-only">{{ label }}</span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  /**
   * Size of the spinner
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg' | 'xl'

  /**
   * Text to display next to spinner (optional)
   */
  text?: string

  /**
   * Whether to center the spinner in its container
   * @default false
   */
  center?: boolean

  /**
   * Fullscreen overlay mode
   * @default false
   */
  fullscreen?: boolean

  /**
   * Accessibility label for screen readers
   * @default 'Loading...'
   */
  label?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  text: '',
  center: false,
  fullscreen: false,
  label: 'Loading...'
})

const spinnerClasses = computed(() => ({
  'loading-spinner': true,
  'loading-spinner--center': props.center,
  'loading-spinner--fullscreen': props.fullscreen
}))

const sizeClass = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'spinner-sm'
    case 'lg':
      return 'spinner-lg'
    case 'xl':
      return 'spinner-xl'
    default:
      return ''
  }
})
</script>

<style scoped>
.loading-spinner {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-md);
}

.loading-spinner--center {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  min-height: 200px;
}

.loading-spinner--fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: rgba(255, 255, 255, 0.9);
  z-index: var(--z-index-modal);
}

[data-theme="dark"] .loading-spinner--fullscreen {
  background-color: rgba(17, 24, 39, 0.9);
}

.loading-text {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-medium);
}

/* Spinner animation is defined in utilities.css */
.spinner {
  display: inline-block;
  width: 1rem;
  height: 1rem;
  border: 2px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: var(--border-radius-full);
  animation: spin 0.6s linear infinite;
}

.spinner-sm {
  width: 0.75rem;
  height: 0.75rem;
  border-width: 1.5px;
}

.spinner-lg {
  width: 1.5rem;
  height: 1.5rem;
  border-width: 3px;
}

.spinner-xl {
  width: 2rem;
  height: 2rem;
  border-width: 3px;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
