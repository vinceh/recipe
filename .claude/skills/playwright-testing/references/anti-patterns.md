# Playwright Testing Anti-Patterns

## Overview

This guide identifies common mistakes and anti-patterns in Playwright testing, providing examples of what to avoid and how to write better tests.

## Locator Anti-Patterns

### ❌ Using Implementation-Specific Selectors

**Bad:**
```typescript
// Brittle CSS selectors
await page.locator('.btn-3847.primary-action.mt-4').click();
await page.locator('#submit_btn_2947').click();
await page.locator('div.container > div.row > div.col-md-6').click();

// Generated class names
await page.locator('.css-1a2b3c4').click();
await page.locator('[class*="styled__Button"]').click();
```

**Good:**
```typescript
// Semantic locators
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByLabel('Email').fill('user@example.com');
await page.getByText('Welcome').isVisible();
```

### ❌ Using Fragile XPath

**Bad:**
```typescript
// Position-dependent XPath
await page.locator('//div[3]/span[2]/button[1]').click();

// Deep nesting
await page.locator('//html/body/div/div/div/form/button').click();
```

**Good:**
```typescript
// Role-based locators
await page.getByRole('button', { name: 'Save' }).click();

// Data attributes when needed
await page.getByTestId('save-button').click();
```

### ❌ Not Handling Multiple Matches

**Bad:**
```typescript
// Ambiguous locator that might match multiple elements
await page.getByRole('button').click(); // Error if multiple buttons exist
```

**Good:**
```typescript
// Be specific
await page.getByRole('button', { name: 'Submit' }).click();

// Or explicitly handle multiple matches
await page.getByRole('button').first().click();
await page.getByRole('button').nth(2).click();
```

## Waiting Anti-Patterns

### ❌ Hard-Coded Waits

**Bad:**
```typescript
// Never use hard-coded waits
await page.waitForTimeout(5000); // Wastes time or still flaky
await new Promise(r => setTimeout(r, 3000)); // Same problem
```

**Good:**
```typescript
// Wait for specific conditions
await page.getByRole('alert').waitFor({ state: 'visible' });
await page.waitForLoadState('networkidle');
await page.waitForResponse(resp => resp.url().includes('/api/data'));
```

### ❌ Not Waiting for Dynamic Content

**Bad:**
```typescript
// Clicking immediately without waiting
await page.goto('/dashboard');
await page.getByText('Data').click(); // May fail if content loads async
```

**Good:**
```typescript
// Playwright auto-waits, but be explicit when needed
await page.goto('/dashboard');
await page.getByText('Data').waitFor();
await page.getByText('Data').click();

// Or wait for network
await page.goto('/dashboard');
await page.waitForLoadState('networkidle');
await page.getByText('Data').click();
```

## Test Structure Anti-Patterns

### ❌ Dependent Tests

**Bad:**
```typescript
let userId: string;

test('create user', async ({ page }) => {
  // Creates user
  userId = await createUser(page);
});

test('delete user', async ({ page }) => {
  // Depends on previous test
  await deleteUser(page, userId); // Fails if first test fails
});
```

**Good:**
```typescript
test('user lifecycle', async ({ page }) => {
  // Single test for related operations
  const userId = await createUser(page);
  await deleteUser(page, userId);
});

// Or use beforeEach for setup
test.describe('user tests', () => {
  let userId: string;

  test.beforeEach(async ({ page }) => {
    userId = await createUser(page);
  });

  test.afterEach(async ({ page }) => {
    await deleteUser(page, userId);
  });

  test('user can update profile', async ({ page }) => {
    // Test logic
  });
});
```

### ❌ Testing Implementation Details

**Bad:**
```typescript
test('internal state changes', async ({ page }) => {
  await page.goto('/');

  // Testing internal implementation
  const reactFiberNode = await page.evaluate(() => {
    return window.React.__SECRET_INTERNALS;
  });
  expect(reactFiberNode.state).toBe('loaded');
});
```

**Good:**
```typescript
test('page loads successfully', async ({ page }) => {
  await page.goto('/');

  // Test user-visible behavior
  await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
  await expect(page.getByRole('navigation')).toBeVisible();
});
```

### ❌ Overly Complex Tests

**Bad:**
```typescript
test('entire user journey', async ({ page }) => {
  // 200 lines of test code
  await register(page);
  await login(page);
  await browseProducts(page);
  await addToCart(page);
  await checkout(page);
  await verifyOrder(page);
  await logout(page);
  // Hard to debug when it fails
});
```

