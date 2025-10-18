# Vue 3 Testing Guide (2025)

A comprehensive guide to testing Vue 3 applications using modern tooling and best practices.

## Summary

This guide covers Vue 3 testing using **Vitest** (the 2025 standard), **@vue/test-utils**, and **@testing-library/vue**. It emphasizes testing user behavior over implementation details, leveraging Vitest's native ESM support and Vite integration for fast, reliable tests.

Key principles:
- Test what users see and do, not implementation details
- Use Vitest (not Jest) for Vue 3 projects
- Prefer Testing Library queries (getByRole, getByText)
- Keep tests simple, readable, and focused
- Mock external dependencies, not internal logic

---

## 1. Testing Stack (2025)

### Core Tools

**Vitest** - The modern testing framework for Vue 3
- Native ESM support (no transpilation needed)
- Seamless Vite integration (shares config)
- Extremely fast (powered by Vite)
- Jest-compatible API
- Built-in TypeScript support

**@vue/test-utils** - Official Vue testing library
- Component mounting (mount, shallowMount)
- Props, emits, slots testing
- Vue-specific APIs

**@testing-library/vue** - User-centric testing
- Focus on user behavior
- Semantic queries (getByRole, getByLabelText)
- Encourages accessible markup

### Why Vitest in 2025?

Vitest solves Jest's issues with Vue 3: native ESM, no config overhead, uses your existing Vite config, instant transformation, and first-class TypeScript support.

---

## 2. Vitest Setup

### Installation

```bash
npm install -D vitest @vue/test-utils @testing-library/vue
npm install -D jsdom @vitest/ui @vitest/coverage-v8
```

### vitest.config.ts

```typescript
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/main.ts', '**/*.spec.ts'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
})
```

### vitest.setup.ts

```typescript
import { expect, afterEach } from 'vitest'
import { cleanup } from '@testing-library/vue'
import matchers from '@testing-library/jest-dom/matchers'

expect.extend(matchers)
afterEach(() => cleanup())
```

### package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## 3. Component Testing Basics

### mount() vs shallowMount()

```typescript
import { mount, shallowMount } from '@vue/test-utils'

// mount() - Renders component AND all children (preferred)
const wrapper = mount(MyComponent)

// shallowMount() - Renders component, stubs children
// Use only when performance is an issue
const wrapper = shallowMount(MyComponent)
```

### Finding Elements (Testing Library Way)

```typescript
import { render, screen } from '@testing-library/vue'

describe('UserProfile', () => {
  it('displays user information', () => {
    render(UserProfile, {
      props: { name: 'Alice', role: 'Admin' },
    })

    // ✅ BEST: getByRole (accessible, semantic)
    const heading = screen.getByRole('heading', { name: 'Alice' })
    expect(heading).toBeInTheDocument()

    // ✅ GOOD: getByLabelText (forms)
    const emailInput = screen.getByLabelText('Email')

    // ✅ GOOD: getByText (content)
    const role = screen.getByText('Admin')

    // ⚠️ AVOID: getByTestId (only as last resort)
  })
})
```

### Query Priority

```typescript
// Use this priority order:
// 1. getByRole          - Most accessible
// 2. getByLabelText     - Forms
// 3. getByPlaceholderText
// 4. getByText          - Non-interactive content
// 5. getByDisplayValue  - Form current values
// 6. getByAltText       - Images
// 7. getByTitle
// 8. getByTestId        - Last resort only
```

### Triggering Events

```typescript
import { render, screen } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'

describe('Button', () => {
  it('handles click events', async () => {
    const { emitted } = render(MyButton)
    const button = screen.getByRole('button', { name: 'Submit' })

    const user = userEvent.setup()
    await user.click(button)

    expect(emitted()).toHaveProperty('click')
  })
})
```

### Testing Library Philosophy

```typescript
// ❌ BAD: Testing implementation details
it('increments count data property', () => {
  const wrapper = mount(Counter)
  wrapper.vm.count = 5
  expect(wrapper.vm.count).toBe(5)
})

// ✅ GOOD: Testing user behavior
it('increments count when button clicked', async () => {
  render(Counter)
  const button = screen.getByRole('button', { name: '+' })

  await userEvent.setup().click(button)

  expect(screen.getByText('Count: 1')).toBeInTheDocument()
})
```

---

## 4. Testing Props and Emits

### Passing Props

```typescript
describe('ProductCard', () => {
  it('displays product information', () => {
    render(ProductCard, {
      props: {
        title: 'Laptop',
        price: 999,
        inStock: true,
      },
    })

    expect(screen.getByText('Laptop')).toBeInTheDocument()
    expect(screen.getByText('$999')).toBeInTheDocument()
  })
})
```

