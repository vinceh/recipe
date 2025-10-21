# Development Workflow

**Last Updated:** 2025-10-21
**Purpose:** Define MANDATORY step-by-step workflows for backend and frontend development

---

## Table of Contents

1. [Backend Development Workflow](#backend-development-workflow)
2. [Frontend Development Workflow](#frontend-development-workflow)
3. [Critical Rules](#critical-rules)
4. [Common Pitfalls](#common-pitfalls)

---

## Backend Development Workflow

### BEFORE Development

#### Step 1: Check for Existing Acceptance Criteria

```bash
# Search acceptance-criteria.md for relevant ACs
grep -i "keyword" docs/new_claude/acceptance-criteria.md
```

**If ACs exist:**
- ✅ Read ALL relevant ACs thoroughly
- ✅ Understand exact requirements
- ✅ Note AC IDs for reference in tests and commits (e.g., AC-SCALE-001)

**If NO ACs exist:**
- 🛑 **STOP coding immediately**
- ✅ Write comprehensive ACs in [acceptance-criteria.md](acceptance-criteria.md)
- ✅ Use GIVEN-WHEN-THEN format (see existing examples)
- ✅ Cover ALL aspects of the feature
- ✅ Number ACs sequentially (e.g., AC-FEAT-001, AC-FEAT-002)
- ✅ Get AC review/approval before proceeding with code

**Example AC Format:**
```markdown
### AC-SCALE-001: Scale Recipe by Servings

**GIVEN** a recipe with original servings of 4
**WHEN** user requests to scale to 6 servings
**THEN** system calculates scale factor (1.5)
**AND** adjusts all ingredient amounts proportionally
**AND** returns scaled ingredient list

**Acceptance:**
- Scale factor = new_servings / original_servings
- All ingredient amounts multiplied by scale factor
- Amounts rounded to 2 decimal places
```

#### Step 2: Review Existing APIs

- ✅ Check [api-reference.md](api-reference.md) to understand existing endpoints
- ✅ Avoid duplicating functionality
- ✅ Ensure new endpoints follow existing patterns

---

### DURING Development

#### Step 3: Implement Code (TDD Approach)

1. **Write RSpec tests FIRST** for each AC
   - Each AC should have at least one test
   - Test names clearly reference AC IDs
   - Tests validate exact AC requirements
   - Cover edge cases

**Example Test:**
```ruby
# spec/services/recipe_scaler_spec.rb
RSpec.describe RecipeScaler do
  describe '#scale' do
    # AC-SCALE-001
    it 'scales recipe by servings with correct scale factor' do
      recipe = create(:recipe, servings: 4, ingredients: [
        { name: 'flour', amount: 200, unit: 'g' }
      ])

      scaler = RecipeScaler.new(recipe)
      result = scaler.scale(new_servings: 6)

      expect(result[:scale_factor]).to eq(1.5)
      expect(result[:ingredients][0][:amount]).to eq(300)
    end
  end
end
```

2. **Implement the feature** to make tests pass
3. **Add i18n for ALL user-facing text** (NO hardcoded strings)

**Backend i18n:**
```ruby
# ❌ BAD - NEVER DO THIS:
flash[:notice] = "Recipe created successfully"
render json: { error: "Invalid input" }

# ✅ GOOD - ALWAYS DO THIS:
flash[:notice] = I18n.t('recipes.create.success')
render json: { error: I18n.t('recipes.create.invalid_input') }
```

4. **Add translations to ALL 7 locale files:**
   - `config/locales/en.yml` (English)
   - `config/locales/ja.yml` (Japanese)
   - `config/locales/ko.yml` (Korean)
   - `config/locales/zh-tw.yml` (Traditional Chinese)
   - `config/locales/zh-cn.yml` (Simplified Chinese)
   - `config/locales/es.yml` (Spanish)
   - `config/locales/fr.yml` (French)

---

### AFTER Development

#### Step 4: Run Tests (100% Pass Required)

```bash
cd backend
bundle exec rspec
```

**Required Output:**
```
Finished in X.XX seconds
XXX examples, 0 failures, 0 pending
```

**Verification Checklist:**
- [ ] ✅ ALL tests passing (100%)
- [ ] ✅ ZERO failures
- [ ] ✅ ZERO pending tests
- [ ] ✅ New tests included in count
- [ ] ✅ Existing tests still pass

**🔴 STOP: If ANY test fails, fix before proceeding**

#### Step 5: Update Documentation

1. **If API endpoints were added/modified:**
   - [ ] Update [api-reference.md](api-reference.md) using [api-documentation-guide.md](api-documentation-guide.md)
   - [ ] Test all cURL and code examples
   - [ ] Document request/response formats
   - [ ] Document error codes

2. **Update other relevant docs:**
   - [ ] [architecture.md](architecture.md) if new models/patterns added
   - [ ] [development-checklist.md](development-checklist.md) - mark task complete

3. **Commit message:**
   - Reference AC IDs (e.g., "Implement recipe scaling (AC-SCALE-001 to AC-SCALE-012)")

#### Step 6: Mark Task Complete

- [ ] Find relevant task in [development-checklist.md](development-checklist.md)
- [ ] Mark as complete with `[x]`
- [ ] Update phase notes with:
  - Number of tests passing
  - Key implementation details
  - Any deviations from plan

---

## Frontend Development Workflow

### BEFORE Development

#### Step 0: Check for Existing Acceptance Criteria (MANDATORY)

```bash
# Search acceptance-criteria.md for relevant ACs
grep -i "keyword" docs/new_claude/acceptance-criteria.md
```

**If ACs exist:**
- ✅ Read ALL relevant ACs thoroughly
- ✅ Understand exact requirements including user flows, accessibility states, error handling, and visual requirements
- ✅ Note AC IDs for reference in Playwright tests and commits (e.g., AC-FEAT-001)

**If NO ACs exist:**
- 🛑 **STOP coding immediately**
- ✅ Write comprehensive ACs in [acceptance-criteria.md](acceptance-criteria.md)
- ✅ Use GIVEN-WHEN-THEN format (see existing examples)
- ✅ Cover ALL aspects of the UI feature (user flows, states, interactions, responsive behavior)
- ✅ Number ACs sequentially (e.g., AC-FEAT-001, AC-FEAT-002)
- ✅ Get AC review/approval before proceeding with code

**Example AC Format:**
```markdown
### AC-RECIPE-UI-001: Display Recipe Card with Image

**GIVEN** user views recipe list page
**WHEN** recipes are loaded
**THEN** each recipe displays as a card
**AND** card shows recipe image, title, cooking time, and difficulty
**AND** card is clickable to view recipe details

**Acceptance:**
- Card uses RecipeCard component from component library
- Image aspect ratio is 16:9
- Missing images show placeholder
- Card has hover state for better UX
```

#### Step 1: Check for Existing Components

- ✅ **Check [component-library.md](component-library.md)** for existing components
- ✅ **Reuse existing components** whenever possible
- ✅ Avoid creating duplicate or similar components

**Examples of reusable components:**
- `LoadingSpinner`, `ErrorMessage`, `ConfirmDialog`, `EmptyState`
- `RecipeCard`, `FilterPanel`, `SearchBar`
- Admin layout components

#### Step 2: Review Design System

- ✅ **Read [architecture.md](architecture.md)** → Frontend Architecture section
- ✅ Understand design tokens (CSS variables)
- ✅ Understand component organization patterns
- ✅ Understand folder structure

**Golden Rule:** Never hardcode colors, spacing, or fonts - always use CSS variables:

```vue
<!-- ❌ BAD - NEVER DO THIS: -->
<style scoped>
.card {
  padding: 16px;
  color: #333333;
  font-size: 14px;
}
</style>

<!-- ✅ GOOD - ALWAYS DO THIS: -->
<style scoped>
.card {
  padding: var(--spacing-md);
  color: var(--color-text);
  font-size: var(--font-size-sm);
}
</style>
```

---

### DURING Development

#### Step 3: Implement Component

1. **Follow component file structure** from [architecture.md](architecture.md)
2. **Use design tokens** from `variables.css`
3. **NO hardcoded user-facing text** - use i18n from the start

**Frontend i18n:**
```vue
<!-- ❌ BAD - NEVER DO THIS: -->
<h1>Welcome to Ember</h1>
<button>Create Recipe</button>
<p>No recipes found</p>

<!-- ✅ GOOD - ALWAYS DO THIS: -->
<h1>{{ $t('common.welcome') }}</h1>
<button>{{ $t('common.buttons.createRecipe') }}</button>
<p>{{ $t('admin.recipes.noRecipes') }}</p>
```

4. **Add translations to ALL 7 locale files IMMEDIATELY:**
   - `frontend/src/locales/en.json` (English)
   - `frontend/src/locales/ja.json` (Japanese)
   - `frontend/src/locales/ko.json` (Korean)
   - `frontend/src/locales/zh-tw.json` (Traditional Chinese)
   - `frontend/src/locales/zh-cn.json` (Simplified Chinese)
   - `frontend/src/locales/es.json` (Spanish)
   - `frontend/src/locales/fr.json` (French)

**See [i18n-workflow.md](i18n-workflow.md) for complete i18n guide.**

---

### AFTER Development

#### Step 4: Verify i18n Coverage (MANDATORY - 100% Required)

**Automated Check:**
```bash
cd frontend
npm run check:i18n
```

**Expected output:**
```
✅ SUCCESS: 100% translation coverage across all 7 languages!
```

**Manual Verification (Required Even After Script Passes):**

1. Start dev server: `npm run dev`
2. Open http://localhost:5173
3. Open browser DevTools console
4. Switch through ALL 7 languages:
   - [ ] 🇬🇧 English (en) - verify all text displays correctly
   - [ ] 🇯🇵 日本語 (ja) - verify all text displays correctly
   - [ ] 🇰🇷 한국어 (ko) - verify all text displays correctly
   - [ ] 🇹🇼 繁體中文 (zh-tw) - verify all text displays correctly
   - [ ] 🇨🇳 简体中文 (zh-cn) - verify all text displays correctly
   - [ ] 🇪🇸 Español (es) - verify all text displays correctly
   - [ ] 🇫🇷 Français (fr) - verify all text displays correctly

**Check for issues:**
- [ ] No `[missing.key]` brackets visible in UI
- [ ] No console warnings: `[i18n] Missing translation`
- [ ] All buttons, labels, messages display translated text
- [ ] No English text visible when viewing non-English languages

**🔴 STOP: If ANY issue found, fix translations before proceeding**

#### Step 5: Update Documentation

1. **Component Library** ([component-library.md](component-library.md))
   - [ ] Component location documented
   - [ ] Purpose clearly stated
   - [ ] All props documented with types and defaults
   - [ ] All emits documented with payload types
   - [ ] All slots documented
   - [ ] At least 2 usage examples provided (basic + advanced)
   - [ ] Related components listed
   - [ ] Notes section includes gotcas and best practices
   - [ ] Component status tracker updated
   - [ ] Last Updated date is current

2. **Architecture Documentation** ([architecture.md](architecture.md))
   - [ ] New folders added to project structure (if applicable)
   - [ ] New CSS files documented (if applicable)
   - [ ] New patterns documented in best practices (if applicable)
   - [ ] New composables documented (if applicable)

3. **Development Checklist** ([development-checklist.md](development-checklist.md))
   - [ ] Task marked as complete
   - [ ] Documentation subtasks checked off

#### Step 6: Write and Run Playwright Tests (MANDATORY - 100% Pass Required)

**Just like backend requires RSpec tests for every AC, frontend requires Playwright tests for every AC.**

1. **Write Playwright tests for EVERY AC from Step 0**
   - [ ] Each AC must have at least one Playwright test
   - [ ] Test names clearly reference AC IDs (e.g., `test('AC-RECIPE-UI-001: displays recipe card with image', async ({ page }) => { ... })`)
   - [ ] Tests validate exact AC requirements
   - [ ] Include edge cases, error states, and accessibility checks as specified in ACs

**Example Test:**
```typescript
// tests/e2e/recipes/recipe-card.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Recipe Card Display', () => {
  // AC-RECIPE-UI-001
  test('AC-RECIPE-UI-001: displays recipe card with image', async ({ page }) => {
    await page.goto('/recipes')

    const recipeCard = page.locator('.recipe-card').first()
    await expect(recipeCard).toBeVisible()

    await expect(recipeCard.locator('.recipe-image')).toBeVisible()
    await expect(recipeCard.locator('.recipe-title')).toBeVisible()
    await expect(recipeCard.locator('.cooking-time')).toBeVisible()

    await recipeCard.hover()
    await expect(recipeCard).toHaveClass(/hover/)
  })
})
```

2. **Capture UI screenshots during test runs**
   - [ ] Use `await page.screenshot({ path: 'screenshots/feature-name.png' })` to capture the implemented UI
   - [ ] Take screenshots of key states: default, hover, error, loading, etc.
   - [ ] Screenshot filenames should be descriptive (e.g., `recipe-card-default.png`, `recipe-form-error-state.png`)

3. **Evaluate UI against industry standards**
   - [ ] Review ALL captured screenshots immediately
   - [ ] Evaluate against industry-standard UI/UX practices:
     - Visual hierarchy clear and logical
     - Proper spacing and alignment
     - Consistent with design system
     - Accessible contrast ratios
     - Appropriate interactive states (hover, focus, active)
     - Responsive to different viewport sizes
     - Error states are clear and actionable
   - [ ] Document any required refinements
   - [ ] Make necessary UI improvements BEFORE completing the task
   - [ ] Re-run tests and capture new screenshots after improvements

4. **Delete screenshot files after review**
   - [ ] Screenshots are temporary artifacts for UI evaluation only
   - [ ] Delete ALL screenshot files from filesystem after completing UI evaluation
   - [ ] DO NOT commit screenshot files to the repository
   - [ ] Verify no screenshot files remain: `find . -name "*.png" -path "*/screenshots/*"`

5. **Run the complete Playwright test suite**

```bash
cd frontend
npm run test:e2e
```

**Required Output:**
```
✅ XX passed (Xm)
0 failures
```

**Verification Checklist:**
- [ ] ✅ 100% of Playwright tests passing (ZERO failures)
- [ ] ✅ New tests included and passing
- [ ] ✅ Existing tests still pass
- [ ] ✅ UI screenshots captured and evaluated
- [ ] ✅ UI refinements completed based on evaluation
- [ ] ✅ All screenshot files deleted
- [ ] ✅ New test specs committed alongside the feature

**🔴 STOP: If ANY test fails or UI doesn't meet standards, fix before proceeding**

#### Step 7: Run Quality Checks

```bash
cd frontend

# Type checking
npm run type-check

# i18n coverage (should already be done in Step 4)
npm run check:i18n

# Build (includes type checking)
npm run build
```

#### Step 8: Mark Task Complete

- [ ] Find relevant task in [development-checklist.md](development-checklist.md)
- [ ] Mark as complete with `[x]`
- [ ] Update component status tracker
- [ ] Commit message references task or feature

---

## Critical Rules

### Backend

1. **🔴 ACs FIRST** - Write acceptance criteria BEFORE coding
2. **🔴 NO ACs = NO CODE** - If ACs don't exist, write them first
3. **🔴 Tests ALWAYS** - RSpec test for EVERY AC
4. **🔴 100% Pass** - All tests must pass before commit (zero failures, zero pending)
5. **🔴 Document APIs** - Update api-reference.md when endpoints change
6. **🔴 NO hardcoded text** - Use I18n.t() for ALL user-facing strings
7. **🔴 Reference AC IDs** - In commits, code comments, and tests

### Frontend

1. **🔴 ACs FIRST** - Write acceptance criteria BEFORE coding
2. **🔴 NO ACs = NO CODE** - If ACs don't exist, write them first
3. **🔴 Playwright Tests ALWAYS** - Test for EVERY AC (just like backend RSpec)
4. **🔴 100% Pass** - All Playwright tests must pass before commit (zero failures)
5. **🔴 Evaluate UI** - Capture screenshots, review against industry standards, delete after review
6. **🔴 Reuse Components** - Check component-library.md BEFORE creating new ones
7. **🔴 100% i18n** - All 7 languages required (no exceptions)
8. **🔴 Design Tokens** - Never hardcode colors/spacing (use CSS variables)
9. **🔴 Document While Building** - Update component-library.md as you code
10. **🔴 Test All Languages** - Switch through all 7 in browser before commit
11. **🔴 NO hardcoded text** - Use $t() or t() for ALL user-facing strings

---

## Common Pitfalls

### Backend

❌ **Coding before writing ACs**
- Leads to incomplete requirements, missed edge cases, untestable code

❌ **Skipping tests**
- "I'll write them later" = they never get written

❌ **Not running full test suite**
- New code might break existing tests

❌ **Hardcoding user-facing text**
- `"Error occurred"` instead of `I18n.t('errors.generic')`

❌ **Not updating API documentation**
- Future developers waste time reading code to understand endpoints

### Frontend

❌ **Coding before writing ACs**
- Leads to incomplete UI requirements, missed user flows, untestable interfaces

❌ **Skipping Playwright tests**
- "I'll write them later" = they never get written
- Creates untested UI with hidden bugs

❌ **Not running full Playwright test suite**
- New UI changes might break existing user flows

❌ **Skipping UI screenshot evaluation**
- Ships UI that doesn't meet industry standards
- Misses obvious UX issues that screenshots would reveal

❌ **Committing screenshot files**
- Screenshots are temporary evaluation artifacts only
- Bloats repository with binary files

❌ **Creating new components without checking existing ones**
- Leads to duplicate components with similar functionality

❌ **Hardcoding CSS values**
- `padding: 16px` instead of `padding: var(--spacing-md)`
- Makes design system changes difficult

❌ **Adding i18n as an afterthought**
- Hardcoding text then having to refactor everything
- Missing translations in some languages

❌ **Not testing in all languages**
- Layout breaks with CJK characters, missing translations discovered late

❌ **Not documenting components**
- "I'll document it later" = it never gets documented
- Future you forgets how to use the props

---

## Summary Workflow Diagrams

### Backend
```
1. Check ACs → Write ACs if missing
2. Write RSpec tests (TDD)
3. Implement code + i18n
4. Run bundle exec rspec → 100% pass
5. Update api-reference.md (if applicable)
6. Mark task complete
7. Commit
```

### Frontend
```
1. Check ACs → Write ACs if missing (GIVEN-WHEN-THEN format)
2. Check component-library.md for existing components
3. Implement component + i18n (all 7 languages)
4. Run npm run check:i18n → 100% pass
5. Test in browser (switch through all 7 languages)
6. Write Playwright tests for all ACs
7. Run npm run test:e2e → 100% pass (0 failures)
8. Capture UI screenshots → evaluate against industry standards
9. Refine UI based on evaluation → re-test
10. Delete all screenshot files
11. Document in component-library.md
12. Update architecture.md (if needed)
13. Mark task complete
14. Commit
```

---

**Last Updated:** 2025-10-21
