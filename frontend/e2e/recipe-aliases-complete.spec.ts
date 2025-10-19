import { test, expect } from '@playwright/test';

test.describe('Recipe Aliases - Complete Functionality', () => {
  test('should add, save, and display aliases correctly', async ({ page }) => {
    console.log('Testing complete alias functionality...');

    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });

    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const recipeName = `Alias Test Recipe ${Date.now()}`;

    // Fill basic required fields
    await page.fill('input#name', recipeName);

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');
    await ingredientInputs.nth(1).fill('1');
    await ingredientInputs.nth(2).fill('cup');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test cooking step');

    // Add multiple aliases
    const aliasInput = page.locator('input#aliases');
    const aliasesToAdd = [
      'Alternative Name 1',
      'Another Name',
      'Recipe Nickname',
      'Common Name',
      'Regional Variant'
    ];

    console.log('Adding aliases to form...');
    for (const alias of aliasesToAdd) {
      await aliasInput.fill(alias);
      await aliasInput.press('Enter');
      await page.waitForTimeout(200);

      // Verify alias appears as a tag
      await expect(page.locator('.recipe-form__tag').filter({ hasText: alias })).toBeVisible();
      console.log(`✓ Added alias: ${alias}`);
    }

    // Test removing an alias
    console.log('Testing alias removal...');
    const removeButton = page.locator('.recipe-form__tag')
      .filter({ hasText: 'Another Name' })
      .locator('button');
    await removeButton.click();

    // Verify it's removed
    await expect(page.locator('.recipe-form__tag').filter({ hasText: 'Another Name' })).not.toBeVisible();
    console.log('✓ Successfully removed alias');

    // Count remaining aliases (should be 4)
    const remainingAliases = page.locator('.recipe-form__tag').filter({
      has: page.locator('button:has-text("×")')
    });
    await expect(remainingAliases).toHaveCount(4);
    console.log('✓ Correct number of aliases remaining');

    // Save the recipe
    console.log('Saving recipe with aliases...');
    await page.click('button:has-text("Save")');

    // Wait for redirect to detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    console.log('✓ Recipe saved successfully');

    // Verify recipe name is displayed
    await expect(page.locator(`h1:has-text("${recipeName}")`).or(page.locator(`p:has-text("${recipeName}")`)).first()).toBeVisible();

    // Verify all remaining aliases are displayed on the detail page
    console.log('Verifying aliases on detail page...');
    const expectedAliases = [
      'Alternative Name 1',
      'Recipe Nickname',
      'Common Name',
      'Regional Variant'
    ];

    for (const alias of expectedAliases) {
      await expect(page.locator(`text="${alias}"`)).toBeVisible();
      console.log(`✓ Alias displayed: ${alias}`);
    }

    // Verify removed alias is NOT displayed
    await expect(page.locator('text="Another Name"')).not.toBeVisible();
    console.log('✓ Removed alias not displayed');

    console.log('============================================');
    console.log('✅ ALIAS FUNCTIONALITY TEST PASSED!');
    console.log('✅ Aliases can be added during creation');
    console.log('✅ Aliases can be removed before saving');
    console.log('✅ Aliases are saved correctly');
    console.log('✅ Aliases display on recipe detail page');
    console.log('============================================');
  });

  test('should handle edge cases for aliases', async ({ page }) => {
    console.log('Testing alias edge cases...');

    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });

    // Navigate to new recipe page
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    const aliasInput = page.locator('input#aliases');

    // Test 1: Empty alias (should not add)
    console.log('Test 1: Empty alias');
    await aliasInput.fill('   ');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    let aliasTags = page.locator('.recipe-form__tag').filter({
      has: page.locator('button:has-text("×")')
    });
    await expect(aliasTags).toHaveCount(0);
    console.log('✓ Empty alias not added');

    // Test 2: Alias with special characters
    console.log('Test 2: Special characters');
    const specialAlias = 'Crème Brûlée (French Dessert)';
    await aliasInput.fill(specialAlias);
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    await expect(page.locator('.recipe-form__tag').filter({ hasText: specialAlias })).toBeVisible();
    console.log('✓ Special characters handled correctly');

    // Test 3: Long alias name
    console.log('Test 3: Long alias name');
    const longAlias = 'This is a very long alternative name for a recipe that might be used in some contexts';
    await aliasInput.fill(longAlias);
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    await expect(page.locator('.recipe-form__tag').filter({ hasText: longAlias })).toBeVisible();
    console.log('✓ Long alias names work');

    // Test 4: Multiple aliases with same name (depends on implementation)
    console.log('Test 4: Duplicate alias');
    await aliasInput.fill('Duplicate Name');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    // Try to add same alias again
    await aliasInput.fill('Duplicate Name');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);

    // Count how many "Duplicate Name" tags exist (implementation may allow or prevent duplicates)
    const duplicates = page.locator('.recipe-form__tag').filter({ hasText: 'Duplicate Name' });
    const count = await duplicates.count();
    console.log(`✓ Duplicate handling: ${count} instance(s) of "Duplicate Name"`);

    // Test 5: Removing all aliases
    console.log('Test 5: Remove all aliases');
    const allRemoveButtons = page.locator('.recipe-form__tag button:has-text("×")');
    const buttonCount = await allRemoveButtons.count();

    for (let i = buttonCount - 1; i >= 0; i--) {
      await allRemoveButtons.nth(i).click();
      await page.waitForTimeout(100);
    }

    aliasTags = page.locator('.recipe-form__tag').filter({
      has: page.locator('button:has-text("×")')
    });
    await expect(aliasTags).toHaveCount(0);
    console.log('✓ All aliases can be removed');

    // Test 6: Recipe saves without any aliases
    console.log('Test 6: Save recipe without aliases');

    const recipeName = `No Alias Recipe ${Date.now()}`;
    await page.fill('input#name', recipeName);

    const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
    await ingredientInputs.nth(0).fill('Test Ingredient');

    const step1 = page.locator('textarea').first();
    await step1.fill('Test step');

    await page.click('button:has-text("Save")');
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });

    // Recipe should save successfully without aliases
    await expect(page.locator('h1').or(page.locator('p')).filter({ hasText: recipeName }).first()).toBeVisible();
    console.log('✓ Recipe saves successfully without aliases');

    console.log('============================================');
    console.log('✅ ALL ALIAS EDGE CASES HANDLED!');
    console.log('============================================');
  });
});