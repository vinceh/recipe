# Requirements to UX Design

Comprehensive process for translating requirements into effective UX designs through requirement analysis, user journey mapping, information architecture, user flow design, and wireframing.

## Analyzing Requirements

Transform vague requirements into actionable UX designs by deeply understanding user needs, constraints, and success criteria.

### Requirement Types

Different requirements lead to different UX considerations:

**Functional Requirements** ("System must...")
- Define what features exist
- UX focus: How users access and use these features

**User Requirements** ("User needs to...")
- Define user goals
- UX focus: Optimal path to accomplish goals

**Business Requirements** ("Company wants...")
- Define business objectives
- UX focus: Balance user needs with business goals

**Technical Constraints** ("Must work on...")
- Define limitations
- UX focus: Design within constraints

**Accessibility Requirements** ("Must support...")
- Define inclusive design needs
- UX focus: WCAG 2.2 compliance, universal design

### Requirement Analysis Questions

For each requirement, ask:

**User-focused:**
- Who is the user? (role, expertise, context)
- What problem are they solving?
- What's their current solution? (pain points)
- When/where will they use this?
- What does success look like for them?

**System-focused:**
- What data/functionality is needed?
- What are the inputs and outputs?
- What are the business rules?
- What are the technical constraints?
- What are the performance requirements?

**UX-focused:**
- How should this flow?
- What interaction patterns fit?
- How do we prevent errors?
- How do we handle edge cases?
- How do we make this accessible?

### Example: Analyzing "Password Reset" Requirement

**Initial requirement:** "Users should be able to reset their password."

**After analysis:**

**User needs:**
- **Who**: Registered user who forgot password
- **Problem**: Can't access account
- **Current solution**: Contact support (slow, frustrating)
- **Success**: Regain access within 5 minutes

**System needs:**
- Verify user owns email address
- Generate secure reset token
- Expire token after 1 hour
- Require new password meets requirements
- Log password change event

**UX decisions:**
- Link prominently near password field (not hidden in footer)
- Single-step: email input only (no security questions)
- Clear feedback at each step
- Email with large, clear CTA button
- Show password requirements inline
- Confirm success and redirect to login

## User Journey Mapping

Visualize the complete user experience from initial need through goal achievement, identifying touchpoints, emotions, pain points, and opportunities.

### Journey Map Components

**Stages**: High-level phases users go through
**Touchpoints**: Specific interactions with product/service
**Actions**: What users do at each stage
**Thoughts**: What users think/wonder
**Emotions**: How users feel (anxious, confident, frustrated, delighted)
**Pain points**: Where friction occurs
**Opportunities**: Where UX can improve

### Creating a Journey Map

**Step 1: Define the journey scope**
- Start and end points
- User persona (who is this for?)
- Scenario (what are they trying to do?)

**Step 2: Identify stages**
- Break journey into 4-7 logical phases
- Name stages from user perspective

**Example stages for online shopping:**
1. Discovery (realizing need)
2. Research (finding options)
3. Evaluation (comparing choices)
4. Purchase (buying decision)
5. Delivery (waiting for product)
6. Use (experiencing product)
7. Support (if issues arise)

**Step 3: Map touchpoints**
- Where does user interact with your product/service?
- Include all channels (web, mobile, email, support, etc.)

**Step 4: Document user experience**
- What actions do they take?
- What are they thinking?
- How are they feeling?

**Step 5: Identify pain points**
- Where does friction occur?
- What frustrates users?
- Where do they drop off?

**Step 6: Spot opportunities**
- How can we reduce friction?
- What delighters can we add?
- Where can we exceed expectations?

### Journey Map Example: Food Delivery App

