import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export type Language = 'en' | 'ja' | 'ko' | 'zh-tw' | 'zh-cn' | 'es' | 'fr'
export type Theme = 'light' | 'dark' | 'auto'
export type ViewMode = 'grid' | 'list'

// Import i18n instance directly
import { i18n } from '@/plugins/i18n'

export const useUiStore = defineStore('ui', () => {
  // State
  const language = ref<Language>((localStorage.getItem('locale') as Language) || 'en')
  const theme = ref<Theme>((localStorage.getItem('theme') as Theme) || 'auto')
  const viewMode = ref<ViewMode>((localStorage.getItem('viewMode') as ViewMode) || 'grid')
  const sidebarOpen = ref(true)
  const mobileMenuOpen = ref(false)
  const notifications = ref<Notification[]>([])

  interface Notification {
    id: number
    type: 'success' | 'error' | 'warning' | 'info'
    message: string
    duration?: number
  }

  // Getters
  const isDarkMode = computed(() => {
    if (theme.value === 'dark') return true
    if (theme.value === 'light') return false
    // Auto mode - check system preference
    return window.matchMedia('(prefers-color-scheme: dark)').matches
  })

  const isRTL = computed(() => {
    // RTL languages not supported in MVP
    return false
  })

  const hasNotifications = computed(() => notifications.value.length > 0)

  // Actions
  function setLanguage(newLanguage: Language) {
    language.value = newLanguage
    // Update Vue I18n locale using global instance
    i18n.global.locale.value = newLanguage
    localStorage.setItem('locale', newLanguage)
    document.documentElement.lang = newLanguage

    // Update RTL attribute if needed
    if (isRTL.value) {
      document.documentElement.dir = 'rtl'
    } else {
      document.documentElement.dir = 'ltr'
    }
  }

  function setTheme(newTheme: Theme) {
    theme.value = newTheme
    localStorage.setItem('theme', newTheme)

    // Update theme class on document
    if (isDarkMode.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  function setViewMode(mode: ViewMode) {
    viewMode.value = mode
    localStorage.setItem('viewMode', mode)
  }

  function toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value
  }

  function toggleMobileMenu() {
    mobileMenuOpen.value = !mobileMenuOpen.value
  }

  function closeMobileMenu() {
    mobileMenuOpen.value = false
  }

  function showNotification(
    type: Notification['type'],
    message: string,
    duration = 5000
  ) {
    const id = Date.now()
    const notification: Notification = { id, type, message, duration }

    notifications.value.push(notification)

    if (duration > 0) {
      setTimeout(() => {
        removeNotification(id)
      }, duration)
    }

    return id
  }

  function removeNotification(id: number) {
    notifications.value = notifications.value.filter(n => n.id !== id)
  }

  function clearNotifications() {
    notifications.value = []
  }

  function showSuccess(message: string, duration = 5000) {
    return showNotification('success', message, duration)
  }

  function showError(message: string, duration = 7000) {
    return showNotification('error', message, duration)
  }

  function showWarning(message: string, duration = 6000) {
    return showNotification('warning', message, duration)
  }

  function showInfo(message: string, duration = 5000) {
    return showNotification('info', message, duration)
  }

  // Initialize theme on store creation
  function initialize() {
    setTheme(theme.value)
    setLanguage(language.value)
  }

  return {
    // State
    language,
    theme,
    viewMode,
    sidebarOpen,
    mobileMenuOpen,
    notifications,

    // Getters
    isDarkMode,
    isRTL,
    hasNotifications,

    // Actions
    setLanguage,
    setTheme,
    setViewMode,
    toggleSidebar,
    toggleMobileMenu,
    closeMobileMenu,
    showNotification,
    removeNotification,
    clearNotifications,
    showSuccess,
    showError,
    showWarning,
    showInfo,
    initialize
  }
})
