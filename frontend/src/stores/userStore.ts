import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/services/authApi'
import type { User, Recipe, LoginCredentials, SignupCredentials } from '@/services/types'

export const useUserStore = defineStore('user', () => {
  // State
  const currentUser = ref<User | null>(null)
  const favorites = ref<Recipe[]>([])
  const authToken = ref<string | null>(localStorage.getItem('authToken'))
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const isAuthenticated = computed(() => !!currentUser.value && !!authToken.value)
  const isAdmin = computed(() => currentUser.value?.role === 'admin')
  const userName = computed(() => currentUser.value?.name || currentUser.value?.email || 'User')
  const hasFavorites = computed(() => favorites.value.length > 0)
  const favoriteCount = computed(() => favorites.value.length)

  const isFavorite = computed(() => (recipeId: number) => {
    return favorites.value.some(recipe => recipe.id === recipeId)
  })

  // Actions
  async function login(credentials: LoginCredentials) {
    loading.value = true
    error.value = null

    try {
      const response = await authApi.login(credentials)

      if (response.success && response.data) {
        currentUser.value = response.data.user
        authToken.value = response.data.token
        localStorage.setItem('authToken', response.data.token)
        localStorage.setItem('currentUser', JSON.stringify(response.data.user))

        // Fetch favorites after login
        await fetchFavorites()
      } else {
        throw new Error(response.message || 'Login failed')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Login failed'
      console.error('Login error:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function signup(credentials: SignupCredentials) {
    loading.value = true
    error.value = null

    try {
      const response = await authApi.signup(credentials)

      if (response.success && response.data) {
        currentUser.value = response.data.user
        authToken.value = response.data.token
        localStorage.setItem('authToken', response.data.token)
      } else {
        throw new Error(response.message || 'Signup failed')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Signup failed'
      console.error('Signup error:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    loading.value = true
    error.value = null

    try {
      await authApi.logout()
    } catch (err: any) {
      console.error('Logout error:', err)
      // Continue with logout even if API call fails
    } finally {
      currentUser.value = null
      authToken.value = null
      favorites.value = []
      localStorage.removeItem('authToken')
      localStorage.removeItem('currentUser')
      loading.value = false
    }
  }

  async function fetchCurrentUser() {
    if (!authToken.value) {
      return
    }

    loading.value = true
    error.value = null

    try {
      const response = await authApi.getCurrentUser()

      if (response.success && response.data) {
        currentUser.value = response.data.user
        // Fetch favorites after getting user
        await fetchFavorites()
      } else {
        throw new Error(response.message || 'Failed to fetch user')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch user'
      console.error('Error fetching user:', err)

      // If unauthorized, clear auth state
      if (err.response?.status === 401) {
        currentUser.value = null
        authToken.value = null
        localStorage.removeItem('authToken')
      }
    } finally {
      loading.value = false
    }
  }

  async function fetchFavorites() {
    if (!isAuthenticated.value) {
      return
    }

    loading.value = true
    error.value = null

    try {
      const response = await authApi.getFavorites()

      if (response.success && response.data) {
        favorites.value = response.data.recipes
      } else {
        throw new Error(response.message || 'Failed to fetch favorites')
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || err.message || 'Failed to fetch favorites'
      console.error('Error fetching favorites:', err)
    } finally {
      loading.value = false
    }
  }

  function addToFavorites(recipe: Recipe) {
    if (!favorites.value.some(fav => fav.id === recipe.id)) {
      favorites.value.push(recipe)
    }
  }

  function removeFromFavorites(recipeId: number) {
    favorites.value = favorites.value.filter(recipe => recipe.id !== recipeId)
  }

  function clearError() {
    error.value = null
  }

  // Initialize auth state on store creation
  async function initialize() {
    if (authToken.value) {
      // Try to restore user from localStorage first
      const storedUser = localStorage.getItem('currentUser')
      if (storedUser) {
        try {
          currentUser.value = JSON.parse(storedUser)
          return
        } catch (err) {
          console.error('Failed to parse stored user:', err)
        }
      }

      // If no stored user, try to fetch from API
      try {
        await fetchCurrentUser()
      } catch (err) {
        console.warn('Failed to fetch user on init, clearing auth state')
        // Clear invalid token
        currentUser.value = null
        authToken.value = null
        localStorage.removeItem('authToken')
        localStorage.removeItem('currentUser')
      }
    }
  }

  return {
    // State
    currentUser,
    favorites,
    authToken,
    loading,
    error,

    // Getters
    isAuthenticated,
    isAdmin,
    userName,
    hasFavorites,
    favoriteCount,
    isFavorite,

    // Actions
    login,
    signup,
    logout,
    fetchCurrentUser,
    fetchFavorites,
    addToFavorites,
    removeFromFavorites,
    clearError,
    initialize
  }
})
