# Recipe App System Specification

⚠️ **CRITICAL WARNING** ⚠️
> 
> **ALL PSEUDO CODE AND EXAMPLES IN THIS DOCUMENT ARE FOR REFERENCE ONLY**
> 
> This document presents simplified conceptual models to illustrate architectural patterns. The code and structures shown are NOT production-ready and should be:
> - **HEAVILY CUSTOMIZED** for your specific use case
> - **EXTENDED** to be feature complete
> - **TESTED** thoroughly for edge cases
> - **OPTIMIZED** for your performance requirements
> - **SECURED** against injection attacks and data leaks
> 
> Consider this a conceptual starting point for understanding spreadsheet architecture, not a copy-paste solution!

## Project Overview

Build a recipe management system where:
1. **Recipes are structured data** (JSON) with dynamic scaling, ingredient substitutions, and adaptive instructions
2. **Each step has 3 pre-generated variants**: Original, Easier, No Equipment (AI-generated at save time)
3. **AI chat is available** for edge cases where users need custom adaptations
4. **Users can personalize** their own copy without modifying the base recipe

## Core Design Philosophy

- **Pre-compute alternatives** (instant UX, no waiting for AI during cooking)
- **AI as safety net** for edge cases (~10% of users need this)
- **Separation of concerns**: Base recipe vs. user customizations
- **90%+ coverage** with 2 pre-generated alternatives per step

---

## System Architecture

### Data Flow

```
RECIPE CREATION:
Author writes recipe → AI generates 2 alternatives per step → Human reviews → Save to DB

RECIPE VIEWING:
User opens recipe → Toggle between variants → (If needed) Chat with AI → Save personal copy
```

### Key Features

1. **Dynamic Scaling**: Adjust servings, all quantities recalculate with smart ratios
2. **Ingredient Swaps**: Predefined substitutions with ratio adjustments
3. **Adaptive Instructions**: 3 variants per step (Original/Easier/No Equipment)
4. **AI Chat**: Context-aware assistance for edge cases
5. **User Personalization**: Notes, swaps, and modifications saved separately

---

## Database Schema

### Recipe Structure (JSON)

```json
{
  "recipe": {
    "id": "string",
    "name": "string",
    "cuisine": "string",
    "servings": {
      "base_serving_size": "number",
      "current_servings": "number",
      "scalable": "boolean"
    },
    "timing": {
      "prep_minutes": "number",
      "cook_minutes": "number",
      "total_minutes": "number"
    },
    "equipment": [...],
    "ingredient_groups": [...],
    "steps": [...],
    "user_customizations": {...}
  }
}
```

---

## Complete Example: Oyakodon Recipe

