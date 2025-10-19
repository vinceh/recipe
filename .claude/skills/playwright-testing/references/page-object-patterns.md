# Page Object Model Patterns for Playwright

## Overview

The Page Object Model (POM) is a design pattern that creates an abstraction layer between tests and the UI, making tests more maintainable, readable, and reusable. This guide covers advanced POM patterns for Playwright with TypeScript.

## Core Principles

### Single Responsibility
Each page object should represent a single page or component, encapsulating all interactions with that specific part of the application.

### Abstraction
Hide implementation details from tests. Tests should describe "what" to do, not "how" to do it.

### DRY (Don't Repeat Yourself)
Centralize element locators and common actions to avoid duplication across tests.

## Basic Page Object Structure

```typescript
import { Page, Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

## Advanced Patterns

### Base Page Class

Create a base class with common functionality shared across all pages:

```typescript
export abstract class BasePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  abstract path(): string;

  async goto(): Promise<void> {
    await this.page.goto(this.path());
    await this.waitForPageLoad();
  }

  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('networkidle');
  }

  async takeScreenshot(name: string): Promise<void> {
    await this.page.screenshot({
      path: `screenshots/${name}.png`,
      fullPage: true
    });
  }

  async getTitle(): Promise<string> {
    return await this.page.title();
  }

  async getCurrentURL(): Promise<string> {
    return this.page.url();
  }

  async waitForNavigation(url: string | RegExp): Promise<void> {
    await this.page.waitForURL(url);
  }

  async reload(): Promise<void> {
    await this.page.reload();
  }
}

// Concrete implementation
export class HomePage extends BasePage {
  readonly searchInput: Locator;
  readonly searchButton: Locator;

  constructor(page: Page) {
    super(page);
    this.searchInput = page.getByPlaceholder('Search...');
    this.searchButton = page.getByRole('button', { name: 'Search' });
  }

  path(): string {
    return '/';
  }

  async search(query: string): Promise<void> {
    await this.searchInput.fill(query);
    await this.searchButton.click();
  }
}
```

### Page Manager Pattern

Centralize page object creation and management:

```typescript
export class PageManager {
  private readonly page: Page;
  private pages: Map<string, any> = new Map();

  constructor(page: Page) {
    this.page = page;
  }

  private getPage<T>(name: string, PageClass: new (page: Page) => T): T {
    if (!this.pages.has(name)) {
      this.pages.set(name, new PageClass(this.page));
    }
    return this.pages.get(name) as T;
  }

  get login(): LoginPage {
    return this.getPage('login', LoginPage);
  }

  get home(): HomePage {
    return this.getPage('home', HomePage);
  }

  get dashboard(): DashboardPage {
    return this.getPage('dashboard', DashboardPage);
  }

  get profile(): ProfilePage {
    return this.getPage('profile', ProfilePage);
  }

  // Clear cached pages if needed
  clear(): void {
    this.pages.clear();
  }
}

// Usage in tests
test('user journey', async ({ page }) => {
  const pages = new PageManager(page);

  await pages.login.goto();
  await pages.login.login('user@example.com', 'password');

  await pages.dashboard.expectWelcomeMessage();
  await pages.dashboard.navigateToProfile();

  await pages.profile.updateName('John Doe');
});
```

### Component Page Objects

For reusable UI components, create separate page objects:

```typescript
export class NavigationComponent {
  readonly page: Page;
  readonly homeLink: Locator;
  readonly profileLink: Locator;
  readonly settingsLink: Locator;
  readonly logoutButton: Locator;

  constructor(page: Page) {
    this.page = page;
    const nav = page.getByRole('navigation');
    this.homeLink = nav.getByRole('link', { name: 'Home' });
    this.profileLink = nav.getByRole('link', { name: 'Profile' });
    this.settingsLink = nav.getByRole('link', { name: 'Settings' });
    this.logoutButton = nav.getByRole('button', { name: 'Logout' });
  }

  async navigateToHome(): Promise<void> {
    await this.homeLink.click();
  }

  async navigateToProfile(): Promise<void> {
    await this.profileLink.click();
  }

  async logout(): Promise<void> {
    await this.logoutButton.click();
  }
}

// Page with component
export class DashboardPage extends BasePage {
  readonly navigation: NavigationComponent;
  readonly content: Locator;

