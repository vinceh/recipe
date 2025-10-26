# Component Testing with Playwright (Experimental)

Playwright's experimental component testing allows testing Vue components in isolation without a full browser. This provides faster feedback while still rendering components in a real environment.

## Setup

### Enable Component Testing

Install the experimental component testing package:

```bash
npm install -D @playwright/experimental-ct-vue
```

Create `playwright/index.html`:

```html
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width" />
    <title>Component Tests</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="./index.ts"></script>
  </body>
</html>
```

Create `playwright/index.ts`:

```typescript
import { createApp } from 'vue'
import { createPinia } from 'pinia'

export async function mount(Component: any, options: any) {
  const app = createApp(Component)

  // Setup Pinia if needed
  if (options?.pinia) {
    app.use(options.pinia)
  }

  // Setup router if needed
  if (options?.router) {
    app.use(options.router)
  }

  app.mount('#app')
}
```

Configure `playwright.config.ts`:

```typescript
export default defineConfig({
  testDir: './tests/components',
  use: {
    ctViteConfig: {
      plugins: [vue()]
    }
  }
});
```

### TypeScript Support

Create `vue.d.ts`:

```typescript
declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}
```

## Testing Components

### Basic Component Mount

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import Button from '@/components/Button.vue';

test('button renders with text', async ({ mount }) => {
  const component = await mount(Button, {
    props: {
      label: 'Click me'
    }
  });

  const button = component.getByRole('button');
  await expect(button).toHaveText('Click me');
});
```

### Testing Props

```typescript
test('button disabled prop', async ({ mount }) => {
  const component = await mount(Button, {
    props: {
      label: 'Submit',
      disabled: true
    }
  });

  await expect(component.getByRole('button')).toBeDisabled();
});

test('button variant affects styling', async ({ mount }) => {
  const component = await mount(Button, {
    props: {
      label: 'Primary',
      variant: 'primary'
    }
  });

  await expect(component.getByRole('button')).toHaveClass(/primary/);
});
```

### Testing Events

```typescript
test('button emits click event', async ({ mount }) => {
  const messages: string[] = [];

  const component = await mount(Button, {
    props: {
      label: 'Click'
    },
    on: {
      click: () => messages.push('clicked')
    }
  });

  await component.getByRole('button').click();
  expect(messages).toEqual(['clicked']);
});

test('button emits custom event with data', async ({ mount }) => {
  const events: any[] = [];

  const component = await mount(Button, {
    props: { label: 'Action' },
    on: {
      action: (data: any) => events.push(data)
    }
  });

  await component.getByRole('button').click();
  expect(events[0].id).toBe('button-123');
});
```

### Testing Slots

```typescript
test('renders default slot content', async ({ mount }) => {
  const component = await mount(Card, {
    slots: {
      default: 'Card content here'
    }
  });

  await expect(component).toContainText('Card content here');
});

test('renders named slots', async ({ mount }) => {
  const component = await mount(Dialog, {
    slots: {
      header: 'Dialog Title',
      default: 'Dialog body content',
      footer: '<button>OK</button>'
    }
  });

  await expect(component.getByText('Dialog Title')).toBeVisible();
  await expect(component.getByText('Dialog body content')).toBeVisible();
  await expect(component.getByRole('button', { name: 'OK' })).toBeVisible();
});
```

### Testing Composables in Components

```typescript
test('component uses composable correctly', async ({ mount }) => {
  const component = await mount(Counter);

  // Initial state from composable
  await expect(component.getByText('Count: 0')).toBeVisible();

  // Interact and verify composable updated state
  await component.getByRole('button', { name: 'Increment' }).click();
  await expect(component.getByText('Count: 1')).toBeVisible();

  // Verify computed value from composable
  await expect(component.getByText('Double: 2')).toBeVisible();
});
```

## Advanced Patterns

### Testing with Pinia Store

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import { createPinia, setActivePinia } from 'pinia';
import { createTestingPinia } from '@pinia/testing';

test('component uses Pinia store', async ({ mount }) => {
  const pinia = createTestingPinia({
    initialState: {
      user: {
        name: 'Test User',
        email: 'test@example.com'
      }
    }
  });

  const component = await mount(UserProfile, {
    pinia
  });

  await expect(component.getByText('Test User')).toBeVisible();
  await expect(component.getByText('test@example.com')).toBeVisible();
});
```

### Testing with Mock Modules

```typescript
test('component with mocked API', async ({ mount }) => {
  const component = await mount(UserList, {
    // Mock the API call
    props: {
      // Mock data via prop
      users: [
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' }
      ]
    }
  });

  await expect(component.getByText('Alice')).toBeVisible();
  await expect(component.getByText('Bob')).toBeVisible();
});
```

### Testing Component Lifecycle

