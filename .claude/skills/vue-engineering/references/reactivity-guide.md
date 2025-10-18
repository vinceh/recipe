# Vue 3 Reactivity System Guide

## Overview

Vue 3's reactivity system is built on JavaScript Proxies, providing fine-grained reactive state management. This guide covers 2025 best practices for Vue 3.5+.

**Key Benefits:**
- Automatic UI updates when data changes
- Efficient change detection and DOM updates
- Type-safe with TypeScript
- Composable and reusable reactive logic

---

## ref() vs reactive()

### ref()

`ref()` creates a reactive reference to a value, wrapping it in an object with a `.value` property.

```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)
const user = ref({ name: 'John', age: 30 })
const items = ref([1, 2, 3])

// Access using .value
count.value++
user.value.name = 'Jane'
items.value.push(4)
</script>

<template>
  <!-- .value auto-unwrapped in templates -->
  <div>{{ count }}</div>
  <div>{{ user.name }}</div>
</template>
```

**Key Characteristics:**
- Always accessed via `.value` in JavaScript
- Auto-unwrapped in templates (no `.value` needed)
- Works with any value type (primitives, objects, arrays)
- Can be reassigned entirely: `user.value = { name: 'Bob', age: 25 }`
- Better TypeScript inference

### reactive()

`reactive()` creates a reactive proxy of an object. Only works with objects, arrays, Maps, Sets.

```vue
<script setup>
import { reactive } from 'vue'

const state = reactive({
  count: 0,
  message: 'Hello',
  user: { name: 'John', age: 30 }
})

// Access directly (no .value)
state.count++
state.user.name = 'Jane'
</script>
```

**Key Characteristics:**
- No `.value` needed (direct property access)
- Only works with objects, arrays, Maps, Sets
- Cannot be reassigned entirely (loses reactivity)
- Destructuring loses reactivity (unless using `toRefs()`)

### Comparison Table

| Feature | ref() | reactive() |
|---------|-------|------------|
| Works with primitives | Yes | No |
| Works with objects | Yes | Yes |
| Access syntax | `.value` in JS | Direct access |
| Can reassign | Yes | No (loses reactivity) |
| TypeScript inference | Excellent | Good |

### When to Use Each

**Use ref() for:**
- Primitives (strings, numbers, booleans)
- Single values that may be reassigned
- Consistent API across all types

**Use reactive() for:**
- Complex nested state structures
- Form data with multiple fields
- When you want to avoid `.value` syntax

### 2025 Consensus: Prefer ref()

The Vue community increasingly favors `ref()` for:

**1. Consistency:**
```vue
<script setup>
import { ref } from 'vue'

// Single pattern for all types
const count = ref(0)
const user = ref({ name: 'John' })
const items = ref([1, 2, 3])
</script>
```

**2. Reassignment Safety:**
```vue
<script setup>
import { ref, reactive } from 'vue'

// ref() - reassignment works
const user = ref({ name: 'John' })
user.value = { name: 'Jane' } // Reactivity preserved

// reactive() - reassignment breaks reactivity
let state = reactive({ count: 0 })
state = { count: 1 } // Reactivity LOST!
</script>
```

**3. Better TypeScript Support:**
```vue
<script setup lang="ts">
import { ref } from 'vue'

interface User {
  name: string
  age: number
}

const user = ref<User | null>(null)
</script>
```

### Performance Considerations

Both `ref()` and `reactive()` have similar performance. Don't optimize prematurely—choose based on developer experience and consistency.

---

## toRefs()

`toRefs()` converts a reactive object's properties into individual refs, preserving reactivity when destructuring.

### The Problem

```vue
<script setup>
import { reactive } from 'vue'

const state = reactive({
  count: 0,
  message: 'Hello'
})

// WRONG: Loses reactivity
const { count, message } = state
count++ // Component won't update!
</script>
```

### The Solution

```vue
<script setup>
import { reactive, toRefs } from 'vue'

const state = reactive({
  count: 0,
  message: 'Hello'
})

// Preserves reactivity
const { count, message } = toRefs(state)
count.value++ // Component WILL update
</script>
```

### When to Use toRefs()

