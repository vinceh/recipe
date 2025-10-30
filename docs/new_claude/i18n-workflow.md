# Internationalization & Translation Workflow

Two complementary systems handle language support:
- **Static i18n (YAML):** UI text, 7 languages, developer-maintained
- **Dynamic translation (Mobility):** Recipe content, 6 languages, AI-generated

---

## Supported Languages

| Language | Code | Native | UI (YAML) | Recipes (Mobility) |
|----------|------|--------|-----------|-------------------|
| English | `en` | English | Yes | Yes |
| Japanese | `ja` | 日本語 | Yes | Yes |
| Korean | `ko` | 한국어 | Yes | Yes |
| Traditional Chinese | `zh-tw` | 繁體中文 | Yes | Yes |
| Simplified Chinese | `zh-cn` | 简体中文 | Yes | Yes |
| Spanish | `es` | Español | Yes | Yes |
| French | `fr` | Français | Yes | Yes |

**Requirement:** 100% translation coverage for UI text (all 7 languages). Recipe translations auto-generated on creation.

---

## 1. Static UI Translation (YAML)

### Backend i18n

**Location:** `backend/config/locales/`

**Files:** `en.yml`, `ja.yml`, `ko.yml`, `zh-tw.yml`, `zh-cn.yml`, `es.yml`, `fr.yml`

**Namespaces:**
- `common` - Shared UI strings (buttons, labels)
- `errors` - Validation and error messages
- `navigation` - Menu items and links
- `forms` - Form labels and placeholders
- `api` - API response messages

**Usage:**
```ruby
I18n.t('api.recipe.created')
I18n.t('errors.validation.required', field: 'Name')
```

### Frontend i18n (Vue)

**Location:** `frontend/src/locales/`

**Files:** `en.json`, `ja.json`, `ko.json`, `zh-tw.json`, `zh-cn.json`, `es.json`, `fr.json`

**Structure:**
```json
{
  "common": {
    "buttons": { "save": "...", "cancel": "..." },
    "labels": { "name": "...", "email": "..." }
  },
  "errors": {
    "validation": { "required": "...", "invalid": "..." }
  }
}
```

**Usage in templates:**
```vue
{{ $t('recipe.title') }}
{{ $t('common.buttons.save') }}
<input :placeholder="$t('forms.recipe.name')" />
```

**Usage in script (Composition API):**
```typescript
import { useI18n } from 'vue-i18n'
const { t } = useI18n()
const message = t('common.messages.success')
```

---

## 2. Dynamic Recipe Translation (Mobility)

### What Gets Translated

Entire recipe content translated to 6 non-English languages on creation via AI (Claude API).

**Translated models & fields:**
- Recipe: `name`
- IngredientGroup: `name`
- RecipeIngredient: `ingredient_name`, `preparation_notes`
- RecipeStep: `instruction_original`, `instruction_easier`, `instruction_no_equipment`
- Equipment: `canonical_name`
- DataReference: `display_name`

### Translation Tables

**Pattern:** Each translatable model → dedicated translation table (normalized)

```
Recipe → RecipeTranslation (recipe_id, locale, name)
IngredientGroup → IngredientGroupTranslation (ingredient_group_id, locale, name)
RecipeIngredient → RecipeIngredientTranslation (recipe_ingredient_id, locale, ingredient_name, preparation_notes)
RecipeStep → RecipeStepTranslation (recipe_step_id, locale, instruction_original, instruction_easier, instruction_no_equipment)
Equipment → EquipmentTranslation (equipment_id, locale, canonical_name)
DataReference → DataReferenceTranslation (data_reference_id, locale, display_name)
```

**Constraint:** `UNIQUE(entity_id, locale)`

### Fallback Chain

When translation missing for locale:

```
ja → en
ko → en
zh-tw → zh-cn → en
zh-cn → zh-tw → en
es → en
fr → en
```

### Reading Translations

**In specific locale:**
```ruby
recipe = Recipe.find(id)
I18n.with_locale(:ja) { recipe.name }  # Japanese translation
```

