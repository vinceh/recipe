import apiClient from './api'
import type { AuthResponse, LoginCredentials, SignupData, User, ApiResponse, Recipe } from './types'

export const authApi = {
  async login(credentials: LoginCredentials): Promise<ApiResponse<AuthResponse>> {
    const response = await apiClient.post('/auth/sign_in', { user: credentials })

    // Extract JWT token from Authorization header
    const token = response.headers.authorization || response.headers.Authorization

    return {
      ...response.data,
      data: {
        ...response.data.data,
        token: token // Add token to response data
      }
    }
  },

  async signup(credentials: SignupData): Promise<ApiResponse<AuthResponse>> {
    const response = await apiClient.post('/auth', { user: credentials })

    // Extract JWT token from Authorization header (same as login)
    const token = response.headers.authorization || response.headers.Authorization

    return {
      ...response.data,
      data: {
        ...response.data.data,
        token: token
      }
    }
  },

  async logout(): Promise<ApiResponse<{ message: string }>> {
    const { data } = await apiClient.delete('/auth/sign_out')
    return data
  },

  async getCurrentUser(): Promise<ApiResponse<{ user: User }>> {
    const { data } = await apiClient.get('/auth/me')
    return data
  },

  async getFavorites(): Promise<ApiResponse<{ favorites: Recipe[] }>> {
    const { data } = await apiClient.get('/users/me/favorites')
    return data
  },

  async requestPasswordReset(email: string): Promise<ApiResponse<{ message: string }>> {
    const { data } = await apiClient.post('/auth/password', { user: { email } })
    return data
  },

  async resetPassword(token: string, password: string): Promise<ApiResponse<{ message: string }>> {
    const { data } = await apiClient.put('/auth/password', {
      user: {
        reset_password_token: token,
        password: password,
        password_confirmation: password
      }
    })
    return data
  }
}
