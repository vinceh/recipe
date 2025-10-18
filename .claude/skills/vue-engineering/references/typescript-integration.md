# Vue 3 TypeScript Integration Reference (2025)

This guide covers TypeScript integration with Vue 3.5+ and TypeScript 5+, focusing on 2025 best practices.

## 1. Project Setup (2025)

### Use Vite with create-vue

Scaffold Vue + TypeScript projects using Vite:

```bash
npm create vue@latest

# Select TypeScript: Yes
# Add ESLint: Yes (recommended)
```

**Note:** Vue CLI is deprecated. Use Vite + create-vue for all new projects.

### tsconfig.json Configuration

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*.ts", "src/**/*.tsx", "src/**/*.vue"]
}
```

### IDE Setup: Volar (2025 Standard)

**Use Volar, NOT Vetur:**
- Extension: Vue - Official (VS Code Extension ID: `Vue.volar`)
- Vetur is deprecated and incompatible with Vue 3 + TypeScript

**Enable Takeover Mode** for better performance:
```json
{
  "volar.takeOverMode.enabled": true
}
```

## 2. Typing Props

### Basic Props with defineProps

Use TypeScript-only syntax:

```vue
<script setup lang="ts">
// Simple types
const props = defineProps<{
  title: string
  count: number
  isActive: boolean
}>()

// Optional props
const props = defineProps<{
  title: string
  subtitle?: string
}>()

// Union types
const props = defineProps<{
  status: 'pending' | 'active' | 'completed'
}>()
</script>
```

### Props with Default Values

Use `withDefaults` for defaults:

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
  tags?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
  tags: () => []  // Use function for object/array defaults
})
</script>
```

### Complex Prop Types

```vue
<script setup lang="ts">
interface User {
  id: number
  name: string
}

interface Props {
  user: User
  items: User[]
  onClick: (id: number) => void
  formatter?: (value: string) => string
}

const props = defineProps<Props>()
</script>
```

## 3. Typing Emits

### Basic Emit Typing

Use TypeScript-only syntax:

```vue
<script setup lang="ts">
// Events with/without payload
const emit = defineEmits<{
  submit: []  // void event
  update: [value: string]
  change: [id: number, name: string]  // Multiple parameters
}>()

function handleClick() {
  emit('update', 'new value')
  emit('change', 1, 'John')
}
</script>
```

### Typed v-model

```vue
<script setup lang="ts">
const props = defineProps<{
  modelValue: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()
</script>
```

## 4. Typing Refs and Reactive

### Ref Type Annotations

```vue
<script setup lang="ts">
import { ref } from 'vue'

// Simple types (inference works)
const count = ref(0)  // Ref<number>

// Explicit type when needed
interface User {
  id: number
  name: string
}

const user = ref<User | null>(null)
const users = ref<User[]>([])
</script>
```

### Template Refs

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'

// DOM element refs
const inputRef = ref<HTMLInputElement>()

// Component refs
import MyComponent from './MyComponent.vue'
const componentRef = ref<InstanceType<typeof MyComponent>>()

onMounted(() => {
  inputRef.value?.focus()
})
</script>

<template>
  <input ref="inputRef" type="text" />
  <MyComponent ref="componentRef" />
</template>
```

### When to Add Explicit Types

```vue
<script setup lang="ts">
// ✅ Inference works - no annotation needed
const count = ref(0)

// ⚠️ Need explicit type - initial value is null/undefined
const user = ref<User | null>(null)

// ⚠️ Need explicit type - union types
const status = ref<'idle' | 'loading' | 'success'>('idle')
</script>
```

## 5. Typing Composables

### Basic Composable

```typescript
// composables/useCounter.ts
import { ref, computed } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const doubled = computed(() => count.value * 2)

  function increment() {
    count.value++
  }

  return { count, doubled, increment }
}
```

### Explicit Return Types

```typescript
// composables/useUser.ts
import { ref, type Ref } from 'vue'

interface User {
  id: number
  name: string
}

interface UseUserReturn {
  user: Ref<User | null>
  loading: Ref<boolean>
  fetchUser: (id: number) => Promise<void>
}

export function useUser(): UseUserReturn {
  const user = ref<User | null>(null)
  const loading = ref(false)

  async function fetchUser(id: number) {
    loading.value = true
    const response = await fetch(`/api/users/${id}`)
    user.value = await response.json()
    loading.value = false
  }

  return { user, loading, fetchUser }
}
```

### Generic Composables

```typescript
// composables/useFetch.ts
import { ref, type Ref } from 'vue'

