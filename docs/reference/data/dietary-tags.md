# Standardized Dietary Tags Reference

This document defines all allowed dietary tags for recipes. Use these exact strings in the recipe schema.

**Source:** Merged from our original list + Edamam Health Labels (comprehensive industry standard)

## Dietary Restrictions

**Key**: `dietary_tags`
**Type**: Array of strings
**Purpose**: Filter recipes by dietary needs
**Format**: lowercase with hyphens (e.g., `gluten-free`, not `gluten_free`)

### Allowed Values

```yaml
# Animal Product Restrictions
- vegetarian          # No meat, poultry, or seafood (may include eggs/dairy)
- vegan               # No animal products whatsoever
- pescatarian         # No meat or poultry (seafood allowed)
- pork-free           # No pork products
- red-meat-free       # No beef, lamb, pork

# Religious/Cultural Dietary Laws
- kosher              # Follows Jewish dietary laws
- halal               # Follows Islamic dietary guidelines (not in Edamam but commonly needed)

# Allergen-Free (Edamam Standard)
- gluten-free         # No wheat, barley, rye, or gluten-containing ingredients
- wheat-free          # No wheat (but may contain other gluten grains)
- dairy-free          # No milk, cheese, butter, cream, yogurt
- egg-free            # No eggs or egg products
- soy-free            # No soy or soy-derived ingredients
- fish-free           # No fish or fish products
- shellfish-free      # No shrimp, crab, lobster, etc.
- tree-nut-free       # No tree nuts (almonds, walnuts, cashews, etc.)
- peanut-free         # No peanuts or peanut products
- crustacean-free     # No crabs, lobster, shrimp (subset of shellfish)
- mollusk-free        # No clams, oysters, mussels, squid
- celery-free         # No celery (common allergen in EU)
- mustard-free        # No mustard
- sesame-free         # No sesame seeds or sesame oil
- lupine-free         # No lupin beans (allergen in some regions)
- sulfite-free        # No sulfites/sulphites

# Specialized Diets
- keto-friendly       # Very low carb, high fat (typically <20g net carbs per serving)
- paleo               # No grains, legumes, dairy, or processed foods
- Mediterranean       # Mediterranean diet principles
- DASH                # Dietary Approaches to Stop Hypertension
- low-fat-abs         # Low fat (absolute terms)
- low-sugar           # Reduced sugar content
- sugar-conscious     # Mindful of sugar content
- low-carb            # Reduced carbohydrate content (not in original list)
- low-sodium          # Reduced sodium (not in original list)
- kidney-friendly     # Suitable for kidney disease diets
- immuno-supportive   # Supports immune system

# Preparation Methods & Special Considerations
- alcohol-free        # No alcoholic ingredients (including cooking wine)
- alcohol-cocktail    # Contains alcohol (for filtering out when alcohol-free needed)
- no-oil-added        # No oils added during cooking
- fodmap-free         # Low FODMAP diet (IBS-friendly)
- whole30             # Whole30 elimination diet compliant (not in Edamam)
- raw                 # No cooking above 118°F (48°C) (not in Edamam)
```

**Total:** 42 dietary tags

## Usage in Recipe Schema

```json
{
  "dietary_tags": ["vegan", "gluten-free", "nut-free"],
  ...
}
```

## Human-Readable Labels (for UI)

```javascript
const DIETARY_TAG_LABELS = {
  'vegetarian': 'Vegetarian',
  'vegan': 'Vegan',
  'pescatarian': 'Pescatarian',
  'pork-free': 'Pork-Free',
  'red-meat-free': 'Red Meat-Free',
  'kosher': 'Kosher',
  'halal': 'Halal',
  'gluten-free': 'Gluten-Free',
  'wheat-free': 'Wheat-Free',
  'dairy-free': 'Dairy-Free',
  'egg-free': 'Egg-Free',
  'soy-free': 'Soy-Free',
  'fish-free': 'Fish-Free',
  'shellfish-free': 'Shellfish-Free',
  'tree-nut-free': 'Tree Nut-Free',
  'peanut-free': 'Peanut-Free',
  'crustacean-free': 'Crustacean-Free',
  'mollusk-free': 'Mollusk-Free',
  'celery-free': 'Celery-Free',
  'mustard-free': 'Mustard-Free',
  'sesame-free': 'Sesame-Free',
  'lupine-free': 'Lupine-Free',
  'sulfite-free': 'Sulfite-Free',
  'keto-friendly': 'Keto-Friendly',
  'paleo': 'Paleo',
  'Mediterranean': 'Mediterranean',
  'DASH': 'DASH Diet',
  'low-fat-abs': 'Low-Fat',
  'low-sugar': 'Low-Sugar',
  'sugar-conscious': 'Sugar-Conscious',
  'low-carb': 'Low-Carb',
  'low-sodium': 'Low-Sodium',
  'kidney-friendly': 'Kidney-Friendly',
  'immuno-supportive': 'Immuno-Supportive',
  'alcohol-free': 'Alcohol-Free',
  'alcohol-cocktail': 'Contains Alcohol',
  'no-oil-added': 'No Oil Added',
  'fodmap-free': 'Low-FODMAP',
  'whole30': 'Whole30',
  'raw': 'Raw'
}
```

