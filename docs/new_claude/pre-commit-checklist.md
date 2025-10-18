# Pre-Commit Checklist

**⚠️ DO NOT COMMIT until ALL checklist items are complete**

**Last Updated:** 2025-10-19

---

## Backend Pre-Commit Checklist

Use this checklist before committing ANY backend code.

### ✅ Acceptance Criteria (MANDATORY)

**CRITICAL: Every backend feature MUST have ACs**

- [ ] **Checked [acceptance-criteria.md](acceptance-criteria.md) for relevant ACs**
  - [ ] ✅ Found existing ACs that cover this work
  - [ ] OR ✅ Wrote new ACs because none existed
  - [ ] ✅ All ACs use GIVEN-WHEN-THEN format
  - [ ] ✅ ACs comprehensively cover all aspects of the work

### ✅ Testing (MANDATORY - 100% Pass Required)

- [ ] **RSpec tests written for ALL ACs**
  - [ ] ✅ Each AC has corresponding test(s)
  - [ ] ✅ Test names reference AC IDs
  - [ ] ✅ Tests validate AC requirements
  - [ ] ✅ Edge cases covered

- [ ] **ALL project tests passing:**
  ```bash
  cd backend
  bundle exec rspec
  ```
  - [ ] ✅ Run `bundle exec rspec` → 100% passing
  - [ ] ✅ Zero failures, zero pending
  - [ ] ✅ All existing tests still pass
  - [ ] ✅ New tests pass

**🔴 STOP: If ANY test fails or ANY AC uncovered, DO NOT COMMIT**

### ✅ Internationalization (i18n)

- [ ] **NO hardcoded user-facing text**
  - [ ] ✅ All strings use `I18n.t('key')` instead of hardcoded text
  - [ ] ✅ Translations added to ALL 7 locale files:
    - `config/locales/en.yml` (English)
    - `config/locales/ja.yml` (Japanese)
    - `config/locales/ko.yml` (Korean)
    - `config/locales/zh-tw.yml` (Traditional Chinese)
    - `config/locales/zh-cn.yml` (Simplified Chinese)
    - `config/locales/es.yml` (Spanish)
    - `config/locales/fr.yml` (French)

### ✅ Documentation

- [ ] **[api-reference.md](api-reference.md) updated** (if endpoint added/modified)
  - [ ] Request/response formats documented
  - [ ] cURL examples tested
  - [ ] JavaScript/TypeScript examples tested
  - [ ] Error codes documented

- [ ] **Code comments reference AC IDs** where relevant
- [ ] **Commit message references AC IDs** (e.g., "AC-SCALE-001")

### ✅ Final Verification

- [ ] Feature complete per ACs
- [ ] All ACs have passing tests
- [ ] `bundle exec rspec` shows 100% passing
- [ ] Task marked complete in [development-checklist.md](development-checklist.md)

---

## Frontend Pre-Commit Checklist

Use this checklist before committing ANY frontend code.

### ✅ Component Development

- [ ] **Component code written and tested**
- [ ] **Checked [component-library.md](component-library.md) for existing components**
  - [ ] ✅ Reused existing components wherever possible
  - [ ] ✅ Did not create duplicate components

### ✅ Internationalization (i18n) - MANDATORY 100% Coverage

- [ ] **ALL user-facing text translated to ALL 7 languages**
  - [ ] ✅ Added to `frontend/src/locales/en.json` (English)
  - [ ] ✅ Added to `frontend/src/locales/ja.json` (Japanese)
  - [ ] ✅ Added to `frontend/src/locales/ko.json` (Korean)
  - [ ] ✅ Added to `frontend/src/locales/zh-tw.json` (Traditional Chinese)
  - [ ] ✅ Added to `frontend/src/locales/zh-cn.json` (Simplified Chinese)
  - [ ] ✅ Added to `frontend/src/locales/es.json` (Spanish)
  - [ ] ✅ Added to `frontend/src/locales/fr.json` (French)

- [ ] **Automated i18n coverage check:**
  ```bash
  cd frontend
  npm run check:i18n
  ```
  - [ ] ✅ Output shows: `✅ SUCCESS: 100% translation coverage`

- [ ] **Manual browser verification:**
  ```bash
  npm run dev
  # Open http://localhost:5173
  ```
  - [ ] ✅ Switched to **English (en)** - all text displays correctly
  - [ ] ✅ Switched to **Japanese (ja)** - all text displays correctly
  - [ ] ✅ Switched to **Korean (ko)** - all text displays correctly
  - [ ] ✅ Switched to **Traditional Chinese (zh-tw)** - all text displays correctly
  - [ ] ✅ Switched to **Simplified Chinese (zh-cn)** - all text displays correctly
  - [ ] ✅ Switched to **Spanish (es)** - all text displays correctly
  - [ ] ✅ Switched to **French (fr)** - all text displays correctly