interface UseFetchReturn<T> {
  data: Ref<T | null>
  loading: Ref<boolean>
  execute: () => Promise<void>
}

export function useFetch<T>(url: string): UseFetchReturn<T> {
  const data = ref<T | null>(null)
  const loading = ref(false)

  async function execute() {
    loading.value = true
    const response = await fetch(url)
    data.value = await response.json()
    loading.value = false
  }

  return { data, loading, execute }
}

// Usage
const { data } = useFetch<User[]>('/api/users')
```

## 6. Generic Components

### Basic Generic Component

```vue
<!-- components/GenericList.vue -->
<script setup lang="ts" generic="T">
interface Props {
  items: T[]
  keyField: keyof T
}

const props = defineProps<Props>()

const emit = defineEmits<{
  select: [item: T]
}>()
</script>

<template>
  <ul>
    <li
      v-for="item in items"
      :key="String(item[keyField])"
      @click="emit('select', item)"
    >
      <slot :item="item" />
    </li>
  </ul>
</template>
```

### Constrained Generics

```vue
<!-- components/DataTable.vue -->
<script setup lang="ts" generic="T extends { id: number | string }">
interface Props {
  data: T[]
  columns: Array<{
    key: keyof T
    label: string
  }>
}

const props = defineProps<Props>()
</script>

<template>
  <table>
    <thead>
      <tr>
        <th v-for="col in columns" :key="String(col.key)">
          {{ col.label }}
        </th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="row in data" :key="row.id">
        <td v-for="col in columns" :key="String(col.key)">
          {{ row[col.key] }}
        </td>
      </tr>
    </tbody>
  </table>
</template>
```

## 7. Type-Safe Provide/Inject

### InjectionKey Pattern

```typescript
// keys.ts
import type { InjectionKey, Ref } from 'vue'

export interface User {
  id: number
  name: string
}

export const UserKey: InjectionKey<Ref<User | null>> = Symbol('user')
```

### Provider Component

```vue
<!-- App.vue -->
<script setup lang="ts">
import { provide, ref } from 'vue'
import { UserKey, type User } from './keys'

const user = ref<User | null>({
  id: 1,
  name: 'John',
  email: 'john@example.com'
})

provide(UserKey, user)
</script>
```

### Consumer Component

```vue
<!-- UserProfile.vue -->
<script setup lang="ts">
import { inject } from 'vue'
import { UserKey } from './keys'

const user = inject(UserKey)
if (!user) throw new Error('User required')
</script>

<template>
  <div v-if="user?.value">
    <h1>{{ user.value.name }}</h1>
  </div>
</template>
```

## 8. IDE Setup

### Volar Takeover Mode

Enable in `.vscode/settings.json`:

```json
{
  "typescript.tsdk": "node_modules/typescript/lib",
  "volar.takeOverMode.enabled": true,
  "editor.formatOnSave": true,
  "[vue]": {
    "editor.defaultFormatter": "Vue.volar"
  }
}
```

### ESLint + TypeScript

Install and configure:

```bash
npm install -D @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

`.eslintrc.cjs`:
```javascript
module.exports = {
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser'
  },
  extends: [
    'plugin:vue/vue3-recommended',
    'plugin:@typescript-eslint/recommended'
  ]
}
```

## 9. Common TypeScript Patterns

### Interfaces vs Types

```typescript
// ✅ Use interface for object shapes (extendable)
interface User {
  id: number
  name: string
}

interface Admin extends User {
  role: 'admin'
}

// ✅ Use type for unions, intersections
type Status = 'pending' | 'active' | 'completed'
type Result<T> = { success: true; data: T } | { success: false; error: string }
```

### Type Utilities

```typescript
interface User {
  id: number
  name: string
  email: string
}

// Partial - all properties optional
type PartialUser = Partial<User>

// Pick - select specific properties
type UserPreview = Pick<User, 'id' | 'name'>

// Omit - exclude specific properties
type UserWithoutId = Omit<User, 'id'>

// Record - object with specific key/value types
type UserMap = Record<number, User>
```

### Discriminated Unions

