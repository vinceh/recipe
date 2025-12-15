import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { recipeApi } from '@/services/recipeApi'
import { adminApi } from '@/services/adminApi'
import type { Unit, UnitCategory, SupportedLanguage } from '@/services/types'

export const useUnitStore = defineStore('unit', () => {
  const units = ref<Unit[]>([])
  const categories = ref<UnitCategory[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const loaded = ref(false)

  const unitsByCategory = computed(() => {
    const grouped: Record<UnitCategory, Unit[]> = {
      unit_volume: [],
      unit_weight: [],
      unit_quantity: [],
      unit_length: [],
      unit_other: []
    }
    for (const unit of units.value) {
      if (grouped[unit.category]) {
        grouped[unit.category].push(unit)
      }
    }
    return grouped
  })

  async function fetchUnits(force = false) {
    if (loaded.value && !force) return

    loading.value = true
    error.value = null
    try {
      const response = await recipeApi.getUnits()
      if (response.success) {
        units.value = response.data.units
        categories.value = response.data.categories
        loaded.value = true
      }
    } catch (e: any) {
      error.value = e.message || 'Failed to fetch units'
    } finally {
      loading.value = false
    }
  }

  async function createUnit(canonicalName: string, category: UnitCategory, autoTranslate = true): Promise<Unit | null> {
    loading.value = true
    error.value = null
    try {
      const response = await adminApi.createUnit({ canonical_name: canonicalName, category }, autoTranslate)
      if (response.success) {
        units.value.push(response.data.unit)
        return response.data.unit
      }
      return null
    } catch (e: any) {
      error.value = e.message || 'Failed to create unit'
      return null
    } finally {
      loading.value = false
    }
  }

  function getTranslatedName(unit: Unit, locale?: SupportedLanguage): string {
    const currentLocale = locale || (localStorage.getItem('locale') as SupportedLanguage) || 'en'
    return unit.translations?.[currentLocale] || unit.canonical_name
  }

  function findByName(name: string): Unit | undefined {
    const lowerName = name.toLowerCase()
    return units.value.find(u =>
      u.canonical_name.toLowerCase() === lowerName ||
      Object.values(u.translations || {}).some(t => t.toLowerCase() === lowerName)
    )
  }

  function findById(id: number): Unit | undefined {
    return units.value.find(u => u.id === id)
  }

  function findByCanonicalName(canonicalName: string): Unit | undefined {
    return units.value.find(u => u.canonical_name === canonicalName)
  }

  function searchUnits(query: string, locale?: SupportedLanguage): Unit[] {
    if (!query) return units.value
    const lowerQuery = query.toLowerCase()
    const currentLocale = locale || (localStorage.getItem('locale') as SupportedLanguage) || 'en'
    return units.value.filter(u =>
      u.canonical_name.toLowerCase().includes(lowerQuery) ||
      (u.translations?.[currentLocale]?.toLowerCase().includes(lowerQuery))
    )
  }

  function clearAll() {
    units.value = []
    categories.value = []
    loaded.value = false
  }

  return {
    units,
    categories,
    loading,
    error,
    loaded,
    unitsByCategory,
    fetchUnits,
    createUnit,
    getTranslatedName,
    findByName,
    findById,
    findByCanonicalName,
    searchUnits,
    clearAll
  }
})
