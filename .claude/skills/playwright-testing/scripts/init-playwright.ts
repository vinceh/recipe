#!/usr/bin/env node
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';

const writeFile = promisify(fs.writeFile);
const mkdir = promisify(fs.mkdir);
const exists = promisify(fs.exists);

/**
 * Initialize Playwright in an existing project with TypeScript support
 * and best practice configurations
 */
async function initPlaywright() {
  console.log('🎭 Initializing Playwright Testing Environment...\n');

  // Check if package.json exists
  if (!fs.existsSync('package.json')) {
    console.error('❌ No package.json found. Please run this script from your project root.');
    process.exit(1);
  }

  try {
    // Step 1: Install Playwright and TypeScript dependencies
    console.log('📦 Installing Playwright and dependencies...');
    execSync(
      'npm install --save-dev @playwright/test @types/node typescript tsx',
      { stdio: 'inherit' }
    );

    // Step 2: Install Playwright browsers
    console.log('\n🌐 Installing Playwright browsers...');
    execSync('npx playwright install', { stdio: 'inherit' });

    // Step 3: Create directory structure
    console.log('\n📁 Creating test directory structure...');
    const directories = [
      'tests',
      'tests/e2e',
      'tests/components',
      'tests/visual',
      'tests/fixtures',
      'tests/pages',
      'tests/helpers',
      'tests/data'
    ];

    for (const dir of directories) {
      if (!fs.existsSync(dir)) {
        await mkdir(dir, { recursive: true });
        console.log(`   ✓ Created ${dir}`);
      } else {
        console.log(`   ⚠️ ${dir} already exists`);
      }
    }

    // Step 4: Create Playwright config
    console.log('\n⚙️ Creating playwright.config.ts...');
    const playwrightConfig = `import { defineConfig, devices } from '@playwright/test';
import * as path from 'path';

/**
 * See https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './tests',
  testMatch: /.*\\.spec\\.ts$/,

  /* Run tests in files in parallel */
  fullyParallel: true,

  /* Fail the build on CI if you accidentally left test.only in the source code */
  forbidOnly: !!process.env.CI,

  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,

  /* Opt out of parallel tests on CI */
  workers: process.env.CI ? 1 : undefined,

  /* Reporter to use */
  reporter: [
    ['html', { open: 'never' }],
    ['line'],
    ['json', { outputFile: 'test-results.json' }]
  ],

  /* Global timeout */
  timeout: 30000,

  /* Shared settings for all the projects below */
  use: {
    /* Base URL to use in actions like \`await page.goto('/')\` */
    baseURL: process.env.BASE_URL || 'http://localhost:3000',

    /* Collect trace when retrying the failed test */
    trace: 'on-first-retry',

    /* Screenshot on failure */
    screenshot: 'only-on-failure',

    /* Video on failure */
    video: 'retain-on-failure',

    /* Timeout for each action */
    actionTimeout: 15000,

    /* Navigation timeout */
    navigationTimeout: 30000,
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    /* Test against mobile viewports */
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },

    /* Test against branded browsers */
    {
      name: 'Microsoft Edge',
      use: { ...devices['Desktop Edge'], channel: 'msedge' },
    },
    {
      name: 'Google Chrome',
      use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    },
  ],

  /* Run your local dev server before starting the tests */
  webServer: process.env.CI ? undefined : {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    stdout: 'pipe',
    stderr: 'pipe',
  },
});
`;

    await writeFile('playwright.config.ts', playwrightConfig);
    console.log('   ✓ Created playwright.config.ts');

    // Step 5: Create TypeScript config for tests
    console.log('\n📝 Creating TypeScript configuration...');
    const tsConfig = {
      compilerOptions: {
        target: 'ES2020',
        module: 'commonjs',
        lib: ['ES2020', 'DOM', 'DOM.Iterable'],
        strict: true,
        esModuleInterop: true,
        skipLibCheck: true,
        forceConsistentCasingInFileNames: true,
        resolveJsonModule: true,
        moduleResolution: 'node',
        types: ['@playwright/test', 'node'],
        baseUrl: '.',
        paths: {
          '@tests/*': ['tests/*'],
          '@pages/*': ['tests/pages/*'],
          '@fixtures/*': ['tests/fixtures/*'],
          '@helpers/*': ['tests/helpers/*'],
          '@data/*': ['tests/data/*']
        }
      },
      include: ['tests/**/*.ts', 'playwright.config.ts'],
      exclude: ['node_modules', 'dist', 'playwright-report', 'test-results']
    };

    await writeFile('tsconfig.json', JSON.stringify(tsConfig, null, 2));
    console.log('   ✓ Created tsconfig.json');

    // Step 6: Create base fixture
    console.log('\n🔧 Creating base fixtures...');
    const baseFixture = `import { test as base, expect } from '@playwright/test';

// Define custom fixtures
type MyFixtures = {
  // Add custom fixtures here
  testUser: {
    email: string;
    password: string;
  };
};

// Extend base test with custom fixtures
export const test = base.extend<MyFixtures>({
  testUser: async ({}, use) => {
    // Setup: Create test user
    const user = {
      email: \`test.\${Date.now()}@example.com\`,
      password: 'TestPass123!'
    };

    // Use the fixture value
    await use(user);

    // Teardown: Cleanup test user if needed
    // await deleteTestUser(user.email);
  },
});

export { expect };
`;

    await writeFile('tests/fixtures/base.fixture.ts', baseFixture);
    console.log('   ✓ Created base fixture');

    // Step 7: Create example test
    console.log('\n✅ Creating example test...');
    const exampleTest = `import { test, expect } from '../fixtures/base.fixture';

test.describe('Example Test Suite', () => {
  test('should load homepage', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Home/);
  });

  test('should navigate to about page', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('link', { name: 'About' }).click();
    await expect(page).toHaveURL(/.*about/);
  });
});
`;

    await writeFile('tests/e2e/example.spec.ts', exampleTest);
    console.log('   ✓ Created example test');

    // Step 8: Update package.json scripts
    console.log('\n📜 Updating package.json scripts...');
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf-8'));

    packageJson.scripts = {
      ...packageJson.scripts,
      'test:e2e': 'playwright test',
      'test:e2e:ui': 'playwright test --ui',
      'test:e2e:debug': 'playwright test --debug',
      'test:e2e:headed': 'playwright test --headed',
      'test:e2e:chrome': 'playwright test --project=chromium',
      'test:e2e:firefox': 'playwright test --project=firefox',
      'test:e2e:webkit': 'playwright test --project=webkit',
      'test:visual': 'playwright test tests/visual',
      'test:components': 'playwright test tests/components',
      'test:report': 'playwright show-report',
      'test:codegen': 'playwright codegen'
    };

    await writeFile('package.json', JSON.stringify(packageJson, null, 2));
    console.log('   ✓ Updated package.json with test scripts');

    // Step 9: Create .gitignore entries
    console.log('\n🚫 Updating .gitignore...');
    const gitignoreEntries = `
# Playwright
playwright-report/
test-results/
playwright/.cache/
.playwright/
test-results.json
*.trace.zip
`;

    if (fs.existsSync('.gitignore')) {
      fs.appendFileSync('.gitignore', gitignoreEntries);
      console.log('   ✓ Updated .gitignore');
    } else {
      await writeFile('.gitignore', gitignoreEntries);
      console.log('   ✓ Created .gitignore');
    }

    // Success message
    console.log(`
✅ Playwright successfully initialized!

📚 Available Commands:
   npm run test:e2e         - Run all e2e tests
   npm run test:e2e:ui      - Run tests with UI mode
   npm run test:e2e:debug   - Debug tests
   npm run test:e2e:headed  - Run tests in headed mode
   npm run test:visual      - Run visual tests
   npm run test:components  - Run component tests
   npm run test:report      - Show HTML report
   npm run test:codegen     - Generate tests with codegen

📁 Project Structure:
   tests/
   ├── e2e/          - End-to-end tests
   ├── components/   - Component tests
   ├── visual/       - Visual regression tests
   ├── fixtures/     - Custom test fixtures
   ├── pages/        - Page objects
   ├── helpers/      - Test utilities
   └── data/         - Test data

🎯 Next Steps:
   1. Configure your BASE_URL in playwright.config.ts
   2. Create page objects in tests/pages/
   3. Write your first test in tests/e2e/
   4. Run tests with: npm run test:e2e

📖 Documentation: https://playwright.dev
`);

  } catch (error) {
    console.error('❌ Error initializing Playwright:', error);
    process.exit(1);
  }
}

// Run the initialization
initPlaywright();