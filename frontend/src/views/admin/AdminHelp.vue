<template>
  <div class="admin-help">
    <PageHeader
      title="Help & Support"
      subtitle="Get help and find answers to common questions"
    />

    <div class="help-sections">
      <div class="help-card">
        <i class="pi pi-book help-card__icon"></i>
        <h3 class="help-card__title">Documentation</h3>
        <p class="help-card__description">Learn how to use Ember with our comprehensive guides.</p>
        <button class="btn btn-outline">View Docs</button>
      </div>

      <div class="help-card">
        <i class="pi pi-comments help-card__icon"></i>
        <h3 class="help-card__title">Community</h3>
        <p class="help-card__description">Connect with other Ember users and share recipes.</p>
        <button class="btn btn-outline">Join Community</button>
      </div>

      <div class="help-card">
        <i class="pi pi-envelope help-card__icon"></i>
        <h3 class="help-card__title">Contact Support</h3>
        <p class="help-card__description">Get in touch with our support team for assistance.</p>
        <button class="btn btn-outline">Contact Us</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import PageHeader from '@/components/shared/PageHeader.vue'
</script>

<style scoped>
.admin-help {
  width: 100%;
}

.help-sections {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--spacing-lg);
}

.help-card {
  background-color: var(--color-background);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-md);
}

.help-card__icon {
  font-size: var(--font-size-4xl);
  color: var(--color-primary);
  margin-bottom: var(--spacing-sm);
}

.help-card__title {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.help-card__description {
  color: var(--color-text-secondary);
  font-size: var(--font-size-sm);
  margin-bottom: var(--spacing-md);
}
</style>
