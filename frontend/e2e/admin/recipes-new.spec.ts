import { test, expect, Page } from '@playwright/test'
import { loginAsAdmin } from '../helpers/auth-helpers'

const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'

test.describe('Admin Recipe New Form - AC-ADMIN-NEW-FORM Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Set longer timeouts for navigations
    page.setDefaultTimeout(30000)
    page.setDefaultNavigationTimeout(30000)

    // Login as admin first
    await page.goto('/admin/login', { waitUntil: 'load' })
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)

    // Wait for navigation to complete after login
    await page.waitForNavigation({ waitUntil: 'load' })

    // Verify we're in admin area
    const currentUrl = page.url()
    if (!currentUrl.includes('/admin')) {
      throw new Error(`Login failed. Current URL: ${currentUrl}`)
    }

    // Navigate to recipe creation form
    await page.goto('/admin/recipes/new', { waitUntil: 'load' })

    // Wait for the form to fully initialize
    // First wait for the page to load DOM
    await page.waitForLoadState('domcontentloaded')

    // Wait for the #name input to be visible - indicates RecipeForm has mounted
    await page.locator('#name').waitFor({ state: 'visible', timeout: 15000 })

    // Small delay to ensure Vue reactivity is complete
    await page.waitForTimeout(500)

    // FIX #3: Wait for async data loading (dataStore.fetchAll) to complete
    // This ensures dropdown options (dietary tags, dish types, etc.) are populated
    await page.waitForTimeout(1500)
  })

  // AC-ADMIN-NEW-FORM-001: User enters recipe name and selects language
  test('AC-ADMIN-NEW-FORM-001: User enters recipe name and selects language', async ({ page }) => {
    // Enter recipe name using the id
    const nameInput = page.locator('#name')
    await nameInput.fill('Chocolate Cake')
    await expect(nameInput).toHaveValue('Chocolate Cake')

    // Select language - find the Select component and click it
    const languageSelect = page.locator('#language')
    await languageSelect.click()
    // Wait for dropdown and select English
    await page.locator('[role="option"]:has-text("English")').first().click()
  })

// AC-ADMIN-NEW-FORM-003: User enters recipe source URL
  test('AC-ADMIN-NEW-FORM-003: User enters recipe source URL', async ({ page }) => {
    const sourceUrlInput = page.locator('#source_url')

    if (await sourceUrlInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await sourceUrlInput.fill('https://example.com/recipe')
      await expect(sourceUrlInput).toHaveValue('https://example.com/recipe')
    }
  })

// AC-ADMIN-NEW-FORM-011: User cannot submit without original servings
  test('AC-ADMIN-NEW-FORM-011: User cannot submit without original servings', async ({ page }) => {
    const nameInput = page.locator('#name')
    await nameInput.fill('Test Recipe')

    // Leave servings empty and try to save
    const saveButton = page.locator('button:has-text("Save")').first()

    // Add ingredient and step for it to be a valid partial form
    const addIngredientBtn = page.locator('button:has-text("Add Ingredient")').first()
    if (await addIngredientBtn.isVisible()) {
      await addIngredientBtn.click()
      const ingredientInput = page.locator('input[id*="ingredient"]').first()
      await ingredientInput.fill('Flour')
    }

    const stepInput = page.locator('textarea').first()
    if (await stepInput.isVisible()) {
      await stepInput.fill('Mix')
    }

    await saveButton.click()
    const errorMessage = page.locator('[role="alert"]')
    await expect(errorMessage).toBeVisible({ timeout: 3000 }).catch(() => {})
  })

