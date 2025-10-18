# Smart Scaling System - Technical Design

⚠️ **WARNING: This is high-level pseudo-code for architectural planning. NOT production-ready. Requires rigorous testing, validation, and refinement before implementation.**

---

## Overview

The Smart Scaling System enables intelligent recipe scaling with two primary modes:

1. **Scale by Servings**: Multiply all ingredients by a factor (e.g., 4 servings → 6 servings = 1.5x)
2. **Scale by Ingredient**: Scale based on available ingredient amount (e.g., have 200g beef, recipe needs 500g = 0.4x)

### Core Design Principles

- **Context-Aware Precision**: Baking requires exactness (use grams), cooking allows approximation (use fractions)
- **Human-Friendly Output**: Prefer "2/3 cup" over "0.666 cups"
- **Unit Flexibility**: Step down to smaller units when needed (0.5 tbsp → 1.5 tsp)
- **Whole Item Intelligence**: Handle eggs, onions contextually (0.4 eggs → "1/2 egg" in cooking, "20g beaten egg" in baking)

---

## Core Components

### 1. ScalingEngine (Main Service)
Orchestrates all scaling operations.

```ruby
class RecipeScalingService
  def initialize(recipe, precision_context: 'cooking')
    @recipe = recipe
    @precision_context = precision_context
  end

  def scale_by_servings(target_servings)
    # Calculate factor and scale all ingredients
  end

  def scale_by_ingredient(ingredient_id, target_amount, target_unit)
    # Scale based on one ingredient's available amount
  end
end
```

### 2. Key Supporting Services

- **UnitConverter**: Handles unit conversions (tbsp → tsp, cups → ml)
- **FractionFormatter**: Converts decimals to friendly fractions (0.66 → "2/3")
- **PrecisionDetector**: Determines if recipe is baking/cooking context
- **WholeItemHandler**: Special logic for eggs, onions, etc.

---

## Algorithm Pseudo-Code

### Scale by Servings

```
FUNCTION scaleByServings(recipe, targetServings):
    // Calculate scaling factor
    scalingFactor = targetServings / recipe.servings

    // Detect cooking context (baking vs cooking)
    context = detectCookingContext(recipe)

    // Scale each ingredient
    FOR EACH ingredient IN recipe.ingredients:
        rawAmount = ingredient.amount * scalingFactor

        // Apply smart rounding based on context
        IF context == "baking":
            finalAmount = preservePrecision(rawAmount)
        ELSE:
            finalAmount = roundToFriendlyFraction(rawAmount)

        // Check if unit should be stepped down
        IF shouldStepDown(finalAmount, ingredient.unit):
            (finalAmount, finalUnit) = stepDownUnit(finalAmount, ingredient.unit)

        scaledIngredient = createScaledIngredient(ingredient, finalAmount, finalUnit)

    RETURN scaledRecipe
```

### Scale by Ingredient

```
FUNCTION scaleByIngredient(recipe, ingredientId, targetAmount, targetUnit):
    // Find the base ingredient
    baseIngredient = recipe.ingredients.find(id == ingredientId)

    // Convert target amount to same unit as original
    IF targetUnit != baseIngredient.unit:
        targetAmount = convert(targetAmount, targetUnit, baseIngredient.unit)

    // Calculate scaling factor from this ingredient
    scalingFactor = targetAmount / baseIngredient.amount

    // Scale all other ingredients using this factor
    FOR EACH ingredient IN recipe.ingredients:
        IF ingredient.id == ingredientId:
            // Use exact target amount
            scaledIngredient = ingredient with targetAmount
        ELSE:
            // Scale proportionally
            scaledIngredient = scaleIngredient(ingredient, scalingFactor, context)

    // Update serving count
    newServings = round(recipe.servings * scalingFactor)

    RETURN scaledRecipe with newServings
```

### Friendly Fraction Rounding

