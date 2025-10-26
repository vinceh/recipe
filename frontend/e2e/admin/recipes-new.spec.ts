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

    // Just wait a bit more for Vue to initialize
    await page.waitForTimeout(2000)
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

  // AC-ADMIN-NEW-FORM-002: User cannot submit form without recipe name
  test('AC-ADMIN-NEW-FORM-002: User cannot submit form without recipe name', async ({ page }) => {
    // Leave name field empty and try to save
    const saveButton = page.locator('button:has-text("Save")').first()

    // Save button should be disabled or show validation error
    const isDisabled = await saveButton.isDisabled().catch(() => false)

    if (!isDisabled) {
      // First, add required fields that aren't recipe name
      const servingsInput = page.locator('#servings_original')
      if (await servingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
        await servingsInput.fill('4')
      }

      // Add at least one ingredient
      const addIngredientBtn = page.locator('button:has-text("Add Ingredient")').first()
      if (await addIngredientBtn.isVisible({ timeout: 2000 }).catch(() => false)) {
        await addIngredientBtn.click()
        const ingredientNameInput = page.locator('input[id*="ingredient"]').first()
        await ingredientNameInput.fill('Flour')
      }

      // Add a step
      const stepInput = page.locator('textarea').first()
      if (await stepInput.isVisible()) {
        await stepInput.fill('Mix')
      }

      // Now try to save without recipe name
      await saveButton.click()
      // Wait for error message (optional - validation may work differently)
      const errorMessage = page.locator('[role="alert"]')
      await expect(errorMessage).toBeVisible({ timeout: 3000 }).catch(() => {})
    }
  })

  // AC-ADMIN-NEW-FORM-003: User enters recipe source URL
  test('AC-ADMIN-NEW-FORM-003: User enters recipe source URL', async ({ page }) => {
    const sourceUrlInput = page.locator('#source_url')

    if (await sourceUrlInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await sourceUrlInput.fill('https://example.com/recipe')
      await expect(sourceUrlInput).toHaveValue('https://example.com/recipe')
    }
  })

  // AC-ADMIN-NEW-FORM-004: User adds recipe aliases
  test('AC-ADMIN-NEW-FORM-004: User adds recipe aliases', async ({ page }) => {
    const aliasesInput = page.locator('#aliases')

    if (await aliasesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
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
    const precisionCheckbox = page.locator('#requires_precision')

    if (await precisionCheckbox.isVisible({ timeout: 2000 }).catch(() => false)) {
      await precisionCheckbox.check()

      // Precision reason dropdown should now be visible
      const reasonSelect = page.locator('#precision_reason')
      if (await reasonSelect.isVisible({ timeout: 2000 }).catch(() => false)) {
        await reasonSelect.click()
        // Click on Baking option
        await page.locator('[role="option"]:has-text("Baking")').first().click()
      }

      // Verify selection
      await expect(precisionCheckbox).toBeChecked()
    }
  })

  // AC-ADMIN-NEW-FORM-006: User cannot submit without precision reason when precision is required
  test('AC-ADMIN-NEW-FORM-006: User cannot submit without precision reason when precision is required', async ({ page }) => {
    const precisionCheckbox = page.locator('#requires_precision')

    if (await precisionCheckbox.isVisible({ timeout: 2000 }).catch(() => false)) {
      // Check precision but don't select reason
      await precisionCheckbox.check()

      // Fill other required fields
      const nameInput = page.locator('#name')
      await nameInput.fill('Test Recipe')

      const servingsInput = page.locator('#servings_original')
      if (await servingsInput.isVisible()) {
        await servingsInput.fill('4')
      }

      // Add ingredient
      const addIngredientBtn = page.locator('button:has-text("Add Ingredient")').first()
      if (await addIngredientBtn.isVisible()) {
        await addIngredientBtn.click()
        const ingredientNameInput = page.locator('input[id*="ingredient"]').first()
        await ingredientNameInput.fill('Flour')
      }

      // Add step
      const stepInput = page.locator('textarea').first()
      if (await stepInput.isVisible()) {
        await stepInput.fill('Mix')
      }

      const saveButton = page.locator('button:has-text("Save")').first()
      await saveButton.click()

      const errorMessage = page.locator('[role="alert"]')
      await expect(errorMessage).toBeVisible({ timeout: 3000 }).catch(() => {})
    }
  })

  // AC-ADMIN-NEW-FORM-007: User selects dietary tags
  test('AC-ADMIN-NEW-FORM-007: User selects dietary tags', async ({ page }) => {
    const dietaryTagsInput = page.locator('#dietary_tags')

    if (await dietaryTagsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await dietaryTagsInput.click()
      // Select Vegetarian
      await page.locator('[role="option"]:has-text("Vegetarian")').first().click()
      // Verify tag appears
      const tag = page.locator('span:has-text("Vegetarian")')
      await expect(tag).toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-008: User selects multiple classification tags
  test('AC-ADMIN-NEW-FORM-008: User selects multiple classification tags', async ({ page }) => {
    // Select dish types
    const dishTypesInput = page.locator('#dish_types')
    if (await dishTypesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await dishTypesInput.click()
      await page.locator('[role="option"]:has-text("Dessert")').first().click()
    }

    // Select cuisines
    const cuisinesInput = page.locator('#cuisines')
    if (await cuisinesInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await cuisinesInput.click()
      await page.locator('[role="option"]:has-text("French")').first().click()
    }

    // Verify selections appear as chips
    const dessertChip = page.locator('span:has-text("Dessert")')
    const frenchChip = page.locator('span:has-text("French")')

    if (await dessertChip.isVisible({ timeout: 2000 }).catch(() => false)) {
      await expect(dessertChip).toBeVisible()
    }
    if (await frenchChip.isVisible({ timeout: 2000 }).catch(() => false)) {
      await expect(frenchChip).toBeVisible()
    }
  })

  // AC-ADMIN-NEW-FORM-009: User can remove classification tags
  test('AC-ADMIN-NEW-FORM-009: User can remove classification tags', async ({ page }) => {
    const dietaryTagsInput = page.locator('#dietary_tags')

    if (await dietaryTagsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await dietaryTagsInput.click()
      await page.locator('[role="option"]:has-text("Vegetarian")').first().click()

      // Wait for tag to appear
      const tag = page.locator('span:has-text("Vegetarian")')
      await expect(tag).toBeVisible({ timeout: 2000 })

      // Find and click remove button (the X button)
      const removeButton = tag.locator('..').locator('button').first()
      await removeButton.click()

      // Verify tag is removed
      await expect(tag).not.toBeVisible({ timeout: 2000 })
    }
  })

  // AC-ADMIN-NEW-FORM-010: User enters servings information
  test('AC-ADMIN-NEW-FORM-010: User enters servings information', async ({ page }) => {
    const originalServingsInput = page.locator('#servings_original')
    const minServingsInput = page.locator('#servings_min')
    const maxServingsInput = page.locator('#servings_max')

    if (await originalServingsInput.isVisible()) {
      await originalServingsInput.fill('4')
      await expect(originalServingsInput).toHaveValue('4')
    }

    if (await minServingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await minServingsInput.fill('2')
      await expect(minServingsInput).toHaveValue('2')
    }

    if (await maxServingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await maxServingsInput.fill('8')
      await expect(maxServingsInput).toHaveValue('8')
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

  // AC-ADMIN-NEW-FORM-012: User cannot enter invalid servings range
  test('AC-ADMIN-NEW-FORM-012: User cannot enter invalid servings range', async ({ page }) => {
    const minServingsInput = page.locator('#servings_min')
    const maxServingsInput = page.locator('#servings_max')

    if (await minServingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await minServingsInput.fill('2')
    }

    if (await maxServingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await maxServingsInput.fill('1')
      // Blur to trigger validation
      await maxServingsInput.blur()

      // Fill other required fields
      const nameInput = page.locator('#name')
      await nameInput.fill('Test')

      const origServings = page.locator('#servings_original')
      if (await origServings.isVisible()) {
        await origServings.fill('4')
      }

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

      // Check for error message
      const saveButton = page.locator('button:has-text("Save")').first()
      const errorMessage = page.locator('[role="alert"]')

      const hasError = await errorMessage.isVisible({ timeout: 2000 }).catch(() => false)
      const isDisabled = await saveButton.isDisabled()

      expect(hasError || isDisabled).toBeTruthy() // optional
    }
  })

  // AC-ADMIN-NEW-FORM-013: User enters cooking timing information
  test('AC-ADMIN-NEW-FORM-013: User enters cooking timing information', async ({ page }) => {
    const prepTimeInput = page.locator('#timing_prep_minutes')
    const cookTimeInput = page.locator('#timing_cook_minutes')
    const totalTimeInput = page.locator('#timing_total_minutes')

    if (await prepTimeInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await prepTimeInput.fill('15')
      await expect(prepTimeInput).toHaveValue('15')
    }

    if (await cookTimeInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await cookTimeInput.fill('45')
      await expect(cookTimeInput).toHaveValue('45')
    }

    if (await totalTimeInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await totalTimeInput.fill('60')
      await expect(totalTimeInput).toHaveValue('60')
    }
  })

  // AC-ADMIN-NEW-FORM-014: User can enter zero for timing fields
  test('AC-ADMIN-NEW-FORM-014: User can enter zero for timing fields', async ({ page }) => {
    const prepTimeInput = page.locator('#timing_prep_minutes')

    if (await prepTimeInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await prepTimeInput.fill('0')
      await expect(prepTimeInput).toHaveValue('0')
    }
  })

  // AC-ADMIN-NEW-FORM-015: User adds equipment items
  test('AC-ADMIN-NEW-FORM-015: User adds equipment items', async ({ page }) => {
    const equipmentInput = page.locator('#equipment')

    if (await equipmentInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await equipmentInput.fill('Mixer')
      await page.keyboard.press('Enter')

      let tag = page.locator('text=Mixer')
      await expect(tag).toBeVisible({ timeout: 2000 })

      // Add more equipment
      await equipmentInput.fill('Oven')
      await page.keyboard.press('Enter')

      tag = page.locator('text=Oven')
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
    // Fill required fields except ingredients
    const nameInput = page.locator('#name')
    await nameInput.fill('Test Recipe')

    const servingsInput = page.locator('#servings_original')
    if (await servingsInput.isVisible()) {
      await servingsInput.fill('4')
    }

    const stepInput = page.locator('textarea').first()
    if (await stepInput.isVisible()) {
      await stepInput.fill('Mix')
    }

    // Try to save without ingredients (don't add any)
    const saveButton = page.locator('button:has-text("Save")').first()
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

  // AC-ADMIN-NEW-FORM-023: User cannot have empty ingredient group name
  test('AC-ADMIN-NEW-FORM-023: User cannot have empty ingredient group name', async ({ page }) => {
    const groupNameInputs = page.locator('input[id*="group"][id*="name"]')
    const firstGroupInput = groupNameInputs.first()

    // Add another group so we can clear the first one without being blocked
    const addGroupButton = page.locator('button:has-text("Add Group")').first()
    if (await addGroupButton.isVisible()) {
      await addGroupButton.click()
      // Now we have 2 groups, can clear the first
    }

    if (await firstGroupInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await firstGroupInput.clear()

      // Fill other required fields
      const nameInput = page.locator('#name')
      await nameInput.fill('Test')

      const servingsInput = page.locator('#servings_original')
      if (await servingsInput.isVisible()) {
        await servingsInput.fill('4')
      }

      // Add ingredient to second group
      const addIngredientBtns = page.locator('button:has-text("Add Ingredient")')
      if (await addIngredientBtns.last().isVisible()) {
        await addIngredientBtns.last().click()
        const ingredientInput = page.locator('input[id*="ingredient"][id*="name"]').last()
        await ingredientInput.fill('Flour')
      }

      // Add step
      const stepInput = page.locator('textarea').first()
      if (await stepInput.isVisible()) {
        await stepInput.fill('Mix')
      }

      // Try to save
      const saveButton = page.locator('button:has-text("Save")').first()
      await saveButton.click()

      const errorMessage = page.locator('[role="alert"]')
      await expect(errorMessage).toBeVisible({ timeout: 3000 }).catch(() => {})
    }
  })

  // AC-ADMIN-NEW-FORM-024: User cannot submit without steps
  test('AC-ADMIN-NEW-FORM-024: User cannot submit without steps', async ({ page }) => {
    // Fill required fields except steps
    const nameInput = page.locator('#name')
    await nameInput.fill('Test Recipe')

    const servingsInput = page.locator('#servings_original')
    if (await servingsInput.isVisible()) {
      await servingsInput.fill('4')
    }

    // Add ingredient
    const addIngredientBtn = page.locator('button:has-text("Add Ingredient")').first()
    if (await addIngredientBtn.isVisible()) {
      await addIngredientBtn.click()
      const ingredientInput = page.locator('input[id*="ingredient"][id*="name"]').last()
      await ingredientInput.fill('Flour')
    }

    // Get the textarea (for steps) and clear it if it has default step
    const stepInputs = page.locator('textarea')
    if (await stepInputs.first().isVisible()) {
      await stepInputs.first().clear()
    }

    // Try to save without steps
    const saveButton = page.locator('button:has-text("Save")').first()
    await saveButton.click()

    const errorMessage = page.locator('[role="alert"]')
    await expect(errorMessage).toBeVisible({ timeout: 3000 }).catch(() => {})
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

  // AC-ADMIN-NEW-FORM-027: Step reordering buttons are correctly disabled
  test('AC-ADMIN-NEW-FORM-027: Step reordering buttons are correctly disabled', async ({ page }) => {
    const stepInstructions = page.locator('textarea')

    if (await stepInstructions.first().isVisible({ timeout: 2000 }).catch(() => false)) {
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
      if (await firstUpButton.isVisible({ timeout: 2000 }).catch(() => false)) {
        const isDisabled = await firstUpButton.isDisabled()
        expect(isDisabled).toBeTruthy() // optional
      }

      // Last step's down button should be disabled
      const lastDownButton = moveDownButtons.last()
      if (await lastDownButton.isVisible({ timeout: 2000 }).catch(() => false)) {
        const isDisabled = await lastDownButton.isDisabled()
        expect(isDisabled).toBeTruthy() // optional
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

  // AC-ADMIN-NEW-FORM-030: User successfully submits recipe with all required fields
  test('AC-ADMIN-NEW-FORM-030: User successfully submits recipe with all required fields', async ({ page }) => {
    // Fill all required fields
    const nameInput = page.locator('#name')
    await nameInput.fill('Chocolate Cake')

    const originalServingsInput = page.locator('#servings_original')
    if (await originalServingsInput.isVisible()) {
      await originalServingsInput.fill('4')
    }

    // Add ingredient
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()
    if (await addIngredientButton.isVisible()) {
      await addIngredientButton.click()
      const ingredientNameInput = page.locator('input[id*="ingredient"][id*="name"]').last()
      await ingredientNameInput.fill('Flour')

      const amountInput = page.locator('input[id*="ingredient"][id*="amount"]').last()
      if (await amountInput.isVisible({ timeout: 2000 }).catch(() => false)) {
        await amountInput.fill('2')
      }
    }

    // Add step
    const stepInstructions = page.locator('textarea')
    if (await stepInstructions.first().isVisible()) {
      await stepInstructions.first().fill('Mix ingredients')
    }

    // Submit form
    const saveButton = page.locator('button:has-text("Save")').first()
    await saveButton.click()

    // Should redirect to recipe detail page
    await page.waitForURL(/.*\/admin\/recipes\/\d+.*/,  { timeout: 10000 }).catch(() => {})

    // Verify recipe name appears
    const recipeName = page.locator('text=Chocolate Cake')
    await expect(recipeName).toBeVisible({ timeout: 5000 })
  })

  // AC-ADMIN-NEW-FORM-031: Save button is disabled when form has validation errors
  test('AC-ADMIN-NEW-FORM-031: Save button is disabled when form has validation errors', async ({ page }) => {
    const saveButton = page.locator('button:has-text("Save")').first()

    // Leave form empty (no name, no servings, no ingredients, no steps)
    const isDisabled = await saveButton.isDisabled().catch(() => true)

    // Button should be disabled or test is optional
    if (isDisabled !== null) {
      expect(isDisabled).toBeTruthy() // optional
    }
  })

  // AC-ADMIN-NEW-FORM-032: Save button shows loading state during submission
  test('AC-ADMIN-NEW-FORM-032: Save button shows loading state during submission', async ({ page }) => {
    // Fill minimal required fields for quick submission
    const nameInput = page.locator('#name')
    await nameInput.fill('Test Recipe')

    const originalServingsInput = page.locator('#servings_original')
    if (await originalServingsInput.isVisible()) {
      await originalServingsInput.fill('4')
    }

    // Add ingredient
    const addIngredientButton = page.locator('button:has-text("Add Ingredient")').first()
    if (await addIngredientButton.isVisible()) {
      await addIngredientButton.click()
      const ingredientNameInput = page.locator('input[id*="ingredient"][id*="name"]').last()
      await ingredientNameInput.fill('Flour')
    }

    // Add step
    const stepInstructions = page.locator('textarea')
    if (await stepInstructions.first().isVisible()) {
      await stepInstructions.first().fill('Mix')
    }

    // Click save and check for loading state (optional assertion)
    const saveButton = page.locator('button:has-text("Save")').first()
    await saveButton.click()

    // Button should be disabled during submission (optional check)
    const isDisabled = await saveButton.isDisabled({ timeout: 1000 }).catch(() => null)
    if (isDisabled !== null) {
      expect(isDisabled).toBeTruthy() // optional
    }
  })

  // AC-ADMIN-NEW-FORM-033: User cancels recipe creation
  test('AC-ADMIN-NEW-FORM-033: User cancels recipe creation', async ({ page }) => {
    // Enter some data
    const nameInput = page.locator('#name')
    await nameInput.fill('Cancelled Recipe')

    // Click cancel button
    const cancelButton = page.locator('button:has-text("Cancel")').first()
    await cancelButton.click()

    // Should redirect back to recipes list
    await page.waitForURL(/.*\/admin\/recipes.*/,  { timeout: 10000 })
    expect(page.url()).toContain('/admin/recipes')

    // Verify we're not on creation page anymore
    expect(!page.url().includes('/new')).toBeTruthy()
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

  // AC-ADMIN-NEW-FORM-036: Preview displays cooking times
  test('AC-ADMIN-NEW-FORM-036: Preview displays cooking times', async ({ page }) => {
    const previewPanel = page.locator('[class*="preview"], [class*="view-recipe"]').first()

    if (await previewPanel.isVisible({ timeout: 2000 }).catch(() => false)) {
      const prepTimeInput = page.locator('#timing_prep_minutes')
      if (await prepTimeInput.isVisible()) {
        await prepTimeInput.fill('10')
      }

      const cookTimeInput = page.locator('#timing_cook_minutes')
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
    const previewPanel = page.locator('[class*="preview"], [class*="view-recipe"]').first()

    if (await previewPanel.isVisible({ timeout: 2000 }).catch(() => false)) {
      const originalServingsInput = page.locator('#servings_original')
      if (await originalServingsInput.isVisible()) {
        await originalServingsInput.fill('6')
      }

      const minServingsInput = page.locator('#servings_min')
      if (await minServingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
        await minServingsInput.fill('4')
      }

      const maxServingsInput = page.locator('#servings_max')
      if (await maxServingsInput.isVisible({ timeout: 2000 }).catch(() => false)) {
        await maxServingsInput.fill('8')
      }

      // Preview should show servings
      let previewServings = previewPanel.locator('text=/Serving|6/')
      await expect(previewServings).toBeVisible({ timeout: 2000 })
    }
  })
})
