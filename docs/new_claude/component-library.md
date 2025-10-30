# Component Library Documentation

Update this document every time a component is created, modified, or removed. Each component must document: name, location, purpose, props, emits, slots, examples, related components, and notes.

---

## Table of Contents

- [Shared Components](#shared-components)
  - [LoadingSpinner](#loadingspinner)
  - [ErrorMessage](#errormessage)
  - [ConfirmDialog](#confirmdialog)
  - [EmptyState](#emptystate)
  - [PageHeader](#pageheader)
  - [Badge](#badge)
  - [LanguageSwitcher](#languageswitcher)
- [Admin Components](#admin-components)
  - [Admin Layout](#admin-layout)
  - [Admin Recipes](#admin-recipes)
  - [Admin Data Management](#admin-data-management)
  - [Admin Prompts](#admin-prompts)
  - [Admin Ingredients](#admin-ingredients)
- [User Components](#user-components)
  - [User Layout](#user-layout)
  - [User Recipes](#user-recipes)
  - [User Search](#user-search)
  - [User Features](#user-features)
- [Composables](#composables)

---

## Shared Components

### LoadingSpinner

**Location:** `components/shared/LoadingSpinner.vue`

**Purpose:** Display loading state with consistent styling

**Props:**
```typescript
interface Props {
  size?: 'sm' | 'md' | 'lg' | 'xl'  // default: 'md'
  text?: string                      // Text to display next to spinner
  center?: boolean                   // Center in container (default: false)
  fullscreen?: boolean               // Fullscreen overlay (default: false)
  label?: string                     // Accessibility label (default: 'Loading...')
}
```

**Emits:** None

**Slots:** None

**Usage:**
```vue
<!-- Basic usage -->
<LoadingSpinner />

<!-- With text -->
<LoadingSpinner text="Loading recipes..." size="lg" />

<!-- Centered in container -->
<LoadingSpinner :center="true" />

<!-- Fullscreen overlay -->
<LoadingSpinner :fullscreen="true" text="Processing..." />
```

**Related Components:** ErrorMessage, EmptyState, PlayfulLoadingSpinner

**Notes:**
- Uses design tokens from variables.css
- Accessible with proper ARIA labels
- Fullscreen mode includes semi-transparent backdrop

---

### PlayfulLoadingSpinner

**Location:** `components/shared/PlayfulLoadingSpinner.vue`

**Purpose:** Display loading state with rotating playful text messages (cooking puns). Used for longer-running operations to keep users engaged.

**Props:**
```typescript
interface Props {
  size?: 'sm' | 'md' | 'lg' | 'xl'  // default: 'lg'
  fullscreen?: boolean               // Fullscreen overlay (default: false)
  label?: string                     // Accessibility label (default: 'Loading...')
}
```

**Emits:** None

**Slots:** None

**Usage:**
```vue
<!-- Basic usage with cooking puns -->
<PlayfulLoadingSpinner />

<!-- Fullscreen overlay -->
<PlayfulLoadingSpinner :fullscreen="true" />

<!-- Smaller size -->
<PlayfulLoadingSpinner size="md" />
```

**Features:**
- Rotating cooking pun messages that change every 2 seconds
- "(this may take a while)" subtitle
- 100% i18n coverage with culturally appropriate puns in all 7 languages
- Smooth fade transitions between messages
- Auto-cycles through 8 different cooking-related messages

**Cooking Puns (English):**
1. "Prepping ingredients..."
2. "Simmering your recipe..."
3. "Seasoning to perfection..."
4. "Reducing the sauce..."
5. "Letting it marinate..."
6. "Whisking away..."
7. "Bringing to a boil..."
8. "Adding a pinch of magic..."

**Related Components:** LoadingSpinner, UrlImportDialog

**Notes:**
- Uses design tokens from variables.css
- Accessible with proper ARIA labels
- Automatically manages rotation interval (2 seconds)
- Cleans up interval on component unmount
- i18n keys: `admin.recipes.urlImportDialog.loadingPuns.*` and `admin.recipes.urlImportDialog.loadingSubtitle`

---

### ErrorMessage

**Location:** `components/shared/ErrorMessage.vue`

**Purpose:** Display error messages with consistent styling and optional dismiss

**Props:**
```typescript
interface Props {
  error?: Error | null          // Error object (extracts message)
  message?: string              // Direct error message
  title?: string                // Error title
  severity?: 'error' | 'warning' | 'info'  // default: 'error'
  dismissible?: boolean         // Can be dismissed (default: false)
  compact?: boolean             // Compact mode (default: false)
}
```

**Emits:**
```typescript
{
  dismiss: []  // Emitted when dismissed
}
```

**Slots:**
- `default` - Additional content after message

**Usage:**
```vue
<!-- Basic error -->
<ErrorMessage message="Failed to load recipes" />

<!-- With Error object -->
<ErrorMessage :error="error" severity="error" />

<!-- Dismissible warning -->
<ErrorMessage
  message="Recipe has unsaved changes"
  severity="warning"
  :dismissible="true"
  @dismiss="handleDismiss"
/>

<!-- Compact info message -->
<ErrorMessage
  message="Using cached data"
  severity="info"
  :compact="true"
/>
```

**Related Components:** LoadingSpinner, EmptyState

**Notes:**
- Automatically extracts message from Error objects
- Uses semantic colors from design tokens
- Dark mode compatible

---

### ConfirmDialog

**Location:** `components/shared/ConfirmDialog.vue`

**Purpose:** Modal dialog for confirming actions

**Props:**
```typescript
interface Props {
  isOpen: boolean                     // Controls visibility
  title?: string                      // Dialog title (default: 'Confirm')
  message: string                     // Confirmation message
  confirmText?: string                // Confirm button text (default: 'Confirm')
  cancelText?: string                 // Cancel button text (default: 'Cancel')
  severity?: 'primary' | 'error' | 'warning' | 'success'  // default: 'primary'
  loading?: boolean                   // Confirm button loading state (default: false)
  closeOnBackdrop?: boolean           // Close on backdrop click (default: true)
}
```

**Emits:**
```typescript
{
  confirm: []                 // User confirmed action
  cancel: []                  // User cancelled action
  'update:isOpen': [value: boolean]  // v-model support
}
```

**Slots:**
- `default` - Custom message content

**Usage:**
```vue
<!-- Delete confirmation -->
<ConfirmDialog
  v-model:is-open="showDeleteDialog"
  title="Delete Recipe"
  message="Are you sure you want to delete this recipe? This action cannot be undone."
  severity="error"
  confirm-text="Delete"
  @confirm="handleDelete"
/>

<!-- With loading state -->
<ConfirmDialog
  v-model:is-open="showDialog"
  message="Save changes to recipe?"
  :loading="saving"
  @confirm="handleSave"
/>

<!-- Custom content -->
<ConfirmDialog
  v-model:is-open="showBulkDelete"
  title="Delete Multiple Recipes"
>
  <p>You are about to delete {{ selectedCount }} recipes.</p>
  <p class="text-secondary">This action cannot be undone.</p>
</ConfirmDialog>
```

**Related Components:** None

**Notes:**
- ESC key closes dialog
- Backdrop click closes dialog (unless loading or closeOnBackdrop=false)
- Uses Teleport to render in body
- Modal animations included

---

### EmptyState

**Location:** `components/shared/EmptyState.vue`

**Purpose:** Display when no data/results are available

**Props:**
```typescript
interface Props {
  icon?: string               // PrimeIcon name (without 'pi-' prefix)
  title?: string              // Main message
  description?: string        // Descriptive text
  actionText?: string         // Action button text (default: 'Get Started')
  action?: () => void         // Action button handler
  compact?: boolean           // Compact mode (default: false)
}
```

**Emits:**
```typescript
{
  action: []  // Emitted when action button clicked
}
```

**Slots:**
- `default` - Additional content
- `actions` - Custom action buttons (replaces default button)

**Usage:**
```vue
<!-- No recipes found -->
<EmptyState
  icon="search"
  title="No recipes found"
  description="Try adjusting your filters or search terms"
  action-text="Clear Filters"
  @action="clearFilters"
/>

<!-- Empty favorites with custom actions -->
<EmptyState
  icon="heart"
  title="No favorites yet"
  description="Start adding recipes to your favorites to see them here"
>
  <template #actions>
    <button class="btn btn-primary" @click="goToBrowse">Browse Recipes</button>
  </template>
</EmptyState>

<!-- Compact mode -->
<EmptyState
  icon="inbox"
  title="No items"
  :compact="true"
/>
```

**Related Components:** LoadingSpinner, ErrorMessage

**Notes:**
- Always provide helpful guidance to user
- Include action when appropriate

---

### PageHeader

**Location:** `components/shared/PageHeader.vue`

**Purpose:** Consistent page header with title, subtitle, back button, and actions

**Props:**
```typescript
interface Props {
  title: string               // Page title (required)
  subtitle?: string           // Optional subtitle
  backTo?: string             // Route name/path to navigate back to (shows back button)
}
```

**Emits:** None

**Slots:**
- `actions` - Right-side action buttons
- `tabs` - Tab navigation below header (with top border)

**Usage:**
```vue
<!-- Basic header -->
<PageHeader title="Recipe Management" />

<!-- With subtitle and actions -->
<PageHeader
  title="Edit Recipe"
  subtitle="Last updated 2 hours ago"
>
  <template #actions>
    <button class="btn btn-primary" @click="save">Save</button>
    <button class="btn btn-outline" @click="cancel">Cancel</button>
  </template>
</PageHeader>

<!-- With back button -->
<PageHeader
  title="Recipe Details"
  subtitle="Chocolate Chip Cookies"
  back-to="/recipes"
/>

<!-- With tabs -->
<PageHeader title="Admin Dashboard">
  <template #tabs>
    <div class="tabs">
      <button class="tab tab-active">Overview</button>
      <button class="tab">Analytics</button>
    </div>
  </template>
</PageHeader>
```

**Related Components:** None

**Notes:**
- Responsive design (stacks on mobile)
- Back button uses router.push() or router.back()
- Border-bottom separates from content

---

### Badge

**Location:** `components/shared/Badge.vue`

**Purpose:** Display status, tags, dietary indicators, or counts

**Props:**
```typescript
interface Props {
  variant?: 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info'  // default: 'default'
  size?: 'sm' | 'md' | 'lg'  // default: 'md'
  icon?: string               // PrimeIcon name (without 'pi-' prefix)
  pill?: boolean              // Fully rounded pill style (default: false)
  dot?: boolean               // Dot indicator (small circle) (default: false)
}
```

**Emits:** None

**Slots:**
- `default` - Badge content/text

**Usage:**
```vue
<!-- Dietary tag -->
<Badge variant="success">Vegetarian</Badge>

<!-- With icon -->
<Badge variant="info" icon="clock">15 min</Badge>

<!-- Status badge as pill -->
<Badge variant="warning" :pill="true">Draft</Badge>

<!-- Count badge -->
<Badge variant="primary" size="sm">5</Badge>

<!-- Dot indicator -->
<Badge variant="error" :dot="true" />

<!-- Multiple badges -->
<div class="flex gap-sm">
  <Badge variant="success">Gluten-Free</Badge>
  <Badge variant="info">Quick & Easy</Badge>
  <Badge variant="secondary">Italian</Badge>
</div>
```

**Related Components:** None

**Notes:**
- Uses semantic colors from design tokens
- Dark mode compatible
- Dot style useful for status indicators
- Pill style for tags

---

### LanguageSwitcher

**Location:** `components/shared/LanguageSwitcher.vue`

**Purpose:** Allows users to switch between all 7 supported languages. Displays languages with native names and flag emojis. Persists language preference to localStorage and syncs with Vue I18n.

**Props:**
```typescript
// No props - uses uiStore for state management
```

**Emits:**
```typescript
// No emits - updates state through uiStore.setLanguage()
```

**Slots:** None

**Usage:**
```vue
<!-- Basic usage - typically in header/navbar -->
<LanguageSwitcher />
```

**Supported Languages:**
- 🇬🇧 English (en)
- 🇯🇵 日本語 (ja)
- 🇰🇷 한국어 (ko)
- 🇹🇼 繁體中文 (zh-tw)
- 🇨🇳 简体中文 (zh-cn)
- 🇪🇸 Español (es)
- 🇫🇷 Français (fr)

**How It Works:**
1. Displays current language from `useI18n().locale`
2. When user selects new language:
   - Calls `uiStore.setLanguage(code)`
   - Updates Vue I18n locale
   - Saves to localStorage (`locale` key)
   - Updates document language attribute
   - Updates text direction (LTR/RTL if needed)
3. All UI text updates immediately via Vue I18n's `$t()` function

**Related Components:** None (standalone)

**i18n Keys Used:**
- `common.labels.language` - Accessibility label for select dropdown

**Notes:**
- Language preference persists across sessions via localStorage
- Falls back to browser language → 'en' on first visit
- Uses CSS custom properties for styling (border, background, colors)
- Fully accessible with aria-label
- Mobile responsive (adapts to small screens)
- Works in both light and dark modes

---

## Admin Components

### Admin Layout

#### AdminLayout

**Location:** `components/admin/layout/AdminLayout.vue`

**Purpose:** Main layout wrapper for all admin pages. Provides consistent structure with navbar, sidebar, and main content area. Manages sidebar open/close state.

**Props:**
```typescript
// No props - internal state management only
```

**Emits:**
```typescript
// No emits - internal state management only
```

**Slots:**
- `default` - Main content area for page-specific content

**Usage:**
```vue
<!-- In router configuration -->
{
  path: '/admin',
  component: AdminLayout,
  children: [
    {
      path: '',
      component: AdminDashboard
    }
  ]
}

<!-- AdminDashboard.vue renders inside the layout -->
<template>
  <div class="admin-dashboard">
    <PageHeader title="Dashboard" subtitle="Welcome back to Ember Admin" />
    <!-- Dashboard content here -->
  </div>
</template>
```

**Related Components:** AdminNavBar, AdminSidebar, AdminBreadcrumbs

**Notes:**
- Manages sidebar state internally with `ref(true)` - defaults to open on desktop
- Sidebar toggles on mobile (<768px) with overlay backdrop
- Uses flexbox layout: sticky navbar at top, sidebar on left, scrollable main content
- Background color uses `--color-background-secondary` for subtle contrast
- Max width `--max-width-7xl` with auto margins for content centering
- Responsive padding: `--spacing-xl` on desktop, `--spacing-md` on mobile

---

#### AdminNavBar

**Location:** `components/admin/layout/AdminNavBar.vue`

**Purpose:** Top navigation bar for admin interface with branding, sidebar toggle, theme controls, and user menu

**Props:**
```typescript
// No props
```

**Emits:**
```typescript
interface Emits {
  (e: 'toggle-sidebar'): void  // Emitted when sidebar toggle button is clicked
}
```

**Slots:**
- None

**Usage:**
```vue
<!-- Used internally by AdminLayout -->
<AdminNavBar @toggle-sidebar="toggleSidebar" />

<!-- Features available to users: -->
<!-- - Click hamburger menu to toggle sidebar -->
<!-- - Click globe icon to change language (future feature) -->
<!-- - Click sun/moon icon to toggle light/dark theme -->
<!-- - Click user avatar to open dropdown menu -->
<!-- - User menu includes: Profile, Settings, Logout -->
```

**Related Components:** AdminLayout, AdminSidebar

**Notes:**
- **Branding:** Displays Ember logo (fire icon) + "Ember" text + "Admin" badge
- **Sidebar Toggle:** Hamburger menu button on left side, emits 'toggle-sidebar' event
- **Language Selector:** Globe icon (placeholder for future i18n feature)
- **Theme Toggle:** Sun/moon icon, integrates with `useUiStore().setTheme()`
- **User Menu:** Shows user avatar with initials, name (desktop only), dropdown with:
  - Profile link → `/admin/profile`
  - Settings link → `/admin/settings`
  - Logout button → calls `userStore.logout()` and redirects to `/login`
- **Responsive:** Hides user name and dropdown chevron on mobile (<768px)
- **Click-Outside:** Dropdowns close when clicking outside (window event listener)
- **Sticky Positioning:** Stays at top with `position: sticky; top: 0;`
- **Height:** Fixed 64px height for consistent layout
- **Z-index:** Uses `--z-index-sticky` to stay above content

---

#### AdminSidebar

**Location:** `components/admin/layout/AdminSidebar.vue`

**Purpose:** Persistent sidebar with admin menu navigation. Supports desktop and mobile responsive modes.

**Props:**
```typescript
interface Props {
  isOpen: boolean  // Controls sidebar visibility (managed by AdminLayout)
}
```

**Emits:**
```typescript
interface Emits {
  (e: 'close'): void  // Emitted when mobile overlay is clicked
}
```

**Slots:**
- None

**Usage:**
```vue
<!-- Used internally by AdminLayout -->
<AdminSidebar :is-open="sidebarOpen" @close="closeSidebar" />

<!-- The sidebar contains these navigation items: -->
<!-- Primary Menu: -->
<!-- - Dashboard (/admin) - chart-line icon -->
<!-- - Recipes (/admin/recipes) - book icon -->
<!-- - Data References (/admin/data-references) - database icon -->
<!-- - AI Prompts (/admin/prompts) - sparkles icon -->
<!-- - Ingredients (/admin/ingredients) - list icon -->

<!-- Secondary Menu (after divider): -->
<!-- - Settings (/admin/settings) - cog icon -->
<!-- - Help & Support (/admin/help) - question-circle icon -->
```

**Related Components:** AdminLayout, AdminNavBar, Badge

**Notes:**
- **Menu Items:** Defined as TypeScript array with path, label, icon, optional badge
- **Active State:** Uses `active-class="admin-sidebar__link--active"` from Vue Router
- **Desktop Behavior (>768px):**
  - Width: 260px when open, 0px when closed
  - Smooth transitions with `transition: transform var(--transition-base)`
  - Sticky positioning: `top: 64px` (below navbar)
  - Height: `calc(100vh - 64px)` for full viewport minus navbar
- **Mobile Behavior (<768px):**
  - Fixed positioning with slide-in animation
  - Transforms from `-100%` (off-screen) to `0` (visible)
  - Semi-transparent overlay backdrop when open
  - Clicking overlay emits 'close' event
  - Box shadow for elevation effect
- **Scrolling:** Content area is scrollable with custom scrollbar styling
- **Divider:** Separates primary and secondary menus
- **Icons:** Uses PrimeIcons with consistent sizing (20px width, centered)
- **Badge Support:** Can display badges on menu items (e.g., notification counts)

---

#### AdminBreadcrumbs

**Location:** `components/admin/layout/AdminBreadcrumbs.vue`

**Purpose:** Display navigation breadcrumbs for admin pages to show current location and allow easy navigation

**Props:**
```typescript
interface Breadcrumb {
  label: string    // Display text for breadcrumb
  path: string     // Router path to navigate to
  icon?: string    // Optional PrimeIcon name (without 'pi-' prefix)
}

interface Props {
  breadcrumbs: Breadcrumb[]  // Array of breadcrumb items
}
```

**Emits:**
```typescript
// No emits - uses router-link for navigation
```

**Slots:**
- None

**Usage:**
```vue
<!-- Basic usage in admin page -->
<AdminBreadcrumbs
  :breadcrumbs="[
    { label: 'Dashboard', path: '/admin', icon: 'home' },
    { label: 'Recipes', path: '/admin/recipes', icon: 'book' },
    { label: 'Edit Recipe', path: '/admin/recipes/123' }
  ]"
/>

<!-- With computed breadcrumbs -->
<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const breadcrumbs = computed(() => [
  { label: 'Dashboard', path: '/admin', icon: 'chart-line' },
  { label: 'Recipes', path: '/admin/recipes' },
  { label: route.params.name, path: route.path }
])
</script>

<template>
  <AdminBreadcrumbs :breadcrumbs="breadcrumbs" />
</template>
```

**Related Components:** PageHeader, AdminLayout

**Notes:**
- **Last Item:** Always rendered as `<span>` with `aria-current="page"` (not a link)
- **Icons:** Optional icons displayed before label using PrimeIcons
- **Separator:** Uses `pi-angle-right` icon between items
- **Accessibility:** Wrapped in `<nav aria-label="Breadcrumb">` for screen readers
- **Responsive:** Smaller font on mobile (<768px)
- **Hover Effect:** Links change to primary color on hover
- **Flex Wrap:** Breadcrumbs wrap to multiple lines if needed

---

### Admin Recipes

#### RecipeForm

**Location:** `components/admin/recipes/RecipeForm.vue`

**Purpose:** Comprehensive form for creating and editing recipes with all required fields including ingredients, steps, timing, tags, and equipment

**Props:**
```typescript
interface Props {
  modelValue?: Partial<Recipe> | null  // Recipe data for editing (default: null)
  loading?: boolean                     // Show loading state on save (default: false)
}
```

**Emits:**
```typescript
{
  'update:modelValue': [value: Partial<Recipe>]  // v-model support
  save: []                                         // User clicked Save
  cancel: []                                       // User clicked Cancel
}
```

**Slots:**
None

**Usage:**
```vue
<!-- Create new recipe -->
<RecipeForm
  v-model="recipeData"
  :loading="saving"
  @save="handleSave"
  @cancel="handleCancel"
/>

<!-- Edit existing recipe -->
<RecipeForm
  v-model="existingRecipe"
  :loading="updating"
  @save="handleUpdate"
  @cancel="router.back()"
/>
```

**Form Sections:**
1. **Basic Information**
   - Title (required)
   - Source URL
   - Servings (required)
   - Difficulty (easy/medium/hard)
   - Language (en, ja, ko, zh-tw, zh-cn, es, fr)

2. **Timing**
   - Prep time (minutes)
   - Cook time (minutes)
   - Total time (minutes)

3. **Tags & Classification**
   - Dietary tags (multi-select from dataReferenceStore)
   - Cuisines (multi-select)

4. **Ingredient Groups**
   - Dynamic ingredient groups with add/remove
   - Each ingredient has: name, amount, unit, notes, optional flag
   - Add/remove individual ingredients
   - Delete entire groups (minimum 1 group required)

5. **Steps**
   - Dynamic step list with add/remove/reorder
   - Each step has: instruction (required), timing (optional)
   - Move up/down buttons for reordering
   - Auto-renumbering on changes

6. **Equipment**
   - Comma-separated equipment list
   - Hint text to guide user

**Features:**
- **Validation:** Form validates required fields (title, servings > 0, at least 1 ingredient, at least 1 step)
- **Auto-fetch Data References:** Automatically loads dietary tags, cuisines on mount
- **Responsive:** Mobile-friendly layout with grid-to-column transformation
- **i18n:** 100% translated in all 7 languages
- **Design Tokens:** Uses CSS custom properties for all styling

**Related Components:**
- RecipeImportModal (will use this form for preview/edit)
- RecipeListAdmin (navigation to this form)
- DataReferenceStore (provides tag/cuisine options)

**Notes:**
- Form initializes with 1 empty ingredient and 1 empty step on mount
- Ingredient groups require at least 1 group (cannot delete last group)
- Steps auto-renumber when moved or deleted
- Equipment is stored as comma-separated string, converted to array on save
- Uses PrimeVue components (InputText, InputNumber, Textarea, Dropdown, MultiSelect, Button, Checkbox)
- Satisfies AC-ADMIN-001: Manual Recipe Creation - Full Form

---

#### Image Upload Component

**File:** `frontend/src/components/admin/recipes/RecipeForm.vue`

**Usage:** Admin recipe creation and editing

**Props:** Exposed ref `selectedImageFile: Ref<File | null>`

**Features:**
- File input with drag-and-drop visualization
- Image preview with remove button
- Client-side validation (format: PNG, JPG, GIF, WebP; max 10MB)
- Integrated error messaging

**Localization Keys:**
- `forms.recipe.sections.image` - Section title
- `forms.recipe.image` - Field label
- `forms.recipe.imageUploadPlaceholder` - Upload prompt
- `forms.recipe.imageUploadHint` - Validation help text
- `common.buttons.remove` - Remove image button

---

#### TextImportDialog

**Location:** `components/admin/recipes/TextImportDialog.vue`

**Purpose:** Modal dialog for importing recipes by pasting recipe text. Uses AI (Claude) to parse unstructured recipe text and extract structured data

**Props:**
```typescript
interface Props {
  visible: boolean  // Controls dialog visibility (v-model:visible)
}
```

**Emits:**
```typescript
{
  'update:visible': [value: boolean]  // v-model:visible support
  'import': [text: string]             // User clicked Import with text
}
```

**Exposed Methods:**
```typescript
{
  setLoading(value: boolean): void   // Set loading state from parent
  setError(message: string): void    // Display error message from parent
  resetDialog(): void                // Clear form and reset state
}
```

**Slots:** None

**Usage:**
```vue
<script setup>
const dialogVisible = ref(false)
const dialogRef = ref(null)

async function handleImport(text) {
  dialogRef.value.setLoading(true)
  try {
    const response = await adminApi.parseText({ text_content: text })
    formData.value = response.data.recipe_data
    dialogVisible.value = false
    dialogRef.value.resetDialog()
  } catch (error) {
    dialogRef.value.setError('Failed to parse recipe')
  }
}
</script>

<template>
  <Button label="Import from Text" @click="dialogVisible = true" />
  <TextImportDialog
    ref="dialogRef"
    v-model:visible="dialogVisible"
    @import="handleImport"
  />
</template>
```

**Features:**
- Large monospace textarea (400px min-height)
- Validation: Requires min 50 characters
- Loading state with spinner
- Error handling (keeps dialog open for retry)
- 100% i18n coverage (7 languages)
- Keyboard accessible (Tab, Enter, Escape)

**States:**
1. Empty: Import button disabled
2. Text entered (>= 50 chars): Import enabled
3. Loading: Spinner shown, controls disabled
4. Error: Message displayed inline, text preserved
5. Success: Dialog closes, parent shows feedback

**Related Components:** RecipeForm, AdminRecipeNew

**API:** `POST /admin/recipes/parse_text` with `{ text_content: string }`

**Notes:**
- Dialog not closable during loading
- Uses PrimeVue Dialog, Textarea, Button
- Typical parse time: 5-15 seconds
- Satisfies AC-ADMIN-UI-TEXT-001 through AC-ADMIN-UI-TEXT-005

---

#### UrlImportDialog

**Location:** `components/admin/recipes/UrlImportDialog.vue`

**Purpose:** Modal dialog for importing recipes from URL. Uses AI (Claude) to fetch and parse recipe from webpage, with web scraping fallback. Features playful loading state with cooking puns.

**Props:**
```typescript
interface Props {
  visible: boolean  // Controls dialog visibility (v-model:visible)
}
```

**Emits:**
```typescript
{
  'update:visible': [value: boolean]    // v-model:visible support
  'import': [url: string]                // User clicked Import with URL
  'switch-to-text': [url: string]        // User clicked Switch to Text Import
}
```

**Exposed Methods:**
```typescript
{
  setLoading(value: boolean): void   // Set loading state from parent
  setError(message: string): void    // Display error message from parent
  resetDialog(): void                // Clear form and reset state
}
```

**Slots:** None

**Usage:**
```vue
<script setup>
const dialogVisible = ref(false)
const dialogRef = ref(null)

async function handleImportUrl(url) {
  dialogRef.value.setLoading(true)
  try {
    const response = await adminApi.parseUrl({ url })
    formData.value = response.data.recipe_data
    dialogVisible.value = false
    dialogRef.value.resetDialog()
  } catch (error) {
    if (error.message.includes('not find')) {
      dialogRef.value.setError('Could not find a recipe on this page')
    } else {
      dialogRef.value.setError('Failed to parse recipe from URL')
    }
  }
}

function handleSwitchToText(url) {
  // Close URL dialog, open text dialog
  dialogVisible.value = false
  textDialogVisible.value = true
}
</script>

<template>
  <Button label="Import from URL" @click="dialogVisible = true" />
  <UrlImportDialog
    ref="dialogRef"
    v-model:visible="dialogVisible"
    @import="handleImportUrl"
    @switch-to-text="handleSwitchToText"
  />
</template>
```

**Features:**
- URL format validation (HTTP/HTTPS only)
- PlayfulLoadingSpinner with rotating cooking puns every 2 seconds
- Error recovery with "Switch to Text Import" option
- Error handling for all scenarios (timeout, 403, 404, no recipe, etc.)
- 100% i18n coverage (7 languages with culturally appropriate cooking puns)
- Keyboard accessible (Tab, Enter, Escape)

**States:**
1. Empty: Import button disabled
2. Invalid URL: Validation error shown, Import disabled
3. Valid URL: Import enabled
4. Loading: PlayfulLoadingSpinner shown, dialog not dismissible
5. Error: Message displayed, URL preserved, "Try Again" and "Switch to Text Import" buttons shown
6. Success: Dialog closes, parent shows feedback

**Related Components:** RecipeForm, AdminRecipeNew, PlayfulLoadingSpinner

**API:** `POST /admin/recipes/parse_url` with `{ url: string }`

**Notes:**
- Dialog not closable during loading
- Uses PrimeVue Dialog, InputText, Button
- Typical parse time: 10-30 seconds (AI direct access) or 15-45 seconds (with scraping fallback)
- Satisfies AC-ADMIN-UI-URL-001 through AC-ADMIN-UI-URL-012
- Backend uses two-tier approach: AI direct access first, web scraping fallback if needed

---

## User Components

### User Layout

*(Components to be documented as they are created)*

---

## Composables

### useBreakpoints

**Location:** `composables/useBreakpoints.ts`

**Purpose:** Reactive breakpoint detection for responsive design

**Returns:**
```typescript
{
  isMobile: Ref<boolean>      // < 768px
  isTablet: Ref<boolean>      // 768px - 1023px
  isDesktop: Ref<boolean>     // >= 1024px
  width: Ref<number>          // Current window width
}
```

**Usage:**
```vue
<script setup lang="ts">
import { useBreakpoints } from '@/composables/useBreakpoints'

const { isMobile, isTablet, isDesktop } = useBreakpoints()
</script>

<template>
  <div>
    <MobileNav v-if="isMobile" />
    <DesktopNav v-else />
  </div>
</template>
```

**Notes:**
- Automatically handles window resize
- Cleans up event listeners on unmount

---

### useDebounce

**Location:** `composables/useDebounce.ts`

**Purpose:** Debounce input values to reduce API calls

**Parameters:**
```typescript
function useDebounce<T>(
  value: Ref<T>,
  delay?: number  // default: 300ms
): Ref<T>
```

**Usage:**
```vue
<script setup lang="ts">
import { ref } from 'vue'
import { useDebounce } from '@/composables/useDebounce'

const searchQuery = ref('')
const debouncedQuery = useDebounce(searchQuery, 500)

watch(debouncedQuery, (newQuery) => {
  // This will only fire 500ms after user stops typing
  searchRecipes(newQuery)
})
</script>

<template>
  <input v-model="searchQuery" placeholder="Search recipes..." />
</template>
```

**Notes:**
- Use for search inputs and filters
- 300-500ms delay is recommended

---

### useToast

**Location:** `composables/useToast.ts`

**Purpose:** Display toast notifications

**Returns:**
```typescript
{
  showSuccess: (message: string, duration?: number) => void
  showError: (message: string, duration?: number) => void
  showWarning: (message: string, duration?: number) => void
  showInfo: (message: string, duration?: number) => void
}
```

**Usage:**
```vue
<script setup lang="ts">
import { useToast } from '@/composables/useToast'

const { showSuccess, showError } = useToast()

async function saveRecipe() {
  try {
    await recipeApi.createRecipe(recipe)
    showSuccess('Recipe saved successfully!')
  } catch (error) {
    showError('Failed to save recipe')
  }
}
</script>
```

**Notes:**
- Integrates with uiStore notifications
- Default duration: 5 seconds
- Auto-dismiss after duration

---

### useAuth

**Location:** `composables/useAuth.ts`

**Purpose:** Authentication helper functions

**Returns:**
```typescript
{
  isAuthenticated: ComputedRef<boolean>
  isAdmin: ComputedRef<boolean>
  currentUser: ComputedRef<User | null>
  login: (credentials: LoginCredentials) => Promise<void>
  logout: () => Promise<void>
  requireAuth: () => boolean  // Redirects to login if not authenticated
}
```

**Usage:**
```vue
<script setup lang="ts">
import { useAuth } from '@/composables/useAuth'

const { isAuthenticated, isAdmin, requireAuth } = useAuth()

function handleFavorite() {
  if (!requireAuth()) return
  // User is authenticated, proceed
  toggleFavorite()
}
</script>

<template>
  <Button v-if="isAdmin" label="Admin Panel" />
</template>
```

**Notes:**
- Wraps userStore for convenience
- Use requireAuth() before protected actions

---

## Template for New Components

When adding a new component, copy this template:

```markdown
### ComponentName

**Location:** `components/path/to/ComponentName.vue`

**Purpose:** Brief description of what this component does

**Props:**
```typescript
interface Props {
  propName: PropType         // Description
  optional?: string          // Optional prop (default: 'value')
}
```

**Emits:**
```typescript
{
  eventName: [payload: Type]  // When this event is emitted
}
```

**Slots:**
- `slotName` - Description of slot purpose

**Usage:**
```vue
<!-- Basic usage -->
<ComponentName :prop="value" />

<!-- Advanced usage -->
<ComponentName :prop="value" @event="handler">
  <template #slot>Custom content</template>
</ComponentName>
```

**Related Components:** OtherComponent, AnotherComponent

**Notes:**
- Important considerations
- limitations or limitations
```

---

## Component Status Tracker

| Component | Status | Documented | Last Updated |
|-----------|--------|------------|--------------|
| LoadingSpinner | ✅ Defined | ✅ Yes | 2025-10-08 |
| ErrorMessage | ✅ Defined | ✅ Yes | 2025-10-08 |
| ConfirmDialog | ✅ Defined | ✅ Yes | 2025-10-08 |
| EmptyState | ✅ Defined | ✅ Yes | 2025-10-08 |
| PageHeader | ✅ Defined | ✅ Yes | 2025-10-08 |
| Badge | ✅ Defined | ✅ Yes | 2025-10-08 |
| AdminLayout | 📝 Placeholder | ⏳ Pending | - |
| AdminNavBar | 📝 Placeholder | ⏳ Pending | - |
| AdminSidebar | 📝 Placeholder | ⏳ Pending | - |
| AdminBreadcrumbs | 📝 Placeholder | ⏳ Pending | - |
| RecipeForm | 📝 Placeholder | ⏳ Pending | - |

**Legend:**
- Defined - Component spec fully documented
- Placeholder - Component not yet created
- Pending - Needs documentation
- Outdated - Documentation out of sync

---

## Maintenance Checklist

Before marking any component work as "complete":

- [ ] Component is fully functional
- [ ] All props are documented with types and defaults
- [ ] All emits are documented with payload types
- [ ] All slots are documented
- [ ] At least 2 usage examples provided
- [ ] Related components are listed
- [ ] Notes section includes limitations and best practices
- [ ] Component status tracker is updated
- [ ] `Last Updated` date is current

---

