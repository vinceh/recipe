<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useDataReferenceStore } from '@/stores/dataReferenceStore'
import PageHeader from '@/components/shared/PageHeader.vue'
import ErrorMessage from '@/components/shared/ErrorMessage.vue'
import RecipeForm from '@/components/admin/recipes/RecipeForm.vue'
import TextImportDialog from '@/components/admin/recipes/TextImportDialog.vue'
import UrlImportDialog from '@/components/admin/recipes/UrlImportDialog.vue'
import ViewRecipe from '@/components/shared/ViewRecipe.vue'
import Button from 'primevue/button'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail } from '@/services/types'

const router = useRouter()
const { t, locale } = useI18n()
const dataStore = useDataReferenceStore()

const formData = ref<Partial<RecipeDetail>>({})

function getDataReferenceIdByKey(key: string, referenceType: 'dietary_tag' | 'cuisine'): string | undefined {
  const refMap: Record<string, any[]> = {
    'dietary_tag': dataStore.dietaryTags,
    'cuisine': dataStore.cuisines
  }
  return refMap[referenceType]?.find(ref => ref.key === key)?.id
}

const UNIT_ALIASES: Record<string, string> = {
  'tablespoons': 'tbsp',
  'tablespoon': 'tbsp',
  'teaspoons': 'tsp',
  'teaspoon': 'tsp',
  'cups': 'cup',
  'ounces': 'oz',
  'ounce': 'oz',
  'pounds': 'lb',
  'pound': 'lb',
  'grams': 'g',
  'gram': 'g',
  'kilograms': 'kg',
  'kilogram': 'kg',
  'milligrams': 'mg',
  'milligram': 'mg',
  'milliliters': 'ml',
  'milliliter': 'ml',
  'liters': 'l',
  'liter': 'l',
  'cloves': 'clove',
  'slices': 'slice',
  'sprigs': 'sprig',
  'stalks': 'stalk',
  'pieces': 'piece',
  'leaves': 'leaf',
  'heads': 'head',
  'bunches': 'bunch',
  'cans': 'can',
  'packages': 'package',
  'packet': 'package',
  'packets': 'package',
  'servings': 'serving',
  'strips': 'strip',
  'wedges': 'wedge',
  'fillets': 'fillet',
  'handfuls': 'handful',
  'drops': 'drop',
  'pinches': 'pinch',
  'dashes': 'dash',
  'pints': 'pint',
  'quarts': 'quart',
  'gallons': 'gallon',
  'inches': 'inch',
  'sheets': 'sheet',
  'sticks': 'stick',
  'blocks': 'block',
  'pods': 'pod',
  'cubes': 'cube',
  'jars': 'jar',
  'dozens': 'dozen'
}

function normalizeUnit(unit: string | undefined): string {
  if (!unit) return ''
  const normalized = unit.toLowerCase().trim()
  return UNIT_ALIASES[normalized] || normalized
}

let instructionItemIdCounter = 1

function transformParsedRecipe(recipe: any): Partial<RecipeDetail> {
  // Transform ingredient items to match new API structure with unit normalization
  const transformedIngredientGroups = recipe.ingredient_groups?.map((group: any) => ({
    ...group,
    items: group.items?.map((item: any) => ({
      name: item.name,
      amount: item.amount,
      unit: normalizeUnit(item.unit),
      preparation: item.preparation || item.notes || '',
      optional: item.optional || false
    }))
  }))

  // Transform steps to instruction_items format (what the form expects)
  // Each step with section_heading becomes a heading item + text item
  // Steps without section_heading become just a text item
  const instructionItems: any[] = []

  recipe.steps?.forEach((step: any) => {
    const instruction = step.instruction || step.instructions?.original || step.instructions?.[recipe.language || 'en'] || ''

    // If step has a section heading, add it as a separate heading item
    if (step.section_heading) {
      instructionItems.push({
        id: `item-${instructionItemIdCounter++}`,
        item_type: 'heading',
        content: step.section_heading
      })
    }

    // Add the instruction as a text item
    if (instruction) {
      instructionItems.push({
        id: `item-${instructionItemIdCounter++}`,
        item_type: 'text',
        content: instruction
      })
    }
  })

  // Also create a steps array for the preview (ViewRecipe uses steps format)
  const transformedSteps = recipe.steps?.map((step: any, index: number) => ({
    id: step.id,
    order: index + 1,
    instruction: step.instruction || step.instructions?.original || step.instructions?.[recipe.language || 'en'] || '',
    section_heading: step.section_heading || ''
  }))

  return {
    ...recipe,
    ingredient_groups: transformedIngredientGroups,
    steps: transformedSteps,
    instruction_items: instructionItems
  }
}
const saving = ref(false)
const error = ref<Error | null>(null)
const importDialogVisible = ref(false)
const urlImportDialogVisible = ref(false)
const successMessage = ref('')
const textImportDialogRef = ref<InstanceType<typeof TextImportDialog> | null>(null)
const urlImportDialogRef = ref<InstanceType<typeof UrlImportDialog> | null>(null)
const recipeFormRef = ref<InstanceType<typeof RecipeForm> | null>(null)

