# Best Practices and Anti-Patterns

## Timeout Anti-Patterns (Critical!)

### The Timeout Problem

Using `waitForTimeout()` to "fix" flaky tests is a major anti-pattern. It masks underlying issues and creates brittle, slow tests.

**❌ BAD CODE SMELL:**
```typescript
// This indicates something is wrong - don't do this!
test('login works', async ({ page }) => {
  await page.goto('/login');
  await page.fill('input[type="email"]', 'user@example.com');
  await page.fill('input[type="password"]', 'password');
  await page.click('button');

  // THIS IS WRONG - masking a real problem
  await page.waitForTimeout(5000);

  await expect(page).toHaveURL('/dashboard');
});
```

**Why timeouts are dangerous:**
1. **Hides real issues**: Selector broken? API slow? Vue not mounted? All masked by timeouts.
2. **Makes tests slow**: Waiting 5 seconds per timeout × 100 tests = 500 seconds wasted
3. **Creates flakiness**: If server slower than timeout, test fails unpredictably
4. **Unmaintainable**: Future developers won't know what condition is being waited for
5. **False confidence**: Test might pass on CI but fail in production under load

### Diagnosing Flaky Tests

When a test fails intermittently, ask these questions in order:

#### 1. Is the Selector Wrong?

```typescript
// ❌ Brittle selector
await page.locator('css=.btn-primary').click();

// ✅ Robust semantic selector
await page.getByRole('button', { name: 'Login' }).click();
```

**How to verify**: Use browser DevTools to manually locate the element. If you can't find it, neither can the test.

#### 2. Is the Element Not Yet Visible?

```typescript
// ❌ Masking the visibility issue
await page.waitForTimeout(2000);
await page.getByRole('button', { name: 'Submit' }).click();

// ✅ Wait for actual visibility
await page.getByRole('button', { name: 'Submit' }).waitFor({ state: 'visible' });
await page.getByRole('button', { name: 'Submit' }).click();

// OR auto-wait with Playwright (even better)
await page.getByRole('button', { name: 'Submit' }).click();
```

Playwright automatically waits for elements to be visible before interacting with them.

#### 3. Is Data Still Loading?

```typescript
// ❌ Timeout hoping data arrives
await page.waitForTimeout(3000);
await expect(page.getByText('User data')).toBeVisible();

// ✅ Wait for the API call
await page.waitForResponse(resp =>
  resp.url().includes('/api/user') && resp.status() === 200
);
await expect(page.getByText('User data')).toBeVisible();

// OR wait for specific DOM element
await expect(page.locator('[data-testid="user-data"]')).toBeVisible();
```

#### 4. Is Vue Not Yet Mounted?

```typescript
// ❌ Hoping Vue has mounted
await page.waitForTimeout(2000);
await page.getByRole('button').click();

// ✅ Wait for Vue app to be ready
await page.waitForFunction(() => {
  return !!(window as any).__VUE_DEVTOOLS_GLOBAL_HOOK__?.enabled;
});
await page.getByRole('button').click();
```

#### 5. Is a Transition/Animation Still Running?

```typescript
// ❌ Waiting for animation to finish
await page.waitForTimeout(1000);
await expect(page.getByText('Modal')).toBeVisible();

// ✅ Disable animations in test config
// In playwright.config.ts:
use: {
  // Disable CSS animations
  reducedMotion: 'reduce',
  // Or wait for animation to complete
  navigationTimeout: 30000,
},

// OR wait for animation class to be removed
await page.locator('.modal.animating').waitFor({ state: 'hidden' });
await expect(page.getByText('Modal')).toBeVisible();
```

### The Correct Approach to Flaky Tests

When you encounter a flaky test:

1. **Enable debugging**: Run with `--debug` flag to inspect
2. **Check traces**: Look at trace.zip from failed run to see where it breaks
3. **Identify the condition**: What exactly are you waiting for?
4. **Use appropriate API**: Use the Playwright API for that specific condition
5. **Test locally**: Reproduce the issue in headless mode (`--headed`)
6. **Add logging**: Log what the test is doing for visibility

Example:

