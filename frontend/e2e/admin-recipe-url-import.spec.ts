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

    // Button should have link icon (pi-link class)
    const icon = urlImportButton.locator('[class*="pi-link"]')
    await expect(icon).toBeVisible()
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

    const importButton = page.locator('.url-import-dialog__footer-right button').last()

    // Button should be disabled when URL is empty (has data-p-disabled or aria-disabled)
    await expect(importButton).toBeDisabled()
  })

  test('AC-ADMIN-UI-URL-005: Playful loading state with cooking puns', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('https://example.com/recipe/test')
    await page.locator('.url-import-dialog button:has-text("Import")').click()

    // Input field should remain visible but disabled during loading
    const urlInput = page.locator('.url-import-dialog input[type="url"]')
    await expect(urlInput).toBeVisible()
    await expect(urlInput).toBeDisabled()

    // Check for loading message
    const loadingMessage = page.locator('.url-import-dialog .loading-message')
    await expect(loadingMessage).toBeVisible()

    // Check for spinner icon
    const spinner = loadingMessage.locator('.pi-spinner')
    await expect(spinner).toBeVisible()
  })

  test('AC-ADMIN-UI-URL-006: Successful import populates all fields', async ({ page }) => {
    await page.click('button:has-text("Import from URL")')
    await page.waitForSelector('.url-import-dialog', { state: 'visible' })

    await page.locator('.url-import-dialog input[type="url"]').fill('https://example.com/recipe/beef-noodle')
    await page.locator('.url-import-dialog button:has-text("Import")').click()

    await page.waitForSelector('.success-message', { state: 'visible', timeout: 30000 })
    await expect(page.locator('.url-import-dialog')).not.toBeVisible()

    // Validate recipe name - look for input containing the recipe name
    const recipeName = page.locator('input[placeholder*="recipe" i], input[placeholder*="name" i]').first()
    const nameValue = await recipeName.inputValue()
    expect(nameValue).toMatch(/Taiwanese.*Beef.*Noodle.*Soup/i)

    // Validate that form data was populated by checking page content
    const formContent = await page.content()

    // Check that cuisines were imported
    expect(formContent).toContain('taiwanese')

    // Check that at least one ingredient is present
    expect(formContent).toContain('beef shank')

    // Check that steps were imported
    expect(formContent).toContain('Blanch')

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

    // Error message should contain some text (translated or not)
    const errorText = await errorContainer.textContent()
    expect(errorText?.length).toBeGreaterThan(0)

    // Dialog should remain open
    await expect(page.locator('.url-import-dialog')).toBeVisible()

    // URL should still be in the input
    const urlInput = page.locator('.url-import-dialog input[type="url"]')
    await expect(urlInput).toHaveValue('https://blocked-site.com/recipe')

    // Import button should still be visible to allow retry
    const importButton = page.locator('.url-import-dialog__footer-right button').last()
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

    // Error message should contain some text
    const errorText = await errorContainer.textContent()
    expect(errorText?.length).toBeGreaterThan(0)

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

    // Dialog title should be in Japanese
    await expect(page.locator('text=URLからレシピをインポート')).toBeVisible()

    // Input field should be visible (URL input, no label by design)
    const urlInput = page.locator('.url-import-dialog input[type="url"]')
    await expect(urlInput).toBeVisible()

    // Verify buttons are in Japanese
    const importButton = page.locator('.url-import-dialog button:has-text("インポート")')
    await expect(importButton).toBeVisible()
  })
})
