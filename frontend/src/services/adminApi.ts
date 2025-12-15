import axios from 'axios'
import type {
  RecipeDetail,
  DataReference,
  AiPrompt,
  Ingredient,
  ParseTextPayload,
  ParseUrlPayload,
  CheckDuplicatesPayload,
  ApiResponse,
  PaginationMeta,
  SupportedLanguage,
  Unit,
  UnitCategory
} from './types'

function getAdminBaseUrl(): string {
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL.replace('/api/v1', '')
  }
  const host = window.location.hostname
  return `http://${host}:3000`
}

// Create a separate client for admin endpoints (not under /api/v1)
const adminClient = axios.create({
  baseURL: getAdminBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  withCredentials: true
})

// Request interceptor for adding auth token and locale
adminClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }

    // Add Accept-Language header from current locale
    const locale = localStorage.getItem('locale') || 'en'
    config.headers['Accept-Language'] = locale

    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor for handling errors
adminClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized - clear token and redirect to login
      localStorage.removeItem('authToken')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// Update base URL for admin endpoints
const getAdminUrl = (path: string) => `/admin${path}`

export const adminApi = {
  // Recipe management
  async getRecipes(params: any = {}): Promise<ApiResponse<{ recipes: RecipeDetail[]; pagination: PaginationMeta }>> {
    const { data } = await adminClient.get(getAdminUrl('/recipes'), { params })
    return data
  },

  async getRecipe(id: string | number, lang?: SupportedLanguage): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const params = lang ? { lang } : {}
    const { data } = await adminClient.get(getAdminUrl(`/recipes/${id}`), { params })
    return data
  },

  async createRecipe(recipe: Partial<RecipeDetail> | FormData): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const payload = recipe instanceof FormData ? recipe : { recipe }
    const { data } = await adminClient.post(getAdminUrl('/recipes'), payload)
    return data
  },

  async updateRecipe(id: string | number, recipe: Partial<RecipeDetail> | FormData): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const payload = recipe instanceof FormData ? recipe : { recipe }
    const { data } = await adminClient.put(getAdminUrl(`/recipes/${id}`), payload)
    return data
  },

  async deleteRecipe(id: string | number): Promise<ApiResponse<{ deleted: boolean }>> {
    const { data } = await adminClient.delete(getAdminUrl(`/recipes/${id}`))
    return data
  },

  async bulkDeleteRecipes(ids: number[]): Promise<ApiResponse<{ deleted_count: number }>> {
    const { data } = await adminClient.delete(getAdminUrl('/recipes/bulk_delete'), { data: { ids } })
    return data
  },

  async parseText(payload: ParseTextPayload): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const { data } = await adminClient.post(getAdminUrl('/recipes/parse_text'), payload)
    return data
  },

  async parseUrl(payload: ParseUrlPayload): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const { data } = await adminClient.post(getAdminUrl('/recipes/parse_url'), payload)
    return data
  },

  async parseImage(formData: FormData): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const { data } = await adminClient.post(getAdminUrl('/recipes/parse_image'), formData)
    return data
  },

  async checkDuplicates(payload: CheckDuplicatesPayload): Promise<ApiResponse<{ duplicates: RecipeDetail[] }>> {
    const { data } = await adminClient.post(getAdminUrl('/recipes/check_duplicates'), payload)
    return data
  },

  async regenerateVariants(id: string | number): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const { data } = await adminClient.post(getAdminUrl(`/recipes/${id}/regenerate_variants`))
    return data
  },

  async regenerateTranslations(id: string | number): Promise<ApiResponse<{ recipe: RecipeDetail }>> {
    const { data } = await adminClient.post(getAdminUrl(`/recipes/${id}/regenerate_translations`))
    return data
  },

  // Data references management
  async getDataReferences(params: any = {}): Promise<ApiResponse<{ data_references: DataReference[] }>> {
    const { data } = await adminClient.get(getAdminUrl('/data_references'), { params })
    return data
  },

  async getDataReference(id: number): Promise<ApiResponse<{ data_reference: DataReference }>> {
    const { data } = await adminClient.get(getAdminUrl(`/data_references/${id}`))
    return data
  },

  async createDataReference(dataRef: Partial<DataReference>): Promise<ApiResponse<{ data_reference: DataReference }>> {
    const { data } = await adminClient.post(getAdminUrl('/data_references'), { data_reference: dataRef })
    return data
  },

  async updateDataReference(id: number, dataRef: Partial<DataReference>): Promise<ApiResponse<{ data_reference: DataReference }>> {
    const { data } = await adminClient.put(getAdminUrl(`/data_references/${id}`), { data_reference: dataRef })
    return data
  },

  async deleteDataReference(id: number): Promise<ApiResponse<{ deleted: boolean }>> {
    const { data } = await adminClient.delete(getAdminUrl(`/data_references/${id}`))
    return data
  },

  async activateDataReference(id: number): Promise<ApiResponse<{ data_reference: DataReference }>> {
    const { data } = await adminClient.post(getAdminUrl(`/data_references/${id}/activate`))
    return data
  },

  async deactivateDataReference(id: number): Promise<ApiResponse<{ data_reference: DataReference }>> {
    const { data } = await adminClient.post(getAdminUrl(`/data_references/${id}/deactivate`))
    return data
  },

  // AI prompts management
  async getAiPrompts(params: any = {}): Promise<ApiResponse<{ ai_prompts: AiPrompt[] }>> {
    const { data } = await adminClient.get(getAdminUrl('/ai_prompts'), { params })
    return data
  },

  async getAiPrompt(id: number): Promise<ApiResponse<{ ai_prompt: AiPrompt }>> {
    const { data } = await adminClient.get(getAdminUrl(`/ai_prompts/${id}`))
    return data
  },

  async createAiPrompt(prompt: Partial<AiPrompt>): Promise<ApiResponse<{ ai_prompt: AiPrompt }>> {
    const { data } = await adminClient.post(getAdminUrl('/ai_prompts'), { ai_prompt: prompt })
    return data
  },

  async updateAiPrompt(id: number, prompt: Partial<AiPrompt>): Promise<ApiResponse<{ ai_prompt: AiPrompt }>> {
    const { data } = await adminClient.put(getAdminUrl(`/ai_prompts/${id}`), { ai_prompt: prompt })
    return data
  },

  async deleteAiPrompt(id: number): Promise<ApiResponse<{ deleted: boolean }>> {
    const { data } = await adminClient.delete(getAdminUrl(`/ai_prompts/${id}`))
    return data
  },

  async activateAiPrompt(id: number): Promise<ApiResponse<{ ai_prompt: AiPrompt }>> {
    const { data } = await adminClient.post(getAdminUrl(`/ai_prompts/${id}/activate`))
    return data
  },

  async testAiPrompt(id: number, testVariables: Record<string, any>): Promise<ApiResponse<{ original_content: string; test_content: string; variables_used: Record<string, any> }>> {
    const { data } = await adminClient.post(getAdminUrl(`/ai_prompts/${id}/test`), { test_variables: testVariables })
    return data
  },

  // Ingredients management
  async getIngredients(params: any = {}): Promise<ApiResponse<{ ingredients: Ingredient[]; pagination: PaginationMeta }>> {
    const { data } = await adminClient.get(getAdminUrl('/ingredients'), { params })
    return data
  },

  async getIngredient(id: number): Promise<ApiResponse<{ ingredient: Ingredient }>> {
    const { data } = await adminClient.get(getAdminUrl(`/ingredients/${id}`))
    return data
  },

  async createIngredient(ingredient: Partial<Ingredient>): Promise<ApiResponse<{ ingredient: Ingredient }>> {
    const { data } = await adminClient.post(getAdminUrl('/ingredients'), { ingredient })
    return data
  },

  async updateIngredient(id: number, ingredient: Partial<Ingredient>): Promise<ApiResponse<{ ingredient: Ingredient }>> {
    const { data } = await adminClient.put(getAdminUrl(`/ingredients/${id}`), { ingredient })
    return data
  },

  async deleteIngredient(id: number): Promise<ApiResponse<{ deleted: boolean }>> {
    const { data } = await adminClient.delete(getAdminUrl(`/ingredients/${id}`))
    return data
  },

  async refreshNutrition(id: number): Promise<ApiResponse<{ ingredient: Ingredient }>> {
    const { data } = await adminClient.post(getAdminUrl(`/ingredients/${id}/refresh_nutrition`))
    return data
  },

  // Units management
  async getUnits(params: { category?: UnitCategory; q?: string } = {}): Promise<ApiResponse<{ units: Unit[]; categories: UnitCategory[] }>> {
    const { data } = await adminClient.get(getAdminUrl('/units'), { params })
    return data
  },

  async getUnit(id: number): Promise<ApiResponse<{ unit: Unit }>> {
    const { data } = await adminClient.get(getAdminUrl(`/units/${id}`))
    return data
  },

  async createUnit(unit: { canonical_name: string; category: UnitCategory }, autoTranslate = true): Promise<ApiResponse<{ unit: Unit }>> {
    const { data } = await adminClient.post(getAdminUrl('/units'), { unit, auto_translate: autoTranslate })
    return data
  },

  async updateUnit(id: number, unit: Partial<Unit>): Promise<ApiResponse<{ unit: Unit }>> {
    const { data } = await adminClient.put(getAdminUrl(`/units/${id}`), { unit })
    return data
  },

  async deleteUnit(id: number): Promise<ApiResponse<{ deleted: boolean }>> {
    const { data } = await adminClient.delete(getAdminUrl(`/units/${id}`))
    return data
  },

  async translateUnit(id: number): Promise<ApiResponse<{ unit: Unit }>> {
    const { data } = await adminClient.post(getAdminUrl(`/units/${id}/translate`))
    return data
  }
}