### Testing Emitted Events

```typescript
describe('AddToCartButton', () => {
  it('emits add-to-cart event with product id', async () => {
    const { emitted } = render(AddToCartButton, {
      props: { productId: '123' },
    })

    const button = screen.getByRole('button', { name: 'Add to Cart' })
    await userEvent.setup().click(button)

    expect(emitted()).toHaveProperty('add-to-cart')
    expect(emitted()['add-to-cart'][0]).toEqual(['123'])
  })
})
```

---

## 5. Testing Slots

### Default and Named Slots

```typescript
describe('Modal', () => {
  it('renders header, body, and footer slots', () => {
    render(Modal, {
      slots: {
        header: '<h2>Modal Title</h2>',
        default: '<p>Modal body</p>',
        footer: '<button>Close</button>',
      },
    })

    expect(screen.getByRole('heading', { name: 'Modal Title' })).toBeInTheDocument()
    expect(screen.getByText('Modal body')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Close' })).toBeInTheDocument()
  })
})
```

### Scoped Slots

```typescript
import { h } from 'vue'

describe('DataTable', () => {
  it('provides item data to scoped slot', () => {
    const items = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }]

    render(DataTable, {
      props: { items },
      slots: {
        default: ({ item }) => h('div', {}, `User: ${item.name}`),
      },
    })

    expect(screen.getByText('User: Alice')).toBeInTheDocument()
    expect(screen.getByText('User: Bob')).toBeInTheDocument()
  })
})
```

---

## 6. Testing Composables

### Basic Composable Testing

```typescript
// composables/useCounter.ts
import { ref } from 'vue'

export function useCounter(initialValue = 0) {
  const count = ref(initialValue)
  const increment = () => count.value++
  const decrement = () => count.value--
  return { count, increment, decrement }
}

// composables/useCounter.spec.ts
describe('useCounter', () => {
  it('increments count', () => {
    const { count, increment } = useCounter()
    increment()
    expect(count.value).toBe(1)
  })
})
```

### Testing Lifecycle-Dependent Composables

```typescript
describe('useWindowSize', () => {
  it('tracks window size', async () => {
    const TestComponent = defineComponent({
      setup() {
        return useWindowSize()
      },
      template: '<div>{{ width }} x {{ height }}</div>',
    })

    const wrapper = mount(TestComponent)
    expect(wrapper.vm.width).toBe(window.innerWidth)

    window.innerWidth = 800
    window.dispatchEvent(new Event('resize'))
    await wrapper.vm.$nextTick()

    expect(wrapper.vm.width).toBe(800)
  })
})
```

### Mocking Dependencies in Composables

```typescript
vi.mock('@/api/users', () => ({
  fetchUser: vi.fn(),
}))

describe('useUser', () => {
  it('fetches user on mount', async () => {
    const mockUser = { id: '1', name: 'Alice' }
    vi.mocked(usersApi.fetchUser).mockResolvedValue(mockUser)

    const TestComponent = defineComponent({
      setup() { return useUser('1') },
      template: '<div></div>',
    })

    const wrapper = mount(TestComponent)
    expect(wrapper.vm.loading).toBe(true)

    await vi.waitFor(() => {
      expect(wrapper.vm.loading).toBe(false)
    })

    expect(wrapper.vm.user).toEqual(mockUser)
  })
})
```

---

## 7. Mocking

### Mock API Calls

```typescript
describe('UserList', () => {
  it('displays users from API', async () => {
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve([
          { id: 1, name: 'Alice' },
          { id: 2, name: 'Bob' },
        ]),
      })
    ) as any

    render(UserList)

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument()
    })

    expect(screen.getByText('Bob')).toBeInTheDocument()
  })
})
```

### Mock Vue Router

```typescript
describe('Navigation', () => {
  it('navigates to profile page', async () => {
    const router = createRouter({
      history: createMemoryHistory(),
      routes: [
        { path: '/', name: 'Home', component: { template: '<div>Home</div>' } },
        { path: '/profile', name: 'Profile', component: { template: '<div>Profile</div>' } },
      ],
    })

    render(Navigation, {
      global: { plugins: [router] },
    })

    const profileLink = screen.getByRole('link', { name: 'Profile' })
    await userEvent.setup().click(profileLink)

    expect(router.currentRoute.value.path).toBe('/profile')
  })
})
```

### Mock Pinia Stores

```typescript
describe('CartSummary', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('displays cart total', () => {
    const cartStore = useCartStore()
    cartStore.items = [
      { id: 1, name: 'Laptop', price: 999, quantity: 1 },
      { id: 2, name: 'Mouse', price: 25, quantity: 2 },
    ]

    render(CartSummary, {
      global: { plugins: [createPinia()] },
    })

    expect(screen.getByText('Total: $1,049')).toBeInTheDocument()
  })
})
```

