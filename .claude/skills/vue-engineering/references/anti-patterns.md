# Vue 3 Anti-Patterns and Common Mistakes (2025)

This document covers common Vue 3 anti-patterns and mistakes to avoid based on 2025 best practices. Each section includes examples of what NOT to do and the correct approach.

---

## 1. Using Options API for New Projects (2025)

### Why It's Bad

The Options API is in legacy/maintenance mode as of 2025. New projects should use Composition API exclusively for better TypeScript support, logic reusability, and access to modern Vue features.

### Bad Example

```vue
<!-- Options API - Legacy approach -->
<script>
export default {
  data() {
    return {
      count: 0,
      user: null
    }
  },
  computed: {
    doubleCount() {
      return this.count * 2
    }
  },
  methods: {
    increment() {
      this.count++
    }
  }
}
</script>
```

### Good Example

```vue
<!-- Composition API - Modern approach -->
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

const count = ref(0)
const user = ref<User | null>(null)
const doubleCount = computed(() => count.value * 2)
const increment = () => count.value++

onMounted(() => {
  fetchUser()
})
</script>
```

**When acceptable:** Maintaining existing Options API codebases. For new code, always use Composition API with `<script setup>`.

---

## 2. Misusing v-if vs v-show

### Why It's Bad

Using the wrong directive causes performance issues. `v-if` destroys/recreates DOM (high toggle cost), while `v-show` toggles CSS display (low toggle cost but always rendered).

### Bad Example

```vue
<!-- BAD: Using v-if for frequently toggled elements -->
<template>
  <button @click="showDetails = !showDetails">Toggle</button>
  <div v-if="showDetails">
    <!-- Complex component tree destroyed/recreated on every toggle -->
  </div>
</template>
```

### Good Example

```vue
<!-- GOOD: v-show for frequent toggles -->
<template>
  <button @click="showDetails = !showDetails">Toggle</button>
  <div v-show="showDetails">
    <!-- Fast toggle, no DOM recreation -->
  </div>
</template>

<!-- GOOD: v-if for rarely shown elements -->
<template>
  <ErrorModal v-if="hasError" />
  <AdminPanel v-if="isAdmin" />
</template>
```

**Rule:** Use `v-if` when element rarely changes or is false most of the time. Use `v-show` when element toggles frequently.

---

## 3. Prop Drilling

### Why It's Bad

Passing props through multiple component levels creates fragile, hard-to-maintain code with tight coupling.

### Bad Example

```vue
<!-- App.vue → Layout.vue → Sidebar.vue → Navigation.vue → UserMenu.vue -->
<!-- Props passed through 5 levels just to reach UserMenu! -->
```

### Good Example: Using Pinia

```typescript
// stores/user.ts
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const theme = ref<Theme>('light')
  return { user, theme }
})
```

```vue
<!-- UserMenu.vue - Access directly from any component -->
<script setup lang="ts">
import { useUserStore } from '@/stores/user'
const { user, theme } = storeToRefs(useUserStore())
</script>
```

**Rule:** If passing props through 3+ levels, use provide/inject or Pinia.

---

## 4. Mutating Props Directly

### Why It's Bad

Props are read-only and follow one-way data flow. Direct mutation breaks Vue's reactivity system and causes bugs.

### Bad Example

```vue
<script setup lang="ts">
const props = defineProps<{ user: User }>()

// BAD: Direct mutation
const updateName = () => {
  props.user.name = 'New Name' // Don't do this!
}
</script>
```

### Good Example

```vue
<!-- Child.vue -->
<script setup lang="ts">
const props = defineProps<{ user: User }>()
const emit = defineEmits<{ 'update:user': [user: User] }>()

const updateName = (newName: string) => {
  emit('update:user', { ...props.user, name: newName })
}
</script>

<!-- Parent.vue -->
<template>
  <Child v-model:user="user" />
</template>
```

---

## 5. Not Cleaning Up Side Effects

### Why It's Bad

Failing to clean up side effects causes memory leaks that accumulate over time, degrading performance or crashing the application.

### Bad Example

```vue
<script setup lang="ts">
onMounted(() => {
  window.addEventListener('resize', handleResize)
  setInterval(() => fetchData(), 5000)
  const ws = new WebSocket('ws://api.example.com')
  // Missing cleanup!
})
</script>
```

