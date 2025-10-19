import { defineConfig, devices } from '@playwright/test';
import * as path from 'path';

/**
 * Playwright Configuration Template
 * See https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  // Test directory
  testDir: './tests',

  // Test file patterns
  testMatch: /.*\.(test|spec)\.(ts|tsx|js|jsx)$/,

  // Maximum time one test can run
  timeout: 30 * 1000,

  // Maximum time the whole test suite can run
  globalTimeout: 60 * 60 * 1000, // 1 hour

  // Number of test failures to stop the test suite
  maxFailures: process.env.CI ? 10 : undefined,

  // Run tests in parallel
  fullyParallel: true,

  // Fail the build on CI if test.only is left in source code
  forbidOnly: !!process.env.CI,

  // Retry failed tests
  retries: process.env.CI ? 2 : 0,

  // Number of parallel workers
  workers: process.env.CI ? 1 : '50%',

  // Reporter configuration
  reporter: process.env.CI
    ? [
        ['html', { outputFolder: 'playwright-report', open: 'never' }],
        ['junit', { outputFile: 'test-results/junit.xml' }],
        ['json', { outputFile: 'test-results/results.json' }],
        ['list'],
      ]
    : [
        ['html', { outputFolder: 'playwright-report', open: 'on-failure' }],
        ['line'],
      ],

  // Global setup and teardown
  globalSetup: require.resolve('./tests/global-setup.ts'),
  globalTeardown: require.resolve('./tests/global-teardown.ts'),

  // Output directory for test artifacts
  outputDir: 'test-results/',

  // Snapshot options
  snapshotDir: './tests/__screenshots__',
  snapshotPathTemplate: '{snapshotDir}/{testFileDir}/{testFileName}-{arg}-{projectName}-{platform}{ext}',

  // Update snapshots with --update-snapshots flag
  updateSnapshots: process.env.UPDATE_SNAPSHOTS === 'true' ? 'all' : 'missing',

  // Expect options
  expect: {
    // Maximum time expect() should wait
    timeout: 10000,

    // Screenshot comparison options
    toHaveScreenshot: {
      // Threshold for pixel differences (0-1)
      threshold: 0.2,

      // Maximum allowed pixel difference
      maxDiffPixels: 100,

      // Animations mode
      animations: 'disabled',

      // Screenshot scale
      scale: 'css',
    },
  },

  // Shared settings for all projects
  use: {
    // Base URL for all tests
    baseURL: process.env.BASE_URL || 'http://localhost:3000',

    // Browser action timeout
    actionTimeout: 15 * 1000,

    // Navigation timeout
    navigationTimeout: 30 * 1000,

    // Viewport size
    viewport: { width: 1280, height: 720 },

    // Device scale factor
    deviceScaleFactor: 1,

    // Whether to ignore HTTPS errors
    ignoreHTTPSErrors: true,

    // Capture screenshot on failure
    screenshot: {
      mode: 'only-on-failure',
      fullPage: true,
    },

    // Capture video on failure
    video: {
      mode: 'retain-on-failure',
      size: { width: 1280, height: 720 },
    },

    // Capture trace on failure
    trace: 'retain-on-failure',

    // Accept downloads
    acceptDownloads: true,

    // Emulate user locale
    locale: 'en-US',

    // Timezone
    timezoneId: 'America/New_York',

    // Geolocation
    geolocation: { longitude: -74.0060, latitude: 40.7128 },

    // Permissions
    permissions: ['geolocation', 'notifications'],

    // Color scheme
    colorScheme: 'light',

    // User agent
    userAgent: undefined,

    // Offline mode
    offline: false,

    // HTTP credentials
    httpCredentials: process.env.HTTP_USER && process.env.HTTP_PASS
      ? {
          username: process.env.HTTP_USER,
          password: process.env.HTTP_PASS,
        }
      : undefined,

    // Storage state
    storageState: undefined,

    // Extra HTTP headers
    extraHTTPHeaders: {
      'X-Test-Header': 'playwright-test',
    },
  },

  // Projects configuration
  projects: [
    // Desktop browsers
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        // Chrome-specific options
        launchOptions: {
          args: ['--disable-web-security'],
        },
      },
    },

    {
      name: 'firefox',
      use: {
        ...devices['Desktop Firefox'],
        // Firefox-specific options
      },
    },

    {
      name: 'webkit',
      use: {
        ...devices['Desktop Safari'],
        // WebKit-specific options
      },
    },

    // Mobile browsers
    {
      name: 'mobile-chrome',
      use: {
        ...devices['Pixel 5'],
      },
    },

    {
      name: 'mobile-safari',
      use: {
        ...devices['iPhone 12'],
      },
    },

    // Branded browsers
    {
      name: 'edge',
      use: {
        ...devices['Desktop Edge'],
        channel: 'msedge',
      },
    },

    {
      name: 'chrome',
      use: {
        ...devices['Desktop Chrome'],
        channel: 'chrome',
      },
    },

    // Custom project with specific settings
    {
      name: 'authenticated',
      use: {
        ...devices['Desktop Chrome'],
        // Use saved auth state
        storageState: 'tests/auth/user.json',
      },
      dependencies: ['setup'],
    },

    // Setup project for authentication
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // API testing project
    {
      name: 'api',
      testMatch: /.*\.api\.test\.ts/,
      use: {
        // No browser needed for API tests
        baseURL: process.env.API_URL || 'http://localhost:3000/api',
      },
    },

    // Visual regression testing
    {
      name: 'visual',
      testMatch: /.*\.visual\.test\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        // Consistent viewport for visual tests
        viewport: { width: 1920, height: 1080 },
        deviceScaleFactor: 1,
      },
    },

    // Component testing
    {
      name: 'components',
      testMatch: /.*\.component\.test\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },

    // Accessibility testing
    {
      name: 'a11y',
      testMatch: /.*\.a11y\.test\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        // Include accessibility tree
        video: 'off',
        trace: 'off',
      },
    },

    // Performance testing
    {
      name: 'performance',
      testMatch: /.*\.perf\.test\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        launchOptions: {
          args: ['--enable-precise-memory-info'],
        },
      },
    },
  ],

  // Web server configuration
  webServer: process.env.CI
    ? undefined
    : {
        // Command to start the dev server
        command: 'npm run dev',

        // URL to wait for
        url: 'http://localhost:3000',

        // Timeout for the server to start
        timeout: 120 * 1000,

        // Reuse existing server if available
        reuseExistingServer: !process.env.CI,

        // Environment variables
        env: {
          NODE_ENV: 'test',
        },

        // Capture stdout
        stdout: 'pipe',

        // Capture stderr
        stderr: 'pipe',
      },

  // Folder for test artifacts
  // preserveOutput: 'always',

  // Metadata for the test run
  metadata: {
    // Add custom metadata here
    testRun: new Date().toISOString(),
    environment: process.env.TEST_ENV || 'local',
  },
});

/**
 * Environment-specific configurations
 * Use: TEST_ENV=staging npx playwright test
 */
const configs = {
  local: {
    baseURL: 'http://localhost:3000',
    apiURL: 'http://localhost:3000/api',
  },
  staging: {
    baseURL: 'https://staging.example.com',
    apiURL: 'https://api.staging.example.com',
  },
  production: {
    baseURL: 'https://example.com',
    apiURL: 'https://api.example.com',
  },
};

// Apply environment-specific config
if (process.env.TEST_ENV && configs[process.env.TEST_ENV]) {
  const envConfig = configs[process.env.TEST_ENV];
  // Override config here if needed
}