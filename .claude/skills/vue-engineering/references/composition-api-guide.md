# Composition API Guide

## Overview

The Composition API is Vue 3's primary way of organizing component logic. As of 2025, it is the de facto standard for new Vue codebases, offering improved modularity, reusability, and scalability over the Options API.

## Why Composition API?

**Key Benefits:**
- Better logic reuse through composables
- Superior TypeScript integration
- Clearer code organization by grouping related logic together
- Easier to understand component behavior
- Improved performance in large applications

## `<script setup>` Syntax

`<script setup>` is the recommended way to use Composition API in Single-File Components (SFCs). It's a compile-time syntactic sugar that provides:

- Better runtime performance
- Better IDE type-inference performance
- Less boilerplate code
- Direct template access to top-level bindings

###

 Basic Syntax

```vue
<script setup>
import { ref, computed, onMounted } from 'vue'

// Top-level bindings are automatically available in template
const count = ref(0)
const double = computed(() => count.value * 2)

function increment() {
  count.value++
}

onMounted(() => {
  console.log('Component is mounted!')
})
</script>

<template>
  <div>
    <p>Count: {{ count }}</p>
    <p>Double: {{ double }}</p>
    <button @click="increment">Increment</button>
  </div>
</template>
```

**Key Points:**
- No need to return values - top-level bindings are automatically exposed to template
- Imports are directly usable
- Executes on every component instance creation

---

## Core APIs

### defineProps()

Declare component props with type safety and runtime validation.

```vue
<script setup lang="ts">
// Basic props
const props = defineProps<{
  title: string
  count?: number
}>()

// With defaults (Vue 3.5+ Reactive Props Destructure)
const { title, count = 0 } = defineProps<{
  title: string
  count?: number
}>()

// Runtime validation (JavaScript)
const props = defineProps({
  title: {
    type: String,
    required: true
  },
  count: {
    type: Number,
    default: 0,
    validator: (value) => value >= 0
  }
})
</script>
```

**Important:**
- `defineProps()` is a compiler macro - don't import it
- Props are reactive and read-only
- Use `withDefaults()` for default values in TypeScript (pre-3.5)

### defineEmits()

Declare component events with type safety.

```vue
<script setup lang="ts">
// Type-based declaration (TypeScript)
const emit = defineEmits<{
  update: [id: number]
  submit: [data: FormData]
  close: []
}>()

// Runtime declaration (JavaScript)
const emit = defineEmits(['update', 'submit', 'close'])

// Emit events
function handleUpdate() {
  emit('update', 123)
}

function handleSubmit(data: FormData) {
  emit('submit', data)
}
</script>
```

**Best Practices:**
- Use TypeScript declarations for type safety
- Document event payloads clearly
- Follow naming conventions (kebab-case in templates, camelCase in script)

### defineExpose()

Expose properties/methods to parent components (via template refs).

```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)
const increment = () => count.value++

// Explicitly expose to parent
defineExpose({
  count,
  increment
})
</script>
```

**When to use:**
- When parent needs to call child methods
- When using template refs to access child component
- By default, `<script setup>` components are "closed" - nothing is exposed

### defineSlots()

Type slots for better IDE support (TypeScript only).

```vue
<script setup lang="ts">
const slots = defineSlots<{
  default(props: { msg: string }): any
  header(): any
}>()
</script>
```

---

## Lifecycle Hooks

All lifecycle hooks must be imported and called inside `<script setup>`.

### Available Hooks

```vue
<script setup>
import {
  onBeforeMount,
  onMounted,
  onBeforeUpdate,
  onUpdated,
  onBeforeUnmount,
  onUnmounted,
  onErrorCaptured,
  onActivated,      // for <keep-alive>
  onDeactivated     // for <keep-alive>
} from 'vue'

onBeforeMount(() => {
  console.log('Before mount')
})

onMounted(() => {
  console.log('Component mounted')
  // DOM is available
  // Good for: API calls, third-party library initialization
})

onBeforeUpdate(() => {
  console.log('Before update')
})

onUpdated(() => {
  console.log('After update')
  // DOM has been updated
})

onBeforeUnmount(() => {
  console.log('Before unmount')
  // Good for: cleanup warnings
})

onUnmounted(() => {
  console.log('Component unmounted')
  // Good for: cleanup (event listeners, timers, subscriptions)
})

onErrorCaptured((err, instance, info) => {
  console.error('Error captured:', err, info)
  return false // Propagate error
})
</script>
```

### Common Patterns

**API Calls on Mount:**
```vue
<script setup>
import { ref, onMounted } from 'vue'

const data = ref(null)
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    const response = await fetch('/api/data')
    data.value = await response.json()
  } catch (e) {
    error.value = e
  } finally {
    loading.value = false
  }
})
</script>
```

**Cleanup on Unmount:**
```vue
<script setup>
import { onMounted, onUnmounted } from 'vue'

let timer = null

onMounted(() => {
  timer = setInterval(() => {
    console.log('Tick')
  }, 1000)
})

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
})
</script>
```

---

## Template Refs

Access DOM elements or child component instances.

