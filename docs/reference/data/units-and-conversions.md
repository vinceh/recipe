# Units and Conversion System Reference

This document defines the unit conversion system for the smart scaling engine.

## Supported Units

### Volume (Liquid)

**Metric:**
- `ml` - milliliter
- `l` - liter
- `cl` - centiliter (10ml)
- `dl` - deciliter (100ml)

**Imperial/US:**
- `tsp` - teaspoon (5ml)
- `tbsp` - tablespoon (15ml)
- `fl_oz` - fluid ounce (30ml)
- `cup` - cup (240ml)
- `pint` - pint (473ml)
- `quart` - quart (946ml)
- `gallon` - gallon (3785ml)

### Weight (Mass)

**Metric:**
- `mg` - milligram
- `g` - gram
- `kg` - kilogram

**Imperial/US:**
- `oz` - ounce (28.35g)
- `lb` - pound (453.6g)

### Length/Distance

- `mm` - millimeter
- `cm` - centimeter
- `m` - meter
- `inch` - inch (2.54cm)
- `ft` - foot (30.48cm)

### Temperature

- `c` - Celsius
- `f` - Fahrenheit
- `k` - Kelvin

### Special Units

- `whole` - whole items (eggs, onions, etc.)
- `slice` - slices
- `piece` - pieces
- `clove` - cloves (garlic)
- `sprig` - sprigs (herbs)
- `leaf` - leaves
- `bunch` - bunch
- `package` - package
- `can` - can
- `jar` - jar
- `pinch` - pinch
- `dash` - dash
- `to_taste` - to taste (null quantity)

## Conversion Tables

### Volume Conversions (Base: ml)

```json
{
  "tsp": 5,
  "tbsp": 15,
  "fl_oz": 30,
  "cup": 240,
  "pint": 473,
  "quart": 946,
  "gallon": 3785,
  "ml": 1,
  "cl": 10,
  "dl": 100,
  "l": 1000
}
```

### Weight Conversions (Base: g)

```json
{
  "mg": 0.001,
  "g": 1,
  "kg": 1000,
  "oz": 28.35,
  "lb": 453.6
}
```

### Common Cooking Ratios

```json
{
  "1 tbsp": "3 tsp",
  "1 cup": "16 tbsp",
  "1 cup": "48 tsp",
  "1 fl_oz": "2 tbsp",
  "1 pint": "2 cups",
  "1 quart": "4 cups",
  "1 gallon": "16 cups"
}
```

## Smart Scaling Rules

### Friendly Fractions

When scaling results in decimals, prefer these fractions:

```javascript
const FRIENDLY_FRACTIONS = {
  0.125: "1/8",
  0.25: "1/4",
  0.333: "1/3",
  0.375: "3/8",
  0.5: "1/2",
  0.625: "5/8",
  0.666: "2/3",
  0.75: "3/4",
  0.875: "7/8"
}
```

**Tolerance:** ±0.02 for matching fractions

**Examples:**
- 0.66 tbsp → "2/3 tbsp"
- 0.48 tsp → "1/2 tsp" (close enough)
- 0.33 cup → "1/3 cup"

### Unit Step-Down Rules

When scaled amount becomes awkward, step down to smaller unit:

```javascript
const STEP_DOWN_RULES = {
  // Tablespoon → Teaspoon
  { from: "tbsp", to: "tsp", threshold: 0.5 },
  // Example: 0.33 tbsp → 1 tsp

  // Cup → Tablespoon
  { from: "cup", to: "tbsp", threshold: 0.25 },
  // Example: 0.125 cup → 2 tbsp

  // Ounce → Gram (for precision)
  { from: "oz", to: "g", threshold: 1, context: "baking" },
  // Example: 0.4 oz → 11g (for baking recipes)

  // Pound → Ounce
  { from: "lb", to: "oz", threshold: 0.5 },
  // Example: 0.25 lb → 4 oz
}
```

### Whole Item Scaling

Special handling for countable items:

