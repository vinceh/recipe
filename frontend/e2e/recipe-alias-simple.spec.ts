import { test, expect } from '@playwright/test';

test('Simple alias test - add and verify on detail page', async ({ page }) => {
  console.log('Starting simple alias test...');

  // Login
  await page.goto('/login');
  await page.fill('input[type="email"]', 'admin@ember.app');
  await page.fill('input[type="password"]', '123456');
  await page.click('button[type="submit"]');
  await page.waitForURL('**/admin', { timeout: 10000 });

  // Navigate to new recipe page
  await page.goto('/admin/recipes/new');
  await page.waitForSelector('form', { timeout: 5000 });

  const recipeName = `Simple Alias Recipe ${Date.now()}`;

  // Fill basic required fields
  await page.fill('input#name', recipeName);

  const ingredientInputs = page.locator('.recipe-form__ingredient').first().locator('input[type="text"]');
  await ingredientInputs.nth(0).fill('Test Ingredient');

  const step1 = page.locator('textarea').first();
  await step1.fill('Test step');

  // Add ONE alias
  console.log('Adding alias to form...');
  const aliasInput = page.locator('input#aliases');
  await aliasInput.fill('Test Alias Name');
  await aliasInput.press('Enter');
  await page.waitForTimeout(500);

  // Check if alias tag appears in the form
  const aliasTag = page.locator('.recipe-form__tag').filter({ hasText: 'Test Alias Name' });
  const tagCount = await aliasTag.count();
  console.log(`Alias tags found in form: ${tagCount}`);

  if (tagCount > 0) {
    console.log('✓ Alias tag appears in form');
  } else {
    console.log('✗ Alias tag NOT appearing in form - checking for alternatives...');

    // Check if alias appears anywhere else
    const anyAliasElement = page.locator('text="Test Alias Name"');
    const anyCount = await anyAliasElement.count();
    console.log(`Elements with alias text found: ${anyCount}`);
  }

  // Log the form data being sent
  await page.evaluate(() => {
    console.log('Form state before save:', document.querySelector('form')?.innerHTML?.substring(0, 500));
  });

  // Save the recipe
  console.log('Saving recipe...');
  await page.click('button:has-text("Save")');

  // Wait for redirect
  await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
  console.log('✓ Recipe saved and redirected');

  // Check what's displayed on detail page
  await page.waitForTimeout(2000); // Let page fully load

  // Check if alias section exists
  const aliasSection = page.locator('text="Aliases"').locator('..');
  const aliasContent = await aliasSection.textContent();
  console.log(`Alias section content: ${aliasContent}`);

  // Check specifically for our alias
  const aliasOnDetail = page.locator('text="Test Alias Name"');
  const detailCount = await aliasOnDetail.count();
  console.log(`Alias occurrences on detail page: ${detailCount}`);

  if (detailCount > 0) {
    console.log('✅ Alias is displayed on detail page!');
  } else {
    console.log('❌ Alias is NOT displayed on detail page');

    // Get the entire aliases section to see what's there
    const aliasesDiv = page.locator('.info-item').filter({ has: page.locator('label:has-text("Aliases")') });
    const aliasesText = await aliasesDiv.textContent();
    console.log(`Full aliases section text: ${aliasesText}`);
  }
});