function transformFormDataToBackend(data: Partial<RecipeDetail>): any {
  return {
    name: data.name,
    source_language: data.language,
    source_url: data.source_url,
    requires_precision: data.requires_precision,
    precision_reason: data.precision_reason,
    difficulty_level: data.difficulty_level,
    admin_notes: data.admin_notes,
    servings_original: data.servings?.original,
    servings_min: data.servings?.min,
    servings_max: data.servings?.max,
    prep_minutes: data.timing?.prep_minutes,
    cook_minutes: data.timing?.cook_minutes,
    total_minutes: data.timing?.total_minutes,
    recipe_aliases_attributes: data.aliases?.filter(alias => alias && alias.trim()).map(alias => ({
      alias_name: alias,
      language: data.language || 'en'
    })) || [],
    recipe_dietary_tags_attributes: data.dietary_tags?.filter(tag => tag).map(tag => {
      const id = getDataReferenceIdByKey(tag, 'dietary_tag')
      return id ? { data_reference_id: id } : null
    }).filter(Boolean) || [],
    recipe_cuisines_attributes: data.cuisines?.filter(cuisine => cuisine).map(cuisine => {
      const id = getDataReferenceIdByKey(cuisine, 'cuisine')
      return id ? { data_reference_id: id } : null
    }).filter(Boolean) || [],
    ingredient_groups_attributes: data.ingredient_groups?.filter(group => group.name?.trim()).map((group, groupIdx) => ({
      name: group.name,
      position: groupIdx + 1,
      recipe_ingredients_attributes: group.items?.filter(item => item.name?.trim()).map((item, itemIdx) => ({
        ingredient_name: item.name,
        amount: item.amount,
        unit: item.unit,
        preparation_notes: item.preparation,
        optional: item.optional,
        position: itemIdx + 1
      })) || []
    })) || [],
    recipe_steps_attributes: data.steps?.map(step => ({
      step_number: step.order,
      instruction_original: step.instruction
    })) || []
  }
}