```javascript
const WHOLE_ITEM_RULES = {
  // Eggs: Always round to nearest half
  eggs: {
    precision: 0.5,
    max_decimal: 0.5,
    convert_to_grams_if_baking: true,
    grams_per_egg: 50
  },

  // Onions: Round to nearest quarter
  onions: {
    precision: 0.25,
    allow_fractions: true
  },

  // Garlic cloves: Round to nearest whole
  garlic_cloves: {
    precision: 1,
    allow_fractions: false
  }
}
```

**Examples:**
- 2.3 eggs → "2 eggs" (cooking) or "115g eggs" (baking)
- 0.4 eggs → "1/2 egg" (cooking) or "20g eggs" (baking)
- 1.6 onions → "1 1/2 onions"
- 2.3 cloves garlic → "2 cloves garlic"

### Precision Context

Different precision rules based on recipe type:

```javascript
const PRECISION_RULES = {
  baking: {
    decimal_places: 1,
    prefer_grams: true,
    allow_approximate: false
  },

  cooking: {
    decimal_places: 0,
    prefer_fractions: true,
    allow_approximate: true
  },

  confectionery: {
    decimal_places: 1,
    prefer_grams: true,
    require_temperature_precision: true
  }
}
```

## Recipe Precision Flag

Add to recipe schema:

```json
{
  "requires_precision": true,
  "precision_reason": "baking",
  // Options: "baking", "confectionery", "fermentation", "molecular", "sous_vide"
  ...
}
```

**Detection Keywords** (for AI extraction):
- Contains: cake, bread, pastry, cookie, macaron, soufflé, custard
- Contains: candy, chocolate tempering, sugar work, caramel
- Contains: fermentation, cheese making, pickling (with salt ratios)
- Contains: sous vide, spherification, hydrocolloid, emulsification

## Implementation Example

```javascript
function smartScale(ingredient, scaleFactor, recipeContext) {
  const rawAmount = ingredient.quantity * scaleFactor;
  const unit = ingredient.unit;
  const requiresPrecision = recipeContext.requires_precision;

  // Special handling for "to taste" or null quantities
  if (unit === "to_taste" || ingredient.quantity === null) {
    return { quantity: null, unit: "to_taste" };
  }

  // Whole items (eggs, onions, etc.)
  if (unit === "whole") {
    return scaleWholeItem(rawAmount, ingredient.name, requiresPrecision);
  }

  // Precision recipes: convert to grams/ml
  if (requiresPrecision && canConvertToPreciseUnit(unit)) {
    return convertToPreciseUnit(rawAmount, unit);
  }

  // Check if we should step down to smaller unit
  if (shouldStepDown(rawAmount, unit)) {
    return stepDownUnit(rawAmount, unit);
  }

  // Try to express as friendly fraction
  const fraction = toFriendlyFraction(rawAmount);
  if (fraction) {
    return { quantity: fraction, unit: unit };
  }

  // Default: round to reasonable precision
  return {
    quantity: roundToDecimalPlaces(rawAmount, requiresPrecision ? 1 : 0),
    unit: unit
  };
}
```

## Display Format Examples

```javascript
// Cooking recipe (scaled to 0.4x)
"1 tbsp soy sauce" → "1 tsp soy sauce"
"2 eggs" → "1 egg"
"500g chicken" → "200g chicken"

// Baking recipe (scaled to 0.4x)
"1 tbsp butter" → "6g butter"
"2 eggs" → "100g eggs" or "2 eggs (100g)"
"500g flour" → "200g flour"

// Display both formats for clarity
"1/2 cup (120ml)"
"2 tbsp (30ml)"
"1/2 egg (25g)"
```

## Validation Rules

1. All units must be from the allowed list
2. Quantities must be positive numbers or null (for "to_taste")
3. Temperature units must match context (C/F for cooking, K for scientific)
4. Conversion must maintain approximate equivalence (±5%)

## Future Enhancements

- Density-based conversions (1 cup flour ≠ 1 cup water in grams)
- Regional preferences (US vs UK cup sizes, tablespoon differences)
- Ingredient-specific density database
- Smart suggestions: "Recipe calls for 1/3 cup + 2 tsp, simplify to 6 tbsp?"