**Good:**
```typescript
test.describe('user journey', () => {
  test('user can register', async ({ page }) => {
    await register(page);
    await expect(page).toHaveURL('/welcome');
  });

  test('user can add product to cart', async ({ page }) => {
    await login(page, testUser);
    await addToCart(page, 'Product A');
    await expect(page.getByText('1 item in cart')).toBeVisible();
  });

  test('user can checkout', async ({ page }) => {
    await login(page, testUser);
    await addToCart(page, 'Product A');
    await checkout(page);
    await expect(page).toHaveURL('/order-confirmation');
  });
});
```

## Assertion Anti-Patterns

### ❌ Not Using Playwright's Auto-Retry Assertions

**Bad:**
```typescript
// Manual assertion without retry
const text = await page.getByTestId('status').textContent();
expect(text).toBe('Success'); // Fails immediately if not ready
```

**Good:**
```typescript
// Playwright's auto-retry assertions
await expect(page.getByTestId('status')).toHaveText('Success');
await expect(page.getByRole('button')).toBeEnabled();
```

### ❌ Multiple Assertions Without Context

**Bad:**
```typescript
test('form validation', async ({ page }) => {
  await page.getByRole('button', { name: 'Submit' }).click();

  // No context for failures
  expect(await page.locator('.error').count()).toBe(3);
  expect(await page.locator('.error').first().textContent()).toContain('required');
  expect(await page.locator('.error').nth(1).textContent()).toContain('invalid');
});
```

**Good:**
```typescript
test('form validation', async ({ page }) => {
  await page.getByRole('button', { name: 'Submit' }).click();

  // Clear assertions with context
  await expect(page.getByText('Email is required')).toBeVisible();
  await expect(page.getByText('Password is too short')).toBeVisible();
  await expect(page.getByText('Terms must be accepted')).toBeVisible();
});
```

## Page Object Anti-Patterns

### ❌ Exposing Playwright Internals

**Bad:**
```typescript
class LoginPage {
  constructor(public page: Page) {} // Exposing page object

  getEmailLocator(): Locator {
    return this.page.getByLabel('Email'); // Exposing locator
  }
}

// Test uses internal details
const loginPage = new LoginPage(page);
await loginPage.page.goto('/login');
await loginPage.getEmailLocator().fill('test@example.com');
```

**Good:**
```typescript
class LoginPage {
  constructor(private page: Page) {} // Private

  async goto() {
    await this.page.goto('/login');
  }

  async fillEmail(email: string) {
    await this.page.getByLabel('Email').fill(email);
  }
}

// Test uses abstracted methods
const loginPage = new LoginPage(page);
await loginPage.goto();
await loginPage.fillEmail('test@example.com');
```

### ❌ Page Objects with Business Logic

**Bad:**
```typescript
class CheckoutPage {
  async completePurchase(user: User, product: Product) {
    // Business logic in page object
    const discount = user.isPremium ? 0.2 : 0;
    const finalPrice = product.price * (1 - discount);
    const tax = finalPrice * 0.08;
    const total = finalPrice + tax;

    await this.fillPaymentDetails();
    await this.verifyTotal(total);
    await this.submit();
  }
}
```

**Good:**
```typescript
class CheckoutPage {
  // Page object only handles UI interactions
  async fillPaymentDetails(details: PaymentDetails) {
    await this.page.getByLabel('Card Number').fill(details.cardNumber);
    await this.page.getByLabel('CVV').fill(details.cvv);
  }

  async getDisplayedTotal(): Promise<string> {
    return await this.page.getByTestId('total').textContent();
  }

  async submit() {
    await this.page.getByRole('button', { name: 'Place Order' }).click();
  }
}

// Business logic in test or helper
test('premium user discount', async ({ page }) => {
  const expectedTotal = calculateTotal(product, user);
  await checkoutPage.fillPaymentDetails(paymentDetails);

  const displayedTotal = await checkoutPage.getDisplayedTotal();
  expect(displayedTotal).toBe(expectedTotal);

  await checkoutPage.submit();
});
```

## Data Management Anti-Patterns

### ❌ Hard-Coded Test Data

**Bad:**
```typescript
test('login', async ({ page }) => {
  // Hard-coded credentials
  await page.getByLabel('Email').fill('john.doe@example.com');
  await page.getByLabel('Password').fill('Password123!');
});
```