async function handleSaveRecipe() {
  // Validate form before attempting to save
  if (!recipeFormRef.value?.validateForm()) {
    return
  }

  saving.value = true
  error.value = null

  try {
    const backendData = transformFormDataToBackend(formData.value)
    const imageFile = recipeFormRef.value.selectedImageFile

    let payload: Partial<RecipeDetail> | FormData

    if (imageFile) {
      const formDataPayload = new FormData()
      formDataPayload.append('recipe[name]', backendData.name || '')
      formDataPayload.append('recipe[source_language]', backendData.source_language || 'en')
      if (backendData.source_url) formDataPayload.append('recipe[source_url]', backendData.source_url)
      formDataPayload.append('recipe[requires_precision]', String(backendData.requires_precision || false))
      if (backendData.precision_reason) formDataPayload.append('recipe[precision_reason]', backendData.precision_reason)
      if (backendData.difficulty_level) formDataPayload.append('recipe[difficulty_level]', backendData.difficulty_level)
      if (backendData.admin_notes) formDataPayload.append('recipe[admin_notes]', backendData.admin_notes)
      formDataPayload.append('recipe[servings_original]', String(backendData.servings_original || 1))
      if (backendData.servings_min) formDataPayload.append('recipe[servings_min]', String(backendData.servings_min))
      if (backendData.servings_max) formDataPayload.append('recipe[servings_max]', String(backendData.servings_max))
      formDataPayload.append('recipe[prep_minutes]', String(backendData.prep_minutes || 0))
      formDataPayload.append('recipe[cook_minutes]', String(backendData.cook_minutes || 0))
      formDataPayload.append('recipe[total_minutes]', String(backendData.total_minutes || 0))
      formDataPayload.append('recipe[image]', imageFile)

      // Append nested attributes
      backendData.recipe_aliases_attributes?.forEach((alias: any, idx: number) => {
        formDataPayload.append(`recipe[recipe_aliases_attributes][${idx}][alias_name]`, alias.alias_name)
        formDataPayload.append(`recipe[recipe_aliases_attributes][${idx}][language]`, alias.language)
      })

      backendData.recipe_dietary_tags_attributes?.forEach((tag: any, idx: number) => {
        formDataPayload.append(`recipe[recipe_dietary_tags_attributes][${idx}][data_reference_id]`, String(tag.data_reference_id))
      })

      backendData.recipe_cuisines_attributes?.forEach((cuisine: any, idx: number) => {
        formDataPayload.append(`recipe[recipe_cuisines_attributes][${idx}][data_reference_id]`, String(cuisine.data_reference_id))
      })

      backendData.ingredient_groups_attributes?.forEach((group: any, groupIdx: number) => {
        formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][name]`, group.name)
        formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][position]`, String(group.position))
        group.recipe_ingredients_attributes?.forEach((item: any, itemIdx: number) => {
          formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][recipe_ingredients_attributes][${itemIdx}][ingredient_name]`, item.ingredient_name)
          if (item.amount) formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][recipe_ingredients_attributes][${itemIdx}][amount]`, item.amount)
          if (item.unit) formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][recipe_ingredients_attributes][${itemIdx}][unit]`, item.unit)
          if (item.preparation_notes) formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][recipe_ingredients_attributes][${itemIdx}][preparation_notes]`, item.preparation_notes)
          formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][recipe_ingredients_attributes][${itemIdx}][optional]`, String(item.optional))
          formDataPayload.append(`recipe[ingredient_groups_attributes][${groupIdx}][recipe_ingredients_attributes][${itemIdx}][position]`, String(item.position))
        })
      })

      backendData.recipe_steps_attributes?.forEach((step: any, idx: number) => {
        formDataPayload.append(`recipe[recipe_steps_attributes][${idx}][step_number]`, String(step.step_number))
        formDataPayload.append(`recipe[recipe_steps_attributes][${idx}][instruction_original]`, step.instruction_original)
      })

      payload = formDataPayload
    } else {
      payload = backendData
    }

    const response = await adminApi.createRecipe(payload)

    if (response.success && response.data) {
      router.push({ name: 'admin-recipe-detail', params: { id: response.data.recipe.id } })
    } else {
      throw new Error(response.message || 'Failed to create recipe')
    }
  } catch (e) {
    error.value = e instanceof Error ? e : new Error('Failed to save recipe')
  } finally {
    saving.value = false
  }
}

function handleCancelRecipe() {
  router.push({ name: 'admin-recipes' })
}

function openImportDialog() {
  importDialogVisible.value = true
  successMessage.value = ''
  error.value = null
}

function openUrlImportDialog() {
  urlImportDialogVisible.value = true
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

      // Set the form data with transformation
      const parsedRecipe = (response.data as any).recipe_data
      formData.value = transformParsedRecipe(parsedRecipe)

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

async function handleImportUrl(url: string) {
  if (!urlImportDialogRef.value) return

  urlImportDialogRef.value.setLoading(true)
  error.value = null

  try {
    const response = await adminApi.parseUrl({ url })

    if (response.success && response.data) {
      urlImportDialogVisible.value = false
      urlImportDialogRef.value.resetDialog()

      await nextTick()

      const parsedRecipe = (response.data as any).recipe_data
      formData.value = transformParsedRecipe(parsedRecipe)

      successMessage.value = t('admin.recipes.urlImportDialog.success')
      setTimeout(() => {
        successMessage.value = ''
      }, 5000)
    } else {
      throw new Error(response.message || 'Parse failed')
    }
  } catch (e) {
    console.error('URL import error:', e)

    let errorMessage = 'Failed to parse recipe from URL'

    // Extract error message from axios error response
    if (e && typeof e === 'object' && 'response' in e) {
      const axiosError = e as any
      if (axiosError.response?.data?.message) {
        errorMessage = axiosError.response.data.message
      }
    } else if (e instanceof Error) {
      errorMessage = e.message
    }

    // Handle web search errors
    if (errorMessage.includes('Could not access') || errorMessage.includes('Cannot access') || errorMessage.includes('403') || errorMessage.includes('404')) {
      urlImportDialogRef.value.setError(t('admin.recipes.urlImportDialog.errors.cannotAccess'))
    } else if (errorMessage.includes('Could not find') || errorMessage.includes('No recipe') || errorMessage.includes('not find')) {
      urlImportDialogRef.value.setError(t('admin.recipes.urlImportDialog.errors.noRecipe'))
    } else if (errorMessage.includes('timeout') || errorMessage.includes('Timeout')) {
      urlImportDialogRef.value.setError(t('admin.recipes.urlImportDialog.errors.timeout'))
    } else if (errorMessage.includes('service') || errorMessage.includes('unavailable') || errorMessage.includes('503')) {
      urlImportDialogRef.value.setError(t('admin.recipes.urlImportDialog.errors.aiUnavailable'))
    } else if (errorMessage.includes('network') || errorMessage.includes('connection')) {
      urlImportDialogRef.value.setError(t('admin.recipes.urlImportDialog.errors.networkError'))
    } else {
      urlImportDialogRef.value.setError(t('admin.recipes.urlImportDialog.errors.generic'))
    }
  }
}

function handleSwitchToText(url: string) {
  urlImportDialogVisible.value = false
  importDialogVisible.value = true
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
      <div class="form-column">
        <div class="form-panel">
          <RecipeForm
            ref="recipeFormRef"
            v-model="formData"
            @import-text="openImportDialog"
            @import-url="openUrlImportDialog"
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

    <!-- Import Dialogs -->
    <TextImportDialog
      ref="textImportDialogRef"
      v-model:visible="importDialogVisible"
      @import="handleImportText"
    />

    <UrlImportDialog
      ref="urlImportDialogRef"
      v-model:visible="urlImportDialogVisible"
      @import="handleImportUrl"
      @switch-to-text="handleSwitchToText"
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
  background-color: var(--color-success-light);
  color: var(--color-success-dark);
  border: 1px solid var(--color-success);
  border-radius: var(--border-radius-md);
  font-size: var(--font-size-md);
}

.success-message i {
  font-size: var(--font-size-lg);
}

.split-panel-container {
  display: grid;
  grid-template-columns: 1fr 600px;
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