**With fallback:**
```ruby
I18n.with_locale(:ja) { recipe.name }
# Returns Japanese translation if exists, else fallback to English
```

**Via API:**
```
GET /api/v1/recipes/:id?lang=ja
# Response contains all translations for 'ja' locale (with fallbacks)
```

### Writing Translations

**In code:**
```ruby
recipe = Recipe.find(id)
I18n.with_locale(:ja) { recipe.update(name: 'レシピ') }
```

**Via TranslateRecipeJob (automatic):**
```ruby
# Triggered on recipe creation
TranslateRecipeJob.perform_later(recipe.id)
```

---

## 3. TranslateRecipeJob Workflow

**Trigger:** Recipe creation (enqueued automatically)

**Process:**

1. Load recipe with eager-loaded associations:
   - `ingredient_groups` with `recipe_ingredients`
   - `recipe_steps`, `equipment`

2. Instantiate `RecipeTranslator` service

3. For each language in `[ja, ko, zh-tw, zh-cn, es, fr]`:
   - Call `translator.translate_recipe(recipe, lang)`
   - Receive structured data: `{name, ingredient_groups, steps, equipment}`
   - Apply translations via `apply_translations(recipe, data, lang)`

4. Set `recipe.translations_completed = true`

5. On error:
   - Log error: "Translation failed for recipe #{recipe_id}: #{error}"
   - Re-raise exception (Sidekiq retry)

**apply_translations method:**
```ruby
I18n.with_locale(locale) do
  recipe.update(name: data['name']) if data['name']

  recipe.ingredient_groups.each_with_index do |group, idx|
    group.update(name: data['ingredient_groups'][idx]['name'])

    group.recipe_ingredients.each_with_index do |ingredient, item_idx|
      item = data['ingredient_groups'][idx]['items'][item_idx]
      ingredient.update(ingredient_name: item['name'], preparation_notes: item['preparation'])
    end
  end

  recipe.recipe_steps.order(:step_number).each_with_index do |step, idx|
    instructions = data['steps'][idx]['instructions']
    step.update(
      instruction_original: instructions['original'],
      instruction_easier: instructions['easier'],
      instruction_no_equipment: instructions['no_equipment']
    )
  end

  recipe.equipment.each_with_index do |equipment, idx|
    equipment.update(canonical_name: data['equipment'][idx])
  end
end
```

---

## 4. Auto-Triggered Translation Workflow

**Trigger:** Recipe creation or update (via `after_commit` callbacks)

### Recipe Creation Flow

**Process:**
1. `after_commit :enqueue_translation_on_create`
2. Immediately enqueue `TranslateRecipeJob.perform_later(id)`
3. No rate limiting applied
4. No deduplication check

### Recipe Update Flow

**Process:**
1. `after_commit :enqueue_translation_on_update`
2. Check for existing translation jobs: `has_translation_job_with_recipe_id?`
3. If existing job found:
   - Check if job is running: `has_running_translation_job?`
   - If NOT running: Delete pending job via `delete_pending_translation_job`
   - If running: Keep running job (never interrupt)
4. Schedule new job at next available time: `schedule_translation_at_next_available_time`

### Deduplication Logic

**Purpose:** Ensure latest recipe data wins, prevent queue buildup

**Delete pending jobs when:**
- Existing translation job exists for this recipe
- Job is NOT currently running (no `claimed_execution` record)

**Never delete:**
- Jobs with `claimed_execution` (currently executing)

**Implementation:**
```ruby
SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
  .where('arguments->0 = ?', recipe_id)
  .where(finished_at: nil)
  .joins("LEFT JOIN solid_queue_claimed_executions ON solid_queue_jobs.id = solid_queue_claimed_executions.job_id")
  .where('solid_queue_claimed_executions.job_id IS NULL')
  .destroy_all
```

### Rate Limiting

**Limit:** 4 translations per recipe per hour (rolling window)

**Window:** 1 hour (3600 seconds) from `finished_at` timestamp

**Count method:**
```ruby
SolidQueue::Job.where(class_name: 'TranslateRecipeJob')
  .where('arguments->0 = ?', recipe_id)
  .where('finished_at > ?', Time.current - 3600.seconds)
  .where.not(finished_at: nil)
  .count
```

