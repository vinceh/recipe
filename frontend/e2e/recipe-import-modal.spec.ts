import { test, expect } from '@playwright/test'

test.describe('Recipe Import Modal - AC-ADMIN-016 through AC-ADMIN-035', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login')
    await page.fill('input[type="email"]', 'admin@ember.app')
    await page.fill('input[type="password"]', '123456')
    await page.click('button[type="submit"]')
    await page.waitForURL('**/admin', { timeout: 10000 })

    await page.goto('/admin/recipes/new')
    await page.waitForSelector('form', { timeout: 5000 })
  })

  test.describe('AC-ADMIN-016: Import Modal - Open and Display', () => {
    test('should open modal with Import Recipe button', async ({ page }) => {
      const importButton = page.locator('button:has-text("Import Recipe")')
      await expect(importButton).toBeVisible()

      await importButton.click()

      const modal = page.locator('.recipe-import-modal')
      await expect(modal).toBeVisible()

      await expect(page.locator('.recipe-import-modal h2')).toContainText('Import Recipe')

      await expect(page.locator('.tab:has-text("Text")')).toBeVisible()
      await expect(page.locator('.tab:has-text("URL")')).toBeVisible()
      await expect(page.locator('.tab:has-text("Image")')).toBeVisible()

      await expect(page.locator('.tab--active:has-text("Text")')).toBeVisible()
    })
  })

  test.describe('AC-ADMIN-017: Import Modal - Text Tab UI', () => {
    test('should display text tab with all required elements', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      await expect(page.locator('textarea.form-textarea')).toBeVisible()
      await expect(page.locator('textarea.form-textarea')).toHaveAttribute(
        'placeholder',
        /Paste recipe text here/i
      )

      await expect(page.locator('.char-counter')).toBeVisible()

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeVisible()
      await expect(parseButton).toBeDisabled()
    })
  })

  test.describe('AC-ADMIN-018: Import Modal - Text Validation', () => {
    test('should keep parse button disabled for short text', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('Too short')

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeDisabled()

      const charCounter = page.locator('.char-counter')
      await expect(charCounter).toContainText('minimum 50')
    })

    test('should enable parse button for text >= 50 characters', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      const validText = 'A'.repeat(50)
      await textarea.fill(validText)

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeEnabled()
    })
  })

  test.describe('AC-ADMIN-021: Import Modal - URL Tab UI', () => {
    test('should display URL tab with all required elements', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      await page.click('.tab:has-text("URL")')

      await expect(page.locator('input[type="url"]')).toBeVisible()
      await expect(page.locator('input[type="url"]')).toHaveAttribute(
        'placeholder',
        /https:\/\/example.com\/recipe/
      )

      await expect(page.locator('.hint-text')).toBeVisible()

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeDisabled()
    })
  })

  test.describe('AC-ADMIN-022: Import Modal - URL Validation', () => {
    test('should keep parse button disabled for invalid URL', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')
      await page.click('.tab:has-text("URL")')

      const urlInput = page.locator('input[type="url"]')
      await urlInput.fill('not-a-valid-url')

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeDisabled()
    })

    test('should enable parse button for valid URL', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')
      await page.click('.tab:has-text("URL")')

      const urlInput = page.locator('input[type="url"]')
      await urlInput.fill('https://example.com/recipe')

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeEnabled()
    })
  })

  test.describe('AC-ADMIN-025: Import Modal - Image Tab UI', () => {
    test('should display image tab with upload zone', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')
      await page.click('.tab:has-text("Image")')

      await expect(page.locator('.image-upload-zone')).toBeVisible()
      await expect(page.locator('.image-upload-label')).toContainText(/Drag image here/)

      await expect(page.locator('.image-upload-label')).toContainText(/JPG, PNG, WEBP, GIF/)

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await expect(parseButton).toBeDisabled()
    })
  })

  test.describe('AC-ADMIN-030: Import Modal - Loading State Behavior', () => {
    test('should disable tab switching and close during loading', async ({ page }) => {
      await page.route('**/admin/recipes/parse_text', async (route) => {
        await page.waitForTimeout(1000)
        await route.fulfill({
          status: 200,
          body: JSON.stringify({
            success: true,
            data: {
              recipe_data: {
                name: 'Test Recipe',
                language: 'en',
                ingredient_groups: [{ name: 'Main', items: [] }],
                steps: [{ id: 'step-001', order: 1, instructions: { original: 'Cook' } }]
              }
            }
          })
        })
      })

      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('A'.repeat(60))

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await parseButton.click()

      const urlTab = page.locator('.tab:has-text("URL")')
      await expect(urlTab).toBeDisabled()

      const closeButton = page.locator('.recipe-import-modal__close')
      await expect(closeButton).toBeDisabled()

      const loadingSpinner = page.locator('.loading-spinner')
      await expect(loadingSpinner).toBeVisible()
    })
  })

  test.describe('AC-ADMIN-031: Import Modal - Close and Reset', () => {
    test('should reset all fields when modal closes', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('Some recipe text here')

      const closeButton = page.locator('.recipe-import-modal__close')
      await closeButton.click()

      await expect(page.locator('.recipe-import-modal')).not.toBeVisible()

      await page.click('button:has-text("Import Recipe")')

      await expect(textarea).toHaveValue('')
    })

    test('should close modal when clicking outside', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      const modal = page.locator('.recipe-import-modal')
      await expect(modal).toBeVisible()

      const overlay = page.locator('.recipe-import-modal-overlay')
      await overlay.click({ position: { x: 10, y: 10 } })

      await expect(modal).not.toBeVisible()
    })
  })

  test.describe('AC-ADMIN-032: Import Modal - Keyboard Navigation', () => {
    test('should close modal with ESC key', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      const modal = page.locator('.recipe-import-modal')
      await expect(modal).toBeVisible()

      await page.keyboard.press('Escape')

      await expect(modal).not.toBeVisible()
    })

    test('should trigger parse with Ctrl+Enter on text tab', async ({ page }) => {
      await page.route('**/admin/recipes/parse_text', async (route) => {
        await route.fulfill({
          status: 200,
          body: JSON.stringify({
            success: true,
            data: {
              recipe_data: {
                name: 'Keyboard Test Recipe',
                language: 'en',
                ingredient_groups: [{ name: 'Main', items: [] }],
                steps: [{ id: 'step-001', order: 1, instructions: { original: 'Cook' } }]
              }
            }
          })
        })
      })

      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('A'.repeat(60))

      await page.keyboard.press('Control+Enter')

      await page.waitForTimeout(500)
      await expect(page.locator('.recipe-import-modal')).not.toBeVisible()
    })
  })

  test.describe('AC-ADMIN-034: Import Modal - Error Recovery', () => {
    test('should clear error when user edits input', async ({ page }) => {
      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('short')

      await page.route('**/admin/recipes/parse_text', async (route) => {
        await route.fulfill({
          status: 422,
          body: JSON.stringify({
            success: false,
            message: 'Parse failed'
          })
        })
      })

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await parseButton.click()

      await page.waitForTimeout(500)

      const errorMessage = page.locator('.error-message')
      await expect(errorMessage).toBeVisible()

      await textarea.fill('A'.repeat(60))

      await expect(errorMessage).not.toBeVisible()
    })
  })

  test.describe('AC-ADMIN-035: Import Modal - Parsed Data Validation', () => {
    test('should show error for incomplete recipe data', async ({ page }) => {
      await page.route('**/admin/recipes/parse_text', async (route) => {
        await route.fulfill({
          status: 200,
          body: JSON.stringify({
            success: true,
            data: {
              recipe_data: {
                name: 'Incomplete Recipe'
              }
            }
          })
        })
      })

      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('A'.repeat(60))

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await parseButton.click()

      await page.waitForTimeout(500)

      const errorMessage = page.locator('.error-message')
      await expect(errorMessage).toContainText(/Incomplete recipe data/i)

      const modal = page.locator('.recipe-import-modal')
      await expect(modal).toBeVisible()
    })

    test('should populate form with valid parsed data', async ({ page }) => {
      await page.route('**/admin/recipes/parse_text', async (route) => {
        await route.fulfill({
          status: 200,
          body: JSON.stringify({
            success: true,
            data: {
              recipe_data: {
                name: 'Imported Recipe',
                language: 'en',
                servings: { original: 4, min: 2, max: 8 },
                timing: { prep_minutes: 10, cook_minutes: 20, total_minutes: 30 },
                ingredient_groups: [
                  {
                    name: 'Main Ingredients',
                    items: [{ name: 'flour', amount: '2', unit: 'cups', notes: '', optional: false }]
                  }
                ],
                steps: [
                  {
                    id: 'step-001',
                    order: 1,
                    instructions: { original: 'Mix flour and water' },
                    timing_minutes: 5
                  }
                ]
              }
            }
          })
        })
      })

      await page.click('button:has-text("Import Recipe")')

      const textarea = page.locator('textarea.form-textarea')
      await textarea.fill('A'.repeat(60))

      const parseButton = page.locator('button:has-text("Parse Recipe")')
      await parseButton.click()

      await page.waitForTimeout(500)

      const modal = page.locator('.recipe-import-modal')
      await expect(modal).not.toBeVisible()

      const nameInput = page.locator('input#name')
      await expect(nameInput).toHaveValue('Imported Recipe')
    })
  })
})
