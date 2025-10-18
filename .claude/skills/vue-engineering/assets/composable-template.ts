import { ref, computed, watch, onUnmounted, type Ref } from 'vue'

/**
 * Options for configuring the composable
 */
interface UseCounterOptions {
  /**
   * Initial value for the counter
   * @default 0
   */
  initialValue?: number

  /**
   * Step value for increment/decrement
   * @default 1
   */
  step?: number

  /**
   * Minimum allowed value
   * @default -Infinity
   */
  min?: number

  /**
   * Maximum allowed value
   * @default Infinity
   */
  max?: number

  /**
   * Callback invoked when counter changes
   */
  onChange?: (value: number) => void
}

/**
 * Return type of the composable
 */
interface UseCounterReturn {
  /**
   * Current counter value
   */
  count: Ref<number>

  /**
   * Double the current count
   */
  double: Ref<number>

  /**
   * Whether the counter is at minimum value
   */
  isMin: Ref<boolean>

  /**
   * Whether the counter is at maximum value
   */
  isMax: Ref<boolean>

  /**
   * Increment the counter by step
   */
  increment: () => void

  /**
   * Decrement the counter by step
   */
  decrement: () => void

  /**
   * Set counter to specific value
   */
  set: (value: number) => void

  /**
   * Reset counter to initial value
   */
  reset: () => void
}

/**
 * A reusable counter composable with min/max constraints
 *
 * @example
 * ```ts
 * const { count, increment, decrement, isMax } = useCounter({
 *   initialValue: 5,
 *   step: 2,
 *   max: 10,
 *   onChange: (val) => console.log('Count changed:', val)
 * })
 * ```
 */
export function useCounter(options: UseCounterOptions = {}): UseCounterReturn {
  const {
    initialValue = 0,
    step = 1,
    min = -Infinity,
    max = Infinity,
    onChange
  } = options

  // Validate initial value
  const clampedInitial = Math.max(min, Math.min(max, initialValue))

  // Reactive state
  const count = ref(clampedInitial)

  // Computed values
  const double = computed(() => count.value * 2)

  const isMin = computed(() => count.value <= min)

  const isMax = computed(() => count.value >= max)

  // Methods
  const increment = () => {
    if (count.value + step <= max) {
      count.value += step
    } else {
      count.value = max
    }
  }

  const decrement = () => {
    if (count.value - step >= min) {
      count.value -= step
    } else {
      count.value = min
    }
  }

  const set = (value: number) => {
    count.value = Math.max(min, Math.min(max, value))
  }

  const reset = () => {
    count.value = clampedInitial
  }

  // Watch for changes and invoke callback
  const stopWatch = watch(count, (newValue) => {
    onChange?.(newValue)
  })

  // Cleanup on unmount
  onUnmounted(() => {
    stopWatch()
  })

  return {
    count,
    double,
    isMin,
    isMax,
    increment,
    decrement,
    set,
    reset
  }
}