**Scheduling logic:**

If rate limit NOT exceeded:
- Immediate enqueue: `TranslateRecipeJob.perform_later(id)`

If rate limit exceeded:
- Get oldest completed job in window: `get_oldest_completed_translation_job_in_window`
- Calculate delay: `oldest_job.finished_at + 3601.seconds - Time.current`
- Delay cannot be negative: `delay = [0, calculated_delay].max`
- Schedule with delay: `TranslateRecipeJob.set(wait: delay.seconds).perform_later(id)`

**Window scope:** Only counts jobs within 1-hour window

### Helper Methods

**`has_translation_job_with_recipe_id?`**
- Checks if any translation job exists for this recipe
- Returns `false` if SolidQueue unavailable

**`has_running_translation_job?`**
- Checks if job has `claimed_execution` and `finished_at IS NULL`
- Returns `false` if SolidQueue unavailable

**`get_oldest_completed_translation_job_in_window`**
- Returns oldest completed job within 1-hour window
- Used to calculate next available schedule time
- Returns `nil` if no jobs in window or SolidQueue unavailable

**`job_queue_available?`**
- Checks `SolidQueue::Job` class exists and table exists
- Prevents errors in test environment or before migrations

### Manual Regenerate Endpoint

**Endpoint:** `POST /admin/recipes/:id/regenerate_translations`

**Behavior:**
- Bypasses rate limiting (directly calls `TranslateRecipeJob.perform_later`)
- Bypasses deduplication (does not check for existing jobs)
- Always enqueues immediately

**Use case:** Manual rerun when translations need regeneration

---

## 5. Adding New UI Translations

### Step 1: Add English (source of truth)

**Backend:**
```yaml
# backend/config/locales/en.yml
en:
  api:
    recipe:
      created: "Recipe created successfully"
```

**Frontend:**
```json
// frontend/src/locales/en.json
{
  "recipe": {
    "actions": {
      "create": "Create Recipe"
    }
  }
}
```

### Step 2: Translate to 6 other languages

Use same structure in all locale files.

**Naming conventions:**
- Backend: `snake_case` keys
- Frontend: `camelCase` keys

### Step 3: Verify coverage

**Backend:**
```bash
rails i18n:coverage      # Should show 100%
rails i18n:missing_keys  # Should show no missing keys
```

**Frontend:**
```bash
npm run check:i18n  # Must pass with 100% coverage
```

**Manual check:**
1. Start dev server: `npm run dev`
2. Switch to each language in LanguageSwitcher
3. Check for `[missing.key]` brackets in UI
4. Check console for i18n warnings

---

## 5. Translation Key Naming

### Backend (YAML)

**Format:** `snake_case`

```yaml
errors:
  validation:
    password_too_short: "Password too short"
    email_invalid: "Invalid email"

api:
  recipe:
    created: "Recipe created"
    updated: "Recipe updated"
```

### Frontend (JSON)

**Format:** `camelCase` or `kebab-case` (choose one, use consistently)

```json
{
  "errors": {
    "validation": {
      "passwordTooShort": "Password too short",
      "emailInvalid": "Invalid email"
    }
  },
  "recipe": {
    "actions": {
      "create": "Create Recipe",
      "update": "Update Recipe"
    }
  }
}
```

### Key Organization