```
FUNCTION roundToFriendlyFraction(amount):
    // Try whole number first
    IF abs(amount - round(amount)) < 0.1:
        RETURN round(amount)

    // Try mixed number (e.g., 1 1/2)
    IF amount > 1:
        wholePart = floor(amount)
        fractionalPart = amount - wholePart

        fraction = findClosestFraction(fractionalPart)
        IF fraction found:
            RETURN MixedNumber(wholePart, fraction)

    // Try simple fraction
    fraction = findClosestFraction(amount)
    IF fraction found:
        RETURN fraction

    // Use decimal with 1 decimal place
    RETURN round(amount, 1)

FUNCTION findClosestFraction(decimal):
    // Common fractions
    fractions = {
        0.125: "1/8",
        0.25: "1/4",
        0.33: "1/3",
        0.5: "1/2",
        0.66: "2/3",
        0.75: "3/4"
    }

    FOR EACH (value, fractionStr) IN fractions:
        IF abs(decimal - value) < 0.02:  // 2% tolerance
            RETURN fractionStr

    RETURN null
```

### Unit Step-Down Logic

```
FUNCTION stepDownUnit(amount, currentUnit):
    // Step-down rules
    rules = {
        "cup": {threshold: 0.25, targetUnit: "tablespoon", factor: 16},
        "tablespoon": {threshold: 0.5, targetUnit: "teaspoon", factor: 3},
        "kilogram": {threshold: 0.1, targetUnit: "gram", factor: 1000},
        "liter": {threshold: 0.1, targetUnit: "milliliter", factor: 1000}
    }

    IF rules.has(currentUnit) AND amount < rules[currentUnit].threshold:
        newAmount = amount * rules[currentUnit].factor
        newUnit = rules[currentUnit].targetUnit

        // Verify the new amount is reasonable
        IF newAmount >= 1.0 AND newAmount < 100:
            RETURN (newAmount, newUnit)

    // No step-down needed
    RETURN (amount, currentUnit)
```

### Precision Detection

```
FUNCTION detectCookingContext(recipe):
    // Baking keywords
    bakingKeywords = ["cake", "bread", "cookie", "pastry", "dough",
                      "batter", "macarons", "soufflé", "meringue"]

    recipeText = (recipe.title + " " + recipe.tags.join(" ")).toLowerCase()

    FOR EACH keyword IN bakingKeywords:
        IF recipeText.contains(keyword):
            RETURN "baking"

    // Check for precision ingredients (flour, yeast, baking powder)
    precisionIngredientCount = 0
    FOR EACH ingredient IN recipe.ingredients:
        IF ingredient.name IN ["flour", "yeast", "baking powder", "baking soda"]:
            precisionIngredientCount++

    IF precisionIngredientCount >= 3:
        RETURN "baking"

    // Default to cooking
    RETURN "cooking"
```

### Whole Item Handling

```
FUNCTION handleWholeItem(ingredient, scaledAmount, context):
    itemName = ingredient.name.toLowerCase()

    // If very close to whole number, just round
    IF abs(scaledAmount - round(scaledAmount)) < 0.1:
        RETURN round(scaledAmount)

    // Eggs in baking context
    IF itemName contains "egg" AND context == "baking":
        // Convert to weight for precision
        eggWeight = 50  // grams per large egg
        gramsNeeded = round(scaledAmount * eggWeight)

        RETURN {
            displayAmount: gramsNeeded + "g beaten egg",
            note: "For baking precision"
        }

    // Eggs in cooking context
    IF itemName contains "egg" AND context == "cooking":
        // Round to nearest practical fraction
        IF scaledAmount < 0.3:
            RETURN 0 with note "Very small amount - consider omitting"
        ELSE IF scaledAmount <= 0.6:
            RETURN 0.5  // "1/2 egg" or "1 egg white"
        ELSE:
            RETURN round(scaledAmount)

    // Other whole items (onions, etc.)
    // Round to nearest quarter
    quarters = round(scaledAmount * 4) / 4
    RETURN quarters  // e.g., 0.75 = "3/4 onion"
```

### Unit Conversion

```
FUNCTION convert(amount, fromUnit, toUnit):
    // Conversion table (stored in database)
    conversions = {
        ("cup", "tablespoon"): 16,
        ("tablespoon", "teaspoon"): 3,
        ("cup", "milliliter"): 240,
        ("kilogram", "gram"): 1000,
        ("pound", "ounce"): 16
        // ... more conversions
    }

    // Check if same unit
    IF fromUnit == toUnit:
        RETURN amount

    // Look up direct conversion
    IF conversions.has((fromUnit, toUnit)):
        factor = conversions[(fromUnit, toUnit)]
        RETURN amount * factor

    // Check reverse conversion
    IF conversions.has((toUnit, fromUnit)):
        factor = conversions[(toUnit, fromUnit)]
        RETURN amount / factor

    // No conversion found
    RETURN Error("Cannot convert between units")
```

