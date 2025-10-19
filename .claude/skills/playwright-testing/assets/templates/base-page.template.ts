import { Page, Locator, expect } from '@playwright/test';

/**
 * Base Page class with common functionality
 * All page objects should extend this class
 */
export abstract class BasePage {
  protected readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  /**
   * Define the path for this page
   */
  abstract path(): string;

  /**
   * Navigate to this page
   */
  async goto(): Promise<void> {
    await this.page.goto(this.path());
    await this.waitForPageLoad();
  }

  /**
   * Wait for the page to be fully loaded
   */
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
    await this.waitForPageSpecificElements();
  }

  /**
   * Override this method to wait for page-specific elements
   */
  protected async waitForPageSpecificElements(): Promise<void> {
    // Override in child classes if needed
  }

  /**
   * Get the current page title
   */
  async getTitle(): Promise<string> {
    return await this.page.title();
  }

  /**
   * Get the current URL
   */
  getCurrentURL(): string {
    return this.page.url();
  }

  /**
   * Verify the page title
   */
  async expectTitle(title: string | RegExp): Promise<void> {
    await expect(this.page).toHaveTitle(title);
  }

  /**
   * Verify the page URL
   */
  async expectURL(url: string | RegExp): Promise<void> {
    await expect(this.page).toHaveURL(url);
  }

  /**
   * Take a screenshot of the page
   */
  async takeScreenshot(name: string, fullPage: boolean = true): Promise<void> {
    await this.page.screenshot({
      path: `screenshots/${name}.png`,
      fullPage
    });
  }

  /**
   * Wait for navigation to a new page
   */
  async waitForNavigation(url?: string | RegExp): Promise<void> {
    if (url) {
      await this.page.waitForURL(url);
    } else {
      await this.page.waitForLoadState('networkidle');
    }
  }

  /**
   * Reload the current page
   */
  async reload(): Promise<void> {
    await this.page.reload();
    await this.waitForPageLoad();
  }

  /**
   * Go back to the previous page
   */
  async goBack(): Promise<void> {
    await this.page.goBack();
    await this.waitForPageLoad();
  }

  /**
   * Go forward to the next page
   */
  async goForward(): Promise<void> {
    await this.page.goForward();
    await this.waitForPageLoad();
  }

  /**
   * Check if an element is visible
   */
  async isElementVisible(locator: Locator): Promise<boolean> {
    return await locator.isVisible();
  }

  /**
   * Check if an element is enabled
   */
  async isElementEnabled(locator: Locator): Promise<boolean> {
    return await locator.isEnabled();
  }

  /**
   * Wait for an element to be visible
   */
  async waitForElement(locator: Locator, timeout?: number): Promise<void> {
    await locator.waitFor({
      state: 'visible',
      timeout
    });
  }

  /**
   * Wait for an element to be hidden
   */
  async waitForElementToHide(locator: Locator, timeout?: number): Promise<void> {
    await locator.waitFor({
      state: 'hidden',
      timeout
    });
  }

  /**
   * Scroll to an element
   */
  async scrollToElement(locator: Locator): Promise<void> {
    await locator.scrollIntoViewIfNeeded();
  }

  /**
   * Get text content from an element
   */
  async getElementText(locator: Locator): Promise<string> {
    return await locator.textContent() || '';
  }

  /**
   * Get the count of elements matching a locator
   */
  async getElementCount(locator: Locator): Promise<number> {
    return await locator.count();
  }

  /**
   * Wait for network idle
   */
  async waitForNetworkIdle(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Execute JavaScript in the page context
   */
  async executeScript<T>(script: string | Function, ...args: any[]): Promise<T> {
    return await this.page.evaluate(script, ...args);
  }

  /**
   * Add a cookie to the browser context
   */
  async addCookie(cookie: {
    name: string;
    value: string;
    domain?: string;
    path?: string;
  }): Promise<void> {
    await this.page.context().addCookies([{
      ...cookie,
      url: this.page.url()
    }]);
  }

  /**
   * Clear all cookies
   */
  async clearCookies(): Promise<void> {
    await this.page.context().clearCookies();
  }

  /**
   * Get browser console messages
   */
  async getConsoleMessages(): Promise<string[]> {
    const messages: string[] = [];
    this.page.on('console', msg => messages.push(msg.text()));
    return messages;
  }

  /**
   * Handle dialogs (alerts, confirms, prompts)
   */
  async handleDialog(accept: boolean = true, promptText?: string): Promise<void> {
    this.page.once('dialog', async dialog => {
      if (accept) {
        await dialog.accept(promptText);
      } else {
        await dialog.dismiss();
      }
    });
  }

  /**
   * Wait for a specific response
   */
  async waitForResponse(urlPattern: string | RegExp, statusCode?: number): Promise<void> {
    await this.page.waitForResponse(response =>
      (typeof urlPattern === 'string' ? response.url().includes(urlPattern) : urlPattern.test(response.url())) &&
      (statusCode ? response.status() === statusCode : true)
    );
  }

  /**
   * Mock API response
   */
  async mockAPIResponse(url: string | RegExp, response: {
    status?: number;
    body?: string | object;
    headers?: { [key: string]: string };
  }): Promise<void> {
    await this.page.route(url, async route => {
      await route.fulfill({
        status: response.status || 200,
        body: typeof response.body === 'string' ? response.body : JSON.stringify(response.body),
        headers: response.headers
      });
    });
  }
}