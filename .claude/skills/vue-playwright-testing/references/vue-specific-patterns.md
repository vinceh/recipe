# Vue-Specific Testing Patterns

## Waiting for Vue to Mount

Before interacting with a Vue app, ensure it's fully mounted.

### Detecting Vue Mount

```typescript
// Wait for Vue DevTools hook (indicates Vue app is mounted)
await page.waitForFunction(() => {
  return !!(window as any).__VUE_DEVTOOLS_GLOBAL_HOOK__?.enabled;
});

// Alternative: Wait for a specific element to appear
await page.locator('#app').waitFor();
```

### In Test Setup

```typescript
test.beforeEach(async ({ page }) => {
  await page.goto('/');

  // Wait for Vue to mount before any interactions
  await page.waitForFunction(() => {
    const app = document.querySelector('#app');
    return app && app.hasChildNodes();
  });
});
```

## Testing Vue Router Navigation

### Waiting for Route Changes

```typescript
test('navigates to product page', async ({ page }) => {
  await page.goto('/products');

  // Click navigation link
  await page.getByRole('link', { name: 'Product 123' }).click();

  // Wait for URL change (condition-based, not timeout)
  await expect(page).toHaveURL('/products/123');

  // Verify new page rendered
  await expect(page.getByRole('heading')).toContainText('Product 123');
});
```

### Router Navigation with API Calls

```typescript
test('navigates after data loads', async ({ page }) => {
  // Mock the product API
  await page.route('**/api/products/123', async (route) => {
    await new Promise(resolve => setTimeout(resolve, 500));
    await route.fulfill({
      status: 200,
      body: JSON.stringify({
        id: 123,
        name: 'Product 123',
        price: 99.99
      })
    });
  });

  await page.goto('/products');

  // Click product
  await page.getByRole('link', { name: 'Product 123' }).click();

  // Playwright auto-waits for:
  // 1. Navigation to complete
  // 2. Network requests to finish
  // 3. DOM to update
  await expect(page.getByText('Price: $99.99')).toBeVisible();
});
```

### Testing Route Guards

```typescript
test('redirects to login when not authenticated', async ({ page }) => {
  // No auth token set
  localStorage.removeItem('auth_token');

  await page.goto('/admin');

  // Should redirect to login
  await expect(page).toHaveURL('/login');
});

test('allows access with valid authentication', async ({ page }) => {
  // Set auth token
  await page.evaluate(() => {
    localStorage.setItem('auth_token', 'valid-token-123');
  });

  await page.goto('/admin');

  // Should allow access
  await expect(page).toHaveURL('/admin');
  await expect(page.getByText('Admin Panel')).toBeVisible();
});
```

### Testing Lazy-Loaded Routes

```typescript
test('loads lazy route component', async ({ page }) => {
  await page.goto('/');

  // Click link to lazy-loaded route
  await page.getByRole('link', { name: 'Settings' }).click();

  // Wait for chunk to load and component to render
  await expect(page).toHaveURL('/settings');
  await expect(page.getByRole('heading', { name: 'Settings' })).toBeVisible();
});
```

## Testing Reactive State

### Testing Computed Properties

```typescript
test('computed property updates automatically', async ({ page }) => {
  await page.goto('/counter');

  // Verify initial computed value
  await expect(page.getByText('Count: 0')).toBeVisible();
  await expect(page.getByText('Double: 0')).toBeVisible();

  // Increment counter
  await page.getByRole('button', { name: 'Increment' }).click();

  // Computed value updates automatically (Playwright auto-waits)
  await expect(page.getByText('Count: 1')).toBeVisible();
  await expect(page.getByText('Double: 2')).toBeVisible();
});
```

### Testing Watchers

```typescript
test('watcher triggers side effect', async ({ page }) => {
  await page.goto('/search');

  // Initially no results
  await expect(page.locator('[data-testid="results"]')).toHaveCount(0);

  // Type in search (triggers watcher)
  await page.getByLabel('Search').fill('vue');

  // Results appear (watcher fetches data)
  await expect(page.locator('[data-testid="result-item"]')).not.toHaveCount(0);
});
```

### Testing Reactive Array Operations

