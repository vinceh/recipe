import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Data Display Verification', () => {
  test('should display all recipe data correctly after creation (not as JSON)', async ({ page }) => {
    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });

    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // Create a recipe with various data formats
    const recipeName = `Display Test Recipe ${Date.now()}`;
    const sourceUrl = 'https://displaytest.com/recipe';

    // Fill form with specific test data
    await page.fill('input#name', recipeName);
    await page.fill('input#source_url', sourceUrl);

    // Add ingredients with specific formatting
    const ingredient1Inputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredient1Inputs.nth(0).fill('Flour');
    await ingredient1Inputs.nth(1).fill('2 1/2');
    await ingredient1Inputs.nth(2).fill('cups');
    await ingredient1Inputs.nth(3).fill('sifted');

    // Add second ingredient
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);
    const ingredient2Inputs = page.locator('.recipe-form__ingredient').nth(1).locator('input[type="text"]');
    await ingredient2Inputs.nth(0).fill('Butter');
    await ingredient2Inputs.nth(1).fill('1/2');
    await ingredient2Inputs.nth(2).fill('stick');
    await ingredient2Inputs.nth(3).fill('melted and cooled');

    // Add step
    const step1 = page.locator('textarea').first();
    await step1.fill('Combine all dry ingredients in a large bowl');

    // Save recipe
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // ============================================
    // VERIFY DATA DISPLAY FORMAT
    // ============================================

    // 1. Recipe name should display as plain text
    await expect(page.locator(`text="${recipeName}"`)).toBeVisible();

    // 2. Ingredients should NOT display as JSON
    // Should NOT see JSON brackets or quotes around ingredient data
    await expect(page.locator('text=/\\{"name":|\\["name":|"ingredients":\\{/')).not.toBeVisible();

    // 3. Ingredients should display with proper formatting
    await expect(page.locator('text="Flour"')).toBeVisible();
    await expect(page.locator('text=/2 1\\/2\\s*cups?/')).toBeVisible();
    await expect(page.locator('text="sifted"')).toBeVisible();

    await expect(page.locator('text="Butter"')).toBeVisible();
    await expect(page.locator('text=/1\\/2\\s*stick/')).toBeVisible();
    await expect(page.locator('text="melted and cooled"')).toBeVisible();

    // 4. Steps should display as plain text, NOT as JSON
    await expect(page.locator('text="Combine all dry ingredients in a large bowl"')).toBeVisible();
    await expect(page.locator('text=/\\{"instructions":|\\["instructions":|"steps":\\{/')).not.toBeVisible();
  });

  test('should format ingredient amounts correctly', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Format Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Test various amount formats
    const testCases = [
      { amount: '1', unit: 'cup', name: 'Water', expected: '1 cup' },
      { amount: '2.5', unit: 'tablespoons', name: 'Oil', expected: '2.5 tablespoons' },
      { amount: '1/4', unit: 'teaspoon', name: 'Salt', expected: '1/4 teaspoon' },
      { amount: '3-4', unit: '', name: 'Eggs', expected: '3-4' },
      { amount: '', unit: '', name: 'Pepper to taste', expected: 'Pepper to taste' },
    ];

    // Add ingredients with different formats
    for (let i = 0; i < testCases.length; i++) {
      if (i > 0) {
        await page.locator('button:has-text("Add Ingredient")').first().click();
        await page.waitForTimeout(300);
      }

      const inputs = page.locator('.recipe-form__ingredient').nth(i).locator('input[type="text"]');
      await inputs.nth(0).fill(testCases[i].name);
      await inputs.nth(1).fill(testCases[i].amount);
      await inputs.nth(2).fill(testCases[i].unit);
    }

    // Add step
    await page.locator('textarea').first().fill('Mix everything');

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Verify each ingredient displays correctly
    for (const testCase of testCases) {
      await expect(page.locator(`text="${testCase.name}"`)).toBeVisible();
      if (testCase.amount) {
        await expect(page.locator(`text=/${testCase.expected}/`)).toBeVisible();
      }
    }
  });

  test('should display multilingual steps correctly', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Multilang Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Select language
    await page.locator('#language').locator('..').click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'English' }).first().click();

    // Add ingredient
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    // Add steps with special characters
    const step1 = page.locator('textarea').first();
    await step1.fill('Step with "quotes" and special chars: & < > © ™');

    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step2 = page.locator('textarea').nth(1);
    await step2.fill('Step with emoji 🍳 and unicode characters: café, naïve');

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Verify special characters display correctly
    await expect(page.locator('text=/Step with "quotes" and special chars/')).toBeVisible();
    await expect(page.locator('text=/Step with emoji 🍳/')).toBeVisible();
    await expect(page.locator('text=/café, naïve/')).toBeVisible();
  });

  test('should display equipment list as tags, not JSON', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Equipment Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Add ingredient and step
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');

    // Add equipment
    const equipmentInput = page.locator('input#equipment');
    const equipment = ['Large pot', 'Wooden spoon', 'Measuring cups', 'Kitchen timer'];

    for (const item of equipment) {
      await equipmentInput.fill(item);
      await equipmentInput.press('Enter');
      await page.waitForTimeout(200);
    }

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Equipment should display as individual items, not JSON array
    await expect(page.locator('text=/\\["Large pot"/')).not.toBeVisible();
    await expect(page.locator('text="Large pot"')).toBeVisible();
    await expect(page.locator('text="Wooden spoon"')).toBeVisible();
    await expect(page.locator('text="Measuring cups"')).toBeVisible();
    await expect(page.locator('text="Kitchen timer"')).toBeVisible();
  });

  test('should display aliases as tags, not JSON', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Alias Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Add ingredient and step
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');

    // Add aliases
    const aliasInput = page.locator('input#aliases');
    const aliases = ['Alternative Name', 'Another Name', 'Nickname'];

    for (const alias of aliases) {
      await aliasInput.fill(alias);
      await aliasInput.press('Enter');
      await page.waitForTimeout(200);
    }

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Aliases should display as individual tags, not JSON array
    await expect(page.locator('text=/\\["Alternative Name"/')).not.toBeVisible();
    await expect(page.locator('text="Alternative Name"')).toBeVisible();
    await expect(page.locator('text="Another Name"')).toBeVisible();
    await expect(page.locator('text="Nickname"')).toBeVisible();
  });

  test('should display timing information correctly', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Timing Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Add ingredient and step
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');

    // Set timing
    const timingSection = page.locator('text=Timing').locator('..').locator('..');
    const timingInputs = timingSection.locator('input[type="text"]');
    await timingInputs.nth(0).fill('20'); // Prep
    await timingInputs.nth(1).fill('45'); // Cook
    await timingInputs.nth(2).fill('65'); // Total

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Timing should display as formatted text, not JSON
    await expect(page.locator('text=/65\\s*min/i')).toBeVisible();
    await expect(page.locator('text=/\\{"prep_minutes"/')).not.toBeVisible();
    await expect(page.locator('text=/\\{"timing"/')).not.toBeVisible();
  });

  test('should display precision settings correctly', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Precision Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Add ingredient and step
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');

    // Set precision
    await page.check('input#requires_precision');
    await page.waitForTimeout(500);

    const precisionDropdown = page.locator('#precision_reason').locator('..');
    await precisionDropdown.click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'Confectionery' }).first().click();

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Precision should display as Yes/No or true/false, not raw boolean
    await expect(page.locator('text=/Yes|true/i').first()).toBeVisible();
    await expect(page.locator('text=/Confectionery/i').first()).toBeVisible();
    await expect(page.locator('text="requires_precision"')).not.toBeVisible();
  });

  test('should display admin notes as formatted text', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Notes Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Add ingredient and step
    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await page.locator('textarea').first().fill('Test step');

    // Add admin notes with line breaks
    const adminNotes = `This is the first line of admin notes.
This is the second line.
This recipe requires special attention.`;
    await page.locator('textarea#admin_notes').fill(adminNotes);

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Admin notes should display as formatted text
    await expect(page.locator('text="This is the first line of admin notes"')).toBeVisible();
    await expect(page.locator('text="requires special attention"')).toBeVisible();
  });

  test('should display multiple ingredient groups correctly', async ({ page }) => {
    // Login and navigate
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Groups Test ${Date.now()}`;
    await page.fill('input#name', recipeName);

    // Group 1: Dry Ingredients
    const group1NameInput = page.locator('input[id^="group-name-"]').first();
    await group1NameInput.fill('Dry Ingredients');

    const ingredient1Inputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredient1Inputs.nth(0).fill('Flour');
    await ingredient1Inputs.nth(1).fill('2');
    await ingredient1Inputs.nth(2).fill('cups');

    // Group 2: Wet Ingredients
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    const group2Section = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 2' });
    const group2NameInput = group2Section.locator('input[id^="group-name-"]');
    await group2NameInput.fill('Wet Ingredients');

    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(300);

    const group2Ingredient = group2Section.locator('.recipe-form__ingredient').first();
    const group2Inputs = group2Ingredient.locator('input[type="text"]');
    await group2Inputs.nth(0).fill('Milk');
    await group2Inputs.nth(1).fill('1');
    await group2Inputs.nth(2).fill('cup');

    // Add step
    await page.locator('textarea').first().fill('Mix ingredients');

    // Save and verify
    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Verify groups display correctly
    await expect(page.locator('text="Dry Ingredients"')).toBeVisible();
    await expect(page.locator('text="Wet Ingredients"')).toBeVisible();
    await expect(page.locator('text="Flour"')).toBeVisible();
    await expect(page.locator('text="Milk"')).toBeVisible();

    // Should not display as nested JSON
    await expect(page.locator('text=/\\{"name":"Dry Ingredients"/')).not.toBeVisible();
    await expect(page.locator('text=/ingredient_groups/')).not.toBeVisible();
  });
});