**Returning from Composables:**
```vue
<script setup>
import { reactive, toRefs } from 'vue'

function useUser() {
  const state = reactive({
    user: null,
    loading: false,
    error: null
  })

  async function loadUser() {
    state.loading = true
    try {
      state.user = await fetchUser()
    } catch (e) {
      state.error = e
    } finally {
      state.loading = false
    }
  }

  return {
    ...toRefs(state),
    loadUser
  }
}

const { user, loading, error, loadUser } = useUser()
</script>
```

**toRef() for Single Properties:**
```vue
<script setup>
import { reactive, toRef } from 'vue'

const state = reactive({ count: 0 })
const count = toRef(state, 'count')

count.value++ // Updates state.count
</script>
```

---

## Computed Properties

Computed properties create reactive derived state that automatically updates when dependencies change.

### Creating Computed Values

```vue
<script setup>
import { ref, computed } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

const fullName = computed(() => {
  return `${firstName.value} ${lastName.value}`
})

firstName.value = 'Jane' // fullName becomes 'Jane Doe'
</script>
```

### Computed vs Methods

**Computed (cached):**
```vue
<script setup>
import { ref, computed } from 'vue'

const items = ref([1, 2, 3, 4, 5])

// Cached, only recalculates when items changes
const expensiveSum = computed(() => {
  console.log('Computing sum...') // Only logs when items changes
  return items.value.reduce((sum, item) => sum + item, 0)
})
</script>

<template>
  <!-- Called multiple times, but only computed once -->
  <div>{{ expensiveSum }}</div>
  <div>{{ expensiveSum }}</div>
</template>
```

**When to use each:**
- **Computed:** For derived state based on reactive dependencies (caching benefit)
- **Methods:** For actions, event handlers, or calculations with parameters

### Writable Computed (Getter/Setter)

```vue
<script setup>
import { ref, computed } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

const fullName = computed({
  get() {
    return `${firstName.value} ${lastName.value}`
  },
  set(newValue) {
    const parts = newValue.split(' ')
    firstName.value = parts[0] || ''
    lastName.value = parts[1] || ''
  }
})

fullName.value = 'Jane Smith' // Updates firstName and lastName
</script>

<template>
  <input v-model="fullName" />
</template>
```

### Best Practices

**1. Keep computations pure:**
```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)

// GOOD: Pure computation
const doubled = computed(() => count.value * 2)

// BAD: Side effects
const badComputed = computed(() => {
  console.log('Side effect!') // Avoid
  return count.value * 2
})
</script>
```

**2. Chain computed properties for clarity:**
```vue
<script setup>
import { ref, computed } from 'vue'

const users = ref([...])

const activeUsers = computed(() =>
  users.value.filter(user => user.active)
)

const sortedActiveUsers = computed(() =>
  activeUsers.value.sort((a, b) => a.name.localeCompare(b.name))
)
</script>
```

---

## watch() vs watchEffect()

### watch() - Explicit Dependencies

`watch()` explicitly tracks specific sources and runs a callback when they change.

```vue
<script setup>
import { ref, watch } from 'vue'

const count = ref(0)

watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`)
})
</script>
```

**Watch Multiple Sources:**
```vue
<script setup>
import { ref, watch } from 'vue'

const firstName = ref('John')
const lastName = ref('Doe')

watch([firstName, lastName], ([newFirst, newLast], [oldFirst, oldLast]) => {
  console.log(`Name changed from ${oldFirst} ${oldLast} to ${newFirst} ${newLast}`)
})
</script>
```

**Deep Watching:**
```vue
<script setup>
import { ref, watch } from 'vue'

const user = ref({
  name: 'John',
  profile: { age: 30, city: 'NYC' }
})

watch(
  user,
  (newValue) => {
    console.log('User changed:', newValue)
  },
  { deep: true }
)

user.value.profile.age = 31 // Triggers watch
</script>
```

### watchEffect() - Automatic Dependencies

`watchEffect()` automatically tracks reactive dependencies used within the callback.

```vue
<script setup>
import { ref, watchEffect } from 'vue'

const count = ref(0)

// Automatically tracks count
watchEffect(() => {
  console.log(`Count is ${count.value}`)
})
// Logs: "Count is 0" immediately

count.value++ // Logs: "Count is 1"
</script>
```

### Cleanup Functions

```vue
<script setup>
import { ref, watchEffect } from 'vue'

const userId = ref(1)

