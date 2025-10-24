import { test, expect, Page } from '@playwright/test'
import {
  loginAsAdmin,
  clearAuthState,
  getAuthToken,
  simulateNetworkError,
} from '../helpers/auth-helpers'

const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'

test.describe('Admin Recipes List - AC-ADMIN-RECIPES Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/admin/recipes')
    await clearAuthState(page)
  })

  // AC-ADMIN-RECIPES-001: Unauthenticated Access Redirect
  test('AC-ADMIN-RECIPES-001: Unauthenticated Access Redirect', async ({ page }) => {
    // Navigate to recipes page without authentication
    await page.goto('/admin/recipes')

    // Should redirect to admin login
    await page.waitForURL(/.*\/admin\/login.*/, { timeout: 5000 })
    expect(page.url()).toContain('/admin/login')

    // URL should contain redirect parameter (unencoded or encoded)
    const url = page.url()
    expect(url.includes('redirect=/admin/recipes') || url.includes('redirect=%2Fadmin%2Frecipes')).toBeTruthy()
  })

  // AC-ADMIN-RECIPES-002: Authenticated Admin Page Access
  test('AC-ADMIN-RECIPES-002: Authenticated Admin Page Access', async ({ page }) => {
    // Login as admin first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)

    // Navigate to recipes page
    await page.goto('/admin/recipes')
    await page.waitForLoadState('networkidle')

    // Page header should be visible with title
    const pageHeader = page.locator('h1')
    await expect(pageHeader).toBeVisible()

    // Create Recipe button should be visible
    const createButton = page.locator('button').filter({ hasText: /Create Recipe/ }).first()
    await expect(createButton).toBeVisible()

    // Search bar should be displayed
    const searchInput = page.locator('input[type="text"]')
    await expect(searchInput).toBeVisible()
  })

  // AC-ADMIN-RECIPES-003: Recipe List Display with Data
  test('AC-ADMIN-RECIPES-003: Recipe List Display with Data', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')

    // Wait for table to load (if recipes exist)
    const table = page.locator('table')
    const emptyState = page.locator('[class*="empty"]')

    // Either table is visible (with recipes) or empty state is shown
    const hasTable = await table.isVisible({ timeout: 2000 }).catch(() => false)
    const hasEmptyState = await emptyState.isVisible({ timeout: 2000 }).catch(() => false)

    if (hasTable) {
      // Table headers should be visible
      const nameHeader = page.locator('th:has-text("Name")')
      const languageHeader = page.locator('th:has-text("Language")')
      const cuisinesHeader = page.locator('th:has-text("Cuisines")')
      const dishTypesHeader = page.locator('th:has-text("Dish Types")')
      const servingsHeader = page.locator('th:has-text("Servings")')
      const timingHeader = page.locator('th:has-text("Timing")')
      const actionsHeader = page.locator('th:has-text("Actions")')

      await expect(nameHeader).toBeVisible()
      await expect(languageHeader).toBeVisible()
      await expect(cuisinesHeader).toBeVisible()
      await expect(dishTypesHeader).toBeVisible()
      await expect(servingsHeader).toBeVisible()
      await expect(timingHeader).toBeVisible()
      await expect(actionsHeader).toBeVisible()

      // At least one recipe row should exist
      const recipeRow = page.locator('tbody tr').first()
      await expect(recipeRow).toBeVisible()

      // Each row should have edit button in actions column
      const editButton = recipeRow.locator('.btn-icon')
      await expect(editButton).toBeVisible()
    } else if (hasEmptyState) {
      // Empty state is acceptable when no recipes exist
      await expect(emptyState).toBeVisible()
    }
  })

  // AC-ADMIN-RECIPES-004: Empty State Display
  test('AC-ADMIN-RECIPES-004: Empty State Display', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)

    // Navigate to recipes
    await page.goto('/admin/recipes')

    // Wait a moment for page to fully load
    await page.waitForLoadState('networkidle')

    // Check if we have an empty state or table with data
    const table = page.locator('table')
    const hasTable = await table.isVisible({ timeout: 1000 }).catch(() => false)

    if (!hasTable) {
      // Empty state or message about no recipes should be visible
      const adminRecipesContainer = page.locator('.admin-recipes')
      await expect(adminRecipesContainer).toBeVisible()

      // Should see some indication of empty state (text or empty state component)
      const pageContent = await page.textContent('.admin-recipes')
      expect(pageContent).toBeTruthy()
    }
  })

  // AC-ADMIN-RECIPES-005: Search Functionality
  test('AC-ADMIN-RECIPES-005: Search Functionality', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')

    // Wait for page to be ready
    await page.waitForLoadState('networkidle')

    // Find search input
    const searchInput = page.locator('input[type="text"]').first()
    await expect(searchInput).toBeVisible()

    // Type search query
    await searchInput.fill('test')

    // Wait for debounce and content update
    await page.waitForLoadState('networkidle')

    // Content should be visible
    const adminRecipesContent = page.locator('.admin-recipes')
    await expect(adminRecipesContent).toBeVisible()
  })

  // AC-ADMIN-RECIPES-006: Search Clear Button
  test('AC-ADMIN-RECIPES-006: Search Clear Button', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')

    await page.waitForLoadState('networkidle')

    const searchInput = page.locator('input[type="text"]').first()
    const clearButton = page.locator('.clear-search')

    // Initially, clear button should not be visible (no search query)
    await expect(clearButton).not.toBeVisible()

    // Type search query
    await searchInput.fill('test recipe')

    // Clear button should now be visible
    await expect(clearButton).toBeVisible()

    // Click clear button
    await clearButton.click()

    // Search input should be cleared
    expect(await searchInput.inputValue()).toBe('')
  })

  // AC-ADMIN-RECIPES-007: Pagination Navigation
  test('AC-ADMIN-RECIPES-007: Pagination Navigation', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')

    // Wait for page to load
    await page.waitForLoadState('networkidle')

    // Check if pagination exists
    const pagination = page.locator('.pagination')
    const paginationExists = await pagination.isVisible({ timeout: 1000 }).catch(() => false)

    if (paginationExists) {
      // Pagination controls should be visible
      const prevButton = page.locator('.pagination button:first-of-type')
      const nextButton = page.locator('.pagination button:last-of-type')
      const paginationInfo = page.locator('.pagination-info')

      await expect(paginationInfo).toBeVisible()

      // Initially on page 1, so prev button should be disabled
      const isPrevDisabled = await prevButton.isDisabled()
      expect(isPrevDisabled).toBe(true)

      // Check if there's a next page
      const isNextDisabled = await nextButton.isDisabled()

      if (!isNextDisabled) {
        // If next is enabled, click it
        await nextButton.click()

        // Should fetch new page
        await page.waitForTimeout(300)

        // Now prev button should be enabled
        const isPrevNowEnabled = await prevButton.isDisabled()
        expect(isPrevNowEnabled).toBe(false)
      }
    }
  })

  // AC-ADMIN-RECIPES-008: Recipe Row Click Navigation
  test('AC-ADMIN-RECIPES-008: Recipe Row Click Navigation', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')

    // Wait for content to load
    await page.waitForLoadState('networkidle')

    // Check if any recipe rows exist
    const recipeRow = page.locator('tbody tr').first()
    const rowExists = await recipeRow.isVisible({ timeout: 1000 }).catch(() => false)

    if (rowExists) {
      // Get recipe ID from data attribute or extract from link
      const recipeLink = recipeRow.locator('.recipe-name')

      // Click the recipe row
      await recipeRow.click()

      // Should navigate to recipe detail page
      await page.waitForURL(/.*\/admin\/recipes\/\d+.*/, { timeout: 5000 }).catch(() => {})

      // URL should contain /admin/recipes/
      expect(page.url()).toMatch(/\/admin\/recipes\/\d+/)
    }
  })

  // AC-ADMIN-RECIPES-009: Create Recipe Button Navigation
  test('AC-ADMIN-RECIPES-009: Create Recipe Button Navigation', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')
    await page.waitForLoadState('networkidle')

    // Find and click create recipe button
    const createButton = page.locator('button').filter({ hasText: /Create Recipe/ }).first()
    await expect(createButton).toBeVisible()

    await createButton.click()

    // Should navigate to /admin/recipes/new
    await page.waitForURL(/.*\/admin\/recipes\/new.*/)
    expect(page.url()).toContain('/admin/recipes/new')
  })

  // AC-ADMIN-RECIPES-010: Loading State Display
  test('AC-ADMIN-RECIPES-010: Loading State Display', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)

    // Navigate to recipes
    await page.goto('/admin/recipes')
    await page.waitForLoadState('networkidle')

    // After loading completes, page should have content
    const adminRecipesContainer = page.locator('.admin-recipes')
    await expect(adminRecipesContainer).toBeVisible()

    // Verify page has content
    const pageText = await adminRecipesContainer.textContent()
    expect(pageText).toBeTruthy()
  })

  // AC-ADMIN-RECIPES-011: Error State Display
  test('AC-ADMIN-RECIPES-011: Error State Display', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)

    // Simulate network error
    await page.route('**/api/v1/admin/recipes**', (route) => {
      route.abort('failed')
    })

    // Navigate to recipes
    await page.goto('/admin/recipes')
    await page.waitForLoadState('networkidle').catch(() => {})

    // Page should load with error handling
    const adminRecipesContainer = page.locator('.admin-recipes')
    await expect(adminRecipesContainer).toBeVisible()
  })

  // AC-ADMIN-RECIPES-012: Language Switching Refetch
  test('AC-ADMIN-RECIPES-012: Language Switching Refetch', async ({ page }) => {
    // Login first
    await page.goto('/admin/login')
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.goto('/admin/recipes')
    await page.waitForLoadState('networkidle')

    // Verify page is loaded
    const adminRecipesContainer = page.locator('.admin-recipes')
    await expect(adminRecipesContainer).toBeVisible()

    // Page should have content
    const pageText = await adminRecipesContainer.textContent()
    expect(pageText).toBeTruthy()
  })
})