```json
{
  "recipe": {
    "id": "oyakodon-001",
    "name": "Oyakodon (Chicken and Egg Rice Bowl)",
    "cuisine": "Japanese",
    "source": {
      "name": "Just One Cookbook",
      "author": "Nami",
      "url": "https://www.justonecookbook.com/oyakodon/"
    },
    
    "servings": {
      "base_serving_size": 1,
      "current_servings": 1,
      "scalable": true
    },
    
    "timing": {
      "prep_minutes": 10,
      "cook_minutes": 10,
      "total_minutes": 20
    },
    
    "equipment": [
      {
        "id": "eq-001",
        "name": "oyakodon_pan",
        "display_name": "Oyakodon pan or 8-inch frying pan",
        "required": true
      },
      {
        "id": "eq-002",
        "name": "lid",
        "display_name": "Pan lid",
        "required": false,
        "usage_note": "Optional - use only if eggs aren't setting"
      }
    ],
    
    "ingredient_groups": [
      {
        "group_id": "main",
        "group_name": "Main Ingredients",
        "ingredients": [
          {
            "id": "ing-001",
            "name": "chicken_thigh",
            "display_name": "boneless, skinless chicken thigh",
            "quantity": 140,
            "unit": "g",
            "unit_alternatives": [
              {"unit": "oz", "quantity": 5}
            ],
            "scaling_type": "linear",
            "preparation": "trimmed and cut using sogigiri technique into 2cm pieces",
            "substitutions": [
              {
                "ingredient": "chicken_breast",
                "ratio": 1.0,
                "notes": "Will be drier; chicken thigh preferred"
              }
            ]
          },
          {
            "id": "ing-002",
            "name": "sake",
            "display_name": "sake",
            "quantity": 0.5,
            "unit": "tbsp",
            "unit_alternatives": [
              {"unit": "ml", "quantity": 7.5}
            ],
            "scaling_type": "linear",
            "optional": true
          },
          {
            "id": "ing-003",
            "name": "onion",
            "display_name": "yellow or white onion",
            "quantity": 0.25,
            "unit": "whole",
            "preparation": "sliced lengthwise, about 6mm wide"
          },
          {
            "id": "ing-004",
            "name": "eggs",
            "display_name": "large eggs (at room temperature)",
            "quantity": 2,
            "unit": "whole",
            "preparation": "cracked into bowl, whites 'cut' 5-6 times with chopsticks"
          },
          {
            "id": "ing-005",
            "name": "negi",
            "display_name": "Japanese negi (green parts)",
            "quantity": 2,
            "unit": "tbsp",
            "preparation": "sliced diagonally into 1.3cm pieces",
            "substitutions": [
              {
                "ingredient": "green_onion",
                "ratio": 1.0,
                "notes": "Use green parts only"
              }
            ],
            "optional": true
          }
        ]
      },
      {
        "group_id": "seasoning",
        "group_name": "Seasoning Mixture",
        "ingredients": [
          {
            "id": "ing-006",
            "name": "dashi",
            "display_name": "dashi (Japanese soup stock)",
            "quantity": 60,
            "unit": "ml",
            "unit_alternatives": [
              {"unit": "cup", "quantity": 0.25}
            ],
            "scaling_type": "linear"
          },
          {
            "id": "ing-007",
            "name": "soy_sauce",
            "display_name": "soy sauce",
            "quantity": 1,
            "unit": "tbsp",
            "unit_alternatives": [
              {"unit": "ml", "quantity": 15}
            ],
            "scaling_type": "sublinear",
            "ratio_to": "ing-006",
            "ratio": 0.25
          },
          {
            "id": "ing-008",
            "name": "mirin",
            "display_name": "mirin",
            "quantity": 1,
            "unit": "tbsp",
            "unit_alternatives": [
              {"unit": "ml", "quantity": 15}
            ],
            "scaling_type": "linear",
            "ratio_to": "ing-006",
            "ratio": 0.25
          },
          {
            "id": "ing-009",
            "name": "sugar",
            "display_name": "sugar",
            "quantity": 1,
            "unit": "tsp",
            "unit_alternatives": [
              {"unit": "ml", "quantity": 5}
            ],
            "scaling_type": "sublinear"
          }
        ]
      },
      {
        "group_id": "serving",
        "group_name": "For Serving",
        "ingredients": [
          {
            "id": "ing-010",
            "name": "cooked_rice",
            "display_name": "cooked Japanese short-grain rice",
            "quantity": 250,
            "unit": "g",
            "preparation": "freshly steamed and hot"
          },
          {
            "id": "ing-011",
            "name": "shichimi_togarashi",
            "display_name": "shichimi togarashi (Japanese seven spice)",
            "quantity": null,
            "unit": "to_taste",
            "optional": true
          }
        ]
      }
    ],
    
    "steps": [
      {
        "step_id": "step-001",
        "order": 1,
        "title": "Prepare seasoning mixture",
        "ingredients_referenced": ["ing-006", "ing-007", "ing-008", "ing-009"],
        
        "instructions": {
          "original": {
            "text": "Combine 60ml dashi, 1 tbsp soy sauce, 1 tbsp mirin, and 1 tsp sugar in a bowl until sugar dissolves.",
            "equipment_required": ["bowl"],
            "difficulty": "easy"
          },
          "easier": {
            "text": "Mix all the liquids (dashi, soy sauce, mirin) and sugar in a bowl. Stir until you can't see sugar crystals anymore - about 30 seconds.",
            "equipment_required": ["bowl"],
            "difficulty": "easy",
            "what_changed": "Added time estimate and visual cue for completion"
          },
          "no_equipment": {
            "text": "If you don't have a separate bowl, you can mix these directly in your cooking pan before heating. Just add dashi, soy sauce, mirin, and sugar to the cold pan and stir to dissolve sugar.",
            "equipment_required": ["pan"],
            "difficulty": "easy",
            "what_changed": "Eliminated need for extra bowl"
          }
        },
        
        "timing": {
          "duration_minutes": 1
        },
        "critical": false
      },
      
      {
        "step_id": "step-002",
        "order": 2,
        "title": "Prepare chicken",
        "ingredients_referenced": ["ing-001", "ing-002"],
        
        "instructions": {
          "original": {
            "text": "Trim excess fat from chicken thigh. Cut using sogigiri technique into 2cm pieces. Sprinkle with ½ tbsp sake and set aside for 5 minutes.",
            "equipment_required": ["cutting_board", "knife"],
            "difficulty": "medium"
          },
          "easier": {
            "text": "Remove any big pieces of fat from the chicken. Cut into bite-sized pieces (about the size of large grapes). Don't worry about perfect technique - just try to make them similar thickness so they cook evenly. Sprinkle with sake if using, or just set aside.",
            "equipment_required": ["cutting_board", "knife"],
            "difficulty": "easy",
            "what_changed": "Simplified cutting technique, removed technical term, added size reference"
          },
          "no_equipment": {
            "text": "If you don't have a knife or cutting board, buy pre-cut chicken pieces or ask the butcher to cut it for you. You can also use kitchen scissors to cut the chicken into pieces while holding it over a plate.",
            "equipment_required": ["scissors_optional"],
            "difficulty": "easy",
            "what_changed": "Provided zero-equipment alternatives"
          }
        },
        
        "timing": {
          "duration_minutes": 5,
          "wait_time_minutes": 5
        },
        "technique_reference": {
          "name": "sogigiri",
          "description": "Angle knife nearly parallel to cutting board and slice diagonally"
        },
        "critical": false
      },
      
      {
        "step_id": "step-003",
        "order": 3,
        "title": "Prepare negi",
        "ingredients_referenced": ["ing-005"],
        
        "instructions": {
          "original": {
            "text": "Slice the green parts of negi diagonally into 1.3cm (½ inch) pieces. Set aside.",
            "equipment_required": ["cutting_board", "knife"],
            "difficulty": "easy"
          },
          "easier": {
            "text": "Cut the green onion into small pieces - about the width of your pinky finger. The diagonal angle makes them prettier but cutting straight across works fine too.",
            "equipment_required": ["cutting_board", "knife"],
            "difficulty": "easy",
            "what_changed": "Added size reference, made diagonal angle optional"
          },
          "no_equipment": {
            "text": "You can tear green onions into small pieces by hand, or use kitchen scissors to snip them into a bowl. Or skip this garnish entirely - it's mainly decorative.",
            "equipment_required": ["scissors_optional", "none"],
            "difficulty": "easy",
            "what_changed": "Hand-tearing option, noted it's optional"
          }
        },
        
        "timing": {
          "duration_minutes": 2
        },
        "critical": false
      },
      
      {
        "step_id": "step-004",
        "order": 4,
        "title": "Prepare eggs",
        "ingredients_referenced": ["ing-004"],
        
        "instructions": {
          "original": {
            "text": "Crack 2 eggs into a bowl. Using chopsticks, 'cut' the egg whites 5-6 times into smaller clumps. Do NOT whisk or beat. Eggs should have a marble pattern with whites and yolks still distinct.",
            "equipment_required": ["bowl", "chopsticks"],
            "difficulty": "medium"
          },
          "easier": {
            "text": "Crack eggs into a bowl. Using a fork, gently pierce and lift the egg whites 5-6 times. You don't need perfect technique - just break them up a bit. They should look streaky, not fully mixed.",
            "equipment_required": ["bowl", "fork"],
            "difficulty": "easy",
            "what_changed": "Swapped chopsticks for fork, added reassuring language"
          },
          "no_equipment": {
            "text": "If you don't have chopsticks or a fork, use a butter knife to cut through the eggs in a few places. Or skip this step entirely - your eggs will be more yellow and less marbled, but will taste exactly the same.",
            "equipment_required": ["knife_optional", "none"],
            "difficulty": "easy",
            "what_changed": "Provided zero-equipment option, noted minimal impact"
          }
        },
        
        "timing": {
          "duration_minutes": 1
        },
        "visual_cue": "Marble pattern visible with distinct white and yellow areas",
        "critical": false,
        "impact_if_skipped": "Visual appearance only - taste unaffected"
      },
      
      {
        "step_id": "step-005",
        "order": 5,
        "title": "Start cooking base",
        "ingredients_referenced": ["ing-003", "seasoning"],
        
        "instructions": {
          "original": {
            "text": "In your oyakodon pan, add sliced onions in a single layer. Pour seasoning mixture over onions (should just cover them). Turn heat to medium and bring to simmer.",
            "equipment_required": ["eq-001"],
            "difficulty": "easy"
          },
          "easier": {
            "text": "Put onions in your pan spread out evenly. Pour the sauce over them - they should be mostly covered. Turn heat to medium. You'll know it's ready when you see small bubbles forming around the edges (this takes about 2 minutes).",
            "equipment_required": ["eq-001"],
            "difficulty": "easy",
            "what_changed": "Added time estimate and visual cue for simmering"
          },
          "no_equipment": {
            "text": "If you don't have the traditional pan, use any small pot or frying pan you have. An 8-10 inch pan works great. The key is not to use a huge pan or the sauce will be too thin.",
            "equipment_required": ["any_pan"],
            "difficulty": "easy",
            "what_changed": "Flexible equipment options"
          }
        },
        
        "heat_level": "medium",
        "timing": {
          "duration_minutes": 2
        },
        "visual_cue": "Small bubbles forming around edges",
        "critical": true
      },
      
      {
        "step_id": "step-006",
        "order": 6,
        "title": "Cook chicken",
        "ingredients_referenced": ["ing-001"],
        
        "instructions": {
          "original": {
            "text": "Add prepared chicken on top of onions. Distribute evenly. Once simmering, lower heat to medium-low. Cook UNCOVERED for 4 minutes until chicken is no longer pink, flipping chicken halfway through.",
            "equipment_required": ["eq-001"],
            "difficulty": "medium"
          },
          "easier": {
            "text": "Add chicken pieces on top of the onions. Spread them out so they're not piled up. When you see bubbles, turn the heat down a bit (to medium-low). After 2 minutes, flip the chicken pieces over. Cook for 2 more minutes. Chicken should be white all the way through, no pink.",
            "equipment_required": ["eq-001"],
            "difficulty": "easy",
            "what_changed": "Broke into smaller time chunks, added color check"
          },
          "no_equipment": {
            "text": "If you don't have a lid (the recipe says cook uncovered), that's actually perfect - you don't need one for this step. Cooking without a lid helps the sauce get more flavorful.",
            "equipment_required": ["pan"],
            "difficulty": "easy",
            "what_changed": "Clarified lid isn't needed"
          }
        },
        
        "heat_level": "medium_low",
        "timing": {
          "duration_minutes": 4,
          "flip_at_minutes": 2
        },
        "visual_cue": "Chicken should be white throughout, no pink visible",
        "safety_note": "Chicken must reach 165°F internal temperature",
        "critical": true
      },
      
      {
        "step_id": "step-007",
        "order": 7,
        "title": "First egg addition",
        "ingredients_referenced": ["ing-004"],
        
        "instructions": {
          "original": {
            "text": "Increase heat to medium until simmering. Drizzle two-thirds of the egg mixture (aim for more egg whites) in a circular pattern over the chicken and onions. Avoid the edges where eggs overcook easily.",
            "equipment_required": ["eq-001"],
            "difficulty": "medium"
          },
          "easier": {
            "text": "Turn heat back up to medium. Once you see bubbles again, pour about two-thirds of your eggs over the chicken in a spiral pattern starting from the center. Don't pour near the very edge of the pan. It's okay if it's not perfect.",
            "equipment_required": ["eq-001"],
            "difficulty": "easy",
            "what_changed": "Simplified pouring technique, added reassurance"
          },
          "no_equipment": {
            "text": "If you find it hard to drizzle the eggs in a pattern, just pour them over the center area and let them spread naturally. The end result is almost the same.",
            "equipment_required": ["pan"],
            "difficulty": "easy",
            "what_changed": "Simplified technique for less precision"
          }
        },
        
        "heat_level": "medium",
        "timing": {
          "duration_minutes": 1
        },
        "visual_cue": "Small bubbles at edges before adding eggs",
        "critical": false
      },
      
      {
        "step_id": "step-008",
        "order": 8,
        "title": "Second egg addition and garnish",
        "ingredients_referenced": ["ing-004", "ing-005"],
        
        "instructions": {
          "original": {
            "text": "When eggs are just set but still runny, add remaining one-third of eggs (aim for more yolks) to the center and edges of pan. Immediately add sliced negi on top.",
            "equipment_required": ["eq-001"],
            "difficulty": "medium"
          },
          "easier": {
            "text": "When the first layer of egg looks mostly cooked but still a bit jiggly (like Jello), pour the rest of the eggs over everything. Sprinkle the green onions on top right away. Lower heat to medium-low.",
            "equipment_required": ["eq-001"],
            "difficulty": "easy",
            "what_changed": "Added texture comparison (Jello), simplified"
          },
          "no_equipment": {
            "text": "If you skipped the green onions, that's fine - just add the remaining eggs. If you're nervous about runny eggs, you can wait until the first layer is fully set before adding more.",
            "equipment_required": ["pan"],
            "difficulty": "easy",
            "what_changed": "Made garnish optional, added safety option"
          }
        },
        
        "heat_level": "medium_low",
        "timing": {
          "duration_minutes": 2
        },
        "visual_cue": "First layer should be set but jiggly",
        "critical": false
      },
      
      {
        "step_id": "step-009",
        "order": 9,
        "title": "Finish cooking",
        "ingredients_referenced": [],
        
        "instructions": {
          "original": {
            "text": "Cook until eggs reach your preferred doneness. Use lid ONLY if eggs aren't setting or you want them fully cooked.",
            "equipment_required": ["eq-001", "eq-002"],
            "difficulty": "easy"
          },
          "easier": {
            "text": "Keep cooking until the eggs look done to you. In Japan they like them still a bit runny, but you can cook them fully if you prefer. If the eggs seem to be taking forever, put a lid on for 30 seconds.",
            "equipment_required": ["eq-001", "eq-002"],
            "difficulty": "easy",
            "what_changed": "Explained cultural difference, gave permission for preference"
          },
          "no_equipment": {
            "text": "If you don't have a lid and the eggs aren't cooking fast enough, just turn the heat up slightly for 30 seconds, then turn it off.",
            "equipment_required": ["pan"],
            "difficulty": "easy",
            "what_changed": "Alternative to using lid"
          }
        },
        
        "timing": {
          "duration_minutes": 1,
          "variable": true
        },
        "safety_note": "Eggs should reach 160°F if using regular eggs",
        "critical": true
      },
      
      {
        "step_id": "step-010",
        "order": 10,
        "title": "Serve",
        "ingredients_referenced": ["ing-010", "ing-011"],
        
        "instructions": {
          "original": {
            "text": "Place 250g cooked rice in a donburi bowl. Slide everything from the oyakodon pan onto the rice in one smooth motion. Drizzle with remaining pan sauce. Optionally sprinkle with shichimi togarashi.",
            "equipment_required": ["bowl"],
            "difficulty": "medium"
          },
          "easier": {
            "text": "Put your rice in a bowl. Tilt the pan over the bowl and use a spatula to help slide everything on top of the rice. Pour any extra sauce from the pan over it. Add spice if you want it spicy.",
            "equipment_required": ["bowl", "spatula"],
            "difficulty": "easy",
            "what_changed": "Added spatula helper, simplified language"
          },
          "no_equipment": {
            "text": "If you don't have a proper bowl, any plate or container works. If sliding from the pan is hard, just scoop the chicken and eggs onto the rice with a large spoon. It won't look as pretty but tastes the same.",
            "equipment_required": ["any_container", "spoon"],
            "difficulty": "easy",
            "what_changed": "Flexible plating options"
          }
        },
        
        "timing": {
          "duration_minutes": 1
        },
        "visual_cue": "Chicken and eggs should slide as one intact layer",
        "critical": false
      }
    ],
    
    "user_customizations": {
      "user_id": null,
      "serving_multiplier": 1.0,
      "ingredient_swaps": [],
      "step_notes": [],
      "active_variant": "original"
    }
  }
}
```

