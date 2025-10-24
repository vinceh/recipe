// TypeScript interfaces for API responses
// These match the backend Recipe model structure exactly

export interface RecipeServings {
  original?: number
  min?: number
  max?: number
}

export interface RecipeTiming {
  prep_minutes?: number
  cook_minutes?: number
  total_minutes?: number
}

export interface RecipeNutritionPerServing {
  calories: number
  protein_g: number
  carbs_g: number
  fat_g: number
  fiber_g: number
}

export interface RecipeNutrition {
  per_serving: RecipeNutritionPerServing
}

export interface RecipeIngredientItem {
  name: string
  amount?: string
  unit?: string
  preparation?: string
  optional?: boolean
}

export interface RecipeIngredientGroup {
  name: string
  items: RecipeIngredientItem[]
}

export interface RecipeStep {
  id: string
  order: number
  instruction: string
}

export interface Recipe {
  id: string | number
  name: string  // Translated via Mobility based on Accept-Language or ?lang parameter
  language: string  // The source language of the recipe (e.g., 'en')
  source_url?: string
  requires_precision?: boolean
  precision_reason?: 'baking' | 'confectionery' | 'fermentation' | 'molecular'
  servings: RecipeServings
  timing?: RecipeTiming
  nutrition?: RecipeNutrition
  aliases?: string[]
  dietary_tags?: string[]
  dish_types?: string[]
  cuisines?: string[]
  recipe_types?: string[]
  ingredient_groups: RecipeIngredientGroup[]
  steps: RecipeStep[]
  equipment?: string[]
  translations?: { [language: string]: any }
  translations_completed?: boolean
  last_translated_at?: string
  admin_notes?: string
  favorite?: boolean
  notes?: Note[]
  created_at: string
  updated_at: string
}

export interface RecipeDetail extends Recipe {
  // Additional fields that might come from API joins
  user_notes?: RecipeUserNote[]
}

/**
 * @deprecated Use RecipeIngredientItem and RecipeIngredientGroup instead.
 * Legacy interface kept for backward compatibility during transition to Phase 7.
 */
export interface RecipeIngredient {
  id: number
  name: string
  quantity?: string
  unit?: string
  preparation?: string
  optional: boolean
  order_index: number
}

/**
 * @deprecated Use RecipeStep instead.
 * Legacy interface kept for backward compatibility during transition to Phase 7.
 */
export interface Step {
  id: number
  step_number: number
  instruction: string
}

export interface RecipeUserNote {
  id: number
  content: string
  created_at: string
  updated_at: string
}

/**
 * @deprecated Translation data is now served by the API with locale parameter.
 * Use Recipe with lang parameter instead (e.g., getRecipe(id, { lang: 'ja' })).
 */
export interface Translation {
  id: number
  language: string
  title: string
  ingredients: RecipeIngredient[]
  steps: Step[]
}

/**
 * @deprecated Variants feature is not implemented in Phase 7.
 * This interface is kept for reference only.
 */
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
  original_servings: number
  new_servings: number
  scale_factor: number
  scaled_ingredient_groups: RecipeIngredientGroup[]
}

// Data reference types
export interface DataReference {
  id?: number
  category?: string
  name?: string
  key: string
  display_name: string
  reference_type?: string
  sort_order?: number
  active?: boolean
  translations?: { [key: string]: string }
}

// API response wrapper
export interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string
  errors?: string[]
}

// Search/filter types
export interface RecipeSearchParams {
  q?: string
  dietary_tags?: string[]
  dish_types?: string[]
  cuisines?: string[]
  recipe_types?: string[]
  max_prep_time?: number
  max_cook_time?: number
  max_total_time?: number
  page?: number
  per_page?: number
}

// Auth types
export interface LoginCredentials {
  email: string
  password: string
}

export interface SignupData extends LoginCredentials {
  name: string
}

export interface User {
  id: string | number
  email: string
  name?: string
  role: 'user' | 'admin'
  created_at: string
}

export interface AuthResponse {
  token: string
  user: User
}

// Legacy auth type alias
export type SignupCredentials = SignupData

// Admin-specific types
export interface PaginationMeta {
  current_page: number
  total_pages: number
  total_count: number
  per_page: number
}

export interface RecipeListResponse {
  recipes: Recipe[]
  meta?: PaginationMeta
  pagination?: PaginationMeta
}

export interface RecipeFilters {
  q?: string
  /**
   * Filter by dietary tags. Accepts single tag or array of tags.
   * Single: Used for "Add Another" filter patterns
   * Array: Used for multi-select filter forms
   */
  dietary_tags?: string | string[]
  dish_types?: string | string[]
  cuisines?: string | string[]
  recipe_types?: string | string[]
  max_prep_time?: number
  max_cook_time?: number
  max_total_time?: number
  page?: number
  per_page?: number
  /**
   * Request recipes translated to specific language.
   * Passes as ?lang=XX query parameter to backend.
   * Backend uses Mobility to return translations in requested language.
   * Falls back to source language if translation missing.
   * If not specified, defaults to Accept-Language header value or 'en'.
   */
  lang?: string
}

export interface Note {
  id: number
  content: string
  user_id: number
  recipe_id: number
  created_at: string
  updated_at: string
}

export interface Ingredient {
  id?: number
  name: string
  quantity?: string
  unit?: string
  preparation?: string
  optional?: boolean
}

export interface AiPrompt {
  id: number
  name: string
  prompt_text: string
  prompt_type?: string
  category: string
  active: boolean
  created_at: string
  updated_at: string
}

export interface ParseTextPayload {
  text_content: string
  prompt_id?: number
}

export interface ParseUrlPayload {
  url: string
  prompt_id?: number
}

export interface CheckDuplicatesPayload {
  title: string
  ingredients?: string[]
}
