<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import PageHeader from '@/components/shared/PageHeader.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import RecipeForm from '@/components/admin/recipes/RecipeForm.vue'
import RecipeImportModal from '@/components/admin/recipes/RecipeImportModal.vue'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail } from '@/services/types'

const router = useRouter()

const formData = ref<Partial<RecipeDetail>>({})
const saving = ref(false)
const error = ref<Error | null>(null)
const showImportModal = ref(false)

async function handleSaveRecipe() {
  saving.value = true
  error.value = null

  try {
    console.log('Sending recipe data to backend:', JSON.stringify(formData.value, null, 2))
    const response = await adminApi.createRecipe(formData.value as any)
    console.log('Backend response:', response)
    if (response.success && response.data) {
      // Redirect to the new recipe's detail page
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

function handleImportRecipe(recipeData: Partial<RecipeDetail>) {
  formData.value = recipeData
  console.log('Recipe imported:', recipeData)
}

function openImportModal() {
  showImportModal.value = true
}

function closeImportModal() {
  showImportModal.value = false
}
</script>

<template>
  <div class="admin-recipe-new">
    <PageHeader
      :title="$t('admin.recipes.new.title')"
      :subtitle="$t('admin.recipes.new.subtitle')"
    >
      <template #actions>
        <button class="btn btn-primary btn-sm" @click="openImportModal">
          <i class="pi pi-sparkles"></i>
          {{ $t('admin.recipes.import.importButton') }}
        </button>
        <button class="btn btn-outline btn-sm" @click="handleCancelRecipe">
          <i class="pi pi-arrow-left"></i>
          {{ $t('common.buttons.back') }}
        </button>
      </template>
    </PageHeader>

    <!-- Error state -->
    <ErrorMessage v-if="error" :error="error" />

    <!-- Recipe Form -->
    <div class="recipe-form-container">
      <RecipeForm
        v-model="formData"
        :loading="saving"
        @save="handleSaveRecipe"
        @cancel="handleCancelRecipe"
      />
    </div>

    <!-- Import Modal -->
    <RecipeImportModal
      :is-open="showImportModal"
      @close="closeImportModal"
      @import="handleImportRecipe"
    />
  </div>
</template>

<style scoped>
.admin-recipe-new {
  width: 100%;
  padding: var(--spacing-lg);
}

.recipe-form-container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: var(--spacing-xl);
}
</style>
