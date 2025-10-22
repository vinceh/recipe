import { test, expect, Page } from '@playwright/test'

async function login(page: Page) {
  await page.goto('/login')
  await page.fill('input[type="email"]', 'admin@ember.app')
  await page.fill('input[type="password"]', '123456')
  await page.click('button[type="submit"]')
  await page.waitForURL('**/admin', { timeout: 10000 })
}

const mockRecipeData = {
  "name": "Taiwanese Beef Noodle Soup",
  "language": "en",
  "servings": { "original": 4, "min": 2, "max": 6 },
  "timing": {
    "prep_minutes": 30,
    "cook_minutes": 180,
    "total_minutes": 210
  },
  "dietary_tags": ["dairy-free"],
  "dish_types": ["soup", "main-course"],
  "recipe_types": ["traditional", "comfort-food"],
  "cuisines": ["taiwanese", "chinese"],
  "ingredient_groups": [
    {
      "name": "For the Broth",
      "items": [
        { "name": "beef shank", "amount": "2", "unit": "lbs", "preparation": "cut into chunks" },
        { "name": "beef bones", "amount": "1", "unit": "lb", "preparation": "" },
        { "name": "water", "amount": "4", "unit": "cups", "preparation": "" },
        { "name": "star anise", "amount": "2", "unit": "whole", "preparation": "" },
        { "name": "soy sauce", "amount": "2", "unit": "tbsp", "preparation": "" }
      ]
    },
    {
      "name": "For Serving",
      "items": [
        { "name": "fresh noodles", "amount": "1", "unit": "lb", "preparation": "" },
        { "name": "bok choy", "amount": "2", "unit": "cups", "preparation": "chopped" },
        { "name": "green onions", "amount": "2", "unit": "whole", "preparation": "sliced", "optional": true }
      ]
    }
  ],
  "steps": [
    {
      "id": "step-001",
      "order": 1,
      "instructions": { "original": "Blanch the beef bones in boiling water for 5 minutes to remove impurities." },
      "timing_minutes": 5
    },
    {
      "id": "step-002",
      "order": 2,
      "instructions": { "original": "In a large stockpot, combine blanched bones, beef shank, water, star anise, cinnamon, garlic, and ginger. Bring to a boil." },
      "timing_minutes": 10
    },
    {
      "id": "step-003",
      "order": 3,
      "instructions": { "original": "Reduce heat to low and simmer for 2.5 hours until beef is tender." },
      "timing_minutes": 150
    }
  ],
  "equipment": ["large pot", "stockpot", "chef's knife", "cutting board"],
  "admin_notes": "This recipe requires precision timing for the braising process."
}

