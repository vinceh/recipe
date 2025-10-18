<template>
  <div class="admin-dashboard">
    <PageHeader
      :title="$t('admin.dashboard.title')"
      :subtitle="$t('admin.dashboard.subtitle')"
    />

    <div class="dashboard-stats">
      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--primary">
          <i class="pi pi-book"></i>
        </div>
        <div class="stat-card__content">
          <div class="stat-card__label">{{ $t('admin.dashboard.totalRecipes') }}</div>
          <div class="stat-card__value">0</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--success">
          <i class="pi pi-database"></i>
        </div>
        <div class="stat-card__content">
          <div class="stat-card__label">{{ $t('admin.dashboard.dataReferences') }}</div>
          <div class="stat-card__value">0</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--info">
          <i class="pi pi-sparkles"></i>
        </div>
        <div class="stat-card__content">
          <div class="stat-card__label">{{ $t('admin.dashboard.aiPrompts') }}</div>
          <div class="stat-card__value">0</div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-card__icon stat-card__icon--warning">
          <i class="pi pi-list"></i>
        </div>
        <div class="stat-card__content">
          <div class="stat-card__label">{{ $t('admin.dashboard.ingredients') }}</div>
          <div class="stat-card__value">0</div>
        </div>
      </div>
    </div>

    <div class="dashboard-content">
      <EmptyState
        icon="fire"
        :title="$t('admin.dashboard.welcomeTitle')"
        :description="$t('admin.dashboard.welcomeDescription')"
      >
        <template #actions>
          <router-link to="/admin/recipes" class="btn btn-primary">
            <i class="pi pi-plus"></i>
            {{ $t('common.buttons.createRecipe') }}
          </router-link>
          <router-link to="/admin/data-references" class="btn btn-outline">
            {{ $t('common.buttons.manageData') }}
          </router-link>
        </template>
      </EmptyState>
    </div>
  </div>
</template>

<script setup lang="ts">
import PageHeader from '@/components/shared/PageHeader.vue'
import EmptyState from '@/components/shared/EmptyState.vue'
</script>

<style scoped>
.admin-dashboard {
  width: 100%;
}

.dashboard-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-2xl);
}

.stat-card {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-lg);
  background-color: var(--color-background);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-lg);
  box-shadow: var(--shadow-sm);
}

.stat-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: var(--border-radius-lg);
  font-size: var(--font-size-xl);
}

.stat-card__icon--primary {
  background-color: var(--color-primary-pale);
  color: var(--color-primary);
}

.stat-card__icon--success {
  background-color: var(--color-success-light);
  color: var(--color-success-dark);
}

.stat-card__icon--info {
  background-color: var(--color-info-light);
  color: var(--color-info-dark);
}

.stat-card__icon--warning {
  background-color: var(--color-warning-light);
  color: var(--color-warning-dark);
}

.stat-card__content {
  flex: 1;
}

.stat-card__label {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-xs);
}

.stat-card__value {
  font-size: var(--font-size-3xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
}

.dashboard-content {
  background-color: var(--color-background);
  border: var(--border-width-thin) solid var(--color-border);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
}

/* Responsive */
@media (max-width: 768px) {
  .dashboard-stats {
    grid-template-columns: 1fr;
  }
}
</style>
