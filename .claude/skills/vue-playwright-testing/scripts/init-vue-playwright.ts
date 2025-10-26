#!/usr/bin/env node
/**
 * Initialize Playwright testing in a Vue 3 + Vite project
 *
 * Usage:
 *   npx tsx scripts/init-vue-playwright.ts
 *
 * This script:
 * 1. Creates necessary directories (tests/e2e, tests/fixtures, tests/pages)
 * 2. Generates playwright.config.ts if it doesn't exist
 * 3. Creates vue.d.ts for TypeScript support
 * 4. Adds NPM scripts to package.json
 * 5. Creates example test and page object
 */

import fs from 'fs';
import path from 'path';

const cwd = process.cwd();

interface PackageJson {
  scripts?: Record<string, string>;
  devDependencies?: Record<string, string>;
  [key: string]: any;
}

function ensureDir(dir: string): void {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`✅ Created directory: ${dir}`);
  }
}

function fileExists(file: string): boolean {
  return fs.existsSync(file);
}

function createPlaywrightConfig(): void {
  const configPath = path.join(cwd, 'playwright.config.ts');

  if (fileExists(configPath)) {
    console.log('⚠️  playwright.config.ts already exists, skipping...');
    return;
  }

  const config = `import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    reducedMotion: 'reduce',
  },

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
`;

  fs.writeFileSync(configPath, config);
  console.log('✅ Created playwright.config.ts');
}

function createVueTypeDefinitions(): void {
  const defPath = path.join(cwd, 'vue.d.ts');

  if (fileExists(defPath)) {
    console.log('⚠️  vue.d.ts already exists, skipping...');
    return;
  }

  const def = `declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}
`;

  fs.writeFileSync(defPath, def);
  console.log('✅ Created vue.d.ts');
}

function updatePackageJson(): void {
  const pkgPath = path.join(cwd, 'package.json');

  if (!fileExists(pkgPath)) {
    console.log('❌ package.json not found');
    return;
  }

  const pkg: PackageJson = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));

  if (!pkg.scripts) {
    pkg.scripts = {};
  }

  // Add test scripts
  const scripts = {
    'test:e2e': 'playwright test',
    'test:e2e:debug': 'playwright test --debug',
    'test:e2e:headed': 'playwright test --headed',
    'test:e2e:ui': 'playwright test --ui',
    'test:e2e:report': 'playwright show-report',
  };

  let updated = false;
  for (const [key, value] of Object.entries(scripts)) {
    if (!pkg.scripts[key]) {
      pkg.scripts[key] = value;
      updated = true;
    }
  }

  if (updated) {
    fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\\n');
    console.log('✅ Updated package.json with test scripts');
  } else {
    console.log('ℹ️  Test scripts already in package.json');
  }
}

function createExampleTest(): void {
  const testPath = path.join(cwd, 'tests/e2e/example.spec.ts');

  if (fileExists(testPath)) {
    console.log('⚠️  Example test already exists, skipping...');
    return;
  }

  const test = `import { test, expect } from '@playwright/test';

test.describe('Example', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('page loads successfully', async ({ page }) => {
    // Wait for Vue app to mount
    await page.waitForFunction(() => {
      const app = document.querySelector('#app');
      return app && app.hasChildNodes();
    });

    // Verify page title or heading
    const heading = page.getByRole('heading');
    await expect(heading).toBeDefined();
  });

  test('demonstrates semantic locators', async ({ page }) => {
    // Use semantic locators (most stable)
    const button = page.getByRole('button');

    if (await button.isVisible()) {
      await button.click();
    }
  });
});
`;

  fs.writeFileSync(testPath, test);
  console.log('✅ Created example test: tests/e2e/example.spec.ts');
}

function createExamplePageObject(): void {
  const pagePath = path.join(cwd, 'tests/pages/HomePage.ts');

  if (fileExists(pagePath)) {
    console.log('⚠️  Example page object already exists, skipping...');
    return;
  }

  const page = `import { Page, Locator } from '@playwright/test';

export class HomePage {
  readonly page: Page;
  readonly heading: Locator;
  readonly primaryButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.heading = page.getByRole('heading', { level: 1 });
    this.primaryButton = page.getByRole('button', { name: /primary|main|action/i });
  }

  async navigate() {
    await this.page.goto('/');
  }

  async waitForLoad() {
    await this.heading.waitFor({ state: 'visible' });
  }
}
`;

  fs.writeFileSync(pagePath, page);
  console.log('✅ Created example page object: tests/pages/HomePage.ts');
}

function createTestFixtures(): void {
  const fixturePath = path.join(cwd, 'tests/fixtures/auth.ts');

  if (fileExists(fixturePath)) {
    console.log('⚠️  Test fixtures already exist, skipping...');
    return;
  }

  const fixture = `import { test as base } from '@playwright/test';
import { Page } from '@playwright/test';

type AuthFixtures = {
  authenticatedPage: Page;
};

export const test = base.extend<AuthFixtures>({
  authenticatedPage: async ({ page }, use) => {
    // Setup: Authenticate user
    await page.evaluate(() => {
      localStorage.setItem('auth_token', 'test-token');
    });

    // Use authenticated page
    await use(page);

    // Cleanup: Clear auth
    await page.evaluate(() => {
      localStorage.removeItem('auth_token');
    });
  },
});

export { expect } from '@playwright/test';
`;

  fs.writeFileSync(fixturePath, fixture);
  console.log('✅ Created test fixture: tests/fixtures/auth.ts');
}

function createGitIgnore(): void {
  const gitignorePath = path.join(cwd, '.gitignore');

  if (!fileExists(gitignorePath)) {
    const content = \`
/test-results/
/playwright-report/
/blob-report/
/playwright/.cache/
\`;
    fs.writeFileSync(gitignorePath, content);
    console.log('✅ Created .gitignore with Playwright entries');
  } else {
    const content = fs.readFileSync(gitignorePath, 'utf-8');
    const entriesToAdd = [
      '/test-results/',
      '/playwright-report/',
      '/blob-report/',
      '/playwright/.cache/',
    ];

    let updated = false;
    for (const entry of entriesToAdd) {
      if (!content.includes(entry)) {
        fs.appendFileSync(gitignorePath, entry + '\\n');
        updated = true;
      }
    }

    if (updated) {
      console.log('✅ Updated .gitignore with Playwright entries');
    }
  }
}

function main(): void {
  console.log('🚀 Initializing Playwright for Vue 3 + Vite\\n');

  try {
    // Create directories
    ensureDir(path.join(cwd, 'tests/e2e'));
    ensureDir(path.join(cwd, 'tests/fixtures'));
    ensureDir(path.join(cwd, 'tests/pages'));

    // Create configuration
    createPlaywrightConfig();
    createVueTypeDefinitions();

    // Update package.json
    updatePackageJson();

    // Create example files
    createExampleTest();
    createExamplePageObject();
    createTestFixtures();

    // Update gitignore
    createGitIgnore();

    console.log('\\n✅ Playwright initialization complete!\\n');
    console.log('Next steps:');
    console.log('  1. npm install (if prompted)');
    console.log('  2. npm run test:e2e (to run tests)');
    console.log('  3. npm run test:e2e:ui (to run with UI)');
    console.log('  4. Replace example tests with your own\\n');
  } catch (error) {
    console.error('❌ Error during initialization:', error);
    process.exit(1);
  }
}

main();