### Good Example

```vue
<script setup lang="ts">
let intervalId: number
let ws: WebSocket

onMounted(() => {
  window.addEventListener('resize', handleResize)
  intervalId = setInterval(() => fetchData(), 5000)
  ws = new WebSocket('ws://api.example.com')
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  clearInterval(intervalId)
  ws.close()
})
</script>
```

**Always clean up:** Event listeners, timers/intervals, WebSocket connections, third-party libraries, and DOM observers.

---

## 6. Overusing Watchers

### Why It's Bad

Watchers are for side effects only. Using them for derived state is inefficient and verbose. Computed properties are cached and run before render.

### Bad Example

```vue
<script setup lang="ts">
const firstName = ref('John')
const lastName = ref('Doe')
const fullName = ref('')

// BAD: Using watcher for derived state
watch([firstName, lastName], ([first, last]) => {
  fullName.value = `${first} ${last}`
})
</script>
```

### Good Example

```vue
<script setup lang="ts">
const firstName = ref('John')
const lastName = ref('Doe')

// GOOD: Computed for derived state
const fullName = computed(() => `${firstName.value} ${lastName.value}`)

// GOOD: Watcher for side effects
const searchQuery = ref('')
watch(searchQuery, async (query) => {
  if (query.length > 2) {
    await searchAPI(query) // API call = side effect
  }
})
</script>
```

**Use computed for:** Deriving state, calculations, transformations. **Use watchers for:** API calls, localStorage, logging, animations.

---

## 7. Missing Keys in v-for

### Why It's Bad

Keys are required for Vue to efficiently track elements. Without proper keys: rendering bugs, poor performance, animation glitches, and mixed component state.

### Bad Example

```vue
<!-- BAD: No key -->
<div v-for="item in items">{{ item.name }}</div>

<!-- BAD: Using index as key -->
<div v-for="(item, index) in items" :key="index">
  <input v-model="item.name" />
  <!-- Input state gets mixed up on reorder! -->
</div>
```

### Good Example

```vue
<!-- GOOD: Unique, stable ID -->
<div v-for="item in items" :key="item.id">
  {{ item.name }}
</div>

<!-- GOOD: Composite key when needed -->
<div v-for="item in items" :key="`${item.type}-${item.id}`">
  {{ item.name }}
</div>
```

**Good key must be:** Unique (no duplicates), stable (same item = same key), and predictable (based on data, not position).

**Index acceptable only for:** Truly static lists that never change order.

---

## 8. Creating Monolithic Components

### Why It's Bad

Large components (>300 lines) are hard to understand, test, maintain, and reuse. They re-render more often and have wide-reaching effects.

### Bad Example

```vue
<!-- UserProfile.vue - Monolithic component (500+ lines) -->
<script setup lang="ts">
// User data, posts data, friends data, settings data,
// activity data, photos data...
// 20+ functions, 10+ computed properties, multiple API calls
</script>

<template>
  <!-- 400+ lines of template -->
</template>
```

### Good Example

```vue
<!-- UserProfile.vue - Clean composition -->
<script setup lang="ts">
import ProfileHeader from './ProfileHeader.vue'
import ProfileAbout from './ProfileAbout.vue'
import ProfilePosts from './ProfilePosts.vue'

const userId = defineProps<{ userId: string }>()
const activeTab = ref('posts')
</script>

<template>
  <div class="user-profile">
    <ProfileHeader :user-id="userId" />
    <ProfileAbout :user-id="userId" />
    <ProfilePosts v-if="activeTab === 'posts'" :user-id="userId" />
  </div>
</template>
```

**Break down when:** Component exceeds 300 lines, has 5+ responsibilities, deep template nesting, or parts could be reused elsewhere.

---

## 9. Reactivity Pitfalls

### Why It's Bad

Violating Vue's reactivity rules causes silent failures where UI doesn't update when data changes.

### Common Pitfalls

