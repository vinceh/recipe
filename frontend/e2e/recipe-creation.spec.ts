import { test, expect } from '@playwright/test';

test.describe('Recipe Creation Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');

    // Wait for the login form to be visible
    await page.waitForSelector('input[type="email"]', { timeout: 10000 });

    // Fill in login credentials
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');

    // Click login button
    await page.click('button[type="submit"]');

    // Wait for navigation to complete (should redirect after login)
    await page.waitForURL('**/admin/**', { timeout: 10000 });
  });

  test('should create a new recipe successfully', async ({ page }) => {
    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');

    // Wait for the form to load
    await page.waitForSelector('form', { timeout: 10000 });

    // Fill in basic information
    await page.fill('input#name', 'Test Recipe from Playwright');
    await page.fill('input#source_url', 'https://example.com/recipe');

    // Select language
    await page.click('div[aria-label="Language"]');
    await page.click('li[aria-label="English"]');

    // Set servings
    await page.fill('input#servings_original', '6');
    await page.fill('input#servings_min', '2');
    await page.fill('input#servings_max', '12');

    // Set timing
    await page.fill('input#prep_time', '15');
    await page.fill('input#cook_time', '30');
    await page.fill('input#total_time', '45');

    // Select dietary tags
    await page.click('div[aria-label="Dietary Tags"]');
    await page.click('li:has-text("Vegetarian")');
    await page.keyboard.press('Escape'); // Close dropdown

    // Select cuisines
    await page.click('div[aria-label="Cuisines"]');
    await page.click('li:has-text("Italian")');
    await page.keyboard.press('Escape'); // Close dropdown

    // Select dish types
    await page.click('div[aria-label="Dish Types"]');
    await page.click('li:has-text("Main Course")');
    await page.keyboard.press('Escape'); // Close dropdown

    // Add ingredient to the default group
    const firstIngredientName = await page.locator('input[placeholder*="All-purpose flour"]').first();
    await firstIngredientName.fill('Pasta');

    const firstIngredientAmount = await page.locator('input[placeholder*="2"]').first();
    await firstIngredientAmount.fill('500');

    const firstIngredientUnit = await page.locator('input[placeholder*="cups"]').first();
    await firstIngredientUnit.fill('grams');

    // Add another ingredient
    await page.click('button:has-text("Add Ingredient")');
    const secondIngredientRow = await page.locator('.recipe-form__ingredient').nth(1);
    await secondIngredientRow.locator('input[placeholder*="All-purpose flour"]').fill('Tomato Sauce');
    await secondIngredientRow.locator('input[placeholder*="2"]').fill('2');
    await secondIngredientRow.locator('input[placeholder*="cups"]').fill('cups');

    // Add a step
    const firstStep = await page.locator('textarea.recipe-form__step-instruction').first();
    await firstStep.fill('Boil water and cook pasta according to package directions');

    // Add another step
    await page.click('button:has-text("Add Step")');
    const secondStep = await page.locator('textarea.recipe-form__step-instruction').nth(1);
    await secondStep.fill('Heat tomato sauce and combine with cooked pasta');

    // Add equipment
    await page.fill('input#equipment', 'Large pot');
    await page.click('button:has-text("Add"):near(input#equipment)');

    // Add admin notes
    await page.fill('textarea#admin_notes', 'This is a test recipe created by Playwright');

    // Save the recipe
    await page.click('button:has-text("Save")');

    // Wait for navigation to recipe detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 10000 });

    // Verify we're on the detail page and recipe was created
    await expect(page.locator('h1')).toContainText('Test Recipe from Playwright');

    // Verify ingredients are displayed
    await expect(page.locator('.ingredient-list')).toContainText('Pasta');
    await expect(page.locator('.ingredient-list')).toContainText('Tomato Sauce');

    // Verify steps are displayed correctly (not as JSON)
    await expect(page.locator('.steps-list')).toContainText('Boil water and cook pasta');
    await expect(page.locator('.steps-list')).toContainText('Heat tomato sauce and combine');

    // Verify other details
    await expect(page.locator('text=6')).toBeVisible(); // Servings
    await expect(page.locator('text=45 min')).toBeVisible(); // Total time
    await expect(page.locator('text=vegetarian')).toBeVisible(); // Dietary tag
    await expect(page.locator('text=italian')).toBeVisible(); // Cuisine
  });

  test('should validate required fields', async ({ page }) => {
    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');

    // Wait for the form to load
    await page.waitForSelector('form', { timeout: 10000 });

    // Try to save without filling required fields
    const saveButton = await page.locator('button:has-text("Save")');

    // The save button should be disabled when form is invalid
    await expect(saveButton).toBeDisabled();

    // Fill in only the name
    await page.fill('input#name', 'Incomplete Recipe');

    // Should still be disabled (needs ingredients and steps)
    await expect(saveButton).toBeDisabled();

    // Add an ingredient
    const firstIngredientName = await page.locator('input[placeholder*="All-purpose flour"]').first();
    await firstIngredientName.fill('Test Ingredient');

    // Should still be disabled (needs steps)
    await expect(saveButton).toBeDisabled();

    // Add a step
    const firstStep = await page.locator('textarea.recipe-form__step-instruction').first();
    await firstStep.fill('Test step');

    // Now save button should be enabled
    await expect(saveButton).toBeEnabled();
  });

  test('should handle ingredient groups correctly', async ({ page }) => {
    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');

    // Wait for the form to load
    await page.waitForSelector('form', { timeout: 10000 });

    // Add a second ingredient group
    await page.click('button:has-text("Add Ingredient Group")');

    // Find the second group and set its name
    const secondGroup = await page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 2' });
    await secondGroup.locator('input[placeholder*="Main Ingredients"]').fill('Sauce Ingredients');

    // Add ingredient to second group
    await secondGroup.locator('button:has-text("Add Ingredient")').click();
    const secondGroupIngredient = await secondGroup.locator('.recipe-form__ingredient').first();
    await secondGroupIngredient.locator('input[placeholder*="All-purpose flour"]').fill('Tomatoes');
    await secondGroupIngredient.locator('input[placeholder*="2"]').fill('4');
    await secondGroupIngredient.locator('input[placeholder*="cups"]').fill('medium');

    // Mark as optional
    await secondGroupIngredient.locator('input[type="checkbox"]').check();

    // Verify the ingredient group structure
    await expect(secondGroup.locator('input[value="Sauce Ingredients"]')).toBeVisible();
    await expect(secondGroupIngredient.locator('input[type="checkbox"]')).toBeChecked();
  });
});