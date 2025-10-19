# Visual Testing Guide for Playwright

## Overview

Visual regression testing captures screenshots of your application and compares them against baseline images to detect unintended visual changes. Playwright provides powerful built-in capabilities for visual testing across browsers and viewports.

## Basic Visual Testing

### Simple Screenshot Comparison

```typescript
import { test, expect } from '@playwright/test';

test('homepage visual test', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png');
});

test('element screenshot', async ({ page }) => {
  await page.goto('/');
  const header = page.getByRole('banner');
  await expect(header).toHaveScreenshot('header.png');
});
```

### Configuration Options

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Global screenshot options
    screenshot: {
      mode: 'only-on-failure',
      fullPage: true
    }
  },

  // Visual regression options
  expect: {
    // Threshold for pixel differences (0-1)
    toHaveScreenshot: { threshold: 0.2 },

    // Maximum allowed pixel difference
    toHaveScreenshot: { maxDiffPixels: 100 },

    // Animations handling
    toHaveScreenshot: { animations: 'disabled' },

    // Custom stylesheets
    toHaveScreenshot: {
      stylePath: path.join(__dirname, 'screenshot.css')
    }
  }
});
```

## Advanced Screenshot Options

### Full Page Screenshots

```typescript
test('full page capture', async ({ page }) => {
  await page.goto('/long-page');

  await expect(page).toHaveScreenshot('full-page.png', {
    fullPage: true,
    animations: 'disabled',
    // Mask dynamic content
    mask: [page.locator('.timestamp')],
    // Clip to specific area
    clip: { x: 0, y: 0, width: 800, height: 600 }
  });
});
```

### Handling Dynamic Content

```typescript
test('screenshot with masked elements', async ({ page }) => {
  await page.goto('/dashboard');

  // Mask dynamic content that changes between tests
  await expect(page).toHaveScreenshot('dashboard.png', {
    mask: [
      page.locator('.timestamp'),
      page.locator('.random-id'),
      page.locator('.user-avatar')
    ],
    // Custom mask color
    maskColor: '#FF00FF'
  });
});

test('wait for stable content', async ({ page }) => {
  await page.goto('/charts');

  // Wait for animations to complete
  await page.waitForFunction(() => {
    const animations = document.getAnimations();
    return animations.length === 0;
  });

  // Wait for fonts to load
  await page.waitForFunction(() => document.fonts.ready);

  // Wait for images to load
  await page.waitForLoadState('networkidle');

  await expect(page).toHaveScreenshot('charts.png');
});
```

### Cross-Browser Visual Testing

```typescript
test.describe('cross-browser visuals', () => {
  ['chromium', 'firefox', 'webkit'].forEach(browserName => {
    test(`renders correctly in ${browserName}`, async ({ page }) => {
      await page.goto('/');

      // Browser-specific screenshot names
      await expect(page).toHaveScreenshot(`homepage-${browserName}.png`);
    });
  });
});
```

## Responsive Visual Testing

### Multiple Viewport Sizes

```typescript
const viewports = [
  { name: 'mobile', width: 375, height: 667 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1920, height: 1080 }
];

viewports.forEach(viewport => {
  test(`responsive layout - ${viewport.name}`, async ({ page }) => {
    await page.setViewportSize({
      width: viewport.width,
      height: viewport.height
    });

    await page.goto('/');
    await expect(page).toHaveScreenshot(
      `homepage-${viewport.name}.png`
    );
  });
});
```

### Device Emulation

```typescript
import { devices } from '@playwright/test';

test('mobile visual test', async ({ browser }) => {
  const context = await browser.newContext({
    ...devices['iPhone 13']
  });
  const page = await context.newPage();

  await page.goto('/');
  await expect(page).toHaveScreenshot('iphone-13.png');

  await context.close();
});
```

## Managing Baselines

### Updating Baselines

```bash
# Update all failed screenshots
npx playwright test --update-snapshots

# Update specific test file
npx playwright test path/to/test.spec.ts --update-snapshots

