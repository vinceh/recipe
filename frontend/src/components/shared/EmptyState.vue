<template>
  <div :class="emptyStateClasses">
    <div v-if="icon" class="empty-state-icon">
      <i :class="`pi pi-${icon}`"></i>
    </div>

    <h3 v-if="title" class="empty-state-title">{{ title }}</h3>

    <p v-if="description" class="empty-state-description">{{ description }}</p>

    <slot></slot>

    <div v-if="$slots.actions || actionText" class="empty-state-actions">
      <slot name="actions">
        <button v-if="actionText" class="btn btn-primary" @click="handleAction">
          {{ actionText || $t('common.buttons.getStarted') }}
        </button>
      </slot>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  /**
   * PrimeIcons icon name (without 'pi pi-' prefix)
   * @example 'inbox', 'search', 'file'
   */
  icon?: string

  /**
   * Empty state title
   */
  title?: string

  /**
   * Empty state description
   */
  description?: string

  /**
   * Action button text
   */
  actionText?: string

  /**
   * Action button handler (if provided, shows default action button)
   */
  action?: () => void

  /**
   * Compact mode (smaller padding)
   * @default false
   */
  compact?: boolean
}

import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = withDefaults(defineProps<Props>(), {
  icon: '',
  title: '',
  description: '',
  actionText: '',
  action: undefined,
  compact: false
})

interface Emits {
  (e: 'action'): void
}

const emit = defineEmits<Emits>()

const emptyStateClasses = computed(() => ({
  'empty-state': true,
  'empty-state--compact': props.compact
}))

const handleAction = () => {
  if (props.action) {
    props.action()
  } else {
    emit('action')
  }
}
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-3xl) var(--spacing-xl);
  text-align: center;
  color: var(--color-text-secondary);
  min-height: 300px;
}

.empty-state--compact {
  padding: var(--spacing-xl) var(--spacing-lg);
  min-height: 200px;
}

.empty-state-icon {
  font-size: var(--font-size-5xl);
  color: var(--color-text-tertiary);
  margin-bottom: var(--spacing-lg);
  line-height: 1;
}

.empty-state--compact .empty-state-icon {
  font-size: var(--font-size-4xl);
  margin-bottom: var(--spacing-md);
}

.empty-state-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin: 0 0 var(--spacing-sm) 0;
  max-width: 400px;
}

.empty-state--compact .empty-state-title {
  font-size: var(--font-size-lg);
}

.empty-state-description {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  margin: 0 0 var(--spacing-lg) 0;
  max-width: 500px;
  line-height: var(--line-height-relaxed);
}

.empty-state--compact .empty-state-description {
  font-size: var(--font-size-sm);
  margin-bottom: var(--spacing-md);
}

.empty-state-actions {
  display: flex;
  gap: var(--spacing-md);
  flex-wrap: wrap;
  justify-content: center;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .empty-state {
    padding: var(--spacing-2xl) var(--spacing-md);
  }

  .empty-state-icon {
    font-size: var(--font-size-4xl);
  }

  .empty-state-title {
    font-size: var(--font-size-lg);
  }

  .empty-state-description {
    font-size: var(--font-size-sm);
  }
}
</style>
