import { ref } from 'vue'
import { useDataReferenceStore } from '@/stores'
import { adminApi } from '@/services/adminApi'
import type { RecipeDetail } from '@/services/types'

export function useRecipeSave() {
  const dataStore = useDataReferenceStore()
  const saving = ref(false)
  const error = ref<Error | null>(null)

  function getDataReferenceIdByKey(key: string, referenceType: 'dietary_tag' | 'cuisine'): string | undefined {
    const refMap: Record<string, any[]> = {
      'dietary_tag': dataStore.dietaryTags,
      'cuisine': dataStore.cuisines
    }
    return refMap[referenceType]?.find(ref => ref.key === key)?.id
  }

  function transformFormDataToBackend(data: Partial<RecipeDetail>): any {
    return {
      name: data.name,
      source_language: data.language,
      source_url: data.source_url,
      requires_precision: data.requires_precision,
      precision_reason: data.precision_reason,
      difficulty_level: data.difficulty_level,
      admin_notes: data.admin_notes,
      tags: data.tags || [],
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
      })) || [],
      instruction_items_attributes: data.instruction_items?.filter(item => !item._destroy || item.id).map((item, idx) => ({
        id: item.id,
        item_type: item.item_type,
        position: idx + 1,
        content: item.item_type !== 'image' ? item.content : undefined,
        _destroy: item._destroy
      })) || []
    }
  }

  function buildFormDataPayload(backendData: any, imageFile?: File | null): FormData {
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

    if (backendData.tags?.length) {
      backendData.tags.forEach((tag: string, idx: number) => {
        formDataPayload.append(`recipe[tags][]`, tag)
      })
    }

    if (imageFile) {
      formDataPayload.append('recipe[image]', imageFile)
    }

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

    return formDataPayload
  }

  function buildFormDataPayloadWithInstructionItems(
    backendData: any,
    originalData: Partial<RecipeDetail>,
    imageFile?: File | null
  ): FormData {
    const formDataPayload = buildFormDataPayload(backendData, imageFile)

    const activeItems = originalData.instruction_items?.filter(item => !item._destroy) || []
    activeItems.forEach((item, idx) => {
      const prefix = `recipe[instruction_items_attributes][${idx}]`
      if (item.id) {
        formDataPayload.append(`${prefix}[id]`, String(item.id))
      }
      formDataPayload.append(`${prefix}[item_type]`, item.item_type)
      formDataPayload.append(`${prefix}[position]`, String(idx + 1))
      if (item.item_type !== 'image' && item.content) {
        formDataPayload.append(`${prefix}[content]`, item.content)
      }
      if (item.item_type === 'image' && item.image_file) {
        formDataPayload.append(`${prefix}[image]`, item.image_file)
      }
    })

    // Handle deleted items
    const deletedItems = originalData.instruction_items?.filter(item => item._destroy && item.id) || []
    deletedItems.forEach((item, idx) => {
      const deleteIdx = activeItems.length + idx
      const prefix = `recipe[instruction_items_attributes][${deleteIdx}]`
      formDataPayload.append(`${prefix}[id]`, String(item.id))
      formDataPayload.append(`${prefix}[_destroy]`, 'true')
    })

    return formDataPayload
  }

  async function saveRecipe(
    recipeId: string,
    formData: Partial<RecipeDetail>,
    imageFile?: File | null
  ): Promise<{ success: boolean; data?: RecipeDetail; error?: Error }> {
    saving.value = true
    error.value = null

    try {
      const backendData = transformFormDataToBackend(formData)

      // Check if any instruction items have image files that need uploading
      const hasInstructionImages = formData.instruction_items?.some(
        item => item.item_type === 'image' && item.image_file
      )

      let payload: any
      if (imageFile || hasInstructionImages) {
        // Use FormData when we have any file uploads
        payload = buildFormDataPayloadWithInstructionItems(backendData, formData, imageFile)
      } else if (formData.instruction_items?.length) {
        // Use FormData for instruction items even without images (for consistency)
        payload = buildFormDataPayloadWithInstructionItems(backendData, formData, null)
      } else {
        payload = backendData
      }

      const response = await adminApi.updateRecipe(recipeId, payload)

      if (response.success && response.data) {
        return { success: true, data: response.data.recipe }
      } else {
        const err = new Error(response.message || 'Failed to update recipe')
        error.value = err
        return { success: false, error: err }
      }
    } catch (e) {
      const err = e instanceof Error ? e : new Error('Failed to save recipe')
      error.value = err
      return { success: false, error: err }
    } finally {
      saving.value = false
    }
  }

  return {
    saving,
    error,
    saveRecipe,
    transformFormDataToBackend,
    buildFormDataPayload,
    buildFormDataPayloadWithInstructionItems
  }
}
