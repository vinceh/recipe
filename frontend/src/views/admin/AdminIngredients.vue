<template>
  <div class="admin-ingredients">
    <PageHeader
      title="Ingredients"
      subtitle="Manage your ingredient database"
    />

    <EmptyState
      icon="list"
      title="No ingredients yet"
      description="Build your ingredient library to use across recipes."
    >
      <template #actions>
        <button class="btn btn-primary">
          <i class="pi pi-plus"></i>
          Add Ingredient
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
.admin-ingredients {
  width: 100%;
}
</style>
