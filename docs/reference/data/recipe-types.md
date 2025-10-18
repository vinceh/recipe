# Standardized Recipe Types Reference

This document defines all allowed recipe types. Recipes can have multiple types.

## Recipe Type Categories

**Key**: `recipe_types`
**Type**: Array of strings
**Purpose**: Categorize recipes by dish type and meal context

### Allowed Values

```yaml
# By Course
- appetizer           # Starters, small plates, hors d'oeuvres
- salad               # Leafy salads, grain salads, etc.
- soup                # All soups (hot and cold)
- main_course         # Primary dish of a meal
- side_dish           # Accompaniments to main courses
- dessert             # Sweet dishes served after meal
- snack               # Small portions for between meals
- beverage            # Drinks (smoothies, cocktails, tea, coffee)

# By Meal Time
- breakfast           # Morning meals
- brunch              # Late morning/early afternoon
- lunch               # Midday meal
- dinner              # Evening meal

# By Cooking Method
- baked               # Oven-baked dishes
- grilled             # Cooked on grill or griddle
- fried               # Deep-fried or pan-fried
- roasted             # Dry heat in oven
- steamed             # Cooked with steam
- raw                 # No cooking (salads, ceviche, etc.)
- slow_cooked         # Slow cooker/crockpot dishes
- instant_pot         # Pressure cooker dishes
- air_fried           # Air fryer dishes
- sous_vide           # Precision water bath cooking
- fermented           # Fermented preparations

# By Dish Type
- casserole           # Baked one-dish meals
- stew                # Slow-cooked dishes with liquid
- curry               # Spiced sauce-based dishes
- stir_fry            # Quick high-heat cooking
- pasta               # Pasta-based dishes
- rice_bowl           # Rice as base with toppings
- noodles             # Noodle-based dishes
- pizza               # Pizza and flatbreads
- sandwich            # Sandwiches, wraps, burgers
- taco                # Tacos, burritos, quesadillas
- pie                 # Savory and sweet pies
- tart                # Open-faced pastries
- bread               # Baked breads and rolls
- cake                # Cakes and layer cakes
- cookies             # Cookies and biscuits
- pastry              # Pastries and baked goods
- pudding             # Creamy desserts
- ice_cream           # Frozen desserts
- candy               # Confections

# By Protein
- chicken             # Chicken-based dishes
- beef                # Beef-based dishes
- pork                # Pork-based dishes
- lamb                # Lamb-based dishes
- seafood             # Fish and seafood
- shellfish           # Shrimp, crab, lobster, etc.
- vegetable_focused   # Primarily vegetables
- legume_based        # Beans, lentils, chickpeas
- tofu_tempeh         # Soy protein dishes
- egg_based           # Eggs as primary protein

# By Special Occasion
- holiday             # Holiday-specific recipes
- party               # Party and entertaining
- picnic              # Portable outdoor meals
- meal_prep           # Batch cooking for week
- quick_weeknight     # Fast weeknight dinners (<30 min)
- comfort_food        # Nostalgic, hearty dishes
- fancy_dinner        # Special occasion, impressive

# By Texture/Temperature
- crispy              # Crispy or crunchy texture
- creamy              # Smooth, creamy texture
- hot                 # Served hot
- cold                # Served cold/chilled
- room_temp           # Served at room temperature

# By Portion Style
- one_pot             # Single pot/pan cooking
- sheet_pan           # Sheet pan meals
- individual_serving  # Portioned individually
- family_style        # Shared large portion
- finger_food         # Eaten with hands
```

## Usage in Recipe Schema

```json
{
  "recipe_types": [
    "main_course",
    "japanese",
    "rice_bowl",
    "chicken",
    "quick_weeknight"
  ],
  ...
}
```

## Human-Readable Labels (for UI)

