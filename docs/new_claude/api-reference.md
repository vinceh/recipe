# Recipe API Reference

---

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
  - [User Registration](#user-registration)
  - [User Login](#user-login)
  - [User Logout](#user-logout)
- [Public API](#public-api)
  - [Recipes](#recipes)
    - [List Recipes](#list-recipes)
    - [Get Recipe](#get-recipe)
    - [Scale Recipe](#scale-recipe)
  - [Favorites](#favorites)
    - [Add to Favorites](#add-to-favorites)
    - [Remove from Favorites](#remove-from-favorites)
    - [List Favorites](#list-favorites)
  - [Notes](#notes)
    - [Create Note](#create-note)
    - [List Recipe Notes](#list-recipe-notes)
    - [Update Note](#update-note)
    - [Delete Note](#delete-note)
  - [Data References](#data-references-public)
    - [Get Reference Data](#get-reference-data)
- [Admin API](#admin-api)
  - [Admin Recipes](#admin-recipes)
    - [List Admin Recipes](#list-admin-recipes)
    - [Get Admin Recipe](#get-admin-recipe)
    - [Create Recipe](#create-recipe)
    - [Update Recipe](#update-recipe)
    - [Delete Recipe](#delete-recipe)
    - [Parse Recipe from Text](#parse-recipe-from-text)
    - [Parse Recipe from URL](#parse-recipe-from-url)
    - [Parse Recipe from Image](#parse-recipe-from-image)
    - [Regenerate Variants](#regenerate-variants)
    - [Regenerate Translations](#regenerate-translations)
    - [Check Duplicates](#check-duplicates)
    - [Bulk Delete Recipes](#bulk-delete-recipes)
  - [Admin Data References](#admin-data-references)
    - [List Data References](#list-data-references)
    - [Get Data Reference](#get-data-reference)
    - [Create Data Reference](#create-data-reference)
    - [Update Data Reference](#update-data-reference)
    - [Delete Data Reference](#delete-data-reference)
    - [Activate Data Reference](#activate-data-reference)
    - [Deactivate Data Reference](#deactivate-data-reference)
  - [AI Prompts](#ai-prompts)
    - [List AI Prompts](#list-ai-prompts)
    - [Get AI Prompt](#get-ai-prompt)
    - [Create AI Prompt](#create-ai-prompt)
    - [Update AI Prompt](#update-ai-prompt)
    - [Delete AI Prompt](#delete-ai-prompt)
    - [Activate AI Prompt](#activate-ai-prompt)
    - [Test AI Prompt](#test-ai-prompt)
  - [Ingredients](#ingredients)
    - [List Ingredients](#list-ingredients)
    - [Get Ingredient](#get-ingredient)
    - [Create Ingredient](#create-ingredient)
    - [Update Ingredient](#update-ingredient)
    - [Delete Ingredient](#delete-ingredient)
    - [Refresh Nutrition Data](#refresh-nutrition-data)
- [Common Response Patterns](#common-response-patterns)
- [Error Codes Reference](#error-codes-reference)

---

## Locale-Aware API Responses

All recipe-related endpoints support multi-language responses using the `?lang` query parameter or `Accept-Language` header:

**Query Parameter:**
```
GET /api/v1/recipes/1?lang=ja
```

**Header:**
```
Accept-Language: ja
```

**Supported Languages:** en, ja, ko, zh-tw, zh-cn, es, fr

**Translation Source:**
- **Recipe Content** (name, ingredient names, step instructions): From Mobility translation tables (dynamic recipe translations)
- **UI Text** (field labels, buttons, messages): From Rails i18n backend

**Fallback Chain:**
- ja → en
- ko → en  
- zh-tw → zh-cn → en
- es → en
- fr → en

**Example - Japanese Response:**
```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "name": "和風ステーキ",
      "ingredients": [
        {
          "ingredient_name": "牛肉",
          "amount": 400,
          "unit": "g"
        }
      ],
      "steps": [
        {
          "instruction_original": "牛肉をフライパンで焼く"
        }
      ]
    }
  }
}
```

If translation unavailable, falls back to English automatically.

---


## Overview

The Recipe API is a RESTful API built with Ruby on Rails that provides endpoints for managing recipes, ingredients, user favorites, notes, and administrative functions. The API follows standard REST conventions and returns JSON responses.

### Base Configuration

- **Authentication**: JWT tokens via Devise
- **Content-Type**: `application/json`
- **Supported Languages**: en, ja, ko, zh-tw, zh-cn, es, fr
- **Pagination**: Default 20 items per page, max 100

### Common Headers

**Request Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
Accept-Language: en|ja|ko|zh-tw|zh-cn|es|fr
```

**Response Headers:**
```
Content-Type: application/json
```

---

## Authentication

All authentication endpoints use Devise with JWT strategy.

### User Registration

Create a new user account.

#### HTTP Method and Path

```
POST /api/v1/auth/sign_up
```

#### Authentication

- **Required**: No
- **Type**: None
- **Role Required**: N/A

#### Description

Creates a new user account with email and password. Upon successful registration, returns user data and a JWT token in the `Authorization` response header. The JWT token should be stored and included in subsequent authenticated requests.

#### Request Body

```json
{
  "user": {
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "password_confirmation": "SecurePassword123!"
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `user.email` | String | Yes | Valid email format | User's email address |
| `user.password` | String | Yes | Min 6 characters | User's password |
| `user.password_confirmation` | String | Yes | Must match password | Password confirmation |

#### Response

##### Success (201 Created)

```json
{
  "success": true,
  "message": "Signed up successfully",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "user"
    }
  }
}
```

**Response Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | Boolean | Always true for successful responses |
| `message` | String | Success message |
| `data.user.id` | Integer | User's unique identifier |
| `data.user.email` | String | User's email address |
| `data.user.role` | String | User's role (user or admin) |

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Registration failed",
  "errors": [
    "Email has already been taken",
    "Password is too short (minimum is 6 characters)"
  ]
}
```

#### Example Requests

##### cURL

```bash
curl -X POST http://localhost:3000/api/v1/auth/sign_up \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "SecurePassword123!",
      "password_confirmation": "SecurePassword123!"
    }
  }'
```

##### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/auth/sign_up', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    user: {
      email: 'user@example.com',
      password: 'SecurePassword123!',
      password_confirmation: 'SecurePassword123!'
    }
  })
})

const data = await response.json()
const token = response.headers.get('Authorization')
```

#### Notes

- JWT token is returned in the `Authorization` response header
- Store the token securely (localStorage, sessionStorage, or secure cookie)
- Token must be included in all authenticated requests
- Default role is `user`; admin role must be assigned directly in database

---

### User Login

Authenticate existing user and obtain JWT token.

#### HTTP Method and Path

```
POST /api/v1/auth/sign_in
```

#### Authentication

- **Required**: No
- **Type**: None
- **Role Required**: N/A

#### Description

Authenticates a user with email and password credentials. Returns user data and JWT token in the `Authorization` response header upon successful authentication.

#### Request Body

```json
{
  "user": {
    "email": "user@example.com",
    "password": "SecurePassword123!"
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user.email` | String | Yes | User's email address |
| `user.password` | String | Yes | User's password |

#### Response

##### Success (200 OK)

```json
{
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "user"
    }
  }
}
```

**Response Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

##### Error Responses

**401 Unauthorized**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

#### Example Requests

##### cURL

```bash
curl -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "user@example.com",
      "password": "SecurePassword123!"
    }
  }'
```

##### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/auth/sign_in', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    user: {
      email: 'user@example.com',
      password: 'SecurePassword123!'
    }
  })
})

const data = await response.json()
const token = response.headers.get('Authorization')
// Store token for subsequent requests
localStorage.setItem('authToken', token)
```

#### Notes

- JWT token is returned in the `Authorization` response header
- Token should be stored and included in subsequent authenticated requests
- Generic error messages prevent user enumeration attacks

---

### User Logout

Invalidate JWT token and log out user.

#### HTTP Method and Path

```
DELETE /api/v1/auth/sign_out
```

#### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user

#### Description

Logs out the current user by invalidating their JWT token. The token is added to a denylist and can no longer be used for authentication.

#### Request Parameters

None. Authentication token must be provided in the `Authorization` header.

#### Response

##### Success (200 OK)

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

##### Error Responses

**401 Unauthorized**
```json
{
  "success": false,
  "message": "User not authenticated"
}
```

#### Example Requests

##### cURL

```bash
curl -X DELETE http://localhost:3000/api/v1/auth/sign_out \
  -H "Authorization: Bearer YOUR_TOKEN"
```

##### JavaScript (fetch)

```javascript
const token = localStorage.getItem('authToken')

const response = await fetch('http://localhost:3000/api/v1/auth/sign_out', {
  method: 'DELETE',
  headers: {
    'Authorization': token
  }
})

const data = await response.json()
// Clear stored token
localStorage.removeItem('authToken')
```

#### Notes

- Token is immediately invalidated and cannot be reused
- Client should remove stored token after logout
- Attempting to use token after logout will result in 401 errors

---

## Public API

### Recipes

#### List Recipes

Get a paginated list of recipes with optional filtering and search.

##### HTTP Method and Path

```
GET /api/v1/recipes
```

##### Authentication

- **Required**: No
- **Type**: None
- **Role Required**: N/A

##### Description

Returns a paginated list of recipes. Supports two search modes:

1. **Basic Search**: Simple filtering by name, dietary tags, cuisines, dish types, and time constraints
2. **Advanced Search**: Includes nutrition filtering, ingredient inclusion/exclusion, and serving size constraints

The API automatically detects which mode to use based on the parameters provided.

##### Query Parameters

**Basic Search Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | Integer | No | 1 | Page number for pagination |
| `per_page` | Integer | No | 20 | Items per page (max 100) |
| `q` | String | No | - | Search query for recipe names (case-insensitive) |
| `dietary_tags` | String | No | - | Comma-separated dietary tags (OR logic) |
| `dish_types` | String | No | - | Comma-separated dish types (OR logic) |
| `cuisines` | String | No | - | Comma-separated cuisines (OR logic) |
| `max_cook_time` | Integer | No | - | Maximum cook time in minutes |
| `max_prep_time` | Integer | No | - | Maximum prep time in minutes |
| `max_total_time` | Integer | No | - | Maximum total time in minutes |

**Advanced Search Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `ingredient` | String | No | - | Include recipes with this ingredient |
| `exclude_ingredients` | String | No | - | Exclude recipes with these ingredients (comma-separated) |
| `min_calories` | Integer | No | - | Minimum calories per serving |
| `max_calories` | Integer | No | - | Maximum calories per serving |
| `min_protein` | Integer | No | - | Minimum protein in grams |
| `max_carbs` | Integer | No | - | Maximum carbs in grams |
| `max_fat` | Integer | No | - | Maximum fat in grams |
| `min_servings` | Integer | No | - | Minimum servings |
| `max_servings` | Integer | No | - | Maximum servings |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipes": [
      {
        "id": 1,
        "name": "Taiwanese Beef Noodle Soup",
        "language": "en",
        "servings": 4,
        "timing": {
          "prep_minutes": 30,
          "cook_minutes": 150,
          "total_minutes": 180
        },
        "dietary_tags": ["gluten-free-adaptable"],
        "dish_types": ["main-course", "soup"],
        "cuisines": ["taiwanese", "chinese"],
        "source_url": "https://example.com/recipe",
        "created_at": "2025-10-09T12:00:00Z",
        "updated_at": "2025-10-09T12:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_count": 45,
      "total_pages": 3
    }
  }
}
```

##### Example Requests

###### cURL (Basic Search)

```bash
curl -X GET "http://localhost:3000/api/v1/recipes?q=soup&cuisines=taiwanese,chinese&max_total_time=240" \
  -H "Accept: application/json"
```

###### cURL (Advanced Search)

```bash
curl -X GET "http://localhost:3000/api/v1/recipes?ingredient=beef&exclude_ingredients=pork,chicken&max_calories=500" \
  -H "Accept: application/json"
```

###### JavaScript (fetch)

```javascript
const params = new URLSearchParams({
  page: 1,
  per_page: 20,
  q: 'soup',
  cuisines: 'taiwanese,chinese',
  max_total_time: 240
})

const response = await fetch(`http://localhost:3000/api/v1/recipes?${params}`)
const data = await response.json()
```

##### Notes

- Results are ordered by creation date (newest first)
- Advanced search is triggered automatically when nutrition or ingredient parameters are present
- Multiple values for dietary_tags, dish_types, and cuisines use OR logic
- Search is case-insensitive

##### Related Endpoints

- [Get Recipe](#get-recipe)
- [Scale Recipe](#scale-recipe)

---

#### Get Recipe

Get detailed information about a specific recipe.

##### HTTP Method and Path

```
GET /api/v1/recipes/:id
```

##### Authentication

- **Required**: No
- **Type**: None
- **Role Required**: N/A

##### Description

Returns complete recipe details including ingredients, steps, equipment, nutrition information, and translations.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "name": "Taiwanese Beef Noodle Soup",
      "source_language": "en",
      "servings_original": 4,
      "servings_min": 2,
      "servings_max": 8,
      "prep_minutes": 30,
      "cook_minutes": 150,
      "total_minutes": 180,
      "dietary_tags": ["gluten-free-adaptable"],
      "dish_types": ["main-course", "soup"],
      "recipe_types": ["comfort-food"],
      "cuisines": ["taiwanese", "chinese"],
      "ingredient_groups": [
        {
          "id": 1,
          "name": "Broth",
          "position": 1,
          "recipe_ingredients": [
            {
              "id": 1,
              "ingredient_name": "beef bones",
              "amount": 2.0,
              "unit": "lbs",
              "position": 1,
              "preparation_notes": "preferably with marrow",
              "optional": false
            }
          ]
        }
      ],
      "recipe_steps": [
        {
          "id": 1,
          "step_number": 1,
          "instruction_original": "Blanch beef bones in boiling water for 5 minutes",
          "instruction_easier": "Boil beef bones",
          "instruction_no_equipment": null
        }
      ],
      "equipment": ["large pot", "knife", "cutting board"],
      "nutrition": {
        "calories": 450,
        "protein_g": 35,
        "carbs_g": 45,
        "fat_g": 15,
        "fiber_g": 3,
        "sodium_mg": 800,
        "sugar_g": 2
      },
      "requires_precision": false,
      "precision_reason": null,
      "source_url": "https://example.com/recipe",
      "admin_notes": "Popular traditional recipe",
      "variants_generated": true,
      "variants_generated_at": "2025-10-09T12:00:00Z",
      "translations_completed": false,
      "created_at": "2025-10-09T12:00:00Z",
      "updated_at": "2025-10-09T12:00:00Z"
    }
  }
}
```

##### Error Responses

**404 Not Found**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

##### Example Requests

###### cURL

```bash
curl -X GET http://localhost:3000/api/v1/recipes/1 \
  -H "Accept: application/json"
```

###### JavaScript (fetch)

```javascript
const recipeId = 1
const response = await fetch(`http://localhost:3000/api/v1/recipes/${recipeId}`)
const data = await response.json()
```

##### Notes

- Returns complete recipe data including all fields
- Translations object contains recipe data in other languages
- Nutrition values are per serving
- Equipment array lists all tools needed

##### Related Endpoints

- [List Recipes](#list-recipes)
- [Scale Recipe](#scale-recipe)

---

#### Scale Recipe

Calculate scaled ingredient amounts for different serving sizes.

##### HTTP Method and Path

```
POST /api/v1/recipes/:id/scale
```

##### Authentication

- **Required**: No
- **Type**: None
- **Role Required**: N/A

##### Description

Scales recipe ingredient amounts to a new serving size. Validates that the requested serving size is within the recipe's defined min/max range and returns proportionally adjusted ingredient amounts.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Request Body

```json
{
  "servings": 6
}
```

**Field Descriptions:**

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `servings` | Integer/Float | Yes | Within recipe min/max | Desired number of servings |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "original_servings": 4,
    "new_servings": 6,
    "scale_factor": 1.5,
    "scaled_ingredient_groups": [
      {
        "name": "Broth",
        "items": [
          {
            "ingredient": "beef bones",
            "amount": "3.0",
            "unit": "lbs",
            "notes": "preferably with marrow"
          }
        ]
      }
    ]
  }
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Servings must be between 2 and 8"
}
```

**404 Not Found**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/api/v1/recipes/1/scale \
  -H "Content-Type: application/json" \
  -d '{"servings": 6}'
```

###### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/recipes/1/scale', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ servings: 6 })
})

const data = await response.json()
```

##### Notes

- Amounts are rounded to 2 decimal places
- Scale factor is calculated as: new_servings / original_servings
- Original ingredient structure is preserved
- Min/max serving constraints are enforced

##### Related Endpoints

- [Get Recipe](#get-recipe)
- [List Recipes](#list-recipes)

---

### Favorites

#### Add to Favorites

Add a recipe to the current user's favorites list.

##### HTTP Method and Path

```
POST /api/v1/recipes/:id/favorite
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user

##### Description

Adds a recipe to the current user's favorites. If the recipe is already favorited, returns success without creating a duplicate.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (201 Created or 200 OK)

```json
{
  "success": true,
  "data": {
    "favorited": true
  },
  "message": "Recipe added to favorites"
}
```

##### Error Responses

**401 Unauthorized**
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

**404 Not Found**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/api/v1/recipes/1/favorite \
  -H "Authorization: Bearer YOUR_TOKEN"
```

###### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/recipes/1/favorite', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  }
})

const data = await response.json()
```

##### Notes

- Idempotent operation - safe to call multiple times
- Returns 201 for new favorite, 200 if already favorited
- Requires user authentication

##### Related Endpoints

- [Remove from Favorites](#remove-from-favorites)
- [List Favorites](#list-favorites)

---

#### Remove from Favorites

Remove a recipe from the current user's favorites list.

##### HTTP Method and Path

```
DELETE /api/v1/recipes/:id/favorite
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user

##### Description

Removes a recipe from the current user's favorites list.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "favorited": false
  },
  "message": "Recipe removed from favorites"
}
```

##### Error Responses

**404 Not Found**
```json
{
  "success": false,
  "message": "Recipe not in favorites"
}
```

**401 Unauthorized**
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/api/v1/recipes/1/favorite \
  -H "Authorization: Bearer YOUR_TOKEN"
```

###### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/recipes/1/favorite', {
  method: 'DELETE',
  headers: {
    'Authorization': `Bearer ${token}`
  }
})

const data = await response.json()
```

##### Related Endpoints

- [Add to Favorites](#add-to-favorites)
- [List Favorites](#list-favorites)

---

#### List Favorites

Get the current user's favorite recipes.

##### HTTP Method and Path

```
GET /api/v1/users/me/favorites
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user

##### Description

Returns a paginated list of recipes that the current user has favorited, ordered by when they were favorited (most recent first).

##### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | Integer | No | 1 | Page number for pagination |
| `per_page` | Integer | No | 20 | Items per page (max 100) |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "favorites": [
      {
        "id": 1,
        "name": "Taiwanese Beef Noodle Soup",
        "language": "en",
        "servings": 4,
        "timing": {
          "prep_minutes": 30,
          "cook_minutes": 150,
          "total_minutes": 180
        },
        "dietary_tags": ["gluten-free-adaptable"],
        "dish_types": ["main-course", "soup"],
        "cuisines": ["taiwanese", "chinese"],
        "source_url": "https://example.com/recipe",
        "created_at": "2025-10-09T12:00:00Z",
        "updated_at": "2025-10-09T12:00:00Z",
        "favorited_at": "2025-10-09T14:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_count": 15,
      "total_pages": 1
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET "http://localhost:3000/api/v1/users/me/favorites?page=1&per_page=20" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

###### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/users/me/favorites', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})

const data = await response.json()
```

##### Notes

- Recipes are ordered by favorited_at timestamp (newest first)
- Each recipe includes a `favorited_at` field showing when it was added to favorites
- Returns empty array if user has no favorites

##### Related Endpoints

- [Add to Favorites](#add-to-favorites)
- [Remove from Favorites](#remove-from-favorites)

---

### Notes

#### Create Note

Create a note for a specific recipe.

##### HTTP Method and Path

```
POST /api/v1/recipes/:recipe_id/notes
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user

##### Description

Creates a note attached to a recipe. Notes can be general recipe notes, step-specific notes, or ingredient-specific notes depending on the `note_type` and `note_target_id`.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipe_id` | Integer | Yes | Recipe's unique identifier |

##### Request Body

```json
{
  "note_type": "step",
  "note_target_id": "3",
  "note_text": "Use low heat to prevent burning"
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `note_type` | String | Yes | Type of note: "recipe", "step", or "ingredient" |
| `note_target_id` | String | No | ID of specific step/ingredient (null for recipe notes) |
| `note_text` | String | Yes | The note content |

##### Response

###### Success (201 Created)

```json
{
  "success": true,
  "data": {
    "note": {
      "id": 1,
      "recipe_id": 1,
      "note_type": "step",
      "note_target_id": "3",
      "note_text": "Use low heat to prevent burning",
      "created_at": "2025-10-09T14:30:00Z",
      "updated_at": "2025-10-09T14:30:00Z"
    }
  },
  "message": "Note created successfully"
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to create note",
  "errors": ["Note text can't be blank"]
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/api/v1/recipes/1/notes \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "note_type": "step",
    "note_target_id": "3",
    "note_text": "Use low heat to prevent burning"
  }'
```

###### JavaScript (fetch)

```javascript
const response = await fetch('http://localhost:3000/api/v1/recipes/1/notes', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    note_type: 'step',
    note_target_id: '3',
    note_text: 'Use low heat to prevent burning'
  })
})

const data = await response.json()
```

##### Notes

- Notes are user-specific and private
- `note_target_id` should be null for general recipe notes
- For step notes, `note_target_id` is the step number
- For ingredient notes, `note_target_id` is the ingredient identifier

##### Related Endpoints

- [List Recipe Notes](#list-recipe-notes)
- [Update Note](#update-note)
- [Delete Note](#delete-note)

---

#### List Recipe Notes

Get all notes for a recipe (current user only).

##### HTTP Method and Path

```
GET /api/v1/recipes/:recipe_id/notes
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user

##### Description

Returns all notes created by the current user for a specific recipe, ordered by creation date (newest first).

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipe_id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "notes": [
      {
        "id": 1,
        "recipe_id": 1,
        "note_type": "step",
        "note_target_id": "3",
        "note_text": "Use low heat to prevent burning",
        "created_at": "2025-10-09T14:30:00Z",
        "updated_at": "2025-10-09T14:30:00Z"
      }
    ]
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET http://localhost:3000/api/v1/recipes/1/notes \
  -H "Authorization: Bearer YOUR_TOKEN"
```

##### Related Endpoints

- [Create Note](#create-note)
- [Update Note](#update-note)
- [Delete Note](#delete-note)

---

#### Update Note

Update an existing note.

##### HTTP Method and Path

```
PUT /api/v1/notes/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user (note owner only)

##### Description

Updates the text content of an existing note. Users can only update their own notes.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Note's unique identifier |

##### Request Body

```json
{
  "note_text": "Updated note content"
}
```

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "note": {
      "id": 1,
      "recipe_id": 1,
      "note_type": "step",
      "note_target_id": "3",
      "note_text": "Updated note content",
      "created_at": "2025-10-09T14:30:00Z",
      "updated_at": "2025-10-09T15:00:00Z"
    }
  },
  "message": "Note updated successfully"
}
```

##### Error Responses

**404 Not Found**
```json
{
  "success": false,
  "message": "Note not found or you do not have permission to modify it"
}
```

##### Example Requests

###### cURL

```bash
curl -X PUT http://localhost:3000/api/v1/notes/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"note_text": "Updated note content"}'
```

##### Related Endpoints

- [Create Note](#create-note)
- [List Recipe Notes](#list-recipe-notes)
- [Delete Note](#delete-note)

---

#### Delete Note

Delete a note.

##### HTTP Method and Path

```
DELETE /api/v1/notes/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Any authenticated user (note owner only)

##### Description

Permanently deletes a note. Users can only delete their own notes.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Note's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "deleted": true
  },
  "message": "Note deleted successfully"
}
```

##### Error Responses

**404 Not Found**
```json
{
  "success": false,
  "message": "Note not found or you do not have permission to modify it"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/api/v1/notes/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

##### Related Endpoints

- [Create Note](#create-note)
- [List Recipe Notes](#list-recipe-notes)
- [Update Note](#update-note)

---

### Data References (Public)

#### Get Reference Data

Get all active reference data for dropdown/filter options.

##### HTTP Method and Path

```
GET /api/v1/data_references
```

##### Authentication

- **Required**: No
- **Type**: None
- **Role Required**: N/A

##### Description

Returns all active reference data including dietary tags, dish types, recipe types, and cuisines. This data is used to populate filters, dropdowns, and tags throughout the application.

##### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `category` | String | No | Filter by specific category: dietary_tags, dish_types, recipe_types, or cuisines |

##### Response

###### Success (200 OK) - All Categories

```json
{
  "success": true,
  "data": {
    "dietary_tags": [
      { "key": "vegetarian", "display_name": "Vegetarian" },
      { "key": "vegan", "display_name": "Vegan" }
    ],
    "dish_types": [
      { "key": "main-course", "display_name": "Main Course" },
      { "key": "dessert", "display_name": "Dessert" }
    ],
    "recipe_types": [
      { "key": "comfort-food", "display_name": "Comfort Food" }
    ],
    "cuisines": [
      { "key": "italian", "display_name": "Italian" },
      { "key": "japanese", "display_name": "Japanese" }
    ]
  }
}
```

###### Success (200 OK) - Single Category

```json
{
  "success": true,
  "data": {
    "dietary_tags": [
      { "key": "vegetarian", "display_name": "Vegetarian" },
      { "key": "vegan", "display_name": "Vegan" }
    ]
  }
}
```

##### Error Responses

**400 Bad Request**
```json
{
  "success": false,
  "message": "Invalid category. Valid categories: dietary_tags, dish_types, recipe_types, cuisines"
}
```

##### Example Requests

###### cURL (All Categories)

```bash
curl -X GET http://localhost:3000/api/v1/data_references
```

###### cURL (Single Category)

```bash
curl -X GET http://localhost:3000/api/v1/data_references?category=dietary_tags
```

###### JavaScript (fetch)

```javascript
// Get all reference data
const response = await fetch('http://localhost:3000/api/v1/data_references')
const data = await response.json()

// Get specific category
const dietaryResponse = await fetch('http://localhost:3000/api/v1/data_references?category=dietary_tags')
const dietaryData = await dietaryResponse.json()
```

##### Notes

- Only returns active reference data
- Keys are used internally and in API requests
- Display names are for UI presentation
- Reference data is cached and updated infrequently

##### Related Endpoints

- [List Data References (Admin)](#list-data-references)

---

## Admin API

All admin endpoints require authentication with admin role.

### Admin Recipes

#### List Admin Recipes

Get a paginated list of all recipes with admin-specific filters.

##### HTTP Method and Path

```
GET /admin/recipes
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Returns a paginated list of all recipes with admin metadata. Supports advanced filtering including inactive recipes, admin notes, and more granular search options.

##### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | Integer | No | 1 | Page number for pagination |
| `per_page` | Integer | No | 20 | Items per page (max 100) |
| `q` | String | No | - | Search by recipe name (case-insensitive) |
| `cuisines` | Array | No | - | Filter by multiple cuisines (AND logic) |
| `cuisine` | String | No | - | Legacy: Filter by single cuisine |
| `dish_types` | Array | No | - | Filter by multiple dish types (AND logic) |
| `dietary_tag` | String | No | - | Filter by single dietary tag |
| `max_prep_time` | Integer | No | - | Maximum prep time in minutes |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipes": [
      {
        "id": 1,
        "name": "Taiwanese Beef Noodle Soup",
        "language": "en",
        "servings": {
          "original": 4,
          "min": 2,
          "max": 8
        },
        "timing": {
          "prep_minutes": 30,
          "cook_minutes": 150,
          "total_minutes": 180
        },
        "dietary_tags": ["gluten-free-adaptable"],
        "dish_types": ["main-course", "soup"],
        "recipe_types": ["comfort-food"],
        "cuisines": ["taiwanese", "chinese"],
        "aliases": ["牛肉麺", "Niu Rou Mian"],
        "source_url": "https://example.com/recipe",
        "admin_notes": "Popular recipe, gets good engagement",
        "requires_precision": false,
        "precision_reason": null,
        "variants_generated": true,
        "variants_generated_at": "2025-10-08T10:00:00Z",
        "translations_completed": true,
        "created_at": "2025-10-09T12:00:00Z",
        "updated_at": "2025-10-09T12:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_count": 45,
      "total_pages": 3
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET "http://localhost:3000/admin/recipes?cuisines[]=taiwanese&max_prep_time=60" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Returns all recipes including inactive ones (unlike public API)
- Includes admin-specific fields: admin_notes, variants_generated, translations_completed
- Multiple cuisines/dish_types use AND logic (recipe must have all specified)
- Results ordered by creation date (newest first)

##### Related Endpoints

- [Get Admin Recipe](#get-admin-recipe)
- [Create Recipe](#create-recipe)
- [Update Recipe](#update-recipe)

---

#### Get Admin Recipe

Get complete recipe details with admin metadata.

##### HTTP Method and Path

```
GET /admin/recipes/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Returns complete recipe information including all fields, translations, and admin metadata.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "name": "Taiwanese Beef Noodle Soup",
      "language": "en",
      "servings": {
        "original": 4,
        "min": 2,
        "max": 8
      },
      "timing": {
        "prep_minutes": 30,
        "cook_minutes": 150,
        "total_minutes": 180
      },
      "dietary_tags": ["gluten-free-adaptable"],
      "dish_types": ["main-course", "soup"],
      "recipe_types": ["comfort-food"],
      "cuisines": ["taiwanese", "chinese"],
      "aliases": ["牛肉麺", "Niu Rou Mian"],
      "source_url": "https://example.com/recipe",
      "admin_notes": "Popular recipe, gets good engagement",
      "requires_precision": false,
      "precision_reason": null,
      "variants_generated": true,
      "variants_generated_at": "2025-10-08T10:00:00Z",
      "translations_completed": true,
      "created_at": "2025-10-09T12:00:00Z",
      "updated_at": "2025-10-09T12:00:00Z",
      "ingredient_groups": [],
      "steps": [],
      "equipment": [],
      "nutrition": {},
      "translations": {}
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET http://localhost:3000/admin/recipes/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Related Endpoints

- [List Admin Recipes](#list-admin-recipes)
- [Update Recipe](#update-recipe)

---

#### Create Recipe

Manually create a new recipe (AC-ADMIN-001).

##### HTTP Method and Path

```
POST /admin/recipes
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Creates a new recipe manually. This is used for recipes that are created from scratch rather than parsed from external sources.

##### Request Body

```json
{
  "recipe": {
    "name": "Taiwanese Beef Noodle Soup",
    "source_language": "en",
    "requires_precision": false,
    "precision_reason": null,
    "source_url": "https://example.com/recipe",
    "admin_notes": "Popular traditional recipe",
    "servings_original": 4,
    "servings_min": 2,
    "servings_max": 8,
    "prep_minutes": 30,
    "cook_minutes": 150,
    "total_minutes": 180,
    "ingredient_groups_attributes": [
      {
        "name": "Broth",
        "position": 1,
        "recipe_ingredients_attributes": [
          {
            "ingredient_name": "beef bones",
            "amount": 2.0,
            "unit": "lbs",
            "position": 1,
            "preparation_notes": "preferably with marrow",
            "optional": false
          }
        ]
      }
    ],
    "recipe_steps_attributes": [
      {
        "step_number": 1,
        "instruction_original": "Blanch beef bones in boiling water for 5 minutes",
        "instruction_easier": "Boil beef bones",
        "instruction_no_equipment": null
      }
    ],
    "recipe_nutrition_attributes": {
      "calories": 450,
      "protein_g": 35,
      "carbs_g": 45,
      "fat_g": 15,
      "fiber_g": 3,
      "sodium_mg": 800,
      "sugar_g": 2
    },
    "recipe_aliases_attributes": [
      {"alias_name": "牛肉麺", "language": "zh-tw"},
      {"alias_name": "Niu Rou Mian", "language": "en"}
    ],
    "recipe_dietary_tags_attributes": [
      {"data_reference_id": 1}
    ],
    "recipe_dish_types_attributes": [
      {"data_reference_id": 2}
    ],
    "recipe_cuisines_attributes": [
      {"data_reference_id": 3}
    ],
    "recipe_recipe_types_attributes": [
      {"data_reference_id": 4}
    ],
    "recipe_equipment_attributes": [
      {"equipment_id": 1, "optional": false}
    ]
  }
}
```

##### Response

###### Success (201 Created)

```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "name": "Taiwanese Beef Noodle Soup",
      "language": "en"
    }
  },
  "message": "Recipe created successfully"
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to create recipe",
  "errors": ["Name can't be blank"]
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/recipes \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "recipe": {
      "name": "Taiwanese Beef Noodle Soup",
      "language": "en"
    }
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-001
- Minimum required fields: name, source_language
- Servings and timing are now normalized columns (servings_original, servings_min, servings_max, prep_minutes, cook_minutes, total_minutes)
- Nested attributes use Rails accepts_nested_attributes_for: ingredient_groups_attributes, recipe_steps_attributes, recipe_nutrition_attributes, etc.
- Use _destroy: true flag to delete nested records during updates
- DataReference arrays (dietary_tags, dish_types, cuisines, recipe_types) reference data_reference_id

##### Related Endpoints

- [Update Recipe](#update-recipe)
- [Parse Recipe from Text](#parse-recipe-from-text)

---

#### Update Recipe

Update an existing recipe.

##### HTTP Method and Path

```
PUT /admin/recipes/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Updates an existing recipe. All fields are optional; only provided fields will be updated.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Request Body

Same structure as Create Recipe. All fields are optional.

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "name": "Updated Recipe Name"
    }
  },
  "message": "Recipe updated successfully"
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to update recipe",
  "errors": ["Name can't be blank"]
}
```

**404 Not Found**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

##### Example Requests

###### cURL

```bash
curl -X PUT http://localhost:3000/admin/recipes/1 \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "recipe": {
      "admin_notes": "Updated notes"
    }
  }'
```

##### Related Endpoints

- [Get Admin Recipe](#get-admin-recipe)
- [Create Recipe](#create-recipe)

---

#### Delete Recipe

Permanently delete a recipe.

##### HTTP Method and Path

```
DELETE /admin/recipes/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Permanently deletes a recipe and all associated data. This action cannot be undone.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "deleted": true
  },
  "message": "Recipe deleted successfully"
}
```

##### Error Responses

**404 Not Found**
```json
{
  "success": false,
  "message": "Recipe not found"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/admin/recipes/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- This is a destructive operation and cannot be undone
- Consider using bulk delete for multiple recipes

##### Related Endpoints

- [Bulk Delete Recipes](#bulk-delete-recipes)

---

#### Parse Recipe from Text

Parse recipe data from a text block (AC-ADMIN-002).

##### HTTP Method and Path

```
POST /admin/recipes/parse_text
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Parses a recipe from unstructured text using AI. The text can be in various formats (ingredient lists, instructions, etc.). Returns structured recipe data that can be reviewed and saved.

##### Request Body

```json
{
  "text_content": "Taiwanese Beef Noodle Soup\n\nIngredients:\n- 2 lbs beef bones\n- 1 lb beef shank\n\nInstructions:\n1. Blanch bones..."
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `text_content` | String | Yes | Unstructured recipe text to parse |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe_data": {
      "name": "Taiwanese Beef Noodle Soup",
      "ingredient_groups": [],
      "steps": [],
      "timing": {},
      "servings": {}
    }
  },
  "message": "Recipe parsed successfully"
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to parse recipe from text",
  "errors": ["Could not extract valid recipe data"]
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/recipes/parse_text \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "text_content": "Taiwanese Beef Noodle Soup..."
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-002
- Uses RecipeParserService with AI
- Returns structured data for review before saving
- May not extract all fields accurately; review required

##### Related Endpoints

- [Parse Recipe from URL](#parse-recipe-from-url)
- [Parse Recipe from Image](#parse-recipe-from-image)
- [Create Recipe](#create-recipe)

---

#### Parse Recipe from URL

Parse recipe data from a URL (AC-ADMIN-003).

##### HTTP Method and Path

```
POST /admin/recipes/parse_url
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Fetches and parses a recipe from a URL. Supports various recipe websites and formats. Returns structured recipe data for review.

##### Request Body

```json
{
  "url": "https://example.com/recipes/beef-noodle-soup"
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | String | Yes | URL of the recipe to parse |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe_data": {
      "name": "Taiwanese Beef Noodle Soup",
      "source_url": "https://example.com/recipes/beef-noodle-soup",
      "ingredient_groups": [],
      "steps": []
    }
  },
  "message": "Recipe parsed successfully from URL"
}
```

##### Error Responses

**500 Internal Server Error**
```json
{
  "success": false,
  "message": "Failed to fetch or parse URL",
  "errors": ["Connection timeout"]
}
```

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to parse recipe from URL",
  "errors": ["Could not extract valid recipe data"]
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/recipes/parse_url \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/recipes/beef-noodle-soup"
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-003, AC-ADMIN-003-A, AC-ADMIN-003-B
- Uses RecipeParserService with two-tier approach:
  1. **Primary**: AI direct access (Claude fetches URL directly)
  2. **Fallback**: Web scraping with Nokogiri if AI cannot access
- Automatically includes source_url in parsed data
- Review parsed data before saving as accuracy varies by source
- Typical processing time: 10-30 seconds depending on method used

##### Related Endpoints

- [Parse Recipe from Text](#parse-recipe-from-text)
- [Parse Recipe from Image](#parse-recipe-from-image)

---

#### Parse Recipe from Image

Parse recipe data from an image (AC-ADMIN-004).

##### HTTP Method and Path

```
POST /admin/recipes/parse_image
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Parses a recipe from an image using OCR and AI. Supports both file uploads and image URLs.

##### Request Parameters

**Option 1: File Upload**

Send multipart/form-data with `image_file` parameter.

**Option 2: Image URL**

```json
{
  "image_url": "https://example.com/recipe-image.jpg"
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image_file` | File | No* | Image file to parse (* required if image_url not provided) |
| `image_url` | String | No* | URL to image (* required if image_file not provided) |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe_data": {
      "name": "Taiwanese Beef Noodle Soup",
      "ingredient_groups": [],
      "steps": []
    }
  },
  "message": "Recipe parsed successfully from image"
}
```

##### Error Responses

**400 Bad Request**
```json
{
  "success": false,
  "message": "Image file or URL required",
  "errors": ["Provide either image_file or image_url parameter"]
}
```

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to parse recipe from image",
  "errors": ["Could not extract valid recipe data"]
}
```

##### Example Requests

###### cURL (File Upload)

```bash
curl -X POST http://localhost:3000/admin/recipes/parse_image \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -F "image_file=@/path/to/recipe.jpg"
```

###### cURL (Image URL)

```bash
curl -X POST http://localhost:3000/admin/recipes/parse_image \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/recipe-image.jpg"
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-004
- Uses RecipeParserService with OCR and AI
- Temporary files are cleaned up after processing
- Image quality significantly affects parsing accuracy
- Review parsed data carefully before saving

##### Related Endpoints

- [Parse Recipe from Text](#parse-recipe-from-text)
- [Parse Recipe from URL](#parse-recipe-from-url)

---

#### Regenerate Variants

Regenerate easier/no-equipment step variants (AC-ADMIN-007).

##### HTTP Method and Path

```
POST /admin/recipes/:id/regenerate_variants
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Queues regeneration of recipe step variants including easier versions and no-equipment alternatives.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "variants_generated": true,
      "variants_generated_at": "2025-10-09T15:00:00Z"
    }
  },
  "message": "Step variants regeneration queued"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/recipes/1/regenerate_variants \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Acceptance Criteria: AC-ADMIN-007
- Currently marks as queued; actual generation service to be implemented
- Variants include easier methods and equipment-free alternatives

##### Related Endpoints

- [Regenerate Translations](#regenerate-translations)

---

#### Regenerate Translations

Regenerate recipe translations (AC-ADMIN-008).

##### HTTP Method and Path

```
POST /admin/recipes/:id/regenerate_translations
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Manually triggers translation regeneration for a recipe, bypassing rate limiting and deduplication.

**Behavior:**
- Bypasses rate limiting (4 translations per hour)
- Bypasses deduplication (does not check for existing jobs)
- Directly enqueues `TranslateRecipeJob.perform_later(recipe.id)`
- Always enqueues immediately

**Use case:** Manual rerun when translations need regeneration

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Recipe's unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "recipe": {
      "id": 1,
      "translations_completed": false
    }
  },
  "message": "Translation regeneration queued"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/recipes/1/regenerate_translations \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Acceptance Criteria: AC-ADMIN-008, AC-PHASE5-MANUAL-001, AC-PHASE5-MANUAL-002
- Bypasses auto-triggered translation constraints (rate limiting, deduplication)
- Enqueues job immediately regardless of recent translation history

##### Related Endpoints

- [Regenerate Variants](#regenerate-variants)

---

#### Check Duplicates

Check for duplicate recipes by name and aliases (AC-ADMIN-005, AC-ADMIN-006).

##### HTTP Method and Path

```
POST /admin/recipes/check_duplicates
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Searches for existing recipes that might be duplicates based on fuzzy name matching and exact alias matching. Useful before creating a new recipe.

##### Request Body

```json
{
  "name": "Taiwanese Beef Noodle Soup",
  "aliases": ["牛肉麺", "Niu Rou Mian"]
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | Recipe name to check |
| `aliases` | Array<String> | No | Alternative names to check |

##### Response

###### Success (200 OK) - Duplicates Found

```json
{
  "success": true,
  "data": {
    "has_duplicates": true,
    "similar_recipes": [
      {
        "id": 5,
        "name": "Taiwan Beef Noodle Soup",
        "aliases": ["牛肉麺"],
        "created_at": "2025-10-01T10:00:00Z"
      }
    ]
  }
}
```

###### Success (200 OK) - No Duplicates

```json
{
  "success": true,
  "data": {
    "has_duplicates": false,
    "similar_recipes": []
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/recipes/check_duplicates \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Taiwanese Beef Noodle Soup",
    "aliases": ["牛肉麺", "Niu Rou Mian"]
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-005, AC-ADMIN-006
- Uses fuzzy matching with 85% similarity threshold for names
- Uses exact matching for aliases
- Returns all matches found by either method

##### Related Endpoints

- [Create Recipe](#create-recipe)

---

#### Bulk Delete Recipes

Delete multiple recipes at once (AC-ADMIN-009).

##### HTTP Method and Path

```
DELETE /admin/recipes/bulk_delete
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Permanently deletes multiple recipes in a single operation. This action cannot be undone.

##### Request Body

```json
{
  "recipe_ids": [1, 2, 3, 4, 5]
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `recipe_ids` | Array<Integer> | Yes | Array of recipe IDs to delete |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "deleted_count": 5
  },
  "message": "5 recipe(s) deleted successfully"
}
```

##### Error Responses

**400 Bad Request**
```json
{
  "success": false,
  "message": "recipe_ids must be an array"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/admin/recipes/bulk_delete \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "recipe_ids": [1, 2, 3, 4, 5]
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-009
- This is a destructive operation and cannot be undone
- Returns count of actually deleted recipes
- Non-existent IDs are silently ignored

##### Related Endpoints

- [Delete Recipe](#delete-recipe)

---

### Admin Data References

#### List Data References

Get all data references with optional filtering.

##### HTTP Method and Path

```
GET /admin/data_references
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Returns all data references (dietary tags, cuisines, dish types, etc.) with admin metadata including inactive entries.

##### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reference_type` | String | No | Filter by type: dietary_tag, dish_type, recipe_type, cuisine, unit |
| `active` | String | No | Filter by active status: "true" or "false" |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "data_references": [
      {
        "id": 1,
        "reference_type": "dietary_tag",
        "key": "vegetarian",
        "display_name": "Vegetarian",
        "active": true,
        "sort_order": 1,
        "metadata": {
          "icon": "leaf",
          "color": "green"
        },
        "created_at": "2025-10-09T12:00:00Z",
        "updated_at": "2025-10-09T12:00:00Z"
      }
    ]
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET "http://localhost:3000/admin/data_references?reference_type=dietary_tag&active=true" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Returns both active and inactive references (unlike public API)
- Results ordered by reference_type then key
- Metadata field contains type-specific additional information

##### Related Endpoints

- [Create Data Reference](#create-data-reference)
- [Update Data Reference](#update-data-reference)

---

#### Get Data Reference

Get a single data reference.

##### HTTP Method and Path

```
GET /admin/data_references/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Data reference unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "data_reference": {
      "id": 1,
      "reference_type": "dietary_tag",
      "key": "vegetarian",
      "display_name": "Vegetarian",
      "active": true,
      "sort_order": 1,
      "metadata": {},
      "created_at": "2025-10-09T12:00:00Z",
      "updated_at": "2025-10-09T12:00:00Z"
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET http://localhost:3000/admin/data_references/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

#### Create Data Reference

Create a new data reference.

##### HTTP Method and Path

```
POST /admin/data_references
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Request Body

```json
{
  "data_reference": {
    "reference_type": "dietary_tag",
    "key": "keto",
    "display_name": "Keto Friendly",
    "active": true,
    "sort_order": 10,
    "metadata": {
      "icon": "bolt",
      "color": "purple"
    }
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reference_type` | String | Yes | Type: dietary_tag, dish_type, recipe_type, cuisine, unit |
| `key` | String | Yes | Unique key (lowercase, hyphenated) |
| `display_name` | String | Yes | Human-readable name |
| `active` | Boolean | No | Whether active (default: true) |
| `sort_order` | Integer | No | Display order (default: 0) |
| `metadata` | Object | No | Additional type-specific data |

##### Response

###### Success (201 Created)

```json
{
  "success": true,
  "data": {
    "data_reference": {
      "id": 25,
      "reference_type": "dietary_tag",
      "key": "keto"
    }
  },
  "message": "Data reference created successfully"
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "Failed to create data reference",
  "errors": ["Key has already been taken"]
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/data_references \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "data_reference": {
      "reference_type": "dietary_tag",
      "key": "keto",
      "display_name": "Keto Friendly"
    }
  }'
```

##### Notes

- Key must be unique within the system
- Keys should be lowercase with hyphens
- Metadata structure varies by reference_type

---

#### Update Data Reference

Update an existing data reference (AC-ADMIN-012).

##### HTTP Method and Path

```
PUT /admin/data_references/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Updates a data reference. Changes cascade to all recipes using this reference.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Data reference unique identifier |

##### Request Body

Same structure as Create Data Reference. All fields optional.

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "data_reference": {
      "id": 1,
      "display_name": "Updated Name"
    }
  },
  "message": "Data reference updated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X PUT http://localhost:3000/admin/data_references/1 \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "data_reference": {
      "display_name": "Updated Name"
    }
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-012
- Changes to key or display_name affect all recipes using this reference
- Consider checking recipe usage before major changes

---

#### Delete Data Reference

Permanently delete a data reference.

##### HTTP Method and Path

```
DELETE /admin/data_references/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "deleted": true
  },
  "message": "Data reference deleted successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/admin/data_references/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Consider deactivating instead of deleting
- Deletion may affect existing recipes using this reference

---

#### Activate Data Reference

Activate a deactivated data reference.

##### HTTP Method and Path

```
POST /admin/data_references/:id/activate
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Data reference unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "data_reference": {
      "id": 1,
      "active": true
    }
  },
  "message": "Data reference activated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/data_references/1/activate \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Related Endpoints

- [Deactivate Data Reference](#deactivate-data-reference)

---

#### Deactivate Data Reference

Deactivate a data reference (AC-ADMIN-013).

##### HTTP Method and Path

```
POST /admin/data_references/:id/deactivate
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Deactivates a data reference. Inactive references are hidden from public API but existing recipe associations remain.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Data reference unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "data_reference": {
      "id": 1,
      "active": false
    }
  },
  "message": "Data reference deactivated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/data_references/1/deactivate \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Acceptance Criteria: AC-ADMIN-013
- Deactivated references don't appear in public API
- Existing recipe associations are preserved
- Can be reactivated later

##### Related Endpoints

- [Activate Data Reference](#activate-data-reference)

---

### AI Prompts

#### List AI Prompts

Get all AI prompts with optional filtering.

##### HTTP Method and Path

```
GET /admin/ai_prompts
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Returns all AI prompts used throughout the system for various features.

##### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt_type` | String | No | Filter by type: system or user |
| `active` | String | No | Filter by active status: "true" or "false" |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ai_prompts": [
      {
        "id": 1,
        "prompt_key": "recipe_translation_system",
        "prompt_type": "system",
        "feature_area": "translation",
        "prompt_text": "You are a professional recipe translator...",
        "description": "System prompt for recipe translation",
        "active": true,
        "version": "1.0",
        "variables": ["target_language", "source_language"],
        "created_at": "2025-10-09T12:00:00Z",
        "updated_at": "2025-10-09T12:00:00Z"
      }
    ]
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET "http://localhost:3000/admin/ai_prompts?prompt_type=system&active=true" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Results ordered by creation date (newest first)
- Variables array lists placeholders used in prompt_text
- Only one prompt per feature_area should be active at a time

##### Related Endpoints

- [Create AI Prompt](#create-ai-prompt)
- [Test AI Prompt](#test-ai-prompt)

---

#### Get AI Prompt

Get a single AI prompt.

##### HTTP Method and Path

```
GET /admin/ai_prompts/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | AI prompt unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ai_prompt": {
      "id": 1,
      "prompt_key": "recipe_translation_system",
      "prompt_type": "system",
      "feature_area": "translation",
      "prompt_text": "You are a professional recipe translator...",
      "description": "System prompt for recipe translation",
      "active": true,
      "version": "1.0",
      "variables": ["target_language", "source_language"],
      "created_at": "2025-10-09T12:00:00Z",
      "updated_at": "2025-10-09T12:00:00Z"
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET http://localhost:3000/admin/ai_prompts/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

#### Create AI Prompt

Create a new AI prompt (AC-ADMIN-014).

##### HTTP Method and Path

```
POST /admin/ai_prompts
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Request Body

```json
{
  "ai_prompt": {
    "prompt_key": "recipe_translation_user",
    "prompt_type": "user",
    "feature_area": "translation",
    "prompt_text": "Translate this recipe to {{target_language}}:\n\n{{recipe_content}}",
    "description": "User prompt for translating recipes",
    "active": false,
    "version": "1.0",
    "variables": ["target_language", "recipe_content"]
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `prompt_key` | String | Yes | Unique identifier for the prompt |
| `prompt_type` | String | Yes | Type: system or user |
| `feature_area` | String | Yes | Feature: translation, recipe_parsing, step_variants, etc. |
| `prompt_text` | String | Yes | The prompt template with {{variable}} placeholders |
| `description` | String | No | Human-readable description |
| `active` | Boolean | No | Whether active (default: false) |
| `version` | String | No | Version string |
| `variables` | Array<String> | No | List of variables used in prompt_text |

##### Response

###### Success (201 Created)

```json
{
  "success": true,
  "data": {
    "ai_prompt": {
      "id": 5,
      "prompt_key": "recipe_translation_user"
    }
  },
  "message": "AI prompt created successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/ai_prompts \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ai_prompt": {
      "prompt_key": "new_prompt",
      "prompt_type": "system",
      "feature_area": "translation",
      "prompt_text": "You are a translator..."
    }
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-014
- Use `{{variable_name}}` format for placeholders
- New prompts default to inactive
- Use activate endpoint to enable

##### Related Endpoints

- [Activate AI Prompt](#activate-ai-prompt)
- [Test AI Prompt](#test-ai-prompt)

---

#### Update AI Prompt

Update an existing AI prompt.

##### HTTP Method and Path

```
PUT /admin/ai_prompts/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | AI prompt unique identifier |

##### Request Body

Same structure as Create AI Prompt. All fields optional.

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ai_prompt": {
      "id": 1,
      "prompt_text": "Updated prompt text"
    }
  },
  "message": "AI prompt updated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X PUT http://localhost:3000/admin/ai_prompts/1 \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ai_prompt": {
      "prompt_text": "Updated prompt text"
    }
  }'
```

---

#### Delete AI Prompt

Permanently delete an AI prompt.

##### HTTP Method and Path

```
DELETE /admin/ai_prompts/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "deleted": true
  },
  "message": "AI prompt deleted successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/admin/ai_prompts/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

#### Activate AI Prompt

Activate an AI prompt and deactivate others of same type.

##### HTTP Method and Path

```
POST /admin/ai_prompts/:id/activate
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Activates the specified prompt and automatically deactivates all other prompts of the same `prompt_type`. Ensures only one prompt per type is active.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | AI prompt unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ai_prompt": {
      "id": 1,
      "active": true
    }
  },
  "message": "AI prompt activated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/ai_prompts/1/activate \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Automatically deactivates other prompts of same prompt_type
- Only one prompt per type should be active

##### Related Endpoints

- [Create AI Prompt](#create-ai-prompt)
- [Test AI Prompt](#test-ai-prompt)

---

#### Test AI Prompt

Test an AI prompt with sample variables (AC-ADMIN-015).

##### HTTP Method and Path

```
POST /admin/ai_prompts/:id/test
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Tests an AI prompt by rendering it with provided test variables. Returns both the original template and the rendered version.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | AI prompt unique identifier |

##### Request Body

```json
{
  "test_variables": {
    "target_language": "Japanese",
    "recipe_content": "Taiwanese Beef Noodle Soup..."
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `test_variables` | Object | No | Key-value pairs for prompt variables |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "original_content": "Translate to {{target_language}}:\n\n{{recipe_content}}",
    "test_content": "Translate to Japanese:\n\nTaiwanese Beef Noodle Soup...",
    "variables_used": {
      "target_language": "Japanese",
      "recipe_content": "Taiwanese Beef Noodle Soup..."
    }
  },
  "message": "Prompt test generated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/ai_prompts/1/test \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "test_variables": {
      "target_language": "Japanese",
      "recipe_content": "Test content"
    }
  }'
```

##### Notes

- Acceptance Criteria: AC-ADMIN-015
- Variables use `{{variable_name}}` format
- Helps verify prompt rendering before activation
- Missing variables remain as placeholders in output

##### Related Endpoints

- [Create AI Prompt](#create-ai-prompt)
- [Activate AI Prompt](#activate-ai-prompt)

---

### Ingredients

#### List Ingredients

Get a paginated list of ingredients with optional filtering.

##### HTTP Method and Path

```
GET /admin/ingredients
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Returns a paginated list of ingredients with their basic information and summary of nutrition/alias data.

##### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | Integer | No | 1 | Page number for pagination |
| `per_page` | Integer | No | 50 | Items per page (max 100) |
| `category` | String | No | - | Filter by ingredient category |
| `q` | String | No | - | Search by canonical name (case-insensitive) |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ingredients": [
      {
        "id": 1,
        "canonical_name": "beef shank",
        "category": "meat",
        "has_nutrition": true,
        "aliases_count": 3,
        "created_at": "2025-10-09T12:00:00Z",
        "updated_at": "2025-10-09T12:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 50,
      "total_count": 150,
      "total_pages": 3
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET "http://localhost:3000/admin/ingredients?category=meat&q=beef" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Results ordered alphabetically by canonical_name
- has_nutrition indicates if nutrition data exists
- aliases_count shows number of alternative names

##### Related Endpoints

- [Get Ingredient](#get-ingredient)
- [Create Ingredient](#create-ingredient)

---

#### Get Ingredient

Get detailed information about an ingredient.

##### HTTP Method and Path

```
GET /admin/ingredients/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Ingredient unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ingredient": {
      "id": 1,
      "canonical_name": "beef shank",
      "category": "meat",
      "created_at": "2025-10-09T12:00:00Z",
      "updated_at": "2025-10-09T12:00:00Z",
      "nutrition": {
        "calories": 250,
        "protein_g": 35,
        "carbs_g": 0,
        "fat_g": 12,
        "fiber_g": 0,
        "data_source": "nutritionix",
        "confidence_score": 0.95
      },
      "aliases": [
        { "alias": "beef shin", "language": "en" },
        { "alias": "牛腱", "language": "zh-tw" }
      ]
    }
  }
}
```

##### Example Requests

###### cURL

```bash
curl -X GET http://localhost:3000/admin/ingredients/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Nutrition values are per 100g
- Confidence score indicates data reliability (0-1)
- data_source shows origin: nutritionix, manual, or usda

##### Related Endpoints

- [Update Ingredient](#update-ingredient)
- [Refresh Nutrition Data](#refresh-nutrition-data)

---

#### Create Ingredient

Create a new ingredient with nutrition data.

##### HTTP Method and Path

```
POST /admin/ingredients
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Request Body

```json
{
  "ingredient": {
    "canonical_name": "beef shank",
    "category": "meat"
  },
  "nutrition": {
    "calories": 250,
    "protein_g": 35,
    "carbs_g": 0,
    "fat_g": 12,
    "fiber_g": 0,
    "data_source": "manual",
    "confidence_score": 0.8
  },
  "aliases": [
    { "alias": "beef shin", "language": "en" },
    { "alias": "牛腱", "language": "zh-tw" }
  ]
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ingredient.canonical_name` | String | Yes | Standard ingredient name |
| `ingredient.category` | String | Yes | Ingredient category |
| `nutrition` | Object | No | Nutrition data per 100g |
| `aliases` | Array | No | Alternative names with languages |

##### Response

###### Success (201 Created)

```json
{
  "success": true,
  "data": {
    "ingredient": {
      "id": 1,
      "canonical_name": "beef shank",
      "nutrition": {},
      "aliases": []
    }
  },
  "message": "Ingredient created successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/ingredients \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ingredient": {
      "canonical_name": "beef shank",
      "category": "meat"
    }
  }'
```

##### Notes

- canonical_name should be lowercase
- Nutrition and aliases are optional but recommended
- Nutrition values are per 100g servings
- Confidence score: 0-1, where 1 is highest confidence

##### Related Endpoints

- [Update Ingredient](#update-ingredient)
- [Refresh Nutrition Data](#refresh-nutrition-data)

---

#### Update Ingredient

Update an existing ingredient and its nutrition data.

##### HTTP Method and Path

```
PUT /admin/ingredients/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Ingredient unique identifier |

##### Request Body

```json
{
  "ingredient": {
    "canonical_name": "beef shank",
    "category": "meat"
  },
  "nutrition": {
    "calories": 250,
    "protein_g": 35
  }
}
```

All fields are optional. Only provided fields will be updated.

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ingredient": {
      "id": 1,
      "canonical_name": "beef shank"
    }
  },
  "message": "Ingredient updated successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X PUT http://localhost:3000/admin/ingredients/1 \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nutrition": {
      "calories": 255
    }
  }'
```

##### Notes

- Partial updates supported
- If nutrition object doesn't exist, it will be created
- Existing nutrition values not in request remain unchanged

##### Related Endpoints

- [Get Ingredient](#get-ingredient)
- [Refresh Nutrition Data](#refresh-nutrition-data)

---

#### Delete Ingredient

Permanently delete an ingredient.

##### HTTP Method and Path

```
DELETE /admin/ingredients/:id
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Ingredient unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "deleted": true
  },
  "message": "Ingredient deleted successfully"
}
```

##### Example Requests

###### cURL

```bash
curl -X DELETE http://localhost:3000/admin/ingredients/1 \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- This is a destructive operation and cannot be undone
- Associated nutrition and alias records are also deleted

---

#### Refresh Nutrition Data

Refresh ingredient nutrition from Nutritionix API (AC-NUTR-013 placeholder).

##### HTTP Method and Path

```
POST /admin/ingredients/:id/refresh_nutrition
```

##### Authentication

- **Required**: Yes
- **Type**: Bearer Token
- **Role Required**: Admin

##### Description

Fetches updated nutrition data from the Nutritionix API. Currently updates data_source and confidence_score as a placeholder until full API integration.

##### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | Integer | Yes | Ingredient unique identifier |

##### Response

###### Success (200 OK)

```json
{
  "success": true,
  "data": {
    "ingredient": {
      "id": 1,
      "nutrition": {
        "data_source": "nutritionix",
        "confidence_score": 1.0
      }
    }
  },
  "message": "Nutrition data refreshed successfully"
}
```

##### Error Responses

**422 Unprocessable Entity**
```json
{
  "success": false,
  "message": "No nutrition data to refresh",
  "errors": ["Create nutrition data first"]
}
```

##### Example Requests

###### cURL

```bash
curl -X POST http://localhost:3000/admin/ingredients/1/refresh_nutrition \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

##### Notes

- Acceptance Criteria: AC-NUTR-013 (placeholder)
- Full Nutritionix API integration to be implemented
- Currently updates metadata only
- Requires existing nutrition record

##### Related Endpoints

- [Get Ingredient](#get-ingredient)
- [Update Ingredient](#update-ingredient)

---

## Common Response Patterns

All API responses follow a consistent structure:

### Success Response

```json
{
  "success": true,
  "data": {
    // Response data here
  },
  "message": "Optional success message"
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description",
  "errors": ["Detailed error 1", "Detailed error 2"]
}
```

### Pagination Meta

```json
{
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_count": 45,
    "total_pages": 3
  }
}
```

---

## Error Codes Reference

### HTTP Status Codes

| Code | Meaning | When to Expect |
|------|---------|----------------|
| 200 | OK | Successful GET, PUT, PATCH, DELETE |
| 201 | Created | Successful POST that creates a resource |
| 400 | Bad Request | Invalid request format or parameters |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | Authenticated but not authorized (not admin) |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Validation errors |
| 500 | Internal Server Error | Server-side error |

### Common Error Messages

**Authentication Errors:**
- `"Unauthorized"` - No token or invalid token
- `"User not authenticated"` - Token invalid or expired
- `"Access denied"` - User doesn't have required permissions

**Validation Errors:**
- `"Validation failed"` - One or more fields failed validation
- `"[Field] can't be blank"` - Required field missing
- `"[Field] has already been taken"` - Uniqueness constraint violated
- `"[Field] is too short (minimum is X characters)"` - Length constraint

**Resource Errors:**
- `"Recipe not found"` - Resource with given ID doesn't exist
- `"Note not found or you do not have permission to modify it"` - Ownership check failed

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2025-10-09 | 1.0.0 | Initial API reference documentation |

---

**Note:** This API reference should be updated whenever new endpoints are added or existing endpoints are modified. See [API_REFERENCE_TEMPLATE.md](API_REFERENCE_TEMPLATE.md) for guidelines on documenting new endpoints.