### vi.mock() Patterns

```typescript
// Mock entire module
vi.mock('@/utils/analytics', () => ({
  trackEvent: vi.fn(),
  trackPageView: vi.fn(),
}))

// Partial mock (keep some real implementations)
vi.mock('@/utils/helpers', async () => {
  const actual = await vi.importActual('@/utils/helpers')
  return {
    ...actual,
    formatDate: vi.fn(() => '2025-01-01'),
  }
})
```

---

## 8. Async Testing

### Testing Async Setup

```typescript
describe('UserProfile', () => {
  it('loads user data', async () => {
    vi.mocked(fetchUser).mockResolvedValue({
      id: '1',
      name: 'Alice',
      email: 'alice@example.com',
    })

    render(UserProfile, {
      props: { userId: '1' },
    })

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument()
    })

    expect(screen.getByText('alice@example.com')).toBeInTheDocument()
  })
})
```

### waitFor Utilities

```typescript
// waitFor - Poll until condition is true
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument()
})

// findBy queries (built-in waitFor)
const element = await screen.findByText('Loaded')
expect(element).toBeInTheDocument()
```

### Testing Error States

```typescript
describe('UserProfile', () => {
  it('shows error message on fetch failure', async () => {
    vi.mocked(fetchUser).mockRejectedValue(new Error('User not found'))

    render(UserProfile, { props: { userId: '999' } })

    await waitFor(() => {
      expect(screen.getByText('Error: User not found')).toBeInTheDocument()
    })
  })

  it('allows retry after error', async () => {
    vi.mocked(fetchUser)
      .mockRejectedValueOnce(new Error('Network error'))
      .mockResolvedValueOnce({ id: '1', name: 'Alice' })

    render(UserProfile, { props: { userId: '1' } })

    await screen.findByText('Error: Network error')

    const retryButton = screen.getByRole('button', { name: 'Retry' })
    await userEvent.setup().click(retryButton)

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument()
    })
  })
})
```

---

## 9. Testing User Interactions

### Form Inputs

```typescript
describe('LoginForm', () => {
  it('submits form with user input', async () => {
    const onSubmit = vi.fn()
    render(LoginForm, { props: { onSubmit } })

    const user = userEvent.setup()
    const emailInput = screen.getByLabelText('Email')
    const passwordInput = screen.getByLabelText('Password')

    await user.type(emailInput, 'alice@example.com')
    await user.type(passwordInput, 'secret123')

    const submitButton = screen.getByRole('button', { name: 'Login' })
    await user.click(submitButton)

    expect(onSubmit).toHaveBeenCalledWith({
      email: 'alice@example.com',
      password: 'secret123',
    })
  })
})
```

### Keyboard Events

```typescript
describe('SearchInput', () => {
  it('triggers search on Enter key', async () => {
    const onSearch = vi.fn()
    render(SearchInput, { props: { onSearch } })

    const user = userEvent.setup()
    const input = screen.getByRole('searchbox')

    await user.type(input, 'vue testing')
    await user.keyboard('{Enter}')

    expect(onSearch).toHaveBeenCalledWith('vue testing')
  })
})
```

### Focus Management

```typescript
describe('Modal', () => {
  it('focuses first input when opened', async () => {
    const { rerender } = render(Modal, {
      props: { isOpen: false },
    })

    await rerender({ isOpen: true })

    const firstInput = screen.getByLabelText('Name')
    expect(firstInput).toHaveFocus()
  })
})
```

---

## 10. Best Practices

### Don't Test Implementation Details

```typescript
// ❌ BAD: Testing internal state
it('sets isLoading to false', () => {
  const wrapper = mount(Component)
  expect(wrapper.vm.isLoading).toBe(false)
})

// ✅ GOOD: Test user-visible behavior
it('does not show loading spinner', () => {
  render(Component)
  expect(screen.queryByRole('progressbar')).not.toBeInTheDocument()
})
```

### Test User Behavior, Not Internals

```typescript
// ❌ BAD: Testing method calls
it('calls updateCart method', () => {
  const wrapper = mount(ProductCard)
  const spy = vi.spyOn(wrapper.vm, 'updateCart')
  wrapper.vm.addToCart()
  expect(spy).toHaveBeenCalled()
})

// ✅ GOOD: Test what happens to the user
it('adds item to cart when button clicked', async () => {
  const cartStore = useCartStore()
  render(ProductCard, { props: { productId: '123' } })

  const addButton = screen.getByRole('button', { name: 'Add to Cart' })
  await userEvent.setup().click(addButton)

  expect(cartStore.items).toHaveLength(1)
  expect(screen.getByText('Added to cart')).toBeInTheDocument()
})
```

