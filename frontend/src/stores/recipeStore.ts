import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { recipeApi } from '@/services/recipeApi'
import type {
  Recipe,
  RecipeDetail,
  RecipeFilters,
  Note,
  ScaleRecipePayload,
  PaginationMeta
} from '@/services/types'

export const useRecipeStore = defineStore('recipe', () => {
  // State
  const recipes = ref<Recipe[]>([])
  const currentRecipe = ref<RecipeDetail | null>(null)
  const pagination = ref<PaginationMeta>({
    current_page: 1,
    per_page: 20,
    total_count: 0,
    total_pages: 0
  })
  const filters = ref<RecipeFilters>({
    dietary_tags: [],
    cuisines: [],
    difficulty_level: undefined,
    page: 1,
    per_page: 20
  })
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const hasRecipes = computed(() => recipes.value.length > 0)
  const totalRecipes = computed(() => pagination.value.total_count)
  const hasNextPage = computed(() => pagination.value.current_page < pagination.value.total_pages)
  const hasPreviousPage = computed(() => pagination.value.current_page > 1)

  const filteredByPrecision = computed(() => (requiresPrecision: boolean) => {
    return recipes.value.filter(recipe => recipe.requires_precision === requiresPrecision)
  })

  const filteredByTag = computed(() => (tag: string) => {
    return recipes.value.filter(recipe => recipe.dietary_tags?.includes(tag))
  })

  const currentRecipeNotes = computed(() => currentRecipe.value?.notes || [])
  const currentRecipeTranslations = computed(() => currentRecipe.value?.translations || {})

  // Actions
  async function fetchRecipes(newFilters?: RecipeFilters) {
    loading.value = true
    error.value = null

    try {
      if (newFilters) {
        filters.value = { ...filters.value, ...newFilters }
      }

      const response = await recipeApi.getRecipes(filters.value)

      if (response.success && response.data) {
        recipes.value = response.data.recipes
        if (response.data.pagination) {
          pagination.value = response.data.pagination
        } else if (response.data.meta) {
          pagination.value = response.data.meta
        }
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
      const response = await recipeApi.getRecipe(id)

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

  async function scaleRecipe(id: number, payload: ScaleRecipePayload) {
    loading.value = true
    error.value = null

    try {
      const response = await recipeApi.scaleRecipe(id, payload)

      if (response.success && response.data) {
        return response.data
      } else {
        throw new Error(response.message || 'Failed to scale recipe')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to scale recipe'
      console.error('Error scaling recipe:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function toggleFavorite(id: number) {
    try {
      const recipe = recipes.value.find(r => r.id === id) || currentRecipe.value

      if (!recipe) return

      const isFavorited = recipe.favorite || false
      const response = isFavorited
        ? await recipeApi.unfavoriteRecipe(id)
        : await recipeApi.favoriteRecipe(id)

      if (response.success) {
        const newFavoriteStatus = !isFavorited

        // Update recipe in list
        const recipeIndex = recipes.value.findIndex(r => r.id === id)
        if (recipeIndex !== -1 && recipes.value[recipeIndex]) {
          recipes.value[recipeIndex].favorite = newFavoriteStatus
        }

        // Update current recipe
        if (currentRecipe.value?.id === id) {
          currentRecipe.value.favorite = newFavoriteStatus
        }
      } else {
        throw new Error(response.message || 'Failed to toggle favorite')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to toggle favorite'
      console.error('Error toggling favorite:', err)
      throw err
    }
  }

  async function addNote(recipeId: number, content: string) {
    loading.value = true
    error.value = null

    try {
      const response = await recipeApi.createRecipeNote(recipeId, content)

      if (response.success && response.data) {
        // Add note to current recipe if it's the same
        if (currentRecipe.value?.id === recipeId) {
          if (!currentRecipe.value.notes) {
            currentRecipe.value.notes = []
          }
          currentRecipe.value.notes.push(response.data.note)
        }
        return response.data.note
      } else {
        throw new Error(response.message || 'Failed to add note')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to add note'
      console.error('Error adding note:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateNote(noteId: number, content: string) {
    loading.value = true
    error.value = null

    try {
      const response = await recipeApi.updateNote(noteId, content)

      if (response.success && response.data) {
        // Update note in current recipe
        if (currentRecipe.value?.notes) {
          const noteIndex = currentRecipe.value.notes.findIndex(n => n.id === noteId)
          if (noteIndex !== -1) {
            currentRecipe.value.notes[noteIndex] = response.data.note
          }
        }
        return response.data.note
      } else {
        throw new Error(response.message || 'Failed to update note')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to update note'
      console.error('Error updating note:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function deleteNote(noteId: number) {
    loading.value = true
    error.value = null

    try {
      const response = await recipeApi.deleteNote(noteId)

      if (response.success) {
        // Remove note from current recipe
        if (currentRecipe.value?.notes) {
          currentRecipe.value.notes = currentRecipe.value.notes.filter(n => n.id !== noteId)
        }
      } else {
        throw new Error(response.message || 'Failed to delete note')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to delete note'
      console.error('Error deleting note:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  function setFilters(newFilters: RecipeFilters) {
    filters.value = { ...filters.value, ...newFilters }
  }

  function clearFilters() {
    filters.value = {
      dietary_tags: [],
      cuisines: [],
      difficulty_level: undefined,
      page: 1,
      per_page: 20
    }
  }

  function nextPage() {
    if (hasNextPage.value) {
      filters.value.page = (filters.value.page || 1) + 1
      fetchRecipes()
    }
  }

  function previousPage() {
    if (hasPreviousPage.value) {
      filters.value.page = (filters.value.page || 1) - 1
      fetchRecipes()
    }
  }

  function clearCurrentRecipe() {
    currentRecipe.value = null
  }

  function clearError() {
    error.value = null
  }

  return {
    // State
    recipes,
    currentRecipe,
    pagination,
    filters,
    loading,
    error,

    // Getters
    hasRecipes,
    totalRecipes,
    hasNextPage,
    hasPreviousPage,
    filteredByPrecision,
    filteredByTag,
    currentRecipeNotes,
    currentRecipeTranslations,

    // Actions
    fetchRecipes,
    fetchRecipe,
    scaleRecipe,
    toggleFavorite,
    addNote,
    updateNote,
    deleteNote,
    setFilters,
    clearFilters,
    nextPage,
    previousPage,
    clearCurrentRecipe,
    clearError
  }
})