---

## Edge Cases & Handling

### 1. Very Small Amounts
```
IF scaledAmount < 0.125:
    IF ingredient.isOptional:
        RETURN 0 with note "Consider omitting"
    ELSE IF ingredient.isSpice:
        RETURN "pinch" as displayAmount
    ELSE:
        RETURN minimum measurable amount with warning
```

### 2. Very Large Scaling Factors
```
IF scalingFactor > 5 OR scalingFactor < 0.2:
    warnings.add("Large scaling may affect cooking time")

    // Don't scale spices linearly
    IF ingredient.category == "spice":
        adjustedFactor = scalingFactor * 0.7  // Scale less aggressively
```

### 3. Zero or Negative Amounts
```
IF scaledAmount <= 0:
    IF ingredient.isOptional:
        RETURN 0 with note "Omit"
    ELSE:
        RETURN minimum viable amount with warning
```

### 4. Unit Conversion Failures
```
IF cannot convert units:
    // Preserve original unit
    RETURN scaledAmount in originalUnit
    ADD warning "Cannot convert to target unit"
```

### 5. Fractional Servings
```
IF target servings is fractional (e.g., 2.5):
    ALLOW fractional servings
    DISPLAY as "Makes approximately 2.5 servings (2-3 people)"
    USE exact value for calculations
```

---

## Data Structures

### Recipe JSON
```json
{
  "id": "recipe-001",
  "title": "Chocolate Chip Cookies",
  "servings": 24,
  "tags": ["dessert", "baking", "cookies"],
  "ingredients": [
    {
      "id": "ing-001",
      "name": "flour",
      "amount": 2.0,
      "unit": "cup",
      "isOptional": false,
      "category": "baking_essential"
    },
    {
      "id": "ing-002",
      "name": "eggs",
      "amount": 2,
      "unit": "whole",
      "isOptional": false,
      "category": "protein"
    }
  ]
}
```

### Scaled Ingredient Result
```json
{
  "original": {/* original ingredient */},
  "scaledAmount": 3.0,
  "displayAmount": "3 cups",
  "scaledUnit": "cup",
  "scalingFactor": 1.5,
  "suggestions": [
    {
      "amount": "48 tablespoons",
      "unit": "tbsp",
      "explanation": "Smaller unit alternative"
    }
  ],
  "warnings": []
}
```

---

## Configuration Tables

### Common Fractions
```ruby
COMMON_FRACTIONS = {
  0.125 => "1/8",
  0.25 => "1/4",
  0.33 => "1/3",
  0.375 => "3/8",
  0.5 => "1/2",
  0.625 => "5/8",
  0.66 => "2/3",
  0.75 => "3/4",
  0.875 => "7/8"
}

TOLERANCE = 0.02  # 2% tolerance for matching
```

### Step-Down Rules
```ruby
STEP_DOWN_RULES = {
  "cup" => {threshold: 0.25, target: "tablespoon", factor: 16},
  "tablespoon" => {threshold: 0.5, target: "teaspoon", factor: 3},
  "kilogram" => {threshold: 0.1, target: "gram", factor: 1000},
  "liter" => {threshold: 0.1, target: "milliliter", factor: 1000},
  "pound" => {threshold: 0.25, target: "ounce", factor: 16}
}
```

---

## Rails Integration Example

### Service Object
```ruby
# app/services/recipe_scaling_service.rb
class RecipeScalingService
  def initialize(recipe, precision_context: nil)
    @recipe = recipe
    @precision_context = precision_context || detect_precision_context
  end

  def scale_by_servings(target_servings)
    scaling_factor = target_servings.to_f / @recipe.servings
    scale_all_ingredients(scaling_factor)
  end

  def scale_by_ingredient(ingredient_id, target_amount, target_unit)
    base_ingredient = @recipe.ingredients.find(ingredient_id)
    scaling_factor = calculate_ingredient_based_factor(
      base_ingredient, target_amount, target_unit
    )
    scale_all_ingredients(scaling_factor)
  end

  private

  def scale_all_ingredients(factor)
    scaled_ingredients = @recipe.ingredients.map do |ingredient|
      IngredientScaler.new(ingredient, factor, @precision_context).scale
    end

    build_scaled_recipe(scaled_ingredients, factor)
  end

  def detect_precision_context
    PrecisionDetector.new(@recipe).detect
  end
end
```