```typescript
test('handles loading state correctly', async ({ page }) => {
  await page.goto('/data');

  // Debug: Log when different states appear
  console.log('Initial page state:', await page.content().substring(0, 100));

  // ✅ CORRECT: Wait for loading indicator to appear
  console.log('Waiting for loading indicator...');
  await expect(page.getByText('Loading...')).toBeVisible();

  // ✅ CORRECT: Wait for loading to complete
  console.log('Waiting for loading to finish...');
  await expect(page.getByText('Loading...')).not.toBeVisible();

  // ✅ CORRECT: Verify data is now visible
  console.log('Verifying data loaded...');
  await expect(page.getByText('Data successfully loaded')).toBeVisible();
});
```

## Selector Best Practices

### Locator Priority (Most Stable to Least)

```typescript
// ✅ 1. BEST - User-visible text/roles (most stable)
await page.getByRole('button', { name: 'Login' });
await page.getByLabel('Email Address');
await page.getByPlaceholder('Enter email');
await page.getByText('Welcome');

// ✅ 2. GOOD - Test IDs (use when semantic insufficient)
await page.getByTestId('auth-form');

// ❌ 3. BAD - CSS selectors (fragile to styling changes)
await page.locator('.auth-form');
await page.locator('css=button.primary');

// ❌ 4. WORST - XPath (brittle, slow)
await page.locator('xpath=//*[@class="btn"]');
```

### Adding Test IDs Strategically

Add test IDs only when semantic locators can't work:

```vue
<!-- ✅ Good - semantic without test IDs -->
<button type="submit">Save Profile</button>
<input type="email" aria-label="Email" />

<!-- ✅ Good - complex element needing test ID -->
<div data-testid="product-card-12345" class="product">
  <h3>Product Name</h3>
  <span>$99.99</span>
</div>

<!-- ❌ Bad - test ID when semantic would work -->
<button data-testid="submit-btn">Save</button>
<!-- Should be: getByRole('button', { name: 'Save' }) -->
```

## Network Mocking Patterns

### Mock API Endpoints

```typescript
test('displays mocked data', async ({ page }) => {
  // Setup all API mocks before navigation
  await page.route('**/api/users', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([
        { id: 1, name: 'Alice', email: 'alice@example.com' },
        { id: 2, name: 'Bob', email: 'bob@example.com' }
      ])
    });
  });

  await page.goto('/users');

  // Data from mock should appear
  await expect(page.getByText('Alice')).toBeVisible();
  await expect(page.getByText('bob@example.com')).toBeVisible();
});
```

### Mock Error Responses

```typescript
test('handles API errors gracefully', async ({ page }) => {
  // Mock API to return error
  await page.route('**/api/users', async (route) => {
    await route.abort('failed');
  });

  await page.goto('/users');

  // Error message should be displayed
  await expect(page.getByText('Failed to load users')).toBeVisible();

  // Retry button should be available
  await page.getByRole('button', { name: 'Retry' }).click();

  // Now mock success
  await page.route('**/api/users', async (route) => {
    await route.fulfill({
      status: 200,
      body: JSON.stringify([{ id: 1, name: 'Alice' }])
    });
  });

  // Data appears
  await expect(page.getByText('Alice')).toBeVisible();
});
```

## Debugging Failed Tests

### Using Screenshots

```typescript
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== 'passed') {
    // Screenshot on failure
    await page.screenshot({
      path: `test-results/failed-${testInfo.title}.png`,
      fullPage: true
    });
  }
});
```

### Using Traces

```typescript
test('complex interaction', async ({ page }, testInfo) => {
  await page.context().tracing.start({ screenshots: true, snapshots: true });

  // Test steps...
  await page.goto('/');
  await page.getByRole('button').click();

  // Save trace on failure
  if (testInfo.status !== 'passed') {
    await page.context().tracing.stop({ path: 'trace.zip' });
  }
});

// View with: npx playwright show-trace trace.zip
```

### Using Debug Mode

```bash
# Interactive debugging
npx playwright test --debug

# Headed mode to watch execution
npx playwright test --headed

# Slow down execution for inspection
npx playwright test --headed --slow-mo=1000

# Single worker for easier debugging
npx playwright test --workers=1
```

