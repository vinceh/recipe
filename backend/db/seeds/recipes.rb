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
      {
        id: 1,
        instructions: {
          original: "In a small bowl, mix dashi, soy sauce, mirin, and sugar to make the sauce.",
          easier: nil,
          no_equipment: nil
        },
        equipment: ["small bowl"]
      },
      {
        id: 2,
        instructions: {
          original: "Heat a pan over medium heat and add the sauce mixture. Bring to a simmer.",
          easier: nil,
          no_equipment: nil
        },
        equipment: ["frying pan"]
      },
      {
        id: 3,
        instructions: {
          original: "Add sliced onion and cook until softened, about 3 minutes.",
          easier: nil,
          no_equipment: nil
        },
        equipment: ["frying pan"]
      },
      {
        id: 4,
        instructions: {
          original: "Add chicken pieces and cook until no longer pink, about 5 minutes.",
          easier: nil,
          no_equipment: nil
        },
        equipment: ["frying pan"]
      },
      {
        id: 5,
        instructions: {
          original: "Pour beaten eggs over the chicken in a circular motion. Do not stir.",
          easier: nil,
          no_equipment: nil
        },
        equipment: ["frying pan"]
      },
      {
        id: 6,
        instructions: {
          original: "Cover and cook until eggs are just set but still slightly runny, about 2 minutes.",
          easier: nil,
          no_equipment: nil
        },
        equipment: ["frying pan", "lid"]
      },
      {
        id: 7,
        instructions: {
          original: "Serve over steamed rice and garnish with chopped green onions.",
          easier: nil,
          no_equipment: nil
        },
        equipment: []
      }
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
