# Composables Patterns Guide

## Overview

Composables are reusable functions that leverage Vue 3's Composition API to encapsulate and reuse stateful logic across components. As of 2025, they are the standard approach for code reuse in Vue applications, replacing the old mixins pattern with a more flexible and maintainable solution.

**Core Purpose:**
- Encapsulate reactive state and logic
- Enable code reuse without the drawbacks of mixins
- Organize code by feature rather than by component
- Provide a clear contract for inputs and outputs

### Benefits Over Mixins

**Mixins (Old - Don't Use):**
```javascript
// ❌ Mixins - deprecated pattern
export default {
  mixins: [userMixin, formMixin],
  // Where does 'user' come from? Unclear and error-prone
}
```

**Composables (Modern):**
```javascript
// ✅ Composables - clear and explicit
import { useUser } from '@/composables/useUser'
import { useForm } from '@/composables/useForm'

const { user, loadUser } = useUser()
const { formData, submitForm } = useForm()
// Crystal clear where each value comes from
```

**Why composables won:**
1. **Clear Data Source**: Explicit returns vs. unclear mixin sources
2. **No Naming Conflicts**: Explicit returns prevent property overwrites
3. **Better Type Inference**: TypeScript works naturally
4. **Flexible Composition**: Multiple composables compose without conflicts
5. **Tree-shakeable**: Unused composables aren't bundled

---

## Naming Conventions

### The `use*` Prefix

All composables should start with `use` prefix followed by camelCase:

```javascript
useCounter()      // Manages counter state
useUser()         // Handles user data and operations
useMouse()        // Tracks mouse position
useFetch()        // Handles API requests
useLocalStorage() // Manages localStorage
useDebounce()     // Provides debounced values
```

**Naming Guidelines:**
1. Be descriptive
2. Use domain language
3. Avoid abbreviations
4. Keep consistent project-wide

**File Structure:**
```
src/
  composables/
    useCounter.js
    useUser.js
    useFetch.js
```

---

## Composable Structure

### Accept Flexible Arguments

Accept both refs AND plain values using `toValue()`:

```javascript
import { ref, watch, toValue } from 'vue'

// ✅ Good - accepts both refs and plain values
export function useDebounce(value, delay = 300) {
  const debouncedValue = ref(toValue(value))

  watch(
    () => toValue(value),
    (newValue) => {
      setTimeout(() => {
        debouncedValue.value = newValue
      }, toValue(delay))
    }
  )

  return debouncedValue
}

// Usage - works with both
const searchTerm = ref('hello')
const debouncedSearch = useDebounce(searchTerm, 500)
const debouncedStatic = useDebounce('static', 500)
```

### Use Options Object for Configuration

```javascript
import { ref, onMounted } from 'vue'

// ✅ Good - options object with defaults
export function useFetch(url, options = {}) {
  const {
    immediate = true,
    refetch = false,
    initialData = null,
    onError = null,
    onSuccess = null
  } = options

  const data = ref(initialData)
  const loading = ref(false)
  const error = ref(null)

  async function execute() {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(toValue(url))
      if (!response.ok) throw new Error(response.statusText)
      data.value = await response.json()
      onSuccess?.(data.value)
    } catch (e) {
      error.value = e
      onError?.(e)
    } finally {
      loading.value = false
    }
  }

  if (immediate) {
    onMounted(execute)
  }

  return { data, loading, error, execute }
}
```

### Return Refs for Reactivity

```javascript
import { ref, computed } from 'vue'

// ✅ Good - returns reactive values
export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const doubleCount = computed(() => count.value * 2)

  function increment() {
    count.value++
  }

  function decrement() {
    count.value--
  }

  function reset() {
    count.value = initialValue
  }

  return {
    count,        // ref
    doubleCount,  // computed (ref)
    increment,    // function
    decrement,    // function
    reset         // function
  }
}

// ❌ Bad - returns plain value (not reactive)
export function useCounterBad(initialValue = 0) {
  const count = ref(initialValue)

  return {
    count: count.value, // ❌ Loses reactivity!
    increment: () => count.value++
  }
}
```

### Externalize Non-Reactive Code

```javascript
// ✅ Good - pure functions outside
function calculateTax(amount, rate) {
  return amount * rate
}

function formatCurrency(value) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
  }).format(value)
}

export function useShoppingCart() {
  const items = ref([])

  const subtotal = computed(() => {
    return items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  })

  const tax = computed(() => calculateTax(subtotal.value, 0.08))
  const total = computed(() => subtotal.value + tax.value)
  const formattedTotal = computed(() => formatCurrency(total.value))

  function addItem(item) {
    items.value.push(item)
  }

  return { items, subtotal, tax, total, formattedTotal, addItem }
}
```

---

## Common Patterns

### 1. API/Data Fetching Composable

```javascript
import { ref, watch, toValue } from 'vue'

export function useFetch(url, options = {}) {
  const {
    immediate = true,
    refetch = false,
    initialData = null
  } = options

  const data = ref(initialData)
  const loading = ref(false)
  const error = ref(null)
  const abortController = ref(null)

  async function execute() {
    if (abortController.value) {
      abortController.value.abort()
    }

    abortController.value = new AbortController()
    loading.value = true
    error.value = null

    try {
      const response = await fetch(toValue(url), {
        signal: abortController.value.signal
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }

      data.value = await response.json()
      return data.value
    } catch (e) {
      if (e.name === 'AbortError') return
      error.value = e
      throw e
    } finally {
      loading.value = false
      abortController.value = null
    }
  }

  if (immediate) {
    execute()
  }

  if (refetch) {
    watch(() => toValue(url), execute)
  }

  return {
    data,
    loading,
    error,
    execute,
    abort: () => abortController.value?.abort()
  }
}
```

### 2. Event Listener Composable

```javascript
import { onUnmounted, toValue } from 'vue'

export function useEventListener(target, event, handler, options = {}) {
  let cleanup = () => {}

  const register = () => {
    const targetEl = toValue(target)
    if (!targetEl) return

    const events = Array.isArray(event) ? event : [event]

    events.forEach(evt => {
      targetEl.addEventListener(evt, handler, options)
    })

    cleanup = () => {
      events.forEach(evt => {
        targetEl.removeEventListener(evt, handler, options)
      })
    }
  }

  if (toValue(target)) {
    register()
  }

  onUnmounted(cleanup)

  return cleanup
}

// Usage
useEventListener(window, 'resize', () => {
  console.log('Window resized')
})

// Multiple events
useEventListener(window, ['focus', 'blur'], (e) => {
  console.log('Focus changed:', e.type)
})
```

### 3. Form Validation Composable

```javascript
import { ref, reactive, computed } from 'vue'

export function useForm(initialValues = {}, validationRules = {}) {
  const values = reactive({ ...initialValues })
  const errors = reactive({})
  const touched = reactive({})
  const isSubmitting = ref(false)

  function validateField(field) {
    const rules = validationRules[field]
    if (!rules) return true

    const value = values[field]

    for (const rule of rules) {
      const error = rule(value, values)
      if (error) {
        errors[field] = error
        return false
      }
    }

    errors[field] = null
    return true
  }

  function validateAll() {
    let isValid = true
    Object.keys(validationRules).forEach(field => {
      if (!validateField(field)) {
        isValid = false
      }
    })
    return isValid
  }

  function setFieldValue(field, value) {
    values[field] = value
    if (touched[field]) {
      validateField(field)
    }
  }

  function setFieldTouched(field, isTouched = true) {
    touched[field] = isTouched
    if (isTouched) {
      validateField(field)
    }
  }

  async function handleSubmit(onSubmit) {
    Object.keys(values).forEach(key => {
      touched[key] = true
    })

    const isValid = validateAll()
    if (!isValid) return

    isSubmitting.value = true
    try {
      await onSubmit(values)
    } finally {
      isSubmitting.value = false
    }
  }

  const isValid = computed(() => {
    return Object.keys(validationRules).every(field => !errors[field])
  })

  return {
    values,
    errors,
    touched,
    isSubmitting,
    isValid,
    setFieldValue,
    setFieldTouched,
    handleSubmit
  }
}

// Validation helpers
export const required = (message = 'Required') => {
  return (value) => {
    if (!value || (typeof value === 'string' && !value.trim())) {
      return message
    }
    return null
  }
}

export const email = (message = 'Invalid email') => {
  return (value) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (value && !emailRegex.test(value)) {
      return message
    }
    return null
  }
}
```

---

## Best Practices

### 1. Keep Composables Focused (Single Responsibility)

```javascript
// ✅ Good - focused composables
export function useLocalStorage(key, initialValue) {
  // Only handles localStorage
}

export function useDebounce(value, delay) {
  // Only handles debouncing
}

// ❌ Bad - trying to do too much
export function useDataManager(key, value, debounce, storage) {
  // Handles localStorage, sessionStorage, debouncing, validation
  // Too complex and hard to maintain
}
```

### 2. Document Parameters and Return Values

```javascript
/**
 * Manages a counter with increment, decrement, and reset functionality
 *
 * @param {number} initialValue - Starting count value (default: 0)
 * @param {Object} options - Configuration options
 * @param {number} options.min - Minimum allowed value
 * @param {number} options.max - Maximum allowed value
 * @param {number} options.step - Increment/decrement step (default: 1)
 *
 * @returns {Object} Counter state and methods
 * @returns {Ref<number>} count - Current count value
 * @returns {ComputedRef<boolean>} isAtMin - Whether at minimum
 * @returns {ComputedRef<boolean>} isAtMax - Whether at maximum
 * @returns {Function} increment - Increase count
 * @returns {Function} decrement - Decrease count
 * @returns {Function} reset - Reset to initial value
 */
export function useCounter(initialValue = 0, options = {}) {
  // Implementation
}
```

### 3. Handle Cleanup Properly

```javascript
import { onUnmounted, ref } from 'vue'

// ✅ Good - proper cleanup
export function useInterval(callback, interval) {
  const timer = ref(null)

  function start() {
    if (timer.value) return
    timer.value = setInterval(callback, interval)
  }

  function stop() {
    if (timer.value) {
      clearInterval(timer.value)
      timer.value = null
    }
  }

  onUnmounted(stop)

  return { start, stop }
}
```

**Common cleanup scenarios:**
- Event listeners
- Timers (setTimeout, setInterval)
- WebSocket connections
- Animation frames
- Observers (IntersectionObserver, MutationObserver)
- Subscriptions

### 4. Make Composables Testable

```javascript
// ✅ Good - dependency injection for testability
export function useApi(fetcher = fetch) {
  const data = ref(null)
  const loading = ref(false)

  async function get(url) {
    loading.value = true
    try {
      const response = await fetcher(url)
      data.value = await response.json()
    } finally {
      loading.value = false
    }
  }

  return { data, loading, get }
}

// Easy to test with mock
const mockFetch = vi.fn()
const { data, get } = useApi(mockFetch)
```

### 5. Use TypeScript for Type Safety

```typescript
import { ref, computed, type Ref, type ComputedRef } from 'vue'

interface User {
  id: number
  name: string
  email: string
}

interface UseUserOptions {
  autoFetch?: boolean
  onError?: (error: Error) => void
}

interface UseUserReturn {
  user: Ref<User | null>
  loading: Ref<boolean>
  error: Ref<Error | null>
  isLoggedIn: ComputedRef<boolean>
  fetchUser: (id: number) => Promise<void>
}

export function useUser(options: UseUserOptions = {}): UseUserReturn {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const isLoggedIn = computed(() => user.value !== null)

  async function fetchUser(id: number): Promise<void> {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(`/api/users/${id}`)
      if (!response.ok) throw new Error('Failed to fetch user')
      user.value = await response.json()
    } catch (e) {
      error.value = e as Error
      options.onError?.(e as Error)
    } finally {
      loading.value = false
    }
  }

  return {
    user,
    loading,
    error,
    isLoggedIn,
    fetchUser
  }
}
```

---

## Real-World Examples

### useCounter

```javascript
import { ref, computed } from 'vue'

export function useCounter(initialValue = 0, options = {}) {
  const {
    min = -Infinity,
    max = Infinity,
    step = 1
  } = options

  const count = ref(initialValue)

  const isAtMin = computed(() => count.value <= min)
  const isAtMax = computed(() => count.value >= max)

  function increment(delta = step) {
    const newValue = count.value + delta
    count.value = Math.min(newValue, max)
  }

  function decrement(delta = step) {
    const newValue = count.value - delta
    count.value = Math.max(newValue, min)
  }

  function set(value) {
    count.value = Math.max(min, Math.min(max, value))
  }

  function reset() {
    count.value = initialValue
  }

  return {
    count,
    isAtMin,
    isAtMax,
    increment,
    decrement,
    set,
    reset
  }
}

// Usage
const { count, increment, decrement, isAtMax } = useCounter(0, {
  min: 0,
  max: 10
})
```

### useLocalStorage

```javascript
import { ref, watch, onUnmounted } from 'vue'

export function useLocalStorage(key, initialValue, options = {}) {
  const {
    serializer = JSON,
    onError = (error) => console.error(error)
  } = options

  function readValue() {
    try {
      const item = window.localStorage.getItem(key)
      return item ? serializer.parse(item) : initialValue
    } catch (error) {
      onError(error)
      return initialValue
    }
  }

  const storedValue = ref(readValue())

  function writeValue(value) {
    try {
      window.localStorage.setItem(key, serializer.stringify(value))
    } catch (error) {
      onError(error)
    }
  }

  watch(storedValue, (newValue) => {
    writeValue(newValue)
  }, { deep: true })

  function handleStorageChange(e) {
    if (e.key === key && e.newValue) {
      try {
        storedValue.value = serializer.parse(e.newValue)
      } catch (error) {
        onError(error)
      }
    }
  }

  window.addEventListener('storage', handleStorageChange)

  onUnmounted(() => {
    window.removeEventListener('storage', handleStorageChange)
  })

  return storedValue
}

// Usage
const theme = useLocalStorage('theme', 'light')
const userPrefs = useLocalStorage('preferences', {
  notifications: true,
  language: 'en'
})
```

---

## Testing Composables

### Basic Test Setup

```javascript
import { describe, it, expect } from 'vitest'
import { useCounter } from '@/composables/useCounter'

describe('useCounter', () => {
  it('initializes with default value', () => {
    const { count } = useCounter()
    expect(count.value).toBe(0)
  })

  it('increments count', () => {
    const { count, increment } = useCounter(0)
    increment()
    expect(count.value).toBe(1)
  })

  it('respects min boundary', () => {
    const { count, decrement } = useCounter(0, { min: 0 })
    decrement()
    expect(count.value).toBe(0)
  })

  it('respects max boundary', () => {
    const { count, increment } = useCounter(9, { max: 10 })
    increment()
    increment()
    expect(count.value).toBe(10)
  })
})
```

### Testing with Component Wrapper

```javascript
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { defineComponent, h } from 'vue'
import { useFetch } from '@/composables/useFetch'

function mountComposable(composable) {
  let result
  const component = defineComponent({
    setup() {
      result = composable()
      return () => h('div')
    }
  })

  const wrapper = mount(component)
  return { result, wrapper }
}

describe('useFetch', () => {
  it('fetches data successfully', async () => {
    const mockData = { id: 1, name: 'Test' }
    global.fetch = vi.fn().mockResolvedValueOnce({
      ok: true,
      json: async () => mockData
    })

    const { result } = mountComposable(() =>
      useFetch('/api/test', { immediate: false })
    )

    await result.execute()

    expect(result.loading.value).toBe(false)
    expect(result.data.value).toEqual(mockData)
    expect(result.error.value).toBe(null)
  })
})
```

---

## Summary

**Key Takeaways:**

1. **What are Composables**: Functions leveraging Composition API to encapsulate and reuse stateful logic across components

2. **Naming**: Always use `use*` prefix (useCounter, useFetch, etc.)

3. **Structure Best Practices**:
   - Accept flexible arguments (refs and plain values)
   - Use options objects for configuration
   - Return refs for reactivity
   - Externalize pure functions

4. **Common Patterns**: Data fetching, event listeners, and form validation

5. **Best Practices**:
   - Single responsibility principle
   - Comprehensive documentation
   - Proper cleanup of side effects
   - Design for testability
   - TypeScript for type safety

6. **Testing**: Use component wrappers for lifecycle hooks, mock dependencies, write comprehensive unit tests

7. **Real-World Reference**: Study VueUse for production-ready patterns

Composables are the foundation of modern Vue 3 development. Master these patterns to build maintainable, reusable, and scalable applications.