```javascript
const RECIPE_TYPE_LABELS = {
  // Course
  appetizer: "Appetizer",
  salad: "Salad",
  soup: "Soup",
  main_course: "Main Course",
  side_dish: "Side Dish",
  dessert: "Dessert",
  snack: "Snack",
  beverage: "Beverage",

  // Meal Time
  breakfast: "Breakfast",
  brunch: "Brunch",
  lunch: "Lunch",
  dinner: "Dinner",

  // Cooking Method
  baked: "Baked",
  grilled: "Grilled",
  fried: "Fried",
  roasted: "Roasted",
  steamed: "Steamed",
  raw: "Raw",
  slow_cooked: "Slow Cooked",
  instant_pot: "Instant Pot",
  air_fried: "Air Fried",
  sous_vide: "Sous Vide",
  fermented: "Fermented",

  // Dish Type
  casserole: "Casserole",
  stew: "Stew",
  curry: "Curry",
  stir_fry: "Stir Fry",
  pasta: "Pasta",
  rice_bowl: "Rice Bowl",
  noodles: "Noodles",
  pizza: "Pizza",
  sandwich: "Sandwich",
  taco: "Taco",
  pie: "Pie",
  tart: "Tart",
  bread: "Bread",
  cake: "Cake",
  cookies: "Cookies",
  pastry: "Pastry",
  pudding: "Pudding",
  ice_cream: "Ice Cream",
  candy: "Candy",

  // Protein
  chicken: "Chicken",
  beef: "Beef",
  pork: "Pork",
  lamb: "Lamb",
  seafood: "Seafood",
  shellfish: "Shellfish",
  vegetable_focused: "Vegetable-Focused",
  legume_based: "Legume-Based",
  tofu_tempeh: "Tofu/Tempeh",
  egg_based: "Egg-Based",

  // Special Occasion
  holiday: "Holiday",
  party: "Party",
  picnic: "Picnic",
  meal_prep: "Meal Prep",
  quick_weeknight: "Quick Weeknight",
  comfort_food: "Comfort Food",
  fancy_dinner: "Fancy Dinner",

  // Texture/Temperature
  crispy: "Crispy",
  creamy: "Creamy",
  hot: "Hot",
  cold: "Cold",
  room_temp: "Room Temperature",

  // Portion Style
  one_pot: "One Pot",
  sheet_pan: "Sheet Pan",
  individual_serving: "Individual Serving",
  family_style: "Family Style",
  finger_food: "Finger Food"
}
```

## Grouping for UI Filters

When building filter UI, group types logically:

```javascript
const RECIPE_TYPE_GROUPS = {
  "Course": ["appetizer", "salad", "soup", "main_course", "side_dish", "dessert", "snack", "beverage"],
  "Meal Time": ["breakfast", "brunch", "lunch", "dinner"],
  "Cooking Method": ["baked", "grilled", "fried", "roasted", "steamed", "raw", "slow_cooked", "instant_pot", "air_fried", "sous_vide", "fermented"],
  "Dish Type": ["casserole", "stew", "curry", "stir_fry", "pasta", "rice_bowl", "noodles", "pizza", "sandwich", "taco", "pie", "tart", "bread", "cake", "cookies", "pastry", "pudding", "ice_cream", "candy"],
  "Protein": ["chicken", "beef", "pork", "lamb", "seafood", "shellfish", "vegetable_focused", "legume_based", "tofu_tempeh", "egg_based"],
  "Style": ["holiday", "party", "picnic", "meal_prep", "quick_weeknight", "comfort_food", "fancy_dinner", "one_pot", "sheet_pan"]
}
```

## AI Prompt Integration

```
Available recipe types (can apply multiple):

By Course: appetizer, salad, soup, main_course, side_dish, dessert, snack, beverage
By Meal: breakfast, brunch, lunch, dinner
By Method: baked, grilled, fried, roasted, steamed, raw, slow_cooked, instant_pot, air_fried, sous_vide, fermented
By Dish: casserole, stew, curry, stir_fry, pasta, rice_bowl, noodles, pizza, sandwich, taco, pie, tart, bread, cake, cookies, pastry, pudding, ice_cream, candy
By Protein: chicken, beef, pork, lamb, seafood, shellfish, vegetable_focused, legume_based, tofu_tempeh, egg_based
By Style: holiday, party, picnic, meal_prep, quick_weeknight, comfort_food, fancy_dinner, one_pot, sheet_pan, crispy, creamy, hot, cold, room_temp, individual_serving, family_style, finger_food

Analyze the recipe and return the most relevant types as an array.
```

## Validation Rules

1. All types must be lowercase with underscores
2. Recipes should have 2-6 types (minimum 1, maximum 10)
3. Types should be logically consistent
4. Include at least one "Course" type when applicable

## Future Additions

When adding new recipe types:
1. Update this document
2. Update database schema validation
3. Update frontend filter UI
4. Update AI prompts
5. Consider organizing existing recipes with new type