| Stage | Touchpoint | Actions | Thoughts | Emotions | Pain Points | Opportunities |
|-------|------------|---------|----------|----------|-------------|---------------|
| Hungry | Mobile app | Open app, browse options | "What am I in the mood for?" | Curious, slightly impatient | Too many choices, decision fatigue | Personalized suggestions based on time of day, weather, past orders |
| Ordering | Restaurant menu | Filter by dietary needs, add items | "Is this really enough food?" | Uncertain about portions | Can't see portion sizes, no reviews for specific items | Show portion sizes, photo reviews, "Popular together" suggestions |
| Checkout | Payment screen | Review order, apply promo, pay | "Is delivery free? How long?" | Anxious about cost, worried about wait time | Hidden fees appear, estimated time vague | Show all costs upfront, precise delivery time |
| Waiting | Order tracking | Watch map, check status | "Is it coming? Is it still hot?" | Anxious, impatient, hungry | Vague status ("Preparing..."), can't contact driver | Live map with ETA updates, driver SMS contact option |
| Receiving | Delivery | Meet driver, get food | "Did I get everything?" | Relieved, eager | Missing items common, no easy way to report | In-app checklist, instant refund for missing items |
| Eating | Consuming food | Eat meal | "This is delicious!" or "This is cold" | Satisfied or disappointed | Can't leave feedback until later, too late to fix issues | In-meal feedback option, instant resolution for problems |

### Journey Mapping Best Practices

**Do:**
- Base on research (user interviews, analytics, support tickets)
- Include emotional journey (not just actions)
- Involve cross-functional team (product, design, support, engineering)
- Update regularly as product evolves
- Focus on one persona per map

**Don't:**
- Create based on assumptions only
- Make journey map too complex (keep to 4-7 stages)
- Forget post-purchase experience
- Ignore negative emotions
- Leave opportunities vague ("make it better")

## Information Architecture

Organize content and functionality logically so users can find what they need efficiently.

### IA Principles

**Hierarchy**: Most important items at top levels
**Categorization**: Related items grouped together
**Navigation**: Clear paths between sections
**Searchability**: Content findable via search
**Scalability**: Structure accommodates growth

### Creating Information Architecture

**Step 1: Content Inventory**

List everything that needs to be included:
- All pages/screens
- All features/functionality
- All content types
- All data displayed

**Example inventory for dashboard:**
- Home/overview
- Analytics (traffic, conversions, revenue)
- Content management (pages, media, comments)
- User management (list, roles, permissions)
- Settings (profile, preferences, integrations, billing)
- Help/support

**Step 2: Group Related Items**

Create logical categories:
- What goes together from user perspective?
- What would users expect to find grouped?
- What shares similar functions?

**Grouping methods:**
- **By task**: Group by user goal (Create, Manage, Analyze)
- **By object**: Group by content type (Products, Orders, Customers)
- **By user type**: Group by role (Admin, Editor, Viewer)
- **By frequency**: Group by how often used (Daily, Weekly, Rarely)

**Step 3: Create Hierarchy**

Organize groups into parent-child relationships:

```
Dashboard (Root)
├── Overview (Primary)
│   ├── Key Metrics
│   ├── Recent Activity
│   └── Quick Actions
├── Analytics (Primary)
│   ├── Traffic
│   ├── Conversions
│   └── Revenue
├── Content (Primary)
│   ├── Pages
│   ├── Media
│   └── Comments
├── Users (Primary)
│   ├── All Users
│   ├── Roles
│   └── Permissions
└── Settings (Primary)
    ├── Profile (Secondary)
    ├── Preferences (Secondary)
    ├── Integrations (Secondary)
    └── Billing (Secondary)
```

**Hierarchy guidelines:**
- Keep depth to 3 levels maximum (user → category → item)
- Balance breadth (5-9 items per level is optimal)
- Put most important/frequent at top levels
- Use progressive disclosure for less important items

**Step 4: Define Navigation**

How users move between sections:

**Primary navigation**: Main sections (top-level categories)
**Secondary navigation**: Subsections within main sections
**Tertiary navigation**: Further detail (tabs, filters)
**Utility navigation**: Universal features (search, settings, help, user profile)

**Navigation placement:**
- **Top bar**: Branding, search, user actions
- **Sidebar**: Primary navigation (desktop)
- **Bottom tab bar**: Primary navigation (mobile)
- **Breadcrumbs**: Show current location in hierarchy
- **Hamburger menu**: Overflow items, less-used features

**Step 5: Validate with Card Sorting**

Test IA with users:

**Open card sorting**: Users create their own categories
- Reveals user mental models
- Identifies natural groupings
- Uncovers unexpected associations

**Closed card sorting**: Users sort into predefined categories
- Validates your IA
- Tests category labels
- Identifies confusing placement

