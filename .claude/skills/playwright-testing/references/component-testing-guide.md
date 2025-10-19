# Component Testing Guide for Playwright

## Overview

Component testing with Playwright allows you to test UI components in isolation, providing faster feedback than end-to-end tests while maintaining the benefits of real browser testing. This guide covers component testing for React, Vue, and Angular applications.

## Setup and Configuration

### Installing Playwright Component Testing

```bash
# For React
npm init playwright@latest -- --ct

# For Vue
npm init playwright@latest -- --ct

# For Angular (Experimental)
npm init playwright@latest -- --ct
```

### Configuration File

```typescript
// playwright-ct.config.ts
import { defineConfig, devices } from '@playwright/experimental-ct-react';
// For Vue: '@playwright/experimental-ct-vue'
// For Angular: '@playwright/experimental-ct-angular'

export default defineConfig({
  testDir: './tests/components',
  use: {
    trace: 'on-first-retry',
    ctPort: 3100,
    ctViteConfig: {
      // Vite configuration for component testing
      resolve: {
        alias: {
          '@': '/src',
        },
      },
    },
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
  ],
});
```

## React Component Testing

### Basic React Component Test

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { Button } from './Button';

test('button renders with correct text', async ({ mount }) => {
  const component = await mount(
    <Button variant="primary">Click me</Button>
  );

  await expect(component).toContainText('Click me');
  await expect(component).toHaveClass(/primary/);
});

test('button handles click events', async ({ mount }) => {
  let clicked = false;
  const component = await mount(
    <Button onClick={() => clicked = true}>
      Click me
    </Button>
  );

  await component.click();
  expect(clicked).toBe(true);
});
```

### Testing React Hooks

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { Counter } from './Counter';

test('counter increments on click', async ({ mount }) => {
  const component = await mount(<Counter initialCount={0} />);

  const counter = component.getByTestId('counter-value');
  await expect(counter).toHaveText('0');

  const incrementButton = component.getByRole('button', { name: 'Increment' });
  await incrementButton.click();

  await expect(counter).toHaveText('1');
});
```

### Testing React Context

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { ThemeProvider } from './ThemeContext';
import { ThemedButton } from './ThemedButton';

test('component uses theme context', async ({ mount }) => {
  const component = await mount(
    <ThemeProvider theme="dark">
      <ThemedButton>Click me</ThemedButton>
    </ThemeProvider>
  );

  await expect(component).toHaveClass(/dark-theme/);
});
```

### Testing React Forms

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { LoginForm } from './LoginForm';

test('form validation works', async ({ mount }) => {
  const onSubmit = jest.fn();
  const component = await mount(
    <LoginForm onSubmit={onSubmit} />
  );

  // Submit empty form
  await component.getByRole('button', { name: 'Submit' }).click();
  await expect(component.getByText('Email is required')).toBeVisible();

  // Fill and submit valid form
  await component.getByLabel('Email').fill('user@example.com');
  await component.getByLabel('Password').fill('password123');
  await component.getByRole('button', { name: 'Submit' }).click();

  expect(onSubmit).toHaveBeenCalledWith({
    email: 'user@example.com',
    password: 'password123'
  });
});
```

## Vue Component Testing

### Basic Vue Component Test

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import Button from './Button.vue';

test('button renders with slot content', async ({ mount }) => {
  const component = await mount(Button, {
    slots: {
      default: 'Click me'
    },
    props: {
      variant: 'primary'
    }
  });

  await expect(component).toContainText('Click me');
  await expect(component).toHaveClass(/btn-primary/);
});

test('button emits events', async ({ mount }) => {
  let clickCount = 0;
  const component = await mount(Button, {
    props: {
      variant: 'primary'
    },
    on: {
      click: () => clickCount++
    }
  });

  await component.click();
  expect(clickCount).toBe(1);
});
```

### Testing Vue Composition API

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import Counter from './Counter.vue';

test('counter with composition API', async ({ mount }) => {
  const component = await mount(Counter, {
    props: {
      initialValue: 5
    }
  });

  const display = component.getByTestId('counter-display');
  await expect(display).toHaveText('5');

  await component.getByRole('button', { name: '+' }).click();
  await expect(display).toHaveText('6');

  await component.getByRole('button', { name: '-' }).click();
  await expect(display).toHaveText('5');
});
```

### Testing Vue Slots

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import Card from './Card.vue';

