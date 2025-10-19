import apiClient from './api'
import type { DataReference, ApiResponse } from './types'

export const dataReferenceApi = {
  async getAll(): Promise<ApiResponse<{
    dietary_tags: DataReference[]
    dish_types: DataReference[]
    recipe_types: DataReference[]
    cuisines: DataReference[]
  }>> {
    const { data } = await apiClient.get('/data_references')
    return data
  },

  async getDietaryTags(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const response = await this.getAll()
    return {
      ...response,
      data: { data_references: response.data.dietary_tags }
    }
  },

  async getDishTypes(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const response = await this.getAll()
    return {
      ...response,
      data: { data_references: response.data.dish_types }
    }
  },

  async getCuisines(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const response = await this.getAll()
    return {
      ...response,
      data: { data_references: response.data.cuisines }
    }
  },

  async getRecipeTypes(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const response = await this.getAll()
    return {
      ...response,
      data: { data_references: response.data.recipe_types }
    }
  }
}
