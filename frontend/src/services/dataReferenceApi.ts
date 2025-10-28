import apiClient from './api'
import type { DataReference, ApiResponse } from './types'

export const dataReferenceApi = {
  async getAll(): Promise<ApiResponse<{
    dietary_tags: DataReference[]
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

  async getCuisines(): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const response = await this.getAll()
    return {
      ...response,
      data: { data_references: response.data.cuisines }
    }
  },

}
