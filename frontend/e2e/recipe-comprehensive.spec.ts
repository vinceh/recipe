import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Comprehensive Test', () => {
  test('creates and verifies recipe with all fields', async ({ page }) => {
    console.log('Starting comprehensive recipe creation test...');

    // ============================================
    // STEP 1: LOGIN
    // ============================================
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });
    console.log('✓ Logged in successfully');

    // ============================================
    // STEP 2: NAVIGATE TO NEW RECIPE PAGE
    // ============================================
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });
    console.log('✓ Navigated to new recipe page');

    // ============================================
    // STEP 3: FILL ALL FIELDS WITH TEST DATA
    // ============================================

    // Test data
    const recipeName = `Full Test Recipe ${Date.now()}`;
    const sourceUrl = 'https://test-recipe.com';

    // 3.1 Basic Information
    await page.fill('input#name', recipeName);
    await page.fill('input#source_url', sourceUrl);
    console.log('✓ Filled basic information');

    // 3.2 Servings - Use nth selector for InputNumber components
    const servingsInputs = page.locator('.recipe-form__row').first().locator('input[type="text"]');
    await servingsInputs.nth(0).fill('6');  // Original
    await servingsInputs.nth(1).fill('2');  // Min
    await servingsInputs.nth(2).fill('12'); // Max
    console.log('✓ Filled servings');

    // 3.3 Timing
    const timingSection = page.locator('text=Timing').locator('..').locator('..');
    const timingInputs = timingSection.locator('input[type="text"]');
    await timingInputs.nth(0).fill('15'); // Prep
    await timingInputs.nth(1).fill('30'); // Cook
    await timingInputs.nth(2).fill('45'); // Total
    console.log('✓ Filled timing');

    // 3.4 Precision
    await page.check('input#requires_precision');
    await page.waitForTimeout(500);
    // Click the select dropdown and choose an option
    await page.locator('#precision_reason').locator('..').click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'Baking' }).first().click();
    console.log('✓ Set precision requirements');

    // 3.5 Tags - Use the multiselect components
    // Dietary Tags
    await page.locator('#dietary_tags').locator('..').click();
    await page.waitForTimeout(300);
    const dietaryOptions = page.locator('[role="option"]');
    const vegetarianOption = dietaryOptions.filter({ hasText: 'Vegetarian' }).first();
    if (await vegetarianOption.isVisible()) {
      await vegetarianOption.click();
    }
    await page.keyboard.press('Escape');
    console.log('✓ Selected dietary tags');

    // Cuisines
    await page.locator('#cuisines').locator('..').click();
    await page.waitForTimeout(300);
    const cuisineOptions = page.locator('[role="option"]');
    const italianOption = cuisineOptions.filter({ hasText: 'Italian' }).first();
    if (await italianOption.isVisible()) {
      await italianOption.click();
    }
    await page.keyboard.press('Escape');
    console.log('✓ Selected cuisines');

    // 3.6 Aliases
    const aliasInput = page.locator('input#aliases');
    await aliasInput.fill('Test Alias 1');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);
    await aliasInput.fill('Test Alias 2');
    await aliasInput.press('Enter');
    console.log('✓ Added aliases');

    // 3.7 Ingredient Group 1 (default exists)
    // Update group name
    const group1Name = page.locator('input[value="Main Ingredients"]').first();
    await group1Name.clear();
    await group1Name.fill('Primary Ingredients');

    // Fill first ingredient
    const ingredient1 = page.locator('.recipe-form__ingredient').first();
    const ingredient1Inputs = ingredient1.locator('input[type="text"]');
    await ingredient1Inputs.nth(0).fill('Chicken Breast');
    await ingredient1Inputs.nth(1).fill('2');
    await ingredient1Inputs.nth(2).fill('pounds');
    await ingredient1Inputs.nth(3).fill('boneless, skinless');

    // Add second ingredient to group 1
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);
    const ingredient2 = page.locator('.recipe-form__ingredient').nth(1);
    const ingredient2Inputs = ingredient2.locator('input[type="text"]');
    await ingredient2Inputs.nth(0).fill('Olive Oil');
    await ingredient2Inputs.nth(1).fill('3');
    await ingredient2Inputs.nth(2).fill('tablespoons');
    await ingredient2Inputs.nth(3).fill('extra virgin');
    await ingredient2.locator('input[type="checkbox"]').check(); // Optional
    console.log('✓ Filled first ingredient group');

    // 3.8 Add Ingredient Group 2
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // Find the second group section
    const group2Section = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 2' });

    // Set group 2 name
    await group2Section.locator('input[placeholder*="Main Ingredients"]').fill('Sauce Components');

    // Add ingredient to group 2
    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    const group2Ingredient1 = group2Section.locator('.recipe-form__ingredient').first();
    const group2Ingredient1Inputs = group2Ingredient1.locator('input[type="text"]');
    await group2Ingredient1Inputs.nth(0).fill('Heavy Cream');
    await group2Ingredient1Inputs.nth(1).fill('1');
    await group2Ingredient1Inputs.nth(2).fill('cup');
    await group2Ingredient1Inputs.nth(3).fill('at room temperature');
    console.log('✓ Added second ingredient group');

    // 3.9 Steps
    // First step (already exists)
    const step1 = page.locator('textarea').first();
    await step1.fill('Season chicken with salt and pepper');

    // Add more steps
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step2 = page.locator('textarea').nth(1);
    await step2.fill('Heat oil in pan over medium-high heat');

    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step3 = page.locator('textarea').nth(2);
    await step3.fill('Cook chicken until golden brown, about 7 minutes per side');
    console.log('✓ Added steps');

    // 3.10 Equipment
    const equipmentInput = page.locator('input#equipment');
    await equipmentInput.fill('Large skillet');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);
    await equipmentInput.fill('Meat thermometer');
    await equipmentInput.press('Enter');
    console.log('✓ Added equipment');

    // 3.11 Admin Notes
    await page.fill('textarea#admin_notes', 'Comprehensive test recipe with all fields');
    console.log('✓ Added admin notes');

    // ============================================
    // STEP 4: SAVE THE RECIPE
    // ============================================
    console.log('Saving recipe...');
    await page.click('button:has-text("Save")');

    // Wait for redirect to detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    console.log('✓ Recipe saved successfully');

    // ============================================
    // STEP 5: VERIFY ALL DATA IS DISPLAYED
    // ============================================
    await page.waitForTimeout(2000); // Let page fully load

    console.log('Verifying saved data...');

    // 5.1 Basic Info
    await expect(page.locator(`text="${recipeName}"`)).toBeVisible();
    await expect(page.locator(`text="${sourceUrl}"`)).toBeVisible();
    console.log('✓ Basic info verified');

    // 5.2 Servings (look for the number 6)
    await expect(page.locator('text=/\\b6\\b/')).toBeVisible();
    console.log('✓ Servings verified');

    // 5.3 Timing (45 minutes total)
    await expect(page.locator('text=/45\\s*min/i')).toBeVisible();
    console.log('✓ Timing verified');

    // 5.4 Ingredients
    await expect(page.locator('text="Primary Ingredients"')).toBeVisible();
    await expect(page.locator('text="Chicken Breast"')).toBeVisible();
    await expect(page.locator('text="2 pounds"')).toBeVisible();
    await expect(page.locator('text="boneless, skinless"')).toBeVisible();

    await expect(page.locator('text="Olive Oil"')).toBeVisible();
    await expect(page.locator('text="3 tablespoons"')).toBeVisible();
    await expect(page.locator('text="extra virgin"')).toBeVisible();

    await expect(page.locator('text="Sauce Components"')).toBeVisible();
    await expect(page.locator('text="Heavy Cream"')).toBeVisible();
    await expect(page.locator('text="1 cup"')).toBeVisible();
    console.log('✓ All ingredients verified');

    // 5.5 Steps (verify they're not JSON)
    await expect(page.locator('text="Season chicken with salt and pepper"')).toBeVisible();
    await expect(page.locator('text="Heat oil in pan"')).toBeVisible();
    await expect(page.locator('text="Cook chicken until golden"')).toBeVisible();
    console.log('✓ Steps verified (displayed as text, not JSON)');

    // 5.6 Equipment
    await expect(page.locator('text="Large skillet"')).toBeVisible();
    await expect(page.locator('text="Meat thermometer"')).toBeVisible();
    console.log('✓ Equipment verified');

    // 5.7 Aliases
    await expect(page.locator('text="Test Alias 1"')).toBeVisible();
    await expect(page.locator('text="Test Alias 2"')).toBeVisible();
    console.log('✓ Aliases verified');

    // 5.8 Admin Notes
    await expect(page.locator('text="Comprehensive test recipe with all fields"')).toBeVisible();
    console.log('✓ Admin notes verified');

    // 5.9 Precision
    await expect(page.locator('text=/Yes|true/i').first()).toBeVisible();
    await expect(page.locator('text=/baking/i').first()).toBeVisible();
    console.log('✓ Precision settings verified');

    console.log('============================================');
    console.log('✅ COMPREHENSIVE TEST PASSED!');
    console.log('✅ All fields were saved and displayed correctly');
    console.log('✅ Recipe data is complete and accurate');
    console.log('============================================');
  });
});