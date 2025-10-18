import apiClient from './api'
import type { DataReference, ApiResponse } from './types'

export const dataReferenceApi = {
  async getDataReferences(referenceType?: string): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const params = referenceType ? { reference_type: referenceType } : {}
    const { data } = await apiClient.get('/data_references', { params })
    return data
  },

  async getDietaryTags(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    return this.getDataReferences('dietary_tag')
  },

  async getDishTypes(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    return this.getDataReferences('dish_type')
  },

  async getCuisines(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    return this.getDataReferences('cuisine')
  },

  async getRecipeTypes(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    return this.getDataReferences('recipe_type')
  }
}
