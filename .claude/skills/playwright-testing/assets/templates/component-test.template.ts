import { test, expect } from '@playwright/experimental-ct-react';
// For Vue: import { test, expect } from '@playwright/experimental-ct-vue';
// For Angular: import { test, expect } from '@playwright/experimental-ct-angular';

// Import your component
import { MyComponent } from './MyComponent';

/**
 * Component Test Template
 * Demonstrates common component testing patterns
 */
test.describe('MyComponent', () => {
  /**
   * Basic rendering test
   */
  test('renders with default props', async ({ mount }) => {
    const component = await mount(<MyComponent />);

    await expect(component).toBeVisible();
    await expect(component).toContainText('Expected Text');
  });

  /**
   * Props testing
   */
  test('renders with custom props', async ({ mount }) => {
    const component = await mount(
      <MyComponent
        title="Custom Title"
        variant="primary"
        disabled={false}
      />
    );

    await expect(component).toHaveAttribute('data-variant', 'primary');
    await expect(component.getByRole('heading')).toHaveText('Custom Title');
  });

  /**
   * Event handling
   */
  test('handles click events', async ({ mount }) => {
    let clickCount = 0;
    const handleClick = () => clickCount++;

    const component = await mount(
      <MyComponent onClick={handleClick} />
    );

    await component.getByRole('button').click();
    expect(clickCount).toBe(1);

    await component.getByRole('button').click();
    expect(clickCount).toBe(2);
  });

  /**
   * State changes
   */
  test('updates state on interaction', async ({ mount }) => {
    const component = await mount(<MyComponent />);

    // Initial state
    await expect(component.getByTestId('counter')).toHaveText('0');

    // Interact and verify state change
    await component.getByRole('button', { name: 'Increment' }).click();
    await expect(component.getByTestId('counter')).toHaveText('1');
  });

  /**
   * Form interactions
   */
  test('handles form submission', async ({ mount }) => {
    let formData: any = null;
    const handleSubmit = (data: any) => {
      formData = data;
    };

    const component = await mount(
      <MyComponent onSubmit={handleSubmit} />
    );

    // Fill form fields
    await component.getByLabel('Name').fill('John Doe');
    await component.getByLabel('Email').fill('john@example.com');
    await component.getByRole('checkbox', { name: 'Subscribe' }).check();

    // Submit form
    await component.getByRole('button', { name: 'Submit' }).click();

    // Verify submission
    expect(formData).toEqual({
      name: 'John Doe',
      email: 'john@example.com',
      subscribe: true
    });
  });

  /**
   * Conditional rendering
   */
  test('conditionally renders content', async ({ mount }) => {
    const component = await mount(
      <MyComponent showDetails={false} />
    );

    // Details hidden initially
    await expect(component.getByTestId('details')).not.toBeVisible();

    // Re-mount with details shown
    await component.unmount();
    const componentWithDetails = await mount(
      <MyComponent showDetails={true} />
    );

    await expect(componentWithDetails.getByTestId('details')).toBeVisible();
  });

  /**
   * Loading states
   */
  test('shows loading state', async ({ mount }) => {
    const component = await mount(
      <MyComponent isLoading={true} />
    );

    await expect(component.getByRole('progressbar')).toBeVisible();
    await expect(component.getByText('Loading...')).toBeVisible();
  });

  /**
   * Error states
   */
  test('displays error message', async ({ mount }) => {
    const component = await mount(
      <MyComponent error="Something went wrong" />
    );

    await expect(component.getByRole('alert')).toBeVisible();
    await expect(component.getByRole('alert')).toContainText('Something went wrong');
  });

  /**
   * Accessibility testing
   */
  test('is keyboard accessible', async ({ mount, page }) => {
    const component = await mount(<MyComponent />);

    // Tab to first interactive element
    await page.keyboard.press('Tab');
    const focusedElement = await page.evaluate(() => document.activeElement?.tagName);
    expect(focusedElement).toBe('BUTTON');

    // Activate with Enter
    await page.keyboard.press('Enter');
    // Verify action was triggered
  });

  /**
   * Responsive behavior
   */
  test('adapts to mobile viewport', async ({ mount, page }) => {
    await page.setViewportSize({ width: 375, height: 667 });

    const component = await mount(<MyComponent />);

    // Mobile-specific assertions
    await expect(component.getByTestId('mobile-menu')).toBeVisible();
    await expect(component.getByTestId('desktop-menu')).not.toBeVisible();
  });

  /**
   * Async data loading
   */
  test('loads async data', async ({ mount }) => {
    const mockData = [
      { id: 1, name: 'Item 1' },
      { id: 2, name: 'Item 2' }
    ];

    const fetchData = () => Promise.resolve(mockData);

    const component = await mount(
      <MyComponent fetchData={fetchData} />
    );

    // Wait for data to load
    await expect(component.getByRole('list')).toBeVisible();
    await expect(component.getByRole('listitem')).toHaveCount(2);
  });

  /**
   * Slots/Children testing (React)
   */
  test('renders children correctly', async ({ mount }) => {
    const component = await mount(
      <MyComponent>
        <span>Child Content</span>
      </MyComponent>
    );

    await expect(component.getByText('Child Content')).toBeVisible();
  });

  /**
   * CSS classes and styles
   */
  test('applies correct styles', async ({ mount }) => {
    const component = await mount(
      <MyComponent variant="success" size="large" />
    );

    await expect(component).toHaveClass(/variant-success/);
    await expect(component).toHaveClass(/size-large/);

    // Check computed styles
    const backgroundColor = await component.evaluate(
      el => window.getComputedStyle(el).backgroundColor
    );
    expect(backgroundColor).toBe('rgb(0, 128, 0)');
  });

  /**
   * Component lifecycle
   */
  test('cleanup on unmount', async ({ mount }) => {
    let unmounted = false;
    const onUnmount = () => {
      unmounted = true;
    };

    const component = await mount(
      <MyComponent onUnmount={onUnmount} />
    );

    await component.unmount();
    expect(unmounted).toBe(true);
  });

  /**
   * Integration with context/providers
   */
  test('uses context values', async ({ mount }) => {
    const ThemeProvider = ({ children }: any) => (
      <div data-theme="dark">{children}</div>
    );

    const component = await mount(
      <ThemeProvider>
        <MyComponent />
      </ThemeProvider>
    );

    await expect(component).toHaveAttribute('data-theme', 'dark');
  });

  /**
   * Snapshot testing
   */
  test('matches snapshot', async ({ mount }) => {
    const component = await mount(
      <MyComponent title="Snapshot Test" />
    );

    await expect(component).toHaveScreenshot('my-component.png');
  });

  /**
   * Performance testing
   */
  test('renders efficiently', async ({ mount }) => {
    const startTime = Date.now();

    const component = await mount(
      <MyComponent items={Array(100).fill(null).map((_, i) => ({
        id: i,
        name: `Item ${i}`
      }))} />
    );

    const renderTime = Date.now() - startTime;
    expect(renderTime).toBeLessThan(1000); // Should render within 1 second

    // Verify virtualization if applicable
    const visibleItems = await component.getByRole('listitem').count();
    expect(visibleItems).toBeLessThan(20); // Only visible items rendered
  });
});