import { Page, expect } from '@playwright/test'

/**
 * Helper functions for authentication testing
 */

/**
 * Login as admin user
 */
export async function loginAsAdmin(page: Page, email: string, password: string) {
  await page.fill('[data-testid="admin-email-input"]', email)
  await page.fill('[data-testid="admin-password-input"]', password)
  await page.click('[data-testid="admin-login-button"]')

  // Wait for navigation after successful login
  await page.waitForURL(/.*\/admin.*/,  { timeout: 5000 }).catch(() => {})
}

/**
 * Clear authentication state (localStorage, cookies)
 */
export async function clearAuthState(page: Page) {
  await page.context().clearCookies()
  // Wait for page to be ready before accessing localStorage
  await page.waitForLoadState('domcontentloaded').catch(() => {})
  try {
    await page.evaluate(() => {
      localStorage.clear()
      sessionStorage.clear()
    })
  } catch (e) {
    // localStorage might not be accessible, skip if error
  }
}

/**
 * Get stored JWT token from localStorage
 */
export async function getAuthToken(page: Page): Promise<string | null> {
  return await page.evaluate(() => {
    return localStorage.getItem('authToken')
  })
}

/**
 * Check if user is authenticated
 */
export async function isAuthenticated(page: Page): Promise<boolean> {
  const token = await getAuthToken(page)
  return !!token
}

/**
 * Wait for admin redirect after login
 */
export async function waitForAdminRedirect(page: Page) {
  await page.waitForURL(/.*\/admin$/, { timeout: 5000 })
}

/**
 * Wait for login error message to appear
 */
export async function waitForLoginError(page: Page) {
  await page.waitForSelector('[role="alert"]', { timeout: 3000 })
}

/**
 * Get error message text
 */
export async function getErrorMessage(page: Page): Promise<string> {
  const error = await page.locator('[class*="error-message"]')
  return await error.textContent() || ''
}

/**
 * Verify form inputs are disabled
 */
export async function verifyFormDisabled(page: Page) {
  const emailInput = page.locator('[data-testid="admin-email-input"]')
  const passwordInput = page.locator('[data-testid="admin-password-input"]')
  const submitButton = page.locator('[data-testid="admin-login-button"]')

  expect(await emailInput.isDisabled()).toBe(true)
  expect(await passwordInput.isDisabled()).toBe(true)
  expect(await submitButton.isDisabled()).toBe(true)
}

/**
 * Verify form inputs are enabled
 */
export async function verifyFormEnabled(page: Page) {
  const emailInput = page.locator('[data-testid="admin-email-input"]')
  const passwordInput = page.locator('[data-testid="admin-password-input"]')

  expect(await emailInput.isDisabled()).toBe(false)
  expect(await passwordInput.isDisabled()).toBe(false)
}

/**
 * Verify loading spinner is visible
 */
export async function verifyLoadingSpinnerVisible(page: Page) {
  const spinner = page.locator('[class*="spinner"]')
  await expect(spinner).toBeVisible()
}

/**
 * Verify password field is masked
 */
export async function verifyPasswordMasked(page: Page) {
  const passwordInput = page.locator('[data-testid="admin-password-input"]')
  const type = await passwordInput.getAttribute('type')
  expect(type).toBe('password')
}

/**
 * Verify email field has correct autocomplete
 */
export async function verifyEmailAutocomplete(page: Page) {
  const emailInput = page.locator('[data-testid="admin-email-input"]')
  const autocomplete = await emailInput.getAttribute('autocomplete')
  expect(autocomplete).toBe('email')
}

/**
 * Verify password field has correct autocomplete
 */
export async function verifyPasswordAutocomplete(page: Page) {
  const passwordInput = page.locator('[data-testid="admin-password-input"]')
  const autocomplete = await passwordInput.getAttribute('autocomplete')
  expect(autocomplete).toBe('current-password')
}

/**
 * Simulate network error by blocking API calls
 */
export async function simulateNetworkError(page: Page) {
  await page.route('**/api/v1/auth/**', (route) => {
    route.abort('failed')
  })
}

/**
 * Get submit button state
 */
export async function isSubmitButtonDisabled(page: Page): Promise<boolean> {
  const button = page.locator('[data-testid="admin-login-button"]')
  return await button.isDisabled()
}
