// DOM manipulation form filler - slower timing
(async function() {
  console.log("🍳 Recipe Form Filler - Slow timing version\n");

  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  function findInputInWrapper(wrapper, type = 'text') {
    if (!wrapper) return null;
    if (type === 'number' || type === 'inputnumber') {
      return wrapper.querySelector('input[type="text"], input[inputmode="decimal"], input[inputmode="numeric"]');
    }
    return wrapper.querySelector('input[type="' + type + '"]');
  }

  function setPrimeVueInputValue(input, value) {
    if (!input) return false;
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
    input.dispatchEvent(new Event('blur', { bubbles: true }));
    return true;
  }

  function findPrimeVueComponent(fieldParent, componentClass) {
    if (!fieldParent) return null;
    const selector = '.p-' + componentClass + ', [class*="p-' + componentClass + '"]';
    return fieldParent.querySelector(selector);
  }

  async function clickDropdown(fieldParent, componentClass, delayMs = 200) {
    const component = findPrimeVueComponent(fieldParent, componentClass);
    if (!component) {
      console.log(`⚠️  Could not find ${componentClass}`);
      return null;
    }
    // Find the actual clickable trigger element
    let clickTarget = component.querySelector('button') ||
                      component.querySelector('[role="button"]') ||
                      component.querySelector('.p-select-trigger') ||
                      component.querySelector('.p-multiselect-trigger') ||
                      component;
    clickTarget.click();
    await sleep(delayMs);
    return component;
  }

  async function selectOptionFromDropdown(optionText, delayMs = 150) {
    const options = Array.from(document.querySelectorAll('[role="option"]'));
    const optionLower = optionText.toLowerCase();
    const option = options.find(o => o.textContent.trim().toLowerCase().includes(optionLower));
    if (option) {
      console.log(`  Clicking option: ${option.textContent.trim()}`);
      option.click();
      await sleep(delayMs);
      return true;
    }
    return false;
  }

  console.log("📝 Filling form fields...\n");

  // 1. Fill recipe name
  const nameInput = document.querySelector('#name');
  if (nameInput) {
    setPrimeVueInputValue(nameInput, "Test Chocolate Cake");
    console.log("✅ Filled recipe name");
  }

  // 2. Fill source URL
  const urlInput = document.querySelector('#source_url');
  if (urlInput) {
    setPrimeVueInputValue(urlInput, "https://example.com/chocolate-cake");
    console.log("✅ Filled source URL");
  }

  // 3. Select language
  const languageLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Language'));
  if (languageLabel) {
    const fieldParent = languageLabel.closest('.recipe-form__field');
    await clickDropdown(fieldParent, 'select', 150);
    await selectOptionFromDropdown('English', 100);
    console.log("✅ Selected language");
  }

  // 4. Fill servings
  const servingsLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Servings'));
  if (servingsLabel) {
    const fieldParent = servingsLabel.closest('.recipe-form__field');
    const inputWrapper = fieldParent?.querySelector('.p-inputnumber');
    const input = findInputInWrapper(inputWrapper || fieldParent, 'number');
    if (input) {
      setPrimeVueInputValue(input, "8");
      console.log("✅ Filled servings");
    }
  }

  // 5. Fill prep time
  const prepLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Prep'));
  if (prepLabel) {
    const fieldParent = prepLabel.closest('.recipe-form__field');
    const inputWrapper = fieldParent?.querySelector('.p-inputnumber');
    const input = findInputInWrapper(inputWrapper || fieldParent, 'number');
    if (input) {
      setPrimeVueInputValue(input, "20");
      console.log("✅ Filled prep time");
    }
  }

  // 6. Fill cook time
  const cookLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Cook'));
  if (cookLabel) {
    const fieldParent = cookLabel.closest('.recipe-form__field');
    const inputWrapper = fieldParent?.querySelector('.p-inputnumber');
    const input = findInputInWrapper(inputWrapper || fieldParent, 'number');
    if (input) {
      setPrimeVueInputValue(input, "35");
      console.log("✅ Filled cook time");
    }
  }

  // 7. Fill total time
  const totalLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Total'));
  if (totalLabel) {
    const fieldParent = totalLabel.closest('.recipe-form__field');
    const inputWrapper = fieldParent?.querySelector('.p-inputnumber');
    const input = findInputInWrapper(inputWrapper || fieldParent, 'number');
    if (input) {
      setPrimeVueInputValue(input, "55");
      console.log("✅ Filled total time");
    }
  }

  // 8. Check requires precision
  const precisionButton = Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('Requires precise measurements') || b.textContent.includes('requires precise'));

  if (precisionButton) {
    precisionButton.click();
    await sleep(200);

    // Select precision reason - wait for field to render
    await sleep(500);

    const allLabels = Array.from(document.querySelectorAll('label'));
    let reasonLabel = allLabels.find(l => l.textContent.trim().toLowerCase().includes('reason'));

    if (!reasonLabel) {
      reasonLabel = allLabels.find(l => l.textContent.trim().toLowerCase().includes('precision'));
    }

    if (reasonLabel) {
      const fieldParent = reasonLabel.closest('.recipe-form__field');

      if (fieldParent) {
        await clickDropdown(fieldParent, 'select', 200);
        await sleep(400);

        // Use the existing selectOptionFromDropdown function which works for other dropdowns
        // Try to select "Baking" which is the first option
        const selected = await selectOptionFromDropdown('Baking', 300);
        if (selected) {
          console.log("✅ Set precision reason");
        } else {
          console.log("⚠️  Could not select precision reason");
        }
      }
    }
  } else {
    console.log("⚠️  Could not find requires precision button");
  }

  // 9. Add dietary tags
  const dietaryLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Dietary Tags'));
  if (dietaryLabel) {
    const fieldParent = dietaryLabel.closest('.recipe-form__field');
    await clickDropdown(fieldParent, 'multiselect', 150);
    await selectOptionFromDropdown('Vegetarian', 100);
    document.body.click();
    await sleep(50);
    console.log("✅ Added dietary tag");
  }

  // 10. Add cuisines
  const cuisineLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Cuisines'));
  if (cuisineLabel) {
    const fieldParent = cuisineLabel.closest('.recipe-form__field');
    await clickDropdown(fieldParent, 'multiselect', 150);
    await selectOptionFromDropdown('American', 100);
    document.body.click();
    await sleep(50);
    console.log("✅ Added cuisine");
  }

  // 11. Add dish types
  const dishLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Dish Types'));
  if (dishLabel) {
    const fieldParent = dishLabel.closest('.recipe-form__field');
    await clickDropdown(fieldParent, 'multiselect', 150);
    await selectOptionFromDropdown('Dessert', 100);
    document.body.click();
    await sleep(50);
    console.log("✅ Added dish type");
  }

  // 12. Add recipe types
  const recipeTypeLabel = Array.from(document.querySelectorAll('label')).find(l => l.textContent.includes('Recipe Types'));
  if (recipeTypeLabel) {
    const fieldParent = recipeTypeLabel.closest('.recipe-form__field');
    if (fieldParent) {
      await clickDropdown(fieldParent, 'multiselect', 200);
      await selectOptionFromDropdown('Baking', 150);
    }
  }

  document.body.click();
  await sleep(50);

  // 13. Add equipment
  const equipmentInput = document.querySelector('#equipment');
  if (equipmentInput) {
    const equipmentItems = ["Mixing bowl", "Whisk", "9-inch round cake pan", "Oven"];
    for (const item of equipmentItems) {
      setPrimeVueInputValue(equipmentInput, item);
      const addBtn = equipmentInput.parentElement?.querySelector('button');
      if (addBtn) {
        addBtn.click();
        await sleep(50);
      }
    }
    console.log(`✅ Added ${equipmentItems.length} equipment items`);
  }

  // 14. Add aliases
  const aliasInput = document.querySelector('#aliases');
  if (aliasInput) {
    const aliases = ["Choco Cake", "Easy Cake"];
    for (const alias of aliases) {
      setPrimeVueInputValue(aliasInput, alias);
      const addBtn = aliasInput.parentElement?.querySelector('button');
      if (addBtn) {
        addBtn.click();
        await sleep(50);
      }
    }
    console.log(`✅ Added ${aliases.length} aliases`);
  }

  // 15. Add ingredients
  console.log("\n🥕 Adding ingredients...");

  async function addIngredientsToGroup(groupIndex, groupName, ingredients) {
    const groupContainers = document.querySelectorAll('[class*="ingredient-group"]');
    if (groupContainers.length <= groupIndex) {
      console.log(`⚠️  Could not find ingredient group at index ${groupIndex}`);
      return false;
    }

    const groupContainer = groupContainers[groupIndex];

    // Find group name input - look for the label "Group Name" and get the input after it
    const labels = Array.from(groupContainer.querySelectorAll('label'));
    const groupNameLabel = labels.find(l => l.textContent.toLowerCase().includes('group'));
    let groupNameInput = null;

    if (groupNameLabel) {
      // Get the input field in the same field parent as the label
      const fieldParent = groupNameLabel.closest('[class*="field"]');
      if (fieldParent) {
        groupNameInput = fieldParent.querySelector('input[type="text"]');
      }
    }

    // Fallback: look for input with id containing "group-name"
    if (!groupNameInput) {
      groupNameInput = groupContainer.querySelector('input[id*="group-name"]');
    }

    if (groupNameInput) {
      setPrimeVueInputValue(groupNameInput, groupName);
      console.log(`  ✓ Set group name: ${groupName}`);
    } else {
      console.log(`  ⚠️  Could not find group name input for group ${groupIndex}`);
    }

    // Add ingredients
    for (let i = 0; i < ingredients.length; i++) {
      const ing = ingredients[i];

      // If not the first ingredient, add a new one
      if (i > 0) {
        const addIngBtn = Array.from(groupContainer.querySelectorAll('button')).find(b => b.textContent.includes('Add Ingredient'));
        if (addIngBtn) {
          console.log(`  Adding ingredient ${i + 1}...`);
          addIngBtn.click();
          await sleep(500); // Increased wait time for form to initialize
        }
      }

      // Find ALL ingredient name inputs in this group (exclude group-name inputs!)
      let allIngInputs = Array.from(groupContainer.querySelectorAll('input[placeholder*="ingredient" i], input[id*="ingredient-name"]')).filter(inp => !inp.id.includes('group-name'));

      if (allIngInputs.length <= i) {
        console.log(`  ⚠️  Ingredient ${i} not found. Found ${allIngInputs.length} total ingredients.`);
        continue;
      }

      const nameInput = allIngInputs[i];

      // Find the closest parent container that holds this ingredient's inputs
      let ingredientContainer = nameInput.parentElement;
      let depth = 0;
      while (ingredientContainer && depth < 10) {
        const hasAmount = ingredientContainer.querySelector('input[placeholder*="amount" i], input[id*="ingredient-amount"]');
        const hasUnit = ingredientContainer.querySelector('input[placeholder*="unit" i], input[id*="ingredient-unit"]');
        if (hasAmount && hasUnit) {
          break;
        }
        ingredientContainer = ingredientContainer.parentElement;
        depth++;
      }

      // Get all inputs from this container
      const amountInput = ingredientContainer?.querySelector('input[placeholder*="amount" i], input[id*="ingredient-amount"]');
      const unitInput = ingredientContainer?.querySelector('input[placeholder*="unit" i], input[id*="ingredient-unit"]');
      const prepInput = ingredientContainer?.querySelector('input[placeholder*="notes" i], input[id*="ingredient-notes"]');

      // Fill the inputs
      setPrimeVueInputValue(nameInput, ing.name);
      console.log(`    ✓ ${ing.name}`);

      if (amountInput) {
        setPrimeVueInputValue(amountInput, ing.amount);
      }
      if (unitInput) {
        setPrimeVueInputValue(unitInput, ing.unit);
      }
      if (prepInput) {
        setPrimeVueInputValue(prepInput, ing.prep);
      }

      await sleep(100);
    }
    return true;
  }

  // Add first ingredient group
  const firstGroupNameInput = document.querySelector('[id^="group-name-"]');
  if (firstGroupNameInput) {
    const ingredients = [
      { name: "All-purpose flour", amount: "2", unit: "cups", prep: "sifted" },
      { name: "Cocoa powder", amount: "0.75", unit: "cup", prep: "unsweetened" },
      { name: "Baking soda", amount: "1.5", unit: "tsp", prep: "" },
      { name: "Salt", amount: "1", unit: "tsp", prep: "" }
    ];

    if (await addIngredientsToGroup(0, "Dry Ingredients", ingredients)) {
      console.log(`✅ Added ${ingredients.length} ingredients to Dry Ingredients group`);
    }
  }

  // Add second ingredient group
  const addGroupBtn = Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('Add Ingredient Group'));
  if (addGroupBtn) {
    console.log("📋 Found 'Add Ingredient Group' button, clicking...");
    addGroupBtn.click();
    await sleep(200);

    const ingredients = [
      { name: "Butter", amount: "0.5", unit: "cup", prep: "softened" },
      { name: "Sugar", amount: "1.75", unit: "cups", prep: "" },
      { name: "Eggs", amount: "2", unit: "large", prep: "" },
      { name: "Vanilla extract", amount: "2", unit: "tsp", prep: "" },
      { name: "Hot water", amount: "1", unit: "cup", prep: "" }
    ];

    if (await addIngredientsToGroup(1, "Wet Ingredients", ingredients)) {
      console.log(`✅ Added ${ingredients.length} ingredients to Wet Ingredients group`);
    }
  } else {
    console.log("⚠️  Could not find 'Add Ingredient Group' button");
  }

  // 16. Add steps
  console.log("\n📖 Adding recipe steps...");
  const steps = [
    "Preheat oven to 350°F (175°C)",
    "Mix dry ingredients in a large bowl",
    "In another bowl, cream butter and sugar until light and fluffy",
    "Beat in eggs one at a time, then add vanilla",
    "Alternately add dry ingredients and hot water to wet mixture",
    "Pour batter into greased 9-inch pan",
    "Bake for 30-35 minutes until toothpick comes out clean",
    "Cool in pan for 15 minutes, then turn out onto wire rack"
  ];

  for (let i = 0; i < steps.length; i++) {
    if (i > 0) {
      const addStepBtn = Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('Add Step'));
      if (addStepBtn) {
        addStepBtn.click();
        await sleep(100);
      }
    }

    const textareas = Array.from(document.querySelectorAll('textarea'));
    const stepTextarea = textareas[i];

    if (stepTextarea) {
      setPrimeVueInputValue(stepTextarea, steps[i]);
    }
  }
  console.log(`✅ Added ${steps.length} recipe steps`);

  // 17. Add admin notes
  const adminNotesTextarea = document.querySelector('#admin_notes');
  if (adminNotesTextarea) {
    setPrimeVueInputValue(adminNotesTextarea, "Great beginner recipe for testing all fields");
    console.log("✅ Filled admin notes");
  }

  console.log("\n✨ Form filling complete!");
  console.log("💾 Scroll down and click the Save button to submit");
})();
