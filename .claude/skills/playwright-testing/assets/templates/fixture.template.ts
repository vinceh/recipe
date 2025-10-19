import { test as base, expect, Page } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { DashboardPage } from '../pages/DashboardPage';

/**
 * Custom test fixtures for Playwright tests
 * Extends the base test with application-specific fixtures
 */

// Define fixture types
type TestUser = {
  email: string;
  password: string;
  name: string;
  role: 'admin' | 'user';
};

type APIClient = {
  createUser: (data: Partial<TestUser>) => Promise<TestUser>;
  deleteUser: (email: string) => Promise<void>;
  resetDatabase: () => Promise<void>;
};

type PageObjects = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
};

type AuthenticatedPage = {
  page: Page;
  user: TestUser;
};

// Extend base test with custom fixtures
export type TestFixtures = {
  testUser: TestUser;
  apiClient: APIClient;
  pageObjects: PageObjects;
  authenticatedPage: AuthenticatedPage;
};

export const test = base.extend<TestFixtures>({
  /**
   * Test user fixture
   * Creates a unique test user for each test
   */
  testUser: async ({}, use) => {
    const timestamp = Date.now();
    const user: TestUser = {
      email: `test.user.${timestamp}@example.com`,
      password: 'TestPass123!',
      name: `Test User ${timestamp}`,
      role: 'user'
    };

    // Use the test user
    await use(user);

    // Cleanup is handled by apiClient fixture
  },

  /**
   * API client fixture
   * Provides methods for API operations
   */
  apiClient: async ({ playwright }, use) => {
    const baseURL = process.env.API_URL || 'http://localhost:3000/api';

    const apiClient: APIClient = {
      createUser: async (data: Partial<TestUser>) => {
        const response = await playwright.request.newContext()
          .then(context => context.post(`${baseURL}/users`, {
            data: {
              email: data.email || `test.${Date.now()}@example.com`,
              password: data.password || 'TestPass123!',
              name: data.name || 'Test User',
              role: data.role || 'user'
            }
          }));

        return await response.json();
      },

      deleteUser: async (email: string) => {
        await playwright.request.newContext()
          .then(context => context.delete(`${baseURL}/users/${email}`));
      },

      resetDatabase: async () => {
        await playwright.request.newContext()
          .then(context => context.post(`${baseURL}/test/reset`));
      }
    };

    // Use the API client
    await use(apiClient);

    // Cleanup: Reset database after all tests
    // Uncomment if needed:
    // await apiClient.resetDatabase();
  },

  /**
   * Page objects fixture
   * Provides initialized page objects
   */
  pageObjects: async ({ page }, use) => {
    const pageObjects: PageObjects = {
      loginPage: new LoginPage(page),
      dashboardPage: new DashboardPage(page)
    };

    await use(pageObjects);
  },

  /**
   * Authenticated page fixture
   * Provides a pre-authenticated browser context
   */
  authenticatedPage: async ({ browser, testUser, apiClient }, use) => {
    // Create user via API
    const user = await apiClient.createUser(testUser);

    // Create new context with authentication
    const context = await browser.newContext();
    const page = await context.newPage();

    // Perform login
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login(user.email, user.password);

    // Wait for authentication to complete
    await page.waitForURL('/dashboard');

    // Alternatively, set auth token directly:
    // await context.addCookies([{
    //   name: 'auth-token',
    //   value: 'test-token',
    //   domain: 'localhost',
    //   path: '/'
    // }]);

    // Use the authenticated page
    await use({ page, user });

    // Cleanup
    await context.close();
    await apiClient.deleteUser(user.email);
  }
});

/**
 * Worker-scoped fixtures
 * These fixtures are shared across all tests in a worker
 */
export const test_worker = base.extend<{}, { sharedData: Map<string, any> }>({
  sharedData: [async ({}, use) => {
    const data = new Map<string, any>();

    // Setup shared data
    data.set('config', {
      baseURL: process.env.BASE_URL || 'http://localhost:3000',
      apiURL: process.env.API_URL || 'http://localhost:3000/api'
    });

    await use(data);

    // Cleanup
    data.clear();
  }, { scope: 'worker' }]
});

/**
 * Auto-fixtures
 * These fixtures run automatically for every test
 */
export const test_auto = base.extend({
  // Automatically take screenshot on failure
  screenshotOnFailure: [async ({ page }, use, testInfo) => {
    await use();

    // After test
    if (testInfo.status === 'failed') {
      await page.screenshot({
        path: `screenshots/failures/${testInfo.title}-${Date.now()}.png`,
        fullPage: true
      });
    }
  }, { auto: true }],

  // Automatically collect console logs
  collectLogs: [async ({ page }, use) => {
    const logs: string[] = [];
    page.on('console', msg => logs.push(`${msg.type()}: ${msg.text()}`));

    await use();

    // After test
    if (logs.length > 0) {
      console.log('Console logs:', logs);
    }
  }, { auto: true }]
});

/**
 * Parameterized fixtures
 * Create fixtures with different configurations
 */
export const test_mobile = base.extend({
  // Override viewport for mobile tests
  viewport: { width: 375, height: 667 },

  // Add mobile-specific context options
  contextOptions: {
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15',
    hasTouch: true,
    isMobile: true
  }
});

/**
 * Fixture with options
 * Allow tests to customize fixture behavior
 */
export type EnvironmentOptions = {
  environment: 'development' | 'staging' | 'production';
};

export const test_env = base.extend<EnvironmentOptions>({
  environment: ['development', { option: true }],

  // Use environment option in fixture
  baseURL: async ({ environment }, use) => {
    const urls = {
      development: 'http://localhost:3000',
      staging: 'https://staging.example.com',
      production: 'https://example.com'
    };

    await use(urls[environment]);
  }
});

// Export expect for convenience
export { expect };

/**
 * Usage examples:
 *
 * import { test, expect } from './fixtures';
 *
 * // Use custom fixtures
 * test('authenticated user test', async ({ authenticatedPage }) => {
 *   const { page, user } = authenticatedPage;
 *   await expect(page.getByText(`Welcome, ${user.name}`)).toBeVisible();
 * });
 *
 * // Use page objects
 * test('login flow', async ({ pageObjects }) => {
 *   await pageObjects.loginPage.goto();
 *   await pageObjects.loginPage.login('user@example.com', 'password');
 *   await expect(pageObjects.dashboardPage.welcomeMessage).toBeVisible();
 * });
 *
 * // Use API client
 * test('user management', async ({ apiClient, page }) => {
 *   const user = await apiClient.createUser({ role: 'admin' });
 *   // Test with created user
 *   await apiClient.deleteUser(user.email);
 * });
 */