watchEffect((onCleanup) => {
  const controller = new AbortController()

  fetch(`/api/users/${userId.value}`, {
    signal: controller.signal
  })
    .then(res => res.json())
    .then(data => console.log(data))

  onCleanup(() => {
    controller.abort() // Cancel previous request
  })
})
</script>
```

### Stopping Watchers

```vue
<script setup>
import { ref, watch } from 'vue'

const count = ref(0)

const stopWatch = watch(count, (newValue) => {
  console.log('Watch:', newValue)
})

// Stop manually
function stopWatching() {
  stopWatch()
}
</script>
```

### When to Use Each

**Use watch() when:**
- You need access to previous and new values
- You're watching specific sources explicitly
- You want lazy execution (not immediate by default)

**Use watchEffect() when:**
- You want automatic dependency tracking
- You need immediate execution
- You don't need previous values

### Comparison Table

| Feature | watch() | watchEffect() |
|---------|---------|---------------|
| Dependency tracking | Explicit | Automatic |
| Initial execution | Lazy (unless `immediate: true`) | Immediate |
| Previous value | Yes | No |
| Use case | Specific sources, need old/new values | Side effects, automatic tracking |

### Common Patterns

**Debounced Search:**
```vue
<script setup>
import { ref, watch } from 'vue'

const searchQuery = ref('')
const searchResults = ref([])

watch(searchQuery, (newQuery, oldQuery, onCleanup) => {
  const timeoutId = setTimeout(async () => {
    const response = await fetch(`/api/search?q=${newQuery}`)
    searchResults.value = await response.json()
  }, 300)

  onCleanup(() => clearTimeout(timeoutId))
})
</script>
```

---

## Reactivity Gotchas

### 1. Losing Reactivity When Destructuring

**Problem:**
```vue
<script setup>
import { reactive } from 'vue'

const state = reactive({ count: 0 })
const { count } = state // Loses reactivity
count++ // Won't update component
</script>
```

**Solution:**
```vue
<script setup>
import { reactive, toRefs } from 'vue'

const state = reactive({ count: 0 })
const { count } = toRefs(state)
count.value++ // Will update component
</script>
```

### 2. Reassigning reactive() Breaks Reactivity

**Problem:**
```vue
<script setup>
import { reactive } from 'vue'

let state = reactive({ count: 0 })
state = { count: 1 } // Reactivity LOST
</script>
```

**Solution:**
```vue
<script setup>
import { ref } from 'vue'

const state = ref({ count: 0 })
state.value = { count: 1 } // Reactivity preserved
</script>
```

### 3. Ref Unwrapping

**In templates - auto-unwrapped:**
```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)
</script>

<template>
  <div>{{ count }}</div> <!-- No .value needed -->
</template>
```

**In script - always use .value:**
```vue
<script setup>
import { ref } from 'vue'

const count = ref(0)

console.log(count.value) // Correct
console.log(count) // Wrong - logs ref object
</script>
```

### 4. Computed Dependency Tracking

**Problem:**
```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)
let multiplier = 2 // Not reactive

const result = computed(() => count.value * multiplier)
multiplier = 3 // result doesn't update
</script>
```

**Solution:**
```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)
const multiplier = ref(2) // Make it reactive

const result = computed(() => count.value * multiplier.value)
multiplier.value = 3 // Now result updates
</script>
```

### 5. Async Computed Not Supported

**Problem:**
```vue
<script setup>
import { ref, computed } from 'vue'

const userId = ref(1)

// WRONG: Computed can't be async
const user = computed(async () => {
  const response = await fetch(`/api/users/${userId.value}`)
  return response.json()
})
// user.value is a Promise!
</script>
```

**Solution:**
```vue
<script setup>
import { ref, watch } from 'vue'

const userId = ref(1)
const user = ref(null)

watch(userId, async (newId) => {
  const response = await fetch(`/api/users/${newId}`)
  user.value = await response.json()
}, { immediate: true })
</script>
```

---

## Best Practices (2025)

### 1. Prefer ref() Over reactive()

```vue
<script setup>
import { ref } from 'vue'

// Consistent pattern for all types
const count = ref(0)
const user = ref({ name: 'John', age: 30 })
const items = ref([1, 2, 3])

