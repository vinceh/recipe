import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { adminApi } from '@/services/adminApi'
import type {
  RecipeDetail,
  DataReference,
  AiPrompt,
  Ingredient,
  ParseTextPayload,
  ParseUrlPayload,
  CheckDuplicatesPayload,
  PaginationMeta
} from '@/services/types'

export const useAdminStore = defineStore('admin', () => {
  // State
  const recipes = ref<RecipeDetail[]>([])
  const currentRecipe = ref<RecipeDetail | null>(null)
  const dataReferences = ref<DataReference[]>([])
  const aiPrompts = ref<AiPrompt[]>([])
  const ingredients = ref<Ingredient[]>([])
  const duplicateRecipes = ref<RecipeDetail[]>([])

  const recipesPagination = ref<PaginationMeta>({
    current_page: 1,
    per_page: 20,
    total_count: 0,
    total_pages: 0
  })

  const ingredientsPagination = ref<PaginationMeta>({
    current_page: 1,
    per_page: 50,
    total_count: 0,
    total_pages: 0
  })

  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const activePrompts = computed(() => aiPrompts.value.filter(p => p.active))
  const activeDataReferences = computed(() => dataReferences.value.filter(d => d.active))
  const hasDuplicates = computed(() => duplicateRecipes.value.length > 0)

  const getPromptByType = computed(() => (type: string) => {
    return aiPrompts.value.filter(p => p.prompt_type === type)
  })

  const getDataReferencesByType = computed(() => (type: string) => {
    return dataReferences.value.filter(d => d.reference_type === type)
  })

  // Recipe Actions
  async function fetchRecipes(params: any = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.getRecipes(params)

      if (response.success && response.data) {
        recipes.value = response.data.recipes
        recipesPagination.value = response.data.pagination
      } else {
        throw new Error(response.message || 'Failed to fetch recipes')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch recipes'
      console.error('Error fetching recipes:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchRecipe(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.getRecipe(id)

      if (response.success && response.data) {
        currentRecipe.value = response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to fetch recipe')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch recipe'
      console.error('Error fetching recipe:', err)
    } finally {
      loading.value = false
    }
  }

  async function createRecipe(recipe: Partial<RecipeDetail>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.createRecipe(recipe)

      if (response.success && response.data) {
        recipes.value.unshift(response.data.recipe)
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to create recipe')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to create recipe'
      console.error('Error creating recipe:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateRecipe(id: number, recipe: Partial<RecipeDetail>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.updateRecipe(id, recipe)

      if (response.success && response.data) {
        const index = recipes.value.findIndex(r => r.id === id)
        if (index !== -1) {
          recipes.value[index] = response.data.recipe
        }
        if (currentRecipe.value?.id === id) {
          currentRecipe.value = response.data.recipe
        }
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to update recipe')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to update recipe'
      console.error('Error updating recipe:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteRecipe(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.deleteRecipe(id)

      if (response.success) {
        recipes.value = recipes.value.filter(r => r.id !== id)
        if (currentRecipe.value?.id === id) {
          currentRecipe.value = null
        }
      } else {
        throw new Error(response.message || 'Failed to delete recipe')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to delete recipe'
      console.error('Error deleting recipe:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function bulkDeleteRecipes(ids: number[]) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.bulkDeleteRecipes(ids)

      if (response.success) {
        recipes.value = recipes.value.filter(r => !ids.includes(Number(r.id)))
        return response.data.deleted_count
      } else {
        throw new Error(response.message || 'Failed to delete recipes')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to delete recipes'
      console.error('Error deleting recipes:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function parseText(payload: ParseTextPayload) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.parseText(payload)

      if (response.success && response.data) {
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to parse text')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to parse text'
      console.error('Error parsing text:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function parseUrl(payload: ParseUrlPayload) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.parseUrl(payload)

      if (response.success && response.data) {
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to parse URL')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to parse URL'
      console.error('Error parsing URL:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function parseImage(formData: FormData) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.parseImage(formData)

      if (response.success && response.data) {
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to parse image')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to parse image'
      console.error('Error parsing image:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function checkDuplicates(payload: CheckDuplicatesPayload) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.checkDuplicates(payload)

      if (response.success && response.data) {
        duplicateRecipes.value = response.data.duplicates
        return response.data.duplicates
      } else {
        throw new Error(response.message || 'Failed to check duplicates')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to check duplicates'
      console.error('Error checking duplicates:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function regenerateVariants(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.regenerateVariants(id)

      if (response.success && response.data) {
        if (currentRecipe.value?.id === id) {
          currentRecipe.value = response.data.recipe
        }
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to regenerate variants')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to regenerate variants'
      console.error('Error regenerating variants:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function regenerateTranslations(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.regenerateTranslations(id)

      if (response.success && response.data) {
        if (currentRecipe.value?.id === id) {
          currentRecipe.value = response.data.recipe
        }
        return response.data.recipe
      } else {
        throw new Error(response.message || 'Failed to regenerate translations')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to regenerate translations'
      console.error('Error regenerating translations:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  // Data Reference Actions
  async function fetchDataReferences(params: any = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.getDataReferences(params)

      if (response.success && response.data) {
        dataReferences.value = response.data.data_references
      } else {
        throw new Error(response.message || 'Failed to fetch data references')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch data references'
      console.error('Error fetching data references:', err)
    } finally {
      loading.value = false
    }
  }

  async function createDataReference(dataRef: Partial<DataReference>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.createDataReference(dataRef)

      if (response.success && response.data) {
        dataReferences.value.push(response.data.data_reference)
        return response.data.data_reference
      } else {
        throw new Error(response.message || 'Failed to create data reference')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to create data reference'
      console.error('Error creating data reference:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateDataReference(id: number, dataRef: Partial<DataReference>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.updateDataReference(id, dataRef)

      if (response.success && response.data) {
        const index = dataReferences.value.findIndex(d => d.id === id)
        if (index !== -1) {
          dataReferences.value[index] = response.data.data_reference
        }
        return response.data.data_reference
      } else {
        throw new Error(response.message || 'Failed to update data reference')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to update data reference'
      console.error('Error updating data reference:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteDataReference(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.deleteDataReference(id)

      if (response.success) {
        dataReferences.value = dataReferences.value.filter(d => d.id !== id)
      } else {
        throw new Error(response.message || 'Failed to delete data reference')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to delete data reference'
      console.error('Error deleting data reference:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function toggleDataReferenceActive(id: number, active: boolean) {
    loading.value = true
    error.value = null

    try {
      const response = active
        ? await adminApi.activateDataReference(id)
        : await adminApi.deactivateDataReference(id)

      if (response.success && response.data) {
        const index = dataReferences.value.findIndex(d => d.id === id)
        if (index !== -1) {
          dataReferences.value[index] = response.data.data_reference
        }
        return response.data.data_reference
      } else {
        throw new Error(response.message || 'Failed to toggle data reference')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to toggle data reference'
      console.error('Error toggling data reference:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  // AI Prompt Actions
  async function fetchAiPrompts(params: any = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.getAiPrompts(params)

      if (response.success && response.data) {
        aiPrompts.value = response.data.ai_prompts
      } else {
        throw new Error(response.message || 'Failed to fetch AI prompts')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch AI prompts'
      console.error('Error fetching AI prompts:', err)
    } finally {
      loading.value = false
    }
  }

  async function createAiPrompt(prompt: Partial<AiPrompt>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.createAiPrompt(prompt)

      if (response.success && response.data) {
        aiPrompts.value.push(response.data.ai_prompt)
        return response.data.ai_prompt
      } else {
        throw new Error(response.message || 'Failed to create AI prompt')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to create AI prompt'
      console.error('Error creating AI prompt:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateAiPrompt(id: number, prompt: Partial<AiPrompt>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.updateAiPrompt(id, prompt)

      if (response.success && response.data) {
        const index = aiPrompts.value.findIndex(p => p.id === id)
        if (index !== -1) {
          aiPrompts.value[index] = response.data.ai_prompt
        }
        return response.data.ai_prompt
      } else {
        throw new Error(response.message || 'Failed to update AI prompt')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to update AI prompt'
      console.error('Error updating AI prompt:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteAiPrompt(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.deleteAiPrompt(id)

      if (response.success) {
        aiPrompts.value = aiPrompts.value.filter(p => p.id !== id)
      } else {
        throw new Error(response.message || 'Failed to delete AI prompt')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to delete AI prompt'
      console.error('Error deleting AI prompt:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function activateAiPrompt(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.activateAiPrompt(id)

      if (response.success && response.data) {
        // Deactivate all prompts of the same type
        const prompt = aiPrompts.value.find(p => p.id === id)
        if (prompt) {
          aiPrompts.value.forEach(p => {
            if (p.prompt_type === prompt.prompt_type) {
              p.active = false
            }
          })
        }

        // Activate the selected prompt
        const index = aiPrompts.value.findIndex(p => p.id === id)
        if (index !== -1) {
          aiPrompts.value[index] = response.data.ai_prompt
        }

        return response.data.ai_prompt
      } else {
        throw new Error(response.message || 'Failed to activate AI prompt')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to activate AI prompt'
      console.error('Error activating AI prompt:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function testAiPrompt(id: number, testVariables: Record<string, any>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.testAiPrompt(id, testVariables)

      if (response.success && response.data) {
        return response.data
      } else {
        throw new Error(response.message || 'Failed to test AI prompt')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to test AI prompt'
      console.error('Error testing AI prompt:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  // Ingredient Actions
  async function fetchIngredients(params: any = {}) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.getIngredients(params)

      if (response.success && response.data) {
        ingredients.value = response.data.ingredients
        ingredientsPagination.value = response.data.pagination
      } else {
        throw new Error(response.message || 'Failed to fetch ingredients')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch ingredients'
      console.error('Error fetching ingredients:', err)
    } finally {
      loading.value = false
    }
  }

  async function createIngredient(ingredient: Partial<Ingredient>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.createIngredient(ingredient)

      if (response.success && response.data) {
        ingredients.value.push(response.data.ingredient)
        return response.data.ingredient
      } else {
        throw new Error(response.message || 'Failed to create ingredient')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to create ingredient'
      console.error('Error creating ingredient:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateIngredient(id: number, ingredient: Partial<Ingredient>) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.updateIngredient(id, ingredient)

      if (response.success && response.data) {
        const index = ingredients.value.findIndex(i => i.id === id)
        if (index !== -1) {
          ingredients.value[index] = response.data.ingredient
        }
        return response.data.ingredient
      } else {
        throw new Error(response.message || 'Failed to update ingredient')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to update ingredient'
      console.error('Error updating ingredient:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteIngredient(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.deleteIngredient(id)

      if (response.success) {
        ingredients.value = ingredients.value.filter(i => i.id !== id)
      } else {
        throw new Error(response.message || 'Failed to delete ingredient')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to delete ingredient'
      console.error('Error deleting ingredient:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function refreshNutrition(id: number) {
    loading.value = true
    error.value = null

    try {
      const response = await adminApi.refreshNutrition(id)

      if (response.success && response.data) {
        const index = ingredients.value.findIndex(i => i.id === id)
        if (index !== -1) {
          ingredients.value[index] = response.data.ingredient
        }
        return response.data.ingredient
      } else {
        throw new Error(response.message || 'Failed to refresh nutrition')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to refresh nutrition'
      console.error('Error refreshing nutrition:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  function clearError() {
    error.value = null
  }

  function clearDuplicates() {
    duplicateRecipes.value = []
  }

  return {
    // State
    recipes,
    currentRecipe,
    dataReferences,
    aiPrompts,
    ingredients,
    duplicateRecipes,
    recipesPagination,
    ingredientsPagination,
    loading,
    error,

    // Getters
    activePrompts,
    activeDataReferences,
    hasDuplicates,
    getPromptByType,
    getDataReferencesByType,

    // Recipe Actions
    fetchRecipes,
    fetchRecipe,
    createRecipe,
    updateRecipe,
    deleteRecipe,
    bulkDeleteRecipes,
    parseText,
    parseUrl,
    parseImage,
    checkDuplicates,
    regenerateVariants,
    regenerateTranslations,

    // Data Reference Actions
    fetchDataReferences,
    createDataReference,
    updateDataReference,
    deleteDataReference,
    toggleDataReferenceActive,

    // AI Prompt Actions
    fetchAiPrompts,
    createAiPrompt,
    updateAiPrompt,
    deleteAiPrompt,
    activateAiPrompt,
    testAiPrompt,

    // Ingredient Actions
    fetchIngredients,
    createIngredient,
    updateIngredient,
    deleteIngredient,
    refreshNutrition,

    // Utility Actions
    clearError,
    clearDuplicates
  }
})