- [ ] **No translation issues:**
  - [ ] ✅ No `[missing.key]` brackets visible in UI
  - [ ] ✅ No console warnings: `[i18n] Missing translation`
  - [ ] ✅ All text displays correctly in each language
  - [ ] ✅ Layout doesn't break with CJK characters

**🔴 STOP: If ANY i18n checkbox is unchecked, DO NOT COMMIT**

### ✅ Code Quality

- [ ] **Used translation keys, not hardcoded strings:**
  - [ ] ✅ All `<button>` text uses `{{ $t('...') }}`
  - [ ] ✅ All labels use `{{ $t('...') }}`
  - [ ] ✅ All placeholders use `:placeholder="$t('...')"`
  - [ ] ✅ All error messages use `{{ $t('...') }}`

- [ ] **Used design tokens, not hardcoded values:**
  - [ ] ✅ No hardcoded colors - uses `var(--color-*)` from `variables.css`
  - [ ] ✅ No hardcoded spacing - uses `var(--spacing-*)`
  - [ ] ✅ No hardcoded fonts - uses `var(--font-*)`
  - [ ] ✅ Follows component structure from [architecture.md](architecture.md)

### ✅ Documentation

- [ ] **Component fully documented in [component-library.md](component-library.md)**
  - [ ] Props with types and defaults
  - [ ] Emits with payload types
  - [ ] Slots documented
  - [ ] At least 2 usage examples (basic + advanced)
  - [ ] Related components listed
  - [ ] Notes and gotchas added

- [ ] **[architecture.md](architecture.md) updated** (if new folder/CSS/pattern added)

### ✅ Testing

- [ ] Component renders without errors
- [ ] **Type checking passes:**
  ```bash
  npm run type-check
  ```
- [ ] All functionality tested in browser
- [ ] Responsive design tested (mobile, tablet, desktop)

### ✅ Final Verification

- [ ] Task marked complete in [development-checklist.md](development-checklist.md)
- [ ] Component status tracker updated
- [ ] Commit message references task or feature

---

## Quick Pre-Commit Commands

### Backend
```bash
cd backend

# Run all tests (MUST show 100% passing)
bundle exec rspec

# Run specific test file
bundle exec rspec spec/services/recipe_scaler_spec.rb

# With documentation format
bundle exec rspec --format documentation
```

### Frontend
```bash
cd frontend

# Check i18n coverage (MUST show 100%)
npm run check:i18n

# Type check (MUST pass)
npm run type-check

# Build (includes type checking)
npm run build

# Start dev server for manual testing
npm run dev
```

---

## Common Violations

### ❌ Backend

**Violation: Hardcoded text**
```ruby
# ❌ BAD
flash[:notice] = "Recipe created successfully"

# ✅ GOOD
flash[:notice] = I18n.t('recipes.create.success')
```

**Violation: Missing tests**
- Writing code without corresponding RSpec tests
- Not running full test suite before commit

**Violation: Missing ACs**
- Starting development without acceptance criteria
- Incomplete AC coverage

### ❌ Frontend

**Violation: Hardcoded text**
```vue
<!-- ❌ BAD -->
<button>Save Recipe</button>

<!-- ✅ GOOD -->
<button>{{ $t('common.buttons.saveRecipe') }}</button>
```

**Violation: Hardcoded CSS values**
```vue
<!-- ❌ BAD -->
<style scoped>
.card {
  padding: 16px;
  color: #333333;
}
</style>

<!-- ✅ GOOD -->
<style scoped>
.card {
  padding: var(--spacing-md);
  color: var(--color-text);
}
</style>
```

**Violation: Missing translations**
- Adding text to only English locale file
- Not testing in all 7 languages in browser
- Skipping `npm run check:i18n`

**Violation: Duplicate components**
- Creating new component without checking component-library.md
- Not reusing existing components

---

## Emergency Checklist (Minimum Requirements)

If you're in a hurry, AT MINIMUM verify these before commit:

### Backend Minimum
- [ ] `bundle exec rspec` shows 100% passing
- [ ] All user-facing text uses `I18n.t()`
- [ ] API docs updated (if applicable)

### Frontend Minimum
- [ ] `npm run check:i18n` shows 100% coverage
- [ ] Tested in browser with all 7 languages
- [ ] Component documented in component-library.md

**But really, use the full checklist above.**

---

**Last Updated:** 2025-10-19
