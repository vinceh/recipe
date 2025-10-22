# Recipes Seed File
# This file creates 14 sample recipes for the Ember recipe app

puts "🍳 Seeding recipes..."

recipes_data = [
  {
    name: "Oyakodon (Chicken and Egg Rice Bowl)",
    source_url: "https://www.justonecookbook.com/oyakodon/",
    servings: { original: 2, min: 1, max: 4 },
    timing: { prep_minutes: 10, cook_minutes: 15, total_minutes: 25 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course", "rice-bowl"],
    cuisines: ["japanese"],
    recipe_types: ["quick-weeknight", "one-pot"],
    ingredient_groups: [
      {
        name: "Main Ingredients",
        items: [
          { id: 1, name: "chicken thigh", amount: 300, unit: "g", notes: "boneless, cut into bite-size pieces" },
          { id: 2, name: "eggs", amount: 4, unit: "whole", notes: "beaten" },
          { id: 3, name: "onion", amount: 1, unit: "whole", notes: "thinly sliced" },
          { id: 4, name: "steamed rice", amount: 2, unit: "cups", notes: "freshly cooked" },
          { id: 5, name: "green onion", amount: 2, unit: "stalks", notes: "chopped, for garnish" }
        ]
      },
      {
        name: "Sauce",
        items: [
          { id: 6, name: "dashi stock", amount: 200, unit: "ml" },
          { id: 7, name: "soy sauce", amount: 2, unit: "tbsp" },
          { id: 8, name: "mirin", amount: 2, unit: "tbsp" },
          { id: 9, name: "sugar", amount: 1, unit: "tbsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "In a small bowl, mix dashi, soy sauce, mirin, and sugar to make the sauce." } },
      { id: "step-002", order: 2, instructions: { en: "Heat a pan over medium heat and add the sauce mixture. Bring to a simmer." } },
      { id: "step-003", order: 3, instructions: { en: "Add sliced onion and cook until softened, about 3 minutes." } },
      { id: "step-004", order: 4, instructions: { en: "Add chicken pieces and cook until no longer pink, about 5 minutes." } },
      { id: "step-005", order: 5, instructions: { en: "Pour beaten eggs over the chicken in a circular motion. Do not stir." } },
      { id: "step-006", order: 6, instructions: { en: "Cover and cook until eggs are just set but still slightly runny, about 2 minutes." } },
      { id: "step-007", order: 7, instructions: { en: "Serve over steamed rice and garnish with chopped green onions." } }
    ],
    equipment: ["frying pan", "small bowl", "spatula", "lid"],
    admin_notes: "Classic Japanese comfort food. Eggs should be slightly runny for authentic texture."
  },

  {
    name: "Chicken Nanban",
    source_url: "https://www.justonecookbook.com/chicken-nanban/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 20, cook_minutes: 20, total_minutes: 40 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course"],
    cuisines: ["japanese"],
    recipe_types: ["family-friendly"],
    ingredient_groups: [
      {
        name: "Chicken",
        items: [
          { id: 1, name: "chicken breast", amount: 600, unit: "g", notes: "cut into pieces" },
          { id: 2, name: "salt", amount: 0.5, unit: "tsp" },
          { id: 3, name: "black pepper", amount: 0.25, unit: "tsp" },
          { id: 4, name: "all-purpose flour", amount: 100, unit: "g", notes: "for coating" },
          { id: 5, name: "vegetable oil", amount: 3, unit: "tbsp", notes: "for frying" }
        ]
      },
      {
        name: "Nanban Sauce",
        items: [
          { id: 6, name: "rice vinegar", amount: 100, unit: "ml" },
          { id: 7, name: "soy sauce", amount: 3, unit: "tbsp" },
          { id: 8, name: "sugar", amount: 4, unit: "tbsp" }
        ]
      },
      {
        name: "Tartar Sauce",
        items: [
          { id: 9, name: "hard-boiled eggs", amount: 2, unit: "whole", notes: "chopped" },
          { id: 10, name: "mayonnaise", amount: 100, unit: "g" },
          { id: 11, name: "onion", amount: 0.25, unit: "whole", notes: "minced" },
          { id: 12, name: "lemon juice", amount: 1, unit: "tsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Place 1 large egg in a saucepan and cover with water by one inch. Bring to a boil on medium heat for 12 minutes." } },
      { id: "step-002", order: 2, instructions: { en: "Cool the boiled egg in ice water, then peel." } },
      { id: "step-003", order: 3, instructions: { en: "Finely mince ¼ onion and soak in cold water for 5-10 minutes to reduce sharpness. Drain well." } },
      { id: "step-004", order: 4, instructions: { en: "Cut ½ cucumber lengthwise, remove seeds, slice into thin strips, then finely dice into ⅛-inch pieces." } },
      { id: "step-005", order: 5, instructions: { en: "Mince the boiled egg finely." } },
      { id: "step-006", order: 6, instructions: { en: "Mix drained onion, cucumber, minced boiled egg, 3 tablespoons Japanese mayonnaise, 1 teaspoon rice vinegar, ⅛ teaspoon salt, and ⅛ teaspoon pepper. Refrigerate until serving." } },
      { id: "step-007", order: 7, instructions: { en: "Combine 2 tablespoons soy sauce, 2 tablespoons rice vinegar, 1 tablespoon mirin, and 2 tablespoons sugar in a saucepan. Heat gently until sugar dissolves, then set aside." } },
      { id: "step-008", order: 8, instructions: { en: "Split one boneless, skinless chicken breast horizontally, opening like a book. Cut in half down the middle." } },
      { id: "step-009", order: 9, instructions: { en: "Pound both sides of each cutlet with a meat tenderizer to even thickness." } },
      { id: "step-010", order: 10, instructions: { en: "Apply ⅛ teaspoon salt and ⅛ teaspoon pepper to each cutlet." } },
      { id: "step-011", order: 11, instructions: { en: "Dust each cutlet with 1 tablespoon flour, shaking off excess. Let rest 10 minutes." } },
      { id: "step-012", order: 12, instructions: { en: "Beat 1 large egg in a shallow bowl or plate." } },
      { id: "step-013", order: 13, instructions: { en: "Heat 2 cups neutral oil to 340°F in a medium pot." } },
      { id: "step-014", order: 14, instructions: { en: "Dip floured cutlet in beaten egg, then carefully place in oil. Cook for 4 minutes, flipping once at halfway mark." } },
      { id: "step-015", order: 15, instructions: { en: "Transfer fried cutlet to wire rack to drain." } },
      { id: "step-016", order: 16, instructions: { en: "Repeat the dipping and first fry process with remaining cutlets." } },
      { id: "step-017", order: 17, instructions: { en: "Raise oil temperature to 350°F." } },
      { id: "step-018", order: 18, instructions: { en: "Return first cutlet to oil and fry for 30 seconds on each side. Repeat with remaining cutlets." } },
      { id: "step-019", order: 19, instructions: { en: "Verify internal temperature of chicken reaches 165°F." } },
      { id: "step-020", order: 20, instructions: { en: "Immediately dip hot fried cutlets in the nanban sauce, coating both sides." } },
      { id: "step-021", order: 21, instructions: { en: "Slice each fried cutlet into ¾ inch pieces and transfer to plates." } },
      { id: "step-022", order: 22, instructions: { en: "Top generously with tartar sauce and drizzle additional nanban sauce over chicken." } }
    ],
    equipment: ["frying pan", "bowls", "tongs"],
    admin_notes: "Soaking the hot chicken in nanban sauce is key for authentic flavor."
  },

  {
    name: "Sukiyaki",
    source_url: "https://www.justonecookbook.com/sukiyaki/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 20, cook_minutes: 15, total_minutes: 35 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course", "hot-pot"],
    cuisines: ["japanese"],
    recipe_types: ["family-friendly", "entertaining"],
    ingredient_groups: [
      {
        name: "Main Ingredients",
        items: [
          { id: 1, name: "thinly sliced beef", amount: 500, unit: "g", notes: "ribeye or sirloin" },
          { id: 2, name: "napa cabbage", amount: 300, unit: "g", notes: "cut into pieces" },
          { id: 3, name: "shiitake mushrooms", amount: 8, unit: "whole" },
          { id: 4, name: "firm tofu", amount: 400, unit: "g", notes: "cubed" },
          { id: 5, name: "shirataki noodles", amount: 200, unit: "g" },
          { id: 6, name: "green onions", amount: 4, unit: "stalks", notes: "cut into 2-inch pieces" },
          { id: 7, name: "eggs", amount: 4, unit: "whole", notes: "for dipping (optional)" }
        ]
      },
      {
        name: "Sukiyaki Sauce",
        items: [
          { id: 8, name: "soy sauce", amount: 100, unit: "ml" },
          { id: 9, name: "mirin", amount: 100, unit: "ml" },
          { id: 10, name: "sake", amount: 50, unit: "ml" },
          { id: 11, name: "sugar", amount: 3, unit: "tbsp" },
          { id: 12, name: "dashi stock", amount: 200, unit: "ml" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Put 2 cups water and 1 piece kombu (dried kelp) in a measuring cup or pitcher. Set it aside to steep for a minimum of 30 minutes." } },
      { id: "step-002", order: 2, instructions: { en: "Combine ½ cup sake and ½ cup mirin in a small saucepan. Bring it to a boil and let the alcohol evaporate, about 1 minute." } },
      { id: "step-003", order: 3, instructions: { en: "Add 2 Tbsp sugar and ⅓ cup soy sauce to the saucepan. Bring to a boil and turn off the heat once the sugar is dissolved." } },
      { id: "step-004", order: 4, instructions: { en: "Transfer the sukiyaki sauce to a pitcher for easy pouring at the table." } },
      { id: "step-005", order: 5, instructions: { en: "Cut 4 leaves napa cabbage into pieces 2 inches (5 cm) wide, then cut each piece in half or thirds along the white center." } },
      { id: "step-006", order: 6, instructions: { en: "Cut ¼ bunch shungiku (chrysanthemum greens) into 2-inch (5 cm) sections." } },
      { id: "step-007", order: 7, instructions: { en: "Slice the white part of 1 Tokyo negi (naga negi; long green onion) diagonally into ½-inch (1.3 cm) pieces." } },
      { id: "step-008", order: 8, instructions: { en: "Scrape off the outer skin of 6 inches gobo (burdock root) with the back of a knife, then use a vegetable peeler to shave it into thin strips." } },
      { id: "step-009", order: 9, instructions: { en: "Soak the gobo strips in water for 5 minutes, changing the water once. Drain well." } },
      { id: "step-010", order: 10, instructions: { en: "Cut 1 onion into ½-inch (1.3 cm) slices widthwise. Tear 1 package enoki mushrooms into small clusters. Separate ½ package maitake mushrooms into small clusters." } },
      { id: "step-011", order: 11, instructions: { en: "Cut off and discard the stems of 2 shiitake mushrooms. Optionally, create a decorative flower pattern by cutting V-shaped incisions on the surface." } },
      { id: "step-012", order: 12, instructions: { en: "Cut ½ package broiled tofu (yaki dofu) into smaller pieces." } },
      { id: "step-013", order: 13, instructions: { en: "Optional: Slice carrot into ¼-inch (6 mm) rounds and stamp with a vegetable cutter to create flower shapes." } },
      { id: "step-014", order: 14, instructions: { en: "Rinse and drain shirataki noodles, cut them in half, then cook in boiling water for 2 minutes. Drain well." } },
      { id: "step-015", order: 15, instructions: { en: "Arrange the beef slices, beef suet, and all prepared vegetables, mushrooms, tofu, and shirataki noodles on a large platter. Set aside the eggs and cooked udon noodles for later use." } },
      { id: "step-016", order: 16, instructions: { en: "Set up a portable gas cooktop with a cast-iron sukiyaki pot at the dining table." } },
      { id: "step-017", order: 17, instructions: { en: "Heat the sukiyaki pot on medium heat. Add 1 Tbsp neutral oil (or beef suet). Pour in barely enough sukiyaki sauce to cover the bottom of the pot, about ⅛–¼ inch (3–6 mm) deep." } },
      { id: "step-018", order: 18, instructions: { en: "Place the marbled beef slices in the pot. When the bottom side of the meat is cooked, flip and cook the other side. You can enjoy the beef immediately or proceed to the next step." } },
      { id: "step-019", order: 19, instructions: { en: "Add a selection of vegetables, tofu, and mushrooms to the pot. Pour in enough sukiyaki sauce to partially submerge the ingredients (about ⅓ way up). Let everything simmer until cooked to your liking." } },
      { id: "step-020", order: 20, instructions: { en: "Transfer the cooked ingredients to individual bowls. Taste the sauce and drizzle in a tiny bit of dashi or water if it's getting too salty." } },
      { id: "step-021", order: 21, instructions: { en: "Continue cooking the remaining ingredients in batches (second and third rounds), adjusting the seasoning with dashi or water as needed throughout the meal." } },
      { id: "step-022", order: 22, instructions: { en: "For the finishing course (shime), add the cooked udon noodles to the remaining broth in the sukiyaki pot. Heat through and enjoy." } }
    ],
    equipment: ["sukiyaki pot or large pan", "bowls", "chopsticks"],
    admin_notes: "Traditional sukiyaki is cooked at the table. Raw egg dipping is optional but traditional."
  },

  {
    name: "Agedashi Tofu",
    source_url: "https://www.justonecookbook.com/agedashi-tofu/",
    servings: { original: 2, min: 2, max: 4 },
    timing: { prep_minutes: 15, cook_minutes: 10, total_minutes: 25 },
    dietary_tags: ["vegetarian"],
    dish_types: ["appetizer", "side-dish"],
    cuisines: ["japanese"],
    recipe_types: ["quick-weeknight"],
    ingredient_groups: [
      {
        name: "Tofu",
        items: [
          { id: 1, name: "silken tofu", amount: 400, unit: "g", notes: "firm or extra firm" },
          { id: 2, name: "potato starch", amount: 100, unit: "g", notes: "or cornstarch" },
          { id: 3, name: "vegetable oil", amount: 500, unit: "ml", notes: "for deep frying" }
        ]
      },
      {
        name: "Sauce",
        items: [
          { id: 4, name: "dashi stock", amount: 200, unit: "ml" },
          { id: 5, name: "mirin", amount: 2, unit: "tbsp" },
          { id: 6, name: "soy sauce", amount: 2, unit: "tbsp" },
          { id: 7, name: "sugar", amount: 1, unit: "tsp" },
          { id: 8, name: "grated daikon", amount: 50, unit: "g", notes: "for garnish" },
          { id: 9, name: "grated ginger", amount: 1, unit: "tsp", notes: "for garnish" },
          { id: 10, name: "green onion", amount: 2, unit: "stalks", notes: "chopped, for garnish" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Place the tofu block on a tray or plate. Wrap the tofu in 2-3 layers of paper towels and place another tray on top. Set a heavy object on top to press the tofu. Drain the water out of the tofu for 15 minutes." } },
      { id: "step-002", order: 2, instructions: { en: "Combine dashi stock, soy sauce, and mirin in a small saucepan. Bring to a simmer, then turn off heat, cover, and set aside." } },
      { id: "step-003", order: 3, instructions: { en: "Cut green onions into thin slices." } },
      { id: "step-004", order: 4, instructions: { en: "Peel and grate daikon radish (approximately 2 inches). Gently squeeze out excess water." } },
      { id: "step-005", order: 5, instructions: { en: "Peel and grate fresh ginger (yields about 1 teaspoon with juice)." } },
      { id: "step-006", order: 6, instructions: { en: "Cut the pressed tofu block into 6 equal pieces." } },
      { id: "step-007", order: 7, instructions: { en: "Coat tofu pieces with potato starch or cornstarch, dusting off any excess." } },
      { id: "step-008", order: 8, instructions: { en: "Heat neutral oil (2 cups) to 320-340°F in a deep pot or fryer." } },
      { id: "step-009", order: 9, instructions: { en: "Working in batches of 3 pieces, fry tofu until light brown and crispy, turning once. Place finished pieces on a wire rack or paper towel-lined plate to drain." } },
      { id: "step-010", order: 10, instructions: { en: "Place fried tofu in serving bowls. Pour sauce along the bowl edges without wetting the tofu's crispy top. Top with grated daikon, ginger, green onions, and optional bonito flakes or seven spice powder." } }
    ],
    equipment: ["deep pot", "knife", "small pot", "paper towels"],
    admin_notes: "Tofu should be crispy outside and silky inside. Serve immediately for best texture."
  },

  {
    name: "Lu Rou Fan (Taiwanese Braised Pork Rice)",
    source_url: "https://thewoksoflife.com/lu-rou-fan-taiwan-braised-pork-rice-bowl/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 15, cook_minutes: 90, total_minutes: 105 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course", "rice-bowl"],
    cuisines: ["taiwanese"],
    recipe_types: ["comfort-food", "one-pot"],
    ingredient_groups: [
      {
        name: "Main Ingredients",
        items: [
          { id: 1, name: "pork belly", amount: 600, unit: "g", notes: "cut into small cubes" },
          { id: 2, name: "shallots", amount: 6, unit: "whole", notes: "minced" },
          { id: 3, name: "garlic", amount: 5, unit: "cloves", notes: "minced" },
          { id: 4, name: "hard-boiled eggs", amount: 4, unit: "whole", notes: "peeled" },
          { id: 5, name: "steamed rice", amount: 4, unit: "cups", notes: "for serving" }
        ]
      },
      {
        name: "Braising Liquid",
        items: [
          { id: 6, name: "soy sauce", amount: 100, unit: "ml" },
          { id: 7, name: "dark soy sauce", amount: 2, unit: "tbsp" },
          { id: 8, name: "rice wine", amount: 50, unit: "ml" },
          { id: 9, name: "rock sugar", amount: 3, unit: "tbsp", notes: "or brown sugar" },
          { id: 10, name: "five-spice powder", amount: 1, unit: "tsp" },
          { id: 11, name: "water", amount: 400, unit: "ml" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Bring a medium pot of water to a boil (just enough so that the pork will be fully submerged), and blanch the chopped pork belly for 1 minute. Drain, rinse clean of any scum, and set aside." } },
      { id: "step-002", order: 2, instructions: { en: "Dice the onions or shallots into small pieces." } },
      { id: "step-003", order: 3, instructions: { en: "Chop the shiitake mushrooms into half-inch pieces." } },
      { id: "step-004", order: 4, instructions: { en: "Bundle the star anise, cinnamon stick, cloves, bay leaves, Sichuan peppercorns, dried tangerine peel, and ginger slices in cheesecloth and tie with kitchen string." } },
      { id: "step-005", order: 5, instructions: { en: "Heat the oil in a wok over low heat, and add the sugar. Cook the sugar until it starts to melt and then add the onions." } },
      { id: "step-006", order: 6, instructions: { en: "Turn up the heat to medium high and stir-fry the onions for a minute. Add the mushrooms and stir-fry for another couple minutes." } },
      { id: "step-007", order: 7, instructions: { en: "Add the blanched pork, shaoxing wine, light soy sauce, dark soy sauce and water. Stir and bring the mixture to a boil." } },
      { id: "step-008", order: 8, instructions: { en: "Once boiling, add the spice packet and peeled hardboiled eggs and turn the heat to the lowest setting. Simmer for 1 1/2 hours, stirring occasionally to prevent sticking." } },
      { id: "step-009", order: 9, instructions: { en: "Remove the spice packet and turn up the heat to medium high to thicken the sauce, stirring occasionally. This process should take about 5 minutes." } },
      { id: "step-010", order: 10, instructions: { en: "Serve the braised pork over steamed white rice." } }
    ],
    equipment: ["wok or pot", "lid", "knife"],
    admin_notes: "Taiwanese comfort food classic. Pork should be melt-in-your-mouth tender."
  },

  {
    name: "Taiwanese Chicken and Mushroom Soup",
    source_url: "",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 15, cook_minutes: 45, total_minutes: 60 },
    dietary_tags: ["high-protein", "gluten-free"],
    dish_types: ["soup"],
    cuisines: ["taiwanese"],
    recipe_types: ["comfort-food", "one-pot"],
    ingredient_groups: [
      {
        name: "Main Ingredients",
        items: [
          { id: 1, name: "chicken thighs", amount: 500, unit: "g", notes: "bone-in, cut into pieces" },
          { id: 2, name: "dried shiitake mushrooms", amount: 10, unit: "whole", notes: "rehydrated" },
          { id: 3, name: "ginger", amount: 30, unit: "g", notes: "sliced" },
          { id: 4, name: "goji berries", amount: 2, unit: "tbsp" },
          { id: 5, name: "jujube dates", amount: 6, unit: "whole" },
          { id: 6, name: "water", amount: 1500, unit: "ml" },
          { id: 7, name: "salt", amount: 1, unit: "tsp", notes: "to taste" },
          { id: 8, name: "rice wine", amount: 2, unit: "tbsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Soak dried shiitake mushrooms in warm water for 30 minutes until fully rehydrated and softened. Reserve the soaking liquid." } },
      { id: "step-002", order: 2, instructions: { en: "Cut chicken thighs into 3-4 bite-sized pieces each, keeping the bone in for flavor." } },
      { id: "step-003", order: 3, instructions: { en: "Slice ginger into 5-6 thick pieces, about 5mm thick." } },
      { id: "step-004", order: 4, instructions: { en: "Bring a pot of water to boil and blanch the chicken pieces for 2-3 minutes to remove impurities. Drain and rinse under cold water." } },
      { id: "step-005", order: 5, instructions: { en: "Rinse goji berries and jujube dates under cold water to remove any dust." } },
      { id: "step-006", order: 6, instructions: { en: "In a large pot, add blanched chicken pieces, rehydrated shiitake mushrooms, ginger slices, jujube dates, and 1500ml of water. Add the reserved mushroom soaking liquid for extra flavor." } },
      { id: "step-007", order: 7, instructions: { en: "Add rice wine to the pot and bring everything to a boil over high heat." } },
      { id: "step-008", order: 8, instructions: { en: "Once boiling, reduce heat to low, cover with lid, and simmer for 45-60 minutes until chicken is tender and flavors are well developed." } },
      { id: "step-009", order: 9, instructions: { en: "Add goji berries during the last 10 minutes of simmering to preserve their color and nutrients." } },
      { id: "step-010", order: 10, instructions: { en: "Season with salt to taste. Start with 1 teaspoon and adjust as needed." } },
      { id: "step-011", order: 11, instructions: { en: "Ladle soup into bowls, ensuring each serving has chicken, mushrooms, and herbs. Serve hot." } }
    ],
    equipment: ["large pot", "bowl"],
    admin_notes: "Nourishing Taiwanese soup perfect for cold days or when feeling under the weather."
  },

  {
    name: "Taiwanese Tomato Beef Noodle Soup",
    source_url: "https://thewoksoflife.com/taiwanese-beef-noodle-soup-instant-pot/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 20, cook_minutes: 120, total_minutes: 140 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course", "soup"],
    cuisines: ["taiwanese"],
    recipe_types: ["comfort-food"],
    ingredient_groups: [
      {
        name: "Beef",
        items: [
          { id: 1, name: "beef shank", amount: 800, unit: "g", notes: "cut into chunks" },
          { id: 2, name: "ginger", amount: 40, unit: "g", notes: "sliced" },
          { id: 3, name: "green onions", amount: 3, unit: "stalks", notes: "cut into sections" }
        ]
      },
      {
        name: "Soup Base",
        items: [
          { id: 4, name: "tomatoes", amount: 4, unit: "whole", notes: "large, cut into wedges" },
          { id: 5, name: "tomato paste", amount: 3, unit: "tbsp" },
          { id: 6, name: "soy sauce", amount: 100, unit: "ml" },
          { id: 7, name: "rock sugar", amount: 2, unit: "tbsp" },
          { id: 8, name: "doubanjiang", amount: 2, unit: "tbsp", notes: "spicy bean paste" },
          { id: 9, name: "star anise", amount: 2, unit: "whole" },
          { id: 10, name: "water", amount: 2000, unit: "ml" }
        ]
      },
      {
        name: "Noodles and Garnish",
        items: [
          { id: 11, name: "fresh wheat noodles", amount: 400, unit: "g" },
          { id: 12, name: "bok choy", amount: 200, unit: "g", notes: "blanched" },
          { id: 13, name: "cilantro", amount: 20, unit: "g", notes: "for garnish" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Cut 3 pounds of beef shank into 2-inch chunks." } },
      { id: "step-002", order: 2, instructions: { en: "Prepare the spice packet by combining 4 star anise, 1 Chinese cinnamon stick, 3 bay leaves, 1 tablespoon fennel seeds, 1 tablespoon cumin seeds, 1 teaspoon coriander seeds, 2 tablespoons Sichuan peppercorns, 1/4 teaspoon five spice powder, and 1/4 teaspoon black pepper." } },
      { id: "step-003", order: 3, instructions: { en: "Smash a 2-inch piece of ginger and 6 cloves of garlic." } },
      { id: "step-004", order: 4, instructions: { en: "Cut 3 scallions into 2-inch segments." } },
      { id: "step-005", order: 5, instructions: { en: "Cut 1 onion into wedges and 1 tomato into wedges." } },
      { id: "step-006", order: 6, instructions: { en: "Rip 4 dried chilies in half." } },
      { id: "step-007", order: 7, instructions: { en: "Boil enough water in a pot to cover all of the beef chunks. Once the water is boiling, add the beef and let it come back up to a boil. Boil for 1 minute." } },
      { id: "step-008", order: 8, instructions: { en: "Strain the beef in a colander and rinse thoroughly with fresh water to remove any impurities." } },
      { id: "step-009", order: 9, instructions: { en: "Set the Instant Pot to sauté mode and add 2 tablespoons of oil." } },
      { id: "step-010", order: 10, instructions: { en: "Add the crushed ginger, garlic, scallions, and onion wedges to the Instant Pot in that order. Stir to lightly caramelize and cook until the onion turns translucent." } },
      { id: "step-011", order: 11, instructions: { en: "Add the tomato wedges and dried chilies to the pot and stir." } },
      { id: "step-012", order: 12, instructions: { en: "Add the blanched beef to the Instant Pot." } },
      { id: "step-013", order: 13, instructions: { en: "Add 1 tablespoon tomato paste, 2 tablespoons spicy bean paste (douban jiang), 2 teaspoons sugar, 1/2 cup soy sauce, and 1/2 cup Shaoxing wine to the pot. Mix thoroughly." } },
      { id: "step-014", order: 14, instructions: { en: "Pour 8 cups of water into the Instant Pot." } },
      { id: "step-015", order: 15, instructions: { en: "Add the spice packet to the Instant Pot." } },
      { id: "step-016", order: 16, instructions: { en: "Close the Instant Pot lid with the vent sealed. Set to Meat/Stew setting and cook for 100 minutes." } },
      { id: "step-017", order: 17, instructions: { en: "When the timer finishes, carefully release the pressure." } },
      { id: "step-018", order: 18, instructions: { en: "Boil 32 ounces of fresh wheat noodles per package instructions." } },
      { id: "step-019", order: 19, instructions: { en: "In the last 1-2 minutes of the noodles cooking, add a small handful of bok choy per serving to the boiling water and blanch until just tender." } },
      { id: "step-020", order: 20, instructions: { en: "Drain the noodles and bok choy." } },
      { id: "step-021", order: 21, instructions: { en: "Place a serving of noodles in each bowl." } },
      { id: "step-022", order: 22, instructions: { en: "Add a few stalks of bok choy to each bowl." } },
      { id: "step-023", order: 23, instructions: { en: "Ladle the beef and broth over the noodles and bok choy." } },
      { id: "step-024", order: 24, instructions: { en: "Top each bowl with generous sprinklings of finely minced cilantro, finely chopped scallions, and Chinese pickled mustard greens." } }
    ],
    equipment: ["large pot", "pot", "ladle"],
    admin_notes: "Iconic Taiwanese dish. Tomatoes add unique sweetness to the rich beef broth."
  },

  {
    name: "Kimchi Sundubu Jjigae (Soft Tofu Stew)",
    source_url: "https://www.maangchi.com/recipe/sundubu-jjigae",
    servings: { original: 2, min: 1, max: 4 },
    timing: { prep_minutes: 10, cook_minutes: 15, total_minutes: 25 },
    dietary_tags: ["spicy", "gluten-free"],
    dish_types: ["main-course", "soup"],
    cuisines: ["korean"],
    recipe_types: ["quick-weeknight", "comfort-food"],
    ingredient_groups: [
      {
        name: "Main Ingredients",
        items: [
          { id: 1, name: "soft tofu", amount: 400, unit: "g", notes: "silken" },
          { id: 2, name: "kimchi", amount: 150, unit: "g", notes: "chopped" },
          { id: 3, name: "pork belly", amount: 100, unit: "g", notes: "sliced thin" },
          { id: 4, name: "green onion", amount: 1, unit: "stalk", notes: "chopped" },
          { id: 5, name: "garlic", amount: 2, unit: "cloves", notes: "minced" },
          { id: 6, name: "egg", amount: 1, unit: "whole" }
        ]
      },
      {
        name: "Broth",
        items: [
          { id: 7, name: "anchovy stock", amount: 300, unit: "ml", notes: "or water" },
          { id: 8, name: "gochugaru", amount: 1, unit: "tbsp", notes: "Korean red pepper flakes" },
          { id: 9, name: "soy sauce", amount: 1, unit: "tbsp" },
          { id: 10, name: "sesame oil", amount: 1, unit: "tsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Prepare anchovy stock by boiling dried anchovies and dried kelp in water, then strain and set aside" } },
      { id: "step-002", order: 2, instructions: { en: "Cut pork belly into bite-sized pieces" } },
      { id: "step-003", order: 3, instructions: { en: "Cut kimchi into bite-sized pieces" } },
      { id: "step-004", order: 4, instructions: { en: "Chop green onion and mince garlic" } },
      { id: "step-005", order: 5, instructions: { en: "Mix gochugaru (Korean red pepper flakes) with sesame oil to make hot pepper mixture" } },
      { id: "step-006", order: 6, instructions: { en: "Heat vegetable oil in a pot or Korean earthenware pot (ttukbaegi) over medium-high heat" } },
      { id: "step-007", order: 7, instructions: { en: "Add pork belly to the pot and stir-fry until the meat is browned and the fat is rendered, about 3-4 minutes" } },
      { id: "step-008", order: 8, instructions: { en: "Add minced garlic and stir for about 30 seconds until fragrant" } },
      { id: "step-009", order: 9, instructions: { en: "Add kimchi to the pot and stir constantly for 1-2 minutes" } },
      { id: "step-010", order: 10, instructions: { en: "Pour in anchovy stock (about 1/2 to 1 cup) and bring to a boil" } },
      { id: "step-011", order: 11, instructions: { en: "Cover the pot and cook over medium heat for 7 minutes to develop flavors" } },
      { id: "step-012", order: 12, instructions: { en: "Add salt (about 1/4 to 1/2 teaspoon) and sugar (about 1/2 teaspoon) and mix well to season" } },
      { id: "step-013", order: 13, instructions: { en: "Cut the tube of soft tofu (sundubu) in half and gently squeeze it out into the pot" } },
      { id: "step-014", order: 14, instructions: { en: "Gently break up the tofu into large chunks with a wooden spoon, being careful not to break it into small pieces" } },
      { id: "step-015", order: 15, instructions: { en: "Add the hot pepper mixture (gochugaru with sesame oil) on top and spread it with a spoon" } },
      { id: "step-016", order: 16, instructions: { en: "Let the stew boil for 3-4 minutes to heat the tofu through" } },
      { id: "step-017", order: 17, instructions: { en: "Crack an egg and place it on top in the center of the bubbling stew" } },
      { id: "step-018", order: 18, instructions: { en: "Let the stew bubble and sizzle for 1 minute to partially cook the egg" } },
      { id: "step-019", order: 19, instructions: { en: "Sprinkle chopped green onion on top as garnish" } },
      { id: "step-020", order: 20, instructions: { en: "Serve immediately while hot with steamed rice and side dishes" } }
    ],
    equipment: ["earthenware pot or small pot", "spoon"],
    admin_notes: "Bubbling hot Korean comfort food. Serve with rice and banchan."
  },

  {
    name: "Korean Seafood Pancake (Haemul Pajeon)",
    source_url: "https://www.maangchi.com/recipe/haemul-pajeon",
    servings: { original: 2, min: 2, max: 4 },
    timing: { prep_minutes: 15, cook_minutes: 15, total_minutes: 30 },
    dietary_tags: ["pescatarian"],
    dish_types: ["appetizer", "main-course"],
    cuisines: ["korean"],
    recipe_types: ["entertaining"],
    ingredient_groups: [
      {
        name: "Pancake",
        items: [
          { id: 1, name: "all-purpose flour", amount: 100, unit: "g" },
          { id: 2, name: "potato starch", amount: 50, unit: "g" },
          { id: 3, name: "water", amount: 200, unit: "ml", notes: "cold" },
          { id: 4, name: "egg", amount: 1, unit: "whole" },
          { id: 5, name: "salt", amount: 0.5, unit: "tsp" }
        ]
      },
      {
        name: "Filling",
        items: [
          { id: 6, name: "squid", amount: 100, unit: "g", notes: "cleaned and sliced" },
          { id: 7, name: "shrimp", amount: 100, unit: "g", notes: "peeled" },
          { id: 8, name: "green onions", amount: 4, unit: "stalks", notes: "cut into 2-inch pieces" },
          { id: 9, name: "vegetable oil", amount: 4, unit: "tbsp", notes: "for frying" }
        ]
      },
      {
        name: "Dipping Sauce",
        items: [
          { id: 10, name: "soy sauce", amount: 2, unit: "tbsp" },
          { id: 11, name: "rice vinegar", amount: 1, unit: "tbsp" },
          { id: 12, name: "gochugaru", amount: 0.5, unit: "tsp" },
          { id: 13, name: "sesame seeds", amount: 0.5, unit: "tsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Wash and thoroughly dry the green onions with paper towels. Trim the roots and split the thick white portions lengthwise. Cut crosswise into 2-inch pieces." } },
      { id: "step-002", order: 2, instructions: { en: "Pat the seafood (shrimp, squid, and any other seafood) completely dry with paper towels to remove excess moisture." } },
      { id: "step-003", order: 3, instructions: { en: "In a large mixing bowl, whisk together the all-purpose flour, potato starch (or cornstarch), baking powder, garlic powder, onion powder, chicken bouillon powder, and salt until well combined." } },
      { id: "step-004", order: 4, instructions: { en: "Add the icy cold water to the dry ingredients and mix until just combined to create a thin batter. The consistency should be thinner than regular pancake batter but thicker than crepe batter." } },
      { id: "step-005", order: 5, instructions: { en: "Add the chopped green onions and seafood to the batter. Gently mix until everything is just combined. Do not overmix." } },
      { id: "step-006", order: 6, instructions: { en: "Heat a large 12-inch non-stick pan over medium-high heat. Add 2-3 tablespoons of vegetable oil and swirl to coat the entire bottom of the pan." } },
      { id: "step-007", order: 7, instructions: { en: "Pour half of the batter mixture into the hot pan and quickly spread it into an even, thin round pancake using a spatula or ladle. Fill any gaps and level the surface." } },
      { id: "step-008", order: 8, instructions: { en: "Reduce heat to medium. Cook for 5-7 minutes until the bottom becomes crispy and golden brown with charred edges. Swirl the pan occasionally for even browning. You should see small holes forming and steam rising." } },
      { id: "step-009", order: 9, instructions: { en: "Carefully flip the pancake using a large spatula. Add 2-3 tablespoons of oil around the edges of the pan and swirl to coat." } },
      { id: "step-010", order: 10, instructions: { en: "Cook the second side for 4-5 minutes until golden brown and crispy. Press down on the pancake several times with the spatula to ensure crispiness." } },
      { id: "step-011", order: 11, instructions: { en: "Transfer the cooked pancake to a cutting board. Repeat the cooking process with the remaining batter and oil to make a second pancake." } },
      { id: "step-012", order: 12, instructions: { en: "While the pancakes are cooking or after completion, make the dipping sauce by whisking together soy sauce, rice vinegar, sesame oil, and finely chopped green onion in a small bowl." } },
      { id: "step-013", order: 13, instructions: { en: "Cut the pancakes into small squares or wedges using a sharp knife. Arrange on a serving plate." } },
      { id: "step-014", order: 14, instructions: { en: "Serve the pancake hot with the dipping sauce on the side." } }
    ],
    equipment: ["large non-stick pan", "bowls", "spatula"],
    admin_notes: "Crispy on outside, chewy inside. Perfect with Korean rice wine (makgeolli)."
  },

  {
    name: "Chicken Adobo (Filipino)",
    source_url: "https://panlasangpinoy.com/chicken-adobo-recipe/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 10, cook_minutes: 50, total_minutes: 60 },
    dietary_tags: ["high-protein", "gluten-free"],
    dish_types: ["main-course"],
    cuisines: ["filipino"],
    recipe_types: ["comfort-food", "one-pot"],
    ingredient_groups: [
      {
        name: "Main Ingredients",
        items: [
          { id: 1, name: "chicken thighs and drumsticks", amount: 1000, unit: "g" },
          { id: 2, name: "soy sauce", amount: 100, unit: "ml" },
          { id: 3, name: "white vinegar", amount: 100, unit: "ml" },
          { id: 4, name: "garlic", amount: 8, unit: "cloves", notes: "crushed" },
          { id: 5, name: "bay leaves", amount: 3, unit: "whole" },
          { id: 6, name: "black peppercorns", amount: 1, unit: "tsp", notes: "whole" },
          { id: 7, name: "water", amount: 200, unit: "ml" },
          { id: 8, name: "vegetable oil", amount: 2, unit: "tbsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Combine chicken, soy sauce, and garlic in a large bowl. Mix well. Marinate the chicken for at least 1 hour." } },
      { id: "step-002", order: 2, instructions: { en: "Heat a cooking pot and add cooking oil." } },
      { id: "step-003", order: 3, instructions: { en: "Once the oil is hot enough, pan-fry the marinated chicken for 2 minutes per side." } },
      { id: "step-004", order: 4, instructions: { en: "Pour in the remaining marinade, including garlic, and add water. Bring to a boil." } },
      { id: "step-005", order: 5, instructions: { en: "Add dried bay leaves and whole peppercorn. Simmer for 30 minutes or until the chicken gets tender." } },
      { id: "step-006", order: 6, instructions: { en: "Add the vinegar and let it cook for 10 minutes." } },
      { id: "step-007", order: 7, instructions: { en: "Add sugar and salt to taste. Stir thoroughly." } },
      { id: "step-008", order: 8, instructions: { en: "Remove from heat. Serve hot with rice." } }
    ],
    equipment: ["pot with lid", "tongs"],
    admin_notes: "National dish of Philippines. Tangy, savory, and incredibly flavorful."
  },

  {
    name: "Butter Chicken (Murgh Makhani)",
    source_url: "https://cafedelites.com/butter-chicken/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 30, cook_minutes: 30, total_minutes: 60 },
    dietary_tags: ["high-protein", "gluten-free"],
    dish_types: ["main-course"],
    cuisines: ["indian"],
    recipe_types: ["comfort-food"],
    ingredient_groups: [
      {
        name: "Chicken Marinade",
        items: [
          { id: 1, name: "chicken breast", amount: 600, unit: "g", notes: "cubed" },
          { id: 2, name: "yogurt", amount: 100, unit: "g" },
          { id: 3, name: "lemon juice", amount: 1, unit: "tbsp" },
          { id: 4, name: "garam masala", amount: 1, unit: "tsp" },
          { id: 5, name: "turmeric", amount: 0.5, unit: "tsp" },
          { id: 6, name: "salt", amount: 1, unit: "tsp" }
        ]
      },
      {
        name: "Sauce",
        items: [
          { id: 7, name: "butter", amount: 50, unit: "g" },
          { id: 8, name: "onion", amount: 1, unit: "whole", notes: "diced" },
          { id: 9, name: "garlic", amount: 4, unit: "cloves", notes: "minced" },
          { id: 10, name: "ginger", amount: 15, unit: "g", notes: "grated" },
          { id: 11, name: "tomato passata", amount: 400, unit: "ml" },
          { id: 12, name: "heavy cream", amount: 200, unit: "ml" },
          { id: 13, name: "garam masala", amount: 2, unit: "tsp" },
          { id: 14, name: "paprika", amount: 1, unit: "tsp" },
          { id: 15, name: "sugar", amount: 1, unit: "tsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "In a bowl, combine chicken with all of the ingredients for the chicken marinade; let marinate for 30 minutes to an hour (or overnight if time allows)." } },
      { id: "step-002", order: 2, instructions: { en: "Heat oil in a large skillet or pot over medium-high heat. When sizzling, add chicken pieces in batches of two or three, making sure not to crowd the pan. Fry until browned for only 3 minutes on each side." } },
      { id: "step-003", order: 3, instructions: { en: "Set chicken aside and keep warm. Heat butter or ghee in the same pan. Fry the onions until they start to sweat (about 6 minutes) while scraping up any browned bits stuck on the bottom of the pan." } },
      { id: "step-004", order: 4, instructions: { en: "Add garlic, ginger, and ground spices. Cook for about 20 seconds until aromatic, stirring occasionally." } },
      { id: "step-005", order: 5, instructions: { en: "Add crushed tomatoes, chili powder, and salt. Let simmer for about 10-15 minutes, stirring occasionally until sauce thickens and becomes a deep brown red color." } },
      { id: "step-006", order: 6, instructions: { en: "Remove from heat, scoop mixture into a blender and blend until smooth. You may need to add a couple tablespoons of water to help it blend (up to 1/4 cup). Work in batches depending on the size of your blender." } },
      { id: "step-007", order: 7, instructions: { en: "Pour the puréed sauce back into the pan. Stir the cream, sugar, and crushed kasoori methi (or fenugreek leaves) through the sauce. Add the chicken with juices back into the pan and cook for an additional 8-10 minutes until chicken is cooked through and the sauce is thick and bubbling." } },
      { id: "step-008", order: 8, instructions: { en: "Garnish with chopped cilantro and serve with fresh, hot garlic butter rice and fresh homemade Naan bread!" } }
    ],
    equipment: ["large pan", "bowl"],
    admin_notes: "Rich, creamy Indian classic. Best served with naan bread."
  },

  {
    name: "Homemade Naan Bread",
    source_url: "https://cafedelites.com/garlic-butter-naan/",
    servings: { original: 8, min: 4, max: 12 },
    timing: { prep_minutes: 90, cook_minutes: 20, total_minutes: 110 },
    dietary_tags: ["vegetarian"],
    dish_types: ["side-dish", "bread"],
    cuisines: ["indian"],
    recipe_types: [],
    ingredient_groups: [
      {
        name: "Dough",
        items: [
          { id: 1, name: "all-purpose flour", amount: 400, unit: "g" },
          { id: 2, name: "active dry yeast", amount: 2, unit: "tsp" },
          { id: 3, name: "sugar", amount: 1, unit: "tsp" },
          { id: 4, name: "salt", amount: 1, unit: "tsp" },
          { id: 5, name: "yogurt", amount: 80, unit: "g" },
          { id: 6, name: "milk", amount: 120, unit: "ml", notes: "warm" },
          { id: 7, name: "vegetable oil", amount: 2, unit: "tbsp" }
        ]
      },
      {
        name: "Garlic Butter",
        items: [
          { id: 8, name: "butter", amount: 50, unit: "g", notes: "melted" },
          { id: 9, name: "garlic", amount: 3, unit: "cloves", notes: "minced" },
          { id: 10, name: "cilantro", amount: 2, unit: "tbsp", notes: "chopped" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Combine together the water, sugar and yeast in a mixing bowl. Let sit for 5-10 minutes or until the mixture begins to bubble on top." } },
      { id: "step-002", order: 2, instructions: { en: "Add in the milk, yogurt, oil, minced garlic, flour, baking powder and salt to the yeast mixture. Mix until the dough comes together using your hands." } },
      { id: "step-003", order: 3, instructions: { en: "Turn dough out onto lightly floured surface. Use floured hands to knead the dough until smooth, about 3 to 5 minutes." } },
      { id: "step-004", order: 4, instructions: { en: "Lightly grease the same mixing bowl with a small spray of cooking oil. Transfer dough to the bowl and cover with plastic wrap. Let rest at room temperature for about an hour until doubled in size." } },
      { id: "step-005", order: 5, instructions: { en: "Divide the dough into 10 equal portions and roll into balls." } },
      { id: "step-006", order: 6, instructions: { en: "Use a rolling pin to roll each ball into a large oval, approximately 6 inches long and 1/8-inch thick." } },
      { id: "step-007", order: 7, instructions: { en: "Heat a large cast iron skillet over medium-high heat. Grease skillet all over with 1/2 teaspoon of the extra oil." } },
      { id: "step-008", order: 8, instructions: { en: "Place one piece of the naan on the oiled hot skillet and cook until bubbles form on top, about 1-2 minutes. While cooking, brush the top with a little oil." } },
      { id: "step-009", order: 9, instructions: { en: "Flip the naan and cook for another 1-2 minutes, until large golden spots appear on the bottom." } },
      { id: "step-010", order: 10, instructions: { en: "Remove from the skillet and wrap in a clean kitchen towel to keep warm. Repeat with the remaining naan pieces." } },
      { id: "step-011", order: 11, instructions: { en: "Combine melted butter and minced garlic together in a bowl." } },
      { id: "step-012", order: 12, instructions: { en: "Brush each cooked naan with the garlic butter and top with the fresh herb of your choosing." } }
    ],
    equipment: ["bowls", "rolling pin", "cast iron pan", "brush", "clean towel"],
    admin_notes: "Fresh naan is incomparably better than store-bought. Perfect with curry."
  },

  {
    name: "Classic Lasagna",
    source_url: "https://www.allrecipes.com/recipe/23600/worlds-best-lasagna/",
    servings: { original: 8, min: 6, max: 12 },
    timing: { prep_minutes: 30, cook_minutes: 90, total_minutes: 120 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course"],
    cuisines: ["italian"],
    recipe_types: ["comfort-food", "entertaining", "make-ahead"],
    ingredient_groups: [
      {
        name: "Meat Sauce",
        items: [
          { id: 1, name: "ground beef", amount: 500, unit: "g" },
          { id: 2, name: "Italian sausage", amount: 250, unit: "g" },
          { id: 3, name: "onion", amount: 1, unit: "whole", notes: "diced" },
          { id: 4, name: "garlic", amount: 4, unit: "cloves", notes: "minced" },
          { id: 5, name: "crushed tomatoes", amount: 800, unit: "g", notes: "canned" },
          { id: 6, name: "tomato paste", amount: 170, unit: "g" },
          { id: 7, name: "dried basil", amount: 2, unit: "tsp" },
          { id: 8, name: "dried oregano", amount: 1, unit: "tsp" }
        ]
      },
      {
        name: "Cheese Filling",
        items: [
          { id: 9, name: "ricotta cheese", amount: 450, unit: "g" },
          { id: 10, name: "egg", amount: 1, unit: "whole" },
          { id: 11, name: "parmesan cheese", amount: 50, unit: "g", notes: "grated" },
          { id: 12, name: "fresh parsley", amount: 2, unit: "tbsp", notes: "chopped" }
        ]
      },
      {
        name: "Assembly",
        items: [
          { id: 13, name: "lasagna noodles", amount: 12, unit: "sheets", notes: "cooked" },
          { id: 14, name: "mozzarella cheese", amount: 400, unit: "g", notes: "shredded" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Gather all your ingredients." } },
      { id: "step-002", order: 2, instructions: { en: "Cook sausage, ground beef, onion, and garlic in a Dutch oven over medium heat until well browned." } },
      { id: "step-003", order: 3, instructions: { en: "Stir in crushed tomatoes, tomato sauce, tomato paste, and water. Season with sugar, 2 tablespoons parsley, basil, 1 teaspoon salt, Italian seasoning, fennel seeds, and pepper. Simmer, covered, for about 1½ hours, stirring occasionally." } },
      { id: "step-004", order: 4, instructions: { en: "Bring a large pot of lightly salted water to a boil. Cook lasagna noodles in boiling water for 8 to 10 minutes. Drain noodles, and rinse with cold water." } },
      { id: "step-005", order: 5, instructions: { en: "In a mixing bowl, combine ricotta cheese with egg, remaining 2 tablespoons parsley, and ½ teaspoon salt." } },
      { id: "step-006", order: 6, instructions: { en: "Preheat the oven to 375 degrees F (190 degrees C)." } },
      { id: "step-007", order: 7, instructions: { en: "Spread 1½ cups of meat sauce in the bottom of a 9x13 inch baking dish. Arrange 6 noodles lengthwise over meat sauce. Spread with half of the ricotta cheese mixture. Top with a third of mozzarella cheese slices. Spoon 1½ cups meat sauce over mozzarella, and sprinkle with ¼ cup Parmesan cheese." } },
      { id: "step-008", order: 8, instructions: { en: "Repeat layers, and top with remaining mozzarella and Parmesan cheese. Cover with aluminum foil, making sure the foil does not touch the cheese." } },
      { id: "step-009", order: 9, instructions: { en: "Bake in the preheated oven for 25 minutes. Remove the foil and bake for an additional 25 minutes." } },
      { id: "step-010", order: 10, instructions: { en: "Rest lasagna for 15 minutes before serving." } }
    ],
    equipment: ["large pot", "pot", "9x13 inch baking dish", "aluminum foil", "oven"],
    admin_notes: "Classic comfort food. Can be assembled ahead and refrigerated before baking."
  },

  {
    name: "Japanese Hamburg Steak (Hambagu)",
    source_url: "https://www.justonecookbook.com/hambagu/",
    servings: { original: 4, min: 2, max: 6 },
    timing: { prep_minutes: 20, cook_minutes: 20, total_minutes: 40 },
    dietary_tags: ["high-protein"],
    dish_types: ["main-course"],
    cuisines: ["japanese"],
    recipe_types: ["family-friendly", "comfort-food"],
    ingredient_groups: [
      {
        name: "Patties",
        items: [
          { id: 1, name: "ground beef", amount: 300, unit: "g" },
          { id: 2, name: "ground pork", amount: 200, unit: "g" },
          { id: 3, name: "onion", amount: 0.5, unit: "whole", notes: "finely minced" },
          { id: 4, name: "panko breadcrumbs", amount: 50, unit: "g" },
          { id: 5, name: "milk", amount: 50, unit: "ml" },
          { id: 6, name: "egg", amount: 1, unit: "whole" },
          { id: 7, name: "salt", amount: 0.5, unit: "tsp" },
          { id: 8, name: "black pepper", amount: 0.25, unit: "tsp" },
          { id: 9, name: "nutmeg", amount: 0.125, unit: "tsp" }
        ]
      },
      {
        name: "Sauce",
        items: [
          { id: 10, name: "tonkatsu sauce", amount: 4, unit: "tbsp" },
          { id: 11, name: "ketchup", amount: 2, unit: "tbsp" },
          { id: 12, name: "water", amount: 100, unit: "ml" },
          { id: 13, name: "butter", amount: 1, unit: "tbsp" }
        ]
      }
    ],
    steps: [
      { id: "step-001", order: 1, instructions: { en: "Finely mince ½ onion using the mijingiri technique: make vertical slices, then horizontal slices while keeping the root intact, then perpendicular cuts." } },
      { id: "step-002", order: 2, instructions: { en: "Heat a large pan over medium heat with 1 Tbsp oil." } },
      { id: "step-003", order: 3, instructions: { en: "Add minced onions and sauté until tender and almost translucent." } },
      { id: "step-004", order: 4, instructions: { en: "Transfer sautéed onions to a bowl to cool." } },
      { id: "step-005", order: 5, instructions: { en: "Once cooled, combine onions with ¾ lb ground beef and pork blend (3:1 ratio recommended) in a large bowl." } },
      { id: "step-006", order: 6, instructions: { en: "Add ½ tsp kosher salt, black pepper, and ½ tsp nutmeg to the meat mixture." } },
      { id: "step-007", order: 7, instructions: { en: "Mix in ⅓ cup panko breadcrumbs, 2 Tbsp milk, and 1 large egg using a spatula." } },
      { id: "step-008", order: 8, instructions: { en: "Switch to hand-mixing and knead the mixture until it becomes sticky and pale in color." } },
      { id: "step-009", order: 9, instructions: { en: "Divide mixture into 4 portions (4 oz each) or 6 smaller portions." } },
      { id: "step-010", order: 10, instructions: { en: "Toss each portion between your hands about five times to release any air inside." } },
      { id: "step-011", order: 11, instructions: { en: "Shape each portion into an oval patty and place on a tray." } },
      { id: "step-012", order: 12, instructions: { en: "Cover patties with plastic wrap and refrigerate for at least 30 minutes." } },
      { id: "step-013", order: 13, instructions: { en: "Heat a large pan over medium heat with 1 Tbsp oil." } },
      { id: "step-014", order: 14, instructions: { en: "Place the patties gently into the pan." } },
      { id: "step-015", order: 15, instructions: { en: "Indent the center of each patty with two fingers." } },
      { id: "step-016", order: 16, instructions: { en: "Cook for approximately 3 minutes until the bottom browns." } },
      { id: "step-017", order: 17, instructions: { en: "Flip the patties and cook for another 3 minutes." } },
      { id: "step-018", order: 18, instructions: { en: "Add 3 Tbsp red wine to the pan and reduce heat to low." } },
      { id: "step-019", order: 19, instructions: { en: "Cover the pan with a lid and cook for 5-7 minutes until fully cooked." } },
      { id: "step-020", order: 20, instructions: { en: "Check doneness by inserting a skewer into the center of a patty. If clear juice comes out, the patties are fully cooked." } },
      { id: "step-021", order: 21, instructions: { en: "Increase heat to medium to evaporate any remaining alcohol from the wine." } },
      { id: "step-022", order: 22, instructions: { en: "Transfer the cooked patties to serving plates." } },
      { id: "step-023", order: 23, instructions: { en: "In the same pan, add 1 Tbsp butter, 3 Tbsp ketchup, and 3 Tbsp tonkatsu sauce." } },
      { id: "step-024", order: 24, instructions: { en: "Add 3 Tbsp red wine and 3 Tbsp water to the sauce mixture." } },
      { id: "step-025", order: 25, instructions: { en: "Mix the sauce ingredients well and bring to a simmer over medium heat until the alcohol evaporates." } },
      { id: "step-026", order: 26, instructions: { en: "Cook the sauce until thickened. The sauce is ready when the spatula leaves a line on the bottom of the pan." } },
      { id: "step-027", order: 27, instructions: { en: "Drizzle the sauce over the patties and serve remaining sauce on the side." } }
    ],
    equipment: ["pan with lid", "bowls"],
    admin_notes: "Japanese-style hamburger steak. Juicy and flavorful with sweet-savory sauce."
  }
]

recipes_data.each_with_index do |recipe_data, index|
  begin
    Recipe.create!(recipe_data)
    puts "✅ Created recipe #{index + 1}: #{recipe_data[:name]}"
  rescue => e
    puts "❌ Failed to create recipe #{index + 1}: #{recipe_data[:name]}"
    puts "   Error: #{e.message}"
  end
end

puts ""
puts "🎉 Seeding complete! Total recipes in database: #{Recipe.count}"
