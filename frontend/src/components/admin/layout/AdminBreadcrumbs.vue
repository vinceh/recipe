<template>
  <nav class="admin-breadcrumbs" aria-label="Breadcrumb">
    <ol class="admin-breadcrumbs__list">
      <li
        v-for="(crumb, index) in breadcrumbs"
        :key="index"
        class="admin-breadcrumbs__item"
      >
        <router-link
          v-if="index < breadcrumbs.length - 1"
          :to="crumb.path"
          class="admin-breadcrumbs__link"
        >
          <i v-if="crumb.icon" :class="`pi pi-${crumb.icon}`"></i>
          {{ crumb.label }}
        </router-link>
        <span v-else class="admin-breadcrumbs__current" aria-current="page">
          <i v-if="crumb.icon" :class="`pi pi-${crumb.icon}`"></i>
          {{ crumb.label }}
        </span>
        <i
          v-if="index < breadcrumbs.length - 1"
          class="pi pi-angle-right admin-breadcrumbs__separator"
        ></i>
      </li>
    </ol>
  </nav>
</template>

<script setup lang="ts">
interface Breadcrumb {
  label: string
  path: string
  icon?: string
}

interface Props {
  breadcrumbs: Breadcrumb[]
}

defineProps<Props>()
</script>

<style scoped>
.admin-breadcrumbs {
  padding: var(--spacing-sm) 0;
  margin-bottom: var(--spacing-md);
}

.admin-breadcrumbs__list {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  list-style: none;
  padding: 0;
  margin: 0;
  flex-wrap: wrap;
}

.admin-breadcrumbs__item {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  font-size: var(--font-size-sm);
}

.admin-breadcrumbs__link {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: color var(--transition-fast);
}

.admin-breadcrumbs__link:hover {
  color: var(--color-primary);
}

.admin-breadcrumbs__link i {
  font-size: var(--font-size-sm);
}

.admin-breadcrumbs__current {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-text);
  font-weight: var(--font-weight-medium);
}

.admin-breadcrumbs__current i {
  font-size: var(--font-size-sm);
}

.admin-breadcrumbs__separator {
  color: var(--color-text-tertiary);
  font-size: var(--font-size-xs);
}

/* Responsive */
@media (max-width: 768px) {
  .admin-breadcrumbs {
    padding: var(--spacing-xs) 0;
  }

  .admin-breadcrumbs__list {
    gap: var(--spacing-xxs);
  }

  .admin-breadcrumbs__item {
    font-size: var(--font-size-xs);
  }
}
</style>
