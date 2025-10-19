import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { dataReferenceApi } from '@/services/dataReferenceApi'
import type { DataReference } from '@/services/types'

export const useDataReferenceStore = defineStore('dataReference', () => {
  // State
  const dietaryTags = ref<DataReference[]>([])
  const dishTypes = ref<DataReference[]>([])
  const cuisines = ref<DataReference[]>([])
  const recipeTypes = ref<DataReference[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const activeDietaryTags = computed(() =>
    dietaryTags.value.filter(tag => tag.active)
  )

  const activeDishTypes = computed(() =>
    dishTypes.value.filter(type => type.active)
  )

  const activeCuisines = computed(() =>
    cuisines.value.filter(cuisine => cuisine.active)
  )

  const activeRecipeTypes = computed(() =>
    recipeTypes.value.filter(type => type.active)
  )

  const getDietaryTagByKey = computed(() => (key: string) => {
    return dietaryTags.value.find(tag => tag.key === key)
  })

  const getDishTypeByKey = computed(() => (key: string) => {
    return dishTypes.value.find(type => type.key === key)
  })

  const getCuisineByKey = computed(() => (key: string) => {
    return cuisines.value.find(cuisine => cuisine.key === key)
  })

  const getRecipeTypeByKey = computed(() => (key: string) => {
    return recipeTypes.value.find(type => type.key === key)
  })

  // Actions
  async function fetchDietaryTags() {
    loading.value = true
    error.value = null

    try {
      const response = await dataReferenceApi.getDietaryTags()

      if (response.success && response.data && response.data.data_references) {
        dietaryTags.value = response.data.data_references.sort(
          (a, b) => (a.sort_order || 0) - (b.sort_order || 0)
        )
      } else {
        dietaryTags.value = []
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch dietary tags'
      dietaryTags.value = []
      console.error('Error fetching dietary tags:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchDishTypes() {
    loading.value = true
    error.value = null

    try {
      const response = await dataReferenceApi.getDishTypes()

      if (response.success && response.data && response.data.data_references) {
        dishTypes.value = response.data.data_references.sort(
          (a, b) => (a.sort_order || 0) - (b.sort_order || 0)
        )
      } else {
        dishTypes.value = []
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch dish types'
      dishTypes.value = []
      console.error('Error fetching dish types:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchCuisines() {
    loading.value = true
    error.value = null

    try {
      const response = await dataReferenceApi.getCuisines()

      if (response.success && response.data && response.data.data_references) {
        cuisines.value = response.data.data_references.sort(
          (a, b) => (a.sort_order || 0) - (b.sort_order || 0)
        )
      } else {
        cuisines.value = []
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch cuisines'
      cuisines.value = []
      console.error('Error fetching cuisines:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchRecipeTypes() {
    loading.value = true
    error.value = null

    try {
      const response = await dataReferenceApi.getRecipeTypes()

      if (response.success && response.data && response.data.data_references) {
        recipeTypes.value = response.data.data_references.sort(
          (a, b) => (a.sort_order || 0) - (b.sort_order || 0)
        )
      } else {
        recipeTypes.value = []
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch recipe types'
      recipeTypes.value = []
      console.error('Error fetching recipe types:', err)
    } finally {
      loading.value = false
    }
  }

  async function fetchAll() {
    await Promise.all([
      fetchDietaryTags(),
      fetchDishTypes(),
      fetchCuisines(),
      fetchRecipeTypes()
    ])
  }

  function clearError() {
    error.value = null
  }

  return {
    // State
    dietaryTags,
    dishTypes,
    cuisines,
    recipeTypes,
    loading,
    error,

    // Getters
    activeDietaryTags,
    activeDishTypes,
    activeCuisines,
    activeRecipeTypes,
    getDietaryTagByKey,
    getDishTypeByKey,
    getCuisineByKey,
    getRecipeTypeByKey,

    // Actions
    fetchDietaryTags,
    fetchDishTypes,
    fetchCuisines,
    fetchRecipeTypes,
    fetchAll,
    clearError
  }
})
