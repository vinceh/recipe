# API Documentation Guide

---

## When to Update API Documentation

**CRITICAL: Update [api-reference.md](api-reference.md) when adding or modifying ANY endpoint.**

You MUST update the API documentation whenever:
- Adding a new API endpoint
- Modifying an existing endpoint (request/response format)
- Changing authentication requirements
- Adding or removing query parameters
- Changing error codes or messages
- Updating validation rules

---

## Documentation Process

### Step 1: Use the Template

Start with **[API_REFERENCE_TEMPLATE.md](../claude/API_REFERENCE_TEMPLATE.md)** for consistent formatting.

The template provides:
- Standardized format
- Best practices and guidelines
- Validation checklist
- Common mistakes to avoid

### Step 2: Document All Sections

For each endpoint, document:

1. **Endpoint path** and HTTP method
2. **Description** - What does this endpoint do?
3. **Authentication** - Required? Admin only?
4. **Request**
   - Path parameters
   - Query parameters
   - Request body (with JSON schema)
5. **Response**
   - Success response (200, 201, 204)
   - Response body structure
   - Field descriptions
6. **Error Responses**
   - All possible error codes (400, 401, 403, 404, 422, 500)
   - Error message formats
7. **Examples**
   - cURL example
   - JavaScript example (using fetch or axios)
   - TypeScript example (if applicable)

### Step 3: Test Examples

**CRITICAL: All examples MUST work.**

Before adding examples to documentation:
- [ ] Test cURL commands in terminal
- [ ] Test JavaScript code in browser console or Node.js
- [ ] Verify response formats match documentation
- [ ] Check that error scenarios are accurate

### Step 4: Add to api-reference.md

1. Find the appropriate section (Authentication, Public APIs, Admin APIs, etc.)
2. Add your endpoint in logical order
3. Update the table of contents if needed
4. Update the endpoint count

---

## Documentation Sections in api-reference.md

### 1. Authentication APIs
- Sign Up
- Sign In
- Sign Out

### 2. Public Recipe APIs
- List recipes (with filtering/search)
- Get recipe details
- Scale recipe

### 3. User Feature APIs
- Favorites (add, remove, list)
- Notes (create, list, update, delete)

### 4. Admin APIs
- Admin Recipes (CRUD, parsing, variants, translations)
- Data References (CRUD, activate/deactivate)
- AI Prompts (CRUD, activate, test)
- Ingredients (CRUD, refresh nutrition)

---

## Example API Documentation

### Template Structure

```markdown
### POST /api/v1/recipes/:id/scale

Scale a recipe to a different serving size or ingredient amount.

**Authentication:** Not required (public endpoint)

**Path Parameters:**
- `id` (UUID, required) - Recipe ID

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `new_servings` | Integer | Optional* | Target number of servings |
| `ingredient_target` | Object | Optional* | Ingredient to scale by |
| `ingredient_target.name` | String | Required** | Ingredient name |
| `ingredient_target.amount` | Decimal | Required** | Target amount |
| `ingredient_target.unit` | String | Required** | Target unit |

*One of `new_servings` or `ingredient_target` is required.
**Required if using `ingredient_target` method.

**Response (200 OK):**
```json
{
  "recipe_id": "550e8400-e29b-41d4-a716-446655440000",
  "original_servings": 4,
  "new_servings": 8,
  "scale_factor": 2.0,
  "scaled_ingredients": [
    {
      "name": "flour",
      "amount": 400,
      "unit": "g",
      "original_amount": 200
    }
  ],
  "nutrition_per_serving": {
    "calories": 250,
    "protein_g": 8.5,
    "carbs_g": 45.0,
    "fat_g": 5.2
  }
}
```

**Error Responses:**

- **404 Not Found** - Recipe not found
  ```json
  { "error": "Recipe not found" }
  ```

- **422 Unprocessable Entity** - Invalid scaling parameters
  ```json
  { "error": "Must provide either new_servings or ingredient_target" }
  ```

**Example (cURL):**
```bash
curl -X POST https://api.example.com/api/v1/recipes/550e8400-e29b-41d4-a716-446655440000/scale \
  -H "Content-Type: application/json" \
  -d '{
    "new_servings": 8
  }'