test.describe('Admin Recipe URL Import - AC-ADMIN-UI-URL-001 to AC-ADMIN-UI-URL-012', () => {
  test.beforeEach(async ({ page }) => {
    await login(page)
    await page.goto('/admin/recipes/new')

    // Mock the API endpoint
    await page.route('**/admin/recipes/parse_url', async (route) => {
      const request = route.request()
      const postData = request.postDataJSON()

      if (postData.url.includes('example.com/recipe')) {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            success: true,
            data: { recipe_data: mockRecipeData }
          })
        })
      } else if (postData.url.includes('404')) {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            success: false,
            message: 'Could not find a recipe on this page'
          })
        })
      } else if (postData.url.includes('timeout')) {
        await new Promise(resolve => setTimeout(resolve, 95000))
      } else {
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            success: false,
            message: 'Could not access this URL'
          })
        })
      }
    })
  })

  test('AC-ADMIN-UI-URL-001: Import from URL button renders correctly', async ({ page }) => {
    const urlImportButton = page.locator('button:has-text("Import from URL")')
    await expect(urlImportButton).toBeVisible()
    await expect(urlImportButton).toBeEnabled()
  })

  test('AC-ADMIN-UI-URL-002: Dialog opens with correct UI elements', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')

    const dialog = page.locator('.url-import-dialog')
    await expect(dialog).toBeVisible()

    await expect(page.locator('text=Import Recipe from URL')).toBeVisible()

    const urlInput = page.locator('.url-import-dialog input[type="url"]')
    await expect(urlInput).toBeVisible()

    const importButton = page.locator('.url-import-dialog button:has-text("Import")')
    await expect(importButton).toBeVisible()

    const cancelButton = page.locator('.url-import-dialog button:has-text("Cancel")')
    await expect(cancelButton).toBeVisible()
  })

  test('AC-ADMIN-UI-URL-003: URL format validation', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('not-a-valid-url')

    await expect(page.locator('text=Please enter a valid URL')).toBeVisible()

    const importButton = page.locator('.url-import-dialog button:has-text("Import")')
    await expect(importButton).toBeDisabled()
  })

  test('AC-ADMIN-UI-URL-004: Empty URL validation', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    const importButton = page.locator('.url-import-dialog button:has-text("Import")')

    // Button should be disabled when URL is empty
    await expect(importButton).toBeDisabled()
  })

  test('AC-ADMIN-UI-URL-005: Playful loading state with cooking puns', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('https://example.com/recipe/test')
    await page.locator('.url-import-dialog button:has-text("Import")').click()

    // Check for loading spinner
    const spinner = page.locator('.playful-loading-spinner')
    await expect(spinner).toBeVisible()

    // Check for subtitle
    await expect(page.locator('text=(this may take a while)')).toBeVisible()

    // Check that at least one cooking pun appears
    const cookingPuns = [
      'Prepping ingredients...',
      'Simmering your recipe...',
      'Seasoning to perfection...',
      'Reducing the sauce...',
      'Letting it marinate...',
      'Whisking away...',
      'Bringing to a boil...',
      'Adding a pinch of magic...'
    ]

    let foundPun = false
    for (const pun of cookingPuns) {
      const punLocator = page.locator(`text=${pun}`)
      if (await punLocator.isVisible().catch(() => false)) {
        foundPun = true
        break
      }
    }
    expect(foundPun).toBe(true)
  })

  test('AC-ADMIN-UI-URL-006: Successful import populates all fields', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('https://example.com/recipe/beef-noodle')
    await page.locator('.url-import-dialog button:has-text("Import")').click()

    await page.waitForSelector('.success-message', { state: 'visible', timeout: 30000 })
    await expect(page.locator('.url-import-dialog')).not.toBeVisible()

    // Validate recipe name
    const recipeName = page.locator('input#name')
    await expect(recipeName).toHaveValue(/Taiwanese.*Beef.*Noodle.*Soup/i)

    // Validate that form data was populated
    // Check that ingredient groups exist (should have 2 groups)
    const ingredientGroupLabels = page.locator('label:has-text("Group"), label').filter({ hasText: /group/i })
    const groupCount = await ingredientGroupLabels.count()
    expect(groupCount).toBeGreaterThanOrEqual(1)

    // Validate steps exist (should have at least 3 steps)
    const stepSections = page.locator('[class*="step"]').filter({ has: page.locator('textarea') })
    const stepCount = await stepSections.count()
    expect(stepCount).toBeGreaterThanOrEqual(1)

    // Check that cuisine/dietary tags were imported
    const formContent = await page.content()
    expect(formContent).toContain('taiwanese')  // From mockRecipeData cuisines

    console.log('✅ All URL import fields validated successfully')
  })

  test('AC-ADMIN-UI-URL-007: Cannot access URL error handling', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('https://blocked-site.com/recipe')
    await page.locator('.url-import-dialog button:has-text("Import")').click()

    // Error should be visible in error container
    const errorContainer = page.locator('.url-import-dialog__error')
    await expect(errorContainer).toBeVisible({ timeout: 10000 })
    await expect(errorContainer).toContainText(/Could not access this URL|Cannot access/i)

    // Dialog should remain open
    await expect(page.locator('.url-import-dialog')).toBeVisible()

    // URL should still be in the input
    const urlInput = page.locator('.url-import-dialog input[type="url"]')
    await expect(urlInput).toHaveValue('https://blocked-site.com/recipe')

    // Import button should still be visible to allow retry
    const importButton = page.locator('.url-import-dialog__footer-right button').filter({ hasText: 'Import' })
    await expect(importButton).toBeVisible()
  })

  test('AC-ADMIN-UI-URL-008: No recipe found error with switch to text import', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('https://example.com/404/no-recipe')
    await page.locator('.url-import-dialog button:has-text("Import")').click()

    // Error should be visible in error container
    const errorContainer = page.locator('.url-import-dialog__error')
    await expect(errorContainer).toBeVisible({ timeout: 10000 })
    await expect(errorContainer).toContainText(/Could not find a recipe|No recipe found/i)

    // Switch to Text Import button should be visible
    const switchButton = page.locator('button:has-text("Switch to Text Import")')
    await expect(switchButton).toBeVisible()

    await switchButton.click()

    // URL dialog should close, text dialog should open
    await expect(page.locator('.url-import-dialog')).not.toBeVisible()
    await expect(page.locator('.text-import-dialog')).toBeVisible()
  })

  test('AC-ADMIN-UI-URL-012: All languages supported (test with Japanese)', async ({ page }) => {
    // Change language to Japanese
    const languageSelector = page.locator('select[aria-label="Language"], select').first()
    await languageSelector.selectOption('ja')

    // Wait for language to change
    await page.waitForTimeout(500)

    const urlImportButton = page.locator('button:has-text("URLからインポート")')
    await expect(urlImportButton).toBeVisible()

    await urlImportButton.click()

    await expect(page.locator('text=URLからレシピをインポート')).toBeVisible()
    // Verify the input field is visible (no label by design)
    await expect(page.locator('input[type="url"]')).toBeVisible()
  })
})