test('card renders with named slots', async ({ mount }) => {
  const component = await mount(Card, {
    slots: {
      header: '<h2>Card Title</h2>',
      default: '<p>Card content goes here</p>',
      footer: '<button>Action</button>'
    }
  });

  await expect(component.getByRole('heading')).toHaveText('Card Title');
  await expect(component.getByText('Card content goes here')).toBeVisible();
  await expect(component.getByRole('button')).toHaveText('Action');
});
```

### Testing Vue with Pinia Store

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import { createTestingPinia } from '@pinia/testing';
import TodoList from './TodoList.vue';

test('todo list with pinia store', async ({ mount }) => {
  const component = await mount(TodoList, {
    hooksConfig: {
      plugins: [
        createTestingPinia({
          initialState: {
            todos: {
              items: [
                { id: 1, text: 'Buy groceries', done: false },
                { id: 2, text: 'Walk the dog', done: true }
              ]
            }
          }
        })
      ]
    }
  });

  const todoItems = component.getByRole('listitem');
  await expect(todoItems).toHaveCount(2);

  // Check first todo
  await expect(todoItems.first()).toContainText('Buy groceries');
  await expect(todoItems.first().getByRole('checkbox')).not.toBeChecked();
});
```

## Angular Component Testing

### Basic Angular Component Test

```typescript
import { test, expect } from '@playwright/experimental-ct-angular';
import { ButtonComponent } from './button.component';

test('button renders correctly', async ({ mount }) => {
  const component = await mount(ButtonComponent, {
    props: {
      label: 'Click me',
      type: 'primary'
    }
  });

  await expect(component).toContainText('Click me');
  await expect(component).toHaveClass(/btn-primary/);
});

test('button emits click event', async ({ mount }) => {
  let clicked = false;
  const component = await mount(ButtonComponent, {
    props: {
      label: 'Click'
    },
    on: {
      clicked: () => clicked = true
    }
  });

  await component.click();
  expect(clicked).toBe(true);
});
```

### Testing Angular Forms

```typescript
import { test, expect } from '@playwright/experimental-ct-angular';
import { FormComponent } from './form.component';
import { ReactiveFormsModule } from '@angular/forms';

test('reactive form validation', async ({ mount }) => {
  const component = await mount(FormComponent, {
    imports: [ReactiveFormsModule]
  });

  const emailInput = component.getByLabel('Email');
  const submitButton = component.getByRole('button', { name: 'Submit' });

  // Check initial state
  await expect(submitButton).toBeDisabled();

  // Enter invalid email
  await emailInput.fill('invalid');
  await expect(component.getByText('Invalid email format')).toBeVisible();

  // Enter valid email
  await emailInput.fill('user@example.com');
  await expect(submitButton).toBeEnabled();
});
```

### Testing Angular Services

```typescript
import { test, expect } from '@playwright/experimental-ct-angular';
import { TodoComponent } from './todo.component';
import { TodoService } from './todo.service';

test('component with mocked service', async ({ mount }) => {
  const mockTodoService = {
    getTodos: () => Promise.resolve([
      { id: 1, title: 'Test todo', completed: false }
    ])
  };

  const component = await mount(TodoComponent, {
    providers: [
      { provide: TodoService, useValue: mockTodoService }
    ]
  });

  await expect(component.getByText('Test todo')).toBeVisible();
});
```

## Advanced Component Testing Patterns

### Testing with Mock Data

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { UserList } from './UserList';

test('renders list with mock data', async ({ mount }) => {
  const mockUsers = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
  ];

  const component = await mount(
    <UserList users={mockUsers} />
  );

  const userItems = component.getByRole('listitem');
  await expect(userItems).toHaveCount(2);
  await expect(userItems.first()).toContainText('John Doe');
});
```

### Testing Loading States

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { DataTable } from './DataTable';

test('shows loading state', async ({ mount }) => {
  const component = await mount(
    <DataTable isLoading={true} data={[]} />
  );

  await expect(component.getByRole('progressbar')).toBeVisible();
  await expect(component.getByText('Loading...')).toBeVisible();
});

test('shows data after loading', async ({ mount }) => {
  const component = await mount(
    <DataTable
      isLoading={false}
      data={[{ id: 1, name: 'Item 1' }]}
    />
  );

  await expect(component.getByRole('progressbar')).not.toBeVisible();
  await expect(component.getByText('Item 1')).toBeVisible();
});
```

### Testing Error States

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import ErrorBoundary from './ErrorBoundary.vue';

