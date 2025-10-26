import { test, expect } from '@playwright/test'
import { loginAsAdmin } from '../helpers/auth-helpers'

const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'

test.describe('Form Fill Testing', () => {
  test('Fill entire form via Vue component direct access', async ({ page }) => {
    // Login
    await page.goto('/admin/login', { waitUntil: 'load' })
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.waitForNavigation({ waitUntil: 'load' })

    // Navigate to form
    await page.goto('/admin/recipes/new', { waitUntil: 'load' })
    await page.locator('#name').waitFor({ state: 'visible', timeout: 5000 })

    // Fill form via Vue component
    const result = await page.evaluate(() => {
      let vueComponent: any = null
      const allElements = document.querySelectorAll('*')
      let vueCmpsFound = 0

      // Find Vue component with formData (it's a ref in <script setup>)
      for (let elem of allElements) {
        if ((elem as any).__vueParentComponent) {
          vueCmpsFound++
          const instance = (elem as any).__vueParentComponent.proxy
          const name = instance?.$options?.name || 'unknown'
          console.log(`Found Vue component: ${name}`)

          // Check if formData exists (could be a ref, or direct property)
          if (instance?.formData) {
            console.log(`  - has formData`)
            // If it's a ref, it will have .value property
            const dataObj = instance.formData.value || instance.formData
            if (dataObj && typeof dataObj === 'object' && dataObj.name !== undefined) {
              vueComponent = instance
              console.log(`  - MATCHED! formData has name property`)
              break
            }
          }
        }
      }

      console.log(`Total Vue components found: ${vueCmpsFound}`)
      if (!vueComponent) return { success: false, message: `No Vue component with formData found (checked ${vueCmpsFound} components)` }

      try {
        // Access formData - it's a ref, so we need .value
        const fd = vueComponent.formData.value || vueComponent.formData

        // Basic fields
        fd.name = 'Test Chocolate Cake'
        fd.source_url = 'https://example.com/chocolate-cake'
        fd.language = 'en'
        fd.requires_precision = true
        fd.precision_reason = 'baking'
        fd.admin_notes = 'Great beginner recipe'

        // Servings & timing
        fd.servings = { original: 8, min: 6, max: 12 }
        fd.timing = { prep_minutes: 20, cook_minutes: 35, total_minutes: 55 }

        // Tags
        fd.dietary_tags = ['vegetarian']
        fd.dish_types = ['dessert']
        fd.cuisines = ['american']
        fd.recipe_types = ['baking']
        fd.aliases = ['Choco Cake', 'Easy Cake']
        fd.equipment = ['Mixing bowl', 'Whisk', '9-inch round cake pan', 'Oven']

        // Ingredients
        fd.ingredient_groups = [
          {
            name: 'Dry Ingredients',
            items: [
              { name: 'All-purpose flour', amount: '2', unit: 'cups', preparation: 'sifted', optional: false },
              { name: 'Cocoa powder', amount: '0.75', unit: 'cup', preparation: 'unsweetened', optional: false },
              { name: 'Baking soda', amount: '1.5', unit: 'tsp', preparation: '', optional: false },
              { name: 'Salt', amount: '1', unit: 'tsp', preparation: '', optional: false }
            ]
          },
          {
            name: 'Wet Ingredients',
            items: [
              { name: 'Butter', amount: '0.5', unit: 'cup', preparation: 'softened', optional: false },
              { name: 'Sugar', amount: '1.75', unit: 'cups', preparation: '', optional: false },
              { name: 'Eggs', amount: '2', unit: 'large', preparation: '', optional: false },
              { name: 'Vanilla extract', amount: '2', unit: 'tsp', preparation: '', optional: false },
              { name: 'Hot water', amount: '1', unit: 'cup', preparation: '', optional: false }
            ]
          }
        ]

        // Steps
        fd.steps = [
          { order: 1, instruction: 'Preheat oven to 350°F (175°C)' },
          { order: 2, instruction: 'Mix dry ingredients in a large bowl' },
          { order: 3, instruction: 'In another bowl, cream butter and sugar until light and fluffy' },
          { order: 4, instruction: 'Beat in eggs one at a time, then add vanilla' },
          { order: 5, instruction: 'Alternately add dry ingredients and hot water to wet mixture' },
          { order: 6, instruction: 'Pour batter into greased 9-inch pan' },
          { order: 7, instruction: 'Bake for 30-35 minutes until toothpick comes out clean' },
          { order: 8, instruction: 'Cool in pan for 15 minutes, then turn out onto wire rack' }
        ]

        return { success: true, message: 'Form filled successfully' }
      } catch (e) {
        return { success: false, message: String(e) }
      }
    })

    console.log(result)
    expect(result.success).toBe(true)

    // Verify key fields
    await expect(page.locator('#name')).toHaveValue('Test Chocolate Cake')
    await expect(page.locator('#source_url')).toHaveValue('https://example.com/chocolate-cake')
  })
})
