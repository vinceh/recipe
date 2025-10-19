import { test, expect } from '@playwright/test';

test('Test alias with Add button click', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('input[type="email"]', 'admin@ember.app');
  await page.fill('input[type="password"]', '123456');
  await page.click('button[type="submit"]');
  await page.waitForURL('**/admin', { timeout: 10000 });

  // Navigate to new recipe page
  await page.goto('/admin/recipes/new');
  await page.waitForSelector('form', { timeout: 5000 });

  // Try to add alias using the Add button
  const aliasInput = page.locator('input#aliases');
  await aliasInput.fill('Test Alias With Button');

  // Click Add button
  const addButton = page.locator('button:has-text("Add")').filter({
    has: page.locator('..').filter({ has: page.locator('input#aliases') })
  });

  // First check if the button exists
  const buttonCount = await page.locator('button:has-text("Add")').count();
  console.log(`Found ${buttonCount} Add button(s)`);

  // Try a simpler selector
  const aliasSection = page.locator('input#aliases').locator('..').locator('..');
  const addButtonSimple = aliasSection.locator('button:has-text("Add")');
  const simpleCount = await addButtonSimple.count();
  console.log(`Found ${simpleCount} Add button(s) near alias input`);

  if (simpleCount > 0) {
    console.log('Clicking Add button...');
    await addButtonSimple.first().click();
    await page.waitForTimeout(500);

    // Check if alias tag appears
    const aliasTag = page.locator('.recipe-form__tag').filter({ hasText: 'Test Alias With Button' });
    const tagCount = await aliasTag.count();
    console.log(`Alias tags after button click: ${tagCount}`);

    if (tagCount > 0) {
      console.log('✅ Alias works with Add button!');
    } else {
      console.log('❌ Alias does NOT work with Add button');

      // Check the entire form state
      const aliasesSection = page.locator('.recipe-form__tags');
      const sectionExists = await aliasesSection.count();
      console.log(`Alias tags section exists: ${sectionExists > 0}`);

      if (sectionExists > 0) {
        const content = await aliasesSection.textContent();
        console.log(`Alias tags section content: "${content}"`);
      }
    }
  } else {
    console.log('❌ Add button not found!');
  }
});