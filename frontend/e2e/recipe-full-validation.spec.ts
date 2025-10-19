import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Full Validation', () => {
  // Helper function to login
  async function login(page: any) {
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
  }

  test('validates all recipe form features work correctly', async ({ page }) => {
    await login(page);

    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // 1. Test Basic Information
    await page.fill('input#name', 'Complete Test Recipe');
    await page.fill('input#source_url', 'https://example.com');

    // 2. Test Servings
    await page.fill('input#servings_original', '8');
    await page.fill('input#servings_min', '2');
    await page.fill('input#servings_max', '16');

    // 3. Test Timing
    await page.fill('input#prep_time', '20');
    await page.fill('input#cook_time', '45');
    await page.fill('input#total_time', '65');

    // 4. Test Ingredient Groups
    // First group - Main Ingredients
    await page.fill('input[placeholder*="All-purpose flour"]', 'Chicken Breast');
    await page.fill('input[placeholder*="e.g., 2"]', '4');
    await page.fill('input[placeholder*="e.g., cups"]', 'pieces');

    // Add another ingredient to first group
    await page.click('button:has-text("Add Ingredient")');
    await page.waitForTimeout(500); // Wait for DOM to update

    const ingredientInputs = await page.locator('.recipe-form__ingredient').all();
    if (ingredientInputs.length > 1) {
      const secondIngredient = ingredientInputs[1];
      await secondIngredient.locator('input').nth(0).fill('Olive Oil');
      await secondIngredient.locator('input').nth(1).fill('2');
      await secondIngredient.locator('input').nth(2).fill('tablespoons');
      await secondIngredient.locator('input').nth(3).fill('extra virgin');
      await secondIngredient.locator('input[type="checkbox"]').check();
    }

    // 5. Test Steps
    await page.fill('textarea[placeholder*="Describe the step"]', 'Season the chicken with salt and pepper');

    // Add another step
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(500);
    const stepTextareas = await page.locator('textarea.recipe-form__step-instruction').all();
    if (stepTextareas.length > 1) {
      await stepTextareas[1].fill('Heat oil in a pan and cook chicken until golden brown');
    }

    // 6. Test Equipment
    await page.fill('input#equipment', 'Large skillet');
    await page.keyboard.press('Enter');

    // 7. Test Admin Notes
    await page.fill('textarea#admin_notes', 'Test recipe created by Playwright automated test');

    // Save the recipe
    await page.click('button:has-text("Save")');

    // Verify successful save and redirect
    await page.waitForURL('**/admin/recipes/*', { timeout: 10000 });

    // Verify all data is displayed correctly
    await expect(page.locator('text=Complete Test Recipe')).toBeVisible();
    await expect(page.locator('text=8')).toBeVisible(); // Servings
    await expect(page.locator('text=65 min')).toBeVisible(); // Total time
    await expect(page.locator('text=Chicken Breast')).toBeVisible();
    await expect(page.locator('text=Olive Oil')).toBeVisible();
    await expect(page.locator('text=Season the chicken')).toBeVisible();
    await expect(page.locator('text=Heat oil in a pan')).toBeVisible();

    console.log('✅ Full recipe validation test passed!');
  });

  test('validates required fields and form validation', async ({ page }) => {
    await login(page);
    await page.goto('/admin/recipes/new');

    // Check that save button is disabled initially
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeDisabled();

    // Add only name - should still be disabled
    await page.fill('input#name', 'Test Recipe');
    await expect(saveButton).toBeDisabled();

    // Add ingredient - should still be disabled (needs steps)
    await page.fill('input[placeholder*="All-purpose flour"]', 'Test Ingredient');
    await expect(saveButton).toBeDisabled();

    // Add step - should now be enabled
    await page.fill('textarea[placeholder*="Describe the step"]', 'Test step');
    await expect(saveButton).toBeEnabled();

    console.log('✅ Form validation test passed!');
  });

  test('verifies recipe data persists correctly', async ({ page }) => {
    await login(page);

    // Create a unique recipe name with timestamp
    const recipeName = `Test Recipe ${Date.now()}`;

    // Create recipe
    await page.goto('/admin/recipes/new');
    await page.fill('input#name', recipeName);
    await page.fill('input[placeholder*="All-purpose flour"]', 'Unique Ingredient');
    await page.fill('input[placeholder*="e.g., 2"]', '999');
    await page.fill('input[placeholder*="e.g., cups"]', 'grams');
    await page.fill('textarea[placeholder*="Describe the step"]', 'Unique step instructions');

    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 10000 });

    // Get the recipe ID from URL
    const url = page.url();
    const recipeId = url.split('/').pop();

    // Navigate away and come back to verify data persists
    await page.goto('/admin');
    await page.goto(`/admin/recipes/${recipeId}`);

    // Verify data is still there
    await expect(page.locator(`text=${recipeName}`)).toBeVisible();
    await expect(page.locator('text=Unique Ingredient')).toBeVisible();
    await expect(page.locator('text=999 grams')).toBeVisible();
    await expect(page.locator('text=Unique step instructions')).toBeVisible();

    console.log('✅ Data persistence test passed!');
  });
});