```vue
<script setup>
import { ref, onMounted } from 'vue'

// DOM element ref
const inputRef = ref(null)

// Component instance ref
const childRef = ref(null)

onMounted(() => {
  // Access DOM element
  inputRef.value?.focus()

  // Access child component (if exposed via defineExpose)
  childRef.value?.increment()
})
</script>

<template>
  <input ref="inputRef" />
  <ChildComponent ref="childRef" />
</template>
```

**Dynamic Refs (v-for):**
```vue
<script setup>
import { ref, onMounted } from 'vue'

const itemRefs = ref([])

onMounted(() => {
  console.log(itemRefs.value) // Array of DOM elements
})
</script>

<template>
  <div
    v-for="item in list"
    :key="item.id"
    :ref="el => { if (el) itemRefs.push(el) }"
  >
    {{ item.name }}
  </div>
</template>
```

---

## Using with Normal `<script>`

Combine `<script setup>` with normal `<script>` when needed.

```vue
<script>
// Options not expressible in <script setup>
export default {
  inheritAttrs: false,
  customOptions: {
    /* ... */
  }
}
</script>

<script setup>
// Composition API code here
import { ref } from 'vue'
const count = ref(0)
</script>
```

**Common use cases:**
- Declaring `inheritAttrs: false`
- Registering custom options for plugins
- Declaring module-level side effects that should run once

---

## Reactivity Transform (Deprecated)

**Note:** Reactivity Transform was experimental and has been deprecated as of Vue 3.4. Don't use it in new code.

Instead of:
```vue
<!-- DON'T USE - Deprecated -->
<script setup>
let count = $ref(0) // Deprecated
</script>
```

Use standard refs:
```vue
<script setup>
import { ref } from 'vue'
const count = ref(0) // Correct
</script>
```

---

## TypeScript Support

`<script setup>` provides excellent TypeScript support.

### Generic Components

```vue
<script setup lang="ts" generic="T">
defineProps<{
  items: T[]
  selected: T
}>()
</script>
```

### Type Imports

```vue
<script setup lang="ts">
import type { User } from '@/types'

defineProps<{
  user: User
}>()
</script>
```

---

## Best Practices

### 1. Use `<script setup>` by Default
It's the 2025 standard - cleaner syntax, better performance, better IDE support.

### 2. Group Related Logic
```vue
<script setup>
import { ref, computed, watch } from 'vue'

// ========== User data ==========
const user = ref(null)
const userName = computed(() => user.value?.name)

watch(user, (newUser) => {
  console.log('User changed:', newUser)
})

// ========== Form handling ==========
const formData = ref({})
const isValid = computed(() => validateForm(formData.value))

function submitForm() {
  // ...
}
</script>
```

### 3. Extract Complex Logic to Composables
```vue
<script setup>
import { useUser } from '@/composables/useUser'
import { useForm } from '@/composables/useForm'

const { user, userName, loadUser } = useUser()
const { formData, isValid, submitForm } = useForm()
</script>
```

### 4. Always Clean Up Side Effects
```vue
<script setup>
import { onUnmounted } from 'vue'

const cleanup = setupSomeFeature()

onUnmounted(() => {
  cleanup()
})
</script>
```

### 5. Use TypeScript for Large Projects
```vue
<script setup lang="ts">
// Better type safety, IDE support, and refactoring
</script>
```

---

## Common Patterns

### Async Setup

```vue
<script setup>
import { ref } from 'vue'

const data = ref(null)

// Top-level await is supported
const response = await fetch('/api/data')
data.value = await response.json()

// Component will be rendered after await resolves
// Use with <Suspense> in parent
</script>
```

### Multiple Script Blocks

```vue
<script>
// Module-level code (runs once)
import { someGlobalSetup } from '@/utils'
someGlobalSetup()
</script>

<script setup>
// Component code (runs per instance)
import { ref } from 'vue'
const count = ref(0)
</script>
```

---

## Migration from Options API

If you have existing Options API components:

**Options API:**
```vue
<script>
export default {
  data() {
    return {
      count: 0
    }
  },
  computed: {
    double() {
      return this.count * 2
    }
  },
  methods: {
    increment() {
      this.count++
    }
  },
  mounted() {
    console.log('Mounted')
  }
}
</script>
```

**Composition API (script setup):**
```vue
<script setup>
import { ref, computed, onMounted } from 'vue'

const count = ref(0)
const double = computed(() => count.value * 2)

function increment() {
  count.value++
}

onMounted(() => {
  console.log('Mounted')
})
</script>
```

**Migration Tips:**
- `data()` → `ref()` or `reactive()`
- `computed` → `computed()`
- `methods` → regular functions
- `mounted()` → `onMounted()`
- No `this` keyword needed
- Gradual migration is fine - mix Options API and Composition API components

---

## Summary

**Key Takeaways:**
- Use `<script setup>` for all new components (2025 standard)
- Import lifecycle hooks before using them
- Props and emits are declared with compiler macros
- Template refs give access to DOM and child components
- Combine with normal `<script>` for special options
- Extract reusable logic into composables
- TypeScript provides excellent type safety

The Composition API with `<script setup>` syntax provides a modern, clean, and powerful way to build Vue 3 components.