```typescript
test('component lifecycle', async ({ mount }) => {
  const component = await mount(DataFetcher);

  // Component mounts and shows loading
  await expect(component.getByText('Loading...')).toBeVisible();

  // After mounted hook fires, data loads
  await expect(component.getByText('Data loaded')).toBeVisible();

  // Update component
  const updated = await component.update({
    props: { refreshTrigger: 2 }
  });

  // Data refetches
  await expect(updated.getByText('Data reloaded')).toBeVisible();
});
```

## Testing Complex Components

### Form Component with Validation

```typescript
test('form validates inputs', async ({ mount }) => {
  const component = await mount(ContactForm);

  // Try submitting empty form
  await component.getByRole('button', { name: 'Submit' }).click();

  // Validation errors appear
  await expect(component.getByText('Name is required')).toBeVisible();
  await expect(component.getByText('Email is required')).toBeVisible();

  // Fill form
  await component.getByLabel('Name').fill('John Doe');
  await component.getByLabel('Email').fill('john@example.com');

  // Errors disappear
  await expect(component.getByText('Name is required')).not.toBeVisible();
});

test('form emits submit event with data', async ({ mount }) => {
  const submittedData: any[] = [];

  await mount(ContactForm, {
    on: {
      submit: (data) => submittedData.push(data)
    }
  });

  // Fill and submit
  await component.getByLabel('Name').fill('Jane');
  await component.getByLabel('Email').fill('jane@example.com');
  await component.getByRole('button', { name: 'Submit' }).click();

  expect(submittedData[0]).toEqual({
    name: 'Jane',
    email: 'jane@example.com'
  });
});
```

### List Component with Filtering

```typescript
test('list filters items', async ({ mount }) => {
  const component = await mount(ProductList, {
    props: {
      products: [
        { id: 1, name: 'Laptop', category: 'Electronics' },
        { id: 2, name: 'Mouse', category: 'Electronics' },
        { id: 3, name: 'Desk', category: 'Furniture' }
      ]
    }
  });

  // All items visible initially
  await expect(component.getByText('Laptop')).toBeVisible();
  await expect(component.getByText('Desk')).toBeVisible();

  // Filter by category
  await component.getByLabel('Category').selectOption('Electronics');

  // Only electronics visible
  await expect(component.getByText('Laptop')).toBeVisible();
  await expect(component.getByText('Mouse')).toBeVisible();
  await expect(component.getByText('Desk')).not.toBeVisible();
});
```

## Best Practices

### 1. Test from User Perspective

```typescript
// ✅ Good: Test observable behavior
test('user can select item', async ({ mount }) => {
  const component = await mount(Dropdown);

  await component.getByRole('combobox').click();
  await component.getByRole('option', { name: 'Option A' }).click();

  await expect(component.getByRole('combobox')).toHaveValue('Option A');
});

// ❌ Bad: Testing implementation details
test('internal state updates', async ({ mount }) => {
  const component = await mount(Dropdown);
  // Can't access internal Vue component state this way
});
```

### 2. Keep Component Tests Focused

```typescript
// ✅ Good: Test one behavior
test('button click handler works', async ({ mount }) => {
  const clicks: number[] = [];

  await mount(Button, {
    on: {
      click: () => clicks.push(1)
    }
  });

  await component.getByRole('button').click();
  expect(clicks).toHaveLength(1);
});

// ❌ Bad: Testing multiple unrelated behaviors
test('button works with slots and validation and events', async ({ mount }) => {
  // Too many assertions, hard to debug if it fails
});
```

### 3. Mock External Dependencies

```typescript
// ✅ Good: Mock the API
test('loading state while fetching', async ({ mount }) => {
  const component = await mount(DataComponent, {
    props: {
      // Pass mock data to avoid API call
      initialData: null,
      onLoadData: async () => ({
        items: [{ id: 1, title: 'Item' }]
      })
    }
  });

  await expect(component.getByText('Loading')).toBeVisible();
  await new Promise(resolve => setTimeout(resolve, 100));
  await expect(component.getByText('Item')).toBeVisible();
});
```

## Running Component Tests

```bash
# Run all component tests
npx playwright test tests/components

# Run specific component test
npx playwright test tests/components/Button.spec.ts

# Run in headed mode for debugging
npx playwright test tests/components --headed

# Debug mode with inspector
npx playwright test tests/components --debug
```

## Limitations and Considerations

- Component testing is still experimental - API may change
- Limited to Chromium browser
- Shadow DOM testing has limitations
- Complex state management setup may be verbose
- For integration testing of multiple components, prefer E2E tests

## When to Use Component Tests vs E2E Tests

**Use component tests for:**
- Isolated component behavior
- Props, events, and slots
- Component-specific logic
- Fast feedback during development

**Use E2E tests for:**
- Multi-component workflows
- Real routing and navigation
- API interactions
- Complete user journeys
- Browser compatibility verification
