# Locator Strategies for Playwright

## Overview

Effective locator strategies are crucial for creating stable, maintainable tests. Playwright provides multiple ways to locate elements, with built-in auto-waiting and retry mechanisms. This guide covers best practices for writing resilient locators.

## Locator Priority Guidelines

### Recommended Priority Order

1. **User-facing attributes** (Most stable)
   - `getByRole()`
   - `getByLabel()`
   - `getByPlaceholder()`
   - `getByText()`
   - `getByAltText()`
   - `getByTitle()`

2. **Test IDs** (When semantic locators aren't available)
   - `getByTestId()`

3. **CSS/XPath** (Last resort)
   - `locator()`

## Semantic Locators

### getByRole() - Preferred Method

```typescript
// Buttons
await page.getByRole('button', { name: 'Submit' }).click();
await page.getByRole('button', { name: /submit/i }).click(); // Regex

// Links
await page.getByRole('link', { name: 'Home' }).click();

// Headings
await page.getByRole('heading', { name: 'Welcome', level: 1 });

// Forms
await page.getByRole('textbox', { name: 'Email' }).fill('user@example.com');
await page.getByRole('checkbox', { name: 'Remember me' }).check();
await page.getByRole('combobox', { name: 'Country' }).selectOption('USA');

// Navigation
await page.getByRole('navigation').getByRole('link', { name: 'About' });

// Tables
await page.getByRole('row', { name: 'John Doe' })
  .getByRole('cell', { name: 'Edit' })
  .click();

// Lists
await page.getByRole('list').getByRole('listitem').first();

// Dialogs
await page.getByRole('dialog', { name: 'Confirm' });
await page.getByRole('alert');
```

### getByLabel() - Form Elements

```typescript
// Text inputs
await page.getByLabel('Email').fill('user@example.com');
await page.getByLabel('Password').fill('secret');

// With exact match
await page.getByLabel('Email', { exact: true }).fill('user@example.com');

// Nested labels
await page.getByLabel('Billing Address').fill('123 Main St');

// Associated by for attribute
await page.getByLabel('Terms and Conditions').check();
```

### getByPlaceholder()

```typescript
// Search boxes
await page.getByPlaceholder('Search...').fill('playwright');

// Form fields
await page.getByPlaceholder('Enter your email').fill('user@example.com');

// Partial match
await page.getByPlaceholder(/email/i).fill('user@example.com');
```

### getByText()

```typescript
// Exact text
await page.getByText('Click me').click();

// Partial text
await page.getByText('Click', { exact: false }).click();

// Regular expression
await page.getByText(/welcome.*/i).isVisible();

// Combining with other locators
await page.getByRole('article')
  .getByText('Read more')
  .click();
```

## Advanced Locator Techniques

### Chaining and Filtering

```typescript
// Chain locators
await page
  .getByRole('list', { name: 'Products' })
  .getByRole('listitem')
  .filter({ hasText: 'Laptop' })
  .getByRole('button', { name: 'Add to cart' })
  .click();

// Filter by text
const product = page.getByRole('article').filter({ hasText: 'Premium' });

// Filter by child element
const row = page.getByRole('row').filter({
  has: page.getByRole('cell', { name: 'Active' })
});

// Filter by not having text
const available = page.getByRole('listitem').filter({
  hasNotText: 'Out of stock'
});
```

### Nth-Selectors and Counting

```typescript
// First, last, nth
await page.getByRole('listitem').first().click();
await page.getByRole('listitem').last().click();
await page.getByRole('listitem').nth(2).click(); // 0-based index

// Count elements
const count = await page.getByRole('listitem').count();
expect(count).toBe(5);

// Iterate through elements
const items = page.getByRole('listitem');
for (let i = 0; i < await items.count(); i++) {
  console.log(await items.nth(i).textContent());
}
```

### Parent and Child Navigation

```typescript
// Locate parent
const cell = page.getByText('John Doe');
const row = cell.locator('..'); // Parent element

// XPath parent navigation
const parent = page.getByText('Child').locator('xpath=..');

// Locate within parent
const form = page.getByRole('form', { name: 'Login' });
const email = form.getByLabel('Email');
const password = form.getByLabel('Password');

// Multiple levels
const card = page.locator('.card').filter({ hasText: 'Premium' });
const price = card.locator('.price');
const button = card.getByRole('button');
```

## Dynamic Content Handling

### Waiting Strategies

```typescript
// Auto-waiting (built-in)
await page.getByRole('button', { name: 'Submit' }).click();
// Playwright automatically waits for the button to be visible, enabled, and stable

// Explicit wait for element
await page.getByRole('alert').waitFor({ state: 'visible' });
await page.getByText('Loading...').waitFor({ state: 'hidden' });

// Wait with timeout
await page.getByRole('dialog').waitFor({
  state: 'visible',
  timeout: 5000
});

// Wait for element to be enabled
const button = page.getByRole('button', { name: 'Continue' });
await button.waitFor({ state: 'attached' });
await expect(button).toBeEnabled();
```

### Handling Elements That Appear/Disappear

```typescript
// Handle toasts/notifications
test('dismiss notification', async ({ page }) => {
  // Trigger action that shows notification
  await page.getByRole('button', { name: 'Save' }).click();

  // Wait for and dismiss notification
  const toast = page.getByRole('alert');
  await expect(toast).toBeVisible();
  await toast.getByRole('button', { name: 'Close' }).click();
  await expect(toast).not.toBeVisible();
});

// Handle loading states
test('wait for content to load', async ({ page }) => {
  await page.getByRole('button', { name: 'Load Data' }).click();

  // Wait for loader to appear and disappear
  const loader = page.getByTestId('loader');
  await expect(loader).toBeVisible();
  await expect(loader).not.toBeVisible({ timeout: 10000 });

  // Now interact with loaded content
  await expect(page.getByRole('table')).toBeVisible();
});
```

## Shadow DOM and iFrames

### Shadow DOM

```typescript
// Penetrate shadow DOM
await page.locator('custom-element')
  .locator('internal-button')
  .click();

// With explicit shadow root
const host = page.locator('#shadow-host');
const shadowButton = host.locator('button');
await shadowButton.click();
```

### iFrames

```typescript
// Locate elements in iframe
const frame = page.frameLocator('#my-iframe');
await frame.getByRole('button', { name: 'Submit' }).click();

// Nested iframes
const frame1 = page.frameLocator('#outer-frame');
const frame2 = frame1.frameLocator('#inner-frame');
await frame2.getByText('Content').click();

// Wait for iframe to load
await page.frameLocator('#dynamic-iframe')
  .getByRole('heading')
  .waitFor();
```

## Custom Locator Strategies

### Creating Reusable Locators

```typescript
class CustomLocators {
  static dataGrid(page: Page, gridName: string) {
    return page.getByRole('grid', { name: gridName });
  }

  static gridCell(page: Page, row: number, column: string) {
    return page
      .getByRole('row')
      .nth(row)
      .getByRole('gridcell', { name: column });
  }

  static formField(page: Page, fieldName: string) {
    return page.getByRole('group', { name: fieldName })
      .or(page.getByLabel(fieldName));
  }
}

// Usage
const grid = CustomLocators.dataGrid(page, 'Users');
const cell = CustomLocators.gridCell(page, 2, 'Email');
```

### Locator Aliases

```typescript
// Create page-specific locator aliases
class LoginPageLocators {
  constructor(private page: Page) {}

  get emailInput() {
    return this.page.getByLabel('Email Address')
      .or(this.page.getByPlaceholder('Enter your email'));
  }

  get passwordInput() {
    return this.page.getByLabel('Password')
      .or(this.page.getByPlaceholder('Enter your password'));
  }

  get submitButton() {
    return this.page.getByRole('button', { name: /sign in|log in/i });
  }
}
```

## Resilient Locator Patterns

### Multiple Fallback Strategies

```typescript
// Use .or() for fallback locators
const searchBox = page
  .getByRole('searchbox')
  .or(page.getByPlaceholder('Search'))
  .or(page.getByLabel('Search'))
  .or(page.locator('[type="search"]'));

await searchBox.fill('query');
```

### Flexible Text Matching

```typescript
// Case-insensitive matching
await page.getByRole('button', { name: /submit/i }).click();

// Partial matching
await page.getByText('Welcome', { exact: false }).isVisible();

// Whitespace normalization
await page.getByText('Hello    World').click(); // Matches "Hello World"

// Using regular expressions for flexibility
await page.getByText(/total:?\s*\$[\d,]+\.?\d*/i).isVisible();
```

### Data Attributes Strategy

```typescript
// Use data attributes when needed
await page.getByTestId('submit-form').click();

// Custom data attributes
await page.locator('[data-component="user-card"]').first();

// Combining with other attributes
await page.locator('[data-state="active"][role="tab"]').click();
```

## Performance Optimization

### Efficient Locator Usage

```typescript
// Store locators for reuse
const submitButton = page.getByRole('button', { name: 'Submit' });
await submitButton.isEnabled();
await submitButton.click();

// Avoid repeatedly locating elements in loops
const items = page.getByRole('listitem');
const count = await items.count();
for (let i = 0; i < count; i++) {
  const item = items.nth(i);
  // Work with item
}

// Use evaluateAll for bulk operations
const texts = await page.getByRole('listitem').evaluateAll(
  elements => elements.map(el => el.textContent)
);
```

### Strict Mode

```typescript
// Enable strict mode to catch ambiguous locators
// playwright.config.ts
export default defineConfig({
  use: {
    // Fail if multiple elements match
    strict: true
  }
});

// Handle multiple matches explicitly
const buttons = page.getByRole('button', { name: 'Delete' });
await buttons.first().click(); // Explicitly choose first
```

## Debugging Locators

### Locator Debugging Tools

```typescript
// Highlight element in browser
await page.getByRole('button', { name: 'Submit' }).highlight();

// Count matching elements
const count = await page.getByRole('button').count();
console.log(`Found ${count} buttons`);

// Get all matching texts
const texts = await page.getByRole('link').allTextContents();
console.log('Links:', texts);

// Check if locator matches anything
const exists = await page.getByRole('button', { name: 'Submit' }).count() > 0;
```

### Playwright Inspector

```bash
# Launch codegen to experiment with locators
npx playwright codegen https://example.com

# Use inspector in tests
await page.pause(); // Opens inspector
```

## Best Practices Summary

1. **Prefer semantic locators**: Use role, label, text over CSS/XPath
2. **Be specific but flexible**: Use exact matching when needed, regex for flexibility
3. **Chain locators logically**: Narrow scope progressively
4. **Handle dynamic content**: Use proper waiting strategies
5. **Create abstractions**: Build reusable locator utilities
6. **Test locator stability**: Verify locators work across different states
7. **Use data-testid sparingly**: Only when semantic options aren't available
8. **Avoid brittle selectors**: Don't rely on classes, IDs that may change
9. **Document complex locators**: Add comments explaining the strategy
10. **Review and refactor**: Update locators when UI changes