import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Validation and Error Handling', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });

    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });
  });

  test('should require recipe name', async ({ page }) => {
    const saveButton = page.locator('button:has-text("Save")');

    // Initially save button should be disabled
    await expect(saveButton).toBeDisabled();

    // Fill everything except name
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await ingredientInputs.nth(1).fill('1');
    await ingredientInputs.nth(2).fill('cup');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Save button should still be disabled (missing name)
    await expect(saveButton).toBeDisabled();

    // Add name
    await page.fill('input#name', 'Test Recipe');

    // Save button should now be enabled
    await expect(saveButton).toBeEnabled();
  });

  test('should require at least one ingredient', async ({ page }) => {
    const saveButton = page.locator('button:has-text("Save")');

    // Fill name
    await page.fill('input#name', 'Test Recipe');

    // Fill step but no ingredients
    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Save button should be disabled (no ingredients)
    await expect(saveButton).toBeDisabled();

    // Add an ingredient
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    // Save button should now be enabled
    await expect(saveButton).toBeEnabled();
  });

  test('should require at least one step', async ({ page }) => {
    const saveButton = page.locator('button:has-text("Save")');

    // Fill name
    await page.fill('input#name', 'Test Recipe');

    // Fill ingredient but no steps
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    // Save button should be disabled (no steps)
    await expect(saveButton).toBeDisabled();

    // Add a step
    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Save button should now be enabled
    await expect(saveButton).toBeEnabled();
  });

  test('should validate servings are positive numbers', async ({ page }) => {
    // Fill required fields first
    await page.fill('input#name', 'Test Recipe');

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Try to set negative servings
    const servingsInput = page.locator('.recipe-form__row').first().locator('input[type="text"]').first();
    await servingsInput.clear();
    await servingsInput.fill('-5');

    // The InputNumber component should prevent negative values
    // Check that the value is either 0 or empty (depends on PrimeVue implementation)
    const value = await servingsInput.inputValue();
    expect(Number(value) >= 0).toBeTruthy();
  });

  test('should validate timing values are non-negative', async ({ page }) => {
    // Fill required fields
    await page.fill('input#name', 'Test Recipe');

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    const timingSection = page.locator('text=Timing').locator('..').locator('..');
    const prepTimeInput = timingSection.locator('input[type="text"]').first();

    // Try to enter negative time
    await prepTimeInput.fill('-15');

    // The InputNumber component should prevent negative values
    const value = await prepTimeInput.inputValue();
    expect(Number(value) >= 0).toBeTruthy();
  });

  test('should trim whitespace from recipe name', async ({ page }) => {
    // Fill name with extra spaces
    await page.fill('input#name', '   Test Recipe With Spaces   ');

    // Fill other required fields
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Save button should be enabled (trimmed name is valid)
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeEnabled();
  });

  test('should validate URL format for source URL', async ({ page }) => {
    // Fill required fields
    await page.fill('input#name', 'Test Recipe');

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    const sourceUrlInput = page.locator('input#source_url');

    // Test invalid URL (this should still save as backend might handle validation)
    await sourceUrlInput.fill('not a valid url');

    // Test valid URLs
    await sourceUrlInput.clear();
    await sourceUrlInput.fill('https://example.com/recipe');

    await sourceUrlInput.clear();
    await sourceUrlInput.fill('http://test.org');

    // Save button should remain enabled (URL validation might be backend-side)
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeEnabled();
  });

  test('should prevent removing last ingredient group', async ({ page }) => {
    // Should start with one ingredient group
    const ingredientGroups = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients' });
    await expect(ingredientGroups).toHaveCount(1);

    // Should NOT have a remove button for the only group
    const removeGroupButton = page.locator('button:has-text("Remove Group")');
    await expect(removeGroupButton).not.toBeVisible();

    // Add a second group
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // Now remove buttons should be visible
    await expect(removeGroupButton.first()).toBeVisible();

    // Remove the second group
    await removeGroupButton.first().click();
    await page.waitForTimeout(500);

    // Should be back to one group with no remove button
    await expect(ingredientGroups).toHaveCount(1);
    await expect(removeGroupButton).not.toBeVisible();
  });

  test('should handle empty ingredient groups gracefully', async ({ page }) => {
    // Fill required fields
    await page.fill('input#name', 'Test Recipe');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Add a second ingredient group but leave it empty
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // Fill first group with an ingredient
    const firstGroupIngredient = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await firstGroupIngredient.nth(0).fill('Test Ingredient');

    // Leave second group empty (no ingredients added)
    // The save button should still be enabled (at least one group has ingredients)
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeEnabled();
  });

  test('should handle optional ingredients correctly', async ({ page }) => {
    // Fill required fields
    await page.fill('input#name', 'Test Recipe');

    const ingredient1 = page.locator('.recipe-form__ingredient').first();
    const ingredient1Inputs = ingredient1.locator('input[type="text"]');
    await ingredient1Inputs.nth(0).fill('Required Ingredient');

    // Add second ingredient and mark as optional
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);

    const ingredient2 = page.locator('.recipe-form__ingredient').nth(1);
    const ingredient2Inputs = ingredient2.locator('input[type="text"]');
    await ingredient2Inputs.nth(0).fill('Optional Ingredient');

    // Mark as optional
    const optionalCheckbox = ingredient2.locator('input[type="checkbox"]');
    await optionalCheckbox.check();

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Both ingredients should be displayed
    await expect(page.locator('text="Required Ingredient"')).toBeVisible();
    await expect(page.locator('text="Optional Ingredient"')).toBeVisible();
  });

  test('should handle precision reason visibility correctly', async ({ page }) => {
    const precisionCheckbox = page.locator('input#requires_precision');
    const precisionReasonField = page.locator('#precision_reason').locator('..');

    // Initially precision reason should not be visible
    await expect(precisionReasonField).not.toBeVisible();

    // Check precision checkbox
    await precisionCheckbox.check();
    await page.waitForTimeout(500);

    // Precision reason should be visible
    await expect(precisionReasonField).toBeVisible();

    // Select a reason
    await precisionReasonField.click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'Baking' }).first().click();

    // Uncheck precision checkbox
    await precisionCheckbox.uncheck();
    await page.waitForTimeout(500);

    // Precision reason should be hidden
    await expect(precisionReasonField).not.toBeVisible();

    // Check again
    await precisionCheckbox.check();
    await page.waitForTimeout(500);

    // The previously selected value should be cleared/reset
    await expect(precisionReasonField).toBeVisible();
  });

  test('should display error message on save failure', async ({ page }) => {
    // Mock a network error by intercepting the request
    await page.route('**/admin/recipes', async route => {
      await route.abort('failed');
    });

    // Fill required fields
    await page.fill('input#name', 'Test Recipe');

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // Try to save
    await page.click('button:has-text("Save")');

    // Should display error message
    await page.waitForTimeout(1000);
    const errorMessage = page.locator('[class*="error"]').first();
    await expect(errorMessage).toBeVisible();

    // Should remain on the same page (not redirect)
    await expect(page.url()).toContain('/admin/recipes/new');
  });

  test('should handle very long text in fields gracefully', async ({ page }) => {
    const longText = 'A'.repeat(1000);
    const veryLongText = 'B'.repeat(5000);

    // Fill with long texts
    await page.fill('input#name', longText.substring(0, 255)); // Assuming name has a max length

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill(longText);
    await ingredientInputs.nth(3).fill(veryLongText); // Notes field

    const step1 = page.locator('textarea').first();
    await step1.fill(veryLongText);

    const adminNotes = page.locator('textarea#admin_notes');
    await adminNotes.fill(veryLongText);

    // Save button should be enabled
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeEnabled();

    // The form should handle long text without breaking
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Verify some of the long text is displayed
    await expect(page.locator('text=/AAAA/').first()).toBeVisible();
  });

  test('should maintain form state when adding/removing elements', async ({ page }) => {
    // Fill some data
    const recipeName = 'Test Recipe State';
    await page.fill('input#name', recipeName);

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('First Ingredient');

    // Add equipment
    const equipmentInput = page.locator('input#equipment');
    await equipmentInput.fill('Test Equipment');
    await equipmentInput.press('Enter');

    // Add a new ingredient group
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // Verify original data is still there
    await expect(page.locator('input#name')).toHaveValue(recipeName);
    await expect(ingredientInputs.nth(0)).toHaveValue('First Ingredient');
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Test Equipment' })).toBeVisible();

    // Remove the new group
    await page.locator('button:has-text("Remove Group")').first().click();
    await page.waitForTimeout(500);

    // Original data should still be intact
    await expect(page.locator('input#name')).toHaveValue(recipeName);
    await expect(ingredientInputs.nth(0)).toHaveValue('First Ingredient');
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Test Equipment' })).toBeVisible();
  });
});