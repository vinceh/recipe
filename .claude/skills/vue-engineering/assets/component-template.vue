<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'

/**
 * Component Props
 */
interface Props {
  title: string
  count?: number
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
  disabled: false
})

/**
 * Component Emits
 */
interface Emits {
  update: [value: number]
  submit: [data: { count: number; timestamp: number }]
  close: []
}

const emit = defineEmits<Emits>()

/**
 * Reactive State
 */
const internalCount = ref(props.count)
const isProcessing = ref(false)

/**
 * Computed Properties
 */
const displayText = computed(() => `${props.title}: ${internalCount.value}`)

const canSubmit = computed(() => !props.disabled && !isProcessing.value)

/**
 * Methods
 */
function handleIncrement() {
  if (props.disabled) return

  internalCount.value++
  emit('update', internalCount.value)
}

function handleDecrement() {
  if (props.disabled || internalCount.value <= 0) return

  internalCount.value--
  emit('update', internalCount.value)
}

async function handleSubmit() {
  if (!canSubmit.value) return

  isProcessing.value = true

  try {
    // Simulate async operation
    await new Promise(resolve => setTimeout(resolve, 1000))

    emit('submit', {
      count: internalCount.value,
      timestamp: Date.now()
    })

    emit('close')
  } catch (error) {
    console.error('Submit failed:', error)
  } finally {
    isProcessing.value = false
  }
}

/**
 * Lifecycle Hooks
 */
onMounted(() => {
  console.log('Component mounted:', props.title)
  // Initialize third-party libraries, fetch data, etc.
})

onUnmounted(() => {
  console.log('Component unmounted')
  // Clean up: remove event listeners, clear timers, etc.
})
</script>

<template>
  <div class="component-container">
    <h2 class="component-title">{{ displayText }}</h2>

    <div class="component-content">
      <div class="counter-display">
        Current Count: {{ internalCount }}
      </div>

      <div class="button-group">
        <button
          class="btn btn-secondary"
          :disabled="disabled || internalCount <= 0"
          @click="handleDecrement"
        >
          Decrement
        </button>

        <button
          class="btn btn-primary"
          :disabled="disabled"
          @click="handleIncrement"
        >
          Increment
        </button>
      </div>

      <button
        class="btn btn-success"
        :disabled="!canSubmit"
        @click="handleSubmit"
      >
        {{ isProcessing ? 'Processing...' : 'Submit' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.component-container {
  padding: 1.5rem;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  background-color: white;
}

.component-title {
  margin: 0 0 1rem 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: #1f2937;
}

.component-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.counter-display {
  padding: 1rem;
  background-color: #f3f4f6;
  border-radius: 0.375rem;
  text-align: center;
  font-size: 1.125rem;
  font-weight: 500;
}

.button-group {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 0.375rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background-color: #3b82f6;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #2563eb;
}

.btn-secondary {
  background-color: #6b7280;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background-color: #4b5563;
}

.btn-success {
  background-color: #10b981;
  color: white;
  width: 100%;
}

.btn-success:hover:not(:disabled) {
  background-color: #059669;
}
</style>
