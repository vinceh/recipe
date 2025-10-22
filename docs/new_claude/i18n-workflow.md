# Internationalization (i18n) Workflow

**Author:** V (with Claude Code)
**Date:** 2025-10-08
**Version:** 1.0
**Status:** Living Document

---

## Purpose

This document explains how to work with internationalization in the Recipe App. It covers adding new translations, testing multilingual features, and maintaining 100% translation coverage across all 7 supported languages.

---

## Supported Languages

The Recipe App supports 7 languages with 100% translation coverage:

| Language | Code | Native Name | Flag |
|----------|------|-------------|------|
| English | `en` | English | 🇬🇧 |
| Japanese | `ja` | 日本語 | 🇯🇵 |
| Korean | `ko` | 한국어 | 🇰🇷 |
| Traditional Chinese | `zh-tw` | 繁體中文 | 🇹🇼 |
| Simplified Chinese | `zh-cn` | 简体中文 | 🇨🇳 |
| Spanish | `es` | Español | 🇪🇸 |
| French | `fr` | Français | 🇫🇷 |

**CRITICAL:** ALL user-facing text must be translated into ALL 7 languages before committing.

---

## Translation Architecture

### Backend (Rails I18n)

**Location:** `backend/config/locales/`

**Purpose:** Server-side translations for:
- API response messages
- Error messages
- Email templates
- Backend validation messages
- System notifications

**Files:**
- `en.yml` - English (default)
- `ja.yml` - Japanese
- `ko.yml` - Korean
- `zh-tw.yml` - Traditional Chinese
- `zh-cn.yml` - Simplified Chinese
- `es.yml` - Spanish
- `fr.yml` - French

**Namespaces:**
- `common` - Shared UI strings (buttons, labels, messages)
- `errors` - Validation and error messages
- `navigation` - Navigation menus and links
- `forms` - Form labels and placeholders
- `models` - Model attribute names
- `api` - API response messages

### Frontend (Vue I18n)

**Location:** `frontend/src/locales/`

**Purpose:** Client-side translations for:
- UI buttons and labels
- Navigation items
- Form fields
- Validation messages
- Empty states
- Loading messages

**Files:**
- `en.json` - English (default)
- `ja.json` - Japanese
- `ko.json` - Korean
- `zh-tw.json` - Traditional Chinese
- `zh-cn.json` - Simplified Chinese
- `es.json` - Spanish
- `fr.json` - French

**Structure:**
```json
{
  "common": {
    "buttons": {},
    "labels": {},
    "messages": {}
  },
  "navigation": {},
  "forms": {
    "recipe": {},
    "user": {}
  },
  "errors": {
    "validation": {}
  }
}
```

---

## How to Add New Translation Keys

### Step 1: Add to English Files First

Always start with English as the source of truth.

#### Backend Example:
```yaml
# backend/config/locales/en.yml
en:
  api:
    recipe:
      created: "Recipe created successfully"
      updated: "Recipe updated successfully"
      deleted: "Recipe deleted successfully"
```

#### Frontend Example:
```json
// frontend/src/locales/en.json
{
  "recipe": {
    "actions": {
      "create": "Create Recipe",
      "update": "Update Recipe",
      "delete": "Delete Recipe"
    }
  }
}
```

### Step 2: Add Translations to ALL 6 Other Languages

**⚠️ MANDATORY:** You must translate the keys into ALL languages before committing.

Use the same structure and hierarchy in all locale files.  Use Haiku Sub-Agents for this task.

#### Example for Japanese:
```json
// frontend/src/locales/ja.json
{
  "recipe": {
    "actions": {
      "create": "レシピを作成",
      "update": "レシピを更新",
      "delete": "レシピを削除"
    }
  }
}
```

### Step 3: Verify Translation Coverage

#### Backend Verification:
```bash
# Check coverage for all languages
rails i18n:coverage

# Check for missing keys
rails i18n:missing_keys
```

Expected output:
```
✅ Translation Coverage: 100.0% average
✅ No missing translation keys found!
```

#### Frontend Verification:
1. Run the dev server: `npm run dev`
2. Open browser console
3. Switch between all 7 languages in the LanguageSwitcher
4. Look for warnings: `[i18n] Missing translation: "key" for locale "xx"`
5. Check UI for `[missing.key]` displayed in brackets

---

## Translation Key Naming Conventions

### Backend (YAML)

Use snake_case for keys:

```yaml
errors:
  validation:
    password_too_short: "Password is too short"
    invalid_email: "Invalid email address"
```

