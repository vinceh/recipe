# E2E Testing Patterns for Vue Applications

## Page Object Model for Vue

The Page Object Model encapsulates page interactions into reusable classes. This makes tests more maintainable and readable.

### Basic Page Object

```typescript
// pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorAlert: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorAlert = page.getByRole('alert');
  }

  async navigate() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorAlert).toContainText(message);
  }
}
```

### Using Page Objects in Tests

```typescript
import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test.describe('Login', () => {
  let loginPage: LoginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.navigate();
  });

  test('successful login', async ({ page }) => {
    await loginPage.login('user@example.com', 'password123');
    await expect(page).toHaveURL('/dashboard');
  });

  test('invalid credentials', async () => {
    await loginPage.login('bad@email.com', 'wrong');
    await loginPage.expectError('Invalid credentials');
  });
});
```

## Multi-Page Workflow Testing

### Scenario: Product Purchase Flow

```typescript
import { test, expect } from '@playwright/test';
import { HomePage } from '../pages/HomePage';
import { ProductPage } from '../pages/ProductPage';
import { CartPage } from '../pages/CartPage';
import { CheckoutPage } from '../pages/CheckoutPage';

test('complete purchase workflow', async ({ page }) => {
  // Step 1: Browse home page
  const home = new HomePage(page);
  await home.navigate();
  await expect(home.header).toBeVisible();

  // Step 2: View product
  const product = new ProductPage(page);
  await home.clickProduct('Mountain Bike');
  await expect(product.title).toContainText('Mountain Bike');

  // Step 3: Add to cart
  await product.addToCart();
  await expect(product.cartNotification).toContainText('Added to cart');

  // Step 4: Go to cart
  const cart = new CartPage(page);
  await home.clickCartIcon();
  await expect(cart.items).toHaveCount(1);

  // Step 5: Proceed to checkout
  const checkout = new CheckoutPage(page);
  await cart.proceedToCheckout();
  await expect(page).toHaveURL('/checkout');

  // Step 6: Complete purchase
  await checkout.fillShippingInfo('John Doe', '123 Main St', 'New York', 'NY', '10001');
  await checkout.fillBillingInfo('4242424242424242', '12/25', '123');
  await checkout.submitOrder();

  // Step 7: Verify confirmation
  await expect(page).toHaveURL('/order-confirmation');
  await expect(page.getByText('Order Confirmed')).toBeVisible();
});
```

## Testing Authentication Flows

### Login with API Mocking

```typescript
test('login flow with mocked API', async ({ page }) => {
  // Mock the login API
  await page.route('**/api/auth/login', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        token: 'auth-token-123',
        user: { id: 1, name: 'Test User', email: 'user@example.com' }
      })
    });
  });

  // Mock the user profile API
  await page.route('**/api/user/profile', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        id: 1,
        name: 'Test User',
        email: 'user@example.com',
        role: 'admin'
      })
    });
  });

  const login = new LoginPage(page);
  await login.navigate();
  await login.login('user@example.com', 'password');

  // Wait for dashboard to load
  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByText('Welcome, Test User')).toBeVisible();
});
```

### Testing Protected Routes

```typescript
test('redirects unauthenticated users to login', async ({ page }) => {
  // Navigate to protected page without authentication
  await page.goto('/admin');

  // Should redirect to login
  await expect(page).toHaveURL('/login');
});

test('allows authenticated users to access protected routes', async ({ page }) => {
  // Set authentication token (mocking login)
  await page.evaluate(() => {
    localStorage.setItem('auth_token', 'valid-token');
  });

  // Navigate to protected page
  await page.goto('/admin');

  // Should stay on admin page
  await expect(page).toHaveURL('/admin');
});
```

## Testing Async Operations

### Waiting for Network Requests

```typescript
test('loads data on page mount', async ({ page }) => {
  // Wait for API request and response
  const responsePromise = page.waitForResponse(resp =>
    resp.url().includes('/api/products') && resp.status() === 200
  );

  await page.goto('/products');

  const response = await responsePromise;
  const data = await response.json();

  // Assert data is displayed
  await expect(page.getByText(data[0].name)).toBeVisible();
});
```

### Handling Loading States

```typescript
test('shows loading state and then data', async ({ page }) => {
  // Mock delayed API response
  await page.route('**/api/data', async (route) => {
    await new Promise(resolve => setTimeout(resolve, 1000));
    await route.fulfill({
      status: 200,
      body: JSON.stringify({ results: [{ id: 1, title: 'Item 1' }] })
    });
  });

  await page.goto('/data');

  // Initially shows loading
  await expect(page.getByText('Loading...')).toBeVisible();

  // After API responds, shows data (Playwright auto-waits)
  await expect(page.getByText('Item 1')).toBeVisible();

  // Loading state is gone
  await expect(page.getByText('Loading...')).not.toBeVisible();
});
```

## Testing Error Scenarios

```typescript
test('handles API errors gracefully', async ({ page }) => {
  // Mock API error
  await page.route('**/api/products', async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Server error' })
    });
  });

  await page.goto('/products');

  // Error message should be displayed
  await expect(page.getByText('Failed to load products')).toBeVisible();

  // Retry button should be available
  await expect(page.getByRole('button', { name: 'Retry' })).toBeVisible();
});

test('displays validation errors', async ({ page }) => {
  const form = new FormPage(page);
  await form.navigate();

  // Submit empty form
  await form.submitForm();

  // All validation errors should be visible
  await expect(page.getByText('Email is required')).toBeVisible();
  await expect(page.getByText('Password is required')).toBeVisible();
});
```

