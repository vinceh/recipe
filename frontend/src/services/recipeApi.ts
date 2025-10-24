import apiClient from './api'
import type {
  RecipeListResponse,
  RecipeDetail,
  ScaleRecipePayload,
  ScaleRecipeResponse,
  Note,
  RecipeFilters,
  ApiResponse
} from './types'

export const recipeApi = {
  // Public API endpoints
  async getRecipes(filters: RecipeFilters = {}): Promise<ApiResponse<RecipeListResponse>> {
    // lang parameter will be passed as query param if provided in filters
    // Accept-Language header is automatically added by axios interceptor
    const { data } = await apiClient.get('/recipes', { params: filters })
    return data
  },

  async getRecipe(id: number | string, lang?: string): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const params = lang ? { lang } : {}
    const { data } = await apiClient.get(`/recipes/${id}`, { params })
    return data
  },

  async scaleRecipe(id: number | string, payload: ScaleRecipePayload, lang?: string): Promise<ApiResponse<ScaleRecipeResponse>> {
    const params = lang ? { lang } : {}
    const { data } = await apiClient.post(`/recipes/${id}/scale`, payload, { params })
    return data
  },

  async favoriteRecipe(id: number): Promise<ApiResponse<{ favorited: boolean }>> {
    const { data } = await apiClient.post(`/recipes/${id}/favorite`)
    return data
  },

  async unfavoriteRecipe(id: number): Promise<ApiResponse<{ favorited: boolean }>> {
    const { data } = await apiClient.delete(`/recipes/${id}/favorite`)
    return data
  },

  async getRecipeNotes(id: number): Promise<ApiResponse<{ notes: Note[] }>> {
    const { data } = await apiClient.get(`/recipes/${id}/notes`)
    return data
  },

  async createRecipeNote(id: number, content: string): Promise<ApiResponse<{ note: Note }>> {
    const { data } = await apiClient.post(`/recipes/${id}/notes`, { note: { content } })
    return data
  },

  async updateNote(id: number, content: string): Promise<ApiResponse<{ note: Note }>> {
    const { data } = await apiClient.put(`/notes/${id}`, { note: { content } })
    return data
  },

  async deleteNote(id: number): Promise<ApiResponse<{ deleted: boolean }>> {
    const { data } = await apiClient.delete(`/notes/${id}`)
    return data
  }
}
