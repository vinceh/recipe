#!/usr/bin/env node
import * as fs from 'fs';
import * as path from 'path';
import { promisify } from 'util';
import { chromium, Page } from '@playwright/test';

const writeFile = promisify(fs.writeFile);
const mkdir = promisify(fs.mkdir);

interface PageObjectOptions {
  url: string;
  name: string;
  output?: string;
  analyze?: boolean;
}

/**
 * Generate a Page Object class from a URL
 */
class PageObjectGenerator {
  private options: PageObjectOptions;

  constructor(options: PageObjectOptions) {
    this.options = {
      ...options,
      output: options.output || 'tests/pages'
    };
  }

  /**
   * Analyze page and extract common elements
   */
  private async analyzePage(page: Page): Promise<{
    buttons: string[];
    inputs: string[];
    links: string[];
    headings: string[];
  }> {
    console.log('   🔍 Analyzing page structure...');

    const elements = await page.evaluate(() => {
      const getUniqueTexts = (selector: string, attribute: string = 'textContent'): string[] => {
        const elements = document.querySelectorAll(selector);
        const texts = new Set<string>();
        elements.forEach(el => {
          const text = attribute === 'textContent'
            ? el.textContent?.trim()
            : el.getAttribute(attribute);
          if (text && text.length > 0 && text.length < 50) {
            texts.add(text);
          }
        });
        return Array.from(texts).slice(0, 10); // Limit to 10 items
      };

      return {
        buttons: getUniqueTexts('button, [role="button"], input[type="submit"], input[type="button"]'),
        inputs: getUniqueTexts('input[type="text"], input[type="email"], input[type="password"], textarea', 'placeholder'),
        links: getUniqueTexts('a[href]'),
        headings: getUniqueTexts('h1, h2, h3, [role="heading"]')
      };
    });

    return elements;
  }

  /**
   * Generate TypeScript code for the page object
   */
  private generatePageObjectCode(elements?: any): string {
    const className = this.options.name.endsWith('Page')
      ? this.options.name
      : `${this.options.name}Page`;

    const camelCase = (str: string): string => {
      return str.replace(/[^a-zA-Z0-9]+(.)/g, (_, chr) => chr.toUpperCase())
        .replace(/[^a-zA-Z0-9]/g, '')
        .replace(/^./, chr => chr.toLowerCase());
    };

    let locators = '';
    let methods = '';

    if (elements) {
      // Generate button locators and methods
      if (elements.buttons.length > 0) {
        locators += '\n  // Button locators\n';
        methods += '\n  // Button interactions\n';
        elements.buttons.forEach((text: string) => {
          const propName = camelCase(text + 'Button');
          locators += `  readonly ${propName}: Locator;\n`;
          methods += `
  async click${text.replace(/[^a-zA-Z0-9]/g, '')}(): Promise<void> {
    await this.${propName}.click();
  }\n`;
        });
      }

      // Generate input locators and methods
      if (elements.inputs.length > 0) {
        locators += '\n  // Input locators\n';
        methods += '\n  // Input interactions\n';
        elements.inputs.forEach((placeholder: string) => {
          const propName = camelCase(placeholder + 'Input');
          locators += `  readonly ${propName}: Locator;\n`;
          methods += `
  async fill${placeholder.replace(/[^a-zA-Z0-9]/g, '')}(value: string): Promise<void> {
    await this.${propName}.fill(value);
  }\n`;
        });
      }

      // Generate link locators
      if (elements.links.length > 0) {
        locators += '\n  // Link locators\n';
        elements.links.forEach((text: string) => {
          const propName = camelCase(text + 'Link');
          locators += `  readonly ${propName}: Locator;\n`;
        });
      }

      // Generate heading locators
      if (elements.headings.length > 0) {
        locators += '\n  // Heading locators\n';
        elements.headings.forEach((text: string) => {
          const propName = camelCase(text + 'Heading');
          locators += `  readonly ${propName}: Locator;\n`;
        });
      }
    }

    // Generate constructor body
    let constructorBody = '';
    if (elements) {
      if (elements.buttons.length > 0) {
        constructorBody += '\n    // Initialize button locators\n';
        elements.buttons.forEach((text: string) => {
          const propName = camelCase(text + 'Button');
          constructorBody += `    this.${propName} = page.getByRole('button', { name: '${text}' });\n`;
        });
      }

      if (elements.inputs.length > 0) {
        constructorBody += '\n    // Initialize input locators\n';
        elements.inputs.forEach((placeholder: string) => {
          const propName = camelCase(placeholder + 'Input');
          constructorBody += `    this.${propName} = page.getByPlaceholder('${placeholder}');\n`;
        });
      }

      if (elements.links.length > 0) {
        constructorBody += '\n    // Initialize link locators\n';
        elements.links.forEach((text: string) => {
          const propName = camelCase(text + 'Link');
          constructorBody += `    this.${propName} = page.getByRole('link', { name: '${text}' });\n`;
        });
      }

      if (elements.headings.length > 0) {
        constructorBody += '\n    // Initialize heading locators\n';
        elements.headings.forEach((text: string) => {
          const propName = camelCase(text + 'Heading');
          constructorBody += `    this.${propName} = page.getByRole('heading', { name: '${text}' });\n`;
        });
      }
    }

    return `import { Page, Locator, expect } from '@playwright/test';

/**
 * Page Object for ${this.options.url}
 * Generated on ${new Date().toISOString()}
 */
export class ${className} {
  readonly page: Page;
  ${locators || `
  // Add your locators here
  // readonly submitButton: Locator;
  // readonly emailInput: Locator;
  // readonly passwordInput: Locator;`}

  constructor(page: Page) {
    this.page = page;
    ${constructorBody || `
    // Initialize your locators here
    // this.submitButton = page.getByRole('button', { name: 'Submit' });
    // this.emailInput = page.getByLabel('Email');
    // this.passwordInput = page.getByLabel('Password');`}
  }

  /**
   * Navigate to the page
   */
  async goto(): Promise<void> {
    await this.page.goto('${this.options.url}');
  }

  /**
   * Wait for page to be loaded
   */
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
    // Add specific element checks if needed
    // await expect(this.page.getByRole('main')).toBeVisible();
  }
  ${methods || `
  // Add your methods here
  // async login(email: string, password: string): Promise<void> {
  //   await this.emailInput.fill(email);
  //   await this.passwordInput.fill(password);
  //   await this.submitButton.click();
  // }

  // async expectSuccessMessage(): Promise<void> {
  //   await expect(this.page.getByText('Success')).toBeVisible();
  // }`}

