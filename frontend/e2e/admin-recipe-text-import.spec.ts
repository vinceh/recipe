import { test, expect, Page } from '@playwright/test'

async function login(page: Page) {
  await page.goto('/login')
  await page.fill('input[type="email"]', 'admin@ember.app')
  await page.fill('input[type="password"]', '123456')
  await page.click('button[type="submit"]')
  await page.waitForURL('**/admin', { timeout: 10000 })
}

const comprehensiveRecipeText = `Taiwanese Beef Noodle Soup (牛肉麵)

A hearty and flavorful Taiwanese classic featuring tender braised beef in a rich, spiced broth served over hand-pulled noodles. This dish is perfect for cold weather and special occasions.

Prep Time: 30 minutes
Cook Time: 3 hours
Total Time: 3 hours 30 minutes
Servings: 4-6

Cuisine: Taiwanese, Chinese
Dish Type: Soup, Main Course
Recipe Type: Traditional, Comfort Food
Dietary: Dairy-Free

Equipment needed: Large pot, stockpot, chef's knife, cutting board

For the Broth:
- 2 lbs beef shank, cut into chunks
- 1 lb beef bones
- 4 cups water
- 2 star anise
- 1 cinnamon stick
- 3 cloves garlic, smashed
- 2 inch piece ginger, sliced
- 2 tbsp soy sauce
- 1 tbsp dark soy sauce (for color)
- 1 tbsp sugar
- 2 tbsp Shaoxing wine
- 1 tsp Sichuan peppercorns

For Serving:
- 1 lb fresh noodles
- 2 cups bok choy, chopped
- 2 green onions, sliced (optional)
- Chili oil to taste (optional)

Instructions:
1. Blanch the beef bones in boiling water for 5 minutes to remove impurities. Drain and rinse thoroughly.
2. In a large stockpot, combine the blanched bones, beef shank, water, star anise, cinnamon, garlic, and ginger. Bring to a boil.
3. Reduce heat to low and simmer for 2.5 hours until the beef is tender and the broth is rich and flavorful.
4. Add soy sauce, dark soy sauce, sugar, Shaoxing wine, and Sichuan peppercorns. Simmer for another 30 minutes to allow flavors to meld.
5. Strain the broth and remove the beef chunks. Slice beef against the grain and set aside.
6. Cook fresh noodles according to package directions in a separate pot of boiling water.
7. Blanch bok choy in the noodle water for 1-2 minutes until tender-crisp.
8. To serve, divide noodles among bowls, top with sliced beef and bok choy, ladle hot broth over everything, and garnish with green onions and chili oil if desired.

Admin Notes: This recipe requires precision timing for the braising process to ensure tender beef. The broth can be made ahead and refrigerated for up to 3 days.`

const sampleRecipeText = `Taiwanese Beef Noodle Soup

Ingredients:
- 2 lbs beef shank
- 1 lb beef bones
- 4 cups water
- 2 star anise
- 1 cinnamon stick
- 3 cloves garlic
- 2 tbsp soy sauce
- 1 tbsp sugar
- Fresh noodles

Instructions:
1. Blanch the beef bones in boiling water for 5 minutes to remove impurities
2. In a large pot, combine bones, beef shank, water, star anise, and cinnamon
3. Bring to a boil then reduce heat and simmer for 3 hours
4. Add soy sauce and sugar, adjust seasoning to taste
5. Cook noodles separately and serve with broth`