// Always use .value
count.value++
user.value.name = 'Jane'
</script>
```

**Why:**
- Single mental model
- Safe reassignment
- Better TypeScript support

### 2. Use Computed for Derived State

```vue
<script setup>
import { ref, computed } from 'vue'

const users = ref([...])

// Good: Computed for derived state
const activeUsers = computed(() =>
  users.value.filter(user => user.active)
)

// Bad: Manually syncing with watch
const activeUsers = ref([])
watch(users, (newUsers) => {
  activeUsers.value = newUsers.filter(user => user.active)
})
</script>
```

### 3. Reserve watch for Side Effects

```vue
<script setup>
import { ref, watch } from 'vue'

const searchQuery = ref('')
const searchResults = ref([])

// Good: Side effect (API call)
watch(searchQuery, async (query) => {
  const response = await fetch(`/api/search?q=${query}`)
  searchResults.value = await response.json()
})

// Bad: Deriving state (use computed)
const upperQuery = ref('')
watch(searchQuery, (query) => {
  upperQuery.value = query.toUpperCase() // Use computed!
})
</script>
```

**Use watch/watchEffect for:**
- API calls
- LocalStorage sync
- DOM manipulation
- Setting up subscriptions

**Don't use watch for:**
- Deriving values (use computed)
- Transforming data (use computed)

### 4. Always Clean Up Side Effects

```vue
<script setup>
import { ref, watch, onUnmounted } from 'vue'

const userId = ref(1)

// Cleanup in watch
watch(userId, (newId, oldId, onCleanup) => {
  const controller = new AbortController()
  fetch(`/api/users/${newId}`, { signal: controller.signal })
  onCleanup(() => controller.abort())
})

// Cleanup in lifecycle
const interval = setInterval(() => console.log('Tick'), 1000)
onUnmounted(() => clearInterval(interval))
</script>
```

### 5. Type Safety with TypeScript

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

interface User {
  id: number
  name: string
  email: string
}

const user = ref<User | null>(null)
const users = ref<User[]>([])

// Type inferred automatically
const userNames = computed(() =>
  users.value.map(u => u.name)
) // Type: ComputedRef<string[]>
</script>
```

### 6. Extract Complex Logic to Composables

```vue
<script setup>
// Instead of inline logic
const users = ref([...])
const filter = ref('')
const filteredUsers = computed(() =>
  users.value.filter(u => u.name.includes(filter.value))
)

// Extract to composable
import { useUserList } from '@/composables/useUserList'
const { users, filter, filteredUsers } = useUserList()
</script>
```

### 7. Avoid Deeply Nested reactive() Objects

```vue
<script setup>
import { reactive, ref } from 'vue'

// Avoid deep nesting
const state = reactive({
  user: { profile: { settings: { theme: '#000' } } }
})

// Prefer flat structure
const userThemePrimary = ref('#000')
const userProfile = reactive({ name: '', email: '' })
</script>
```

---

## Summary

**Key Takeaways:**

1. **ref() vs reactive()**
   - Prefer `ref()` for consistency and safety
   - `ref()` works with all types, `reactive()` only with objects
   - `ref()` allows reassignment, `reactive()` doesn't
   - Use `.value` in script, auto-unwrapped in templates

2. **toRefs()**
   - Converts reactive object properties to refs
   - Preserves reactivity when destructuring
   - Essential for composable return values

3. **Computed Properties**
   - Create derived state that auto-updates
   - Cached based on dependencies
   - Must be pure (no side effects)

4. **watch() vs watchEffect()**
   - `watch()` for explicit dependencies and old/new values
   - `watchEffect()` for automatic tracking and immediate execution
   - Use for side effects, not derived state

5. **Reactivity Gotchas**
   - Destructuring loses reactivity (use `toRefs()`)
   - Reassigning `reactive()` breaks reactivity
   - Refs need `.value` in script, not in templates
   - Non-reactive values aren't tracked in computed

6. **Best Practices**
   - Prefer `ref()` over `reactive()` (2025 consensus)
   - Use computed for derived state, not watch
   - Reserve watch for side effects only
   - Always clean up watchers and effects
   - Type reactive state with TypeScript
   - Extract complex logic to composables

Vue 3's reactivity system is powerful and intuitive once you understand these core concepts. Following these 2025 best practices will help you write maintainable, performant, and bug-free Vue applications.