**Tools**: OptimalSort, UserZoom, or physical note cards

## User Flow Design

Map detailed step-by-step paths users take to accomplish specific goals, including decision points, alternative paths, and error handling.

### Flow Components

**Entry point**: Where flow begins
**Actions**: What user does
**System response**: What system does
**Decision points**: Where user makes choice
**Alternate paths**: Different routes to goal
**Error states**: What happens when things go wrong
**Success state**: Goal achieved, what's next?

### Creating User Flows

**Step 1: Define the Goal**

Be specific:
- **Vague**: "Use the app"
- **Specific**: "Create account and complete profile"

**Step 2: Identify Entry Points**

Where do users start?
- Homepage
- Marketing landing page
- Direct link from email
- App store
- Social media

**Step 3: Map Happy Path**

Ideal flow from start to success:

```
User Flow: Create Account

Entry: Homepage
↓
[Homepage]
↓
User clicks "Sign Up" button
↓
[Registration Form]
├─ Email field
├─ Password field
└─ "Create Account" button
↓
User fills email and password
↓
User clicks "Create Account"
↓
System validates input
↓
System creates account
↓
System sends verification email
↓
[Success Screen] "Check your email to verify"
↓
User opens email
↓
User clicks verification link
↓
[Email Verified] Redirect to onboarding
```

**Step 4: Add Decision Points**

Where do users choose paths?

```
[Product List]
↓
User interaction
├─ Clicks product → [Product Detail]
├─ Adds to cart → [Cart Updated] Toast
├─ Uses filters → [Filtered Results]
└─ Searches → [Search Results]
```

**Step 5: Include Error Paths**

What happens when things fail?

```
User clicks "Create Account"
↓
System validates input
├─ Valid? → Create account
└─ Invalid?
    ├─ Email already exists
    │   → [Error] "Email already registered. Try logging in or use different email."
    │   → User corrects → Retry validation
    ├─ Password too weak
    │   → [Error] "Password must be 8+ characters with 1 number"
    │   → User corrects → Retry validation
    └─ Network error
        → [Error] "Connection failed. Please try again."
        → [Retry Button]
```

**Step 6: Optimize for Efficiency**

Reduce steps and cognitive load:

**Before:**
```
Home → Sign Up → Enter Email → Next → Enter Password → Next → Enter Name → Next → Enter Phone → Submit → Verify Email → Done
(8 screens)
```

**After:**
```
Home → Sign Up (Email + Password) → Submit → Verify Email → Done
(4 screens, name and phone collected later if needed)
```

### Flow Diagram Formats

**Flowchart**: Traditional shapes and arrows
**Wireflow**: Wireframes connected by arrows
**Swimlane**: Shows user vs. system actions separately
**Task flow**: User actions only, minimal detail

**Choose based on:**
- **Flowchart**: Technical audience, complex logic
- **Wireflow**: Designers, visual thinkers
- **Swimlane**: Cross-functional teams
- **Task flow**: Quick sketching, early exploration

## Wireframing

Create low-fidelity visual representations of interfaces to communicate layout, hierarchy, and functionality without visual design details.

### Wireframe Fidelity Levels

**Low-fidelity (Lo-fi)**
- Boxes, lines, placeholder text
- No real content, colors, or images
- Fast to create, easy to change
- Focus on structure and flow

**When to use:** Early exploration, rapid iteration, getting alignment on structure

**Mid-fidelity (Mid-fi)**
- Actual content and labels
- Basic spacing and hierarchy
- Grayscale or minimal color
- Realistic proportions

**When to use:** Detailed design planning, developer handoff, usability testing structure

**High-fidelity (Hi-fi)**
- Real content, images, data
- Detailed spacing and typography
- Interaction states (hover, active, disabled)
- Near-production visual design

**When to use:** Final approval, visual testing, marketing materials

### Wireframe Content

**Include:**
- Layout structure (grid, containers)
- Navigation (menus, tabs, links)
- Content hierarchy (headings, body, captions)
- Interactive elements (buttons, forms, controls)
- Placeholders for dynamic content
- Annotations explaining functionality

**Don't include (in lo-fi/mid-fi):**
- Final colors or branding
- Actual photography
- Detailed copywriting
- Animations (describe them)

### Wireframing Process