- Group by feature/domain (recipe, ingredient, user, etc.)
- Use hierarchical keys: `domain.category.specific`
- Reuse keys (don't duplicate the same text under different keys)

---

## 6. Best Practices

### Use i18n consistently

**Bad:** Hardcoded text
```vue
<button>Save Recipe</button>
```

**Good:** Translation key
```vue
<button>{{ $t('recipe.actions.save') }}</button>
```

### Use interpolation, not concatenation

**Bad:** String concatenation
```javascript
const message = t('recipe.created') + ' ' + recipeName
```

**Good:** Interpolation
```javascript
const message = t('recipe.createdWithName', { name: recipeName })
```

```json
{
  "recipe": {
    "createdWithName": "Recipe '{name}' created"
  }
}
```

### Keep text concise

- Shorter text easier to translate
- Better UI layout fit
- Example: "Recipe Saved" instead of "The recipe has been saved to the database"

### Avoid gender assumptions

Write gender-neutral English source text.

### Handle pluralization

Different languages have different rules.

```json
{
  "recipe": {
    "count": "No recipes | 1 recipe | {count} recipes"
  }
}
```

---

## 7. Testing Translations

### Manual verification

1. **Switch languages:** Use LanguageSwitcher (top-right)
2. **Check all routes:** Navigate entire app, no `[missing.key]` visible
3. **Verify browser console:** No i18n warnings
4. **Test API responses:** `Accept-Language` header affects response locale
5. **Test persistence:** Change language, refresh page, verify persisted in localStorage

### Automated tests

**Backend (RSpec):**
```ruby
describe 'i18n' do
  it 'sets locale from Accept-Language header' do
    request = double(headers: { 'Accept-Language' => 'ja' })
    service = I18nService.new
    service.set_locale(request)
    expect(I18n.locale).to eq(:ja)
  end
end
```

**Frontend (Vitest):**
```typescript
it('switches language', () => {
  expect(i18n.global.t('hello')).toBe('Hello')
  i18n.global.locale.value = 'ja'
  expect(i18n.global.t('hello')).toBe('こんにちは')
})
```

---

## 8. Detecting Missing Translations

### Backend

```bash
rails i18n:missing_keys
```

Output shows missing keys per locale.

### Frontend

1. Browser console for `[i18n] Missing translation` warnings
2. UI displays `[namespace.key]` for missing translations

---

## 9. Pre-Commit Checklist

**For UI text changes:**
- [ ] English translation added
- [ ] Translations for all 6 other languages added
- [ ] `rails i18n:coverage` shows 100%
- [ ] `rails i18n:missing_keys` shows no missing keys
- [ ] `npm run check:i18n` passes with 100% coverage
- [ ] Tested in browser with all 7 languages
- [ ] No `[missing.key]` brackets visible
- [ ] No console warnings

---

## 10. Common Translation Patterns

### Buttons
```json
{
  "common": {
    "buttons": {
      "save": "Save",
      "cancel": "Cancel",
      "delete": "Delete"
    }
  }
}
```

### Validation errors
```json
{
  "errors": {
    "validation": {
      "required": "This field is required",
      "invalid": "Invalid value",
      "tooShort": "Too short (min {min} characters)"
    }
  }
}
```

### Enum fields (e.g., Difficulty)
```json
{
  "forms": {
    "recipe": {
      "difficultyLevel": "Difficulty Level",
      "difficultyLevelPlaceholder": "Select difficulty level",
      "difficultyLevels": {
        "easy": "Easy",
        "medium": "Medium",
        "hard": "Hard"
      }
    }
  }
}
```

### Empty states
```json
{
  "recipe": {
    "empty": {
      "title": "No recipes",
      "message": "Create your first recipe"
    }
  }
}
```

---

## 11. Troubleshooting

**Translation not updating after file change:**
→ Restart dev server (`npm run dev`)

**Missing key warning but key exists:**
→ Check for typos: `common.buttons.save` vs `common.button.save`
→ Verify JSON syntax (trailing commas, quotes)

**Chinese locale codes not working:**
→ Use `zh-tw` (Traditional), `zh-cn` (Simplified)
→ Not `zh-TW`, `zh_tw`, `zh-CN`, `zh_cn`

---

## 12. References

- [Rails I18n Guide](https://guides.rubyonrails.org/i18n.html)
- [Vue I18n Documentation](https://vue-i18n.intlify.dev/)
- [Mobility Gem](https://github.com/shioyama/mobility) - Translation system
- [development-checklist.md](./development-checklist.md) - Phase 4 i18n tasks
- [architecture.md](./architecture.md) - Mobility architecture details
- [re-arch-ACs.md](../re-arch-ACs.md) - Phase 5 acceptance criteria (AC-PHASE5-*)