```vue
<script setup lang="ts">
// PITFALL 1: Destructuring loses reactivity
const user = reactive({ name: 'John', age: 30 })
const { name, age } = user // NOT reactive!

// FIX: Use toRefs()
const { name, age } = toRefs(user) // Reactive!

// PITFALL 2: Reassigning reactive breaks reactivity
const state = reactive({ count: 0 })
state = { count: 1 } // BREAKS reactivity!

// FIX: Use ref() for reassignable values
const state = ref({ count: 0 })
state.value = { count: 1 } // Works!

// PITFALL 3: Computed mutations
const fullName = computed(() => `${firstName.value} ${lastName.value}`)
// fullName.value = 'Jane Smith' // Can't do this!

// FIX: Add setter
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (newValue) => {
    [firstName.value, lastName.value] = newValue.split(' ')
  }
})
</script>
```

**Key rules:** Use `toRefs()` when destructuring reactive, use `ref()` for reassignable values, add setters to writable computed properties.

---

## 10. Memory Leaks

### Why It's Bad

Memory leaks cause applications to slow down and crash, especially in SPAs and long-running dashboards.

### Common Leak Sources

```vue
<script setup lang="ts">
// BAD: Event listeners not removed
onMounted(() => {
  document.addEventListener('click', handleClick)
  // Never removed - leaks on component destroy
})

// GOOD: Always clean up
onMounted(() => {
  document.addEventListener('click', handleClick)
})
onUnmounted(() => {
  document.removeEventListener('click', handleClick)
})

// BAD: Third-party libraries not destroyed
let chart: Chart
onMounted(() => {
  chart = new Chart(canvasRef.value, config)
})
// Missing cleanup!

// GOOD: Destroy library instances
onUnmounted(() => {
  chart.destroy()
})
</script>
```

### Memory Leak Prevention Checklist

- All event listeners removed in `onUnmounted`
- All timers/intervals cleared in `onUnmounted`
- WebSocket/SSE connections closed in `onUnmounted`
- Third-party libraries properly destroyed
- No circular references between components
- Abort controllers used for fetch requests

---

## 11. State Management Mistakes

### Why It's Bad

Over-engineering (using Pinia for everything) or under-engineering (prop drilling when store needed) leads to complexity and performance issues.

### Anti-Pattern: Premature Centralization

```typescript
// BAD: Everything in Pinia, even component-specific state
export const useModalStore = defineStore('modal', () => {
  const isOpen = ref(false) // This should be local!
  return { isOpen }
})
```

```vue
<!-- GOOD: Local state for component-specific data -->
<script setup lang="ts">
const isOpen = ref(false) // Modal component - state is local

// Only shared/global state goes in stores
const userStore = useUserStore()
</script>
```

### State Management Decision Tree

```
Is the state specific to one component?
├─ YES → Use local state (ref/reactive)
└─ NO
   ├─ Is it shared across the entire app?
   │  ├─ YES → Use Pinia store
   │  └─ NO → Use provide/inject for component tree
```

**Use local state when:** Data is specific to one component, doesn't need sharing, resets on unmount.

**Use Pinia when:** Data shared across multiple components, persists across routes, accessed anywhere in app.

**Use provide/inject when:** Data shared within component tree, avoiding prop drilling, scoped to specific feature.

---

## 12. Not Optimizing watchEffect

### Why It's Bad

`watchEffect` automatically tracks all reactive dependencies and re-runs on any change, causing unnecessary re-renders and performance issues.

### Bad Example

```vue
<script setup lang="ts">
const user = ref<User>()
const posts = ref<Post[]>()

// BAD: Runs when ANY dependency changes
watchEffect(() => {
  if (user.value) {
    analytics.track('user_viewed', {
      userId: user.value.id,
      postCount: posts.value.length // Unnecessary dependency
    })
  }
})
</script>
```

### Good Example

```vue
<script setup lang="ts">
// GOOD: Explicit dependencies with watch
watch(user, (newUser) => {
  if (newUser) {
    analytics.track('user_viewed', { userId: newUser.id })
  }
})
</script>
```

**Use watchEffect when:** You genuinely need to track ALL dependencies, effect is simple and fast.

**Use watch when:** You need explicit control, need old/new values, making API calls, debouncing.

---

## 13. Ignoring TypeScript Benefits

### Why It's Bad

For medium to large projects, not using TypeScript loses compile-time error detection, IDE support, easier refactoring, and self-documenting code.

