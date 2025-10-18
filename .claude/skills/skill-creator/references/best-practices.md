# Skill Creation Best Practices

Detailed examples and strategies for creating effective, shareable skills based on real-world implementations.

## File Size Optimization

### Target Word Counts

- **SKILL.md**: <5,000 words (essential workflows and procedural knowledge)
- **Reference files**: 1,500-3,500 words each (detailed documentation)
- **Total skill**: Aim for progressive disclosure efficiency

### Real-World Example: vue-engineering Optimization

**Before optimization:**
- 8 reference files totaling ~40,000 words
- Individual files ranged from 4,000-7,800 words
- Excessive redundancy and verbose examples

**After optimization:**
- Same 8 reference files totaling ~17,500 words (56% reduction)
- All files within 1,500-3,500 word range
- Maintained all core concepts and patterns

**Condensing strategies applied:**
- Kept 1-2 best examples per concept instead of 5-6 variations
- Removed redundant explanations of the same pattern
- Consolidated similar anti-patterns into single entries
- Preserved code correctness and educational value
- Maintained comprehensive coverage with less verbosity

### Individual File Examples

**component-patterns.md:** 6,886 → 2,477 words (64% reduction)
- Kept all 7 sections (props, emits, slots, provide/inject, composition, SFC best practices, decision guide)
- Reduced each section from 3-4 examples to 1-2 essential examples
- Removed verbose explanations, kept code-first approach

**anti-patterns.md:** 7,751 → 2,394 words (69% reduction)
- Maintained all 14 anti-patterns
- Condensed each from 2-3 examples to 1 focused bad/good comparison
- Removed redundant "why this is bad" explanations

**reactivity-guide.md:** 4,926 → 2,510 words (49% reduction)
- Preserved complete ref vs reactive comparison
- Kept critical decision tables
- Removed redundant reactive() conversion examples

## Progressive Disclosure in Practice

### What Goes Where

**SKILL.md should contain:**
- Skill overview and purpose (1-2 paragraphs)
- When to use the skill (specific triggering conditions)
- Decision trees and workflow diagrams
- Quick reference patterns (most common use cases)
- Pointers to reference files and when to consult them

**Reference files should contain:**
- Detailed syntax references
- Comprehensive examples and patterns
- Anti-patterns and gotchas
- Domain-specific schemas or specifications
- Extended explanations and edge cases

**Assets should contain:**
- Templates ready for copy/modify (not for reading)
- Boilerplate code structures
- Configuration file templates
- Sample documents or images

### Example: acceptance-test-writing Structure

**SKILL.md (1,926 words):**
- Overview of BDD/ATDD and Gherkin
- 5-step decision tree for choosing format
- Quick reference for common patterns
- Quality checklists
- References to detailed files

**references/gherkin-guide.md (1,056 words):**
- Complete Gherkin syntax reference
- Given-When-Then structure
- Extended keywords (Background, Scenario Outline)
- Best practices for each keyword

**references/anti-patterns.md (1,635 words):**
- 14 common anti-patterns
- Bad vs good examples for each
- Why each pattern should be avoided

**references/examples.md (2,455 words):**
- Real-world examples across domains
- E-commerce, authentication, forms, APIs
- Complete scenarios with context

**assets/acceptance-criteria-template.md:**
- Ready-to-use template for teams
- Both Given-When-Then and rule-oriented formats
- Checklists for validation

## Shareability Principles

### Make Skills Community-Friendly

Skills should be usable by anyone, not tied to specific projects or companies.

**Good - Shareable:**
```markdown
## Creating Vue Components

To create a new Vue component:

1. Use Composition API with `<script setup>`
2. Define props with TypeScript interfaces
3. Follow single-responsibility principle
```

**Bad - Project-specific:**
```markdown
## Creating Vue Components

To create a new component in our monorepo:

1. Copy from `/apps/frontend/src/components/BaseComponent.vue`
2. Update imports to use our `@company/ui-library`
3. Follow the team's naming convention in Confluence doc X
```

### Handling Project-Specific Conventions

Keep project-specific details in repository documentation (README.md, CONTRIBUTING.md, docs/) and use skills for universal best practices.

**Skill (universal):** "Use environment variables for configuration"
**Repo docs (specific):** "We use `.env.local` with keys defined in `env.example`"

**Skill (universal):** "Write tests for all public methods"
**Repo docs (specific):** "Our tests live in `__tests__/` and use custom helpers from `test-utils/`"