## Testing Form Interactions

### Complex Form Testing

```typescript
test('validates multi-step form', async ({ page }) => {
  await page.goto('/signup');

  // Step 1: Personal info
  await page.getByLabel('First Name').fill('John');
  await page.getByLabel('Last Name').fill('Doe');
  await page.getByLabel('Email').fill('john@example.com');

  await page.getByRole('button', { name: 'Next' }).click();

  // Wait for step 2 to appear
  await expect(page.getByText('Address Information')).toBeVisible();

  // Step 2: Address
  await page.getByLabel('Street Address').fill('123 Main St');
  await page.getByLabel('City').fill('New York');
  await page.getByLabel('State').selectOption('NY');

  await page.getByRole('button', { name: 'Next' }).click();

  // Wait for step 3 to appear
  await expect(page.getByText('Review & Confirm')).toBeVisible();

  // Step 3: Review
  await expect(page.getByText('John Doe')).toBeVisible();
  await expect(page.getByText('123 Main St')).toBeVisible();

  await page.getByRole('button', { name: 'Submit' }).click();

  // Verify success
  await expect(page).toHaveURL('/signup-success');
});
```

### Form Field Interactions

```typescript
test('handles various form inputs', async ({ page }) => {
  await page.goto('/form');

  // Text input
  await page.getByLabel('Username').fill('testuser');

  // Textarea
  await page.getByLabel('Bio').fill('This is my bio');

  // Select dropdown
  await page.getByLabel('Country').selectOption('US');

  // Checkbox
  await page.getByLabel('I agree to terms').check();

  // Radio button
  await page.getByLabel('Newsletter - Weekly').check();

  // File upload
  await page.getByLabel('Profile Picture').setInputFiles('path/to/image.png');

  // Date input
  await page.getByLabel('Birthday').fill('01/15/1990');

  // Submit
  await page.getByRole('button', { name: 'Save Profile' }).click();

  await expect(page.getByText('Profile updated successfully')).toBeVisible();
});
```

## Best Practices for E2E Tests

### 1. Setup and Teardown

```typescript
test.describe('Product Management', () => {
  let testProductId: string;

  test.beforeAll(async ({ browser }) => {
    // One-time setup for all tests in this suite
  });

  test.beforeEach(async ({ page }) => {
    // Setup before each test
    const response = await page.request.post('/api/products', {
      data: { name: 'Test Product', price: 99.99 }
    });
    const data = await response.json();
    testProductId = data.id;
  });

  test.afterEach(async ({ request }) => {
    // Cleanup after each test
    await request.delete(`/api/products/${testProductId}`);
  });

  test('update product', async ({ page }) => {
    // Test implementation
  });
});
```

### 2. Using Fixtures for Shared Setup

```typescript
import { test as base } from '@playwright/test';

type TestFixtures = {
  authenticatedPage: Page;
};

export const test = base.extend<TestFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Setup: Navigate and login
    await page.goto('/login');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await page.waitForURL('/dashboard');

    // Use fixture
    await use(page);

    // Cleanup: Logout
    await page.getByRole('button', { name: 'Logout' }).click();
  }
});

test('view user profile', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('/profile');
  await expect(authenticatedPage.getByText('My Profile')).toBeVisible();
});
```

### 3. Test Data Management

```typescript
test.describe('Order Management', () => {
  test('manages order lifecycle', async ({ page, request }) => {
    // Create test data via API
    const createOrderResponse = await request.post('/api/orders', {
      data: {
        items: [{ productId: 1, quantity: 2 }],
        shippingAddress: '123 Main St'
      }
    });
    const order = await createOrderResponse.json();

    // Test with created data
    await page.goto(`/orders/${order.id}`);
    await expect(page.getByText(`Order #${order.id}`)).toBeVisible();

    // Update order via UI
    await page.getByRole('button', { name: 'Cancel Order' }).click();
    await page.getByRole('button', { name: 'Confirm' }).click();

    // Verify via API
    const updatedOrder = await request.get(`/api/orders/${order.id}`);
    const data = await updatedOrder.json();
    expect(data.status).toBe('cancelled');
  });
});
```

## Debugging E2E Tests

### Using Trace Files

```typescript
test('debug with trace', async ({ page }) => {
  // Trace already enabled via config, but can control per-test:
  await page.context().tracing.start({ screenshots: true, snapshots: true });

  // Test implementation
  await page.goto('/');
  await page.getByRole('button').click();

  // Stop and save trace
  await page.context().tracing.stop({ path: 'trace.zip' });
});

// View with: npx playwright show-trace trace.zip
```

### Debugging Output

```typescript
test('debug output', async ({ page }) => {
  // Log page state
  const content = await page.content();
  console.log('Page HTML:', content.substring(0, 500));

  // Pause execution for inspection
  await page.pause();

  // Take screenshot
  await page.screenshot({ path: 'debug.png', fullPage: true });
});
```

### Running in Debug Mode

```bash
# Interactive debugging with Inspector
npx playwright test --debug

# Headed mode to see browser
npx playwright test --headed

# Slow down execution
npx playwright test --headed --workers=1 --slow-mo=1000
```