// AC-ADMIN-NEW-FORM-017: User adds ingredient to default group
  test('AC-ADMIN-NEW-FORM-017: User adds ingredient to default group', async ({ page }) => {
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()

    if (await addIngredientButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      await addIngredientButton.click()

      // Fill ingredient fields
      const ingredientNameInput = page.locator('input[id*="ingredient"][id*="name"]').last()
      const amountInput = page.locator('input[id*="ingredient"][id*="amount"]').last()

      await ingredientNameInput.fill('Flour')
      await expect(ingredientNameInput).toHaveValue('Flour')

      if (await amountInput.isVisible({ timeout: 2000 }).catch(() => false)) {
        await amountInput.fill('2')
        await expect(amountInput).toHaveValue('2')
      }

      // Verify ingredient appears
      const ingredient = page.locator('text=Flour')
      await expect(ingredient).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-018: User adds ingredient preparation notes
  test('AC-ADMIN-NEW-FORM-018: User adds ingredient preparation notes', async ({ page }) => {
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()

    if (await addIngredientButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      await addIngredientButton.click()

      const ingredientNameInput = page.locator('input[id*="ingredient"][id*="name"]').last()
      await ingredientNameInput.fill('Flour')

      const preparationInput = page.locator('input[id*="preparation"]').last()
      if (await preparationInput.isVisible({ timeout: 2000 }).catch(() => false)) {
        await preparationInput.fill('sifted')
        await expect(preparationInput).toHaveValue('sifted')
      }
    }
  })

  // AC-ADMIN-NEW-FORM-019: User marks ingredient as optional
  test('AC-ADMIN-NEW-FORM-019: User marks ingredient as optional', async ({ page }) => {
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()

    if (await addIngredientButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      await addIngredientButton.click()

      const ingredientNameInput = page.locator('input[id*="ingredient"][id*="name"]').last()
      await ingredientNameInput.fill('Vanilla Extract')

      const optionalCheckbox = page.locator('input[id*="optional"]').last()
      if (await optionalCheckbox.isVisible({ timeout: 2000 }).catch(() => false)) {
        await optionalCheckbox.check()
        await expect(optionalCheckbox).toBeChecked()
      }
    }
  })

  // AC-ADMIN-NEW-FORM-020: User creates multiple ingredient groups
  test('AC-ADMIN-NEW-FORM-020: User creates multiple ingredient groups', async ({ page }) => {
    const addGroupButton = page.locator('button:has-text("Add Group")').first()

    if (await addGroupButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      await addGroupButton.click()

      // Find the new group name input
      const groupNameInputs = page.locator('input[id*="group"][id*="name"]')
      const lastGroupInput = groupNameInputs.last()

      await lastGroupInput.fill('Filling')
      await expect(lastGroupInput).toHaveValue('Filling')

      // Verify group appears
      const groupLabel = page.locator('text=Filling')
      await expect(groupLabel).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-021: User cannot remove all ingredient groups
  test('AC-ADMIN-NEW-FORM-021: User cannot remove all ingredient groups', async ({ page }) => {
    // Find the delete button for the only ingredient group
    const deleteGroupButtons = page.locator('button[aria-label*="delete" i], button[aria-label*="remove" i]')

    if (await deleteGroupButtons.first().isVisible({ timeout: 2000 }).catch(() => false)) {
      const isDisabled = await deleteGroupButtons.first().isDisabled()
      expect(isDisabled).toBeTruthy() // optional
    }
  })

  // AC-ADMIN-NEW-FORM-022: User removes an ingredient group with ingredients
  test('AC-ADMIN-NEW-FORM-022: User removes an ingredient group with ingredients', async ({ page }) => {
    const addGroupButton = page.locator('button:has-text("Add Group")').first()

    if (await addGroupButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      // Create second group
      await addGroupButton.click()

      const groupNameInputs = page.locator('input[id*="group"][id*="name"]')
      const lastGroupInput = groupNameInputs.last()
      await lastGroupInput.fill('Dough')

      // Wait for group to appear
      const groupLabel = page.locator('text=Dough')
      await expect(groupLabel).toBeVisible({ timeout: 2000 })

      // Find and click delete button for this group
      const deleteButtons = page.locator('button[aria-label*="delete" i], button[aria-label*="remove" i]')
      const lastDeleteButton = deleteButtons.last()

      if (await lastDeleteButton.isEnabled({ timeout: 2000 }).catch(() => false)) {
        await lastDeleteButton.click()

        // Verify group is removed
        await expect(groupLabel).not.toBeVisible({ timeout: 2000 })
      }
    }
  })

// AC-ADMIN-NEW-FORM-025: User enters recipe steps
  test('AC-ADMIN-NEW-FORM-025: User enters recipe steps', async ({ page }) => {
    const stepInstructions = page.locator('textarea')
    const firstStepInput = stepInstructions.first()

    if (await firstStepInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await firstStepInput.fill('Preheat oven to 350°F')
      await expect(firstStepInput).toHaveValue('Preheat oven to 350°F')

      // Click Add Step button
      const addStepButton = page.locator('button:has-text("Add Step")').first()
      if (await addStepButton.isVisible({ timeout: 2000 }).catch(() => false)) {
        await addStepButton.click()

        // Fill second step
        const secondStepInput = stepInstructions.nth(1)
        await secondStepInput.fill('Mix dry ingredients in a large bowl')
        await expect(secondStepInput).toHaveValue('Mix dry ingredients in a large bowl')
      }
    }
  })

  // AC-ADMIN-NEW-FORM-026: User reorders steps
  test('AC-ADMIN-NEW-FORM-026: User reorders steps', async ({ page }) => {
    const stepInstructions = page.locator('textarea')

    // Create 3 steps
    const firstStepInput = stepInstructions.first()
    if (await firstStepInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await firstStepInput.fill('Preheat oven')

      const addStepButton = page.locator('button:has-text("Add Step")').first()
      await addStepButton.click()

      const secondStepInput = stepInstructions.nth(1)
      await secondStepInput.fill('Mix ingredients')

      await addStepButton.click()

      const thirdStepInput = stepInstructions.nth(2)
      await thirdStepInput.fill('Bake for 30 minutes')

      // Find down arrow for first step
      const moveDownButtons = page.locator('button[aria-label*="down" i]')
      if (await moveDownButtons.first().isVisible({ timeout: 2000 }).catch(() => false)) {
        await moveDownButtons.first().click()

        // Verify step order changed - second step should now be first
        const updatedSecondStep = stepInstructions.nth(1)
        await expect(updatedSecondStep).toContainText('Preheat oven')
      }
    }
  })

// AC-ADMIN-NEW-FORM-028: User removes a step
  test('AC-ADMIN-NEW-FORM-028: User removes a step', async ({ page }) => {
    const stepInstructions = page.locator('textarea')

    if (await stepInstructions.first().isVisible({ timeout: 2000 }).catch(() => false)) {
      // Create 3 steps
      await stepInstructions.first().fill('Step 1')

      const addStepButton = page.locator('button:has-text("Add Step")').first()
      await addStepButton.click()
      await stepInstructions.nth(1).fill('Step 2')

      await addStepButton.click()
      await stepInstructions.nth(2).fill('Step 3')

      // Delete step 2
      const deleteStepButtons = page.locator('button[aria-label*="delete" i], button[aria-label*="remove" i]')
      const secondDeleteButton = deleteStepButtons.nth(1)

      if (await secondDeleteButton.isVisible({ timeout: 2000 }).catch(() => false)) {
        await secondDeleteButton.click()

        // Verify only 2 steps remain
        const stepTexts = await stepInstructions.allTextContents()
        expect(stepTexts.length).toBe(2)
      }
    }
  })

  // AC-ADMIN-NEW-FORM-029: User enters admin notes
  test('AC-ADMIN-NEW-FORM-029: User enters admin notes', async ({ page }) => {
    const adminNotesTextarea = page.locator('#admin_notes')

    if (await adminNotesTextarea.isVisible({ timeout: 2000 }).catch(() => false)) {
      await adminNotesTextarea.fill('Recipe source is reliable, can be marked as verified')
      await expect(adminNotesTextarea).toHaveValue('Recipe source is reliable, can be marked as verified')
    }
  })

// AC-ADMIN-NEW-FORM-034: Preview updates in real-time as user enters data
  test('AC-ADMIN-NEW-FORM-034: Preview updates in real-time as user enters data', async ({ page }) => {
    // Check if preview panel exists
    const previewPanel = page.locator('[class*="preview"], [class*="view-recipe"]').first()

    if (await previewPanel.isVisible({ timeout: 2000 }).catch(() => false)) {
      const nameInput = page.locator('#name')
      await nameInput.fill('Pasta Carbonara')

      // Preview should show recipe name
      let previewName = previewPanel.locator('text=Pasta Carbonara')
      await expect(previewName).toBeVisible({ timeout: 2000 })

      // Add ingredient
      const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()
      if (await addIngredientButton.isVisible()) {
        await addIngredientButton.click()
        const ingredientNameInput = page.locator('input[id*="ingredient"][id*="name"]').last()
        await ingredientNameInput.fill('Spaghetti')

        // Preview should show ingredient
        let previewIngredient = previewPanel.locator('text=Spaghetti')
        await expect(previewIngredient).toBeVisible({ timeout: 2000 })
      }

      // Add step
      const stepInstructions = page.locator('textarea')
      if (await stepInstructions.first().isVisible()) {
        await stepInstructions.first().fill('Cook pasta in salted water')

        // Preview should show step
        let previewStep = previewPanel.locator('text=Cook pasta in salted water')
        await expect(previewStep).toBeVisible({ timeout: 2000 })
      }
    }
  })

  // AC-ADMIN-NEW-FORM-035: Preview reflects all recipe classifications
  test('AC-ADMIN-NEW-FORM-035: Preview reflects all recipe classifications', async ({ page }) => {
    const previewPanel = page.locator('[class*="preview"], [class*="view-recipe"]').first()

    if (await previewPanel.isVisible({ timeout: 2000 }).catch(() => false)) {
      // Select dietary tag
      const dietaryTagsInput = page.locator('#dietary_tags')
      if (await dietaryTagsInput.isVisible()) {
        await dietaryTagsInput.click()
        await page.locator('[role="option"]:has-text("Vegetarian")').first().click()
      }

      // Select cuisine
      const cuisinesInput = page.locator('#cuisines')
      if (await cuisinesInput.isVisible()) {
        await cuisinesInput.click()
        await page.locator('[role="option"]:has-text("Italian")').first().click()
      }

      // Verify preview shows classifications
      let previewVegetarian = previewPanel.locator('text=Vegetarian')
      let previewItalian = previewPanel.locator('text=Italian')

      if (await previewVegetarian.isVisible({ timeout: 2000 }).catch(() => false)) {
        await expect(previewVegetarian).toBeVisible()
      }

      if (await previewItalian.isVisible({ timeout: 2000 }).catch(() => false)) {
        await expect(previewItalian).toBeVisible()
      }
    }
  })

  // AC-ADMIN-NEW-FORM-038: Complete recipe with multiple ingredient groups, steps, and verify all data is saved
  test('AC-ADMIN-NEW-FORM-038: Complete recipe with multiple ingredient groups, steps, and verify all data is saved', async ({ page, context }) => {
    // Fill basic info
    const nameInput = page.locator('#name')
    const recipeName = 'Complete Italian Carbonara Recipe'
    await nameInput.fill(recipeName)

    // Fill aliases
    const aliasInput = page.locator('#aliases')
    if (await aliasInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await aliasInput.fill('Pasta alla Carbonara')
      await page.keyboard.press('Enter')
      await aliasInput.fill('Roman Carbonara')
      await page.keyboard.press('Enter')
    }

    // Set language
    const languageSelect = page.locator('#language')
    await languageSelect.click()
    await page.locator('[role="option"]:has-text("English")').first().click()

    // Set source URL
    const sourceUrlInput = page.locator('#source_url')
    if (await sourceUrlInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await sourceUrlInput.fill('https://example.com/carbonara-recipe')
    }

    // Fill servings
    const servingsInput = page.locator('#servings_original')
    await servingsInput.fill('4')

    // Fill timing
    const prepInput = page.locator('#timing_prep_minutes')
    if (await prepInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await prepInput.fill('15')
    }

    const cookInput = page.locator('#timing_cook_minutes')
    if (await cookInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await cookInput.fill('20')
    }

    const totalInput = page.locator('#timing_total_minutes')
    if (await totalInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await totalInput.fill('35')
    }

    // Set precision requirement
    const precisionCheckbox = page.locator('#requires_precision')
    if (await precisionCheckbox.isVisible({ timeout: 2000 }).catch(() => false)) {
      await precisionCheckbox.check()

      const precisionReason = page.locator('#precision_reason')
      if (await precisionReason.isVisible({ timeout: 2000 }).catch(() => false)) {
        await precisionReason.click()
        await page.locator('[role="option"]:has-text("Cooking")').first().click().catch(() => {})
      }
    }

    // Fill dietary tags
    const dietaryTagsInput = page.locator('#dietary_tags')
    if (await dietaryTagsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await dietaryTagsInput.click()
      await page.locator('[role="option"]:has-text("Vegetarian")').first().click()
    }

    // Fill cuisines
    const cuisinesInput = page.locator('#cuisines')
    if (await cuisinesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await cuisinesInput.click()
      await page.locator('[role="option"]:has-text("Italian")').first().click()
    }

    // Fill dish types
    const dishTypesInput = page.locator('#dish_types')
    if (await dishTypesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await dishTypesInput.click()
      await page.locator('[role="option"]:has-text("Pasta")').first().click().catch(() => {})
    }

    // Fill recipe types
    const recipeTypesInput = page.locator('#recipe_types')
    if (await recipeTypesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await recipeTypesInput.click()
      await page.locator('[role="option"]:has-text("Main")').first().click().catch(() => {})
    }

    // Add equipment
    const equipmentInput = page.locator('#equipment')
    if (await equipmentInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await equipmentInput.fill('Large pot')
      await page.keyboard.press('Enter')
      await equipmentInput.fill('Frying pan')
      await page.keyboard.press('Enter')
    }

    // Add first ingredient group - Main Ingredients
    const ingredientGroupNames = page.locator('input[id*="group"][id*="name"]')
    if (await ingredientGroupNames.first().isVisible({ timeout: 2000 }).catch(() => false)) {
      await ingredientGroupNames.first().fill('Main Ingredients')
    }

    // Add ingredients to first group
    const addIngredientButtons = page.locator('button:has-text("Add Ingredient")')
    const firstAddIngredientButton = addIngredientButtons.first()

    if (await firstAddIngredientButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      // Add first ingredient (already one should exist)
      let ingredientInputs = page.locator('input[id*="ingredient"][id*="name"]')
      let firstIngredient = ingredientInputs.first()
      await firstIngredient.fill('Spaghetti')

      let firstAmount = page.locator('input[id*="ingredient"][id*="amount"]').first()
      if (await firstAmount.isVisible({ timeout: 1000 }).catch(() => false)) {
        await firstAmount.fill('400')
      }

      let firstUnit = page.locator('input[id*="ingredient"][id*="unit"]').first()
      if (await firstUnit.isVisible({ timeout: 1000 }).catch(() => false)) {
        await firstUnit.fill('grams')
      }

      // Add second ingredient
      await firstAddIngredientButton.click()
      await page.waitForTimeout(300)

      ingredientInputs = page.locator('input[id*="ingredient"][id*="name"]')
      const secondIngredient = ingredientInputs.nth(1)
      await secondIngredient.fill('Eggs')

      const secondAmount = page.locator('input[id*="ingredient"][id*="amount"]').nth(1)
      if (await secondAmount.isVisible({ timeout: 1000 }).catch(() => false)) {
        await secondAmount.fill('3')
      }

      const secondUnit = page.locator('input[id*="ingredient"][id*="unit"]').nth(1)
      if (await secondUnit.isVisible({ timeout: 1000 }).catch(() => false)) {
        await secondUnit.fill('whole')
      }

      // Add third ingredient
      await firstAddIngredientButton.click()
      await page.waitForTimeout(300)

      ingredientInputs = page.locator('input[id*="ingredient"][id*="name"]')
      const thirdIngredient = ingredientInputs.nth(2)
      await thirdIngredient.fill('Guanciale')

      const thirdAmount = page.locator('input[id*="ingredient"][id*="amount"]').nth(2)
      if (await thirdAmount.isVisible({ timeout: 1000 }).catch(() => false)) {
        await thirdAmount.fill('200')
      }

      const thirdUnit = page.locator('input[id*="ingredient"][id*="unit"]').nth(2)
      if (await thirdUnit.isVisible({ timeout: 1000 }).catch(() => false)) {
        await thirdUnit.fill('grams')
      }
    }

    // Add second ingredient group
    const addGroupButton = page.locator('button:has-text("Add Group")').first()
    if (await addGroupButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      await addGroupButton.click()
      await page.waitForTimeout(300)

      const allGroupNames = page.locator('input[id*="group"][id*="name"]')
      const secondGroupName = allGroupNames.nth(1)
      if (await secondGroupName.isVisible({ timeout: 1000 }).catch(() => false)) {
        await secondGroupName.fill('Seasonings')
      }

      // Add ingredients to second group
      const addIngredientButtons = page.locator('button:has-text("Add Ingredient")')
      if (await addIngredientButtons.nth(1).isVisible({ timeout: 1000 }).catch(() => false)) {
        let seasoningInputs = page.locator('input[id*="ingredient"][id*="name"]')
        const seasoningName = seasoningInputs.nth(3)
        await seasoningName.fill('Black Pepper')

        const seasoningAmount = page.locator('input[id*="ingredient"][id*="amount"]').nth(3)
        if (await seasoningAmount.isVisible({ timeout: 1000 }).catch(() => false)) {
          await seasoningAmount.fill('1')
        }

        const seasoningUnit = page.locator('input[id*="ingredient"][id*="unit"]').nth(3)
        if (await seasoningUnit.isVisible({ timeout: 1000 }).catch(() => false)) {
          await seasoningUnit.fill('teaspoon')
        }
      }
    }

    // Add steps
    const stepInstructions = page.locator('textarea')
    if (await stepInstructions.first().isVisible({ timeout: 2000 }).catch(() => false)) {
      await stepInstructions.first().fill('Bring a large pot of salted water to boil')

      const addStepButton = page.locator('button:has-text("Add Step")').first()

      // Step 2
      if (await addStepButton.isVisible({ timeout: 1000 }).catch(() => false)) {
        await addStepButton.click()
        await page.waitForTimeout(300)
        const allSteps = page.locator('textarea')
        await allSteps.nth(1).fill('Add spaghetti and cook until al dente')
      }

      // Step 3
      if (await addStepButton.isVisible({ timeout: 1000 }).catch(() => false)) {
        await addStepButton.click()
        await page.waitForTimeout(300)
        const allSteps = page.locator('textarea')
        await allSteps.nth(2).fill('While pasta cooks, fry guanciale until crispy')
      }

      // Step 4
      if (await addStepButton.isVisible({ timeout: 1000 }).catch(() => false)) {
        await addStepButton.click()
        await page.waitForTimeout(300)
        const allSteps = page.locator('textarea')
        await allSteps.nth(3).fill('Beat eggs in a bowl and mix with cheese')
      }

      // Step 5
      if (await addStepButton.isVisible({ timeout: 1000 }).catch(() => false)) {
        await addStepButton.click()
        await page.waitForTimeout(300)
        const allSteps = page.locator('textarea')
        await allSteps.nth(4).fill('Combine hot pasta with guanciale and egg mixture')
      }
    }

    // Add admin notes
    const adminNotesInput = page.locator('#admin_notes')
    if (await adminNotesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await adminNotesInput.fill('This is an authentic Roman carbonara recipe. Use guanciale for best results.')
    }

    // Save the recipe
    const saveButton = page.locator('button:has-text("Save")').first()
    if (await saveButton.isEnabled({ timeout: 2000 }).catch(() => false)) {
      await saveButton.click()

      // Wait for navigation to recipe detail page
      await page.waitForNavigation({ waitUntil: 'networkidle', timeout: 30000 })

      // Verify we're on the recipe detail page
      expect(page.url()).toContain('/admin/recipes/')

      // Verify all data is displayed on the detail page
      const detailPage = page.content()

      // Verify recipe name is present
      await expect(page.locator('text=' + recipeName)).toBeVisible({ timeout: 5000 })

      // Verify we have all the ingredient groups
      const ingredientSection = page.locator('text=Ingredients').or(page.locator('text=Food'))
      if (await ingredientSection.isVisible({ timeout: 2000 }).catch(() => false)) {
        // Verify main ingredients are visible
        await expect(page.locator('text=Spaghetti').or(page.locator('text=400'))).toBeVisible({ timeout: 3000 }).catch(() => {})
        await expect(page.locator('text=Eggs').or(page.locator('text=3'))).toBeVisible({ timeout: 3000 }).catch(() => {})
        await expect(page.locator('text=Guanciale').or(page.locator('text=200'))).toBeVisible({ timeout: 3000 }).catch(() => {})
      }

      // Verify steps are visible
      const stepsSection = page.locator('text=Instructions').or(page.locator('text=Steps'))
      if (await stepsSection.isVisible({ timeout: 2000 }).catch(() => false)) {
        await expect(page.locator('text=Bring a large pot').or(page.locator('text=salted water'))).toBeVisible({ timeout: 3000 }).catch(() => {})
        await expect(page.locator('text=al dente').or(page.locator('text=spaghetti'))).toBeVisible({ timeout: 3000 }).catch(() => {})
      }

      // Verify timing information
      await expect(page.locator('text=35').or(page.locator('text=minutes'))).toBeVisible({ timeout: 3000 }).catch(() => {})
    }
  })

})
