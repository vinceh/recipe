# API Reference

Base URL: `/api/v1` | Content-Type: `application/json`

---

## Authentication

All requests except sign_up/sign_in require `Authorization: Bearer <jwt_token>` header.

### Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/sign_up` | No | Create account, returns JWT |
| POST | `/auth/sign_in` | No | Login, returns JWT |
| DELETE | `/auth/sign_out` | Yes | Logout, invalidates JWT |

### Sign Up
```bash
curl -X POST /api/v1/auth/sign_up -d '{"user":{"email":"x@y.com","password":"pass123","password_confirmation":"pass123"}}'
```
Response: `201` with `Authorization` header containing JWT

### Sign In
```bash
curl -X POST /api/v1/auth/sign_in -d '{"user":{"email":"x@y.com","password":"pass123"}}'
```
Response: `200` with `Authorization` header containing JWT

---

## Locale Support

**Query param:** `?lang=ja` | **Header:** `Accept-Language: ja`

**Languages:** en, ja, ko, zh-tw, zh-cn, es, fr

**Fallback:** ja→en, ko→en, zh-tw→zh-cn→en, es→en, fr→en

---

## Common Response Format

**Success:**
```json
{"success": true, "data": {...}, "message": "..."}
```

**Error:**
```json
{"success": false, "message": "...", "errors": ["..."]}
```

**Pagination (in `data`):**
```json
{"pagination": {"current_page": 1, "per_page": 20, "total_count": 45, "total_pages": 3}}
```

---

## Public Recipes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/recipes` | List recipes with search/filters |
| GET | `/recipes/:id` | Get recipe details |
| POST | `/recipes/:id/scale` | Scale recipe ingredients |

### List Recipes

**Query params:**
- `page`, `per_page` - Pagination (default 20, max 100)
- `q` - Search name (fuzzy)
- `dietary_tags[]` - Filter by tags (OR logic)
- `cuisines[]` - Filter by cuisines (OR logic)
- `dish_types[]` - Filter by dish types (OR logic)
- `max_prep_time`, `max_cook_time`, `max_total_time` - Time filters
- `difficulty_level` - easy|medium|hard
- `lang` - Response language

```bash
curl "/api/v1/recipes?dietary_tags[]=vegan&max_prep_time=30&lang=ja"
```

### Get Recipe

```bash
curl "/api/v1/recipes/1?lang=ja"
```

Response includes: name, servings, timing, ingredient_groups (with items), steps (with variants), equipment, nutrition, dietary_tags, cuisines

### Scale Recipe

```bash
curl -X POST /api/v1/recipes/1/scale -d '{"servings": 8}'
```

Or scale by ingredient:
```bash
curl -X POST /api/v1/recipes/1/scale -d '{"ingredient_id": 5, "new_amount": 500}'
```

---

## Favorites (Auth Required)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/favorites` | List user's favorites |
| POST | `/favorites` | Add recipe to favorites |
| DELETE | `/favorites/:recipe_id` | Remove from favorites |

```bash
curl -H "Authorization: Bearer TOKEN" /api/v1/favorites
curl -X POST -H "Authorization: Bearer TOKEN" /api/v1/favorites -d '{"recipe_id": 1}'
curl -X DELETE -H "Authorization: Bearer TOKEN" /api/v1/favorites/1
```

---

## Notes (Auth Required)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/recipes/:recipe_id/notes` | List user's notes for recipe |
| POST | `/recipes/:recipe_id/notes` | Create note |
| PUT | `/notes/:id` | Update note |
| DELETE | `/notes/:id` | Delete note |

**Note types:** `general`, `ingredient` (requires ingredient_id), `step` (requires step_id)

```bash
curl -X POST -H "Authorization: Bearer TOKEN" /api/v1/recipes/1/notes \
  -d '{"note":{"note_type":"general","content":"Great with extra garlic"}}'
```

---

## Data References (Public)

```bash
curl "/api/v1/data_references?type=dietary_tag&lang=ja"
```

**Types:** dietary_tag, cuisine, dish_type, recipe_type

---

## Admin API

All admin endpoints require `Authorization: Bearer ADMIN_TOKEN` header.

Base path: `/admin` (no /api/v1 prefix)

### Admin Recipes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/recipes` | List all recipes (includes inactive) |
| GET | `/admin/recipes/:id` | Get recipe with admin fields |
| POST | `/admin/recipes` | Create recipe |
| PUT | `/admin/recipes/:id` | Update recipe |
| DELETE | `/admin/recipes/:id` | Delete recipe |
| POST | `/admin/recipes/:id/regenerate_translations` | Regenerate translations |
| POST | `/admin/recipes/check_duplicates` | Check for similar recipes |
| DELETE | `/admin/recipes/bulk_delete` | Delete multiple recipes |

#### List Admin Recipes

