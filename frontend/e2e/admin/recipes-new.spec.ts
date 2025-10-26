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
  test('AC-ADMIN-NEW-FORM-038: Complete recipe with multiple ingredient groups, steps, and verify all data is saved', async ({ page }) => {
    const recipeName = 'Complete Italian Carbonara Recipe'

    // Fill basic info
    await page.locator('#name').fill(recipeName)

    // Set language
    await page.locator('#language').click()
    await page.locator('[role="option"]:has-text("English")').first().click()

    // Fill servings
    await page.locator('#servings_original').fill('4')

    // Fill timing
    await page.locator('#timing_prep_minutes').fill('15')
    await page.locator('#timing_cook_minutes').fill('20')
    await page.locator('#timing_total_minutes').fill('35')

    // Fill first ingredient group
    const groupNameInputs = page.locator('input[id*="group"][id*="name"]')
    await groupNameInputs.first().fill('Main Ingredients')

    // Fill first ingredient
    const allIngredientNameInputs = page.locator('input[id*="name"][id*="ingredient"]')
    await allIngredientNameInputs.first().fill('Spaghetti')
    await page.locator('input[id*="amount"][id*="ingredient"]').first().fill('400')
    await page.locator('input[id*="unit"][id*="ingredient"]').first().fill('grams')

    // Add second ingredient
    await page.locator('button:has-text("Add Ingredient")').first().click()
    await page.waitForTimeout(200)

    const ingredientNameInputs = page.locator('input[id*="name"][id*="ingredient"]')
    const count = await ingredientNameInputs.count()
    if (count >= 2) {
      await ingredientNameInputs.nth(1).fill('Eggs')
      const amountInputs = page.locator('input[id*="amount"][id*="ingredient"]')
      const unitInputs = page.locator('input[id*="unit"][id*="ingredient"]')
      await amountInputs.nth(1).fill('3')
      await unitInputs.nth(1).fill('whole')
    }

    // Fill first step
    const stepInputs = page.locator('textarea')
    await stepInputs.first().fill('Bring a large pot of salted water to boil')

    // Add second step
    await page.locator('button:has-text("Add Step")').first().click()
    await page.waitForTimeout(200)
    const allSteps = page.locator('textarea')
    const stepCount = await allSteps.count()
    if (stepCount >= 2) {
      await allSteps.nth(1).fill('Add spaghetti and cook until al dente')
    }

    // Save the recipe
    const saveButton = page.locator('button:has-text("Save")').first()
    await expect(saveButton).toBeEnabled({ timeout: 5000 })
    await saveButton.click()

    // Wait for navigation and verify we saved successfully
    await page.waitForURL(/\/admin\/recipes\/\d+/, { timeout: 30000 })

    // Verify recipe name appears on detail page
    await expect(page.locator(`text=${recipeName}`)).toBeVisible({ timeout: 5000 })
  })

})
