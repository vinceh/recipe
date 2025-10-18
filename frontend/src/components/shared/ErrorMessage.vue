<template>
  <div v-if="error || message" :class="errorClasses" role="alert">
    <div v-if="!dismissible" class="error-message__icon">
      <i class="pi pi-exclamation-circle"></i>
    </div>

    <div class="error-message__content">
      <h4 v-if="title" class="error-message__title">{{ title }}</h4>
      <p class="error-message__text">{{ displayMessage }}</p>
      <slot></slot>
    </div>

    <button
      v-if="dismissible"
      class="error-message__close"
      @click="handleDismiss"
      aria-label="Dismiss error"
    >
      <i class="pi pi-times"></i>
    </button>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  /**
   * Error object (will extract message from it)
   */
  error?: Error | null

  /**
   * Direct error message
   */
  message?: string

  /**
   * Error title (optional)
   */
  title?: string

  /**
   * Severity level
   * @default 'error'
   */
  severity?: 'error' | 'warning' | 'info'

  /**
   * Whether the error can be dismissed
   * @default false
   */
  dismissible?: boolean

  /**
   * Whether to show in compact mode
   * @default false
   */
  compact?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  error: null,
  message: '',
  title: '',
  severity: 'error',
  dismissible: false,
  compact: false
})

interface Emits {
  (e: 'dismiss'): void
}

const emit = defineEmits<Emits>()

import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const displayMessage = computed(() => {
  if (props.message) {
    return props.message
  }
  if (props.error) {
    return props.error.message || t('common.messages.unexpectedError')
  }
  return t('common.messages.errorOccurred')
})

const errorClasses = computed(() => ({
  'error-message': true,
  [`error-message--${props.severity}`]: true,
  'error-message--compact': props.compact,
  'error-message--dismissible': props.dismissible
}))

const handleDismiss = () => {
  emit('dismiss')
}
</script>

<style scoped>
.error-message {
  display: flex;
  gap: var(--spacing-md);
  padding: var(--spacing-md);
  border: var(--border-width-thin) solid transparent;
  border-radius: var(--border-radius-md);
  margin-bottom: var(--spacing-md);
}

.error-message--error {
  background-color: var(--color-error-light);
  color: var(--color-error-dark);
  border-color: var(--color-error);
}

.error-message--warning {
  background-color: var(--color-warning-light);
  color: var(--color-warning-dark);
  border-color: var(--color-warning);
}

.error-message--info {
  background-color: var(--color-info-light);
  color: var(--color-info-dark);
  border-color: var(--color-info);
}

.error-message--compact {
  padding: var(--spacing-sm) var(--spacing-md);
}

.error-message--dismissible {
  padding-right: var(--spacing-xl);
  position: relative;
}

.error-message__icon {
  flex-shrink: 0;
  font-size: var(--font-size-xl);
  line-height: 1;
}

.error-message__content {
  flex: 1;
  min-width: 0;
}

.error-message__title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  margin: 0 0 var(--spacing-xs) 0;
}

.error-message__text {
  font-size: var(--font-size-sm);
  margin: 0;
  line-height: var(--line-height-normal);
}

.error-message--compact .error-message__text {
  font-size: var(--font-size-sm);
}

.error-message__close {
  position: absolute;
  top: var(--spacing-sm);
  right: var(--spacing-sm);
  background: none;
  border: none;
  cursor: pointer;
  padding: var(--spacing-xs);
  color: inherit;
  opacity: 0.7;
  transition: opacity var(--transition-fast);
  border-radius: var(--border-radius-sm);
}

.error-message__close:hover {
  opacity: 1;
}

.error-message__close:focus {
  outline: none;
  box-shadow: var(--shadow-focus);
}

/* Dark mode adjustments */
[data-theme="dark"] .error-message--error {
  background-color: rgba(239, 68, 68, 0.2);
  border-color: var(--color-error);
}

[data-theme="dark"] .error-message--warning {
  background-color: rgba(245, 158, 11, 0.2);
  border-color: var(--color-warning);
}

[data-theme="dark"] .error-message--info {
  background-color: rgba(59, 130, 246, 0.2);
  border-color: var(--color-info);
}
</style>
