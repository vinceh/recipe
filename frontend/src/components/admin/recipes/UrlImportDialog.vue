<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import Button from 'primevue/button'
import PlayfulLoadingSpinner from '@/components/shared/PlayfulLoadingSpinner.vue'

interface Props {
  visible: boolean
}

interface Emits {
  (e: 'update:visible', value: boolean): void
  (e: 'import', url: string): void
  (e: 'switch-to-text', url: string): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const { t } = useI18n()

const url = ref('')
const loading = ref(false)
const error = ref('')

const isValidUrl = computed(() => {
  if (!url.value.trim()) return false
  try {
    const urlObj = new URL(url.value)
    return urlObj.protocol === 'http:' || urlObj.protocol === 'https:'
  } catch {
    return false
  }
})

const canImport = computed(() => {
  return url.value.trim().length > 0 && isValidUrl.value && !loading.value
})

watch(() => props.visible, (newVisible) => {
  if (!newVisible) {
    resetDialog()
  }
})

function handleImport() {
  if (!canImport.value) {
    if (!url.value.trim()) {
      error.value = t('admin.recipes.urlImportDialog.errors.required')
    } else if (!isValidUrl.value) {
      error.value = t('admin.recipes.urlImportDialog.errors.invalidUrl')
    }
    return
  }

  error.value = ''
  emit('import', url.value.trim())
}

function handleCancel() {
  emit('update:visible', false)
}

function handleSwitchToText() {
  emit('switch-to-text', url.value.trim())
  emit('update:visible', false)
}

function setLoading(value: boolean) {
  loading.value = value
}

function setError(message: string) {
  error.value = message
  loading.value = false
}

function resetDialog() {
  url.value = ''
  error.value = ''
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
    :header="$t('admin.recipes.urlImportDialog.title')"
    :modal="true"
    :closable="!loading"
    :close-on-escape="!loading"
    :dismissable-mask="!loading"
    class="url-import-dialog"
    @update:visible="emit('update:visible', $event)"
  >
    <div class="url-import-dialog__content">
      <p class="url-import-dialog__description">
        {{ $t('admin.recipes.urlImportDialog.description') }}
      </p>

      <div class="url-import-dialog__form">
        <InputText
          id="url-input"
          v-model="url"
          type="url"
          :placeholder="$t('admin.recipes.urlImportDialog.placeholder')"
          class="url-import-dialog__input"
          :disabled="loading"
          :class="{ 'p-invalid': error && url.trim().length > 0 }"
          @keyup.enter="handleImport"
        />

        <small v-if="url.trim().length > 0 && !isValidUrl" class="p-error">
          {{ $t('admin.recipes.urlImportDialog.errors.invalidUrl') }}
        </small>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="url-import-dialog__error">
        <i class="pi pi-exclamation-triangle"></i>
        <span>{{ error }}</span>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="url-import-dialog__loading">
        <PlayfulLoadingSpinner
          size="md"
          :label="$t('admin.recipes.urlImportDialog.importing')"
        />
      </div>
    </div>

    <template #footer>
      <div class="url-import-dialog__footer">
        <div class="url-import-dialog__footer-left">
          <Button
            v-if="error && url.trim().length > 0 && !loading"
            :label="$t('admin.recipes.urlImportDialog.switchToText')"
            icon="pi pi-file-import"
            severity="secondary"
            text
            @click="handleSwitchToText"
          />
        </div>
        <div class="url-import-dialog__footer-right">
          <Button
            :label="$t('admin.recipes.urlImportDialog.cancel')"
            severity="secondary"
            outlined
            :disabled="loading"
            @click="handleCancel"
          />
          <Button
            :label="$t('admin.recipes.urlImportDialog.import')"
            icon="pi pi-download"
            :disabled="!canImport || loading"
            @click="handleImport"
          />
        </div>
      </div>
    </template>
  </Dialog>
</template>

<style scoped>
.url-import-dialog__content {
  margin-top: var(--spacing-lg);
  padding: 0;
  padding-bottom: var(--spacing-lg);
}

.url-import-dialog__loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  margin-top: var(--spacing-md);
  background-color: var(--color-primary-light, #f0f7ff);
  border: 1px solid var(--color-primary);
  border-radius: var(--border-radius-md);
  min-height: auto;
}

.url-import-dialog__description {
  margin: 0 0 var(--spacing-lg) 0;
  color: var(--color-text-secondary);
  font-size: var(--font-size-md);
}

.url-import-dialog__form {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm);
}

.url-import-dialog__label {
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-md);
  color: var(--color-text-primary);
}

.url-import-dialog__input {
  width: 100%;
  font-size: var(--font-size-md);
}

.url-import-dialog__error {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  margin-top: var(--spacing-md);
  background-color: var(--color-error-light, #fee);
  color: var(--color-error, #c00);
  border: 1px solid var(--color-error, #c00);
  border-radius: var(--border-radius-md);
  font-size: var(--font-size-sm);
}

.url-import-dialog__error i {
  font-size: var(--font-size-lg);
}

.url-import-dialog__footer {
  margin-top: var(--spacing-md);
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.url-import-dialog__footer-left {
  flex: 1;
}

.url-import-dialog__footer-right {
  display: flex;
  gap: var(--spacing-sm);
}

:deep(.p-dialog) {
  width: 90vw;
  max-width: 600px;
}

@media (max-width: 768px) {
  :deep(.p-dialog) {
    width: 95vw;
  }

  .url-import-dialog__footer {
    flex-direction: column;
    gap: var(--spacing-sm);
  }

  .url-import-dialog__footer-left,
  .url-import-dialog__footer-right {
    width: 100%;
  }

  .url-import-dialog__footer-right {
    flex-direction: column;
  }
}
</style>
