import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Simple Test', () => {
  test('should create a new recipe with basic fields', async ({ page }) => {
    // Step 1: Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');

    // Wait for successful login - it redirects to /admin
    await page.waitForURL('**/admin', { timeout: 10000 });

    // Step 2: Navigate to new recipe page
    await page.goto('/admin/recipes/new');

    // Step 3: Fill in the recipe form with minimal required fields
    // Recipe name
    await page.fill('input#name', 'Test Recipe from Playwright');

    // The default ingredient group already exists, just add an ingredient
    await page.fill('input[placeholder*="All-purpose flour"]', 'Test Ingredient');
    await page.fill('input[placeholder*="e.g., 2"]', '1');
    await page.fill('input[placeholder*="e.g., cups"]', 'cup');

    // Add a step (there should be a default step already)
    await page.fill('textarea[placeholder*="Describe the step"]', 'This is a test step');

    // Step 4: Save the recipe
    await page.click('button:has-text("Save")');

    // Step 5: Verify we're redirected to the detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 10000 });

    // Step 6: Verify the recipe data is displayed correctly
    // Check that the recipe name is displayed
    const heading = page.locator('h2, h1').filter({ hasText: 'Test Recipe from Playwright' });
    await expect(heading).toBeVisible({ timeout: 10000 });

    // Check that ingredients are displayed (not as JSON)
    await expect(page.locator('text=Test Ingredient')).toBeVisible();

    // Check that steps are displayed correctly (not as JSON)
    await expect(page.locator('text=This is a test step')).toBeVisible();

    console.log('✅ Recipe creation test passed!');
  });
});