---

## AI Generation Prompts

### When Recipe Author Saves (Phase 1)

**Prompt for "Easier" Variant:**
```
You are helping make cooking instructions more accessible. 

Original instruction: "{original_text}"
Equipment mentioned: {equipment_list}
Critical step: {is_critical}

Rewrite this instruction to be easier for:
- Someone with limited cooking experience
- Someone with physical limitations (arthritis, tremors, limited grip strength)
- Someone who gets anxious following complex instructions

Guidelines:
- Use simpler, more common tools if possible
- Break complex actions into smaller parts
- Add reassuring language ("it's okay if...", "don't worry about...")
- Include time estimates and visual cues
- Keep the same end goal
- Be encouraging

Output:
{
  "text": "the rewritten instruction",
  "equipment_required": ["list", "of", "equipment"],
  "difficulty": "easy",
  "what_changed": "brief explanation of changes"
}
```

**Prompt for "No Equipment" Variant:**
```
You are helping make cooking accessible when equipment is missing.

Original instruction: "{original_text}"
Equipment mentioned: {equipment_list}
Critical step: {is_critical}

Rewrite this instruction for someone who:
- Doesn't have the equipment mentioned
- Is in a dorm, hotel, or limited kitchen
- Needs creative alternatives with common household items

Guidelines:
- Suggest alternatives using common items (cups, spoons, scissors, hands)
- If the step can be skipped, explain how and what the impact is
- Be honest about tradeoffs
- If it truly cannot be done without equipment, say so clearly
- Maintain food safety

Output:
{
  "text": "the rewritten instruction",
  "equipment_required": ["alternative", "equipment", "or", "none"],
  "difficulty": "easy",
  "what_changed": "brief explanation",
  "tradeoff": "what changes (if anything)"
}
```

