/**
 * useToast Composable
 *
 * Provides toast notification functionality using the uiStore.
 * Simple wrapper around uiStore notification methods for convenience.
 *
 * Usage:
 * const toast = useToast()
 *
 * toast.showSuccess('Recipe saved successfully!')
 * toast.showError('Failed to save recipe')
 * toast.showWarning('Recipe has unsaved changes')
 * toast.showInfo('Loading recipes...')
 */

import { useUiStore } from '../stores/uiStore'

export interface Toast {
  showSuccess: (message: string, duration?: number) => number
  showError: (message: string, duration?: number) => number
  showWarning: (message: string, duration?: number) => number
  showInfo: (message: string, duration?: number) => number
  dismiss: (id: number) => void
  dismissAll: () => void
}

export function useToast(): Toast {
  const uiStore = useUiStore()

  return {
    /**
     * Show success toast
     * @param message - Success message to display
     * @param duration - Duration in milliseconds (default: 5000)
     * @returns Notification ID
     */
    showSuccess(message: string, duration = 5000): number {
      return uiStore.showSuccess(message, duration)
    },

    /**
     * Show error toast
     * @param message - Error message to display
     * @param duration - Duration in milliseconds (default: 7000)
     * @returns Notification ID
     */
    showError(message: string, duration = 7000): number {
      return uiStore.showError(message, duration)
    },

    /**
     * Show warning toast
     * @param message - Warning message to display
     * @param duration - Duration in milliseconds (default: 6000)
     * @returns Notification ID
     */
    showWarning(message: string, duration = 6000): number {
      return uiStore.showWarning(message, duration)
    },

    /**
     * Show info toast
     * @param message - Info message to display
     * @param duration - Duration in milliseconds (default: 5000)
     * @returns Notification ID
     */
    showInfo(message: string, duration = 5000): number {
      return uiStore.showInfo(message, duration)
    },

    /**
     * Dismiss a specific notification by ID
     * @param id - Notification ID to dismiss
     */
    dismiss(id: number): void {
      uiStore.removeNotification(id)
    },

    /**
     * Dismiss all notifications
     */
    dismissAll(): void {
      uiStore.clearNotifications()
    }
  }
}
