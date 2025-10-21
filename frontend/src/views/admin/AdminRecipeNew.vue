<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import PageHeader from '@/components/shared/PageHeader.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import RecipeForm from '@/components/admin/recipes/RecipeForm.vue'
import TextImportDialog from '@/components/admin/recipes/TextImportDialog.vue'
import ViewRecipe from '@/components/shared/ViewRecipe.vue'
import Button from 'primevue/button'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail } from '@/services/types'

const router = useRouter()
const { t } = useI18n()

const formData = ref<Partial<RecipeDetail>>({})
const saving = ref(false)
const error = ref<Error | null>(null)
const importDialogVisible = ref(false)
const successMessage = ref('')
const textImportDialogRef = ref<InstanceType<typeof TextImportDialog> | null>(null)

async function handleSaveRecipe() {
  saving.value = true
  error.value = null

  try {
    console.log('Sending recipe data to backend:', JSON.stringify(formData.value, null, 2))
    const response = await adminApi.createRecipe(formData.value as any)
    console.log('Backend response:', response)
    if (response.success && response.data) {
      router.push(`/admin/recipes/${response.data.recipe.id}`)
    } else {
      throw new Error(response.message || 'Failed to create recipe')
    }
  } catch (e) {
    console.error('Save error:', e)
    error.value = e instanceof Error ? e : new Error('Failed to save recipe')
  } finally {
    saving.value = false
  }
}

function handleCancelRecipe() {
  router.push('/admin/recipes')
}

function openImportDialog() {
  importDialogVisible.value = true
  successMessage.value = ''
  error.value = null
}

async function handleImportText(text: string) {
  if (!textImportDialogRef.value) return

  textImportDialogRef.value.setLoading(true)
  error.value = null

  try {
    const response = await adminApi.parseText({ text_content: text })

    if (response.success && response.data) {
      // Close dialog first
      importDialogVisible.value = false
      textImportDialogRef.value.resetDialog()

      // Wait for dialog to close before updating form data
      await nextTick()

      // Set the form data
      formData.value = (response.data as any).recipe_data as Partial<RecipeDetail>

      successMessage.value = t('admin.recipes.importDialog.success')
      setTimeout(() => {
        successMessage.value = ''
      }, 5000)
    } else {
      throw new Error(response.message || 'Parse failed')
    }
  } catch (e) {
    console.error('Import error:', e)
    const errorMessage = e instanceof Error ? e.message : 'Failed to parse recipe'

    if (errorMessage.includes('service') || errorMessage.includes('unavailable')) {
      textImportDialogRef.value.setError(t('admin.recipes.importDialog.errors.serviceUnavailable'))
    } else if (errorMessage.includes('parse') || errorMessage.includes('extract')) {
      textImportDialogRef.value.setError(t('admin.recipes.importDialog.errors.parseFailed'))
    } else {
      textImportDialogRef.value.setError(t('admin.recipes.importDialog.errors.generic'))
    }
  }
}
</script>

<template>
  <div class="admin-recipe-new">
    <PageHeader
      :title="$t('admin.recipes.new.title')"
      :subtitle="$t('admin.recipes.new.subtitle')"
    >
      <template #actions>
        <button class="btn btn-outline btn-sm" @click="handleCancelRecipe">
          <i class="pi pi-arrow-left"></i>
          {{ $t('common.buttons.back') }}
        </button>
      </template>
    </PageHeader>

    <!-- Success Message -->
    <div v-if="successMessage" class="success-message">
      <i class="pi pi-check-circle"></i>
      {{ successMessage }}
    </div>

    <!-- Error state -->
    <ErrorMessage v-if="error" :error="error" />

    <!-- Split Panel Layout -->
    <div class="split-panel-container">
      <div class="form-panel">
        <RecipeForm
          v-model="formData"
          :loading="saving"
          @save="handleSaveRecipe"
          @cancel="handleCancelRecipe"
          @import-text="openImportDialog"
        />
      </div>

      <div class="preview-panel">
        <div class="preview-header">
          <i class="pi pi-eye"></i>
          <h3>Preview</h3>
        </div>
        <div class="preview-content">
          <ViewRecipe :recipe="formData" />
        </div>
      </div>
    </div>

    <!-- Import Dialog -->
    <TextImportDialog
      ref="textImportDialogRef"
      v-model:visible="importDialogVisible"
      @import="handleImportText"
    />
  </div>
</template>

<style>
.admin-recipe-new {
  margin: calc(var(--spacing-xl) * -1);
  padding: var(--spacing-xl);
  max-width: none !important;
  width: calc(100% + calc(var(--spacing-xl) * 2));
  height: calc(100vh - 64px);
  display: flex;
  flex-direction: column;
}
</style>

<style scoped>

.success-message {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-md);
  margin: 0 var(--spacing-lg) var(--spacing-lg) var(--spacing-lg);
  background-color: #d1f4e0;
  color: #0d894f;
  border: 1px solid #a3e4c1;
  border-radius: var(--border-radius-md);
  font-size: var(--font-size-md);
}

.success-message i {
  font-size: var(--font-size-lg);
}

.split-panel-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-lg);
  padding: 0 var(--spacing-lg) var(--spacing-lg) var(--spacing-lg);
  flex: 1;
  overflow: hidden;
}

.form-panel {
  background: white;
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
  overflow-y: auto;
  border: 1px solid var(--color-border);
}

.preview-panel {
  background: white;
  border-radius: var(--border-radius-lg);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid var(--color-border);
}

.preview-header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding: var(--spacing-md) var(--spacing-lg);
  background: var(--color-gray-100);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.preview-header i {
  color: var(--color-primary);
  font-size: var(--font-size-lg);
}

.preview-header h3 {
  margin: 0;
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.preview-content {
  flex: 1;
  overflow-y: auto;
}

@media (max-width: 1024px) {
  .split-panel-container {
    grid-template-columns: 1fr;
    overflow: visible;
  }

  .form-panel,
  .preview-panel {
    overflow: visible;
  }

  .preview-content {
    overflow: visible;
  }
}
</style>
