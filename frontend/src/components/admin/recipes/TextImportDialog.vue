<script setup lang="ts">
import { ref, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import Dialog from 'primevue/dialog'
import Textarea from 'primevue/textarea'
import Button from 'primevue/button'

interface Props {
  visible: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
  'update:visible': [value: boolean]
  'import': [text: string]
}>()

const { t } = useI18n()

const recipeText = ref('')
const loading = ref(false)
const error = ref('')

const isTextEmpty = computed(() => {
  return !recipeText.value || recipeText.value.trim().length === 0
})

function handleCancel() {
  resetDialog()
  emit('update:visible', false)
}

function handleImport() {
  if (isTextEmpty.value) {
    error.value = t('admin.recipes.importDialog.errors.empty')
    return
  }

  if (recipeText.value.trim().length < 50) {
    error.value = t('admin.recipes.importDialog.errors.tooShort')
    return
  }

  error.value = ''
  emit('import', recipeText.value.trim())
}

function handleClose(value: boolean) {
  if (!value && !loading.value) {
    resetDialog()
    emit('update:visible', false)
  }
}

function resetDialog() {
  recipeText.value = ''
  error.value = ''
  loading.value = false
}

function setLoading(value: boolean) {
  loading.value = value
}

function setError(message: string) {
  error.value = message
  loading.value = false
}

defineExpose({
  setLoading,
  setError,
  resetDialog
})
</script>

<template>
  <Dialog
    :visible="visible"
    :modal="true"
    :closable="!loading"
    :draggable="false"
    :dismissableMask="!loading"
    class="text-import-dialog"
    @update:visible="handleClose"
  >
    <template #header>
      <div class="dialog-header">
        <i class="pi pi-file-import dialog-header__icon"></i>
        <h3 class="dialog-header__title">{{ $t('admin.recipes.importDialog.title') }}</h3>
      </div>
    </template>

    <div class="dialog-content">
      <Textarea
        v-model="recipeText"
        :placeholder="$t('admin.recipes.importDialog.placeholder')"
        :disabled="loading"
        :autoResize="false"
        rows="15"
        class="recipe-textarea"
        :class="{ 'p-invalid': error }"
      />

      <small v-if="error" class="error-message">
        <i class="pi pi-exclamation-circle"></i>
        {{ error }}
      </small>

      <div v-if="loading" class="loading-message">
        <i class="pi pi-spin pi-spinner"></i>
        {{ $t('admin.recipes.importDialog.parsing') }}
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <Button
          :label="$t('admin.recipes.importDialog.cancel')"
          severity="secondary"
          outlined
          :disabled="loading"
          @click="handleCancel"
        />
        <Button
          :label="$t('admin.recipes.importDialog.import')"
          icon="pi pi-download"
          :loading="loading"
          :disabled="isTextEmpty"
          @click="handleImport"
        />
      </div>
    </template>
  </Dialog>
</template>

<style>
/* Global styles for PrimeVue Dialog (rendered via portal, scoped won't work) */
.p-dialog.text-import-dialog {
  width: 700px;
  max-width: 90vw;
}
</style>

<style scoped>
.dialog-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.dialog-header__icon {
  font-size: var(--font-size-xl);
  color: var(--color-primary);
}

.dialog-header__title {
  margin: 0;
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.dialog-content {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-md);
  padding: var(--spacing-md) 0;
}

.recipe-textarea {
  width: 100%;
  font-family: 'Courier New', monospace;
  font-size: var(--font-size-sm);
  line-height: 1.5;
  min-height: 400px;
}

.recipe-textarea.p-invalid {
  border-color: var(--color-error);
}

.error-message {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  color: var(--color-error);
  font-size: var(--font-size-sm);
  margin-top: calc(var(--spacing-sm) * -1);
}

.error-message i {
  font-size: var(--font-size-md);
}

.loading-message {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  color: var(--color-text-inverse);
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-medium);
  padding: var(--spacing-md);
  background: var(--color-primary);
  border-radius: var(--border-radius-md);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.loading-message i {
  font-size: var(--font-size-lg);
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-sm);
  padding-top: var(--spacing-md);
}

:deep(.p-dialog) {
  border-radius: var(--border-radius-lg);
}

:deep(.p-dialog-header) {
  padding: var(--spacing-lg);
  border-bottom: var(--border-width) solid var(--color-border);
}

:deep(.p-dialog-content) {
  padding: var(--spacing-lg);
}

:deep(.p-dialog-footer) {
  padding: var(--spacing-lg);
  border-top: var(--border-width) solid var(--color-border);
}
</style>
