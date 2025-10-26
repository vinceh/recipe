import { test, expect } from '@playwright/test'
import { loginAsAdmin } from '../helpers/auth-helpers'

const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'

test('Precision reason can be set via component method', async ({ page }) => {
  // Login
  await page.goto('/admin/login', { waitUntil: 'load' })
  await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
  await page.waitForNavigation({ waitUntil: 'load' })

  // Navigate to form
  await page.goto('/admin/recipes/new', { waitUntil: 'load' })
  await page.locator('#name').waitFor({ state: 'visible', timeout: 5000 })

  // Test the exposed method
  const result = await page.evaluate(() => {
    const allElements = document.querySelectorAll('*')
    let recipeFormComponent: any = null
    let foundCount = 0

    // Find the RecipeForm component
    for (let elem of allElements) {
      if ((elem as any).__vueParentComponent) {
        const instance = (elem as any).__vueParentComponent.proxy
        foundCount++

        // Check for setPrecisionReason method
        if (instance?.setPrecisionReason && typeof instance.setPrecisionReason === 'function') {
          console.log('Found RecipeForm component with setPrecisionReason method')
          recipeFormComponent = instance
          break
        }

        // Also check for formData in $options or instance
        if (instance && (instance.formData || instance.$options?.name === 'RecipeForm')) {
          console.log(`Component ${foundCount} has formData: ${!!instance.formData}`)
        }
      }
    }

    console.log(`Checked ${foundCount} Vue components`)

    if (!recipeFormComponent) {
      return { success: false, message: `Could not find RecipeForm component (checked ${foundCount} components)` }
    }

    try {
      // First enable requires_precision
      recipeFormComponent.formData.value.requires_precision = true
      console.log('✅ Enabled requires_precision')

      // Call the exposed method
      recipeFormComponent.setPrecisionReason('baking')
      console.log('✅ Called setPrecisionReason("baking")')

      // Check if the value was set
      const value = recipeFormComponent.formData.value.precision_reason
      console.log(`Precision reason value after method call: ${value}`)

      if (value === 'baking') {
        return { success: true, message: 'Precision reason successfully set to baking' }
      } else {
        return { success: false, message: `Expected "baking" but got "${value}"` }
      }
    } catch (e) {
      return { success: false, message: String(e) }
    }
  })

  console.log(result)
  expect(result.success).toBe(true)

  // Also verify the field is visible when requires_precision is checked
  const requiresPrecisionBtn = page.locator('button').filter({ has: page.locator('#requires_precision') }).first()
  await requiresPrecisionBtn.click()
  await page.waitForTimeout(300)

  // The precision_reason Select should now be visible
  const precisionReasonLabel = await page.locator('label').filter({ hasText: 'Precision Reason' }).first()
  await expect(precisionReasonLabel).toBeVisible()
})
