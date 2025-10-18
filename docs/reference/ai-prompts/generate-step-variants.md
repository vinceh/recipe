# AI Prompts: Generate Step Variants

This document contains the AI prompts used to generate "Easier" and "No Equipment" instruction variants for recipe steps.

## Overview

**When:** After a recipe is saved (background async job)
**Purpose:** Generate two alternative instruction variants for each step
**Job:** `GenerateStepVariantsJob`
**Updates:** Recipe JSON in database when complete

---

## Prompt 1: Generate "Easier" Variant

### Purpose
Create a simplified version of the instruction that requires less cooking technique and is more accessible to home cooks with varying skill levels or physical limitations.

### Target Audience
- Less experienced cooks who may not know specialized techniques
- People with physical limitations (arthritis, tremors, limited grip strength, vision impairment)
- Anyone who gets anxious with complex instructions
- Cooks who want more guidance and reassurance

### System Prompt

```
You are a professional cooking instructor specializing in making recipes accessible to all skill levels. Your goal is to rewrite cooking instructions to be easier while maintaining the same end result.
```

### User Prompt Template

```
Recipe Name: {recipe.name}
Cuisine: {recipe.cuisine}
Recipe Type: {recipe.recipe_types}

Step {step.order}: {step.title}

Original Instruction:
{step.instructions.original.text}

Equipment Required: {step.instructions.original.equipment_required}
Difficulty: {step.instructions.original.difficulty}
Critical Step: {step.critical}

Ingredients Used in This Step:
{list of ingredient names and quantities}

---

Rewrite this instruction to be EASIER for:
- Someone with limited cooking experience
- Someone with physical limitations (shaky hands, weak grip, poor vision)
- Someone who needs more guidance and reassurance

Guidelines:
1. **Break down complex actions** into smaller, sequential parts
2. **Replace technical terms** with everyday language (e.g., "sogigiri" → "angled slicing")
3. **Suggest easier tools** if possible (chopsticks → fork, whisk → spoon)
4. **Add time estimates** so they know what to expect ("about 2 minutes", "30 seconds")
5. **Include visual/sensory cues** ("when you see bubbles", "feels like soft butter", "sounds like sizzling")
6. **Add reassuring language** ("It's okay if...", "Don't worry about...", "Roughly X is fine")
7. **Be encouraging** and reduce anxiety
8. **Keep the same end goal** - the result should be identical or nearly identical
9. **Maintain food safety** - never compromise safety for ease

Important:
- If a technical term is used (like "sogigiri"), explain it simply without using the term
- If the step is already very simple, make it even clearer with more detail
- Add confidence-building language
- If timing is vague in original, provide specific estimates

Output Format (JSON):
{
  "text": "The rewritten easier instruction",
  "equipment_required": ["list", "of", "equipment"],
  "difficulty": "easy",
  "what_changed": "Brief explanation of what you simplified"
}
```

### Example Input/Output

**Input:**
```
Step 2: Prepare chicken
Original: "Trim excess fat from chicken thigh. Cut using sogigiri technique into 2cm pieces. Sprinkle with ½ tbsp sake and set aside for 5 minutes."
Equipment: cutting_board, knife
Difficulty: medium
```

**Output:**
```json
{
  "text": "Remove any big pieces of fat from the chicken. Cut into bite-sized pieces (about the size of large grapes). Don't worry about perfect technique - just try to make them similar thickness so they cook evenly. Sprinkle with sake if using, or just set aside for 5 minutes.",
  "equipment_required": ["cutting_board", "knife"],
  "difficulty": "easy",
  "what_changed": "Removed technical term 'sogigiri', added size reference (grape-sized), added reassurance about imperfect cuts, made sake optional"
}
```

---

## Prompt 2: Generate "No Equipment" Variant

### Purpose
Provide alternative methods when the required equipment is not available, using common household items or simpler approaches.

### Target Audience
- People in dorm rooms, hotel rooms, limited kitchens
- Those who don't own specialized equipment
- Minimalist cooks with basic tools only
- People who need workarounds in a pinch

