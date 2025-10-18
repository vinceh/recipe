<template>
  <div class="admin-data-references">
    <PageHeader
      :title="$t('admin.dataReferences.title')"
      :subtitle="$t('admin.dataReferences.subtitle')"
    />

    <EmptyState
      icon="database"
      :title="$t('admin.dataReferences.noDataReferences')"
      :description="$t('admin.dataReferences.noDataReferencesDescription')"
    >
      <template #actions>
        <button class="btn btn-primary">
          <i class="pi pi-plus"></i>
          {{ $t('common.buttons.addReferenceData') }}
        </button>
      </template>
    </EmptyState>
  </div>
</template>

<script setup lang="ts">
import PageHeader from '@/components/shared/PageHeader.vue'
import EmptyState from '@/components/shared/EmptyState.vue'
</script>

<style scoped>
.admin-data-references {
  width: 100%;
}
</style>
