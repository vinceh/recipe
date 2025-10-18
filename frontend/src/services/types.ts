// TypeScript interfaces for API responses

export interface Recipe {
  id: string | number
  title: string
  source_url?: string
  servings: number
  prep_time_minutes?: number
  cook_time_minutes?: number
  total_time_minutes?: number
  difficulty_level?: string
  dietary_tags?: string[]
  dish_types?: string[]
  cuisines?: string[]
  recipe_types?: string[]
  base_language: string
  active: boolean
  favorite?: boolean
  calories?: string
  protein_g?: string
  carbs_g?: string
  fat_g?: string
  fiber_g?: string
  created_at: string
  updated_at: string
}

export interface RecipeDetail extends Recipe {
  ingredients: RecipeIngredient[]
  steps: Step[]
  notes?: Note[]
  translations?: Translation[]
  variants?: Variant[]
}

export interface RecipeIngredient {
  id: number
  name: string
  quantity?: string
  unit?: string
  preparation?: string
  optional: boolean
  order_index: number
}

export interface Step {
  id: number
  step_number: number
  instruction: string
  time_minutes?: number
}

export interface Note {
  id: number
  content: string
  created_at: string
  updated_at: string
}

export interface Translation {
  id: number
  language: string
  title: string
  ingredients: RecipeIngredient[]
  steps: Step[]
}

export interface Variant {
  id: number
  variant_type: string
  description: string
  ingredients: RecipeIngredient[]
  steps: Step[]
}

export interface ScaleRecipePayload {
  servings: number
}

export interface ScaleRecipeResponse {
  recipe: RecipeDetail
  original_servings: number
  new_servings: number
}

export interface DataReference {
  id: number
  reference_type: string
  key: string
  display_name: string
  active: boolean
  sort_order?: number
  metadata?: Record<string, any>
}

export interface User {
  id: number
  email: string
  name?: string
  role: string
  created_at: string
}

export interface AuthResponse {
  user: User
  token: string
}

export interface LoginCredentials {
  email: string
  password: string
}

export interface SignupCredentials {
  email: string
  password: string
  password_confirmation: string
  name?: string
}

export interface PaginationMeta {
  current_page: number
  per_page: number
  total_count: number
  total_pages: number
}

export interface RecipeListResponse {
  recipes: Recipe[]
  pagination: PaginationMeta
}

export interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string
  errors?: string[]
}

export interface RecipeFilters {
  dietary_tags?: string[]
  dish_types?: string[]
  cuisines?: string[]
  recipe_types?: string[]
  difficulty_level?: string
  max_prep_time?: number
  max_cook_time?: number
  max_total_time?: number
  min_servings?: number
  max_servings?: number
  q?: string
  page?: number
  per_page?: number
}

export interface Ingredient {
  id: number
  canonical_name: string
  category?: string
  has_nutrition?: boolean
  aliases_count?: number
  nutrition?: IngredientNutrition
  aliases?: IngredientAlias[]
  created_at?: string
  updated_at?: string
}

export interface IngredientNutrition {
  calories: number
  protein_g: number
  carbs_g: number
  fat_g: number
  fiber_g: number
  data_source: string
  confidence_score: number
}

export interface IngredientAlias {
  alias: string
  language: string
}

export interface AiPrompt {
  id: number
  prompt_key: string
  prompt_type: string
  feature_area: string
  prompt_text: string
  description?: string
  active: boolean
  version: number
  variables: string[]
  created_at: string
  updated_at: string
}

export interface ParseTextPayload {
  text: string
  source_url?: string
}

export interface ParseUrlPayload {
  url: string
}

export interface ParseImagePayload {
  image: File
}

export interface CheckDuplicatesPayload {
  title: string
}