### AI Chat Context (Phase 2)

**System Prompt for AI Chat:**
```
You are a helpful cooking assistant for {recipe.name}.

Context:
- User is on Step {step.order}: {step.title}
- Instruction variants available:
  * Original: {original.text}
  * Easier: {easier.text}
  * No Equipment: {no_equipment.text}

User highlighted: "{highlighted_text}"
User question: "{user_question}"

Your role:
1. Provide practical, actionable advice
2. Explain WHY your suggestions work
3. Be honest about tradeoffs
4. Be encouraging and reassuring
5. Offer to modify their recipe if helpful

Keep responses:
- Concise (2-3 paragraphs max)
- Specific to their question
- Actionable (clear next steps)

If you suggest modifications:
1. Explain the reasoning
2. Note any taste/texture/appearance changes
3. Confirm it's safe
4. Ask if they want to update their recipe
```

---

## UI/UX Requirements

### Recipe Viewing Interface

```
┌─────────────────────────────────────────────────────┐
│ Oyakodon (Chicken and Egg Rice Bowl)     [Save Recipe] │
├─────────────────────────────────────────────────────┤
│                                                     │
│ ⚙ Servings: [1] ▼    🕐 20 min    📊 Easy         │
│                                                     │
├─────────────────────────────────────────────────────┤
│ INGREDIENTS                        [Shopping List]  │
├─────────────────────────────────────────────────────┤
│ Main Ingredients                                    │
│ □ 140g chicken thigh                [swap]         │
│ □ ½ tbsp sake                       [swap]         │
│ □ ¼ onion                                          │
│ ...                                                 │
├─────────────────────────────────────────────────────┤
│ INSTRUCTIONS                                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Step 1: Prepare seasoning mixture                  │
│ ● Original  ○ Easier  ○ No Equipment              │
│                                                     │
│ Combine 60ml dashi, 1 tbsp soy sauce, 1 tbsp      │
│ mirin, and 1 tsp sugar in a bowl until sugar      │
│ dissolves.                                         │
│                                                     │
│ ⏱ 1 min                                            │
│ [?] Why this step  [💬] Ask AI  [📝] Add note     │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Step 2: Prepare chicken                            │
│ ○ Original  ● Easier  ○ No Equipment              │
│                                                     │
│ Remove any big pieces of fat from the chicken.    │
│ Cut into bite-sized pieces (about the size of     │
│ large grapes). Don't worry about perfect           │
│ technique...                                       │
│                                                     │
│ ⏱ 5 min + 5 min wait                              │
│ [?] What's sogigiri?  [💬] Ask AI  [📝] Add note  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### AI Chat Interface

```
┌─────────────────────────────────────────┐
│ 💬 Ask about Step 4: Prepare eggs      │
├─────────────────────────────────────────┤
│                                         │
│ User: I have Parkinson's and my        │
│ hands shake - can I do this?           │
│                                         │
│ ─────────────────────────────────────  │
│                                         │
│ Claude: For someone with hand tremors, │
│ I'd suggest an even easier approach:   │
│ crack your eggs into the bowl, then    │
│ use a whisk to stir just 3-4 times in │
│ a circular motion. Stop while you can  │
│ still see streaks.                     │
│                                         │
│ This requires less precision than the  │
│ chopstick method but achieves the same │
│ goal. The appearance might be slightly │
│ less marbled, but the taste will be    │
│ identical.                             │
│                                         │
│ [✓ Update step 4 with this]            │
│ [📝 Just save as note]                 │
│                                         │
├─────────────────────────────────────────┤
│ Type your question...            [Send]│
└─────────────────────────────────────────┘
```

### Serving Adjustment

```
┌────────────────────────────────┐
│ Adjust Servings                │
├────────────────────────────────┤
│                                │
│ [1] ←──●────────────→ [4]     │
│     Current: 2 servings        │
│                                │
│ Ingredients will auto-update:  │
│ • 280g chicken (was 140g)     │
│ • 4 eggs (was 2)              │
│ • 120ml dashi (was 60ml)      │
│                                │
│ [Apply Changes]  [Cancel]      │
└────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Core Recipe System (Week 1-2)
- [ ] Database schema implementation
- [ ] Recipe CRUD operations
- [ ] Ingredient scaling logic
- [ ] Basic UI for viewing recipes
- [ ] Toggle between 3 instruction variants