### Bad Example: JavaScript

```vue
<script setup>
// What props? Unknown!
const props = defineProps({
  user: Object,
  settings: Object
})

// Typo - no error until runtime!
const userName = props.user.naem // Should be 'name'

// Wrong type - no error until runtime!
updateUser({ id: '123', age: 'thirty' }) // age should be number
</script>
```

### Good Example: TypeScript

```vue
<script setup lang="ts">
interface Props {
  user: User
  settings: Settings
}

const props = defineProps<Props>()

// Typo - caught at compile time!
// const userName = props.user.naem // TS Error

// Wrong type - caught at compile time!
// updateUser({ id: '123', age: 'thirty' }) // TS Error
</script>
```

**TypeScript is essential for:** Medium to large projects (>10 components), team development, complex state management, API-heavy applications, long-term maintenance.

---

## 14. Bundle Size Ignorance

### Why It's Bad

Large bundle sizes directly impact user experience: slower initial load, poor mobile experience, lower SEO rankings, higher bounce rates.

**Real impact:** 1 second delay = 7% reduction in conversions. 3 second load time = 53% of mobile users abandon.

### Anti-Pattern: Not Lazy Loading

```typescript
// BAD: All routes loaded upfront
import Home from './views/Home.vue'
import AdminPanel from './views/AdminPanel.vue' // Heavy admin features
const routes = [
  { path: '/', component: Home },
  { path: '/admin', component: AdminPanel }
]
// Result: Initial bundle = 500KB+
```

```typescript
// GOOD: Lazy load routes
const routes = [
  { path: '/', component: () => import('./views/Home.vue') },
  { path: '/admin', component: () => import('./views/AdminPanel.vue') }
]
// Result: Initial bundle = 150KB, rest loaded on demand
```

### Anti-Pattern: Importing Entire Libraries

```typescript
// BAD: Import entire library
import _ from 'lodash' // 70KB
import moment from 'moment' // 67KB

// GOOD: Import only what you need
import debounce from 'lodash/debounce' // 2KB
import { format } from 'date-fns' // 13KB (tree-shakeable)
```

### Bundle Optimization Checklist

- Lazy load routes with dynamic imports
- Lazy load heavy components with `defineAsyncComponent`
- Import specific functions, not entire libraries
- Use tree-shakeable libraries (date-fns vs moment)
- Analyze bundle size regularly with visualizer
- Enable compression (gzip/brotli) in production
- Code splitting for vendor and UI libraries
- Initial bundle < 200KB gzipped

**Bundle size goals:**
- Small app: < 150KB gzipped initial
- Medium app: < 200KB gzipped initial
- Large app: < 250KB gzipped initial

---

## Summary Checklist

Use this checklist to audit your Vue 3 codebase:

### Architecture
- Using Composition API for all new components
- Components are focused (< 300 lines)
- Logic extracted into composables

### Rendering & Performance
- Using `v-if` for rarely shown elements
- Using `v-show` for frequently toggled elements
- All `v-for` loops have unique `:key` props
- Heavy components are lazy loaded
- Routes are lazy loaded

### Reactivity
- Props are never mutated directly
- Using `toRefs()` when destructuring reactive objects
- Computed for derived state, not watchers

### State Management
- Local state for component-specific data
- Pinia for truly global state
- provide/inject for feature-scoped data
- No premature centralization

### Memory & Resources
- Event listeners removed in `onUnmounted`
- Timers/intervals cleared in `onUnmounted`
- WebSocket/connections closed properly
- Third-party libraries destroyed

### Code Quality
- TypeScript enabled for medium+ projects
- Proper type definitions for props
- Strict mode enabled in tsconfig

### Bundle Size
- Bundle size analyzed regularly
- Tree-shakeable imports used
- Heavy dependencies lazy loaded
- Initial bundle < 200KB gzipped
- Compression enabled in production

---

## Additional Resources

- [Vue 3 Official Docs](https://vuejs.org/)
- [Vue 3 Performance Guide](https://vuejs.org/guide/best-practices/performance.html)
- [TypeScript with Vue](https://vuejs.org/guide/typescript/overview.html)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vite Bundle Analyzer](https://github.com/btd/rollup-plugin-visualizer)