# Update with custom script
npx tsx scripts/visual-baseline.ts --update
```

### Platform-Specific Baselines

```typescript
test('platform-aware screenshots', async ({ page }, testInfo) => {
  await page.goto('/');

  // Baselines stored per platform
  const platform = process.platform; // 'darwin', 'linux', 'win32'
  await expect(page).toHaveScreenshot(`homepage-${platform}.png`);
});
```

### Custom Baseline Paths

```typescript
// playwright.config.ts
export default defineConfig({
  snapshotDir: './visual-baselines',
  snapshotPathTemplate: '{snapshotDir}/{testFileDir}/{testFileName}-{arg}-{projectName}-{platform}{ext}'
});
```

## Component Visual Testing

### Isolated Component Screenshots

```typescript
test('button variations', async ({ page }) => {
  await page.goto('/components/button');

  const buttons = [
    { variant: 'primary', selector: '.btn-primary' },
    { variant: 'secondary', selector: '.btn-secondary' },
    { variant: 'danger', selector: '.btn-danger' }
  ];

  for (const button of buttons) {
    const element = page.locator(button.selector);
    await expect(element).toHaveScreenshot(
      `button-${button.variant}.png`
    );
  }
});
```

### State-Based Visual Testing

```typescript
test('form field states', async ({ page }) => {
  await page.goto('/components/input');

  const input = page.getByRole('textbox');

  // Default state
  await expect(input).toHaveScreenshot('input-default.png');

  // Focused state
  await input.focus();
  await expect(input).toHaveScreenshot('input-focused.png');

  // Error state
  await input.fill('invalid');
  await input.blur();
  await expect(input).toHaveScreenshot('input-error.png');

  // Disabled state
  await input.evaluate(el => el.disabled = true);
  await expect(input).toHaveScreenshot('input-disabled.png');
});
```

## Advanced Techniques

### Custom Diff Configuration

```typescript
test('custom diff settings', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveScreenshot('homepage.png', {
    // Threshold between 0-1 (0.2 = 20% difference allowed)
    threshold: 0.2,

    // Maximum different pixels
    maxDiffPixels: 100,

    // Pixel ratio threshold
    maxDiffPixelRatio: 0.1,

    // Color difference calculation
    // 'pixelmatch' or 'ssim'
    comparator: 'ssim'
  });
});
```

### Injecting CSS for Screenshots

```typescript
test('screenshot with custom styles', async ({ page }) => {
  await page.goto('/');

  // Hide elements for screenshot
  await page.addStyleTag({
    content: `
      .advertisement { display: none !important; }
      .cookie-banner { display: none !important; }
      * { animation: none !important; }
    `
  });

  await expect(page).toHaveScreenshot('clean-homepage.png');
});
```

### Progressive Loading Visual Tests

```typescript
test('lazy loading images', async ({ page }) => {
  await page.goto('/gallery');

  // Initial state
  await expect(page).toHaveScreenshot('gallery-initial.png');

  // Scroll to trigger lazy loading
  await page.evaluate(() => window.scrollTo(0, 1000));
  await page.waitForTimeout(500);

  await expect(page).toHaveScreenshot('gallery-loaded.png');
});
```

### Dark Mode Visual Testing

```typescript
test.describe('theme variations', () => {
  test('light theme', async ({ page }) => {
    await page.goto('/');
    await page.evaluate(() => {
      document.documentElement.setAttribute('data-theme', 'light');
    });
    await expect(page).toHaveScreenshot('homepage-light.png');
  });

  test('dark theme', async ({ page }) => {
    await page.goto('/');
    await page.evaluate(() => {
      document.documentElement.setAttribute('data-theme', 'dark');
    });
    await expect(page).toHaveScreenshot('homepage-dark.png');
  });
});
```

## Performance Considerations

### Optimizing Screenshot Tests

```typescript
test.describe.configure({ mode: 'parallel' });

test.beforeEach(async ({ page }) => {
  // Disable animations globally
  await page.addInitScript(() => {
    window.matchMedia = () => ({
      matches: false,
      addListener: () => {},
      removeListener: () => {}
    });
  });

  // Set consistent viewport
  await page.setViewportSize({ width: 1280, height: 720 });
});

test('optimized visual test', async ({ page }) => {
  await page.goto('/', {
    waitUntil: 'domcontentloaded' // Don't wait for all resources
  });

  // Wait for critical content only
  await page.waitForSelector('.main-content');

  await expect(page).toHaveScreenshot('page.png', {
    animations: 'disabled',
    caret: 'hide'
  });
});
```

### Selective Visual Testing

```typescript
test('critical UI elements only', async ({ page }) => {
  await page.goto('/');

  // Test only critical components
  const criticalElements = [
    { locator: page.getByRole('banner'), name: 'header' },
    { locator: page.getByRole('navigation'), name: 'nav' },
    { locator: page.locator('.hero'), name: 'hero' }
  ];

  for (const element of criticalElements) {
    await expect(element.locator).toHaveScreenshot(
      `critical-${element.name}.png`
    );
  }
});
```

## CI/CD Integration

### GitHub Actions Setup

```yaml
name: Visual Tests
on: [push, pull_request]

jobs:
  visual-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps

      - name: Run visual tests
        run: npm run test:visual

      - name: Upload baseline updates
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: visual-baselines
          path: tests/__screenshots__/

      - name: Comment on PR
        if: github.event_name == 'pull_request' && failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: 'Visual regression tests failed. Download artifacts to review changes.'
            });
```

### Docker for Consistent Baselines

```dockerfile
FROM mcr.microsoft.com/playwright:v1.48.0-focal

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

CMD ["npm", "run", "test:visual"]
```

## Debugging Visual Tests

### Creating Diff Reports

```typescript
test.afterEach(async ({}, testInfo) => {
  if (testInfo.status === 'failed') {
    const attachments = testInfo.attachments;

    for (const attachment of attachments) {
      if (attachment.name.includes('diff')) {
        console.log(`Visual diff saved: ${attachment.path}`);
      }
    }
  }
});
```

### Interactive Visual Debugging

```typescript
test('debug visual differences', async ({ page }) => {
  await page.goto('/');

  // Pause to inspect visually
  if (process.env.DEBUG_VISUAL) {
    await page.pause();
  }

  await expect(page).toHaveScreenshot('homepage.png');
});
```

## Best Practices

1. **Stabilize content**: Disable animations, wait for fonts, mask dynamic elements
2. **Use consistent environments**: Docker or CI for baseline generation
3. **Organize baselines**: Structure by feature/component
4. **Review changes carefully**: Don't blindly update baselines
5. **Test critical paths**: Focus on important UI elements
6. **Handle flakiness**: Set appropriate thresholds
7. **Document baselines**: Add comments explaining what's tested
8. **Version control baselines**: Track visual changes over time
9. **Optimize performance**: Run visual tests selectively
10. **Monitor test duration**: Balance coverage with speed