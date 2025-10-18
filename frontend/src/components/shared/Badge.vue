<template>
  <span :class="badgeClasses">
    <i v-if="icon" :class="`pi pi-${icon}`"></i>
    <slot></slot>
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  /**
   * Badge variant
   * @default 'default'
   */
  variant?: 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info'

  /**
   * Badge size
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'

  /**
   * PrimeIcons icon name (without 'pi pi-' prefix)
   */
  icon?: string

  /**
   * Rounded pill style
   * @default false
   */
  pill?: boolean

  /**
   * Dot indicator style (small circle)
   * @default false
   */
  dot?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
  size: 'md',
  icon: '',
  pill: false,
  dot: false
})

const badgeClasses = computed(() => ({
  badge: true,
  [`badge-${props.variant}`]: true,
  [`badge-${props.size}`]: true,
  'badge-pill': props.pill,
  'badge-dot': props.dot
}))
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  line-height: 1;
  border-radius: var(--border-radius-md);
  white-space: nowrap;
  vertical-align: middle;
}

/* Sizes */
.badge-sm {
  padding: 2px var(--spacing-xs);
  font-size: 0.625rem; /* 10px */
}

.badge-md {
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-xs);
}

.badge-lg {
  padding: var(--spacing-sm) var(--spacing-md);
  font-size: var(--font-size-sm);
}

/* Pill style */
.badge-pill {
  border-radius: var(--border-radius-full);
}

/* Dot style */
.badge-dot {
  padding: 0;
  width: 0.5rem;
  height: 0.5rem;
  border-radius: var(--border-radius-full);
  font-size: 0;
}

.badge-dot.badge-sm {
  width: 0.375rem;
  height: 0.375rem;
}

.badge-dot.badge-lg {
  width: 0.75rem;
  height: 0.75rem;
}

/* Variants */
.badge-default {
  background-color: var(--color-gray-200);
  color: var(--color-gray-800);
}

[data-theme="dark"] .badge-default {
  background-color: var(--color-gray-700);
  color: var(--color-gray-200);
}

.badge-primary {
  background-color: var(--color-primary-pale);
  color: var(--color-primary-dark);
}

[data-theme="dark"] .badge-primary {
  background-color: rgba(79, 70, 229, 0.2);
  color: var(--color-primary-light);
}

.badge-secondary {
  background-color: var(--color-secondary-pale);
  color: var(--color-secondary-dark);
}

[data-theme="dark"] .badge-secondary {
  background-color: rgba(16, 185, 129, 0.2);
  color: var(--color-secondary-light);
}

.badge-success {
  background-color: var(--color-success-light);
  color: var(--color-success-dark);
}

[data-theme="dark"] .badge-success {
  background-color: rgba(16, 185, 129, 0.2);
  color: var(--color-success-light);
}

.badge-warning {
  background-color: var(--color-warning-light);
  color: var(--color-warning-dark);
}

[data-theme="dark"] .badge-warning {
  background-color: rgba(245, 158, 11, 0.2);
  color: var(--color-warning-light);
}

.badge-error {
  background-color: var(--color-error-light);
  color: var(--color-error-dark);
}

[data-theme="dark"] .badge-error {
  background-color: rgba(239, 68, 68, 0.2);
  color: var(--color-error-light);
}

.badge-info {
  background-color: var(--color-info-light);
  color: var(--color-info-dark);
}

[data-theme="dark"] .badge-info {
  background-color: rgba(59, 130, 246, 0.2);
  color: var(--color-info-light);
}

/* Icon adjustments */
.badge i {
  font-size: 0.75em;
}
</style>