```typescript
test('adds item to reactive list', async ({ page }) => {
  await page.goto('/todos');

  // Initially one todo
  await expect(page.locator('[data-testid="todo"]')).toHaveCount(1);

  // Add new todo
  await page.getByLabel('New todo').fill('Learn Playwright');
  await page.getByRole('button', { name: 'Add' }).click();

  // List updates (Playwright auto-waits for DOM update)
  await expect(page.locator('[data-testid="todo"]')).toHaveCount(2);
  await expect(page.getByText('Learn Playwright')).toBeVisible();
});

test('removes item from list', async ({ page }) => {
  await page.goto('/todos');

  // Count todos
  const count = await page.locator('[data-testid="todo"]').count();

  // Delete first todo
  await page.locator('[data-testid="todo"]').first().getByRole('button', { name: 'Delete' }).click();

  // List updates (one fewer item)
  await expect(page.locator('[data-testid="todo"]')).toHaveCount(count - 1);
});
```

## Testing Pinia Store

### Testing with Store State

```typescript
test('component reflects store state', async ({ page }) => {
  // Initialize store with test data
  await page.evaluate(() => {
    const store = useUserStore();
    store.setUser({ id: 1, name: 'John', email: 'john@example.com' });
  });

  await page.goto('/user');

  // Component displays store data
  await expect(page.getByText('John')).toBeVisible();
  await expect(page.getByText('john@example.com')).toBeVisible();
});
```

### Testing Store Actions

```typescript
test('dispatches store action', async ({ page }) => {
  await page.goto('/checkout');

  // Mock the payment API
  await page.route('**/api/payment', async (route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify({ orderId: '12345' })
    });
  });

  // Fill checkout form
  await page.getByLabel('Card Number').fill('4242424242424242');

  // Submit (triggers store action)
  await page.getByRole('button', { name: 'Pay Now' }).click();

  // Verify success
  await expect(page.getByText('Order #12345')).toBeVisible();
});
```

### Verifying Store State After Action

```typescript
test('updates store after action', async ({ page }) => {
  await page.goto('/cart');

  // Add item to cart
  await page.getByRole('button', { name: 'Add to Cart' }).click();

  // Verify store state changed
  const cartCount = await page.evaluate(() => {
    const store = useCartStore();
    return store.items.length;
  });

  expect(cartCount).toBe(1);

  // Also verify UI reflects change
  await expect(page.getByTestId('cart-count')).toContainText('1');
});
```

## Testing Authentication

### Mock Authentication Endpoints

```typescript
test('login with mocked auth API', async ({ page }) => {
  // Mock login endpoint
  await page.route('**/api/auth/login', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        token: 'auth-token-123',
        user: {
          id: 1,
          email: 'user@example.com',
          name: 'Test User'
        }
      })
    });
  });

  await page.goto('/login');

  // Login
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Sign In' }).click();

  // Wait for redirect to dashboard
  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByText('Welcome, Test User')).toBeVisible();
});
```

### Testing Protected Routes with Authentication

```typescript
test('accesses protected route when authenticated', async ({ page }) => {
  // Set auth token before navigation
  await page.evaluate(() => {
    localStorage.setItem('auth_token', 'valid-token');
    localStorage.setItem('user', JSON.stringify({ id: 1, role: 'admin' }));
  });

  await page.goto('/admin');

  // Should be on admin page
  await expect(page).toHaveURL('/admin');
  await expect(page.getByRole('heading', { name: 'Admin Dashboard' })).toBeVisible();
});
```

### Testing Token Expiration

```typescript
test('redirects to login when token expires', async ({ page }) => {
  // Mock token refresh endpoint to fail
  await page.route('**/api/auth/refresh', async (route) => {
    await route.fulfill({
      status: 401,
      body: JSON.stringify({ error: 'Token expired' })
    });
  });

  // Set expired token
  await page.evaluate(() => {
    localStorage.setItem('auth_token', 'expired-token');
  });

  await page.goto('/dashboard');

  // Should redirect to login
  await expect(page).toHaveURL('/login');
  await expect(page.getByText('Session expired. Please login again')).toBeVisible();
});
```

## Common Vue Patterns

### Modal/Dialog Testing