**Good:**
```typescript
// Use environment variables or test data files
const testUser = {
  email: process.env.TEST_USER_EMAIL || 'test@example.com',
  password: process.env.TEST_USER_PASSWORD || 'TestPass123!'
};

test('login', async ({ page }) => {
  await page.getByLabel('Email').fill(testUser.email);
  await page.getByLabel('Password').fill(testUser.password);
});
```

### ❌ Shared Mutable Test Data

**Bad:**
```typescript
// Shared mutable state
let sharedUser = { name: 'John', email: 'john@example.com' };

test('test 1', async ({ page }) => {
  sharedUser.name = 'Jane'; // Modifies shared state
  // ...
});

test('test 2', async ({ page }) => {
  // Depends on modified state
  expect(sharedUser.name).toBe('Jane'); // Flaky!
});
```

**Good:**
```typescript
// Create fresh data for each test
test('test 1', async ({ page }) => {
  const user = createTestUser();
  user.name = 'Jane';
  // ...
});

test('test 2', async ({ page }) => {
  const user = createTestUser(); // Fresh instance
  expect(user.name).toBe('John');
});
```

## Performance Anti-Patterns

### ❌ Unnecessary Navigation

**Bad:**
```typescript
test('check multiple pages', async ({ page }) => {
  await page.goto('/page1');
  expect(await page.title()).toBe('Page 1');

  await page.goto('/page2');
  expect(await page.title()).toBe('Page 2');

  await page.goto('/page3');
  expect(await page.title()).toBe('Page 3');
});
```

**Good:**
```typescript
// Parallel tests for independent checks
test.describe.parallel('page titles', () => {
  test('page 1 title', async ({ page }) => {
    await page.goto('/page1');
    await expect(page).toHaveTitle('Page 1');
  });

  test('page 2 title', async ({ page }) => {
    await page.goto('/page2');
    await expect(page).toHaveTitle('Page 2');
  });
});
```

### ❌ Not Using Test Hooks Properly

**Bad:**
```typescript
test('test 1', async ({ page }) => {
  await login(page); // Duplicate setup
  // test logic
  await logout(page); // Duplicate teardown
});

test('test 2', async ({ page }) => {
  await login(page); // Duplicate setup
  // test logic
  await logout(page); // Duplicate teardown
});
```

**Good:**
```typescript
test.describe('authenticated tests', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test.afterEach(async ({ page }) => {
    await logout(page);
  });

  test('test 1', async ({ page }) => {
    // test logic
  });

  test('test 2', async ({ page }) => {
    // test logic
  });
});
```

## Error Handling Anti-Patterns

### ❌ Swallowing Errors

**Bad:**
```typescript
test('submit form', async ({ page }) => {
  try {
    await page.getByRole('button', { name: 'Submit' }).click();
    // Swallowing all errors
  } catch (error) {
    // Silent failure
  }
});
```

**Good:**
```typescript
test('submit form', async ({ page }) => {
  try {
    await page.getByRole('button', { name: 'Submit' }).click();
  } catch (error) {
    // Add context and re-throw
    await page.screenshot({ path: 'error-submit.png' });
    throw new Error(`Submit failed: ${error.message}`);
  }
});
```

### ❌ Not Cleaning Up on Failure

**Bad:**
```typescript
test('create and delete resource', async ({ page }) => {
  const resourceId = await createResource(page);
  await validateResource(page, resourceId); // If this fails...
  await deleteResource(page, resourceId); // This never runs
});
```

**Good:**
```typescript
test('create and delete resource', async ({ page }) => {
  let resourceId: string | null = null;

  try {
    resourceId = await createResource(page);
    await validateResource(page, resourceId);
  } finally {
    if (resourceId) {
      await deleteResource(page, resourceId);
    }
  }
});
```

## Best Practices Summary

1. **Use semantic locators**: Avoid CSS/XPath when possible
2. **Let Playwright wait**: Don't use hard-coded timeouts
3. **Keep tests independent**: Each test should run in isolation
4. **Test user behavior**: Not implementation details
5. **Use auto-retry assertions**: Leverage Playwright's built-in waiting
6. **Abstract page interactions**: Use Page Object Model properly
7. **Handle errors gracefully**: Add context, cleanup resources
8. **Parallelize when possible**: Run independent tests concurrently
9. **Keep tests simple**: One concept per test
10. **Use proper test hooks**: Avoid duplication with beforeEach/afterEach