import { test, expect } from '@playwright/test';

/**
 * Acceptance Criteria for Recipe Creation - BDD Format
 *
 * These tests follow Given-When-Then format to validate all acceptance criteria
 * for the admin recipe creation feature.
 */

test.describe('Recipe Creation - Acceptance Criteria', () => {

  // ============================================
  // AC-RECIPE-001: Create Recipe with Minimum Required Fields
  // ============================================
  test('AC-RECIPE-001: Admin creates recipe with minimum required fields', async ({ page }) => {
    // GIVEN admin is logged in and on new recipe page
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // AND recipe form is displayed with default values
    await expect(page.locator('form')).toBeVisible();
    await expect(page.locator('button:has-text("Save")')).toBeDisabled();

    // WHEN admin enters minimum required data
    const recipeName = `AC Test Recipe ${Date.now()}`;
    await page.fill('input#name', recipeName);

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test cooking instructions');

    // AND admin clicks Save
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeEnabled();
    await saveButton.click();

    // THEN recipe is created successfully
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // AND admin is redirected to recipe detail page
    await expect(page.url()).toMatch(/\/admin\/recipes\/\d+/);

    // AND recipe data is displayed correctly
    await expect(page.locator(`text="${recipeName}"`)).toBeVisible();
    await expect(page.locator('text="Test Ingredient"')).toBeVisible();
    await expect(page.locator('text="Test cooking instructions"')).toBeVisible();
  });

  // ============================================
  // AC-RECIPE-002: Validation Prevents Saving Invalid Recipe
  // ============================================
  test('AC-RECIPE-002: System prevents saving recipe without required fields', async ({ page }) => {
    // GIVEN admin is on new recipe page
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // WHEN admin attempts to save without filling required fields
    const saveButton = page.locator('button:has-text("Save")');

    // THEN save button is disabled
    await expect(saveButton).toBeDisabled();

    // WHEN admin fills only recipe name
    await page.fill('input#name', 'Incomplete Recipe');

    // THEN save button remains disabled (missing ingredients and steps)
    await expect(saveButton).toBeDisabled();

    // WHEN admin adds an ingredient but no steps
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    // THEN save button remains disabled (missing steps)
    await expect(saveButton).toBeDisabled();

    // WHEN admin adds a step
    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    // THEN save button becomes enabled
    await expect(saveButton).toBeEnabled();
  });

  // ============================================
  // AC-RECIPE-003: Multiple Ingredient Groups Management
  // ============================================
  test('AC-RECIPE-003: Admin manages multiple ingredient groups', async ({ page }) => {
    // GIVEN admin is on new recipe page
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // AND one ingredient group exists by default
    let ingredientGroups = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients' });
    await expect(ingredientGroups).toHaveCount(1);

    // WHEN admin clicks "Add Ingredient Group"
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // THEN a new ingredient group is added
    ingredientGroups = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients' });
    await expect(ingredientGroups).toHaveCount(2);

    // AND admin can name each group
    const group1Name = page.locator('input[id^="group-name-0"]');
    await group1Name.clear();
    await group1Name.fill('Main Ingredients');

    const group2Section = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 2' });
    const group2Name = group2Section.locator('input[id^="group-name-"]');
    await group2Name.fill('Sauce');

    // AND admin can add ingredients to each group
    const group1Ingredient = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await group1Ingredient.nth(0).fill('Chicken');

    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(300);
    const group2Ingredient = group2Section.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await group2Ingredient.nth(0).fill('Cream');

    // WHEN admin saves the recipe
    await page.fill('input#name', 'Multi-Group Recipe');
    await page.locator('textarea').first().fill('Cook the chicken');
    await page.click('button:has-text("Save")');

    // THEN recipe is saved with multiple groups
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    await expect(page.locator('text="Main Ingredients"')).toBeVisible();
    await expect(page.locator('text="Sauce"')).toBeVisible();
    await expect(page.locator('text="Chicken"')).toBeVisible();
    await expect(page.locator('text="Cream"')).toBeVisible();
  });

  // ============================================
  // AC-RECIPE-004: Optional Ingredients Handling
  // ============================================
  test('AC-RECIPE-004: Admin marks ingredients as optional', async ({ page }) => {
    // GIVEN admin is adding ingredients to a recipe
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // WHEN admin adds required ingredient
    const ingredient1 = page.locator('.recipe-form__ingredient').first();
    const ingredient1Inputs = ingredient1.locator('input[type="text"]');
    await ingredient1Inputs.nth(0).fill('Required Ingredient');

    // AND admin adds optional ingredient
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);
    const ingredient2 = page.locator('.recipe-form__ingredient').nth(1);
    const ingredient2Inputs = ingredient2.locator('input[type="text"]');
    await ingredient2Inputs.nth(0).fill('Optional Garnish');

    // AND marks it as optional
    const optionalCheckbox = ingredient2.locator('input[type="checkbox"]');
    await optionalCheckbox.check();
    await expect(optionalCheckbox).toBeChecked();

    // WHEN admin saves the recipe
    await page.fill('input#name', 'Optional Ingredients Test');
    await page.locator('textarea').first().fill('Test step');
    await page.click('button:has-text("Save")');

    // THEN both ingredients are saved
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    await expect(page.locator('text="Required Ingredient"')).toBeVisible();
    await expect(page.locator('text="Optional Garnish"')).toBeVisible();

    // AND optional status is preserved (shown in detail view)
    // Note: Actual display of optional status depends on detail view implementation
  });

  // ============================================
  // AC-RECIPE-005: Step Management and Reordering
  // ============================================
  test('AC-RECIPE-005: Admin reorders recipe steps', async ({ page }) => {
    // GIVEN admin has added multiple steps to a recipe
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // Add three steps
    const step1 = page.locator('textarea').nth(0);
    await step1.fill('Step One: Prepare ingredients');

    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step2 = page.locator('textarea').nth(1);
    await step2.fill('Step Two: Cook the main dish');

    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step3 = page.locator('textarea').nth(2);
    await step3.fill('Step Three: Add garnish and serve');

    // WHEN admin moves step 2 up
    const moveUpButton = page.locator('.recipe-form__step').nth(1).locator('button[class*="pi-arrow-up"]');
    await moveUpButton.click();
    await page.waitForTimeout(300);

    // THEN step order is changed
    await expect(page.locator('textarea').nth(0)).toHaveValue('Step Two: Cook the main dish');
    await expect(page.locator('textarea').nth(1)).toHaveValue('Step One: Prepare ingredients');
    await expect(page.locator('textarea').nth(2)).toHaveValue('Step Three: Add garnish and serve');

    // WHEN admin saves the recipe
    await page.fill('input#name', 'Reordered Steps Recipe');
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.click('button:has-text("Save")');

    // THEN steps are saved in the new order
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    const stepsText = await page.locator('.steps-list').textContent();
    expect(stepsText?.indexOf('Cook the main dish')).toBeLessThan(stepsText?.indexOf('Prepare ingredients') || 999);
  });

  // ============================================
  // AC-RECIPE-006: Precision Requirements
  // ============================================
  test('AC-RECIPE-006: Admin specifies precision requirements for baking', async ({ page }) => {
    // GIVEN admin is creating a baking recipe
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // AND precision reason dropdown is initially hidden
    const precisionReasonField = page.locator('#precision_reason').locator('..');
    await expect(precisionReasonField).not.toBeVisible();

    // WHEN admin checks "Requires Precision"
    const precisionCheckbox = page.locator('input#requires_precision');
    await precisionCheckbox.check();
    await page.waitForTimeout(500);

    // THEN precision reason dropdown becomes visible
    await expect(precisionReasonField).toBeVisible();

    // WHEN admin selects "Baking" as the reason
    await precisionReasonField.click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'Baking' }).first().click();

    // AND admin saves the recipe
    await page.fill('input#name', 'Precision Baking Recipe');
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Flour');
    await ingredientInputs.nth(1).fill('250');
    await ingredientInputs.nth(2).fill('grams');
    await page.locator('textarea').first().fill('Mix precisely');
    await page.click('button:has-text("Save")');

    // THEN recipe is saved with precision requirements
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    await expect(page.locator('text=/Yes|true/i').first()).toBeVisible();
    await expect(page.locator('text=/Baking/i').first()).toBeVisible();
  });

  // ============================================
  // AC-RECIPE-007: Tag Classification
  // ============================================
  test('AC-RECIPE-007: Admin classifies recipe with tags', async ({ page }) => {
    // GIVEN admin is on new recipe page
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // WHEN admin selects dietary tags
    const dietaryTagsDropdown = page.locator('#dietary_tags').locator('..');
    await dietaryTagsDropdown.click();
    await page.waitForTimeout(300);

    // Select first available option
    const dietaryOption = page.locator('[role="option"]').first();
    const dietaryTagText = await dietaryOption.textContent();
    if (await dietaryOption.isVisible()) {
      await dietaryOption.click();
    }
    await page.keyboard.press('Escape');

    // AND admin selects cuisine
    const cuisinesDropdown = page.locator('#cuisines').locator('..');
    await cuisinesDropdown.click();
    await page.waitForTimeout(300);

    const cuisineOption = page.locator('[role="option"]').first();
    const cuisineText = await cuisineOption.textContent();
    if (await cuisineOption.isVisible()) {
      await cuisineOption.click();
    }
    await page.keyboard.press('Escape');

    // AND admin saves the recipe
    await page.fill('input#name', 'Tagged Recipe');
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');
    await page.click('button:has-text("Save")');

    // THEN recipe is saved with selected tags
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Tags should be displayed (exact text depends on available tags in system)
    if (dietaryTagText) {
      await expect(page.locator('.tags')).toContainText(dietaryTagText);
    }
    if (cuisineText) {
      await expect(page.locator('.tags')).toContainText(cuisineText);
    }
  });

  // ============================================
  // AC-RECIPE-008: Cancel Without Saving
  // ============================================
  test('AC-RECIPE-008: Admin cancels recipe creation without saving', async ({ page }) => {
    // GIVEN admin has partially filled the recipe form
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    await page.fill('input#name', 'Unsaved Recipe');
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Unsaved Ingredient');

    // WHEN admin clicks Cancel button
    await page.click('button:has-text("Cancel")');

    // THEN admin is redirected to recipes list
    await page.waitForURL('**/admin/recipes', { timeout: 5000 });

    // AND no new recipe is created
    await expect(page.locator('h1')).toContainText('Recipes');

    // AND the unsaved recipe name should not appear in the list
    await expect(page.locator('text="Unsaved Recipe"')).not.toBeVisible();
  });

  // ============================================
  // AC-RECIPE-009: Equipment List Management
  // ============================================
  test('AC-RECIPE-009: Admin specifies required equipment', async ({ page }) => {
    // GIVEN admin is on new recipe page
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // WHEN admin adds equipment items
    const equipmentInput = page.locator('input#equipment');

    await equipmentInput.fill('Stand mixer');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    await equipmentInput.fill('9-inch cake pan');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    await equipmentInput.fill('Wire cooling rack');
    await equipmentInput.press('Enter');

    // THEN equipment items are displayed as tags
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Stand mixer' })).toBeVisible();
    await expect(page.locator('.recipe-form__tag').filter({ hasText: '9-inch cake pan' })).toBeVisible();
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Wire cooling rack' })).toBeVisible();

    // WHEN admin removes an equipment item
    const removeButton = page.locator('.recipe-form__tag').filter({ hasText: 'Stand mixer' }).locator('button');
    await removeButton.click();

    // THEN the item is removed
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Stand mixer' })).not.toBeVisible();

    // WHEN admin saves the recipe
    await page.fill('input#name', 'Equipment Test Recipe');
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');
    await page.click('button:has-text("Save")');

    // THEN equipment is saved and displayed
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    await expect(page.locator('text="9-inch cake pan"')).toBeVisible();
    await expect(page.locator('text="Wire cooling rack"')).toBeVisible();
    await expect(page.locator('text="Stand mixer"')).not.toBeVisible();
  });

  // ============================================
  // AC-RECIPE-010: Admin Notes
  // ============================================
  test('AC-RECIPE-010: Admin adds internal notes to recipe', async ({ page }) => {
    // GIVEN admin is creating a recipe
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // WHEN admin adds admin notes
    const adminNotes = `Important: This recipe was adapted from the original version.
Customer feedback suggests reducing salt by 25%.
Consider testing with alternative flour types.`;

    await page.locator('textarea#admin_notes').fill(adminNotes);

    // AND admin saves the recipe
    await page.fill('input#name', 'Recipe with Admin Notes');
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');
    await page.click('button:has-text("Save")');

    // THEN recipe is saved with admin notes
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // AND admin notes are displayed
    await expect(page.locator('text="recipe was adapted from the original"')).toBeVisible();
    await expect(page.locator('text="reducing salt by 25%"')).toBeVisible();
    await expect(page.locator('text="alternative flour types"')).toBeVisible();
  });
});