**Query params:** `page`, `per_page`, `q`, `cuisines[]`, `dietary_tag`, `max_prep_time`, `difficulty_level`

```bash
curl -H "Authorization: Bearer ADMIN_TOKEN" "/admin/recipes?cuisines[]=taiwanese&max_prep_time=60"
```

#### Create Recipe

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/recipes \
  -d '{
    "recipe": {
      "name": "Recipe Name",
      "source_language": "en",
      "servings_original": 4,
      "servings_min": 2,
      "servings_max": 8,
      "prep_minutes": 30,
      "cook_minutes": 60,
      "difficulty_level": "medium",
      "ingredient_groups_attributes": [{
        "name": "Main",
        "position": 1,
        "recipe_ingredients_attributes": [{
          "ingredient_name": "chicken",
          "amount": 500,
          "unit": "g",
          "position": 1
        }]
      }],
      "recipe_steps_attributes": [{
        "step_number": 1,
        "instruction_original": "Prep the chicken"
      }]
    }
  }'
```

#### Update Recipe

Same structure as create, with `_destroy: true` to remove nested records.

#### Regenerate Translations

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/recipes/1/regenerate_translations
```

Queues TranslateRecipeJob for all 6 non-English languages.

#### Check Duplicates

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/recipes/check_duplicates \
  -d '{"name": "Beef Noodle Soup"}'
```

Returns similar recipe names using fuzzy matching.

#### Bulk Delete

```bash
curl -X DELETE -H "Authorization: Bearer ADMIN_TOKEN" /admin/recipes/bulk_delete \
  -d '{"ids": [1, 2, 3]}'
```

### Recipe Parsing (AI)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/recipes/parse_text` | Parse recipe from text |
| POST | `/admin/recipes/parse_url` | Parse recipe from URL |

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/recipes/parse_text \
  -d '{"text": "Recipe text here..."}'

curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/recipes/parse_url \
  -d '{"url": "https://example.com/recipe"}'
```

Returns parsed recipe structure ready for review/edit before saving.

---

### Admin Data References

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/data_references` | List all (includes inactive) |
| GET | `/admin/data_references/:id` | Get single |
| POST | `/admin/data_references` | Create |
| PUT | `/admin/data_references/:id` | Update |
| DELETE | `/admin/data_references/:id` | Delete |
| POST | `/admin/data_references/:id/activate` | Activate |
| POST | `/admin/data_references/:id/deactivate` | Deactivate |

**Query params:** `type` (dietary_tag, cuisine, dish_type, recipe_type), `active` (true/false)

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/data_references \
  -d '{"data_reference":{"reference_type":"dietary_tag","key":"nut-free","display_name":"Nut Free"}}'
```

---

### AI Prompts

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/ai_prompts` | List prompts |
| GET | `/admin/ai_prompts/:id` | Get prompt |
| POST | `/admin/ai_prompts` | Create prompt |
| PUT | `/admin/ai_prompts/:id` | Update prompt |
| DELETE | `/admin/ai_prompts/:id` | Delete prompt |
| POST | `/admin/ai_prompts/:id/activate` | Set as active for type |
| POST | `/admin/ai_prompts/:id/test` | Test prompt with sample input |

**Prompt types:** recipe_parser, recipe_translator, variant_generator

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/ai_prompts \
  -d '{"ai_prompt":{"name":"Recipe Parser v2","prompt_type":"recipe_parser","prompt_text":"Parse this recipe...","model":"claude-3-opus"}}'

curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/ai_prompts/1/test \
  -d '{"input": "Sample recipe text"}'
```

---

### Ingredients

| Method | Path | Description |
|--------|------|-------------|
| GET | `/admin/ingredients` | List with search |
| GET | `/admin/ingredients/:id` | Get with nutrition |
| POST | `/admin/ingredients` | Create |
| PUT | `/admin/ingredients/:id` | Update |
| DELETE | `/admin/ingredients/:id` | Delete |
| POST | `/admin/ingredients/:id/refresh_nutrition` | Refresh nutrition from Nutritionix |

**Query params:** `q` (search name), `page`, `per_page`

```bash
curl -X POST -H "Authorization: Bearer ADMIN_TOKEN" /admin/ingredients \
  -d '{"ingredient":{"canonical_name":"chicken breast","category":"protein","aliases":["chicken","poultry"]}}'
```

---

## Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success (GET, PUT, DELETE) |
| 201 | Created (POST) |
| 400 | Bad request format |
| 401 | Missing/invalid token |
| 403 | Not authorized (not admin) |
| 404 | Resource not found |
| 422 | Validation errors |
| 500 | Server error |

**Common errors:**
- `"Unauthorized"` - No token or invalid
- `"Access denied"` - User not admin
- `"[Field] can't be blank"` - Required field missing
- `"[Field] has already been taken"` - Uniqueness violation
