import { Page, Locator } from '@playwright/test';

export interface RecipeFormData {
  name: string;
  sourceUrl: string;
  language: string;
  requiresPrecision: boolean;
  precisionReason?: string;
  servingsOriginal: number;
  servingsMin?: number;
  servingsMax?: number;
  prepMinutes: number;
  cookMinutes: number;
  totalMinutes: number;
  adminNotes: string;
  equipment: string[];
  aliases: string[];
  dietaryTags: string[];
  cuisines: string[];
  dishTypes: string[];
  recipeTypes: string[];
  ingredientGroups: IngredientGroup[];
  steps: string[];
}

export interface IngredientGroup {
  name: string;
  items: IngredientItem[];
}

export interface IngredientItem {
  name: string;
  amount?: string;
  unit?: string;
  preparation?: string;
}

export class RecipeFormPage {
  readonly page: Page;

  // Basic fields
  readonly nameInput: Locator;
  readonly sourceUrlInput: Locator;
  readonly adminNotesInput: Locator;
  readonly languageSelect: Locator;
  readonly saveButton: Locator;
  readonly cancelButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.nameInput = page.locator('#name');
    this.sourceUrlInput = page.locator('#source_url');
    this.adminNotesInput = page.locator('#admin_notes');
    this.languageSelect = page.locator('#language');
    this.saveButton = page.getByRole('button', { name: /save|submit/i });
    this.cancelButton = page.getByRole('button', { name: /cancel/i });
  }

  async goto() {
    await this.page.goto('/admin/recipes/new', { waitUntil: 'load' });
    await this.nameInput.waitFor({ state: 'visible', timeout: 5000 });
  }

  async fillBasicInfo(data: {
    name: string;
    sourceUrl: string;
    language: string;
    adminNotes: string;
  }) {
    await this.nameInput.fill(data.name);
    await this.sourceUrlInput.fill(data.sourceUrl);
    await this.selectDropdown('language', data.language);
    await this.adminNotesInput.fill(data.adminNotes);
  }

  async fillServings(data: {
    original: number;
    min?: number;
    max?: number;
  }) {
    const servingsLabel = this.page.getByLabel(/Servings/i);
    const fieldParent = servingsLabel.locator('..');
    const input = fieldParent.locator('input[inputmode="decimal"], input[type="text"]').first();
    await input.fill(String(data.original));
  }

  async fillTiming(data: {
    prepMinutes: number;
    cookMinutes: number;
    totalMinutes: number;
  }) {
    const prepLabel = this.page.getByLabel(/Prep/i);
    const cookLabel = this.page.getByLabel(/Cook/i);
    const totalLabel = this.page.getByLabel(/Total/i);

    // Fill prep time
    const prepField = prepLabel.locator('..');
    const prepInput = prepField.locator('input[inputmode="decimal"], input[type="text"]').first();
    await prepInput.fill(String(data.prepMinutes));

    // Fill cook time
    const cookField = cookLabel.locator('..');
    const cookInput = cookField.locator('input[inputmode="decimal"], input[type="text"]').first();
    await cookInput.fill(String(data.cookMinutes));

    // Fill total time
    const totalField = totalLabel.locator('..');
    const totalInput = totalField.locator('input[inputmode="decimal"], input[type="text"]').first();
    await totalInput.fill(String(data.totalMinutes));
  }

  async setPrecisionRequirement(required: boolean, reason?: string) {
    const requiresPrecisionBtn = this.page.locator('button').filter({
      has: this.page.locator('#requires_precision')
    }).first();

    const checkbox = this.page.locator('#requires_precision');
    const isChecked = await checkbox.isChecked();

    if ((required && !isChecked) || (!required && isChecked)) {
      await requiresPrecisionBtn.click();
      await this.page.waitForTimeout(300);
    }

    if (required && reason) {
      // Use the exposed method to set precision reason
      await this.page.evaluate((value) => {
        const allElements = document.querySelectorAll('*');
        for (let elem of allElements) {
          if ((elem as any).__vueParentComponent) {
            const instance = (elem as any).__vueParentComponent.proxy;
            if (typeof instance?.setPrecisionReason === 'function') {
              instance.setPrecisionReason(value);
              break;
            }
          }
        }
      }, reason);
      await this.page.waitForTimeout(300);
    }
  }

  async addEquipment(items: string[]) {
    for (const item of items) {
      const equipmentLabel = this.page.getByLabel(/Equipment/i).first();
      const fieldParent = equipmentLabel.locator('..');
      const input = fieldParent.locator('input[type="text"]').first();
      const addBtn = fieldParent.getByRole('button', { name: /add/i });

      await input.fill(item);
      await addBtn.click();
      await this.page.waitForTimeout(200);
    }
  }

  async addAliases(aliases: string[]) {
    for (const alias of aliases) {
      const aliasLabel = this.page.getByLabel(/Aliases/i).first();
      const fieldParent = aliasLabel.locator('..');
      const input = fieldParent.locator('input[type="text"]').first();
      const addBtn = fieldParent.getByRole('button', { name: /add/i });

      await input.fill(alias);
      await addBtn.click();
      await this.page.waitForTimeout(200);
    }
  }

  async selectMultiSelect(label: string, values: string[]) {
    const fieldLabel = this.page.getByLabel(new RegExp(label, 'i')).first();
    const fieldParent = fieldLabel.locator('..');
    const multiSelect = fieldParent.locator('[class*="p-multiselect"]').first();

    for (const value of values) {
      // Click to open dropdown
      await multiSelect.click();
      await this.page.waitForTimeout(200);

      // Click the option
      const option = this.page.locator('[role="option"]').filter({
        hasText: new RegExp(value, 'i')
      }).first();
      await option.click();
      await this.page.waitForTimeout(200);
    }

    // Close dropdown by clicking elsewhere
    await this.page.locator('body').click();
    await this.page.waitForTimeout(100);
  }

  async fillDietaryTags(tags: string[]) {
    await this.selectMultiSelect('Dietary Tags', tags);
  }

  async fillCuisines(cuisines: string[]) {
    await this.selectMultiSelect('Cuisines', cuisines);
  }

  async fillDishTypes(types: string[]) {
    await this.selectMultiSelect('Dish Types', types);
  }

  async fillRecipeTypes(types: string[]) {
    await this.selectMultiSelect('Recipe Types', types);
  }

  async addIngredientGroups(groups: IngredientGroup[]) {
    // First group is already present, fill it and add more as needed
    for (let i = 0; i < groups.length; i++) {
      const group = groups[i];

      // Fill group name using ID selector
      const groupNameInput = this.page.locator(`#group-name-${i}`);
      await groupNameInput.fill(group.name);
      await this.page.waitForTimeout(100);

      // Add ingredients to this group
      for (let j = 0; j < group.items.length; j++) {
        const item = group.items[j];

        // Fill ingredient name
        const ingredientNameInputs = this.page.locator('input').filter({
          has: this.page.locator('[placeholder*="ingredient" i]')
        });
        // Find the right ingredient input for this group
        const ingredientSection = this.page.locator('.recipe-form__ingredient-group').nth(i);
        const nameInputs = ingredientSection.locator('input[placeholder*="ingredient" i]');
        const nameInput = nameInputs.nth(j);
        await nameInput.fill(item.name);

        if (item.amount) {
          const amountInputs = ingredientSection.locator('input[placeholder*="amount" i]');
          await amountInputs.nth(j).fill(item.amount);
        }

        if (item.unit) {
          const unitInputs = ingredientSection.locator('input[placeholder*="unit" i]');
          await unitInputs.nth(j).fill(item.unit);
        }

        if (item.preparation) {
          const prepInputs = ingredientSection.locator('input[placeholder*="notes" i]');
          await prepInputs.nth(j).fill(item.preparation);
        }

        // Add another ingredient if not the last one
        if (j < group.items.length - 1) {
          const addIngredientBtn = ingredientSection.getByRole('button', { name: /add ingredient/i });
          await addIngredientBtn.click();
          await this.page.waitForTimeout(200);
        }
      }

      // Add another group if not the last one
      if (i < groups.length - 1) {
        const addGroupBtn = this.page.getByRole('button', { name: /add group|add ingredient group/i });
        await addGroupBtn.click();
        await this.page.waitForTimeout(300);
      }
    }
  }

  async addSteps(steps: string[]) {
    for (let i = 0; i < steps.length; i++) {
      const stepTextareas = this.page.locator('textarea');
      const stepTextarea = stepTextareas.nth(i);
      await stepTextarea.fill(steps[i]);

      // Add another step if not the last one
      if (i < steps.length - 1) {
        const addStepBtn = this.page.getByRole('button', { name: /add step/i });
        await addStepBtn.click();
        await this.page.waitForTimeout(200);
      }
    }
  }

  async fillCompleteForm(data: RecipeFormData) {
    // Fill basic info
    await this.fillBasicInfo({
      name: data.name,
      sourceUrl: data.sourceUrl,
      language: data.language,
      adminNotes: data.adminNotes,
    });

    // Fill servings
    await this.fillServings({
      original: data.servingsOriginal,
      min: data.servingsMin,
      max: data.servingsMax,
    });

    // Fill timing
    await this.fillTiming({
      prepMinutes: data.prepMinutes,
      cookMinutes: data.cookMinutes,
      totalMinutes: data.totalMinutes,
    });

    // Set precision requirement
    await this.setPrecisionRequirement(data.requiresPrecision, data.precisionReason);

    // Add dietary tags
    if (data.dietaryTags.length > 0) {
      await this.fillDietaryTags(data.dietaryTags);
    }

    // Add cuisines
    if (data.cuisines.length > 0) {
      await this.fillCuisines(data.cuisines);
    }

    // Add dish types
    if (data.dishTypes.length > 0) {
      await this.fillDishTypes(data.dishTypes);
    }

    // Add recipe types
    if (data.recipeTypes.length > 0) {
      await this.fillRecipeTypes(data.recipeTypes);
    }

    // Add equipment
    if (data.equipment.length > 0) {
      await this.addEquipment(data.equipment);
    }

    // Add aliases
    if (data.aliases.length > 0) {
      await this.addAliases(data.aliases);
    }

    // Add ingredient groups
    if (data.ingredientGroups.length > 0) {
      await this.addIngredientGroups(data.ingredientGroups);
    }

    // Add steps
    if (data.steps.length > 0) {
      await this.addSteps(data.steps);
    }
  }

  async submitForm() {
    await this.saveButton.click();
    // Wait for navigation to recipes list or success state
    await this.page.waitForNavigation({ waitUntil: 'networkidle', timeout: 10000 }).catch(() => {});
  }

  private async selectDropdown(id: string, value: string) {
    const selectElement = this.page.locator(`#${id}`);
    const parentDiv = selectElement.locator('..');
    const selectComponent = parentDiv.locator('[class*="p-select"]').first();

    // Click to open
    const trigger = selectComponent.locator('button, [role="button"]').first();
    await trigger.click();
    await this.page.waitForTimeout(200);

    // Select option
    const option = this.page.locator('[role="option"]').filter({ hasText: new RegExp(value, 'i') }).first();
    await option.click();
    await this.page.waitForTimeout(200);
  }
}