### Controller Usage
```ruby
# app/controllers/recipes_controller.rb
class RecipesController < ApplicationController
  def scale
    @recipe = Recipe.find(params[:id])

    scaled_recipe = RecipeScalingService
      .new(@recipe)
      .scale_by_servings(params[:target_servings].to_i)

    render json: ScaledRecipeSerializer.new(scaled_recipe)
  end
end
```

---

## Testing Strategy

### Unit Tests
```ruby
describe RecipeScalingService do
  describe "#scale_by_servings" do
    it "scales ingredients proportionally" do
      recipe = create(:recipe, servings: 4, ingredients: [
        {name: "flour", amount: 2.0, unit: "cup"}
      ])

      scaled = RecipeScalingService.new(recipe).scale_by_servings(6)

      expect(scaled.ingredients.first.amount).to eq(3.0)
    end

    it "rounds to friendly fractions in cooking context" do
      # 2 cups * 1.5 = 3 cups (stays whole)
      # 1 cup * 0.66 = 0.66 cups → "2/3 cup"
    end

    it "preserves precision in baking context" do
      # 2.5 cups * 1.2 = 3.0 cups (exact decimal)
    end
  end

  describe "#scale_by_ingredient" do
    it "calculates factor from target ingredient" do
      # Recipe: 500g beef, scale to 200g
      # Factor: 200/500 = 0.4
      # All ingredients scale by 0.4
    end
  end
end

describe FractionFormatter do
  it "converts decimals to friendly fractions" do
    expect(format(0.5)).to eq("1/2")
    expect(format(0.66)).to eq("2/3")
    expect(format(1.5)).to eq("1 1/2")
  end
end

describe WholeItemHandler do
  it "handles eggs in baking context" do
    # 2.3 eggs in baking → "115g beaten egg"
  end

  it "handles eggs in cooking context" do
    # 2.3 eggs in cooking → "2 eggs"
  end
end
```

---

## Performance Considerations

### Targets
- Recipe scaling: < 50ms for recipes with up to 50 ingredients
- Unit conversion lookup: < 5ms (cached)
- Fraction calculation: < 10ms

### Optimizations
1. **Cache unit conversions** (static data, never expires)
2. **Cache precision detection** per recipe (session-based)
3. **Lazy evaluation** for display suggestions (only when requested)
4. **Database indexing** on recipe.id and ingredient lookups

### Memory
- Recipe object: ~5KB
- Scaled recipe: ~10KB (includes suggestions)
- Target: Support 1000 concurrent scaling operations (~10MB)

---

## Implementation Checklist

### Phase 1: Core Functionality
- [ ] Implement basic servings-based scaling
- [ ] Create unit conversion table
- [ ] Build fraction formatter
- [ ] Add whole item detection

### Phase 2: Smart Features
- [ ] Context detection (baking vs cooking)
- [ ] Precision-aware rounding
- [ ] Unit step-down logic
- [ ] Enhanced whole item handling

### Phase 3: Ingredient-Based Scaling
- [ ] Implement scale-by-ingredient
- [ ] Handle unit mismatches
- [ ] Serving count recalculation

### Phase 4: Polish
- [ ] Comprehensive error messages
- [ ] Edge case hardening
- [ ] Performance optimization
- [ ] Testing coverage

---

## Key Design Decisions

1. **Rule-based vs AI-based**: Using rule-based system for predictability and speed
2. **BigDecimal for precision**: Avoid floating-point errors in calculations
3. **Session-based scaling**: Don't modify original recipes, create scaled views
4. **Database storage**: Store conversion rules in DB for easy updates
5. **Context detection**: Automatic detection with manual override option

---

## Future Enhancements

- Nutrition-based scaling (scale to target calories/protein)
- Batch recipe scaling (scale multiple recipes together)
- Custom unit systems (regional variations)
- Ingredient substitution integration
- Cost-based scaling (scale to budget)

---

*This design provides the algorithmic foundation for the smart scaling system. Implementation should follow Rails best practices and include comprehensive testing before production use.*
