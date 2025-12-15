/**
 * useAuth Composable
 *
 * Provides authentication helpers and guards.
 * Simple wrapper around userStore for convenient auth checks.
 *
 * Usage:
 * const { isAuthenticated, isAdmin, currentUser, requireAuth, requireAdmin } = useAuth()
 *
 * if (isAuthenticated.value) {
 *   // User is logged in
 * }
 *
 * if (isAdmin.value) {
 *   // User has admin role
 * }
 *
 * // In a route guard or component:
 * requireAuth() // Throws error if not authenticated
 * requireAdmin() // Throws error if not admin
 */

import { computed } from 'vue'
import { useUserStore } from '../stores/userStore'
import type { User } from '../services/types'
import type { ComputedRef } from 'vue'

export interface Auth {
  isAuthenticated: ComputedRef<boolean>
  isAdmin: ComputedRef<boolean>
  currentUser: ComputedRef<User | null>
  requireAuth: () => void
  requireAdmin: () => void
  login: (email: string, password: string) => Promise<void>
  signup: (email: string, password: string) => Promise<void>
  logout: () => Promise<void>
}

export function useAuth(): Auth {
  const userStore = useUserStore()

  // Computed properties for reactive auth state
  const isAuthenticated = computed(() => userStore.isAuthenticated)
  const isAdmin = computed(() => userStore.isAdmin)
  const currentUser = computed(() => userStore.currentUser)

  /**
   * Throws error if user is not authenticated
   * Use in route guards or protected components
   */
  const requireAuth = () => {
    if (!userStore.isAuthenticated) {
      throw new Error('Authentication required')
    }
  }

  /**
   * Throws error if user is not admin
   * Use in admin route guards or admin components
   */
  const requireAdmin = () => {
    if (!userStore.isAuthenticated) {
      throw new Error('Authentication required')
    }
    if (!userStore.isAdmin) {
      throw new Error('Admin access required')
    }
  }

  /**
   * Login helper
   * @param email - User email
   * @param password - User password
   */
  const login = async (email: string, password: string) => {
    await userStore.login({ email, password })
  }

  /**
   * Signup helper
   * @param email - User email
   * @param password - User password
   */
  const signup = async (email: string, password: string) => {
    await userStore.signup({ email, password })
  }

  /**
   * Logout helper
   */
  const logout = async () => {
    await userStore.logout()
  }

  return {
    isAuthenticated,
    isAdmin,
    currentUser,
    requireAuth,
    requireAdmin,
    login,
    signup,
    logout
  }
}

/**
 * Route guard for authentication
 * Usage in router:
 *
 * {
 *   path: '/favorites',
 *   component: FavoritesView,
 *   beforeEnter: requireAuthGuard
 * }
 */
export const requireAuthGuard = () => {
  const userStore = useUserStore()
  if (!userStore.isAuthenticated) {
    return { name: 'login' }
  }
}

/**
 * Route guard for admin access
 * Usage in router:
 *
 * {
 *   path: '/admin',
 *   component: AdminLayout,
 *   beforeEnter: requireAdminGuard
 * }
 */
export const requireAdminGuard = () => {
  const userStore = useUserStore()
  if (!userStore.isAuthenticated) {
    return { name: 'login' }
  }
  if (!userStore.isAdmin) {
    return { name: 'home' } // Redirect non-admin users to home
  }
}