### Phase 2: AI Generation (Week 3)
- [ ] Integrate AI API (Claude/GPT)
- [ ] Implement "Easier" variant generation
- [ ] Implement "No Equipment" variant generation
- [ ] Human review interface for generated variants
- [ ] Save all 3 variants to database

### Phase 3: User Customization (Week 4)
- [ ] User accounts and authentication
- [ ] Save personal recipe copies
- [ ] Custom ingredient swaps
- [ ] Step notes
- [ ] Shopping list generation

### Phase 4: AI Chat (Week 5)
- [ ] Chat interface for recipe pages
- [ ] Context-aware prompting
- [ ] Text highlighting → Ask AI
- [ ] Save chat-modified steps to personal copy
- [ ] Chat history per recipe

### Phase 5: Polish (Week 6)
- [ ] Mobile responsive design
- [ ] Print-friendly recipe view
- [ ] Share recipe links
- [ ] Recipe rating and reviews
- [ ] Search and filtering

---

## Technical Stack Recommendations

### Backend
- **Database**: PostgreSQL (JSON support for flexible recipe structure)
- **API**: Node.js + Express or Python + FastAPI
- **AI Integration**: Anthropic Claude API or OpenAI API

### Frontend
- **Framework**: React or Next.js
- **State Management**: Redux or Zustand
- **Styling**: Tailwind CSS

