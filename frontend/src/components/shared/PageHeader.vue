<template>
  <header class="page-header">
    <div class="page-header__content">
      <div class="page-header__main">
        <div v-if="backTo" class="page-header__back">
          <button class="btn-reset page-header__back-button" @click="handleBack">
            <i class="pi pi-arrow-left"></i>
            <span>{{ $t('common.buttons.back') }}</span>
          </button>
        </div>

        <div class="page-header__titles">
          <h1 class="page-header__title">{{ title }}</h1>
          <p v-if="subtitle" class="page-header__subtitle">{{ subtitle }}</p>
        </div>
      </div>

      <div v-if="$slots.actions" class="page-header__actions">
        <slot name="actions"></slot>
      </div>
    </div>

    <div v-if="$slots.tabs" class="page-header__tabs">
      <slot name="tabs"></slot>
    </div>
  </header>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

interface Props {
  /**
   * Page title
   */
  title: string

  /**
   * Page subtitle (optional)
   */
  subtitle?: string

  /**
   * Route name or path to navigate back to (shows back button if provided)
   */
  backTo?: string
}

const props = withDefaults(defineProps<Props>(), {
  subtitle: '',
  backTo: ''
})

const router = useRouter()

const handleBack = () => {
  if (props.backTo) {
    router.push(props.backTo)
  } else {
    router.back()
  }
}
</script>

<style scoped>
.page-header {
  background-color: var(--color-background);
  border-bottom: var(--border-width-thin) solid var(--color-border);
  margin-bottom: var(--spacing-lg);
}

.page-header__content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: var(--spacing-lg);
  padding: var(--spacing-lg) var(--spacing-xl);
}

.page-header__main {
  flex: 1;
  min-width: 0;
}

.page-header__back {
  margin-bottom: var(--spacing-sm);
}

.page-header__back-button {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-xs) var(--spacing-sm);
  color: var(--color-text-secondary);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  border-radius: var(--border-radius-md);
  transition: all var(--transition-fast);
}

.page-header__back-button:hover {
  color: var(--color-primary);
  background-color: var(--color-background-secondary);
}

.page-header__back-button:focus {
  box-shadow: var(--shadow-focus);
}

.page-header__titles {
  min-width: 0;
}

.page-header__title {
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0;
  line-height: var(--line-height-tight);
}

.page-header__subtitle {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  margin: var(--spacing-xs) 0 0 0;
  line-height: var(--line-height-normal);
}

.page-header__actions {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  flex-shrink: 0;
}

.page-header__tabs {
  padding: 0 var(--spacing-xl);
  border-top: var(--border-width-thin) solid var(--color-border-light);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .page-header__content {
    flex-direction: column;
    align-items: stretch;
    padding: var(--spacing-md);
  }

  .page-header__title {
    font-size: var(--font-size-2xl);
  }

  .page-header__subtitle {
    font-size: var(--font-size-sm);
  }

  .page-header__actions {
    justify-content: flex-start;
    width: 100%;
  }

  .page-header__tabs {
    padding: 0 var(--spacing-md);
  }
}

@media (max-width: 480px) {
  .page-header__title {
    font-size: var(--font-size-xl);
  }

  .page-header__actions {
    flex-direction: column;
    align-items: stretch;
    gap: var(--spacing-sm);
  }
}
</style>