  /**
   * Take a screenshot of the page
   */
  async screenshot(name: string): Promise<void> {
    await this.page.screenshot({ path: \`screenshots/\${name}.png\`, fullPage: true });
  }

  /**
   * Verify page title
   */
  async expectTitle(title: string | RegExp): Promise<void> {
    await expect(this.page).toHaveTitle(title);
  }

  /**
   * Verify page URL
   */
  async expectURL(url: string | RegExp): Promise<void> {
    await expect(this.page).toHaveURL(url);
  }
}
`;
  }

  /**
   * Generate the page object file
   */
  async generate(): Promise<void> {
    console.log(`\n🎭 Generating Page Object: ${this.options.name}`);
    console.log(`📍 URL: ${this.options.url}\n`);

    // Create output directory if it doesn't exist
    if (!fs.existsSync(this.options.output!)) {
      await mkdir(this.options.output!, { recursive: true });
      console.log(`   ✓ Created directory: ${this.options.output}`);
    }

    let elements;

    // Analyze page if requested
    if (this.options.analyze) {
      console.log('   🌐 Launching browser...');
      const browser = await chromium.launch({ headless: true });
      const page = await browser.newPage();

      try {
        console.log(`   🔗 Navigating to ${this.options.url}...`);
        await page.goto(this.options.url, { waitUntil: 'networkidle' });
        elements = await this.analyzePage(page);

        console.log('   ✓ Page analysis complete');
        console.log(`     - Found ${elements.buttons.length} buttons`);
        console.log(`     - Found ${elements.inputs.length} inputs`);
        console.log(`     - Found ${elements.links.length} links`);
        console.log(`     - Found ${elements.headings.length} headings`);
      } catch (error) {
        console.warn('   ⚠️ Could not analyze page:', error);
        console.log('   → Generating template without analysis');
      } finally {
        await browser.close();
      }
    }

    // Generate the TypeScript code
    const code = this.generatePageObjectCode(elements);

    // Write the file
    const fileName = this.options.name.endsWith('.ts')
      ? this.options.name
      : `${this.options.name}.ts`;
    const filePath = path.join(this.options.output!, fileName);

    await writeFile(filePath, code);
    console.log(`\n✅ Page Object generated successfully!`);
    console.log(`   📄 File: ${filePath}`);

    // Provide usage example
    const className = this.options.name.endsWith('Page')
      ? this.options.name
      : `${this.options.name}Page`;

    console.log(`
📚 Usage Example:

import { test } from '@playwright/test';
import { ${className} } from './${path.basename(filePath, '.ts')}';

test('example test', async ({ page }) => {
  const ${className.charAt(0).toLowerCase() + className.slice(1)} = new ${className}(page);
  await ${className.charAt(0).toLowerCase() + className.slice(1)}.goto();
  // Add your test logic here
});
`);
  }
}

// Parse command line arguments
async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    console.log(`
Page Object Generator for Playwright

Usage:
  npx tsx generate-page-object.ts --url=<URL> --name=<PageName> [options]

Options:
  --url      Required. The URL of the page to generate object for
  --name     Required. The name of the page object class
  --output   Output directory (default: tests/pages)
  --analyze  Analyze the page and generate locators automatically
  --help     Show this help message

Examples:
  npx tsx generate-page-object.ts --url="/login" --name="LoginPage"
  npx tsx generate-page-object.ts --url="https://example.com" --name="HomePage" --analyze
  npx tsx generate-page-object.ts --url="/dashboard" --name="Dashboard" --output="src/pages"
`);
    process.exit(0);
  }

  // Parse arguments
  const options: PageObjectOptions = {
    url: '',
    name: ''
  };

  args.forEach(arg => {
    const [key, value] = arg.split('=');
    const cleanKey = key.replace('--', '');

    if (cleanKey === 'url') options.url = value;
    if (cleanKey === 'name') options.name = value;
    if (cleanKey === 'output') options.output = value;
    if (cleanKey === 'analyze') options.analyze = true;
  });

  // Validate required arguments
  if (!options.url) {
    console.error('❌ Error: --url is required');
    process.exit(1);
  }
  if (!options.name) {
    console.error('❌ Error: --name is required');
    process.exit(1);
  }

  // Generate the page object
  const generator = new PageObjectGenerator(options);
  try {
    await generator.generate();
  } catch (error) {
    console.error('❌ Error generating page object:', error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

export { PageObjectGenerator };