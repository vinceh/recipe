# Vue 3 Component Design Patterns

A comprehensive guide to Vue 3 component communication and composition patterns using modern best practices.

## Table of Contents

1. [Props](#props)
2. [Emits](#emits)
3. [Slots](#slots)
4. [Provide/Inject](#provideinject)
5. [Component Composition Patterns](#component-composition-patterns)
6. [Single File Component Best Practices](#single-file-component-best-practices)
7. [Props vs Emits vs Slots - When to Use](#props-vs-emits-vs-slots---when-to-use)

---

## Props

Props are the primary mechanism for passing data from parent to child components. They create a one-way data flow that makes applications easier to understand.

### defineProps with TypeScript

Vue 3.3+ supports type-based props declaration:

```vue
<script setup lang="ts">
// Type-based declaration (recommended)
interface Props {
  title: string
  count?: number
  user: {
    id: number
    name: string
  }
  tags: string[]
  size?: 'small' | 'medium' | 'large'
}

const props = defineProps<Props>()
</script>
```

### Runtime Validation

For runtime validation or when not using TypeScript:

```vue
<script setup lang="ts">
import type { PropType } from 'vue'

interface User {
  id: number
  name: string
  role: 'admin' | 'user'
}

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  user: {
    type: Object as PropType<User>,
    required: true
  },
  size: {
    type: String as PropType<'small' | 'medium' | 'large'>,
    default: 'medium',
    validator: (value: string) => ['small', 'medium', 'large'].includes(value)
  }
})
</script>
```

### Default Values

Use `withDefaults` (Vue 3.3+):

```vue
<script setup lang="ts">
interface Props {
  title?: string
  count?: number
  tags?: string[]
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Untitled',
  count: 0,
  tags: () => []  // Functions for objects/arrays
})
</script>
```

Vue 3.5+ supports reactive destructuring with defaults:

```vue
<script setup lang="ts">
interface Props {
  title?: string
  count?: number
}

// Destructure with defaults - maintains reactivity in 3.5+!
const {
  title = 'Untitled',
  count = 0
} = defineProps<Props>()
</script>
```

### Props are Read-Only

Props follow one-way data flow and should never be mutated:

```vue
<script setup lang="ts">
const props = defineProps<{ count: number }>()

// DON'T - mutate props directly
props.count++ // Error!

// DO - use local state
const localCount = ref(props.count)

// DO - emit event to parent
const emit = defineEmits<{ increment: [] }>()
const increment = () => emit('increment')

// DO - use computed for transformations
const doubledCount = computed(() => props.count * 2)
</script>
```

### Best Practices

1. **Use type-based props for TypeScript projects**
2. **Make props required by default, optional explicitly**
3. **Use specific types over generic ones** (`'pending' | 'active'` vs `string`)
4. **Prefix boolean props with is/has/should**
5. **Use functions for object/array defaults** to avoid shared references
6. **Keep props focused and minimal**

---

## Emits

Emits enable child components to communicate with parents by dispatching events up the component tree.

### defineEmits with TypeScript

Type-safe event emission in Vue 3.3+:

```vue
<script setup lang="ts">
const emit = defineEmits<{
  submit: [data: FormData]
  update: [id: string, value: number]
  close: []  // no payload
}>()

// Usage
const handleSubmit = (data: FormData) => {
  emit('submit', data)  // Type-safe!
}
</script>
```

### Typed Event Payloads

Complex payload types:

```vue
<script setup lang="ts">
interface User {
  id: string
  name: string
}

const emit = defineEmits<{
  'user:created': [user: User]
  'user:deleted': [userId: string]
  'validation:error': [errors: Record<string, string[]>]
}>()
</script>
```

### Event Naming Conventions

1. **Use kebab-case for multi-word events**
   ```vue
   <script setup lang="ts">
   const emit = defineEmits<{
     'user-created': [user: User]  // Good
   }>()
   </script>

   <ChildComponent @user-created="handleUserCreated" />
   ```

2. **Use update:propertyName for v-model**
   ```vue
   <script setup lang="ts">
   const emit = defineEmits<{
     'update:modelValue': [value: string]
   }>()
   </script>

   <SearchInput v-model="query" />
   ```

3. **Use action:context pattern for namespacing**
   ```vue
   <script setup lang="ts">
   const emit = defineEmits<{
     'user:created': [user: User]
     'validation:error': [errors: ValidationErrors]
   }>()
   </script>
   ```

### When to Use Emits vs Other Patterns

**Use emits when:**
- Direct parent-child communication
- Events are specific to the component interaction

**Use provide/inject when:**
- Deep component hierarchies (3+ levels)
- Multiple descendants need the same functionality

**Use composables when:**
- Logic needs to be reused across components
- State management is needed

---

## Slots

Slots enable content distribution, allowing parent components to inject custom content into child components.

### Named Slots

```vue
<!-- Card.vue -->
<template>
  <div class="card">
    <header class="card-header">
      <slot name="header">Default Header</slot>
    </header>
    <main class="card-body">
      <slot></slot>  <!-- default slot -->
    </main>
    <footer class="card-footer">
      <slot name="footer"></slot>
    </footer>
  </div>
</template>

<!-- Usage -->
<Card>
  <template #header>
    <h2>User Profile</h2>
  </template>

  <p>Card content goes here</p>

  <template #footer>
    <button>Save</button>
  </template>
</Card>
```

### Scoped Slots

Allow child components to expose data to parent-provided content:

```vue
<!-- DataTable.vue -->
<script setup lang="ts" generic="T">
interface Props {
  items: T[]
}

const props = defineProps<Props>()
</script>

<template>
  <table>
    <tbody>
      <tr v-for="(item, index) in items" :key="index">
        <!-- Expose item and index to parent -->
        <slot name="row" :item="item" :index="index">
          {{ item }}
        </slot>
      </tr>
    </tbody>
  </table>
</template>

<!-- Usage -->
<DataTable :items="users">
  <template #row="{ item, index }">
    <td>{{ index + 1 }}</td>
    <td><strong>{{ item.name }}</strong></td>
  </template>
</DataTable>
```

### useSlots() API

Access slots programmatically for conditional rendering:

```vue
<script setup lang="ts">
import { useSlots } from 'vue'

const slots = useSlots()

const hasHeader = computed(() => !!slots.header)
const hasFooter = computed(() => !!slots.footer)
</script>

<template>
  <div class="card">
    <header v-if="hasHeader" class="card-header">
      <slot name="header"></slot>
    </header>

    <main class="card-body">
      <slot></slot>
    </main>

    <footer v-if="hasFooter" class="card-footer">
      <slot name="footer"></slot>
    </footer>
  </div>
</template>
```

### Renderless Component Pattern

Components that provide logic without rendering UI:

```vue
<!-- MouseTracker.vue -->
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'

const x = ref(0)
const y = ref(0)

const update = (event: MouseEvent) => {
  x.value = event.pageX
  y.value = event.pageY
}

onMounted(() => window.addEventListener('mousemove', update))
onUnmounted(() => window.removeEventListener('mousemove', update))
</script>

<template>
  <slot :x="x" :y="y"></slot>
</template>

<!-- Usage -->
<MouseTracker v-slot="{ x, y }">
  <div>Mouse position: {{ x }}, {{ y }}</div>
</MouseTracker>
```

---

## Provide/Inject

Provide/Inject implements dependency injection, allowing ancestor components to provide data/methods to all descendants without prop drilling.

### Basic Usage

```vue
<!-- ParentComponent.vue -->
<script setup lang="ts">
import { provide, ref } from 'vue'

const theme = ref('light')
const toggleTheme = () => {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
}

provide('theme', theme)
provide('toggleTheme', toggleTheme)
</script>

<!-- ChildComponent.vue (any level deep) -->
<script setup lang="ts">
import { inject } from 'vue'
import type { Ref } from 'vue'

const theme = inject<Ref<string>>('theme')
const toggleTheme = inject<() => void>('toggleTheme')
</script>

<template>
  <div :class="`theme-${theme}`">
    <button @click="toggleTheme">Toggle Theme</button>
  </div>
</template>
```

### Typed Injection Keys

Use InjectionKey for type safety:

```ts
// keys.ts
import type { InjectionKey, Ref } from 'vue'

export interface User {
  id: string
  name: string
}

export const UserKey: InjectionKey<Ref<User | null>> = Symbol('user')
```

```vue
<!-- Provider.vue -->
<script setup lang="ts">
import { provide, ref } from 'vue'
import { UserKey } from './keys'
import type { User } from './keys'

const user = ref<User | null>(null)

provide(UserKey, user)
</script>

<!-- Consumer.vue -->
<script setup lang="ts">
import { inject } from 'vue'
import { UserKey } from './keys'

const user = inject(UserKey)

// With defaults
const userWithDefault = inject(UserKey, ref(null))
</script>
```

### When to Use vs Props/Emits

**Use provide/inject when:**

1. **Deep component hierarchies** (3+ levels)
2. **Plugin-like functionality** (toast notifications, modals)
3. **Framework-like features** (form validation, tabs)

**Use props/emits when:**

1. **Direct parent-child** communication
2. **Explicit data flow** is important
3. **Component reusability** matters

---

## Component Composition Patterns

### Container/Presentational Pattern

Separate logic (container) from presentation (presentational):

**Container Component (Logic)**
```vue
<!-- UserListContainer.vue -->
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import UserListView from './UserListView.vue'

const users = ref<User[]>([])
const loading = ref(false)
const searchQuery = ref('')

const fetchUsers = async () => {
  loading.value = true
  try {
    const response = await fetch('/api/users')
    users.value = await response.json()
  } finally {
    loading.value = false
  }
}

const filteredUsers = computed(() => {
  return users.value.filter(u =>
    u.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  )
})

onMounted(fetchUsers)
</script>

<template>
  <UserListView
    :users="filteredUsers"
    :loading="loading"
    :search-query="searchQuery"
    @update:search-query="searchQuery = $event"
  />
</template>
```

**Presentational Component (UI)**
```vue
<!-- UserListView.vue -->
<script setup lang="ts">
interface Props {
  users: User[]
  loading: boolean
  searchQuery: string
}

defineProps<Props>()

const emit = defineEmits<{
  'update:searchQuery': [query: string]
}>()
</script>

<template>
  <div class="user-list">
    <input
      :value="searchQuery"
      @input="emit('update:searchQuery', $event.target.value)"
      placeholder="Search users..."
    />

    <div v-if="loading">Loading...</div>
    <UserCard v-else v-for="user in users" :key="user.id" :user="user" />
  </div>
</template>
```

### Compound Components

Components designed to work together with shared state:

```vue
<!-- Tabs.vue -->
<script setup lang="ts">
import { provide, ref, readonly } from 'vue'

const activeTab = ref(0)

provide('tabsActiveIndex', readonly(activeTab))
provide('tabsSetActive', (index: number) => {
  activeTab.value = index
})
</script>

<template>
  <div class="tabs">
    <slot></slot>
  </div>
</template>

<!-- Tab.vue -->
<script setup lang="ts">
import { inject, onMounted, ref, computed } from 'vue'

const index = ref(-1)
const activeIndex = inject('tabsActiveIndex')
const setActive = inject('tabsSetActive')
const register = inject('tabsRegister')

const isActive = computed(() => index.value === activeIndex?.value)

onMounted(() => {
  index.value = register?.() ?? -1
})
</script>

<template>
  <button
    :class="{ active: isActive }"
    @click="setActive?.(index)"
  >
    <slot></slot>
  </button>
</template>

<!-- Usage -->
<Tabs>
  <TabList>
    <Tab>Profile</Tab>
    <Tab>Settings</Tab>
  </TabList>
  <TabPanels>
    <TabPanel><UserProfile /></TabPanel>
    <TabPanel><UserSettings /></TabPanel>
  </TabPanels>
</Tabs>
```

### When to Split Components

**Split when:**
1. Component exceeds 200-300 lines
2. Multiple distinct responsibilities
3. Reusable logic/UI
4. Improves testability

**Don't split when:**
1. Components would be too granular
2. Tight coupling with parent
3. Used only once with no reuse potential

---

## Single File Component Best Practices

### Script Setup Organization

Organize imports and code in a consistent order:

```vue
<script setup lang="ts">
// 1. Type imports
import type { PropType, Ref } from 'vue'
import type { User } from '@/types'

// 2. Vue imports
import { ref, computed, watch, onMounted } from 'vue'

// 3. Component imports
import UserCard from './UserCard.vue'

// 4. Composable imports
import { useAuth } from '@/composables/useAuth'

// 5. Utility imports
import { formatDate } from '@/utils/date'

// 6. Types/Interfaces
interface Props {
  userId: string
}

// 7. Props definition
const props = defineProps<Props>()

// 8. Emits definition
const emit = defineEmits<{ close: [] }>()

// 9. Composables
const { user } = useAuth()

// 10. Reactive state
const isEditing = ref(false)

// 11. Computed properties
const displayName = computed(() => user.value?.name || 'Unknown')

// 12. Methods/functions
const save = async () => {
  // ...
}

// 13. Watchers
watch(() => props.userId, (newId) => {
  // ...
})

// 14. Lifecycle hooks
onMounted(() => {
  // ...
})
</script>
```

### Style Scoping

Always scope styles unless specifically creating global styles:

```vue
<template>
  <div class="user-card">
    <h2 class="user-card__title">{{ user.name }}</h2>
  </div>
</template>

<style scoped>
.user-card {
  padding: 1rem;
  border: 1px solid #ccc;
}

.user-card__title {
  font-size: 1.5rem;
}

/* Target child component elements */
.user-card :deep(.avatar) {
  border-radius: 50%;
}
</style>
```

### Component Naming

Follow Vue style guide conventions:

```
<!-- Good -->
UserCard.vue
ProductList.vue
TheHeader.vue  <!-- Single-instance -->

<!-- Base components -->
BaseButton.vue
BaseInput.vue

<!-- Tightly coupled -->
TodoList.vue
TodoListItem.vue
```

**In templates:**

```vue
<template>
  <!-- PascalCase for components -->
  <UserCard :user="user" />

  <!-- Self-closing for components without children -->
  <BaseIcon name="user" />
</template>
```

### File Organization

Organize component files by feature:

```
src/
├── components/
│   ├── base/          # Base/generic components
│   │   ├── BaseButton.vue
│   │   └── BaseInput.vue
│   ├── layout/        # Layout components
│   │   └── TheHeader.vue
│   └── user/          # Feature-specific
│       └── UserCard.vue
├── views/             # Page-level components
├── composables/       # Reusable composition functions
├── stores/            # Pinia stores
└── types/             # TypeScript types
```

---

## Props vs Emits vs Slots - When to Use

### Props: Pass Data Down

**Use props for:**
- Passing data from parent to child
- Configuration options
- Rendering data

```vue
<UserCard
  :user="user"
  :show-avatar="true"
  :clickable="false"
/>
```

### Emits: Send Events Up

**Use emits for:**
- User interactions
- Notifying parent of state changes
- v-model synchronization

```vue
<ItemList
  v-model="selectedItem"
  @item-selected="handleSelection"
  @delete="confirmDelete"
/>
```

### Slots: Content Injection

**Use slots for:**
- Customizing component rendering
- Layout components
- Passing complex markup

```vue
<Card>
  <template #header>
    <h2>Custom Title</h2>
  </template>

  <p>Content here</p>

  <template #footer>
    <button>Action</button>
  </template>
</Card>
```

### Provide/Inject: Deep Hierarchies

**Use provide/inject for:**
- Shared state across component tree
- Plugin-like functionality
- Avoiding prop drilling

```vue
<!-- Ancestor provides -->
<script setup lang="ts">
const theme = ref('light')
provide('theme', theme)
</script>

<!-- Deep descendant injects -->
<script setup lang="ts">
const theme = inject('theme')
</script>
```

### Decision Guide

```
Need to pass data to child?
└─ Use Props

Need to notify parent of event?
└─ Use Emits

Need to customize child rendering?
└─ Use Slots

Need to share across component tree?
└─ Use Provide/Inject

Need global state management?
└─ Use Pinia/Composable
```

### Examples by Scenario

```vue
<!-- Simple data display: Props -->
<UserAvatar :user="user" :size="48" />

<!-- Form input: Props + Emits (v-model) -->
<TextInput v-model="name" :label="Name" />

<!-- Layout: Slots -->
<PageLayout>
  <template #header><Navigation /></template>
  <MainContent />
</PageLayout>

<!-- Customizable list: Props + Scoped Slots -->
<DataList :items="users">
  <template #item="{ item }">
    <CustomUserCard :user="item" />
  </template>
</DataList>

<!-- Form validation: Provide/Inject -->
<Form>
  <FormField name="email" />
  <FormField name="password" />
</Form>

<!-- Global state: Pinia -->
<script setup>
import { useUserStore } from '@/stores/user'
const userStore = useUserStore()
</script>
```

### Anti-patterns to Avoid

```vue
<!-- DON'T: Pass everything through props (prop drilling) -->
<Level1 :theme="theme">
  <Level2 :theme="theme">
    <Level3 :theme="theme">
<!-- DO: Use provide/inject -->
provide('theme', theme)

<!-- DON'T: Use slots for simple data -->
<UserCard>
  <template #name>{{ user.name }}</template>
</UserCard>
<!-- DO: Use props -->
<UserCard :name="user.name" />

<!-- DON'T: Mutate props -->
props.count++ // Error!
<!-- DO: Emit event -->
emit('increment')
```

---

## Summary

### Key Takeaways

1. **Props** are for one-way data flow from parent to child
   - Use TypeScript type-based declaration
   - Make props required by default
   - Never mutate props

2. **Emits** enable child-to-parent communication
   - Use typed emits for type safety
   - Follow kebab-case naming conventions
   - Use `update:propertyName` for v-model

3. **Slots** allow flexible content injection
   - Named slots for multiple insertion points
   - Scoped slots to pass data to parent
   - Use `useSlots()` for conditional rendering

4. **Provide/Inject** prevents prop drilling
   - Use `InjectionKey` for type safety
   - Wrap with `readonly()` to prevent mutations
   - Ideal for framework-like features

5. **Component Composition**
   - Container/Presentational separates logic from UI
   - Compound components work together with shared state
   - Split components when they exceed 200-300 lines

6. **Best Practices**
   - Organize script setup in consistent order
   - Always scope styles unless global needed
   - Follow PascalCase naming for components
   - Organize files by feature, not type

### Quick Reference

| Pattern | Use Case | Example |
|---------|----------|---------|
| Props | Pass data down | `<Card :title="title" />` |
| Emits | Send events up | `@submit="handleSubmit"` |
| Slots | Inject content | `<template #header>...</template>` |
| Scoped Slots | Pass data to slot | `<template #item="{ item }">` |
| Provide/Inject | Deep hierarchy | `provide('theme', theme)` |
| Composables | Reusable logic | `const { data } = useFetch()` |
| Pinia | Global state | `const store = useUserStore()` |

### Additional Resources

- [Vue 3 Documentation](https://vuejs.org/)
- [Vue 3 Style Guide](https://vuejs.org/style-guide/)
- [TypeScript with Vue](https://vuejs.org/guide/typescript/overview.html)
- [Composition API FAQ](https://vuejs.org/guide/extras/composition-api-faq.html)