  constructor(page: Page) {
    super(page);
    this.navigation = new NavigationComponent(page);
    this.content = page.getByRole('main');
  }

  path(): string {
    return '/dashboard';
  }
}
```

### Fixture Pattern

Use Playwright fixtures for page object initialization:

```typescript
import { test as base } from '@playwright/test';

type Pages = {
  loginPage: LoginPage;
  dashboardPage: DashboardPage;
  profilePage: ProfilePage;
};

export const test = base.extend<Pages>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  dashboardPage: async ({ page }, use) => {
    const dashboardPage = new DashboardPage(page);
    await use(dashboardPage);
  },

  profilePage: async ({ page }, use) => {
    const profilePage = new ProfilePage(page);
    await use(profilePage);
  },
});

// Usage in tests
test('user can update profile', async ({ loginPage, profilePage }) => {
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password');

  await profilePage.goto();
  await profilePage.updateName('Jane Doe');
  await profilePage.expectSuccessMessage();
});
```

### Fluent Interface Pattern

Enable method chaining for better readability:

```typescript
export class SearchPage {
  private page: Page;
  private searchInput: Locator;
  private filterButton: Locator;
  private sortDropdown: Locator;
  private results: Locator;

  constructor(page: Page) {
    this.page = page;
    this.searchInput = page.getByRole('searchbox');
    this.filterButton = page.getByRole('button', { name: 'Filter' });
    this.sortDropdown = page.getByRole('combobox', { name: 'Sort by' });
    this.results = page.getByRole('list', { name: 'Search results' });
  }

  async search(query: string): Promise<this> {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
    return this;
  }

  async filterBy(category: string): Promise<this> {
    await this.filterButton.click();
    await this.page.getByRole('checkbox', { name: category }).check();
    await this.page.getByRole('button', { name: 'Apply' }).click();
    return this;
  }

  async sortBy(option: string): Promise<this> {
    await this.sortDropdown.selectOption(option);
    return this;
  }

  async expectResultCount(count: number): Promise<this> {
    await expect(this.results.getByRole('listitem')).toHaveCount(count);
    return this;
  }
}

// Usage
test('search with filters', async ({ page }) => {
  const searchPage = new SearchPage(page);

  await searchPage
    .search('laptop')
    .filterBy('Electronics')
    .sortBy('Price: Low to High')
    .expectResultCount(10);
});
```

### Data Builder Pattern

Separate test data creation from page objects:

```typescript
export class UserBuilder {
  private user: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phone?: string;
    address?: string;
  };

  constructor() {
    this.user = {
      email: `test${Date.now()}@example.com`,
      password: 'TestPass123!',
      firstName: 'John',
      lastName: 'Doe'
    };
  }

  withEmail(email: string): this {
    this.user.email = email;
    return this;
  }

  withName(firstName: string, lastName: string): this {
    this.user.firstName = firstName;
    this.user.lastName = lastName;
    return this;
  }

  withPhone(phone: string): this {
    this.user.phone = phone;
    return this;
  }

  build() {
    return this.user;
  }
}

// Usage in page object
export class RegistrationPage {
  async registerUser(userData: ReturnType<UserBuilder['build']>) {
    await this.fillEmail(userData.email);
    await this.fillPassword(userData.password);
    await this.fillName(userData.firstName, userData.lastName);
    if (userData.phone) {
      await this.fillPhone(userData.phone);
    }
    await this.submit();
  }
}

// Usage in test
test('register new user', async ({ page }) => {
  const user = new UserBuilder()
    .withName('Jane', 'Smith')
    .withPhone('555-0123')
    .build();

  const registrationPage = new RegistrationPage(page);
  await registrationPage.registerUser(user);
});
```

### State Management Pattern

Handle complex application state:

```typescript
export class ApplicationState {
  private page: Page;
  private currentUser?: { email: string; token: string };

  constructor(page: Page) {
    this.page = page;
  }

  async login(email: string, password: string): Promise<void> {
    const response = await this.page.request.post('/api/login', {
      data: { email, password }
    });

    this.currentUser = await response.json();

    // Set authentication in browser context
    await this.page.context().addCookies([{
      name: 'auth-token',
      value: this.currentUser.token,
      url: this.page.url()
    }]);
  }

