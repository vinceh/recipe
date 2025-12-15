import apiClient from './api'
import type {
  RecipeListResponse,
  RecipeDetail,
  ScaleRecipePayload,
  ScaleRecipeResponse,
  Note,
  RecipeFilters,
  ApiResponse,
  SupportedLanguage,
  Unit,
  UnitCategory
} from './types'

export const recipeApi = {
  /**
   * Fetch recipes with search, filter, and pagination options
   *
   * Language resolution (priority high to low):
   * 1. filters.lang (explicit ?lang=XX query param)
   * 2. Accept-Language header (from localStorage via axios interceptor)
   * 3. Backend default (en)
   *
   * @param filters - Search/filter/pagination criteria, optionally includes lang
   */
  async getRecipes(filters: RecipeFilters = {}): Promise<ApiResponse<RecipeListResponse>> {
    const { data } = await apiClient.get('/recipes', { params: filters })
    return data
  },

  /**
   * Fetch single recipe with full details
   *
   * Language resolution (priority high to low):
   * 1. lang parameter (explicit ?lang=XX query param)
   * 2. Accept-Language header (from localStorage via axios interceptor)
   * 3. Backend default (en)
   *
   * @param id - Recipe ID (UUID string or numeric ID)
   * @param lang - Optional language code (en, ja, ko, zh-tw, zh-cn, es, fr)
   */
  async getRecipe(id: string | number, lang?: SupportedLanguage): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const params = { lang }
    const { data } = await apiClient.get(`/recipes/${id}`, { params })
    return data
  },

  /**
   * Scale recipe ingredients to new serving size
   *
   * Language resolution (priority high to low):
   * 1. lang parameter (explicit ?lang=XX query param)
   * 2. Accept-Language header (from localStorage via axios interceptor)
   * 3. Backend default (en)
   *
   * @param id - Recipe ID (UUID string or numeric ID)
   * @param payload - Scaling request with new servings count
   * @param lang - Optional language code (en, ja, ko, zh-tw, zh-cn, es, fr)
   */
  async scaleRecipe(id: string | number, payload: ScaleRecipePayload, lang?: SupportedLanguage): Promise<ApiResponse<ScaleRecipeResponse>> {
    const params = { lang }
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
  },

  async adjustRecipe(recipe: RecipeDetail, prompt: string): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const { data } = await apiClient.post('/ai/adjust_recipe', { recipe, prompt })
    return data
  },

  async getUnits(): Promise<ApiResponse<{ units: Unit[], categories: UnitCategory[] }>> {
    const { data } = await apiClient.get('/units')
    return data
  }
}