test('displays error message', async ({ mount }) => {
  const component = await mount(ErrorBoundary, {
    props: {
      error: new Error('Something went wrong'),
      showDetails: true
    }
  });

  await expect(component.getByRole('alert')).toBeVisible();
  await expect(component).toContainText('Something went wrong');
  await expect(component.getByRole('button', { name: 'Retry' })).toBeVisible();
});
```

### Testing Accessibility

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { injectAxe, checkA11y } from 'axe-playwright';
import { Modal } from './Modal';

test('modal is accessible', async ({ mount, page }) => {
  const component = await mount(
    <Modal isOpen={true} title="Confirm Action">
      <p>Are you sure you want to continue?</p>
      <button>Cancel</button>
      <button>Confirm</button>
    </Modal>
  );

  await injectAxe(page);
  await checkA11y(page);

  // Check ARIA attributes
  await expect(component).toHaveAttribute('role', 'dialog');
  await expect(component).toHaveAttribute('aria-modal', 'true');
  await expect(component).toHaveAttribute('aria-labelledby', /.+/);
});
```

### Testing Responsive Components

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { ResponsiveNav } from './ResponsiveNav';

test.describe('responsive navigation', () => {
  test('shows hamburger menu on mobile', async ({ mount, page }) => {
    await page.setViewportSize({ width: 375, height: 667 });

    const component = await mount(<ResponsiveNav />);

    await expect(component.getByRole('button', { name: 'Menu' })).toBeVisible();
    await expect(component.getByRole('navigation')).not.toBeVisible();
  });

  test('shows full menu on desktop', async ({ mount, page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });

    const component = await mount(<ResponsiveNav />);

    await expect(component.getByRole('button', { name: 'Menu' })).not.toBeVisible();
    await expect(component.getByRole('navigation')).toBeVisible();
  });
});
```

### Testing Component Interactions

```typescript
import { test, expect } from '@playwright/experimental-ct-vue';
import DragDropList from './DragDropList.vue';

test('drag and drop reorders items', async ({ mount, page }) => {
  const component = await mount(DragDropList, {
    props: {
      items: ['Item 1', 'Item 2', 'Item 3']
    }
  });

  const items = component.getByRole('listitem');
  const firstItem = items.first();
  const lastItem = items.last();

  // Drag first item to last position
  await firstItem.dragTo(lastItem);

  // Verify new order
  const updatedItems = component.getByRole('listitem');
  await expect(updatedItems.first()).toContainText('Item 2');
  await expect(updatedItems.last()).toContainText('Item 1');
});
```

## Performance Testing

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { LargeList } from './LargeList';

test('renders large list efficiently', async ({ mount, page }) => {
  const items = Array.from({ length: 1000 }, (_, i) => ({
    id: i,
    name: `Item ${i}`
  }));

  const startTime = Date.now();
  const component = await mount(<LargeList items={items} />);
  const renderTime = Date.now() - startTime;

  // Check render performance
  expect(renderTime).toBeLessThan(1000); // Should render in less than 1s

  // Check virtualization is working
  const visibleItems = await component.getByRole('listitem').count();
  expect(visibleItems).toBeLessThan(50); // Only visible items should be rendered
});
```

## Testing with External Dependencies

```typescript
import { test, expect } from '@playwright/experimental-ct-react';
import { MapComponent } from './MapComponent';

test('map component with mocked API', async ({ mount, page }) => {
  // Mock external map API
  await page.addInitScript(() => {
    window.google = {
      maps: {
        Map: class MockMap {
          constructor() {}
          setCenter() {}
          setZoom() {}
        },
        Marker: class MockMarker {
          constructor() {}
          setPosition() {}
        }
      }
    };
  });

  const component = await mount(
    <MapComponent
      center={{ lat: 40.7128, lng: -74.0060 }}
      zoom={12}
    />
  );

  await expect(component.getByTestId('map-container')).toBeVisible();
});
```

## Best Practices

1. **Keep tests focused**: Test one component behavior at a time
2. **Use data-testid sparingly**: Prefer semantic queries
3. **Mock external dependencies**: Keep tests fast and isolated
4. **Test user interactions**: Focus on how users interact with components
5. **Test accessibility**: Include a11y checks in component tests
6. **Use fixtures for common setups**: Reduce boilerplate code
7. **Test error boundaries**: Ensure components handle errors gracefully
8. **Test responsive behavior**: Verify components work across viewports
9. **Keep tests maintainable**: Use page objects for complex components
10. **Run tests in CI**: Include component tests in your pipeline