  async logout(): Promise<void> {
    await this.page.context().clearCookies();
    this.currentUser = undefined;
  }

  isAuthenticated(): boolean {
    return !!this.currentUser;
  }

  getCurrentUser() {
    return this.currentUser;
  }
}

// Usage with page objects
export class AuthenticatedPage extends BasePage {
  protected state: ApplicationState;

  constructor(page: Page, state: ApplicationState) {
    super(page);
    this.state = state;
  }

  async ensureAuthenticated(): Promise<void> {
    if (!this.state.isAuthenticated()) {
      throw new Error('User must be authenticated');
    }
  }
}
```

### Waiting Strategies

Implement intelligent waiting mechanisms:

```typescript
export class WaitablePage {
  private page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async waitForDataLoad(): Promise<void> {
    // Wait for specific API calls
    await Promise.all([
      this.page.waitForResponse(resp =>
        resp.url().includes('/api/data') && resp.status() === 200
      ),
      this.page.waitForLoadState('networkidle')
    ]);
  }

  async waitForAnimation(): Promise<void> {
    // Wait for CSS animations to complete
    await this.page.waitForFunction(() => {
      const animations = document.getAnimations();
      return animations.length === 0 ||
             animations.every(animation => animation.playState === 'finished');
    });
  }

  async waitForElement(selector: string, state: 'attached' | 'detached' | 'visible' | 'hidden' = 'visible'): Promise<void> {
    await this.page.locator(selector).waitFor({ state });
  }

  async waitForCustomCondition(condition: () => boolean | Promise<boolean>): Promise<void> {
    await this.page.waitForFunction(condition);
  }
}
```

## Best Practices

### 1. Keep Page Objects Simple
Page objects should only contain element locators and methods for interacting with the page. Business logic belongs in tests or helper functions.

### 2. Use Descriptive Method Names
Methods should clearly describe what they do from a user's perspective:
```typescript
// Good
async submitLoginForm()
async expectWelcomeMessage()

// Bad
async clickButton()
async checkText()
```

### 3. Return Page Objects for Navigation
When actions navigate to a new page, return the corresponding page object:
```typescript
export class LoginPage {
  async loginSuccessfully(email: string, password: string): Promise<DashboardPage> {
    await this.login(email, password);
    const dashboardPage = new DashboardPage(this.page);
    await dashboardPage.waitForPageLoad();
    return dashboardPage;
  }
}
```

### 4. Implement Proper Error Handling
```typescript
export class FormPage {
  async submitForm(data: FormData): Promise<void> {
    try {
      await this.fillForm(data);
      await this.submit();
      await this.waitForSuccess();
    } catch (error) {
      const screenshot = await this.page.screenshot();
      throw new Error(`Form submission failed: ${error.message}`, {
        cause: { screenshot }
      });
    }
  }
}
```

### 5. Use Type Safety
Leverage TypeScript for better IDE support and error prevention:
```typescript
type SortOption = 'price-asc' | 'price-desc' | 'name' | 'date';

export class ProductListPage {
  async sortBy(option: SortOption): Promise<void> {
    await this.sortDropdown.selectOption(option);
  }
}
```

## Testing Different Page States

```typescript
export class StatefulPage {
  private page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async inLoadingState(): Promise<void> {
    await expect(this.page.getByTestId('loader')).toBeVisible();
  }

  async inErrorState(errorMessage?: string): Promise<void> {
    const error = this.page.getByRole('alert');
    await expect(error).toBeVisible();
    if (errorMessage) {
      await expect(error).toContainText(errorMessage);
    }
  }

  async inSuccessState(): Promise<void> {
    await expect(this.page.getByTestId('success-message')).toBeVisible();
  }

  async inEmptyState(): Promise<void> {
    await expect(this.page.getByText('No data available')).toBeVisible();
  }
}
```

## Common Pitfalls to Avoid

1. **Don't expose Playwright internals**: Keep page objects abstracted from Playwright-specific details
2. **Avoid hard-coded waits**: Use Playwright's built-in waiting mechanisms
3. **Don't mix assertions with actions**: Keep them separate for clarity
4. **Avoid overly complex page objects**: Split large pages into smaller components
5. **Don't duplicate locator definitions**: Define each locator once in the constructor