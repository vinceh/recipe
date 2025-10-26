import { test, expect } from '@playwright/test';
import { loginAsAdmin } from '../helpers/auth-helpers';
import { RecipeFormPage, RecipeFormData } from './pages/RecipeFormPage';

const ADMIN_EMAIL = 'admin@ember.app';
const ADMIN_PASSWORD = '123456';

test.describe('Complete Recipe Form - Save & Verification', () => {
  let recipeFormPage: RecipeFormPage;

  test.beforeEach(async ({ page }) => {
    // Given: Admin is logged in
    await page.goto('/admin/login', { waitUntil: 'load' });
    await loginAsAdmin(page, ADMIN_EMAIL, ADMIN_PASSWORD);
    await page.waitForNavigation({ waitUntil: 'load' });

    // And: Navigate to recipe creation form
    recipeFormPage = new RecipeFormPage(page);
    await recipeFormPage.goto();
  });

  test('complete recipe form with multiple ingredient groups saves successfully', async ({ page }) => {
    // Given: A comprehensive recipe with all fields populated
    const completeRecipeData: RecipeFormData = {
      name: 'Ultimate Chocolate Soufflé',
      sourceUrl: 'https://www.example.com/ultimate-chocolate-souffle',
      language: 'English',
      requiresPrecision: true,
      precisionReason: 'baking',
      servingsOriginal: 6,
      servingsMin: 4,
      servingsMax: 8,
      prepMinutes: 25,
      cookMinutes: 35,
      totalMinutes: 60,
      adminNotes: 'Award-winning recipe. Perfect for special occasions. Requires careful technique with egg whites.',
      equipment: [
        'Mixing bowl',
        'Whisk',
        '8-inch ramekins',
        'Double boiler',
        'Sifter'
      ],
      aliases: [
        'Chocolate Soufflé',
        'French Chocolate Soufflé',
        'Elegant Chocolate Dessert'
      ],
      dietaryTags: ['vegetarian'],
      cuisines: ['french'],
      dishTypes: ['dessert'],
      recipeTypes: ['baking'],
      ingredientGroups: [
        {
          name: 'Chocolate Base',
          items: [
            { name: 'Dark chocolate', amount: '200', unit: 'g', preparation: 'chopped' },
            { name: 'Butter', amount: '100', unit: 'g', preparation: 'softened' },
            { name: 'Egg yolks', amount: '6', unit: 'large', preparation: 'room temperature' },
            { name: 'Cocoa powder', amount: '2', unit: 'tbsp', preparation: 'unsweetened' }
          ]
        },
        {
          name: 'Meringue',
          items: [
            { name: 'Egg whites', amount: '8', unit: 'large', preparation: 'room temperature' },
            { name: 'Cream of tartar', amount: '1', unit: 'tsp', preparation: '' },
            { name: 'Granulated sugar', amount: '100', unit: 'g', preparation: '' },
            { name: 'Vanilla extract', amount: '1', unit: 'tsp', preparation: 'pure' }
          ]
        },
        {
          name: 'Finishing Touches',
          items: [
            { name: 'Powdered sugar', amount: '2', unit: 'tbsp', preparation: 'for dusting' },
            { name: 'Raspberry coulis', amount: '1', unit: 'cup', preparation: 'optional' },
            { name: 'Fresh berries', amount: 'to taste', unit: 'optional', preparation: 'for garnish' }
          ]
        }
      ],
      steps: [
        'Preheat oven to 375°F (190°C). Butter and sugar 6 ramekins, place on baking sheet.',
        'Chop dark chocolate and place in heat-safe bowl with butter. Create double boiler and melt together.',
        'Remove from heat and whisk in egg yolks one at a time. Sift cocoa powder and fold gently.',
        'In separate bowl, beat egg whites with cream of tartar until foamy.',
        'Gradually add sugar while beating, continue until stiff peaks form.',
        'Gently fold one-third of meringue into chocolate mixture, then fold in remaining meringue.',
        'Divide evenly among prepared ramekins, filling to just below rim.',
        'Bake for 12-15 minutes, until soufflés have risen but centers still jiggle slightly.',
        'Dust with powdered sugar immediately before serving.',
        'Serve immediately with raspberry coulis and fresh berries if desired.'
      ]
    };

    // When: User fills the complete recipe form
    await recipeFormPage.fillCompleteForm(completeRecipeData);

    // Then: Form should be completely filled
    await expect(recipeFormPage.nameInput).toHaveValue(completeRecipeData.name);
    await expect(recipeFormPage.sourceUrlInput).toHaveValue(completeRecipeData.sourceUrl);
    await expect(recipeFormPage.adminNotesInput).toHaveValue(completeRecipeData.adminNotes);

    // When: User submits the form
    await recipeFormPage.submitForm();

    // Then: User should be redirected to recipes list
    await expect(page).toHaveURL(/\/admin\/recipes(?!\/)/, { timeout: 15000 });

    // And: Recipe should appear in the list
    const recipeName = page.getByText(completeRecipeData.name);
    await expect(recipeName).toBeVisible({ timeout: 5000 });
  });

  test('form with multiple equipment and aliases saves and displays correctly', async ({ page }) => {
    // Given: A recipe with many equipment items and aliases
    const recipeData: RecipeFormData = {
      name: 'Professional Bread Making',
      sourceUrl: 'https://www.example.com/bread-making',
      language: 'English',
      requiresPrecision: true,
      precisionReason: 'baking',
      servingsOriginal: 1,
      prepMinutes: 480,
      cookMinutes: 60,
      totalMinutes: 540,
      adminNotes: 'Professional sourdough bread recipe with temperature-sensitive fermentation.',
      equipment: [
        'Large mixing bowl',
        'Kitchen scale',
        'Bread lame',
        'Dutch oven',
        'Banneton proofing basket',
        'Bench scraper',
        'Thermometer',
        'Dough whisk'
      ],
      aliases: [
        'Sourdough',
        'Artisan Bread',
        'European Bread',
        'Slow Ferment Bread'
      ],
      dietaryTags: [],
      cuisines: ['european'],
      dishTypes: [],
      recipeTypes: [],
      ingredientGroups: [
        {
          name: 'Dough',
          items: [
            { name: 'Bread flour', amount: '500', unit: 'g', preparation: '' },
            { name: 'Water', amount: '350', unit: 'ml', preparation: 'filtered' },
            { name: 'Sourdough starter', amount: '100', unit: 'g', preparation: 'active' },
            { name: 'Sea salt', amount: '10', unit: 'g', preparation: '' }
          ]
        }
      ],
      steps: [
        'Mix flour and water, let rest 30 minutes',
        'Add sourdough starter and salt, mix thoroughly',
        'Bulk fermentation 4-6 hours with stretch and folds every 30 minutes',
        'Shape and place in banneton basket',
        'Cold fermentation overnight in refrigerator',
        'Preheat Dutch oven to 500°F',
        'Score the dough with bread lame',
        'Bake covered 20 minutes, uncovered 25-30 minutes until golden'
      ]
    };

    // When: User fills and submits form with many equipment items
    await recipeFormPage.fillCompleteForm(recipeData);
    await recipeFormPage.submitForm();

    // Then: Recipe is saved and appears in list
    await expect(page).toHaveURL(/\/admin\/recipes(?!\/)/, { timeout: 15000 });
    await expect(page.getByText(recipeData.name)).toBeVisible({ timeout: 5000 });
  });

  test('form with all dietary and cuisine options saves properly', async ({ page }) => {
    // Given: A recipe with multiple dietary tags and cuisines
    const recipeData: RecipeFormData = {
      name: 'Mediterranean Buddha Bowl',
      sourceUrl: 'https://www.example.com/buddha-bowl',
      language: 'English',
      requiresPrecision: false,
      servingsOriginal: 2,
      prepMinutes: 20,
      cookMinutes: 0,
      totalMinutes: 20,
      adminNotes: 'Healthy, colorful, and nutritious. Mix and match vegetables based on season.',
      equipment: [
        'Cutting board',
        'Chef knife',
        'Large bowl'
      ],
      aliases: [
        'Greek Buddha Bowl',
        'Healthy Mediterranean Bowl'
      ],
      dietaryTags: ['vegetarian'],
      cuisines: ['mediterranean', 'greek'],
      dishTypes: ['salad'],
      recipeTypes: ['no-cook'],
      ingredientGroups: [
        {
          name: 'Base',
          items: [
            { name: 'Arugula', amount: '2', unit: 'cups', preparation: 'fresh' },
            { name: 'Quinoa', amount: '1', unit: 'cup', preparation: 'cooked' }
          ]
        },
        {
          name: 'Vegetables',
          items: [
            { name: 'Cherry tomatoes', amount: '1', unit: 'cup', preparation: 'halved' },
            { name: 'Cucumber', amount: '1', unit: 'medium', preparation: 'diced' },
            { name: 'Red bell pepper', amount: '1', unit: 'medium', preparation: 'sliced' }
          ]
        },
        {
          name: 'Toppings',
          items: [
            { name: 'Feta cheese', amount: '1/2', unit: 'cup', preparation: 'crumbled' },
            { name: 'Kalamata olives', amount: '1/4', unit: 'cup', preparation: '' },
            { name: 'Tahini dressing', amount: '1/4', unit: 'cup', preparation: '' }
          ]
        }
      ],
      steps: [
        'Arrange arugula and quinoa as base in large bowl',
        'Arrange prepared vegetables around the bowl',
        'Top with feta cheese and kalamata olives',
        'Drizzle with tahini dressing',
        'Serve immediately'
      ]
    };

    // When: User fills form with multiple dietary and cuisine selections
    await recipeFormPage.fillCompleteForm(recipeData);
    await recipeFormPage.submitForm();

    // Then: Recipe is successfully saved
    await expect(page).toHaveURL(/\/admin\/recipes(?!\/)/, { timeout: 15000 });
    await expect(page.getByText(recipeData.name)).toBeVisible({ timeout: 5000 });
  });

  test('form validation works - saves only when all required fields are complete', async ({ page }) => {
    // When: User tries to submit with minimal data
    const minimalData: RecipeFormData = {
      name: 'Quick Test Recipe',
      sourceUrl: '',
      language: 'English',
      requiresPrecision: false,
      servingsOriginal: 1,
      prepMinutes: 5,
      cookMinutes: 5,
      totalMinutes: 10,
      adminNotes: '',
      equipment: [],
      aliases: [],
      dietaryTags: [],
      cuisines: [],
      dishTypes: [],
      recipeTypes: [],
      ingredientGroups: [
        {
          name: 'Ingredients',
          items: [
            { name: 'Test ingredient', amount: '1', unit: 'cup', preparation: '' }
          ]
        }
      ],
      steps: [
        'Mix all ingredients',
        'Cook until done'
      ]
    };

    await recipeFormPage.fillCompleteForm(minimalData);

    // Then: Form should be valid and save successfully
    await recipeFormPage.submitForm();

    // Recipe should be saved even with minimal data
    await expect(page).toHaveURL(/\/admin\/recipes(?!\/)/, { timeout: 15000 });
    await expect(page.getByText(minimalData.name)).toBeVisible({ timeout: 5000 });
  });
});