## AI Prompt Integration

When using AI to extract or validate dietary tags, provide this list:

```
Available dietary tags: vegetarian, vegan, pescatarian, pork-free, red-meat-free, kosher, halal, gluten-free, wheat-free, dairy-free, egg-free, soy-free, fish-free, shellfish-free, tree-nut-free, peanut-free, crustacean-free, mollusk-free, celery-free, mustard-free, sesame-free, lupine-free, sulfite-free, keto-friendly, paleo, Mediterranean, DASH, low-fat-abs, low-sugar, sugar-conscious, low-carb, low-sodium, kidney-friendly, immuno-supportive, alcohol-free, alcohol-cocktail, no-oil-added, fodmap-free, whole30, raw

Analyze the recipe and return only the tags that apply from this list. Use hyphens, not underscores.
```

## Validation Rules

1. Tags must be lowercase with hyphens (not spaces or underscores)
2. Multiple tags are allowed per recipe
3. Tags must come from the allowed list above
4. Conflicting tags should be validated:
   - ❌ `["vegan", "pescatarian"]` - invalid (vegan excludes fish)
   - ❌ `["vegetarian", "pescatarian"]` - redundant (use pescatarian only)
   - ❌ `["alcohol-free", "alcohol-cocktail"]` - contradictory
   - ✅ `["vegan", "gluten-free", "tree-nut-free"]` - valid

## Database Seeding

```ruby
# db/seeds/dietary_tags.rb
DIETARY_TAGS = {
  'vegetarian' => 'Vegetarian',
  'vegan' => 'Vegan',
  'pescatarian' => 'Pescatarian',
  'pork-free' => 'Pork-Free',
  'red-meat-free' => 'Red Meat-Free',
  'kosher' => 'Kosher',
  'halal' => 'Halal',
  'gluten-free' => 'Gluten-Free',
  'wheat-free' => 'Wheat-Free',
  'dairy-free' => 'Dairy-Free',
  'egg-free' => 'Egg-Free',
  'soy-free' => 'Soy-Free',
  'fish-free' => 'Fish-Free',
  'shellfish-free' => 'Shellfish-Free',
  'tree-nut-free' => 'Tree Nut-Free',
  'peanut-free' => 'Peanut-Free',
  'crustacean-free' => 'Crustacean-Free',
  'mollusk-free' => 'Mollusk-Free',
  'celery-free' => 'Celery-Free',
  'mustard-free' => 'Mustard-Free',
  'sesame-free' => 'Sesame-Free',
  'lupine-free' => 'Lupine-Free',
  'sulfite-free' => 'Sulfite-Free',
  'keto-friendly' => 'Keto-Friendly',
  'paleo' => 'Paleo',
  'Mediterranean' => 'Mediterranean',
  'DASH' => 'DASH Diet',
  'low-fat-abs' => 'Low-Fat',
  'low-sugar' => 'Low-Sugar',
  'sugar-conscious' => 'Sugar-Conscious',
  'low-carb' => 'Low-Carb',
  'low-sodium' => 'Low-Sodium',
  'kidney-friendly' => 'Kidney-Friendly',
  'immuno-supportive' => 'Immuno-Supportive',
  'alcohol-free' => 'Alcohol-Free',
  'alcohol-cocktail' => 'Contains Alcohol',
  'no-oil-added' => 'No Oil Added',
  'fodmap-free' => 'Low-FODMAP',
  'whole30' => 'Whole30',
  'raw' => 'Raw'
}

DIETARY_TAGS.each_with_index do |(key, display_name), index|
  DataReference.find_or_create_by!(
    reference_type: 'dietary_tag',
    key: key
  ) do |ref|
    ref.display_name = display_name
    ref.sort_order = index
    ref.active = true
  end
end
```

## Future Additions

When adding new dietary tags:
1. Update this document
2. Update database seed file
3. Update frontend filter UI
4. Update AI prompts
5. Re-tag existing recipes if applicable
