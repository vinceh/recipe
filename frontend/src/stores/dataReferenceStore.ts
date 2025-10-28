import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { dataReferenceApi } from '@/services/dataReferenceApi'
import type { DataReference } from '@/services/types'

export const useDataReferenceStore = defineStore('dataReference', () => {
  // State
  const dietaryTags = ref<DataReference[]>([])
  const cuisines = ref<DataReference[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const activeDietaryTags = computed(() =>
    dietaryTags.value.filter(tag => tag.active)
  )

  const activeCuisines = computed(() =>
    cuisines.value.filter(cuisine => cuisine.active)
  )

  const getDietaryTagByKey = computed(() => (key: string) => {
    return dietaryTags.value.find(tag => tag.key === key)
  })

  const getCuisineByKey = computed(() => (key: string) => {
    return cuisines.value.find(cuisine => cuisine.key === key)
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

  async function fetchAll() {
    await Promise.all([
      fetchDietaryTags(),
      fetchCuisines()
    ])
  }

  function clearAll() {
    dietaryTags.value = []
    cuisines.value = []
  }

  function clearError() {
    error.value = null
  }

  return {
    // State
    dietaryTags,
    cuisines,
    loading,
    error,

    // Getters
    activeDietaryTags,
    activeCuisines,
    getDietaryTagByKey,
    getCuisineByKey,

    // Actions
    fetchDietaryTags,
    fetchCuisines,
    fetchAll,
    clearAll,
    clearError
  }
})