### Frontend (JSON)

Use camelCase for keys:

```json
{
  "errors": {
    "validation": {
      "passwordTooShort": "Password is too short",
      "invalidEmail": "Invalid email address"
    }
  }
}
```

### Key Organization Guidelines

1. **Group by feature/domain:**
   ```json
   {
     "recipe": {
       "title": "Recipe Title",
       "servings": "Servings"
     },
     "ingredient": {
       "name": "Ingredient Name",
       "quantity": "Quantity"
     }
   }
   ```

2. **Use descriptive, hierarchical keys:**
   - ✅ `forms.recipe.validation.titleRequired`
   - ❌ `error1`, `msg_xyz`

3. **Avoid duplication:**
   - If the same text appears in multiple places, reuse the key
   - Example: `common.buttons.save` instead of separate keys for each form

---

## Using Translations in Code

### Backend (Rails)

```ruby
# In controllers or services
I18n.t('api.recipe.created')
# => "Recipe created successfully"

# With interpolation
I18n.t('api.recipe.created_by', name: user.name)
# => "Recipe created by John"

# In models (validation errors)
validates :title, presence: { message: I18n.t('errors.validation.required') }
```

### Frontend (Vue)

#### In Templates:
```vue
<template>
  <!-- Basic usage -->
  <h1>{{ $t('recipe.title') }}</h1>

  <!-- With interpolation -->
  <p>{{ $t('recipe.servings', { count: 4 }) }}</p>

  <!-- For attributes -->
  <input :placeholder="$t('forms.recipe.title')" />
</template>
```

#### In Script (Composition API):
```vue
<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const message = t('common.messages.success')
</script>
```

---

## How to Test Translations

### Manual Testing Checklist

1. **Switch Languages:**
   - Use the LanguageSwitcher dropdown (top-right corner)
   - Switch to each of the 7 languages
   - Verify UI text changes immediately

2. **Check All Pages:**
   - Navigate through all routes
   - Verify no `[missing.key]` brackets appear
   - Check browser console for i18n warnings

3. **Test Forms:**
   - Submit forms with validation errors
   - Verify error messages display in the current language

4. **Test API Responses:**
   - Trigger API calls
   - Check Network tab → Request Headers → `Accept-Language`
   - Verify API responses return localized messages

5. **Test Persistence:**
   - Change language
   - Refresh the page
   - Verify language persists (from localStorage)

### Automated Testing

#### Backend (RSpec):
```ruby
# spec/services/i18n_service_spec.rb
RSpec.describe I18nService do
  describe '.set_locale' do
    it 'sets locale from Accept-Language header' do
      request = double(headers: { 'Accept-Language' => 'ja' })
      I18nService.set_locale(request)
      expect(I18n.locale).to eq(:ja)
    end
  end
end
```

#### Frontend (Vitest):
```typescript
// tests/i18n.spec.ts
import { mount } from '@vue/test-utils'
import { createI18n } from 'vue-i18n'

describe('i18n', () => {
  it('switches language', async () => {
    const i18n = createI18n({
      legacy: false,
      locale: 'en',
      messages: { en: { hello: 'Hello' }, ja: { hello: 'こんにちは' } }
    })

    expect(i18n.global.t('hello')).toBe('Hello')

    i18n.global.locale.value = 'ja'
    expect(i18n.global.t('hello')).toBe('こんにちは')
  })
})
```

---

## Detecting Missing Translations

### In Development

Missing translations are automatically detected:

1. **Console Warnings:**
   ```
   [i18n] Missing translation: "recipe.newKey" for locale "ja"
   ```

2. **Visual Indicators:**
   - Missing keys display as `[recipe.newKey]` in the UI

### Backend Detection

Run the rake task:
```bash
rails i18n:missing_keys
```

Output shows missing keys by locale:
```
❌ Missing keys in ja:
  - api.recipe.new_feature

❌ Missing keys in es:
  - api.recipe.new_feature
```

### Frontend Detection

1. Open browser DevTools console
2. Switch through all 7 languages
3. Watch for `[i18n] Missing translation` warnings
4. Check UI for `[missing.key]` text

---

## Best Practices for Writing Translatable Text

### 1. Avoid Hardcoded Strings

❌ **Bad:**
```vue
<button>Save Recipe</button>
```

✅ **Good:**
```vue
<button>{{ $t('recipe.actions.save') }}</button>
```

### 2. Keep Text Concise

Shorter text is easier to translate and fits better in UI layouts.