```typescript
test('opens and closes modal', async ({ page }) => {
  await page.goto('/products');

  // Modal not visible initially
  await expect(page.getByRole('dialog')).not.toBeVisible();

  // Click to open modal
  await page.getByRole('button', { name: 'View Details' }).first().click();

  // Modal becomes visible
  await expect(page.getByRole('dialog')).toBeVisible();

  // Close modal
  await page.getByRole('button', { name: 'Close' }).click();

  // Modal hidden
  await expect(page.getByRole('dialog')).not.toBeVisible();
});
```

### Tab/Accordion Testing

```typescript
test('switches between tabs', async ({ page }) => {
  await page.goto('/profile');

  // First tab initially active
  await expect(page.getByRole('tab', { name: 'Overview', selected: true })).toBeVisible();

  // Click second tab
  await page.getByRole('tab', { name: 'Settings' }).click();

  // Tab content updates
  await expect(page.getByRole('tab', { name: 'Settings', selected: true })).toBeVisible();
  await expect(page.getByRole('tabpanel')).toContainText('Change Password');
});
```

### Dropdown/Select Testing

```typescript
test('selects option from dropdown', async ({ page }) => {
  await page.goto('/settings');

  // Open dropdown
  await page.getByLabel('Theme').click();

  // Select option
  await page.getByRole('option', { name: 'Dark Mode' }).click();

  // Verify selection (and UI updates)
  await expect(page.getByLabel('Theme')).toHaveValue('dark');
  await expect(page.locator('body')).toHaveClass(/dark-theme/);
});
```

### Pagination Testing

```typescript
test('navigates pages with pagination', async ({ page }) => {
  await page.goto('/posts');

  // Initially on page 1
  await expect(page.getByRole('button', { name: '1', exact: true })).toHaveAttribute('aria-current', 'page');

  // First 10 items visible
  await expect(page.locator('[data-testid="post"]')).toHaveCount(10);

  // Go to page 2
  await page.getByRole('button', { name: '2' }).click();

  // Page updated
  await expect(page).toHaveURL(/page=2/);
  await expect(page.getByRole('button', { name: '2', exact: true })).toHaveAttribute('aria-current', 'page');
  await expect(page.locator('[data-testid="post"]')).toHaveCount(10);
});
```

## Proper Wait Strategies (Not Timeouts!)

### Waiting for Specific Conditions

```typescript
// ✅ Wait for element visibility
await page.locator('.loading-spinner').waitFor({ state: 'hidden' });

// ✅ Wait for API response
const response = await page.waitForResponse(resp =>
  resp.url().includes('/api/data') && resp.status() === 200
);

// ✅ Wait for network idle
await page.waitForLoadState('networkidle');

// ✅ Wait for specific function condition
await page.waitForFunction(() => {
  return (window as any).__DATA_LOADED__ === true;
});

// ❌ NEVER do this - it's a code smell
await page.waitForTimeout(3000);
```

### Vue-Specific Conditional Waits

```typescript
// Wait for Vue component to be interactive
await page.waitForFunction(() => {
  const app = (window as any).__VUE_APP__;
  return app && !app._loading;
});

// Wait for reactive update
await page.locator('[data-testid="user-name"]').waitFor({ state: 'attached' });
await expect(page.getByText('John Doe')).toBeVisible();

// Wait for async component
await expect(page.locator('async-component:not(.placeholder)')).toBeVisible();
```

## Summary: When and How to Wait

| Scenario | Solution | Example |
|----------|----------|---------|
| Element appears after action | `waitFor()` or `expect().toBeVisible()` | `await expect(page.getByText('Success')).toBeVisible()` |
| API call completes | `waitForResponse()` | `await page.waitForResponse(r => r.url().includes('/api'))` |
| URL changes | `expect(page).toHaveURL()` | `await expect(page).toHaveURL('/dashboard')` |
| Vue component renders | `waitForFunction()` | `await page.waitForFunction(() => document.querySelector('#app').hasChildNodes())` |
| Async operation completes | `waitForLoadState()` | `await page.waitForLoadState('networkidle')` |
| Disabled attribute removed | `locator().waitFor()` | `await page.locator('button:not([disabled])').waitFor()` |

**Golden Rule**: If you find yourself reaching for `waitForTimeout()`, stop and ask: "What specific condition am I waiting for?" Then use the appropriate Playwright API for that condition.