**Step 1: Sketch First**

Start with paper/whiteboard:
- Quick exploration
- Multiple variations
- No commitment to ideas
- Easy to discard

**Step 2: Create Digital Wireframes**

Use tools (Figma, Sketch, Adobe XD, Balsamiq):
- Refine best sketches
- Add labels and annotations
- Link screens together
- Create flow

**Step 3: Annotate**

Explain non-obvious aspects:
- Interaction behavior (What happens on click?)
- Data sources (Where does this come from?)
- Business rules (When is this visible?)
- States (loading, error, empty, success)
- Responsive behavior (How does mobile differ?)

**Example annotation:**
```
[Search Results]
- Default: Show 20 results per page
- Pagination: Load next 20 on "Load More" click
- Empty state: "No results found for '{query}'. Try different keywords."
- Loading: Show skeleton screens for result cards
- Error: "Couldn't load results. [Retry]"
```

### Wireframe Best Practices

**Do:**
- Start low-fidelity, increase detail gradually
- Use consistent elements (buttons, forms)
- Show different states (normal, hover, loading, error)
- Include annotations for clarity
- Test wireframes with users
- Collaborate with developers early

**Don't:**
- Jump to high-fidelity too soon
- Spend time on visual design in wireframes
- Create wireframes in isolation
- Forget responsive considerations
- Assume everyone understands without explanation

## UX Documentation Standards

Document UX decisions to ensure consistent implementation and maintain rationale for future reference.

### UX Design Document Structure

```markdown
# [Feature Name] UX Design

## Overview
Brief description of feature and user value

## User Goals
What users want to accomplish

## Requirements Summary
Key functional and non-functional requirements

## User Journey
High-level journey with touchpoints

## Information Architecture
How content/features are organized

## User Flows
Detailed step-by-step flows for key tasks

## Interaction Patterns
Which patterns used and why

## Wireframes/Mockups
Visual representations with annotations

## Design Rationale
Why key UX decisions were made

## Edge Cases and Error Handling
How unusual situations are handled

## Accessibility Considerations
WCAG compliance and inclusive design

## Success Metrics
How to measure UX effectiveness
```

### Documentation Best Practices

**Be specific:**
- **Vague**: "Make it user-friendly"
- **Specific**: "Validate email on blur, show error below field in red with correction instructions"

**Show, don't just tell:**
- Include wireframes, flows, examples
- Use screenshots for existing patterns
- Provide code snippets for interactions

**Explain the why:**
- Don't just describe what (developers can see that)
- Explain rationale for UX decisions
- Reference principles applied

**Keep it current:**
- Update as design evolves
- Version control (track changes)
- Archive old decisions for reference

**Make it scannable:**
- Use headings and lists
- Include table of contents
- Link between related sections
- Highlight key decisions

## From Requirements to UX: Complete Example

**Requirement:** "Add ability for users to save items for later."

**Analysis:**
- **Users**: Shoppers who aren't ready to purchase
- **Problem**: Lose track of items they're interested in
- **Success**: Save items and find them easily later

**Journey touchpoints:**
- Browsing products → See interesting item → Save for later
- Later: Visit "Saved Items" → Review → Purchase or remove

**IA decision:**
- Add "Saved Items" to primary navigation (alongside Cart, Orders)
- Accessible from user account menu

**User flow:**
```
[Product Page]
↓
User clicks "Save for Later" (heart icon)
↓
System saves to user account
↓
[Toast] "Saved to your list. View saved items"
↓
User continues browsing or clicks toast
↓
[Saved Items Page]
- List of saved items
- "Add to Cart" button each
- "Remove" button each
```

**Interaction patterns:**
- Heart icon (universal save symbol)
- Toast confirmation (non-intrusive)
- Grid layout for saved items (matches product listing)

**Wireframe annotations:**
- "Heart icon: Outlined when not saved, filled when saved"
- "Toast appears bottom-left, auto-dismisses after 4s"
- "Saved items page: Empty state shows 'No saved items yet. Browse products to save items for later.'"

**Rationale:**
- Heart icon: Familiar pattern from social media, e-commerce
- Toast vs. modal: Non-intrusive, doesn't interrupt browsing
- Prominent placement in nav: Encourages use, easy to find
