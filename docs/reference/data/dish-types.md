# Standardized Dish Types Reference

This document defines all allowed dish types for recipes. Dish types indicate what course or category the dish belongs to.

**Source:** Edamam Dish Type standard (industry standard for recipe categorization)

**Note:** This is separate from `recipe_types` which describes cooking methods, proteins, and styles.

## Dish Types

**Key**: `dish_types`
**Type**: Array of strings
**Purpose**: Categorize recipes by course/meal category
**Format**: lowercase with hyphens

### Allowed Values

```yaml
- biscuits-and-cookies  # Cookies, biscuits, crackers
- bread                 # Breads, rolls, baguettes, flatbreads
- cereals               # Breakfast cereals, oatmeal, granola
- condiments-and-sauces # Condiments, sauces, dressings, spreads
- desserts              # Sweet dishes, cakes, pastries (not cookies/bread)
- drinks                # Beverages, smoothies, juices, cocktails
- main-course           # Primary dish of a meal, entrées
- pancake               # Pancakes, waffles, crepes
- preps                 # Prepared ingredients (stocks, doughs, bases)
- preserve              # Jams, pickles, preserves, canned goods
- salad                 # Salads of all types
- sandwiches            # Sandwiches, wraps, burgers
- side-dish             # Accompaniments to main courses
- soup                  # Soups, stews, broths
- starter               # Appetizers, hors d'oeuvres, first course
- sweets                # Candies, confections, sweet snacks
```

**Total:** 16 dish types

## Usage in Recipe Schema

```json
{
  "dish_types": ["main-course"],
  ...
}
```

Most recipes will have only one dish type, but multiple are allowed:

```json
{
  "dish_types": ["side-dish", "salad"],
  ...
}
```

## Human-Readable Labels (for UI)

```javascript
const DISH_TYPE_LABELS = {
  'biscuits-and-cookies': 'Biscuits & Cookies',
  'bread': 'Bread',
  'cereals': 'Cereals',
  'condiments-and-sauces': 'Condiments & Sauces',
  'desserts': 'Desserts',
  'drinks': 'Drinks',
  'main-course': 'Main Course',
  'pancake': 'Pancakes & Waffles',
  'preps': 'Meal Prep',
  'preserve': 'Preserves',
  'salad': 'Salad',
  'sandwiches': 'Sandwiches',
  'side-dish': 'Side Dish',
  'soup': 'Soup',
  'starter': 'Starter',
  'sweets': 'Sweets'
}
```

## AI Prompt Integration

When using AI to extract or validate dish types, provide this list:

```
Available dish types: biscuits-and-cookies, bread, cereals, condiments-and-sauces, desserts, drinks, main-course, pancake, preps, preserve, salad, sandwiches, side-dish, soup, starter, sweets

Analyze the recipe and return the most appropriate dish type(s) from this list. Most recipes will have only one.
```

## Examples

| Recipe | Dish Type(s) |
|--------|--------------|
| Spaghetti Carbonara | `["main-course"]` |
| Caesar Salad | `["salad", "side-dish"]` |
| Chocolate Chip Cookies | `["biscuits-and-cookies"]` |
| Tom Yum Soup | `["soup"]` |
| Sourdough Bread | `["bread"]` |
| Spring Rolls | `["starter"]` |
| Mango Smoothie | `["drinks"]` |
| Tiramisu | `["desserts"]` |
| Coleslaw | `["side-dish"]` |
| Chicken Stock | `["preps"]` |
| Strawberry Jam | `["preserve"]` |
| BBQ Sauce | `["condiments-and-sauces"]` |
| Blueberry Pancakes | `["pancake"]` |
| Club Sandwich | `["sandwiches"]` |
| Fudge | `["sweets"]` |
| Granola | `["cereals"]` |

## Relationship to Recipe Types

**Dish Types** answer: "What course/category is this?"
**Recipe Types** answer: "How is it made? What's in it? What style?"

Example: Pad Thai
- `dish_types`: `["main-course"]`
- `recipe_types`: `["stir-fry", "noodles", "quick-weeknight"]`
- `cuisines`: `["thai"]`

## Database Seeding

```ruby
# db/seeds/dish_types.rb
DISH_TYPES = {
  'biscuits-and-cookies' => 'Biscuits & Cookies',
  'bread' => 'Bread',
  'cereals' => 'Cereals',
  'condiments-and-sauces' => 'Condiments & Sauces',
  'desserts' => 'Desserts',
  'drinks' => 'Drinks',
  'main-course' => 'Main Course',
  'pancake' => 'Pancakes & Waffles',
  'preps' => 'Meal Prep',
  'preserve' => 'Preserves',
  'salad' => 'Salad',
  'sandwiches' => 'Sandwiches',
  'side-dish' => 'Side Dish',
  'soup' => 'Soup',
  'starter' => 'Starter',
  'sweets' => 'Sweets'
}

DISH_TYPES.each_with_index do |(key, display_name), index|
  DataReference.find_or_create_by!(
    reference_type: 'dish_type',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.sort_order = index
    ref.active = true
  end
end
```

## Validation Rules

1. Dish types must be lowercase with hyphens
2. Multiple dish types allowed (though usually only 1-2)
3. Must come from the allowed list above
4. Consider overlap carefully:
   - ✅ `["salad", "side-dish"]` - A salad served as a side
   - ✅ `["soup", "main-course"]` - Hearty soup as main dish
   - ❌ `["desserts", "main-course"]` - Usually contradictory
   - ❌ `["biscuits-and-cookies", "bread"]` - Pick the most specific one

## Future Additions

When adding new dish types:
1. Update this document
2. Update database seed file
3. Update frontend filter UI
4. Update AI prompts
5. Coordinate with Edamam standard if possible