### Infrastructure
- **Hosting**: Vercel/Netlify (frontend) + Railway/Render (backend)
- **Storage**: PostgreSQL for recipes, Redis for caching AI responses

---

## Key Metrics to Track

1. **Variant Usage**: % of users choosing Original vs Easier vs No Equipment
2. **AI Chat Engagement**: % of users who open chat, average questions asked
3. **Recipe Completion**: Do users with adapted instructions complete more recipes?
4. **Customization Rate**: How many users save personal modifications?
5. **AI Generation Quality**: Human review ratings of AI-generated variants

---

## Example API Endpoints

```
GET    /api/recipes/:id                    - Get recipe with all variants
POST   /api/recipes                        - Create recipe (triggers AI generation)
PATCH  /api/recipes/:id/servings           - Update serving size
POST   /api/recipes/:id/customize          - Save user customization
POST   /api/recipes/:id/chat               - AI chat endpoint
GET    /api/recipes/:id/shopping-list      - Generate shopping list
```

---

## Security & Privacy Considerations

1. **User Data**: Personal recipe modifications are private by default
2. **AI Prompts**: Don't include personal user info in AI prompts
3. **Rate Limiting**: Limit AI chat to prevent abuse
4. **Content Moderation**: Review AI-generated content for quality/safety

---

## Success Criteria

**Phase 1 Success**: Recipe system works with manual variants
**Phase 2 Success**: AI generates useful variants 90%+ of the time
**Phase 3 Success**: Users can personalize without breaking recipes
**Phase 4 Success**: AI chat resolves 80%+ of user questions
**Overall Success**: Users with accessibility needs can complete recipes they couldn't before

---

## Next Steps

1. Review this specification
2. Set up development environment
3. Implement Phase 1 (core recipe system)
4. Test with Oyakodon example
5. Add AI generation layer
6. User testing with real accessibility needs

---

*This specification uses Oyakodon as the complete example, but the system should work for any recipe following this JSON structure.*
