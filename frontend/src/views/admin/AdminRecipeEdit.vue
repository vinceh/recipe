<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useDataReferenceStore, useUiStore } from '@/stores'
import { useRecipeSave } from '@/composables/useRecipeSave'
import PageHeader from '@/components/shared/PageHeader.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import RecipeForm from '@/components/admin/recipes/RecipeForm.vue'
import ViewRecipe from '@/components/shared/ViewRecipe.vue'
import Button from 'primevue/button'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail } from '@/services/types'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const dataStore = useDataReferenceStore()
const uiStore = useUiStore()
const { saving, error: saveError, saveRecipe } = useRecipeSave()

const recipeId = computed(() => route.params.id as string)
const formData = ref<Partial<RecipeDetail>>({})
const loading = ref(true)
const error = ref<Error | null>(null)
const recipeFormRef = ref<InstanceType<typeof RecipeForm> | null>(null)

async function fetchRecipe() {
  loading.value = true
  error.value = null

  try {
    const [recipeResponse] = await Promise.all([
      adminApi.getRecipe(recipeId.value, uiStore.language),
      dataStore.fetchAll()
    ])

    if (recipeResponse.success && recipeResponse.data) {
      formData.value = recipeResponse.data.recipe
    }
  } catch (e) {
    error.value = e instanceof Error ? e : new Error('Failed to fetch recipe')
  } finally {
    loading.value = false
  }
}

async function handleSaveRecipe() {
  if (!recipeFormRef.value?.validateForm()) {
    return
  }

  const imageFile = recipeFormRef.value.selectedImageFile
  const result = await saveRecipe(recipeId.value, formData.value, imageFile)

  if (result.success) {
    router.push({ name: 'admin-recipe-detail', params: { id: recipeId.value } })
  } else if (result.error) {
    error.value = result.error
  }
}

function handleCancel() {
  router.push({ name: 'admin-recipe-detail', params: { id: recipeId.value } })
}

onMounted(() => {
  fetchRecipe()
})
</script>

<template>
  <div class="admin-recipe-edit">
    <PageHeader
      :title="formData.name || $t('common.buttons.edit')"
      :subtitle="$t('admin.recipes.detail.subtitle')"
    >
      <template #actions>
        <button class="btn btn-outline btn-sm" @click="handleCancel">
          <i class="pi pi-arrow-left"></i>
          {{ $t('common.buttons.back') }}
        </button>
      </template>
    </PageHeader>

    <div v-if="loading" class="loading-state">
      <i class="pi pi-spinner pi-spin"></i>
      <p>{{ $t('common.messages.loading') }}</p>
    </div>

    <ErrorMessage v-else-if="error" :error="error" />

    <template v-else>
      <div class="split-panel-container">
        <div class="form-column">
          <div class="form-panel">
            <RecipeForm
              ref="recipeFormRef"
              v-model="formData"
            />
          </div>
          <div class="form-actions">
            <Button
              type="button"
              :label="$t('common.buttons.save')"
              severity="success"
              :loading="saving"
              :disabled="saving || !(recipeFormRef?.isValid)"
              @click="handleSaveRecipe"
              class="form-actions__button"
            />
          </div>
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
    </template>
  </div>
</template>

<style>
.admin-recipe-edit {
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
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-2xl);
  color: var(--color-text-secondary);
}

.loading-state i {
  font-size: 2rem;
  margin-bottom: var(--spacing-md);
}

.split-panel-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-lg);
  padding: 0 var(--spacing-lg) var(--spacing-lg) var(--spacing-lg);
  flex: 1;
  overflow: hidden;
}

.form-column {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
  height: 100%;
  min-height: 0;
}

.form-panel {
  background: white;
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-xl);
  overflow-y: auto;
  border: 1px solid var(--color-border);
  flex: 1;
  min-height: 0;
}

.form-actions {
  display: flex;
  gap: var(--spacing-md);
  padding: var(--spacing-lg);
  background: white;
  border-radius: var(--border-radius-lg);
  border: 1px solid var(--color-border);
  flex-shrink: 0;
}

.form-actions__button {
  width: 100%;
  min-height: 44px;
}

.preview-panel {
  background: white;
  border-radius: var(--border-radius-lg);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid var(--color-border);
  height: 100%;
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
  min-height: 0;
}

@media (max-width: 1024px) {
  .split-panel-container {
    grid-template-columns: 1fr;
    overflow: visible;
  }

  .form-column {
    gap: var(--spacing-md);
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
