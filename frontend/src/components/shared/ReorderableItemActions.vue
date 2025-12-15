<script setup lang="ts">
import Button from 'primevue/button'

interface Props {
  canMoveUp: boolean
  canMoveDown: boolean
  canDelete?: boolean
}

withDefaults(defineProps<Props>(), {
  canDelete: true
})

defineEmits<{
  moveUp: []
  moveDown: []
  delete: []
}>()
</script>

<template>
  <div class="reorderable-actions">
    <Button
      type="button"
      icon="pi pi-arrow-up"
      severity="secondary"
      size="small"
      text
      :disabled="!canMoveUp"
      @click="$emit('moveUp')"
    />
    <Button
      type="button"
      icon="pi pi-arrow-down"
      severity="secondary"
      size="small"
      text
      :disabled="!canMoveDown"
      @click="$emit('moveDown')"
    />
    <Button
      v-if="canDelete"
      type="button"
      icon="pi pi-trash"
      severity="danger"
      size="small"
      text
      @click="$emit('delete')"
    />
  </div>
</template>

<style scoped>
.reorderable-actions {
  display: flex;
  gap: var(--spacing-xs);
}
</style>