## Description Quality

### Vague vs Specific Descriptions

The description field determines when Claude will use your skill. Be specific about triggering conditions.

**Vague (poor discoverability):**
- "For testing" - Could mean any type of testing
- "Frontend development" - Too broad
- "Database work" - Unclear when to use

**Specific (good discoverability):**
- "This skill should be used when users want to create acceptance tests using Gherkin syntax for BDD/ATDD workflows"
- "This skill should be used when users are building Vue 3 applications with Composition API, Pinia, and TypeScript"
- "This skill should be used when users need to query or model BigQuery data warehouse schemas"

### Components of a Good Description

1. **Domain/technology**: What specific area does this cover?
2. **Triggering action**: What user intent triggers this?
3. **Key differentiators**: What makes this unique vs similar skills?

Example:
```yaml
description: This skill should be used when users want to create or modify Vue 3 components using Composition API, TypeScript, and modern tooling (Vite, Vitest). It covers component patterns, state management, and performance optimization.
```

## Research-Driven Development

### Why Research Matters

Technology evolves rapidly. Skills must reflect current practices, not historical ones.

**Case Study: vue-engineering**

Research phase discoveries:
- Vue 3.5.18 current version (not 3.0 or 2.x)
- Composition API now standard (Options API legacy)
- `<script setup>` recommended syntax (not regular `<script>`)
- Vite 6 current build tool (Vue CLI deprecated)
- Vitest 3 current test framework (Jest legacy for Vue)
- Volar extension current (Vetur deprecated)
- ref() preferred over reactive() (2025 community consensus)

Without research, the skill would have taught outdated patterns, reducing its value.

### Research Checklist

Before creating a skill:
- [ ] Identify current major version of primary technology
- [ ] Research recommended tooling and ecosystem
- [ ] Review official documentation for latest best practices
- [ ] Check community consensus on debated patterns
- [ ] Identify deprecated approaches to avoid
- [ ] Look for recent performance improvements or new features

## Avoiding Content Duplication

### One Source of Truth Principle

Each piece of information should exist in exactly one place.

**Bad - Duplicated:**

SKILL.md contains:
```markdown
## Props Validation

Use TypeScript interfaces for props:

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
}
const props = defineProps<Props>()
</script>
```
```

references/component-patterns.md also contains the same example.

**Good - Single source:**

SKILL.md contains:
```markdown
## Component Communication

See `references/component-patterns.md` for detailed props, emits, and slots patterns.
```

references/component-patterns.md contains the full examples.

### Decision Framework

**Include in SKILL.md if:**
- It's a critical workflow or decision tree
- Users need it immediately to get started
- It's a quick reference (< 10 lines of code)

**Move to references if:**
- It's detailed explanation or background
- It's one of many similar examples
- It's domain-specific knowledge
- It's comprehensive syntax reference

## Iteration and Refinement

### Testing Your Skill

After creating a skill, test it on real tasks:

1. Use the skill for its intended purpose
2. Note where Claude struggles or seems uncertain
3. Identify missing information or unclear instructions
4. Check if reference files are being loaded appropriately
5. Validate that examples are current and correct

### Common Issues After First Use

**Claude doesn't use the skill when expected:**
- Description may be too vague
- SKILL.md may not clearly state when to use it

**Claude uses the skill but struggles:**
- Missing critical workflow steps in SKILL.md
- Reference files may be too verbose or hard to navigate
- Examples may not match real-world use cases

**Context fills up too quickly:**
- Reference files may be too large
- SKILL.md may contain content better suited for references
- Consider condensing or splitting large files

### Refinement Example

**Initial vue-engineering skill:**
- 8 reference files averaging 5,000 words each
- Users noticed context filled quickly
- Files loaded slowly due to size

**After refinement:**
- Same 8 files condensed to ~2,500 words average
- Faster loading and more context available
- No loss of essential information

## Summary Checklist

Before finalizing a skill:

- [ ] SKILL.md under 5,000 words
- [ ] Reference files between 1,500-3,500 words
- [ ] Description is specific and actionable
- [ ] No duplicate content across files
- [ ] Researched current versions and best practices
- [ ] Skills are shareable, not project-specific
- [ ] Progressive disclosure followed (essentials in SKILL.md, details in references)
- [ ] Tested on real tasks and refined based on results
- [ ] All examples use current, non-deprecated syntax
- [ ] Clear pointers from SKILL.md to reference files
