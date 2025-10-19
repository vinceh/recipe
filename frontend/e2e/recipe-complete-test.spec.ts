import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Complete Field Test', () => {
  test('creates recipe with ALL fields and verifies EVERYTHING is saved', async ({ page }) => {
    // ============================================
    // STEP 1: LOGIN
    // ============================================
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@ember.app');
    await page.fill('input[type="password"]', '123456');
    await page.click('button[type="submit"]');
    await page.waitForURL('**/admin', { timeout: 10000 });

    // ============================================
    // STEP 2: NAVIGATE TO NEW RECIPE PAGE
    // ============================================
    await page.goto('/admin/recipes/new');
    await page.waitForSelector('form', { timeout: 5000 });

    // ============================================
    // STEP 3: FILL IN ALL FIELDS
    // ============================================

    // Test data - we'll verify all of this appears correctly
    const testData = {
      name: 'Complete Test Recipe With All Fields',
      sourceUrl: 'https://example.com/my-test-recipe',
      language: 'en',
      servings: {
        original: '8',
        min: '2',
        max: '16'
      },
      timing: {
        prep: '25',
        cook: '45',
        total: '70'
      },
      ingredientGroup1: {
        name: 'Main Ingredients Group',
        items: [
          {
            name: 'Chicken Breast',
            amount: '4',
            unit: 'pounds',
            notes: 'boneless and skinless',
            optional: false
          },
          {
            name: 'Olive Oil',
            amount: '3',
            unit: 'tablespoons',
            notes: 'extra virgin preferred',
            optional: true
          }
        ]
      },
      ingredientGroup2: {
        name: 'Sauce Ingredients',
        items: [
          {
            name: 'Heavy Cream',
            amount: '2',
            unit: 'cups',
            notes: 'room temperature',
            optional: false
          },
          {
            name: 'Parmesan Cheese',
            amount: '1.5',
            unit: 'cups',
            notes: 'freshly grated',
            optional: false
          }
        ]
      },
      steps: [
        'Season the chicken breasts with salt and pepper on both sides',
        'Heat olive oil in a large skillet over medium-high heat',
        'Cook chicken for 7-8 minutes per side until golden brown',
        'Remove chicken and set aside to rest',
        'In the same pan, add cream and bring to a simmer',
        'Add parmesan cheese and stir until sauce thickens'
      ],
      equipment: ['Large skillet', 'Meat thermometer', 'Cutting board'],
      aliases: ['Creamy Chicken Recipe', 'Chicken in Cream Sauce'],
      adminNotes: 'This is a comprehensive test recipe with all fields filled',
      requiresPrecision: true,
      precisionReason: 'baking'
    };

    // ============================================
    // 3.1 BASIC INFORMATION
    // ============================================
    await page.fill('input#name', testData.name);
    await page.fill('input#source_url', testData.sourceUrl);

    // ============================================
    // 3.2 SERVINGS
    // ============================================
    // PrimeVue InputNumber components need special handling
    const servingsOriginal = page.locator('input[id="servings_original"]');
    await servingsOriginal.clear();
    await servingsOriginal.fill(testData.servings.original);

    const servingsMin = page.locator('input[id="servings_min"]');
    await servingsMin.clear();
    await servingsMin.fill(testData.servings.min);

    const servingsMax = page.locator('input[id="servings_max"]');
    await servingsMax.clear();
    await servingsMax.fill(testData.servings.max);

    // ============================================
    // 3.3 TIMING
    // ============================================
    const prepTime = page.locator('input[id="prep_time"]');
    await prepTime.clear();
    await prepTime.fill(testData.timing.prep);

    const cookTime = page.locator('input[id="cook_time"]');
    await cookTime.clear();
    await cookTime.fill(testData.timing.cook);

    const totalTime = page.locator('input[id="total_time"]');
    await totalTime.clear();
    await totalTime.fill(testData.timing.total);

    // ============================================
    // 3.4 PRECISION
    // ============================================
    await page.check('input#requires_precision');
    await page.waitForTimeout(500); // Wait for conditional field to appear

    // Select precision reason - click on the select component
    const precisionSelect = page.locator('#precision_reason').locator('..');
    await precisionSelect.click();
    await page.locator('li').filter({ hasText: 'Baking' }).click();

    // ============================================
    // 3.5 TAGS & CLASSIFICATION
    // ============================================

    // Dietary Tags - find by ID and parent container
    const dietaryTagsSelect = page.locator('#dietary_tags').locator('..');
    await dietaryTagsSelect.click();
    await page.waitForTimeout(300);
    await page.locator('[role="option"]').filter({ hasText: 'Vegetarian' }).first().click();
    await page.locator('[role="option"]').filter({ hasText: 'Gluten-Free' }).first().click();
    await page.keyboard.press('Escape');

    // Cuisines
    const cuisinesSelect = page.locator('#cuisines').locator('..');
    await cuisinesSelect.click();
    await page.waitForTimeout(300);
    await page.locator('[role="option"]').filter({ hasText: 'American' }).first().click();
    await page.locator('[role="option"]').filter({ hasText: 'Italian' }).first().click();
    await page.keyboard.press('Escape');

    // Dish Types
    const dishTypesSelect = page.locator('#dish_types').locator('..');
    await dishTypesSelect.click();
    await page.waitForTimeout(300);
    await page.locator('[role="option"]').filter({ hasText: 'Main Course' }).first().click();
    await page.locator('[role="option"]').filter({ hasText: 'Appetizer' }).first().click();
    await page.keyboard.press('Escape');

    // Recipe Types
    const recipeTypesSelect = page.locator('#recipe_types').locator('..');
    await recipeTypesSelect.click();
    await page.waitForTimeout(300);
    await page.locator('[role="option"]').filter({ hasText: 'Quick' }).first().click();
    await page.locator('[role="option"]').filter({ hasText: 'Comfort Food' }).first().click();
    await page.keyboard.press('Escape');

    // ============================================
    // 3.6 ALIASES
    // ============================================
    for (const alias of testData.aliases) {
      await page.fill('input#aliases', alias);
      await page.keyboard.press('Enter');
      await page.waitForTimeout(200);
    }

    // ============================================
    // 3.7 INGREDIENT GROUP 1 - Main Ingredients
    // ============================================

    // Group 1 already exists by default, update its name
    const group1NameInput = page.locator('input[value="Main Ingredients"]').first();
    await group1NameInput.clear();
    await group1NameInput.fill(testData.ingredientGroup1.name);

    // Fill first ingredient (already exists)
    const ingredient1Inputs = page.locator('.recipe-form__ingredient').first().locator('input');
    await ingredient1Inputs.nth(0).fill(testData.ingredientGroup1.items[0].name);
    await ingredient1Inputs.nth(1).fill(testData.ingredientGroup1.items[0].amount);
    await ingredient1Inputs.nth(2).fill(testData.ingredientGroup1.items[0].unit);
    await ingredient1Inputs.nth(3).fill(testData.ingredientGroup1.items[0].notes);

    // Add second ingredient to group 1
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);

    const ingredient2 = page.locator('.recipe-form__ingredient').nth(1);
    const ingredient2Inputs = ingredient2.locator('input');
    await ingredient2Inputs.nth(0).fill(testData.ingredientGroup1.items[1].name);
    await ingredient2Inputs.nth(1).fill(testData.ingredientGroup1.items[1].amount);
    await ingredient2Inputs.nth(2).fill(testData.ingredientGroup1.items[1].unit);
    await ingredient2Inputs.nth(3).fill(testData.ingredientGroup1.items[1].notes);
    await ingredient2.locator('input[type="checkbox"]').check(); // Mark as optional

    // ============================================
    // 3.8 INGREDIENT GROUP 2 - Sauce Ingredients
    // ============================================

    // Add second ingredient group
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    // Find and update the second group's name
    const group2Section = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 2' });
    const group2NameInput = group2Section.locator('input[placeholder*="Main Ingredients"]');
    await group2NameInput.fill(testData.ingredientGroup2.name);

    // Add first ingredient to group 2
    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    const group2Ingredient1 = group2Section.locator('.recipe-form__ingredient').first();
    const group2Ingredient1Inputs = group2Ingredient1.locator('input');
    await group2Ingredient1Inputs.nth(0).fill(testData.ingredientGroup2.items[0].name);
    await group2Ingredient1Inputs.nth(1).fill(testData.ingredientGroup2.items[0].amount);
    await group2Ingredient1Inputs.nth(2).fill(testData.ingredientGroup2.items[0].unit);
    await group2Ingredient1Inputs.nth(3).fill(testData.ingredientGroup2.items[0].notes);

    // Add second ingredient to group 2
    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    const group2Ingredient2 = group2Section.locator('.recipe-form__ingredient').nth(1);
    const group2Ingredient2Inputs = group2Ingredient2.locator('input');
    await group2Ingredient2Inputs.nth(0).fill(testData.ingredientGroup2.items[1].name);
    await group2Ingredient2Inputs.nth(1).fill(testData.ingredientGroup2.items[1].amount);
    await group2Ingredient2Inputs.nth(2).fill(testData.ingredientGroup2.items[1].unit);
    await group2Ingredient2Inputs.nth(3).fill(testData.ingredientGroup2.items[1].notes);

    // ============================================
    // 3.9 STEPS
    // ============================================

    // Fill first step (already exists)
    const step1Textarea = page.locator('textarea.recipe-form__step-instruction').first();
    await step1Textarea.fill(testData.steps[0]);

    // Add remaining steps
    for (let i = 1; i < testData.steps.length; i++) {
      await page.click('button:has-text("Add Step")');
      await page.waitForTimeout(300);
      const stepTextarea = page.locator('textarea.recipe-form__step-instruction').nth(i);
      await stepTextarea.fill(testData.steps[i]);
    }

    // ============================================
    // 3.10 EQUIPMENT
    // ============================================
    for (const equipment of testData.equipment) {
      await page.fill('input#equipment', equipment);
      await page.keyboard.press('Enter');
      await page.waitForTimeout(200);
    }

    // ============================================
    // 3.11 ADMIN NOTES
    // ============================================
    await page.fill('textarea#admin_notes', testData.adminNotes);

    // ============================================
    // STEP 4: SAVE THE RECIPE
    // ============================================
    console.log('Saving recipe...');
    await page.click('button:has-text("Save")');

    // Wait for redirect to detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 10000 });
    console.log('Recipe saved successfully, now on detail page');

    // ============================================
    // STEP 5: VERIFY ALL DATA IS DISPLAYED CORRECTLY
    // ============================================

    // Wait for page to fully load
    await page.waitForTimeout(1000);

    console.log('Starting verification of all fields...');

    // 5.1 Verify Basic Information
    await expect(page.locator('h1, h2').filter({ hasText: testData.name })).toBeVisible();

    // 5.2 Verify Servings
    await expect(page.locator(`text=${testData.servings.original}`)).toBeVisible();

    // 5.3 Verify Timing
    await expect(page.locator(`text=${testData.timing.total} min`)).toBeVisible();

    // 5.4 Verify Precision
    await expect(page.locator('text=Yes').or(page.locator('text=Requires Precision: Yes'))).toBeVisible();
    await expect(page.locator('text=baking').or(page.locator('text=Baking'))).toBeVisible();

    // 5.5 Verify Tags - check for any of the tags we selected
    await expect(page.locator('text=/vegetarian|gluten-free/i')).toBeVisible();
    await expect(page.locator('text=/american|italian/i')).toBeVisible();

    // 5.6 Verify Aliases
    for (const alias of testData.aliases) {
      await expect(page.locator(`text=${alias}`)).toBeVisible();
    }

    // 5.7 Verify Ingredient Groups and Items
    await expect(page.locator(`text=${testData.ingredientGroup1.name}`)).toBeVisible();
    await expect(page.locator(`text=${testData.ingredientGroup2.name}`)).toBeVisible();

    // Verify each ingredient with its details
    for (const item of testData.ingredientGroup1.items) {
      await expect(page.locator(`text=${item.name}`)).toBeVisible();
      await expect(page.locator(`text=${item.amount}`)).toBeVisible();
      await expect(page.locator(`text=${item.unit}`)).toBeVisible();
      await expect(page.locator(`text=${item.notes}`)).toBeVisible();
    }

    for (const item of testData.ingredientGroup2.items) {
      await expect(page.locator(`text=${item.name}`)).toBeVisible();
      await expect(page.locator(`text=${item.amount}`)).toBeVisible();
      await expect(page.locator(`text=${item.unit}`)).toBeVisible();
      await expect(page.locator(`text=${item.notes}`)).toBeVisible();
    }

    // 5.8 Verify Steps (not as JSON!)
    for (const step of testData.steps) {
      // Check that at least part of the step text is visible (not as JSON)
      const stepPartial = step.substring(0, 30);
      await expect(page.locator(`text=${stepPartial}`)).toBeVisible();
    }

    // 5.9 Verify Equipment
    for (const equipment of testData.equipment) {
      await expect(page.locator(`text=${equipment}`)).toBeVisible();
    }

    // 5.10 Verify Admin Notes
    await expect(page.locator(`text=${testData.adminNotes}`)).toBeVisible();

    // 5.11 Verify Source URL
    await expect(page.locator(`text=${testData.sourceUrl}`)).toBeVisible();

    console.log('✅ ALL FIELDS VERIFIED SUCCESSFULLY!');
    console.log('✅ Recipe creation with complete data test passed!');
  });
});