### System Prompt

```
You are a resourceful cooking instructor who specializes in improvisation and alternative methods. Your goal is to help people cook without specialized equipment by suggesting creative alternatives using common household items.
```

### User Prompt Template

```
Recipe Name: {recipe.name}
Cuisine: {recipe.cuisine}
Recipe Type: {recipe.recipe_types}

Step {step.order}: {step.title}

Original Instruction:
{step.instructions.original.text}

Equipment Required: {step.instructions.original.equipment_required}
Difficulty: {step.instructions.original.difficulty}
Critical Step: {step.critical}

Ingredients Used in This Step:
{list of ingredient names and quantities}

---

Rewrite this instruction for someone who DOES NOT HAVE the required equipment.

Guidelines:
1. **Suggest alternative common household items** (scissors for knife, mug for measuring cup, hands for mixing)
2. **Be creative but practical** - alternatives should actually work
3. **Be honest about tradeoffs** - if something will be different, say so
4. **Explain impact clearly** - "It won't look as pretty but tastes the same"
5. **If step can be skipped**, say so with the impact: "This is mainly for presentation, you can skip it"
6. **Maintain food safety** - never suggest unsafe shortcuts
7. **Use what most people have**:
   - Plates, bowls, mugs, cups
   - Spoons, forks, butter knives
   - Scissors, hands
   - Plastic bags, paper towels
   - Cans, jars, bottles
8. **Consider multiple alternatives** if equipment is truly needed

Important:
- If the equipment is truly essential and has no alternative, say: "This equipment is essential - you'll need to get/borrow X"
- Focus on accessibility - assume minimal kitchen setup
- Don't compromise food safety for convenience
- Be clear about what changes (appearance, texture, time) if anything

Output Format (JSON):
{
  "text": "The rewritten instruction with alternative methods",
  "equipment_required": ["alternative", "equipment", "or", "none"],
  "difficulty": "easy",
  "what_changed": "Brief explanation of equipment alternatives",
  "tradeoff": "What changes, if anything (appearance/texture/time), or null if no change"
}
```

### Example Input/Output

**Input:**
```
Step 4: Prepare eggs
Original: "Crack 2 eggs into a bowl. Using chopsticks, 'cut' the egg whites 5-6 times into smaller clumps. Do NOT whisk or beat. Eggs should have a marble pattern with whites and yolks still distinct."
Equipment: bowl, chopsticks
Difficulty: medium
```

**Output:**
```json
{
  "text": "Crack 2 eggs into any container (bowl, mug, cup). If you don't have chopsticks or a fork, use a butter knife to cut through the eggs 5-6 times. Or skip this step entirely - your eggs will be more yellow and less marbled, but will taste exactly the same.",
  "equipment_required": ["any_container", "knife_optional", "or_none"],
  "difficulty": "easy",
  "what_changed": "Allowed any container instead of bowl, suggested knife instead of chopsticks, made step optional",
  "tradeoff": "Visual appearance only - eggs will be more uniform yellow instead of marbled. Taste is identical."
}
```

---

## Implementation Workflow

### Background Job: `GenerateStepVariantsJob`

**Trigger:** After admin saves recipe (either manual entry or AI import)

**Process:**
```ruby
# GenerateStepVariantsJob
def perform(recipe_id)
  recipe = Recipe.find(recipe_id)

  recipe.steps.each do |step|
    # Skip if variants already exist
    next if step.instructions.easier.present? && step.instructions.no_equipment.present?

    # Generate "Easier" variant
    easier_variant = generate_easier_variant(recipe, step)

    # Generate "No Equipment" variant
    no_equipment_variant = generate_no_equipment_variant(recipe, step)

    # Update step with variants
    step.instructions.easier = easier_variant
    step.instructions.no_equipment = no_equipment_variant
  end

  recipe.save!

  # Mark variants as complete
  recipe.update(variants_generated: true, variants_generated_at: Time.current)
end
```

