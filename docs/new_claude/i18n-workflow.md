# i18n Workflow

Two systems handle language support:
- **Static i18n (YAML/JSON):** UI text, developer-maintained
- **Dynamic translation (Mobility):** Recipe content, AI-generated (see architecture.md)

---

## Supported Languages

| Code | Language | UI | Recipes |
|------|----------|-----|---------|
| `en` | English | Yes | Yes |
| `ja` | Japanese | Yes | Yes |
| `ko` | Korean | Yes | Yes |
| `zh-tw` | Traditional Chinese | Yes | Yes |
| `zh-cn` | Simplified Chinese | Yes | Yes |
| `es` | Spanish | Yes | Yes |
| `fr` | French | Yes | Yes |

---

## Adding UI Translations

### Backend (Rails)

**Location:** `backend/config/locales/{locale}.yml`

```yaml
# backend/config/locales/en.yml
en:
  api:
    recipe:
      created: "Recipe created successfully"
```

**Usage:**
```ruby
I18n.t('api.recipe.created')
I18n.t('errors.validation.required', field: 'Name')
```

### Frontend (Vue)

**Location:** `frontend/src/locales/{locale}.json`

```json
{
  "recipe": {
    "actions": {
      "create": "Create Recipe"
    }
  }
}
```

**Usage:**
```vue
{{ $t('recipe.actions.create') }}
<input :placeholder="$t('forms.recipe.name')" />
```

```typescript
import { useI18n } from 'vue-i18n'
const { t } = useI18n()
const message = t('common.messages.success')
```

---

## Key Naming

- **Backend (YAML):** `snake_case`
- **Frontend (JSON):** `camelCase`
- **Structure:** `domain.category.specific` (e.g., `recipe.actions.save`)

---

## Verification

**Backend:**
```bash
rails i18n:coverage      # Must be 100%
rails i18n:missing_keys  # Must show no missing keys
```

**Frontend:**
```bash
npm run check:i18n  # Must pass 100%
```

**Manual:**
1. Switch through all 7 languages in LanguageSwitcher
2. No `[missing.key]` brackets visible
3. No console i18n warnings

---

## Best Practices

**Use interpolation:**
```json
{ "recipe": { "createdWithName": "Recipe '{name}' created" } }
```
```javascript
t('recipe.createdWithName', { name: recipeName })
```

**Handle pluralization:**
```json
{ "recipe": { "count": "No recipes | 1 recipe | {count} recipes" } }
```

---

## Common Patterns

```json
{
  "common": {
    "buttons": { "save": "Save", "cancel": "Cancel", "delete": "Delete" }
  },
  "errors": {
    "validation": {
      "required": "This field is required",
      "tooShort": "Too short (min {min} characters)"
    }
  },
  "recipe": {
    "empty": { "title": "No recipes", "message": "Create your first recipe" }
  }
}
```

---

## Troubleshooting

- **Translation not updating:** Restart dev server
- **Missing key but exists:** Check typos, JSON syntax
- **Chinese locale:** Use `zh-tw`/`zh-cn` (not `zh-TW`, `zh_tw`)