❌ **Bad:**
```json
{
  "message": "This is a very long message that explains everything in great detail"
}
```

✅ **Good:**
```json
{
  "title": "Recipe Saved",
  "message": "Your recipe has been saved successfully"
}
```

### 3. Avoid String Concatenation

Different languages have different grammar and word order.

❌ **Bad:**
```javascript
const message = t('recipe.created') + ' ' + recipeName
```

✅ **Good:**
```javascript
// Use interpolation
const message = t('recipe.createdWithName', { name: recipeName })
```

```json
{
  "recipe": {
    "createdWithName": "Recipe '{name}' created successfully"
  }
}
```

### 4. Provide Context in Key Names

❌ **Bad:**
```json
{
  "save": "Save"
}
```

✅ **Good:**
```json
{
  "recipe": {
    "actions": {
      "save": "Save Recipe"
    }
  }
}
```

### 5. Use Gender-Neutral Language

Avoid assumptions about gender in English source text.

### 6. Separate Pluralization

Different languages have different pluralization rules.

```json
{
  "recipe": {
    "count": "No recipes | 1 recipe | {count} recipes"
  }
}
```

---

## Common Translation Patterns

### Buttons
```json
{
  "common": {
    "buttons": {
      "save": "Save",
      "cancel": "Cancel",
      "delete": "Delete",
      "edit": "Edit",
      "create": "Create"
    }
  }
}
```

### Form Validation
```json
{
  "errors": {
    "validation": {
      "required": "This field is required",
      "invalidEmail": "Invalid email address",
      "tooShort": "Too short (minimum {min} characters)"
    }
  }
}
```

### Empty States
```json
{
  "recipe": {
    "empty": {
      "title": "No recipes yet",
      "message": "Create your first recipe to get started"
    }
  }
}
```

---

## Troubleshooting

### Issue: Translation not updating after changing locale file

**Solution:** Restart the dev server
```bash
# Stop and restart
npm run dev
```

### Issue: Missing key warning but key exists

**Solution:** Check for typos in:
1. Key path: `common.buttons.save` vs `common.button.save`
2. Locale file structure (must match exactly)
3. JSON syntax errors (trailing commas, missing quotes)

### Issue: Chinese variants not working

**Solution:** Ensure locale codes match:
- Traditional Chinese: `zh-tw` (not `zh-TW` or `zh_tw`)
- Simplified Chinese: `zh-cn` (not `zh-CN` or `zh_cn`)

---

## Maintaining 100% Coverage

### Pre-Commit Checklist

Before committing any code with user-facing text:

- [ ] Added English translation to locale file(s)
- [ ] Added translations for ALL 6 other languages
- [ ] Ran `rails i18n:coverage` → shows 100%
- [ ] Ran `rails i18n:missing_keys` → shows ✅
- [ ] Tested in browser with all 7 languages
- [ ] No `[missing.key]` brackets visible
- [ ] No console warnings for missing translations

### Monthly Audit

Perform a comprehensive i18n audit once per month:

1. Run coverage reports for backend and frontend
2. Test all features in all 7 languages
3. Check for outdated or unused keys
4. Review and improve translation quality
5. Update this workflow document as needed

---

## Resources

- [Vue I18n Documentation](https://vue-i18n.intlify.dev/)
- [Rails I18n Guide](https://guides.rubyonrails.org/i18n.html)
- [Unicode CLDR](http://cldr.unicode.org/) - Language data standards
- [development-checklist.md](./development-checklist.md) - Phase 3.5 i18n tasks
- [DOCUMENTATION-WORKFLOW.md](./DOCUMENTATION-WORKFLOW.md) - i18n requirements

---

## Quick Reference

### Add New Translation (Frontend)

1. Add to `locales/en.json`
2. Add to `locales/ja.json`
3. Add to `locales/ko.json`
4. Add to `locales/zh-tw.json`
5. Add to `locales/zh-cn.json`
6. Add to `locales/es.json`
7. Add to `locales/fr.json`
8. Test in browser

### Add New Translation (Backend)

1. Add to `config/locales/en.yml`
2. Add to all 6 other `.yml` files
3. Run `rails i18n:coverage`
4. Run `rails i18n:missing_keys`

### Use Translation in Vue

```vue
{{ $t('namespace.key') }}
{{ $t('namespace.key', { param: value }) }}
```

### Use Translation in Rails

```ruby
I18n.t('namespace.key')
I18n.t('namespace.key', param: value)
```
