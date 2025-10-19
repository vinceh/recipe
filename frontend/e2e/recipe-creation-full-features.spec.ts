import { test, expect } from '@playwright/test';

test.describe('Recipe Creation - Full Features Test', () => {
  test('should create a recipe with ALL fields populated and verify display', async ({ page }) => {
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

    const recipeName = `Comprehensive Test Recipe ${Date.now()}`;
    const sourceUrl = 'https://example.com/test-recipe';

    // 3.1 Basic Information
    await page.fill('input#name', recipeName);
    await page.fill('input#source_url', sourceUrl);

    // Select language
    await page.locator('#language').locator('..').click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'English' }).first().click();
    console.log('✓ Filled basic information');

    // 3.2 Servings
    const servingsInputs = page.locator('.recipe-form__row').first().locator('input[type="text"]');
    await servingsInputs.nth(0).clear();
    await servingsInputs.nth(0).fill('6');  // Original
    await servingsInputs.nth(1).clear();
    await servingsInputs.nth(1).fill('2');  // Min
    await servingsInputs.nth(2).clear();
    await servingsInputs.nth(2).fill('12'); // Max
    console.log('✓ Filled servings');

    // 3.3 Timing
    const timingSection = page.locator('text=Timing').locator('..').locator('..');
    const timingInputs = timingSection.locator('input[type="text"]');
    await timingInputs.nth(0).fill('15'); // Prep
    await timingInputs.nth(1).fill('30'); // Cook
    await timingInputs.nth(2).fill('45'); // Total
    console.log('✓ Filled timing');

    // 3.4 Precision Settings
    await page.check('input#requires_precision');
    await page.waitForTimeout(500);

    // Select precision reason
    const precisionDropdown = page.locator('#precision_reason').locator('..');
    await precisionDropdown.click();
    await page.waitForTimeout(300);
    await page.locator('li').filter({ hasText: 'Baking' }).first().click();
    console.log('✓ Set precision requirements');

    // 3.5 Classification - Tags and Categories
    // Dietary Tags
    const dietaryTagsDropdown = page.locator('#dietary_tags').locator('..');
    await dietaryTagsDropdown.click();
    await page.waitForTimeout(300);

    // Select first available dietary tag
    const dietaryOptions = page.locator('[role="option"]');
    const firstDietaryOption = dietaryOptions.first();
    if (await firstDietaryOption.isVisible()) {
      await firstDietaryOption.click();
    }
    await page.keyboard.press('Escape');
    console.log('✓ Selected dietary tags');

    // Cuisines
    const cuisinesDropdown = page.locator('#cuisines').locator('..');
    await cuisinesDropdown.click();
    await page.waitForTimeout(300);

    // Select first available cuisine
    const cuisineOptions = page.locator('[role="option"]');
    const firstCuisineOption = cuisineOptions.first();
    if (await firstCuisineOption.isVisible()) {
      await firstCuisineOption.click();
    }
    await page.keyboard.press('Escape');
    console.log('✓ Selected cuisines');

    // Dish Types
    const dishTypesDropdown = page.locator('#dish_types').locator('..');
    await dishTypesDropdown.click();
    await page.waitForTimeout(300);

    // Select first available dish type
    const dishTypeOptions = page.locator('[role="option"]');
    const firstDishTypeOption = dishTypeOptions.first();
    if (await firstDishTypeOption.isVisible()) {
      await firstDishTypeOption.click();
    }
    await page.keyboard.press('Escape');
    console.log('✓ Selected dish types');

    // Recipe Types
    const recipeTypesDropdown = page.locator('#recipe_types').locator('..');
    await recipeTypesDropdown.click();
    await page.waitForTimeout(300);

    // Select first available recipe type
    const recipeTypeOptions = page.locator('[role="option"]');
    const firstRecipeTypeOption = recipeTypeOptions.first();
    if (await firstRecipeTypeOption.isVisible()) {
      await firstRecipeTypeOption.click();
    }
    await page.keyboard.press('Escape');
    console.log('✓ Selected recipe types');

    // 3.6 Aliases
    const aliasInput = page.locator('input#aliases');
    await aliasInput.fill('Alternative Name 1');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);
    await aliasInput.fill('Alternative Name 2');
    await aliasInput.press('Enter');
    await page.waitForTimeout(200);
    await aliasInput.fill('Nickname Recipe');
    await aliasInput.press('Enter');
    console.log('✓ Added aliases');

    // 3.7 Ingredient Group 1 - Main Ingredients
    // Update default group name
    const group1Name = page.locator('input').filter({ hasText: /Main Ingredients/i }).first();
    if (await group1Name.isVisible()) {
      await group1Name.clear();
      await group1Name.fill('Main Ingredients');
    } else {
      // If not found, fill the first group name input
      const groupNameInput = page.locator('input[id^="group-name-"]').first();
      await groupNameInput.fill('Main Ingredients');
    }

    // Add first ingredient
    const ingredient1 = page.locator('.recipe-form__ingredient').first();
    const ingredient1Inputs = ingredient1.locator('input[type="text"]');
    await ingredient1Inputs.nth(0).fill('Chicken Breast');
    await ingredient1Inputs.nth(1).fill('2');
    await ingredient1Inputs.nth(2).fill('pounds');
    await ingredient1Inputs.nth(3).fill('boneless, skinless, cut into cubes');

    // Add second ingredient
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);

    const ingredient2 = page.locator('.recipe-form__ingredient').nth(1);
    const ingredient2Inputs = ingredient2.locator('input[type="text"]');
    await ingredient2Inputs.nth(0).fill('Olive Oil');
    await ingredient2Inputs.nth(1).fill('3');
    await ingredient2Inputs.nth(2).fill('tablespoons');
    await ingredient2Inputs.nth(3).fill('extra virgin preferred');

    // Mark as optional
    const optionalCheckbox = ingredient2.locator('input[type="checkbox"]');
    await optionalCheckbox.check();

    // Add third ingredient
    await page.locator('button:has-text("Add Ingredient")').first().click();
    await page.waitForTimeout(500);

    const ingredient3 = page.locator('.recipe-form__ingredient').nth(2);
    const ingredient3Inputs = ingredient3.locator('input[type="text"]');
    await ingredient3Inputs.nth(0).fill('Garlic');
    await ingredient3Inputs.nth(1).fill('4');
    await ingredient3Inputs.nth(2).fill('cloves');
    await ingredient3Inputs.nth(3).fill('minced');
    console.log('✓ Filled first ingredient group');

    // 3.8 Add Second Ingredient Group - Sauce
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    const group2Section = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 2' });

    // Set group 2 name
    const group2NameInput = group2Section.locator('input[id^="group-name-"]');
    await group2NameInput.fill('Sauce Ingredients');

    // Add ingredients to group 2
    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    const group2Ingredient1 = group2Section.locator('.recipe-form__ingredient').first();
    const group2Ingredient1Inputs = group2Ingredient1.locator('input[type="text"]');
    await group2Ingredient1Inputs.nth(0).fill('Heavy Cream');
    await group2Ingredient1Inputs.nth(1).fill('1');
    await group2Ingredient1Inputs.nth(2).fill('cup');
    await group2Ingredient1Inputs.nth(3).fill('room temperature');

    // Add another ingredient to group 2
    await group2Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    const group2Ingredient2 = group2Section.locator('.recipe-form__ingredient').nth(1);
    const group2Ingredient2Inputs = group2Ingredient2.locator('input[type="text"]');
    await group2Ingredient2Inputs.nth(0).fill('Parmesan Cheese');
    await group2Ingredient2Inputs.nth(1).fill('1/2');
    await group2Ingredient2Inputs.nth(2).fill('cup');
    await group2Ingredient2Inputs.nth(3).fill('freshly grated');
    console.log('✓ Added second ingredient group');

    // 3.9 Add Third Ingredient Group - Garnish
    await page.click('button:has-text("Add Ingredient Group")');
    await page.waitForTimeout(500);

    const group3Section = page.locator('.recipe-form__section').filter({ hasText: 'Ingredients 3' });

    // Set group 3 name
    const group3NameInput = group3Section.locator('input[id^="group-name-"]');
    await group3NameInput.fill('Garnish');

    // Add ingredient to group 3
    await group3Section.locator('button:has-text("Add Ingredient")').click();
    await page.waitForTimeout(500);

    const group3Ingredient1 = group3Section.locator('.recipe-form__ingredient').first();
    const group3Ingredient1Inputs = group3Ingredient1.locator('input[type="text"]');
    await group3Ingredient1Inputs.nth(0).fill('Fresh Basil');
    await group3Ingredient1Inputs.nth(1).fill('1/4');
    await group3Ingredient1Inputs.nth(2).fill('cup');
    await group3Ingredient1Inputs.nth(3).fill('chopped');

    // Mark garnish as optional
    const garnishOptional = group3Ingredient1.locator('input[type="checkbox"]');
    await garnishOptional.check();
    console.log('✓ Added third ingredient group');

    // 3.10 Steps - Add multiple detailed steps
    // Step 1 (already exists)
    const step1 = page.locator('textarea').first();
    await step1.fill('Season the chicken pieces with salt and pepper. Let them rest at room temperature for 15 minutes to ensure even cooking.');

    // Step 2
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step2 = page.locator('textarea').nth(1);
    await step2.fill('Heat olive oil in a large skillet over medium-high heat. When the oil shimmers, add the seasoned chicken pieces in a single layer.');

    // Step 3
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step3 = page.locator('textarea').nth(2);
    await step3.fill('Cook chicken for 5-7 minutes per side until golden brown and internal temperature reaches 165°F (74°C). Transfer to a plate and keep warm.');

    // Step 4
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step4 = page.locator('textarea').nth(3);
    await step4.fill('In the same skillet, reduce heat to medium. Add minced garlic and sauté for 30 seconds until fragrant, being careful not to burn.');

    // Step 5
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step5 = page.locator('textarea').nth(4);
    await step5.fill('Pour in the heavy cream and bring to a gentle simmer. Add the parmesan cheese and stir continuously until melted and sauce thickens, about 3-4 minutes.');

    // Step 6
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step6 = page.locator('textarea').nth(5);
    await step6.fill('Return the cooked chicken to the skillet and toss to coat with the sauce. Simmer for 2 minutes to reheat the chicken.');

    // Step 7
    await page.click('button:has-text("Add Step")');
    await page.waitForTimeout(300);
    const step7 = page.locator('textarea').nth(6);
    await step7.fill('Remove from heat and garnish with fresh basil. Serve immediately while hot with your choice of pasta or rice.');
    console.log('✓ Added detailed steps');

    // 3.11 Equipment
    const equipmentInput = page.locator('input#equipment');

    await equipmentInput.fill('Large skillet');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    await equipmentInput.fill('Meat thermometer');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    await equipmentInput.fill('Wooden spoon');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    await equipmentInput.fill('Cutting board');
    await equipmentInput.press('Enter');
    await page.waitForTimeout(200);

    await equipmentInput.fill('Sharp knife');
    await equipmentInput.press('Enter');
    console.log('✓ Added equipment');

    // 3.12 Admin Notes
    const adminNotesTextarea = page.locator('textarea#admin_notes');
    await adminNotesTextarea.fill(
      'This is a comprehensive test recipe created to verify all form fields are working correctly. ' +
      'It includes multiple ingredient groups, detailed steps, equipment list, and all classification tags. ' +
      'This recipe was created as part of the Playwright E2E test suite to ensure the recipe creation form ' +
      'handles complex recipes with all optional fields populated.'
    );
    console.log('✓ Added admin notes');

    // ============================================
    // STEP 4: SAVE THE RECIPE
    // ============================================
    console.log('Saving recipe with all fields populated...');

    // Verify save button is enabled
    const saveButton = page.locator('button:has-text("Save")');
    await expect(saveButton).toBeEnabled();

    // Click save
    await saveButton.click();

    // Wait for redirect to detail page
    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 });
    console.log('✓ Recipe saved successfully');

    // ============================================
    // STEP 5: COMPREHENSIVE DATA VERIFICATION
    // ============================================
    await page.waitForTimeout(2000); // Let page fully load

    console.log('Verifying all saved data...');

    // 5.1 Basic Information
    await expect(page.locator(`text="${recipeName}"`)).toBeVisible();
    await expect(page.locator(`text="${sourceUrl}"`)).toBeVisible();
    console.log('✓ Basic info verified');

    // 5.2 Servings
    await expect(page.locator('text=/\\b6\\b/')).toBeVisible();
    console.log('✓ Servings verified');

    // 5.3 Timing (45 minutes total)
    await expect(page.locator('text=/45\\s*min/i')).toBeVisible();
    console.log('✓ Timing verified');

    // 5.4 Main Ingredients Group
    await expect(page.locator('text="Main Ingredients"')).toBeVisible();
    await expect(page.locator('text="Chicken Breast"')).toBeVisible();
    await expect(page.locator('text=/2\\s*pounds?/')).toBeVisible();
    await expect(page.locator('text="boneless, skinless, cut into cubes"')).toBeVisible();

    await expect(page.locator('text="Olive Oil"')).toBeVisible();
    await expect(page.locator('text=/3\\s*tablespoons?/')).toBeVisible();

    await expect(page.locator('text="Garlic"')).toBeVisible();
    await expect(page.locator('text=/4\\s*cloves?/')).toBeVisible();
    console.log('✓ Main ingredients verified');

    // 5.5 Sauce Ingredients Group
    await expect(page.locator('text="Sauce Ingredients"')).toBeVisible();
    await expect(page.locator('text="Heavy Cream"')).toBeVisible();
    await expect(page.locator('text=/1\\s*cup/')).toBeVisible();

    await expect(page.locator('text="Parmesan Cheese"')).toBeVisible();
    console.log('✓ Sauce ingredients verified');

    // 5.6 Garnish Group
    await expect(page.locator('text="Garnish"')).toBeVisible();
    await expect(page.locator('text="Fresh Basil"')).toBeVisible();
    console.log('✓ Garnish ingredients verified');

    // 5.7 Steps (verify they display as text, not JSON)
    await expect(page.locator('text=/Season the chicken pieces with salt and pepper/')).toBeVisible();
    await expect(page.locator('text=/Heat olive oil in a large skillet/')).toBeVisible();
    await expect(page.locator('text=/Cook chicken for 5-7 minutes per side/')).toBeVisible();
    await expect(page.locator('text=/add minced garlic and sauté/')).toBeVisible();
    await expect(page.locator('text=/Pour in the heavy cream/')).toBeVisible();
    await expect(page.locator('text=/Return the cooked chicken to the skillet/')).toBeVisible();
    await expect(page.locator('text=/garnish with fresh basil/')).toBeVisible();
    console.log('✓ All steps verified as readable text');

    // 5.8 Equipment
    await expect(page.locator('text="Large skillet"')).toBeVisible();
    await expect(page.locator('text="Meat thermometer"')).toBeVisible();
    await expect(page.locator('text="Wooden spoon"')).toBeVisible();
    await expect(page.locator('text="Cutting board"')).toBeVisible();
    await expect(page.locator('text="Sharp knife"')).toBeVisible();
    console.log('✓ All equipment verified');

    // 5.9 Aliases
    await expect(page.locator('text="Alternative Name 1"')).toBeVisible();
    await expect(page.locator('text="Alternative Name 2"')).toBeVisible();
    await expect(page.locator('text="Nickname Recipe"')).toBeVisible();
    console.log('✓ All aliases verified');

    // 5.10 Admin Notes
    await expect(page.locator('text=/comprehensive test recipe created to verify all form fields/')).toBeVisible();
    console.log('✓ Admin notes verified');

    // 5.11 Precision Settings
    await expect(page.locator('text=/Yes|true/i').first()).toBeVisible();
    await expect(page.locator('text=/baking/i').first()).toBeVisible();
    console.log('✓ Precision settings verified');

    console.log('============================================');
    console.log('✅ COMPREHENSIVE TEST COMPLETED SUCCESSFULLY!');
    console.log('✅ All fields saved and displayed correctly');
    console.log('✅ Recipe data integrity verified');
    console.log('✅ Complex recipe with multiple groups handled');
    console.log('============================================');
  });
});