### Prefer getByRole Over getByText

```typescript
// ❌ AVOID: Too specific, breaks easily
screen.getByText('Click here to submit the form')

// ✅ BETTER: More flexible
screen.getByText(/submit/i)

// ✅ BEST: Semantic, accessible
screen.getByRole('button', { name: /submit/i })
```

### Keep Tests Simple and Readable

```typescript
// ✅ GOOD: Clear, descriptive
it('displays success message after saving', async () => {
  render(EditProfile)

  const nameInput = screen.getByLabelText('Name')
  await userEvent.setup().type(nameInput, 'Alice')

  const saveButton = screen.getByRole('button', { name: 'Save' })
  await userEvent.setup().click(saveButton)

  expect(screen.getByText('Profile saved successfully')).toBeInTheDocument()
})
```

### One Assertion Concept Per Test

```typescript
// ✅ GOOD: Separate concerns
it('submits form with valid data', async () => {
  // Only test successful submission
})

it('navigates to dashboard after submission', async () => {
  // Only test navigation
})

it('shows error message for invalid data', async () => {
  // Only test error handling
})
```

---

## 11. E2E Testing Considerations

### When to Use E2E Tests

Use E2E (Playwright or Cypress) for:
- Critical user flows (login, checkout, payment)
- Multi-page workflows
- Integration with real backend
- Browser-specific behavior
- Visual regression

Don't use E2E for:
- Unit logic (use component tests)
- Component variations (use component tests)
- Edge cases (too slow for E2E)
- Quick feedback (E2E is slow)

### E2E vs Component Tests

```typescript
// Component test: Fast, isolated, many variations
describe('LoginForm', () => {
  it('shows error for invalid email')
  it('shows error for short password')
  it('disables button while loading')
  // ... 20+ test cases, runs in seconds
})

// E2E test: Slow, integrated, critical path only
describe('User Login Flow', () => {
  it('allows user to login and access dashboard', () => {
    // Single happy path test with real backend
  })
})
```

### Testing Strategy

```
Component Tests (80%)          E2E Tests (20%)
├─ Fast (milliseconds)         ├─ Slow (seconds/minutes)
├─ Isolated                    ├─ Integrated
├─ Many variations             ├─ Critical paths only
├─ Mock dependencies           ├─ Real backend
└─ Run on every commit         └─ Run before deployment

Testing Pyramid:
       E2E (Few, slow)
      /              \
     /  Integration   \
    /   (Some, med)    \
   /                    \
  /  Unit/Component     \
 /    (Many, fast)       \
```

---

## 12. Code Coverage

### Coverage Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.{js,ts,vue}'],
      exclude: ['node_modules/', 'src/main.ts', '**/*.spec.ts'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
})
```

### Coverage Best Practices

```typescript
// ✅ GOOD: Write tests for behavior, coverage follows
it('displays error for invalid input', async () => {
  // This naturally covers error handling code
})

// ❌ BAD: Write tests just to increase coverage
it('sets error to null', () => {
  wrapper.vm.error = null
  expect(wrapper.vm.error).toBeNull() // Meaningless test
})

// Focus on:
// - Critical business logic
// - Error handling paths
// - Edge cases
// - User interactions

// Don't worry about:
// - Type definitions
// - Constants/configs
// - Simple getters/setters
```

---

## Final Recommendations

### Testing Checklist

- Use Vitest (not Jest) for Vue 3 projects
- Install @testing-library/vue for user-centric tests
- Configure coverage with 80% thresholds
- Test user behavior, not implementation
- Prefer getByRole over other queries
- Use async/await for all async operations
- Mock external dependencies (APIs, stores, router)
- Write descriptive test names
- One assertion concept per test
- Keep tests simple and readable

### Common Pitfalls to Avoid

```typescript
// ❌ Don't access vm internals
wrapper.vm.someMethod()

// ❌ Don't test implementation details
expect(wrapper.find('.some-class').exists()).toBe(true)

// ❌ Don't use arbitrary test IDs
screen.getByTestId('wrapper-div-123')

// ❌ Don't forget await for async operations
userEvent.click(button)  // Wrong
await userEvent.click(button)  // Correct

// ❌ Don't mock everything
vi.mock('vue')  // Never do this
```

### Learning Resources

- [Vitest Documentation](https://vitest.dev)
- [Vue Test Utils](https://test-utils.vuejs.org)
- [Testing Library](https://testing-library.com/docs/vue-testing-library/intro)
- [Common Testing Mistakes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

---

**Remember**: Good tests give you confidence to refactor, catch bugs early, and document how your code should behave. Focus on testing what matters to users, not implementation details.