test.describe('Admin Recipe Text Import - AC-ADMIN-UI-TEXT-001 to AC-ADMIN-UI-TEXT-005', () => {
  test.beforeEach(async ({ page }) => {
    await login(page)
    await page.goto('/admin/recipes/new')
  })

  test('AC-ADMIN-UI-TEXT-001: Import button renders correctly with icon and i18n text', async ({ page }) => {
    const importButton = page.locator('button:has-text("Import from Text")')

    await expect(importButton).toBeVisible()

    const icon = importButton.locator('i.pi-file-import')
    await expect(icon).toBeVisible()

    await page.screenshot({ path: 'screenshots/import-button-default.png', fullPage: false })
  })

  test('AC-ADMIN-UI-TEXT-002: Dialog opens when import button clicked with correct UI elements', async ({ page }) => {
    await page.click('button:has-text("Import from Text")')

    await page.waitForSelector('.text-import-dialog', { state: 'visible', timeout: 5000 })

    const dialogTitle = page.locator('h3:has-text("Import Recipe from Text")')
    await expect(dialogTitle).toBeVisible()

    const textarea = page.locator('.text-import-dialog textarea')
    await expect(textarea).toBeVisible()
    await expect(textarea).toHaveAttribute('placeholder', /Paste your recipe text here/)

    const importButton = page.locator('.text-import-dialog button:has-text("Import")')
    await expect(importButton).toBeVisible()

    const cancelButton = page.locator('.text-import-dialog button:has-text("Cancel")')
    await expect(cancelButton).toBeVisible()

    await page.screenshot({ path: 'screenshots/import-dialog-empty.png', fullPage: true })

    await cancelButton.click()
    await expect(page.locator('.text-import-dialog')).not.toBeVisible()
  })

  test('AC-ADMIN-UI-TEXT-003: Import parses text and populates form with all fields', async ({ page }) => {
    await page.click('button:has-text("Import from Text")')
    await page.waitForSelector('.text-import-dialog', { state: 'visible' })

    await page.screenshot({ path: 'screenshots/import-dialog-before-paste.png', fullPage: true })

    await page.locator('.text-import-dialog textarea').fill(sampleRecipeText)

    await page.screenshot({ path: 'screenshots/import-dialog-with-text.png', fullPage: true })

    await page.locator('.text-import-dialog button:has-text("Import")').click()

    await page.screenshot({ path: 'screenshots/import-dialog-loading.png', fullPage: true })

    await page.waitForSelector('.success-message', { state: 'visible', timeout: 30000 })

    const successMessage = page.locator('.success-message')
    await expect(successMessage).toContainText('Recipe imported successfully')

    await page.screenshot({ path: 'screenshots/import-success-message.png', fullPage: true })

    await expect(page.locator('.text-import-dialog')).not.toBeVisible()

    const recipeName = page.locator('input#name')
    await expect(recipeName).toHaveValue(/Taiwanese|Beef|Noodle|beef/i)

    await page.screenshot({ path: 'screenshots/form-populated-after-import.png', fullPage: true })

    const ingredients = await page.locator('input[placeholder*="flour"], input[placeholder*="Ingredient"]').count()
    expect(ingredients).toBeGreaterThan(0)
  })

  test('AC-ADMIN-UI-TEXT-004: Error handling displays correctly for parsing failures', async ({ page }) => {
    await page.click('button:has-text("Import from Text")')
    await page.waitForSelector('.text-import-dialog', { state: 'visible' })

    await page.locator('.text-import-dialog textarea').fill('Too short')
    await page.locator('.text-import-dialog button:has-text("Import")').click()

    const errorMessage = page.locator('.text-import-dialog .error-message')
    await expect(errorMessage).toBeVisible({ timeout: 5000 })

    await page.screenshot({ path: 'screenshots/import-error-too-short.png', fullPage: true })

    await expect(page.locator('.text-import-dialog')).toBeVisible()

    const textareaValue = await page.locator('.text-import-dialog textarea').inputValue()
    expect(textareaValue).toBe('Too short')
  })

  test('AC-ADMIN-UI-TEXT-005: Empty text validation prevents import', async ({ page }) => {
    await page.click('button:has-text("Import from Text")')
    await page.waitForSelector('.text-import-dialog', { state: 'visible' })

    const importButton = page.locator('.text-import-dialog button:has-text("Import")')
    await expect(importButton).toBeDisabled()

    await page.screenshot({ path: 'screenshots/import-error-empty.png', fullPage: true })

    await importButton.click({ force: true })

    const errorMessage = page.locator('.text-import-dialog .error-message')
    await expect(errorMessage).toBeVisible()
    await expect(errorMessage).toContainText('Please paste recipe text before importing')
  })

  test('AC-ADMIN-UI-TEXT-INTEGRATION: Full workflow from import to save', async ({ page }) => {
    await page.click('button:has-text("Import from Text")')
    await page.waitForSelector('.text-import-dialog', { state: 'visible' })

    await page.locator('.text-import-dialog textarea').fill(sampleRecipeText)
    await page.locator('.text-import-dialog button:has-text("Import")').click()

    await page.waitForSelector('.success-message', { state: 'visible', timeout: 30000 })

    await page.screenshot({ path: 'screenshots/full-workflow-form-populated.png', fullPage: true })

    await page.click('button:has-text("Save")')

    await page.waitForURL('**/admin/recipes/*', { timeout: 15000 })

    await page.screenshot({ path: 'screenshots/full-workflow-saved.png', fullPage: true })

    const heading = page.locator('h2, h1').filter({ hasText: /Taiwanese|Beef|Noodle|beef/i })
    await expect(heading).toBeVisible({ timeout: 10000 })
  })

  test('AC-ADMIN-UI-TEXT-ACCESSIBILITY: Dialog keyboard navigation', async ({ page }) => {
    await page.keyboard.press('Tab')

    const importButton = page.locator('button:has-text("Import from Text")')
    await importButton.focus()
    await page.keyboard.press('Enter')

    await page.waitForSelector('.text-import-dialog', { state: 'visible' })

    await page.keyboard.press('Tab')
    const textarea = page.locator('.text-import-dialog textarea')
    await expect(textarea).toBeFocused()

    await textarea.fill(sampleRecipeText)

    await page.keyboard.press('Tab')
    await page.keyboard.press('Tab')

    const activeElement = await page.evaluateHandle(() => document.activeElement?.textContent)
    const buttonText = await activeElement.jsonValue()
    expect(buttonText).toContain('Import')
  })

  test('AC-ADMIN-UI-TEXT-COMPREHENSIVE: All recipe fields are parsed and populated', async ({ page }) => {
    await page.click('button:has-text("Import from Text")')
    await page.waitForSelector('.text-import-dialog', { state: 'visible' })

    await page.locator('.text-import-dialog textarea').fill(comprehensiveRecipeText)
    await page.locator('.text-import-dialog button:has-text("Import")').click()

    await page.waitForSelector('.success-message', { state: 'visible', timeout: 30000 })
    await expect(page.locator('.text-import-dialog')).not.toBeVisible()

    // Validate recipe name
    const recipeName = page.locator('input#name')
    await expect(recipeName).toHaveValue(/Taiwanese.*Beef.*Noodle.*Soup/i)

    // Validate timing fields are populated
    const prepTime = page.locator('input#prep_time_minutes, input[placeholder*="prep"]')
    await expect(prepTime.first()).toHaveValue('30')

    const cookTime = page.locator('input#cook_time_minutes, input[placeholder*="cook"]')
    await expect(cookTime.first()).toHaveValue('180')

    const totalTime = page.locator('input#total_time_minutes, input[placeholder*="total"]')
    await expect(totalTime.first()).toHaveValue('210')

    // Validate servings
    const servings = page.locator('input[placeholder*="servings"], input[placeholder*="Servings"]')
    const servingsValue = await servings.first().inputValue()
    expect(parseInt(servingsValue)).toBeGreaterThanOrEqual(4)
    expect(parseInt(servingsValue)).toBeLessThanOrEqual(6)

    // Validate ingredient groups exist (should have 2 groups: "For the Broth" and "For Serving")
    const ingredientGroups = await page.locator('input[placeholder*="group"], input[placeholder*="Group"]').count()
    expect(ingredientGroups).toBeGreaterThanOrEqual(2)

    // Validate ingredients have amounts filled in
    const ingredientAmounts = page.locator('input[placeholder*="amount"], input[placeholder*="Amount"]')
    const firstAmount = await ingredientAmounts.first().inputValue()
    expect(firstAmount).toBeTruthy()
    expect(firstAmount.length).toBeGreaterThan(0)

    // Validate steps are populated (should have 8 steps)
    const steps = await page.locator('textarea[placeholder*="instruction"], textarea[placeholder*="Instruction"]').count()
    expect(steps).toBeGreaterThanOrEqual(8)

    // Validate admin notes are populated
    const adminNotes = page.locator('textarea#admin_notes, textarea[placeholder*="admin"], textarea[placeholder*="Admin"]')
    const adminNotesValue = await adminNotes.first().inputValue()
    expect(adminNotesValue).toContain('precision')

    // Validate tags/metadata if available (cuisines, dish types, etc.)
    // Note: These may be in dropdowns or multi-selects depending on the form implementation
    const pageContent = await page.content()
    expect(pageContent).toContain('Taiwanese')

    console.log('✅ All comprehensive fields validated successfully')
  })
})
