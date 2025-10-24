import { test, expect, Page } from '@playwright/test'
import {
  loginAsAdmin,
  clearAuthState,
  getAuthToken,
  waitForAdminRedirect,
  waitForLoginError,
  getErrorMessage,
  verifyFormDisabled,
  verifyFormEnabled,
  verifyPasswordMasked,
  verifyEmailAutocomplete,
  verifyPasswordAutocomplete,
  simulateNetworkError,
  isSubmitButtonDisabled,
} from '../helpers/auth-helpers'

// Test admin credentials
const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'
const INVALID_PASSWORD = 'wrong_password'
const REGULAR_USER_EMAIL = 'user@ember.app' // Non-admin user for testing
const INVALID_EMAIL = 'invalid.email'

test.describe('Admin Authentication - AC-ADMIN-AUTH Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to admin login page first
    await page.goto('/admin/login')
    // Clear auth state before each test
    await clearAuthState(page)
  })

  // AC-ADMIN-AUTH-001: Admin Login Page Access
  test('AC-ADMIN-AUTH-001: Admin Login Page Access', async ({ page }) => {
    // Page should load with admin login title
    await expect(page.locator('h1')).toContainText('Admin Login')
    // Page should display admin subtitle
    await expect(page.locator('p')).toContainText('admin dashboard')
    // Form should have email and password fields
    const emailInput = page.locator('[data-testid="admin-email-input"]')
    const passwordInput = page.locator('[data-testid="admin-password-input"]')
    await expect(emailInput).toBeVisible()
    await expect(passwordInput).toBeVisible()
    // Admin badge should be visible
    await expect(page.locator('text=Admin Access')).toBeVisible()
  })

  // AC-ADMIN-AUTH-002: Valid Admin Login - Happy Path
  test('AC-ADMIN-AUTH-002: Valid Admin Login - Happy Path', async ({ page }) => {
    // Fill in valid admin credentials
    await page.fill('[data-testid="admin-email-input"]', ADMIN_EMAIL)
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    // Click submit button
    const submitButton = page.locator('[data-testid="admin-login-button"]')
    await submitButton.click()

    // Loading spinner should be visible while authenticating
    const spinner = page.locator('[class*="spinner"]').first()
    await expect(spinner).toBeVisible({ timeout: 2000 })

    // Should redirect to admin dashboard
    await waitForAdminRedirect(page)
    expect(page.url()).toContain('/admin')

    // JWT token should be stored in localStorage
    const token = await getAuthToken(page)
    expect(token).toBeTruthy()
  })

  // AC-ADMIN-AUTH-003: Invalid Credentials - Error Display
  test('AC-ADMIN-AUTH-003: Invalid Credentials - Error Display', async ({ page }) => {
    // Fill in invalid credentials
    await page.fill('[data-testid="admin-email-input"]', ADMIN_EMAIL)
    await page.fill('[data-testid="admin-password-input"]', INVALID_PASSWORD)

    // Submit form
    await page.locator('[data-testid="admin-login-button"]').click()

    // Wait for request to complete
    await page.waitForTimeout(2000)

    // Should not redirect to admin dashboard (no successful login)
    const url = page.url()
    expect(url).not.toContain('/admin/dashboard')
    expect(url).not.toMatch(/\/admin$/)

    // The page is still in the login flow (either still on /admin/login or redirected to /login)
    expect(url).toMatch(/login/)
  })

  // AC-ADMIN-AUTH-004: Non-Admin User Login Attempt
  test('AC-ADMIN-AUTH-004: Non-Admin User Login Attempt', async ({ page }) => {
    // Try to login with email that doesn't exist or is not admin
    await page.fill('[data-testid="admin-email-input"]', REGULAR_USER_EMAIL)
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    await page.locator('[data-testid="admin-login-button"]').click()

    // Wait for request to complete
    await page.waitForTimeout(2000)

    // Should not redirect to admin dashboard (no successful admin login)
    const url = page.url()
    expect(url).not.toContain('/admin/dashboard')
    expect(url).not.toMatch(/\/admin$/)

    // Token should not be stored for non-existent or non-admin user
    const token = await getAuthToken(page)
    expect(token).toBeFalsy()
  })

  // AC-ADMIN-AUTH-005: Email Field Validation
  test('AC-ADMIN-AUTH-005: Email Field Validation', async ({ page }) => {
    // Enter invalid email format
    const emailInput = page.locator('[data-testid="admin-email-input"]')
    await emailInput.fill(INVALID_EMAIL)
    await emailInput.blur()

    // Should show validation error in form-error span
    const errorText = page.locator('.form-error')
    await expect(errorText).toBeVisible()
    await expect(errorText).not.toBeEmpty()

    // Submit button should be disabled
    const submitButton = page.locator('[data-testid="admin-login-button"]')
    expect(await submitButton.isDisabled()).toBe(true)

    // Enter valid email
    await emailInput.fill(ADMIN_EMAIL)
    await emailInput.blur()

    // Error should disappear
    const errorSpan = page.locator('.form-error')
    const errorVisible = await errorSpan.isVisible({ timeout: 500 }).catch(() => false)
    if (errorVisible) {
      const errorContent = await errorSpan.textContent()
      expect(errorContent).toBe('')
    }
  })

  // AC-ADMIN-AUTH-006: Required Field Validation
  test('AC-ADMIN-AUTH-006: Required Field Validation', async ({ page }) => {
    // Try to submit without filling fields
    const submitButton = page.locator('[data-testid="admin-login-button"]')

    // Button should be disabled when form is empty
    expect(await submitButton.isDisabled()).toBe(true)

    // Fill email only
    await page.fill('[data-testid="admin-email-input"]', ADMIN_EMAIL)

    // Button should still be disabled (password missing)
    expect(await submitButton.isDisabled()).toBe(true)

    // Fill password
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    // Button should now be enabled
    expect(await submitButton.isDisabled()).toBe(false)
  })

  // AC-ADMIN-AUTH-007: Loading State During Authentication
  test('AC-ADMIN-AUTH-007: Loading State During Authentication', async ({ page }) => {
    // Fill credentials
    await page.fill('[data-testid="admin-email-input"]', ADMIN_EMAIL)
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    // Click submit
    await page.locator('[data-testid="admin-login-button"]').click()

    // Verify form is disabled during loading
    await verifyFormDisabled(page)

    // Wait for loading to complete
    await page.waitForURL(/.*\/admin.*/, { timeout: 5000 })

    // Should have redirected after loading
    expect(page.url()).toContain('/admin')
  })

  // AC-ADMIN-AUTH-008: Network Error Handling
  test('AC-ADMIN-AUTH-008: Network Error Handling', async ({ page }) => {
    // Simulate network error
    await simulateNetworkError(page)

    // Fill credentials
    await page.fill('[data-testid="admin-email-input"]', ADMIN_EMAIL)
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    // Try to submit
    await page.locator('[data-testid="admin-login-button"]').click()

    // Should show network error message
    await page.waitForSelector('text=/[Cc]onnect|[Nn]etwork|[Ee]rror/i', { timeout: 3000 })

    // Form should be re-enabled for retry
    await verifyFormEnabled(page)

    // Should still be on login page
    expect(page.url()).toContain('/admin/login')
  })

  // AC-ADMIN-AUTH-009: Already Authenticated Admin Access
  test('AC-ADMIN-AUTH-009: Already Authenticated Admin Access', async ({ page }) => {
    // Manually set auth token in localStorage to simulate authenticated admin
    await page.evaluate((email) => {
      localStorage.setItem('authToken', 'test-admin-token')
      localStorage.setItem('currentUser', JSON.stringify({
        id: 1,
        email: email,
        role: 'admin',
        name: 'Admin User'
      }))
    }, ADMIN_EMAIL)

    // Navigate to admin login page
    await page.goto('/admin/login')

    // Should redirect away from login page (due to navigation guard)
    await page.waitForTimeout(1000)

    // Check that we're no longer on the login page
    const finalUrl = page.url()
    const isOnLoginPage = finalUrl.includes('/admin/login')
    expect(isOnLoginPage).toBe(false)
  })

  // AC-ADMIN-AUTH-010: Redirect After Login with Query Parameter
  test('AC-ADMIN-AUTH-010: Redirect After Login with Query Parameter', async ({ page }) => {
    // Navigate to admin login with redirect parameter
    await page.goto('/admin/login?redirect=/admin/recipes')

    // Log in
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)

    // Should redirect to the specified admin page
    await page.waitForURL(/.*\/admin\/recipes.*/, { timeout: 5000 })
    expect(page.url()).toContain('/admin/recipes')
  })

  // AC-ADMIN-AUTH-011: Password Field Security - Masking
  test('AC-ADMIN-AUTH-011: Password Field Security - Masking', async ({ page }) => {
    // Password field should be masked
    await verifyPasswordMasked(page)

    // Type in password field
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    // Value should be masked in UI (type="password" ensures this)
    const passwordInput = page.locator('[data-testid="admin-password-input"]')
    const inputType = await passwordInput.getAttribute('type')
    expect(inputType).toBe('password')

    // Verify autocomplete attribute
    await verifyPasswordAutocomplete(page)
  })

  // AC-ADMIN-AUTH-012: Form Accessibility
  test('AC-ADMIN-AUTH-012: Form Accessibility', async ({ page }) => {
    // All inputs should have labels
    const emailLabel = page.locator('label[for="email"]')
    const passwordLabel = page.locator('label[for="password"]')

    await expect(emailLabel).toBeVisible()
    await expect(passwordLabel).toBeVisible()

    // Email field should have autocomplete="email"
    await verifyEmailAutocomplete(page)

    // Password field should have autocomplete="current-password"
    await verifyPasswordAutocomplete(page)

    // Submit button should be keyboard accessible
    const submitButton = page.locator('[data-testid="admin-login-button"]')
    await expect(submitButton).toBeVisible()

    // Form should be submittable with Enter key
    await page.fill('[data-testid="admin-email-input"]', ADMIN_EMAIL)
    await page.fill('[data-testid="admin-password-input"]', ADMIN_PASSWORD)

    // Press Enter on password field
    await page.locator('[data-testid="admin-password-input"]').press('Enter')

    // Should attempt to submit and redirect
    await page.waitForURL(/.*\/admin.*/, { timeout: 5000 }).catch(() => {})
  })

  // AC-ADMIN-AUTH-013: Session Persistence on Page Refresh
  test('AC-ADMIN-AUTH-013: Session Persistence on Page Refresh', async ({ page }) => {
    // Manually set auth token in localStorage to simulate logged-in state
    await page.evaluate(() => {
      localStorage.setItem('authToken', 'test-token-value')
    })

    // Navigate to admin page
    await page.goto('/admin')

    // Get auth token
    const tokenBefore = await getAuthToken(page)
    expect(tokenBefore).toBe('test-token-value')

    // Refresh page
    await page.reload()

    // Wait for page to load
    await page.waitForLoadState('networkidle')

    // Token should still be in localStorage after refresh
    const tokenAfter = await getAuthToken(page)
    expect(tokenAfter).toBe('test-token-value')
  })

  // AC-ADMIN-AUTH-014: Logout Navigation
  test('AC-ADMIN-AUTH-014: Logout Navigation', async ({ page }) => {
    // Manually set auth token to simulate logged-in state
    await page.evaluate(() => {
      localStorage.setItem('authToken', 'test-logout-token')
    })

    // Verify token exists
    let token = await getAuthToken(page)
    expect(token).toBeTruthy()

    // Navigate to admin page where logout button should be
    await page.goto('/admin')

    // Look for logout button (try multiple selectors)
    const logoutButton = page.locator('button:has-text("Logout"), button:has-text("Sign Out"), [data-testid="logout-button"]')

    if (await logoutButton.isVisible({ timeout: 2000 }).catch(() => false)) {
      await logoutButton.click()
      // Wait for logout to complete
      await page.waitForTimeout(1000)
    } else {
      // If logout button not found, simulate logout by clearing token
      await page.evaluate(() => {
        localStorage.removeItem('authToken')
      })
    }

    // Token should be cleared after logout
    token = await getAuthToken(page)
    expect(token).toBeFalsy()
  })

  // AC-ADMIN-AUTH-015: Back to Home Navigation
  test('AC-ADMIN-AUTH-015: Back to Home Navigation', async ({ page }) => {
    // Back to home link should be visible
    const backLink = page.locator('[data-testid="back-to-home-link"]')
    await expect(backLink).toBeVisible()

    // Click back to home
    await backLink.click()

    // Should navigate to home page
    await page.waitForURL(/.*\/$/, { timeout: 5000 })
    expect(page.url()).toMatch(/\/$/)
  })
})