**Database Flag:**
```ruby
# Add to recipes table
- variants_generated (boolean, default: false)
- variants_generated_at (timestamp)
```

**Frontend Behavior:**
```javascript
// Show loading state while variants generate
if (!recipe.variants_generated) {
  // Display: "Generating easier alternatives..."
  // Or just show original version with notice
}

// Once generated, enable variant toggle
if (recipe.variants_generated) {
  // Enable: [Original] [Easier] [No Equipment] buttons
}
```

---

## Error Handling

### If AI Generation Fails

```ruby
def handle_generation_failure(recipe, step, error)
  # Log error
  Rails.logger.error("Failed to generate variants for recipe #{recipe.id}, step #{step.id}: #{error}")

  # Fallback: Copy original to both variants
  step.instructions.easier = {
    text: step.instructions.original.text,
    equipment_required: step.instructions.original.equipment_required,
    difficulty: step.instructions.original.difficulty,
    what_changed: "Variant generation failed - showing original"
  }

  step.instructions.no_equipment = step.instructions.easier.dup

  # Mark as failed for retry
  recipe.update(variants_generation_failed: true)
end
```

### Retry Strategy

- Retry failed generations up to 3 times
- Exponential backoff (1min, 5min, 15min)
- After 3 failures, fall back to original instruction
- Admin can manually trigger regeneration

---

## Testing Prompts

### Test Case 1: Simple Step
```
Step 1: Combine ingredients
Original: "Mix flour, sugar, and salt in a bowl."
Expected Easier: More detail about mixing method
Expected No Equipment: Suggest using plate or any container
```

### Test Case 2: Technical Step
```
Step 5: Temper chocolate
Original: "Heat chocolate to 115°F, cool to 81°F, reheat to 89°F."
Expected Easier: Explain why tempering matters, add visual cues
Expected No Equipment: Suggest microwave method or explain it truly needs thermometer
```

### Test Case 3: Critical Safety Step
```
Step 8: Cook chicken
Original: "Cook chicken until internal temperature reaches 165°F."
Expected Easier: Add time estimate, visual cues (no pink)
Expected No Equipment: Never compromise - must reach safe temp
```

### Test Case 4: Optional Garnish
```
Step 10: Garnish
Original: "Slice herbs diagonally and arrange on top."
Expected Easier: "Roughly chop herbs and sprinkle on top"
Expected No Equipment: "Skip garnish or tear herbs by hand - purely decorative"
```

---

## Validation Rules

After AI generates variants, validate:

1. ✅ **Structure matches** - Has all required fields
2. ✅ **Text is different** - Not just copy of original
3. ✅ **Same goal** - Result should be equivalent
4. ✅ **Safety maintained** - No unsafe shortcuts
5. ✅ **Difficulty appropriate** - "easier" and "no_equipment" should be marked "easy"
6. ✅ **Equipment listed** - Array is present (can be empty for no_equipment)

If validation fails → Log error → Retry generation → Fallback to original

---

## Cost Optimization

**Per Recipe:**
- 2 API calls per step (easier + no_equipment)
- Average recipe: 8-10 steps = 16-20 API calls
- Use Claude Haiku (fastest, cheapest) for these generations
- Batch multiple steps in one API call if possible

**Estimated Cost:**
- ~$0.05-0.10 per recipe (with Haiku)
- Acceptable for background processing
- Only runs once per recipe

---

## Future Enhancements

1. **User Feedback Loop**
   - Let users rate variant quality
   - Regenerate variants with poor ratings
   - Use feedback to improve prompts

2. **Language-Specific Variants**
   - Generate variants for each translated language
   - Maintain cultural context in alternatives

3. **Difficulty Levels**
   - Add "Expert" variant for advanced techniques
   - Add "Kids" variant for cooking with children

4. **Equipment Detection**
   - Ask users what equipment they have
   - Only show relevant variants
   - "You don't have a stand mixer - here's the no-equipment version"

---

_This document defines the AI generation system for recipe step variants._
