import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Basic Functionality', () => {
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

  test('should display the recipe creation form with all sections', async ({ page }) => {
    // Verify page title
    await expect(page.locator('h1')).toContainText('New Recipe');

    // Verify all form sections are present (use h3 to be specific)
    await expect(page.locator('h3:has-text("Basic Information")')).toBeVisible();
    await expect(page.locator('h3:has-text("Servings")')).toBeVisible();
    await expect(page.locator('h3:has-text("Timing")')).toBeVisible();
    await expect(page.locator('h3:has-text("Precision Requirements")')).toBeVisible();
    await expect(page.locator('h3:has-text("Tags & Classification")')).toBeVisible();
    await expect(page.locator('h3:has-text("Alternate Names")')).toBeVisible();
    await expect(page.locator('h3:has-text("Ingredients")')).toBeVisible();
    await expect(page.locator('h3:has-text("Instructions")')).toBeVisible();
    await expect(page.locator('h3:has-text("Equipment")')).toBeVisible();
    await expect(page.locator('h3:has-text("Admin Notes")')).toBeVisible();

    // Verify form action buttons
    await expect(page.locator('button:has-text("Cancel")')).toBeVisible();
    await expect(page.locator('button:has-text("Save")')).toBeVisible();
  });

  test('should have save button disabled when form is invalid', async ({ page }) => {
    // Initially the save button should be disabled (no required fields filled)
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeDisabled();
  });

  test('should enable save button when minimum required fields are filled', async ({ page }) => {
    const saveButton = page.locator('button:has-text("Save")');

    // Fill minimum required fields
    await page.fill('input#name', 'Test Recipe');

    // Add at least one ingredient (required)
    const firstIngredientName = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]').first();
    await firstIngredientName.fill('Test Ingredient');

    // Add at least one step (required)
    const firstStep = page.locator('textarea').first();
    await firstStep.fill('Test step instructions');

    // Save button should now be enabled
    await expect(saveButton).toBeEnabled();
  });

  test('should create a basic recipe with minimum required fields', async ({ page }) => {
    const recipeName = `Basic Test Recipe ${Date.now()}`;

    // Fill basic information
    await page.fill('input#name', recipeName);

    // Fill servings (has default but let's set it explicitly)
    const servingsInput = page.locator('#servings_original input');
    await servingsInput.clear();
    await servingsInput.fill('4');

    // Add one ingredient
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await ingredientInputs.nth(1).fill('1');
    await ingredientInputs.nth(2).fill('cup');

    // Add one step
    const step1 = page.locator('textarea').first();
    await step1.fill('Mix all ingredients together');

    // Save the recipe
    await page.click('button:has-text("Save")');

    // Should redirect to recipe detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Verify the recipe name is displayed
    await expect(page.locator(`text="${recipeName}"`)).toBeVisible();

    // Verify basic data is displayed
    await expect(page.locator('text="Test Ingredient"')).toBeVisible();
    await expect(page.locator('text="1 cup"')).toBeVisible();
    await expect(page.locator('text="Mix all ingredients together"')).toBeVisible();
  });

  test('should handle cancel button correctly', async ({ page }) => {
    // Fill some data
    await page.fill('input#name', 'Unsaved Recipe');

    // Click cancel
    await page.click('button:has-text("Cancel")');

    // Should navigate back to recipes list
    await page.waitForURL('**/admin/recipes', { timeout: 5000 });

    // Verify we're on the recipes list page
    await expect(page.locator('h1')).toContainText('Recipes');
  });

  test('should add and remove ingredient groups', async ({ page }) => {
    // Initially should have one ingredient group
    let ingredientGroups = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients' });
    await expect(ingredientGroups).toHaveCount(1);

    // Add a new ingredient group
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // Should now have two ingredient groups
    ingredientGroups = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients' });
    await expect(ingredientGroups).toHaveCount(2);

    // Remove the second group
    const removeGroupButton = page.locator('button:has-text("Remove Group")').first();
    await removeGroupButton.click();

    // Should be back to one group
    await page.waitForTimeout(500);
    ingredientGroups = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients' });
    await expect(ingredientGroups).toHaveCount(1);
  });

  test('should add and remove ingredients within a group', async ({ page }) => {
    // Get the first ingredient group
    const firstGroup = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 1' });

    // Initially should have one ingredient row
    let ingredients = firstGroup.locator('.recipe-form__ingredient');
    await expect(ingredients).toHaveCount(1);

    // Add another ingredient
    await firstGroup.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    // Should now have two ingredients
    ingredients = firstGroup.locator('.recipe-form__ingredient');
    await expect(ingredients).toHaveCount(2);

    // Remove the second ingredient
    const removeButton = firstGroup.locator('.recipe-form__ingredient').nth(1).locator('button[class*="pi-trash"]');
    await removeButton.click();

    // Should be back to one ingredient
    await page.waitForTimeout(500);
    ingredients = firstGroup.locator('.recipe-form__ingredient');
    await expect(ingredients).toHaveCount(1);
  });

  test('should add and remove steps', async ({ page }) => {
    // Initially should have one step
    let steps = page.locator('textarea');
    await expect(steps).toHaveCount(2); // One for step, one for admin notes

    // Add another step
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(500);

    // Should now have two steps (plus admin notes textarea)
    steps = page.locator('textarea');
    await expect(steps).toHaveCount(3);

    // Remove the second step
    const removeStepButton = page.locator('.recipe-form__step').nth(1).locator('button[class*="pi-trash"]');
    await removeStepButton.click();

    // Should be back to one step (plus admin notes)
    await page.waitForTimeout(500);
    steps = page.locator('textarea');
    await expect(steps).toHaveCount(2);
  });

  test('should reorder steps using arrow buttons', async ({ page }) => {
    // Add two more steps
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);

    // Fill the steps with distinct content
    const step1 = page.locator('textarea').nth(0);
    const step2 = page.locator('textarea').nth(1);
    const step3 = page.locator('textarea').nth(2);

    await step1.fill('First step');
    await step2.fill('Second step');
    await step3.fill('Third step');

    // Move the second step up
    const moveUpButton = page.locator('.recipe-form__step').nth(1).locator('button[class*="pi-arrow-up"]');
    await moveUpButton.click();
    await page.waitForTimeout(300);

    // Verify order changed
    await expect(page.locator('textarea').nth(0)).toHaveValue('Second step');
    await expect(page.locator('textarea').nth(1)).toHaveValue('First step');

    // Move the third step down (should not move as it's already last)
    const moveDownButton = page.locator('.recipe-form__step').nth(2).locator('button[class*="pi-arrow-down"]');
    await expect(moveDownButton).toBeDisabled();
  });

  test('should add equipment items', async ({ page }) => {
    const equipmentInput = page.locator('input#equipment');

    // Add first equipment item
    await equipmentInput.fill('Large pot');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    // Verify it was added
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Large pot' })).toBeVisible();

    // Add second equipment item
    await equipmentInput.fill('Wooden spoon');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    // Verify both are displayed
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Large pot' })).toBeVisible();
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Wooden spoon' })).toBeVisible();

    // Remove the first item
    const removeButton = page.locator('.recipe-form__tag').filter({ hasText: 'Large pot' }).locator('button');
    await removeButton.click();

    // Verify only the second item remains
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Large pot' })).not.toBeVisible();
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Wooden spoon' })).toBeVisible();
  });

  test('should add aliases', async ({ page }) => {
    const aliasInput = page.locator('input#aliases');

    // Add first alias
    await aliasInput.fill('Alternative Name 1');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    // Verify it was added
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Alternative Name 1' })).toBeVisible();

    // Add second alias
    await aliasInput.fill('Alternative Name 2');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    // Verify both are displayed
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Alternative Name 1' })).toBeVisible();
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Alternative Name 2' })).toBeVisible();
  });

  test('should toggle precision requirement', async ({ page }) => {
    const precisionCheckbox = page.locator('input#requires_precision');
    const precisionReason = page.locator('#precision_reason').locator('..');

    // Initially precision reason should not be visible
    await expect(precisionReason).not.toBeVisible();

    // Check the precision checkbox
    await precisionCheckbox.check();
    await page.waitForTimeout(500);

    // Precision reason dropdown should now be visible
    await expect(precisionReason).toBeVisible();

    // Select a precision reason
    await precisionReason.click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'Baking' }).first().click();

    // Uncheck the precision checkbox
    await precisionCheckbox.uncheck();
    await page.waitForTimeout(500);

    // Precision reason should be hidden again
    await expect(precisionReason).not.toBeVisible();
  });
});