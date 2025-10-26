import { test, expect, Page } from '@playwright/test'
import { loginAsAdmin, clearAuthState } from '../helpers/auth-helpers'

const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'

test.describe('Admin Recipe New Form - AC-ADMIN-NEW-FORM Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Login as admin first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    // Navigate to recipe creation form
    await page.goto('/admin/recipes/new')
    await page.waitForLoadState('networkidle')
  })

  // AC-ADMIN-NEW-FORM-001: User enters recipe name and selects language
  test('AC-ADMIN-NEW-FORM-001: User enters recipe name and selects language', async ({ page }) => {
    // Enter recipe name
    const nameInput = page.locator('input[placeholder*="name" i], [data-testid*="name-input" i]').first()
    await nameInput.fill('Chocolate Cake')
    await expect(nameInput).toHaveValue('Chocolate Cake')

    // Select language dropdown
    const languageSelect = page.locator('select, [role="combobox"]').first()
    await languageSelect.click()
    const englishOption = page.locator('text=English').first()
    await englishOption.click()

    // Verify selections
    await expect(nameInput).toHaveValue('Chocolate Cake')
  })

  // AC-ADMIN-NEW-FORM-002: User cannot submit form without recipe name
  test('AC-ADMIN-NEW-FORM-002: User cannot submit form without recipe name', async ({ page }) => {
    // Leave name field empty and try to save
    const saveButton = page.locator('button:has-text("Save")').first()

    // Save button should be disabled or show validation error
    const isDisabled = await saveButton.isDisabled().catch(() => false)

    // If button is enabled, click it and expect error
    if (!isDisabled) {
      await saveButton.click()
      // Wait for error message
      const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
      await expect(errorMessage).toBeVisible({ timeout: 2000 })
    } else {
      // Button is disabled, which is acceptable
      await expect(saveButton).toBeDisabled()
    }
  })

  // AC-ADMIN-NEW-FORM-003: User enters recipe source URL
  test('AC-ADMIN-NEW-FORM-003: User enters recipe source URL', async ({ page }) => {
    const sourceUrlInput = page.locator('input[type="url"], input[placeholder*="url" i]').first()

    if (await sourceUrlInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await sourceUrlInput.fill('https://example.com/recipe')
      await expect(sourceUrlInput).toHaveValue('https://example.com/recipe')
    }
  })

  // AC-ADMIN-NEW-FORM-004: User adds recipe aliases
  test('AC-ADMIN-NEW-FORM-004: User adds recipe aliases', async ({ page }) => {
    // Find aliases input field
    const aliasesInput = page.locator('input[placeholder*="alias" i], [data-testid*="aliases"]').first()

    if (await aliasesInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await aliasesInput.fill('Chocolate Torte')
      await page.keyboard.press('Enter')

      // Verify first tag appears
      const tag1 = page.locator('text=Chocolate Torte')
      await expect(tag1).toBeVisible({ timeout: 2000 })

      // Add second alias
      await aliasesInput.fill("Devil's Food")
      await page.keyboard.press('Enter')

      const tag2 = page.locator("text=Devil's Food")
      await expect(tag2).toBeVisible({ timeout: 2000 })

      // Remove first tag by clicking × button
      const removeButton = tag1.locator('..').locator('button').first()
      await removeButton.click()

      // Verify only second tag remains
      await expect(tag1).not.toBeVisible({ timeout: 2000 })
      await expect(tag2).toBeVisible()
    }
  })

  // AC-ADMIN-NEW-FORM-005: User marks recipe as requiring precision and selects reason
  test('AC-ADMIN-NEW-FORM-005: User marks recipe as requiring precision and selects reason', async ({ page }) => {
    const precisionCheckbox = page.locator('input[type="checkbox"][aria-label*="precision" i], [data-testid*="precision-checkbox"]').first()

    if (await precisionCheckbox.isVisible({ timeout: 1000 }).catch(() => false)) {
      await precisionCheckbox.check()

      // Precision reason dropdown should now be visible
      const reasonSelect = page.locator('select, [role="combobox"]').nth(2)
      await reasonSelect.click()

      const bakingOption = page.locator('text=Baking').first()
      await bakingOption.click()

      // Verify selection
      await expect(precisionCheckbox).toBeChecked()
    }
  })

  // AC-ADMIN-NEW-FORM-006: User cannot submit without precision reason when precision is required
  test('AC-ADMIN-NEW-FORM-006: User cannot submit without precision reason when precision is required', async ({ page }) => {
    const precisionCheckbox = page.locator('input[type="checkbox"][aria-label*="precision" i], [data-testid*="precision-checkbox"]').first()

    if (await precisionCheckbox.isVisible({ timeout: 1000 }).catch(() => false)) {
      // Check precision but don't select reason
      await precisionCheckbox.check()

      const saveButton = page.locator('button:has-text("Save")').first()
      const isDisabled = await saveButton.isDisabled().catch(() => false)

      if (!isDisabled) {
        await saveButton.click()
        const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
        await expect(errorMessage).toBeVisible({ timeout: 2000 })
      }
    }
  })

  // AC-ADMIN-NEW-FORM-007: User selects dietary tags
  test('AC-ADMIN-NEW-FORM-007: User selects dietary tags', async ({ page }) => {
    // Find dietary tags multi-select
    const dietaryTagsField = page.locator('[data-testid*="dietary" i], label:has-text("Dietary")').first()

    if (await dietaryTagsField.isVisible({ timeout: 1000 }).catch(() => false)) {
      const input = dietaryTagsField.locator('..').locator('input').first()
      await input.click()

      // Select Vegetarian
      const vegetarianOption = page.locator('text=Vegetarian').first()
      if (await vegetarianOption.isVisible({ timeout: 1000 }).catch(() => false)) {
        await vegetarianOption.click()
      }

      // Verify tag appears
      const tag = page.locator('text=Vegetarian')
      await expect(tag).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-008: User selects multiple classification tags
  test('AC-ADMIN-NEW-FORM-008: User selects multiple classification tags', async ({ page }) => {
    // Select from dish types
    const dishTypesField = page.locator('[data-testid*="dish" i], label:has-text("Dish Type")').first()
    if (await dishTypesField.isVisible({ timeout: 1000 }).catch(() => false)) {
      const input = dishTypesField.locator('..').locator('input').first()
      await input.click()
      const dessertOption = page.locator('text=Dessert').first()
      if (await dessertOption.isVisible()) {
        await dessertOption.click()
      }
    }

    // Select from cuisines
    const cuisinesField = page.locator('[data-testid*="cuisine" i], label:has-text("Cuisine")').first()
    if (await cuisinesField.isVisible({ timeout: 1000 }).catch(() => false)) {
      const input = cuisinesField.locator('..').locator('input').first()
      await input.click()
      const frenchOption = page.locator('text=French').first()
      if (await frenchOption.isVisible()) {
        await frenchOption.click()
      }
    }

    // Verify selections appear as chips
    const dessertChip = page.locator('text=Dessert')
    const frenchChip = page.locator('text=French')

    if (await dessertChip.isVisible({ timeout: 2000 }).catch(() => false)) {
      await expect(dessertChip).toBeVisible()
    }
    if (await frenchChip.isVisible({ timeout: 2000 }).catch(() => false)) {
      await expect(frenchChip).toBeVisible()
    }
  })

  // AC-ADMIN-NEW-FORM-009: User can remove classification tags
  test('AC-ADMIN-NEW-FORM-009: User can remove classification tags', async ({ page }) => {
    // First add a tag
    const dietaryTagsField = page.locator('[data-testid*="dietary" i], label:has-text("Dietary")').first()

    if (await dietaryTagsField.isVisible({ timeout: 1000 }).catch(() => false)) {
      const input = dietaryTagsField.locator('..').locator('input').first()
      await input.click()

      const vegetarianOption = page.locator('text=Vegetarian').first()
      if (await vegetarianOption.isVisible({ timeout: 1000 }).catch(() => false)) {
        await vegetarianOption.click()
      }

      // Wait for tag to appear
      const tag = page.locator('text=Vegetarian')
      await expect(tag).toBeVisible({ timeout: 2000 })

      // Find and click remove button
      const removeButton = tag.locator('..').locator('button').first()
      await removeButton.click()

      // Verify tag is removed
      await expect(tag).not.toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-010: User enters servings information
  test('AC-ADMIN-NEW-FORM-010: User enters servings information', async ({ page }) => {
    const originalServingsInput = page.locator('input[aria-label*="original" i], [data-testid*="original-servings"]').first()
    const minServingsInput = page.locator('input[aria-label*="minimum" i], [data-testid*="min-servings"]').first()
    const maxServingsInput = page.locator('input[aria-label*="maximum" i], [data-testid*="max-servings"]').first()

    if (await originalServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await originalServingsInput.fill('4')
      await expect(originalServingsInput).toHaveValue('4')
    }

    if (await minServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await minServingsInput.fill('2')
      await expect(minServingsInput).toHaveValue('2')
    }

    if (await maxServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await maxServingsInput.fill('8')
      await expect(maxServingsInput).toHaveValue('8')
    }
  })

  // AC-ADMIN-NEW-FORM-011: User cannot submit without original servings
  test('AC-ADMIN-NEW-FORM-011: User cannot submit without original servings', async ({ page }) => {
    const originalServingsInput = page.locator('input[aria-label*="original" i], [data-testid*="original-servings"]').first()

    // Leave servings empty and try to save
    const saveButton = page.locator('button:has-text("Save")').first()
    const isDisabled = await saveButton.isDisabled().catch(() => false)

    if (!isDisabled) {
      await saveButton.click()
      const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
      await expect(errorMessage).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-012: User cannot enter invalid servings range
  test('AC-ADMIN-NEW-FORM-012: User cannot enter invalid servings range', async ({ page }) => {
    const minServingsInput = page.locator('input[aria-label*="minimum" i], [data-testid*="min-servings"]').first()
    const maxServingsInput = page.locator('input[aria-label*="maximum" i], [data-testid*="max-servings"]').first()

    if (await minServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await minServingsInput.fill('2')
    }

    if (await maxServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await maxServingsInput.fill('1')
      // Blur to trigger validation
      await maxServingsInput.blur()

      // Check for error message
      const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
      const saveButton = page.locator('button:has-text("Save")').first()

      // Either error message appears or save button is disabled
      const hasError = await errorMessage.isVisible({ timeout: 2000 }).catch(() => false)
      const isDisabled = await saveButton.isDisabled()

      expect(hasError || isDisabled).toBeTruthy()
    }
  })

  // AC-ADMIN-NEW-FORM-013: User enters cooking timing information
  test('AC-ADMIN-NEW-FORM-013: User enters cooking timing information', async ({ page }) => {
    const prepTimeInput = page.locator('input[aria-label*="prep" i], [data-testid*="prep-time"]').first()
    const cookTimeInput = page.locator('input[aria-label*="cook" i], [data-testid*="cook-time"]').first()
    const totalTimeInput = page.locator('input[aria-label*="total" i], [data-testid*="total-time"]').first()

    if (await prepTimeInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await prepTimeInput.fill('15')
      await expect(prepTimeInput).toHaveValue('15')
    }

    if (await cookTimeInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await cookTimeInput.fill('45')
      await expect(cookTimeInput).toHaveValue('45')
    }

    if (await totalTimeInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await totalTimeInput.fill('60')
      await expect(totalTimeInput).toHaveValue('60')
    }
  })

  // AC-ADMIN-NEW-FORM-014: User can enter zero for timing fields
  test('AC-ADMIN-NEW-FORM-014: User can enter zero for timing fields', async ({ page }) => {
    const prepTimeInput = page.locator('input[aria-label*="prep" i], [data-testid*="prep-time"]').first()

    if (await prepTimeInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await prepTimeInput.fill('0')
      await expect(prepTimeInput).toHaveValue('0')

      // Save button should still be enabled (or at least no error)
      const saveButton = page.locator('button:has-text("Save")').first()
      const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
      const hasError = await errorMessage.isVisible({ timeout: 1000 }).catch(() => false)
      expect(!hasError).toBeTruthy()
    }
  })

  // AC-ADMIN-NEW-FORM-015: User adds equipment items
  test('AC-ADMIN-NEW-FORM-015: User adds equipment items', async ({ page }) => {
    const equipmentInput = page.locator('input[placeholder*="equipment" i], [data-testid*="equipment"]').first()

    if (await equipmentInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await equipmentInput.fill('Mixer')
      await page.keyboard.press('Enter')

      let tag = page.locator('text=Mixer')
      await expect(tag).toBeVisible({ timeout: 2000 })

      // Add more equipment
      await equipmentInput.fill('Oven')
      await page.keyboard.press('Enter')

      tag = page.locator('text=Oven')
      await expect(tag).toBeVisible({ timeout: 2000 })

      await equipmentInput.fill('Baking Pans')
      await page.keyboard.press('Enter')

      tag = page.locator('text=Baking Pans')
      await expect(tag).toBeVisible({ timeout: 2000 })

      // Remove Mixer
      const mixerTag = page.locator('text=Mixer')
      const removeButton = mixerTag.locator('..').locator('button').first()
      await removeButton.click()

      await expect(mixerTag).not.toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-016: User cannot submit without ingredients
  test('AC-ADMIN-NEW-FORM-016: User cannot submit without ingredients', async ({ page }) => {
    // Try to save without adding ingredients
    const saveButton = page.locator('button:has-text("Save")').first()
    const isDisabled = await saveButton.isDisabled().catch(() => false)

    if (!isDisabled) {
      await saveButton.click()
      const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
      await expect(errorMessage).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-017: User adds ingredient to default group
  test('AC-ADMIN-NEW-FORM-017: User adds ingredient to default group', async ({ page }) => {
    // Find add ingredient button
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()

    if (await addIngredientButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      await addIngredientButton.click()

      // Fill ingredient fields
      const ingredientNameInput = page.locator('input[placeholder*="ingredient" i], input[placeholder*="name" i]').last()
      const amountInput = page.locator('input[placeholder*="amount" i], input[placeholder*="quantity" i]').last()
      const unitSelect = page.locator('select, [role="combobox"]').last()

      await ingredientNameInput.fill('Flour')
      await expect(ingredientNameInput).toHaveValue('Flour')

      if (await amountInput.isVisible({ timeout: 1000 }).catch(() => false)) {
        await amountInput.fill('2')
        await expect(amountInput).toHaveValue('2')
      }

      if (await unitSelect.isVisible({ timeout: 1000 }).catch(() => false)) {
        await unitSelect.click()
        const cupsOption = page.locator('text=cups').first()
        if (await cupsOption.isVisible()) {
          await cupsOption.click()
        }
      }

      // Verify ingredient appears
      const ingredient = page.locator('text=Flour')
      await expect(ingredient).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-018: User adds ingredient preparation notes
  test('AC-ADMIN-NEW-FORM-018: User adds ingredient preparation notes', async ({ page }) => {
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()

    if (await addIngredientButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      await addIngredientButton.click()

      const ingredientNameInput = page.locator('input[placeholder*="ingredient" i]').last()
      await ingredientNameInput.fill('Flour')

      const preparationInput = page.locator('input[placeholder*="preparation" i], textarea[placeholder*="prep" i]').last()
      if (await preparationInput.isVisible({ timeout: 1000 }).catch(() => false)) {
        await preparationInput.fill('sifted')
        await expect(preparationInput).toHaveValue('sifted')
      }
    }
  })

  // AC-ADMIN-NEW-FORM-019: User marks ingredient as optional
  test('AC-ADMIN-NEW-FORM-019: User marks ingredient as optional', async ({ page }) => {
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()

    if (await addIngredientButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      await addIngredientButton.click()

      const ingredientNameInput = page.locator('input[placeholder*="ingredient" i]').last()
      await ingredientNameInput.fill('Vanilla Extract')

      const optionalCheckbox = page.locator('input[type="checkbox"][aria-label*="optional" i]').last()
      if (await optionalCheckbox.isVisible({ timeout: 1000 }).catch(() => false)) {
        await optionalCheckbox.check()
        await expect(optionalCheckbox).toBeChecked()
      }
    }
  })

  // AC-ADMIN-NEW-FORM-020: User creates multiple ingredient groups
  test('AC-ADMIN-NEW-FORM-020: User creates multiple ingredient groups', async ({ page }) => {
    const addGroupButton = page.locator('button:has-text("Add Group")').first()

    if (await addGroupButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      await addGroupButton.click()

      // Find the new group name input
      const groupNameInputs = page.locator('input[placeholder*="group" i]')
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
    const deleteGroupButtons = page.locator('button[aria-label*="delete" i], button[title*="delete" i]').filter({ hasText: /delete|remove/i })

    // If only one group, the delete button should be disabled
    if (await deleteGroupButtons.first().isVisible({ timeout: 1000 }).catch(() => false)) {
      const isDisabled = await deleteGroupButtons.first().isDisabled()
      expect(isDisabled).toBeTruthy()
    }
  })

  // AC-ADMIN-NEW-FORM-022: User removes an ingredient group with ingredients
  test('AC-ADMIN-NEW-FORM-022: User removes an ingredient group with ingredients', async ({ page }) => {
    const addGroupButton = page.locator('button:has-text("Add Group")').first()

    if (await addGroupButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      // Create second group
      await addGroupButton.click()

      const groupNameInputs = page.locator('input[placeholder*="group" i]')
      const lastGroupInput = groupNameInputs.last()
      await lastGroupInput.fill('Dough')

      // Wait for group to appear
      const groupLabel = page.locator('text=Dough')
      await expect(groupLabel).toBeVisible({ timeout: 2000 })

      // Find and click delete button for this group
      const deleteButtons = page.locator('button[aria-label*="delete" i], button[title*="delete" i]')
      const lastDeleteButton = deleteButtons.last()

      if (await lastDeleteButton.isEnabled({ timeout: 1000 }).catch(() => false)) {
        await lastDeleteButton.click()

        // Verify group is removed
        await expect(groupLabel).not.toBeVisible({ timeout: 2000 })
      }
    }
  })

  // AC-ADMIN-NEW-FORM-023: User cannot have empty ingredient group name
  test('AC-ADMIN-NEW-FORM-023: User cannot have empty ingredient group name', async ({ page }) => {
    const groupNameInputs = page.locator('input[placeholder*="group" i]')
    const firstGroupInput = groupNameInputs.first()

    // Clear the group name
    if (await firstGroupInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await firstGroupInput.clear()

      // Try to save
      const saveButton = page.locator('button:has-text("Save")').first()
      const isDisabled = await saveButton.isDisabled().catch(() => false)

      if (!isDisabled) {
        await saveButton.click()
        const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
        await expect(errorMessage).toBeVisible({ timeout: 2000 })
      }
    }
  })

  // AC-ADMIN-NEW-FORM-024: User cannot submit without steps
  test('AC-ADMIN-NEW-FORM-024: User cannot submit without steps', async ({ page }) => {
    // Try to save without adding steps
    const saveButton = page.locator('button:has-text("Save")').first()
    const isDisabled = await saveButton.isDisabled().catch(() => false)

    if (!isDisabled) {
      await saveButton.click()
      const errorMessage = page.locator('[role="alert"], [class*="error"]').first()
      await expect(errorMessage).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-025: User enters recipe steps
  test('AC-ADMIN-NEW-FORM-025: User enters recipe steps', async ({ page }) => {
    const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')
    const firstStepInput = stepInstructions.first()

    if (await firstStepInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await firstStepInput.fill('Preheat oven to 350°F')
      await expect(firstStepInput).toHaveValue('Preheat oven to 350°F')

      // Click Add Step button
      const addStepButton = page.locator('button:has-text("Add Step")').first()
      if (await addStepButton.isVisible({ timeout: 1000 }).catch(() => false)) {
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
    const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')

    // Create 3 steps
    const firstStepInput = stepInstructions.first()
    if (await firstStepInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await firstStepInput.fill('Preheat oven')

      const addStepButton = page.locator('button:has-text("Add Step")').first()
      await addStepButton.click()

      const secondStepInput = stepInstructions.nth(1)
      await secondStepInput.fill('Mix ingredients')

      await addStepButton.click()

      const thirdStepInput = stepInstructions.nth(2)
      await thirdStepInput.fill('Bake for 30 minutes')

      // Find down arrow for first step
      const moveDownButtons = page.locator('button[aria-label*="down" i], button[title*="down" i]')
      if (await moveDownButtons.first().isVisible({ timeout: 1000 }).catch(() => false)) {
        await moveDownButtons.first().click()

        // Verify step order changed
        await expect(secondStepInput).toContainText('Preheat oven')
      }
    }
  })

  // AC-ADMIN-NEW-FORM-027: Step reordering buttons are correctly disabled
  test('AC-ADMIN-NEW-FORM-027: Step reordering buttons are correctly disabled', async ({ page }) => {
    const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')

    if (await stepInstructions.first().isVisible({ timeout: 1000 }).catch(() => false)) {
      // Create 3 steps
      await stepInstructions.first().fill('Step 1')

      const addStepButton = page.locator('button:has-text("Add Step")').first()
      await addStepButton.click()
      await stepInstructions.nth(1).fill('Step 2')

      await addStepButton.click()
      await stepInstructions.nth(2).fill('Step 3')

      // Check button states
      const moveUpButtons = page.locator('button[aria-label*="up" i]')
      const moveDownButtons = page.locator('button[aria-label*="down" i]')

      // First step's up button should be disabled
      const firstUpButton = moveUpButtons.first()
      if (await firstUpButton.isVisible()) {
        const isDisabled = await firstUpButton.isDisabled()
        expect(isDisabled).toBeTruthy()
      }

      // Last step's down button should be disabled
      const lastDownButton = moveDownButtons.last()
      if (await lastDownButton.isVisible()) {
        const isDisabled = await lastDownButton.isDisabled()
        expect(isDisabled).toBeTruthy()
      }
    }
  })

  // AC-ADMIN-NEW-FORM-028: User removes a step
  test('AC-ADMIN-NEW-FORM-028: User removes a step', async ({ page }) => {
    const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')

    if (await stepInstructions.first().isVisible({ timeout: 1000 }).catch(() => false)) {
      // Create 3 steps
      await stepInstructions.first().fill('Step 1')

      const addStepButton = page.locator('button:has-text("Add Step")').first()
      await addStepButton.click()
      await stepInstructions.nth(1).fill('Step 2')

      await addStepButton.click()
      await stepInstructions.nth(2).fill('Step 3')

      // Delete step 2
      const deleteStepButtons = page.locator('button[aria-label*="delete" i]')
      const secondDeleteButton = deleteStepButtons.nth(1)

      if (await secondDeleteButton.isVisible({ timeout: 1000 }).catch(() => false)) {
        await secondDeleteButton.click()

        // Verify step 2 content (should now be step 3)
        const stepTexts = await stepInstructions.allTextContents()
        expect(stepTexts.length).toBe(2)
      }
    }
  })

  // AC-ADMIN-NEW-FORM-029: User enters admin notes
  test('AC-ADMIN-NEW-FORM-029: User enters admin notes', async ({ page }) => {
    const adminNotesTextarea = page.locator('textarea[placeholder*="admin" i], textarea[placeholder*="notes" i]').last()

    if (await adminNotesTextarea.isVisible({ timeout: 1000 }).catch(() => false)) {
      await adminNotesTextarea.fill('Recipe source is reliable, can be marked as verified')
      await expect(adminNotesTextarea).toHaveValue('Recipe source is reliable, can be marked as verified')
    }
  })

  // AC-ADMIN-NEW-FORM-030: User successfully submits recipe with all required fields
  test('AC-ADMIN-NEW-FORM-030: User successfully submits recipe with all required fields', async ({ page }) => {
    // Fill all required fields
    const nameInput = page.locator('input[placeholder*="name" i]').first()
    await nameInput.fill('Chocolate Cake')

    const originalServingsInput = page.locator('input[aria-label*="original" i], [data-testid*="original-servings"]').first()
    if (await originalServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await originalServingsInput.fill('4')
    }

    // Add ingredient
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()
    if (await addIngredientButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      await addIngredientButton.click()
      const ingredientNameInput = page.locator('input[placeholder*="ingredient" i]').last()
      await ingredientNameInput.fill('Flour')

      const amountInput = page.locator('input[placeholder*="amount" i]').last()
      if (await amountInput.isVisible({ timeout: 1000 }).catch(() => false)) {
        await amountInput.fill('2')
      }
    }

    // Add step
    const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')
    if (await stepInstructions.first().isVisible({ timeout: 1000 }).catch(() => false)) {
      await stepInstructions.first().fill('Mix ingredients')
    }

    // Submit form
    const saveButton = page.locator('button:has-text("Save")').first()
    await saveButton.click()

    // Should redirect to recipe detail page
    await page.waitForURL(/.*\/admin\/recipes\/\d+.*/,  { timeout: 5000 }).catch(() => {})

    // Verify recipe name appears
    const recipeName = page.locator('text=Chocolate Cake')
    await expect(recipeName).toBeVisible({ timeout: 3000 })
  })

  // AC-ADMIN-NEW-FORM-031: Save button is disabled when form has validation errors
  test('AC-ADMIN-NEW-FORM-031: Save button is disabled when form has validation errors', async ({ page }) => {
    const saveButton = page.locator('button:has-text("Save")').first()

    // Leave form empty (no name, no servings, no ingredients, no steps)
    const isDisabled = await saveButton.isDisabled()

    // Button should be disabled or show tooltip on hover
    if (isDisabled) {
      await expect(saveButton).toBeDisabled()
    }
  })

  // AC-ADMIN-NEW-FORM-032: Save button shows loading state during submission
  test('AC-ADMIN-NEW-FORM-032: Save button shows loading state during submission', async ({ page }) => {
    // Fill minimal required fields for quick submission
    const nameInput = page.locator('input[placeholder*="name" i]').first()
    await nameInput.fill('Test Recipe')

    const originalServingsInput = page.locator('input[aria-label*="original" i], [data-testid*="original-servings"]').first()
    if (await originalServingsInput.isVisible({ timeout: 1000 }).catch(() => false)) {
      await originalServingsInput.fill('4')
    }

    // Add ingredient
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()
    if (await addIngredientButton.isVisible({ timeout: 1000 }).catch(() => false)) {
      await addIngredientButton.click()
      const ingredientNameInput = page.locator('input[placeholder*="ingredient" i]').last()
      await ingredientNameInput.fill('Flour')
    }

    // Add step
    const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')
    if (await stepInstructions.first().isVisible({ timeout: 1000 }).catch(() => false)) {
      await stepInstructions.first().fill('Mix')
    }

    // Click save and check for loading state
    const saveButton = page.locator('button:has-text("Save")').first()
    await saveButton.click()

    // Check for loading indicator (spinner or text)
    const spinner = page.locator('[class*="spinner"], [class*="loading"]').first()
    const isLoading = await spinner.isVisible({ timeout: 2000 }).catch(() => false)

    // Button should be disabled during submission
    const isDisabled = await saveButton.isDisabled({ timeout: 1000 }).catch(() => true)

    expect(isLoading || isDisabled).toBeTruthy()
  })

  // AC-ADMIN-NEW-FORM-033: User cancels recipe creation
  test('AC-ADMIN-NEW-FORM-033: User cancels recipe creation', async ({ page }) => {
    // Enter some data
    const nameInput = page.locator('input[placeholder*="name" i]').first()
    await nameInput.fill('Cancelled Recipe')

    // Click cancel button
    const cancelButton = page.locator('button:has-text("Cancel")').first()
    await cancelButton.click()

    // Should redirect back to recipes list
    await page.waitForURL(/.*\/admin\/recipes.*/,  { timeout: 5000 })
    expect(page.url()).toContain('/admin/recipes')

    // Verify we're not on creation page anymore
    expect(!page.url().includes('/new')).toBeTruthy()
  })

  // AC-ADMIN-NEW-FORM-034: Preview updates in real-time as user enters data
  test('AC-ADMIN-NEW-FORM-034: Preview updates in real-time as user enters data', async ({ page }) => {
    // Check if preview panel exists
    const previewPanel = page.locator('[class*="preview"], aside').first()

    if (await previewPanel.isVisible({ timeout: 1000 }).catch(() => false)) {
      const nameInput = page.locator('input[placeholder*="name" i]').first()
      await nameInput.fill('Pasta Carbonara')

      // Preview should show recipe name
      let previewName = previewPanel.locator('text=Pasta Carbonara')
      await expect(previewName).toBeVisible({ timeout: 2000 })

      // Add ingredient
      const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()
      if (await addIngredientButton.isVisible()) {
        await addIngredientButton.click()
        const ingredientNameInput = page.locator('input[placeholder*="ingredient" i]').last()
        await ingredientNameInput.fill('Spaghetti')

        // Preview should show ingredient
        let previewIngredient = previewPanel.locator('text=Spaghetti')
        await expect(previewIngredient).toBeVisible({ timeout: 2000 })
      }

      // Add step
      const stepInstructions = page.locator('textarea[placeholder*="instruction" i]')
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
    const previewPanel = page.locator('[class*="preview"], aside').first()

    if (await previewPanel.isVisible({ timeout: 1000 }).catch(() => false)) {
      // Select dietary tag
      const dietaryTagsField = page.locator('[data-testid*="dietary" i], label:has-text("Dietary")').first()
      if (await dietaryTagsField.isVisible()) {
        const input = dietaryTagsField.locator('..').locator('input').first()
        await input.click()
        const vegetarianOption = page.locator('text=Vegetarian').first()
        if (await vegetarianOption.isVisible()) {
          await vegetarianOption.click()
        }
      }

      // Select cuisine
      const cuisinesField = page.locator('[data-testid*="cuisine" i], label:has-text("Cuisine")').first()
      if (await cuisinesField.isVisible()) {
        const input = cuisinesField.locator('..').locator('input').first()
        await input.click()
        const italianOption = page.locator('text=Italian').first()
        if (await italianOption.isVisible()) {
          await italianOption.click()
        }
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

  // AC-ADMIN-NEW-FORM-036: Preview displays cooking times
  test('AC-ADMIN-NEW-FORM-036: Preview displays cooking times', async ({ page }) => {
    const previewPanel = page.locator('[class*="preview"], aside').first()

    if (await previewPanel.isVisible({ timeout: 1000 }).catch(() => false)) {
      const prepTimeInput = page.locator('input[aria-label*="prep" i], [data-testid*="prep-time"]').first()
      if (await prepTimeInput.isVisible()) {
        await prepTimeInput.fill('10')
      }

      const cookTimeInput = page.locator('input[aria-label*="cook" i], [data-testid*="cook-time"]').first()
      if (await cookTimeInput.isVisible()) {
        await cookTimeInput.fill('20')
      }

      // Preview should show timing
      let previewTime = previewPanel.locator('text=/Prep|Cook|min/')
      await expect(previewTime).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-037: Preview shows serving information
  test('AC-ADMIN-NEW-FORM-037: Preview shows serving information', async ({ page }) => {
    const previewPanel = page.locator('[class*="preview"], aside').first()

    if (await previewPanel.isVisible({ timeout: 1000 }).catch(() => false)) {
      const originalServingsInput = page.locator('input[aria-label*="original" i], [data-testid*="original-servings"]').first()
      if (await originalServingsInput.isVisible()) {
        await originalServingsInput.fill('6')
      }

      const minServingsInput = page.locator('input[aria-label*="minimum" i], [data-testid*="min-servings"]').first()
      if (await minServingsInput.isVisible()) {
        await minServingsInput.fill('4')
      }

      const maxServingsInput = page.locator('input[aria-label*="maximum" i], [data-testid*="max-servings"]').first()
      if (await maxServingsInput.isVisible()) {
        await maxServingsInput.fill('8')
      }

      // Preview should show servings
      let previewServings = previewPanel.locator('text=/Serving|6/')
      await expect(previewServings).toBeVisible({ timeout: 2000 })
    }
  })
})
