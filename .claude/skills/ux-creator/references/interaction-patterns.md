# Interaction Patterns

Common, proven UI/UX interaction patterns for navigation, forms, feedback, progressive disclosure, search, empty states, and onboarding. Use these established patterns instead of inventing custom solutions—users expect familiar interactions.

## Navigation Patterns

### Tab Bar (Bottom Navigation)

**Best for:** Mobile apps with 3-5 primary sections requiring frequent switching.

**When to use:**
- Mobile-first applications
- Equal-importance top-level sections
- Need persistent, visible navigation
- One-handed thumb reach important

**When NOT to use:**
- More than 5 sections (too crowded)
- Desktop applications (use sidebar instead)
- Single-flow apps (wizards, onboarding)
- Temporary navigation needs

**Guidelines:**
- 3-5 items maximum
- Icons + labels for clarity
- Highlight current section
- Position in thumb-reachable zone
- Persist across app (don't hide)

**Examples:** Instagram (Home, Search, Reels, Shop, Profile), iOS Settings

### Sidebar Navigation

**Best for:** Desktop applications or mobile apps with 5+ sections and hierarchical structure.

**When to use:**
- Desktop or tablet applications
- 5+ navigation items
- Hierarchical navigation (categories with subcategories)
- Content-heavy applications

**When NOT to use:**
- Mobile-first apps (use bottom tabs)
- Simple apps with <5 sections
- Full-screen focused tasks (video, games)

**Guidelines:**
- Collapsible for more content space
- Group related items
- Use visual hierarchy (primary vs. secondary items)
- Highlight active section
- Sticky position for easy access

**Examples:** Gmail, Slack, Admin dashboards

### Breadcrumbs

**Best for:** Multi-level hierarchies where users need context and ability to navigate up.

**When to use:**
- Deep navigation hierarchies (3+ levels)
- E-commerce categories
- Documentation sites
- File systems

**When NOT to use:**
- Flat site structure
- Single-path flows (checkout, onboarding)
- Mobile (too small, use back button)

**Guidelines:**
- Show full path: Home > Category > Subcategory > Item
- Make each level clickable
- Use chevrons (>) or slashes (/) as separators
- Truncate middle items if path is too long
- Position above main content

**Examples:** Amazon product categories, Documentation sites

### Hamburger Menu

**Best for:** Mobile apps with 6+ sections or infrequently accessed options.

**When to use:**
- Many navigation items (6+)
- Secondary navigation
- Need clean, minimal interface
- Space-constrained mobile layouts

**When NOT to use:**
- Primary navigation (use bottom tabs)
- 3-5 items (make visible instead)
- Critical, frequent actions

**Guidelines:**
- Use standard three-line icon
- Animate smoothly
- Include close button
- Dim/disable background when open
- Consider replacing with visible tabs if space allows

**Examples:** Mobile news apps, secondary menus

## Form Patterns

### Inline Validation

**Best for:** All forms where immediate feedback improves completion rates.

**When to use:**
- Always, unless specific reason not to
- Complex validation rules
- Reducing form abandonment
- Improving data quality

**When NOT to use:**
- Password strength (show requirements, not errors)
- Optional fields (validate only if user enters data)

**Guidelines:**
- Validate on blur (when user leaves field), not on every keystroke
- Show success checkmarks for valid fields
- Display errors immediately, clearly, with fix instructions
- Position error messages near fields
- Don't disable submit until first attempt

**Example error message:** "Email already registered. Try logging in or use a different email."

### Multi-Step Forms (Wizard)

**Best for:** Long forms that would be overwhelming as single page.

**When to use:**
- Forms with 10+ fields
- Logical grouping possible (Personal Info → Payment → Review)
- Each step has clear purpose
- Linear process (no jumping around needed)

**When NOT to use:**
- Short forms (5-8 fields, keep single page)
- Users need to see all fields (comparison, overview)
- No logical grouping
- Frequent back-and-forth needed

**Guidelines:**
- Show progress indicator (Step 2 of 4, or progress bar)
- Allow back navigation to edit previous steps
- Save progress (don't lose data)
- Validate each step before advancing
- Show summary/review before final submission

**Example:** Checkout (Shipping → Payment → Review), Account setup

### Smart Defaults and Autofill

**Best for:** Reducing user effort and errors.

**When to use:**
- Predictable values (country based on IP)
- Previously entered data (shipping = billing address)
- Browser autofill supported
- Common use cases

**When NOT to use:**
- Sensitive fields where wrong default is dangerous
- User preference varies widely

**Guidelines:**
- Use browser autocomplete attributes (name, email, address, etc.)
- Remember previous entries (with user consent)
- Make defaults editable
- Highlight autofilled fields
- Don't assume (e.g., gender, relationship status)

**Examples:** "Same as shipping address" checkbox, Country defaulted to user's location

### Optional vs. Required Fields

**Best for:** Clarity about what's needed vs. nice-to-have.

**When to use:**
- Forms with mix of required and optional fields
- Reducing form abandonment
- Collecting additional useful data

**When NOT to use:**
- All fields required (don't mark every field)
- All fields optional (mark required ones)

**Guidelines:**
- Mark required fields with asterisk (*) or (required) label
- Or mark optional fields with (optional)
- Explain why optional data is useful
- Don't make fields required unless truly necessary
- Group optional fields under "More information" or "Optional"

## Feedback Patterns

### Loading States

**Best for:** Informing users that a process is ongoing.

**When to use:**
- Operations taking >100ms
- Network requests
- Heavy computations
- File uploads

**When NOT to use:**
- Instant operations (<100ms)
- When better pattern exists (optimistic UI)

**Types:**
- **Spinner**: Short waits (1-3 seconds), indeterminate time
- **Progress bar**: Long waits (>3 seconds), known duration
- **Skeleton screens**: Loading content with layout preserved
- **Inline spinners**: For component-level loading

**Guidelines:**
- Show loading state immediately
- Use skeleton screens for content-heavy pages
- Show progress percentage for file uploads
- Disable actions during loading
- Provide cancel option for long operations

### Toast Notifications

**Best for:** Non-critical, temporary feedback that doesn't require user action.

**When to use:**
- Success confirmations ("Settings saved")
- Background task completions
- Informational messages
- Undo actions ("Message deleted. Undo?")

**When NOT to use:**
- Critical errors (use modal)
- Information user must read (use modal)
- Multiple toasts simultaneously (queue them)

**Guidelines:**
- Auto-dismiss after 3-5 seconds
- Position consistently (usually bottom or top)
- One toast at a time
- Provide undo for destructive actions
- Keep message concise (one line)
- Use appropriate severity (success green, error red, info blue)

**Example:** "Settings saved successfully" (auto-dismiss), "Email sent. Undo?" (with action)

### Modal Alerts

**Best for:** Critical information or actions requiring user attention.

**When to use:**
- Critical errors blocking workflow
- Destructive action confirmations (delete, logout)
- Important information user must acknowledge
- Focus-requiring tasks (compose email, fill form)

**When NOT to use:**
- Non-critical notifications (use toast)
- Frequently shown messages (users ignore)
- Can be inline instead (error under field, not modal)

**Guidelines:**
- Darken/blur background (focus on modal)
- Clearly indicate purpose (heading, icon)
- Provide clear actions (Cancel, Confirm)
- Allow dismissing (X button, click outside, Esc key)
- Don't stack modals
- Accessibility: trap focus, announce to screen readers

**Example confirmation modal:**
```
Delete Account?
This will permanently delete your account and all data. This cannot be undone.
[Cancel]  [Yes, Delete Account]
```

### Error Messages

**Best for:** Helping users understand and recover from problems.

**When to use:**
- Input validation errors
- System errors
- Permission denied
- Network failures

**When NOT to use:**
- Not actually an error (use info message)
- Can be prevented (use error prevention instead)

**Guidelines:**
- Use plain language, not error codes
- Explain what went wrong
- Suggest how to fix
- Provide recovery path
- Use appropriate severity (error, warning, info)
- Position near affected element

**Examples:**
- **Bad:** "Error 422"
- **Good:** "Email already registered. Try logging in or use a different email."
- **Bad:** "Invalid input"
- **Good:** "Password must be at least 8 characters with 1 number and 1 special character"

## Progressive Disclosure Patterns

### Accordions

**Best for:** Organizing related content where users need only subset at a time.

**When to use:**
- FAQs (one question open at a time)
- Settings grouped by category
- Long forms broken into sections
- Content-heavy pages

**When NOT to use:**
- Users need to see all content (use normal sections)
- Single item (no need for accordion)
- Critical information (don't hide)

**Guidelines:**
- Use chevron/arrow to indicate expandable
- Animate expansion smoothly
- Allow multiple open or single-open depending on use case
- Start with first item open, or all closed
- Keyboard accessible (arrow keys, Enter)

**Example:** FAQ page, Settings page by category

### "Show More" / "Load More"

**Best for:** Long lists or text content that would overwhelm if fully displayed.

**When to use:**
- Long article previews (truncate with "Read more")
- Search results (load 20, then "Load more")
- Comment sections
- Activity feeds

**When NOT to use:**
- Short content (show all)
- Navigation (paginate or infinite scroll instead)

**Guidelines:**
- Clearly indicate more content available
- Show how much more (e.g., "Show 50 more comments")
- Maintain scroll position after loading
- Provide "Show all" option when reasonable
- Consider infinite scroll for feeds

### Tooltips

**Best for:** Contextual help without cluttering interface.

**When to use:**
- Explaining unfamiliar icons
- Providing additional context
- Showing keyboard shortcuts
- Field-level help text

**When NOT to use:**
- Critical information (make visible)
- Long explanations (use help icon with modal)
- Touch devices where hover doesn't exist (use info icon)

**Guidelines:**
- Show on hover (desktop) or tap (mobile)
- Keep text concise (1-2 sentences)
- Position to not obscure content
- Delay appearance slightly (300ms) to avoid accidental triggers
- Dismiss on click outside or hover away
- Keyboard accessible (focus triggers tooltip)

## Search and Filtering Patterns

### Autocomplete

**Best for:** Helping users enter known items faster and reducing errors.

**When to use:**
- Search bars
- Large dropdown lists (countries, states)
- Tag input
- Form fields with predictable values

**When NOT to use:**
- Open-ended text (no predictable suggestions)
- Short lists (use dropdown instead)

**Guidelines:**
- Show suggestions after 2-3 characters
- Highlight matching text
- Limit to 5-10 suggestions
- Allow arrow key navigation
- Allow using suggestion or typing custom value
- Show recent searches

**Example:** Google search, Airport code entry

### Faceted Filters

**Best for:** Narrowing large result sets with multiple attributes.

**When to use:**
- E-commerce product listings
- Job boards
- Real estate searches
- Any multi-attribute data

**When NOT to use:**
- Small result sets (<20 items)
- Single filter sufficient
- Mobile (collapse filters)

**Guidelines:**
- Group related filters
- Show count of available results per filter
- Allow multiple selections within category
- Apply filters immediately or with "Apply" button
- Show active filters clearly with remove option
- Collapse less-used filters

**Example:** Amazon filters (Price, Brand, Rating, Prime, etc.)

### Search Filters

**Best for:** Refining search results.

**When to use:**
- After initial search
- Large result sets
- Multiple filter dimensions

**When NOT to use:**
- No search conducted yet
- Tiny result sets

**Guidelines:**
- Show filters after search, not before
- Display active filters prominently
- Allow removing individual filters
- Show result count updating
- Provide "Clear all filters" option

## Empty State Patterns

Empty states guide users when no content exists, turning potential dead-ends into opportunities.

### First-Time Empty State

**Best for:** New users with no data yet.

**When to use:**
- New user accounts
- Unopened features
- No items in category

**Guidelines:**
- Explain what will appear here
- Provide clear call-to-action to create first item
- Use friendly, encouraging tone
- Show example or illustration
- Offer help or tutorial

**Example:**
```
No projects yet
Create your first project to start collaborating with your team.
[+ Create Project]
```

### Error Empty State

**Best for:** When data should exist but failed to load.

**When to use:**
- Network errors
- Permission denied
- Server errors

**Guidelines:**
- Explain what went wrong
- Suggest solutions
- Provide retry action
- Contact support option for persistent issues

**Example:**
```
Couldn't load messages
Check your internet connection and try again.
[Retry]
```

### Search/Filter Empty State

**Best for:** When no results match criteria.

**When to use:**
- Search returns nothing
- All items filtered out

**Guidelines:**
- Confirm the search term
- Suggest broadening search
- Check for typos
- Provide link to clear filters
- Suggest related terms

**Example:**
```
No results for "bleu chees"
Did you mean "blue cheese"?
Try broadening your search or clearing filters.
[Clear Filters]
```

## Onboarding Patterns

### Progressive Onboarding

**Best for:** Teaching features in context as users encounter them.

**When to use:**
- Complex applications
- Many features to learn
- Want to reduce time-to-first-value

**When NOT to use:**
- Simple apps (don't over-explain)
- Critical tasks that can't be interrupted

**Guidelines:**
- Show tips in context, not upfront tour
- Highlight new feature with tooltip/callout
- Allow dismissing ("Got it" or X)
- Don't show same tip twice
- Provide way to replay tips ("Show tips again")

**Example:** "💡 Tip: Press Cmd+K to quickly search"

### Guided Tour

**Best for:** Showcasing key features to new users.

**When to use:**
- First-time users
- Major redesigns
- Complex interfaces
- New feature announcements

**When NOT to use:**
- Returning users (make skippable)
- Simple interfaces
- Every minor change

**Guidelines:**
- Make skippable ("Skip tour")
- Show progress (3 of 5)
- Keep to 3-5 steps maximum
- Focus on value, not features
- Allow pausing and resuming
- Dim background, highlight target
- Provide "Show tour again" option

### Checklist Onboarding

**Best for:** Guiding users to complete setup or key actions.

**When to use:**
- Account setup
- Achieving key milestones
- Incomplete profiles

**Guidelines:**
- Show progress (2 of 5 completed)
- Check off completed items
- Link to incomplete tasks
- Allow dismissing when done
- Celebrate completion

**Example:**
```
Get started with your account (3/5 complete)
✅ Create account
✅ Verify email
✅ Add profile photo
⬜ Invite team members
⬜ Create first project
```

## Pattern Selection Guide

| Need | Use | Avoid |
|------|-----|-------|
| Mobile primary nav (3-5 items) | Bottom tab bar | Hamburger menu |
| Desktop nav (5+ items) | Sidebar | Bottom tabs |
| Deep hierarchy | Breadcrumbs | Flat structure |
| Long form (10+ fields) | Multi-step wizard | Single page |
| Non-critical feedback | Toast | Modal |
| Critical confirmation | Modal | Toast |
| Expandable content | Accordion | Always visible |
| Additional context | Tooltip | Inline text |
| Filter large dataset | Faceted filters | Single search |
| No search results | Helpful empty state | Blank page |

## Mobile vs. Desktop Considerations

**Mobile-specific patterns:**
- Bottom tab navigation (thumb-reachable)
- Swipe gestures (delete, archive)
- Pull-to-refresh
- Action sheets (instead of context menus)
- Full-screen modals (limited space)

**Desktop-specific patterns:**
- Hover states and tooltips
- Context menus (right-click)
- Keyboard shortcuts
- Multiple windows/panels
- Drag-and-drop

**Responsive patterns:**
- Sidebar on desktop → hamburger on mobile
- Table on desktop → cards on mobile
- Hover tooltips on desktop → info icon on mobile
- Multi-column on desktop → single column on mobile