```

**Example (JavaScript):**
```javascript
const response = await fetch('/api/v1/recipes/550e8400-e29b-41d4-a716-446655440000/scale', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    new_servings: 8
  })
});

const data = await response.json();
console.log(data.scale_factor); // 2.0
```

**Related Endpoints:**
- GET /api/v1/recipes/:id - Get original recipe
- GET /api/v1/recipes - List all recipes
```

---

## Best Practices

### 1. Be Comprehensive

Document EVERY possible:
- Request parameter
- Query parameter
- Response field
- Error scenario

Don't assume developers will "figure it out."

### 2. Use Real Examples

```
**BAD:**
"Returns an array of recipes"

**GOOD:**
{
  "recipes": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Chocolate Chip Cookies",
      "servings": { "count": 24, "unit": "cookies" },
      "timing": { "prep_time": 15, "cook_time": 12, "total_time": 27 }
    }
  ],
  "total": 42,
  "page": 1,
  "per_page": 20
}
```

### 3. Document Validation Rules

Be explicit about:
- Required vs optional fields
- Data types (String, Integer, Boolean, UUID, etc.)
- Format constraints (email, URL, date)
- Min/max values
- Allowed values (enums)

Example:
```markdown
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `email` | String | Yes | Must be valid email format |
| `password` | String | Yes | Min 8 characters |
| `role` | String | No | One of: "user", "admin" |
| `preferred_language` | String | No | One of: "en", "ja", "ko", "zh-tw", "zh-cn", "es", "fr" |
```

### 4. Show Both Success and Error Cases

Always document:
- **Happy path** - What happens when everything works
- **Error cases** - What happens when it fails

### 5. Link Related Endpoints

Help developers discover related functionality:
- Recipe creation → Recipe update, Recipe delete
- Add favorite → Remove favorite, List favorites
- Create note → Update note, Delete note

### 6. Keep Examples Updated

When you modify an endpoint:
- [ ] Update request/response examples
- [ ] Update error examples
- [ ] Re-test all code snippets

---

## Common Mistakes to Avoid

### Mistake 1: Not Testing Examples

Don't copy-paste examples without testing. Broken examples frustrate developers.

### Mistake 2: Incomplete Error Documentation

Don't just document 200 OK. Document 400, 401, 403, 404, 422, 500 cases.

### Mistake 3: Vague Descriptions

```
**BAD:** "Creates a recipe"

**GOOD:** "Creates a new recipe with ingredients, steps, and metadata.
Admin only. Triggers background job to generate step variants."
```

### Mistake 4: Missing Field Descriptions

```
**BAD:**
{
  "servings": { "count": 4, "unit": "servings" }
}

**GOOD:**
| Field | Type | Description |
|-------|------|-------------|
| `servings.count` | Integer | Number of servings this recipe makes |
| `servings.unit` | String | Unit of servings (e.g., "servings", "cookies", "slices") |
```

### Mistake 5: Not Updating TOC

When adding endpoints, update the table of contents in api-reference.md.

---

## Validation Checklist

Before marking API documentation complete:

- [ ] All endpoints have descriptions
- [ ] All request parameters documented with types and constraints
- [ ] All response fields documented
- [ ] All error codes documented (400, 401, 403, 404, 422, 500)
- [ ] cURL example tested and works
- [ ] JavaScript example tested and works
- [ ] Related endpoints linked
- [ ] Table of contents updated (if new endpoint added)
- [ ] Endpoint count updated in documentation header

---

## Why API Documentation Is Critical

- **Prevents wasted time** - No need to read controller code to understand endpoints
- **Reduces errors** - Clear documentation prevents API misuse
- **Speeds up development** - Frontend can work independently
- **Improves onboarding** - New developers learn API quickly
- **Documents decisions** - Captures the "why" behind design
