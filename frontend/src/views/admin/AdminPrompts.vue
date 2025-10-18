<template>
  <div class="admin-prompts">
    <PageHeader
      :title="$t('admin.prompts.title')"
      :subtitle="$t('admin.prompts.subtitle')"
    />

    <EmptyState
      icon="sparkles"
      :title="$t('admin.prompts.noPrompts')"
      :description="$t('admin.prompts.noPromptsDescription')"
    >
      <template #actions>
        <button class="btn btn-primary">
          <i class="pi pi-plus"></i>
          {{ $t('common.buttons.createPromptTemplate') }}
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
.admin-prompts {
  width: 100%;
}
</style>
