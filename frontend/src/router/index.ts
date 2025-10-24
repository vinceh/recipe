import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import AdminLayout from '@/components/admin/layout/AdminLayout.vue'
import { useUserStore } from '@/stores/userStore'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue'),
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
    },
    {
      path: '/admin/login',
      name: 'admin-login',
      component: () => import('../views/admin/AdminLoginView.vue'),
    },
    {
      path: '/admin',
      component: AdminLayout,
      meta: { requiresAdmin: true },
      children: [
        {
          path: '',
          name: 'admin-dashboard',
          component: () => import('@/views/admin/AdminDashboard.vue'),
        },
        {
          path: 'recipes',
          name: 'admin-recipes',
          component: () => import('@/views/admin/AdminRecipes.vue'),
        },
        {
          path: 'recipes/new',
          name: 'admin-recipe-new',
          component: () => import('@/views/admin/AdminRecipeNew.vue'),
        },
        {
          path: 'recipes/:id',
          name: 'admin-recipe-detail',
          component: () => import('@/views/admin/AdminRecipeDetail.vue'),
        },
        {
          path: 'data-references',
          name: 'admin-data-references',
          component: () => import('@/views/admin/AdminDataReferences.vue'),
        },
        {
          path: 'prompts',
          name: 'admin-prompts',
          component: () => import('@/views/admin/AdminPrompts.vue'),
        },
        {
          path: 'ingredients',
          name: 'admin-ingredients',
          component: () => import('@/views/admin/AdminIngredients.vue'),
        },
        {
          path: 'settings',
          name: 'admin-settings',
          component: () => import('@/views/admin/AdminSettings.vue'),
        },
        {
          path: 'help',
          name: 'admin-help',
          component: () => import('@/views/admin/AdminHelp.vue'),
        },
        {
          path: 'profile',
          name: 'admin-profile',
          component: () => import('@/views/admin/AdminProfile.vue'),
        },
      ],
    },
  ],
})

// Global navigation guard for authentication
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()

  // Wait for store initialization if auth token exists
  if (userStore.authToken && !userStore.currentUser) {
    await userStore.initialize()
  }

  // Redirect authenticated admins away from admin login page
  if (to.name === 'admin-login' && userStore.isAuthenticated && userStore.isAdmin) {
    next({ name: 'admin-dashboard' })
    return
  }

  // Check if route requires admin access
  if (to.meta.requiresAdmin) {
    if (!userStore.isAuthenticated) {
      // Not logged in, redirect to admin login
      next({ name: 'admin-login', query: { redirect: to.fullPath } })
    } else if (!userStore.isAdmin) {
      // Logged in but not admin, redirect to home
      next({ name: 'home' })
    } else {
      // Is admin, allow access
      next()
    }
  } else {
    // Route doesn't require admin, allow access
    next()
  }
})

export default router
