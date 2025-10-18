/**
 * useDebounce Composable
 *
 * Provides debounced value and callback functionality.
 * Useful for search inputs, form validation, API calls on user input.
 *
 * Usage Example 1 - Debounced Value:
 * const searchQuery = ref('')
 * const debouncedQuery = useDebounce(searchQuery, 500)
 *
 * watch(debouncedQuery, (newValue) => {
 *   // Only called 500ms after user stops typing
 *   performSearch(newValue)
 * })
 *
 * Usage Example 2 - Debounced Function:
 * const { debouncedFn } = useDebouncedFn((query: string) => {
 *   performSearch(query)
 * }, 500)
 *
 * debouncedFn(searchQuery.value) // Only executes after 500ms of no calls
 */

import { ref, watch, type Ref } from 'vue'

/**
 * Debounces a ref value
 * @param value - The ref to debounce
 * @param delay - Delay in milliseconds (default: 300)
 * @returns Debounced ref value
 */
export function useDebounce<T>(value: Ref<T>, delay: number = 300): Ref<T> {
  const debouncedValue = ref(value.value) as Ref<T>
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  watch(
    value,
    (newValue) => {
      // Clear existing timeout
      if (timeoutId !== null) {
        clearTimeout(timeoutId)
      }

      // Set new timeout
      timeoutId = setTimeout(() => {
        debouncedValue.value = newValue
      }, delay)
    },
    { immediate: false }
  )

  return debouncedValue
}

/**
 * Creates a debounced function
 * @param fn - The function to debounce
 * @param delay - Delay in milliseconds (default: 300)
 * @returns Object with debouncedFn and cancel method
 */
export function useDebouncedFn<T extends (...args: any[]) => any>(
  fn: T,
  delay: number = 300
) {
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  const debouncedFn = (...args: Parameters<T>) => {
    // Clear existing timeout
    if (timeoutId !== null) {
      clearTimeout(timeoutId)
    }

    // Set new timeout
    timeoutId = setTimeout(() => {
      fn(...args)
    }, delay)
  }

  const cancel = () => {
    if (timeoutId !== null) {
      clearTimeout(timeoutId)
      timeoutId = null
    }
  }

  return {
    debouncedFn,
    cancel
  }
}

/**
 * Creates a debounced ref with immediate and cancel methods
 * @param initialValue - Initial value
 * @param delay - Delay in milliseconds (default: 300)
 * @returns Object with value, debouncedValue, cancel, and immediate methods
 */
export function useDebouncedRef<T>(initialValue: T, delay: number = 300) {
  const value = ref(initialValue) as Ref<T>
  const debouncedValue = ref(initialValue) as Ref<T>
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  watch(
    value,
    (newValue) => {
      // Clear existing timeout
      if (timeoutId !== null) {
        clearTimeout(timeoutId)
      }

      // Set new timeout
      timeoutId = setTimeout(() => {
        debouncedValue.value = newValue
      }, delay)
    },
    { immediate: false }
  )

  const cancel = () => {
    if (timeoutId !== null) {
      clearTimeout(timeoutId)
      timeoutId = null
    }
  }

  const immediate = () => {
    cancel()
    debouncedValue.value = value.value
  }

  return {
    value,
    debouncedValue,
    cancel,
    immediate
  }
}
