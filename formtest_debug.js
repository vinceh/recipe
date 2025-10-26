// Debug script to find the Vue component structure
(function() {
  console.log("🔍 Searching for Vue components...\n");

  const allElements = document.querySelectorAll('*');
  let found = false;

  for (let elem of allElements) {
    // Check for Vue 3 component instance
    if (elem.__vueParentComponent) {
      const instance = elem.__vueParentComponent.proxy;
      console.log("✅ Found Vue component instance!");
      console.log("Element:", elem);
      console.log("Instance keys:", Object.keys(instance).slice(0, 20));

      // Look for formData or similar properties
      const allProps = Object.keys(instance);
      const dataProps = allProps.filter(k =>
        k.includes('form') || k.includes('data') || k.includes('recipe') || k.includes('Form')
      );

      console.log("\n📋 Potential data properties:", dataProps);

      // Print actual values
      dataProps.forEach(prop => {
        try {
          const value = instance[prop];
          if (typeof value === 'object' && value !== null) {
            console.log(`\n${prop}:`, JSON.stringify(value).substring(0, 200));
          } else {
            console.log(`\n${prop}:`, value);
          }
        } catch (e) {
          console.log(`\n${prop}: [error reading]`);
        }
      });

      found = true;
      break;
    }
  }

  if (!found) {
    console.log("❌ Could not find Vue component");
    console.log("\nTrying alternative search methods...");

    // Check if there's a data property
    const recipeForm = document.querySelector('.form-panel');
    if (recipeForm) {
      console.log("Found form-panel element:", recipeForm);
      console.log("Properties:", Object.keys(recipeForm).filter(k => k.includes('vue') || k.includes('__')));
    }
  }
})();