### Logging During Tests

```typescript
test('debugging with logs', async ({ page }) => {
  page.on('console', msg => {
    console.log('[PAGE LOG]', msg.text());
  });

  page.on('request', req => {
    console.log(`[REQUEST] ${req.method()} ${req.url()}`);
  });

  page.on('response', res => {
    console.log(`[RESPONSE] ${res.status()} ${res.url()}`);
  });

  await page.goto('/');
  // Network activity logged automatically
});
```

## Test Isolation

### Each Test is Independent

```typescript
test.describe('User Management', () => {
  // ✅ CORRECT: Each test creates its own data
  test('creates user', async ({ request }) => {
    const res = await request.post('/api/users', {
      data: { name: 'Alice', email: 'alice@example.com' }
    });
    const user = await res.json();

    expect(user.id).toBeDefined();
  });

  test('lists users', async ({ request }) => {
    // This test should NOT depend on previous test
    // Create test data fresh
    const res = await request.post('/api/users', {
      data: { name: 'Bob', email: 'bob@example.com' }
    });
    const user = await res.json();

    const list = await request.get('/api/users');
    const data = await list.json();

    expect(data).toContainEqual(expect.objectContaining({ id: user.id }));
  });
});

// ❌ WRONG: Test depends on previous test
test('test 1: create user', async ({ request }) => {
  // Test 1 creates 'Alice'
});

test('test 2: list has user', async ({ request }) => {
  // This assumes test 1 ran first - FRAGILE!
  // What if tests run in different order or test 1 fails?
});
```

### Using Fixtures for Setup

```typescript
import { test as base } from '@playwright/test';

type TestFixtures = {
  authenticatedPage: Page;
  testUser: any;
};

export const test = base.extend<TestFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Setup auth
    await page.evaluate(() => {
      localStorage.setItem('auth_token', 'test-token');
    });

    // Use page
    await use(page);

    // Cleanup
    await page.evaluate(() => {
      localStorage.removeItem('auth_token');
    });
  },

  testUser: async ({ request }, use) => {
    // Create test user via API
    const res = await request.post('/api/users', {
      data: { name: 'Test User', email: 'test@example.com' }
    });
    const user = await res.json();

    // Use user
    await use(user);

    // Cleanup
    await request.delete(`/api/users/${user.id}`);
  }
});

// Usage
test('view user profile', async ({ authenticatedPage, testUser }) => {
  await authenticatedPage.goto(`/profile/${testUser.id}`);
  await expect(authenticatedPage.getByText(testUser.name)).toBeVisible();
});
```

## Performance Optimization

### Running Tests in Parallel

```typescript
// playwright.config.ts
export default defineConfig({
  workers: process.env.CI ? 1 : 4, // Parallel on local, serial in CI
  fullyParallel: true, // Run all tests in parallel if possible
});
```

### Sharing Authentication State

```typescript
import { authenticate } from './auth-helper';

export const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    // Reuse auth token instead of logging in each test
    const token = await authenticate();
    await page.evaluate(token => {
      localStorage.setItem('auth_token', token);
    }, token);

    await use(page);
  }
});
```

## Configuration Best Practices

### playwright.config.ts

```typescript
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    // Disable animations for reliable testing
    reducedMotion: 'reduce',
  },

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    // Multi-browser testing
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],

  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results.json' }],
    process.env.CI ? ['github'] : ['list'],
  ],
});
```

## Summary: What to Do Instead of Timeouts

| Issue | Solution |
|-------|----------|
| Element not visible | `await expect(element).toBeVisible()` |
| Waiting for text | `await expect(page.getByText('text')).toBeVisible()` |
| Waiting for API | `await page.waitForResponse(r => r.url().includes('/api'))` |
| Waiting for URL change | `await expect(page).toHaveURL('/path')` |
| Waiting for network idle | `await page.waitForLoadState('networkidle')` |
| Element appears then disappears | `await expect(page.getByText('Loading')).not.toBeVisible()` |
| Custom condition | `await page.waitForFunction(() => condition)` |

**NEVER use `waitForTimeout()` without first asking: "What condition am I waiting for?"**
