<template>
  <div class="admin-settings">
    <PageHeader
      title="Settings"
      subtitle="Manage your application settings and preferences"
    />

    <div class="settings-sections">
      <div class="settings-card">
        <h3 class="settings-card__title">General Settings</h3>
        <p class="settings-card__description">Coming soon...</p>
      </div>

      <div class="settings-card">
        <h3 class="settings-card__title">Appearance</h3>
        <p class="settings-card__description">Coming soon...</p>
      </div>

      <div class="settings-card">
        <h3 class="settings-card__title">Notifications</h3>
        <p class="settings-card__description">Coming soon...</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import PageHeader from '@/components/shared/PageHeader.vue'
</script>

<style scoped>
.admin-settings {
  width: 100%;
}

.settings-sections {
  display: grid;
  gap: var(--spacing-lg);
}

.settings-card {
  background-color: var(--color-background);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
}

.settings-card__title {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
}

.settings-card__description {
  color: var(--color-text-secondary);
  font-size: var(--font-size-sm);
}
</style>