```vue
<script setup lang="ts">
type LoadingState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User[] }
  | { status: 'error'; error: string }

const state = ref<LoadingState>({ status: 'idle' })

// Type narrowing
function renderContent() {
  switch (state.value.status) {
    case 'success':
      return state.value.data.length  // TypeScript knows data exists
    case 'error':
      return state.value.error  // TypeScript knows error exists
  }
}
</script>
```

### Const Assertions

```typescript
// Create literal types
const colors = ['red', 'blue', 'green'] as const
type Color = typeof colors[number]  // "red" | "blue" | "green"

// Readonly configuration
const CONFIG = {
  api: { baseUrl: 'https://api.example.com' },
  features: { darkMode: true }
} as const
```

## 10. Migration from JavaScript

### Incremental Adoption

**Step 1: Enable TypeScript**

```bash
npm install -D typescript vue-tsc @vue/tsconfig
```

Create `tsconfig.json`:
```json
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "compilerOptions": {
    "allowJs": true,
    "checkJs": false,
    "strict": false
  }
}
```

**Step 2: Rename files gradually**
- Start with new files in TypeScript
- Rename `.js` to `.ts` one at a time
- Add `lang="ts"` to Vue SFCs
- Start with leaf components

**Step 3: Increase strictness**

```json
{
  "compilerOptions": {
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strict": true
  }
}
```

### Migration Checklist

- [ ] Install TypeScript and vue-tsc
- [ ] Create tsconfig.json with `allowJs: true`
- [ ] Update build scripts
- [ ] Rename components incrementally
- [ ] Add types to props/emits
- [ ] Enable strict options gradually
- [ ] Remove `any` types
- [ ] Enable CI/CD type checking

## 11. Build Configuration

### Vite Transpilation

**Important:** Vite transpiles but does NOT type-check during development.

`vite.config.ts`:
```typescript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: { '@': '/src' }
  }
})
```

### Type Checking with vue-tsc

`package.json`:
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vue-tsc --noEmit && vite build",
    "type-check": "vue-tsc --noEmit"
  }
}
```

Run type checking in watch mode:
```bash
# Terminal 1: Dev server
npm run dev

# Terminal 2: Type checking
vue-tsc --noEmit --watch
```

### CI/CD Type Checking

`.github/workflows/ci.yml`:
```yaml
jobs:
  type-check:
    steps:
      - run: npm ci
      - run: npm run type-check
      - run: npm run build
```

### Type-Only Imports

Optimize bundle size:

```typescript
// Type-only import (removed at runtime)
import type { User } from './types'

// Mixed import
import { type User, fetchUser } from './api'
```

### tsconfig Organization

**tsconfig.json** (source):
```json
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "include": ["src/**/*"],
  "compilerOptions": {
    "paths": { "@/*": ["./src/*"] }
  }
}
```

**tsconfig.node.json** (build tools):
```json
{
  "extends": "@tsconfig/node20/tsconfig.json",
  "include": ["vite.config.*"],
  "compilerOptions": {
    "composite": true,
    "types": ["node"]
  }
}
```

## Summary

### 2025 Best Practices Checklist

**Project Setup:**
- [ ] Use Vite + create-vue (not Vue CLI)
- [ ] Install Volar (Vue - Official)
- [ ] Enable Volar Takeover Mode
- [ ] Configure strict TypeScript

**Component Development:**
- [ ] Use `<script setup lang="ts">`
- [ ] Type props with `defineProps<T>()`
- [ ] Use `withDefaults()` for defaults
- [ ] Type emits with `defineEmits<T>()`
- [ ] Add explicit ref types when needed

**Advanced Patterns:**
- [ ] Create typed composables
- [ ] Use generic components
- [ ] Implement type-safe provide/inject
- [ ] Use discriminated unions for state

**Build & Tooling:**
- [ ] Run `vue-tsc --noEmit` before build
- [ ] Set up CI/CD type checking
- [ ] Use type-only imports
- [ ] Configure ESLint with TypeScript

### Common Pitfalls

- Using Vetur instead of Volar
- Not running vue-tsc (Vite doesn't type-check)
- Overusing `any` type
- Not using type-only imports
- Mixing runtime/type-based props
- Forgetting `withDefaults()` for defaults

### Resources

- [Vue 3 TypeScript Guide](https://vuejs.org/guide/typescript/overview.html)
- [Volar Extension](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
