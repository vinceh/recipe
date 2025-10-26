// Simple debug script to find RecipeForm component and understand its structure
(function() {
  console.log("🔍 Searching for Vue components...\n");

  const allElements = document.querySelectorAll('*');
  let foundRecipeForm = false;

  for (let elem of allElements) {
    if (elem.__vueParentComponent) {
      const instance = elem.__vueParentComponent.proxy;
      const name = instance?.$options?.name || instance?.__vueParentComponent?.type?.name || 'unknown';

      if (name.includes('Recipe') || name.includes('Form') || instance.formData) {
        console.log(`✅ Found potential RecipeForm: ${name}`);
        console.log(`Element:`, elem.tagName, elem.className.substring(0, 100));
        console.log(`\nInstance properties (first 40):`);
        const keys = Object.keys(instance).slice(0, 40);
        keys.forEach(key => console.log(`  - ${key}`));

        console.log(`\nChecking for formData...`);
        console.log(`  instance.formData:`, typeof instance.formData);
        if (instance.formData) {
          console.log(`  formData type:`, instance.formData.constructor?.name);
          console.log(`  formData.value:`, !!instance.formData.value);
          console.log(`  formData keys:`, Object.keys(instance.formData).slice(0, 10));
        }

        console.log(`\nChecking $data...`);
        const dataKeys = Object.keys(instance.$data || {});
        console.log(`  $data keys:`, dataKeys.slice(0, 10));

        // Try to find which property is the reactive form data
        dataKeys.forEach(key => {
          const value = instance.$data[key];
          if (value && typeof value === 'object' && (value.name !== undefined || value.servings !== undefined)) {
            console.log(`\n  ✓ Found form-like object at $data.${key}`);
            console.log(`    Keys:`, Object.keys(value).slice(0, 10));
          }
        });

        foundRecipeForm = true;
      }
    }
  }

  if (!foundRecipeForm) {
    console.log("❌ Could not find RecipeForm component");
  }
})();
