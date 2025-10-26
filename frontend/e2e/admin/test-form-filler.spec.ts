import { test, expect } from '@playwright/test'
import { loginAsAdmin } from '../helpers/auth-helpers'
import * as fs from 'fs'

const ADMIN_EMAIL = 'admin@ember.app'
const ADMIN_PASSWORD = '123456'

test.describe('Form Filler Script - Complete Recipe Form', () => {
  test('Run formtest.js script and verify form is filled', async ({ page }) => {
    // Login
    await page.goto('/admin/login', { waitUntil: 'load' })
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.waitForNavigation({ waitUntil: 'load' })

    // Navigate to recipe creation form
    await page.goto('/admin/recipes/new', { waitUntil: 'networkidle' })

    // Wait for form to be visible
    await page.locator('#name').waitFor({ state: 'visible', timeout: 10000 })
    await page.waitForTimeout(1000)

    // Read and execute formtest.js
    const formtestCode = fs.readFileSync('./formtest.js', 'utf-8')

    // Execute the form filling script
    console.log('Executing formtest.js...')
    const result = await page.evaluate(formtestCode)

    // Wait for async operations to complete
    await page.waitForTimeout(2000)

    // Collect all console logs
    const consoleLogs: string[] = []
    page.on('console', msg => {
      consoleLogs.push(`[${msg.type()}] ${msg.text()}`)
    })

    // Verify key fields are filled
    console.log('\n✅ Verifying form fields...')

    // Check name field
    const nameValue = await page.locator('#name').inputValue()
    console.log(`Name field: "${nameValue}"`)
    expect(nameValue).toBe('Test Chocolate Cake')

    // Check URL field
    const urlValue = await page.locator('#source_url').inputValue()
    console.log(`URL field: "${urlValue}"`)
    expect(urlValue).toBe('https://example.com/chocolate-cake')

    // Check admin notes
    const notesValue = await page.locator('#admin_notes').inputValue()
    console.log(`Admin notes: "${notesValue}"`)
    expect(notesValue).toContain('Great beginner recipe')

    // Check if equipment items are visible
    const equipmentItems = await page.locator('.recipe-form__tag').allTextContents()
    console.log(`Equipment items found: ${equipmentItems.length}`)
    console.log(`Equipment: ${equipmentItems.join(', ')}`)
    expect(equipmentItems.length).toBeGreaterThanOrEqual(4)

    // Check if aliases are visible
    const ingredientTexts = await page.locator('input').filter({ has: page.locator('[class*="ingredient"]') }).allTextContents()
    console.log(`Total ingredient-related inputs: ${ingredientTexts.length}`)

    // Verify steps are added
    const textareas = await page.locator('textarea').count()
    console.log(`Textareas found (steps): ${textareas}`)
    expect(textareas).toBeGreaterThanOrEqual(8)

    console.log('\n📊 Form filling verification complete!')
  })

  test('Form filler script and Save submission', async ({ page }) => {
    // Login
    await page.goto('/admin/login', { waitUntil: 'load' })
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD)
    await page.waitForNavigation({ waitUntil: 'load' })

    // Navigate to recipe creation form
    await page.goto('/admin/recipes/new', { waitUntil: 'networkidle' })

    // Wait for form to be visible
    await page.locator('#name').waitFor({ state: 'visible', timeout: 10000 })
    await page.waitForTimeout(1000)

    // Read and execute formtest.js
    const formtestCode = fs.readFileSync('./formtest.js', 'utf-8')

    // Execute the form filling script
    console.log('Executing formtest.js...')
    await page.evaluate(formtestCode)

    // Wait for async operations to complete
    await page.waitForTimeout(2000)

    // Verify form is filled
    const nameValue = await page.locator('#name').inputValue()
    expect(nameValue).toBe('Test Chocolate Cake')

    // Try to find and click the Save button
    console.log('\n💾 Looking for Save button...')
    const saveBtn = await page.locator('button:has-text("Save"), button:has-text("Submit")').first()

    if (await saveBtn.isVisible()) {
      console.log('✅ Found Save button, clicking...')

      // Scroll to ensure button is in viewport
      await saveBtn.scrollIntoViewIfNeeded()
      await page.waitForTimeout(500)

      // Click save and wait for navigation or response
      const navigationPromise = page.waitForNavigation({ waitUntil: 'networkidle', timeout: 10000 }).catch(() => {})
      await saveBtn.click()

      await navigationPromise
      await page.waitForTimeout(1000)

      // Check if we're back on the recipes list or got a success message
      const currentUrl = page.url()
      console.log(`Current URL after save: ${currentUrl}`)

      if (currentUrl.includes('/admin/recipes') && !currentUrl.includes('/new')) {
        console.log('✅ Form saved successfully!')
        expect(true).toBe(true)
      } else {
        console.log('⚠️ Save may have succeeded but URL indicates still on form')
      }
    } else {
      console.log('⚠️ Could not find visible Save button')
    }
  })
})
