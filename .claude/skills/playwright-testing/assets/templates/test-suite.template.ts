import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { DashboardPage } from '../pages/DashboardPage';

/**
 * Test Suite Template
 * Demonstrates comprehensive test suite structure and patterns
 */

// Test data
const TEST_DATA = {
  validUser: {
    email: 'test@example.com',
    password: 'ValidPass123!'
  },
  invalidUser: {
    email: 'invalid@example.com',
    password: 'wrong'
  }
};

// Suite-level configuration
test.describe.configure({
  mode: 'parallel', // Run tests in parallel
  retries: 2, // Retry failed tests
  timeout: 30000 // 30 second timeout per test
});

/**
 * Main test suite
 */
test.describe('User Authentication Flow', () => {
  let loginPage: LoginPage;
  let dashboardPage: DashboardPage;

  /**
   * Setup before each test
   */
  test.beforeEach(async ({ page }) => {
    // Initialize page objects
    loginPage = new LoginPage(page);
    dashboardPage = new DashboardPage(page);

    // Navigate to starting point
    await loginPage.goto();

    // Ensure clean state
    await page.context().clearCookies();
  });

  /**
   * Cleanup after each test
   */
  test.afterEach(async ({ page }, testInfo) => {
    // Take screenshot if test failed
    if (testInfo.status === 'failed') {
      await page.screenshot({
        path: `screenshots/${testInfo.title}-failure.png`,
        fullPage: true
      });
    }

    // Log test duration
    console.log(`Test "${testInfo.title}" took ${testInfo.duration}ms`);
  });

  /**
   * Nested describe for logical grouping
   */
  test.describe('Successful Login Scenarios', () => {
    test('user can login with valid credentials', async ({ page }) => {
      // Arrange
      const { email, password } = TEST_DATA.validUser;

      // Act
      await loginPage.fillEmail(email);
      await loginPage.fillPassword(password);
      await loginPage.clickSubmit();

      // Assert
      await expect(page).toHaveURL('/dashboard');
      await expect(dashboardPage.welcomeMessage).toBeVisible();
      await expect(dashboardPage.welcomeMessage).toContainText('Welcome');
    });

    test('user can login and logout', async ({ page }) => {
      // Login
      await loginPage.login(
        TEST_DATA.validUser.email,
        TEST_DATA.validUser.password
      );

      // Verify logged in
      await expect(page).toHaveURL('/dashboard');

      // Logout
      await dashboardPage.logout();

      // Verify logged out
      await expect(page).toHaveURL('/login');
      await expect(loginPage.loginForm).toBeVisible();
    });

    test('remember me persists session', async ({ page, context }) => {
      // Login with remember me
      await loginPage.fillEmail(TEST_DATA.validUser.email);
      await loginPage.fillPassword(TEST_DATA.validUser.password);
      await loginPage.checkRememberMe();
      await loginPage.clickSubmit();

      // Verify logged in
      await expect(page).toHaveURL('/dashboard');

      // Get cookies
      const cookies = await context.cookies();
      const authCookie = cookies.find(c => c.name === 'auth-token');

      // Verify cookie has extended expiry
      expect(authCookie).toBeDefined();
      expect(authCookie?.expires).toBeGreaterThan(Date.now() / 1000 + 86400); // > 1 day
    });
  });

  /**
   * Failed login scenarios
   */
  test.describe('Failed Login Scenarios', () => {
    test('shows error for invalid credentials', async ({ page }) => {
      // Attempt login with invalid credentials
      await loginPage.login(
        TEST_DATA.invalidUser.email,
        TEST_DATA.invalidUser.password
      );

      // Verify error message
      await expect(loginPage.errorMessage).toBeVisible();
      await expect(loginPage.errorMessage).toContainText('Invalid email or password');

      // Verify still on login page
      await expect(page).toHaveURL('/login');
    });

    test('shows error for empty fields', async ({ page }) => {
      // Click submit without filling fields
      await loginPage.clickSubmit();

      // Verify validation errors
      await expect(loginPage.emailError).toBeVisible();
      await expect(loginPage.emailError).toContainText('Email is required');
      await expect(loginPage.passwordError).toBeVisible();
      await expect(loginPage.passwordError).toContainText('Password is required');
    });

    test('shows error for invalid email format', async ({ page }) => {
      // Enter invalid email
      await loginPage.fillEmail('not-an-email');
      await loginPage.fillPassword('somepassword');
      await loginPage.clickSubmit();

      // Verify email validation error
      await expect(loginPage.emailError).toBeVisible();
      await expect(loginPage.emailError).toContainText('Please enter a valid email');
    });

    test('account locks after multiple failed attempts', async ({ page }) => {
      // Attempt login 5 times with wrong password
      for (let i = 0; i < 5; i++) {
        await loginPage.login(
          TEST_DATA.validUser.email,
          'wrongpassword'
        );

        // Clear error for next attempt
        if (i < 4) {
          await page.reload();
        }
      }

      // Verify account locked message
      await expect(loginPage.errorMessage).toContainText('Account locked');
      await expect(loginPage.errorMessage).toContainText('too many failed attempts');
    });
  });

  /**
   * Password recovery flow
   */
  test.describe('Password Recovery', () => {
    test('user can reset password', async ({ page }) => {
      // Click forgot password
      await loginPage.clickForgotPassword();

      // Verify on reset page
      await expect(page).toHaveURL('/reset-password');

      // Enter email
      await page.getByLabel('Email').fill(TEST_DATA.validUser.email);
      await page.getByRole('button', { name: 'Send Reset Link' }).click();

      // Verify success message
      await expect(page.getByText('Reset link sent')).toBeVisible();
    });
  });

  /**
   * Accessibility tests
   */
  test.describe('Accessibility', () => {
    test('login page is keyboard navigable', async ({ page }) => {
      // Tab through form elements
      await page.keyboard.press('Tab');
      await expect(loginPage.emailInput).toBeFocused();

      await page.keyboard.press('Tab');
      await expect(loginPage.passwordInput).toBeFocused();

      await page.keyboard.press('Tab');
      await expect(loginPage.rememberMeCheckbox).toBeFocused();

      await page.keyboard.press('Tab');
      await expect(loginPage.submitButton).toBeFocused();

      // Submit with Enter
      await loginPage.emailInput.fill(TEST_DATA.validUser.email);
      await loginPage.passwordInput.fill(TEST_DATA.validUser.password);
      await loginPage.passwordInput.press('Enter');

      await expect(page).toHaveURL('/dashboard');
    });

    test('login page has proper ARIA labels', async ({ page }) => {
      // Check form has proper role
      await expect(loginPage.loginForm).toHaveAttribute('role', 'form');

      // Check inputs have labels
      await expect(loginPage.emailInput).toHaveAttribute('aria-label', /.+/);
      await expect(loginPage.passwordInput).toHaveAttribute('aria-label', /.+/);

      // Check error messages have proper role
      await loginPage.clickSubmit(); // Trigger errors
      await expect(loginPage.emailError).toHaveAttribute('role', 'alert');
    });
  });

  /**
   * Cross-browser tests
   */
  test.describe('Cross-browser Compatibility', () => {
    ['chromium', 'firefox', 'webkit'].forEach(browserName => {
      test(`login works in ${browserName}`, async ({ page }) => {
        await loginPage.login(
          TEST_DATA.validUser.email,
          TEST_DATA.validUser.password
        );

        await expect(page).toHaveURL('/dashboard');
      });
    });
  });

  /**
   * Mobile responsiveness
   */
  test.describe('Mobile View', () => {
    test.use({
      viewport: { width: 375, height: 667 }
    });

    test('login page is responsive', async ({ page }) => {
      // Verify mobile layout
      await expect(loginPage.loginForm).toBeVisible();

      // Check mobile-specific elements
      const formWidth = await loginPage.loginForm.evaluate(el => el.offsetWidth);
      expect(formWidth).toBeLessThanOrEqual(375);

      // Perform login on mobile
      await loginPage.login(
        TEST_DATA.validUser.email,
        TEST_DATA.validUser.password
      );

      await expect(page).toHaveURL('/dashboard');
    });
  });

  /**
   * Performance tests
   */
  test.describe('Performance', () => {
    test('login completes within acceptable time', async ({ page }) => {
      const startTime = Date.now();

      await loginPage.login(
        TEST_DATA.validUser.email,
        TEST_DATA.validUser.password
      );

      const loginTime = Date.now() - startTime;

      // Login should complete within 3 seconds
      expect(loginTime).toBeLessThan(3000);

      // Check specific metrics
      const metrics = await page.evaluate(() => ({
        domContentLoaded: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
        loadComplete: performance.timing.loadEventEnd - performance.timing.navigationStart
      }));

      expect(metrics.domContentLoaded).toBeLessThan(1000);
      expect(metrics.loadComplete).toBeLessThan(2000);
    });
  });

  /**
   * Data-driven tests
   */
  test.describe('Data-driven Login Tests', () => {
    const testCases = [
      { email: 'user1@example.com', password: 'Pass1!', shouldPass: true },
      { email: 'user2@example.com', password: 'Pass2!', shouldPass: true },
      { email: 'invalid@example.com', password: 'wrong', shouldPass: false }
    ];

    testCases.forEach(({ email, password, shouldPass }) => {
      test(`login ${shouldPass ? 'succeeds' : 'fails'} for ${email}`, async ({ page }) => {
        await loginPage.login(email, password);

        if (shouldPass) {
          await expect(page).toHaveURL('/dashboard');
        } else {
          await expect(loginPage.errorMessage).toBeVisible();
          await expect(page).toHaveURL('/login');
        }
      });
    });
  });

  /**
   * Skip/Only modifiers for test control
   */
  test.skip('work in progress test', async ({ page }) => {
    // This test will be skipped
  });

  test.fixme('broken test to fix later', async ({ page }) => {
    // This test is marked as needing fixes
  });

  // test.only('run only this test', async ({ page }) => {
  //   // Uncomment to run only this test during development
  // });
});