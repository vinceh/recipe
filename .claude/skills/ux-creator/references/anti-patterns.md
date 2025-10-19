# UX Anti-Patterns

Common UX mistakes and dark patterns to avoid. Each anti-pattern includes bad vs. good examples showing how to fix the issue.

## Navigation and Information Architecture

### 1. Hidden Navigation (Mystery Meat)

**Problem:** Navigation hidden behind unclear icons or obscure interactions.

**Why it's bad:** Users waste time hunting for features, abandoning tasks when they can't find what they need.

**Bad example:**
- Single hamburger menu containing all 15 navigation items
- No visible navigation on homepage
- Icons without labels that don't clearly indicate function

**Good example:**
- Bottom tab bar with 4-5 primary sections (icons + labels)
- Hamburger menu only for secondary/less frequent items
- Clear, recognizable icons with text labels

**Fix:** Make primary navigation always visible. Use progressive disclosure for secondary navigation.

### 2. Inconsistent Navigation

**Problem:** Navigation changes location, style, or structure between pages.

**Why it's bad:** Users must relearn navigation on each page, increasing cognitive load and frustration.

**Bad example:**
- Homepage has top horizontal menu
- Product pages have sidebar navigation
- Checkout has no navigation at all
- Settings has bottom navigation

**Good example:**
- Consistent primary navigation in same location on all pages
- May hide on checkout to reduce distractions, but structure remains

**Fix:** Keep navigation structure, position, and styling consistent throughout application.

### 3. Deep Hierarchy

**Problem:** Content buried 5+ levels deep requiring many clicks to reach.

**Why it's bad:** Users give up before reaching goal. Violates "3-click rule" guideline.

**Bad example:**
```
Home → Products → Category → Subcategory → Sub-subcategory → Product
(5 clicks to reach a product)
```

**Good example:**
```
Home → Products with filters → Product
(2 clicks, use filters instead of hierarchy)
```

**Fix:** Flatten hierarchy to maximum 3 levels. Use search, filters, and faceted navigation instead of deep nesting.

## Forms and Input

### 4. No Inline Validation

**Problem:** Form only validates on submit, showing all errors at once after user fills entire form.

**Why it's bad:** Users invest time filling form only to discover multiple errors. Frustrating to fix all at once.

**Bad example:**
- User fills 10-field form
- Clicks "Submit"
- Page reloads showing 6 errors at top
- User must scroll to find each problematic field

**Good example:**
- Validation happens on blur (when user leaves field)
- Errors shown immediately below field with fix instructions
- Checkmark shows valid fields
- Submit button enabled, but shows summary of remaining errors if clicked early

**Fix:** Validate fields on blur, show errors inline immediately, use constructive error messages.

### 5. Cryptic Error Messages

**Problem:** Error messages that don't explain problem or solution.

**Why it's bad:** Users don't know what went wrong or how to fix it. Increases support burden.

**Bad examples:**
- "Error 422"
- "Invalid input"
- "Operation failed"
- "Bad request"

**Good examples:**
- "Email already registered. Try logging in or use a different email."
- "Password must be at least 8 characters with 1 number and 1 special character."
- "File size too large (5MB). Maximum allowed is 2MB. Try compressing the file."
- "Connection lost. Check your internet and try again."

**Fix:** Use plain language, explain what's wrong, suggest how to fix, provide recovery path.

### 6. Required Fields Not Marked

**Problem:** Users don't know which fields are required until form submission fails.

**Why it's bad:** Wastes time, creates frustration, increases abandonment.

**Bad example:**
- 10-field form with no indication which are required
- User submits with only 5 fields filled
- Error: "Please fill all required fields"
- User must guess which ones

**Good example:**
- Required fields marked with asterisk (*) or "(required)" label
- Legend at top: "* indicates required field"
- Or mark optional fields with "(optional)"
- Provide clear guidance upfront

**Fix:** Mark required fields clearly before user starts filling form.

### 7. Asking for Too Much Information

**Problem:** Forms request unnecessary information.

**Why it's bad:** Reduces completion rates. Every additional field decreases conversion.

**Bad example:**
- Newsletter signup asking for: First name, Last name, Email, Phone, Company, Title, Industry, Company size, Country
- Only email is actually needed

**Good example:**
- Newsletter signup asking only for email
- Collect additional information later if needed, after user is engaged

**Fix:** Only ask for information you truly need now. Collect optional data later when value is established.

## Feedback and Communication

### 8. No Loading States

**Problem:** No indication that system is processing.

**Why it's bad:** Users wonder if click registered, click multiple times, lose trust.

**Bad example:**
- Click "Submit Order" button
- No loading indicator
- Button remains clickable
- No feedback for 3+ seconds

**Good example:**
- Click "Submit Order"
- Button shows spinner and text changes to "Processing..."
- Button disabled during processing
- Success message appears when complete

**Fix:** Show loading state for any operation taking >100ms. Use progress bars for operations >3 seconds.

### 9. Auto-Advancing Carousels

**Problem:** Carousel automatically rotates slides on timer.

**Why it's bad:** Users reading slide get interrupted. Accessibility nightmare for screen readers. Low interaction rates.

**Bad example:**
- Homepage carousel rotating every 3 seconds
- User reading slide 2, carousel auto-advances to slide 3
- No way to pause
- Carousel cycles through while screen reader reads previous slide

**Good example:**
- Static hero section with primary message
- Or manual carousel with clear controls:
  - Pause button (required for WCAG)
  - Previous/Next buttons
  - Dot indicators showing position
  - Only advances on user interaction

**Fix:** Don't auto-advance. If you must, provide pause button and allow 5+ seconds per slide minimum.

### 10. Modal Overload

**Problem:** Excessive use of modal dialogs interrupting user flow.

**Why it's bad:** Interrupts user tasks, creates frustration, users develop "banner blindness" and dismiss without reading.

**Bad example:**
- Newsletter popup on page load
- Cookie consent modal
- Discount offer modal
- "Rate our app" modal
- All within first 30 seconds

**Good example:**
- Cookie consent as banner (non-modal) at bottom
- Newsletter signup as dismissible callout, not modal
- Offers shown contextually (not on entry)
- Rating request after user accomplishes something (not randomly)

**Fix:** Use modals sparingly for critical decisions only. Use toasts, banners, or inline messages for non-critical information.

## Content and Copy

### 11. Jargon and Technical Terms

**Problem:** Interface uses system-oriented terminology users don't understand.

**Why it's bad:** Users don't know what features do, make mistakes, avoid using features.

**Bad examples:**
- "Flush cache"
- "Terminate instance"
- "Deallocate resources"
- "Serialize data"

**Good examples:**
- "Clear saved data"
- "Stop server"
- "Free up space"
- "Export data"

**Fix:** Use plain language users understand. Explain technical terms if you must use them.

### 12. No Empty States

**Problem:** Blank screen when no content exists.

**Why it's bad:** Users don't know what should be here or how to proceed. Feels broken.

**Bad example:**
- "Projects" page shows nothing
- Blank white screen
- No indication this is intentional

**Good example:**
```
No projects yet
Create your first project to start collaborating with your team.
[+ Create Project]

Or import an existing project
[Import Project]
```

**Fix:** Design helpful empty states explaining what belongs here and how to add it.

## Dark Patterns (Deceptive Design)

### 13. Disguised Ads

**Problem:** Ads designed to look like content or navigation.

**Why it's bad:** Deceptive, erodes trust, users feel tricked, may violate regulations.

**Bad example:**
- "Download" button that's actually an ad
- "Continue" button that enrolls in subscription
- "Recommended articles" that are all sponsored

**Good example:**
- Clearly labeled "Advertisement" or "Sponsored"
- Visual distinction from regular content
- Actual action buttons clearly labeled

**Fix:** Never deceive users. Clearly distinguish ads from content and actions.

### 14. Roach Motel (Hard to Cancel)

**Problem:** Easy to sign up, extremely difficult to cancel.

**Why it's bad:** Deceptive, illegal in many jurisdictions, destroys trust, generates negative word-of-mouth.

**Bad example:**
- Sign up online in 2 clicks
- Cancellation requires calling phone number during business hours
- Or cancellation buried 5 levels deep in settings
- Or "Are you SURE? You'll lose EVERYTHING!" with misleading buttons

**Good example:**
- Cancellation as easy as sign-up
- Clear "Cancel Subscription" in account settings
- Simple confirmation: "Cancel subscription? You can resubscribe anytime."
- Process completes immediately online

**Fix:** Make cancellation as easy as sign-up. Required by law in many places (California, EU).

### 15. Forced Continuity

**Problem:** Free trial ends and automatically charges without clear warning.

**Why it's bad:** Users feel tricked, leads to chargebacks, destroys trust, often illegal.

**Bad example:**
- Free trial starts, credit card required
- No email warning before trial ends
- Automatic charge on day 8 with no notification

**Good example:**
- Clear notice: "Free for 7 days, then $9.99/month. Cancel anytime."
- Email 2 days before trial ends: "Your trial ends in 2 days"
- Charge notification email: "You've been charged $9.99 for Premium"
- Easy cancellation before and after charge

**Fix:** Be transparent about charges. Warn before charging. Allow easy cancellation.

## Accessibility Violations

### 16. Insufficient Color Contrast

**Problem:** Text/UI elements don't have enough contrast with background.

**Why it's bad:** Unreadable for users with low vision or in bright sunlight. Fails WCAG.

**Bad examples:**
- Light gray text (#AAAAAA) on white background (2.3:1 ratio)
- Blue button (#4B8EF5) with white text (2.9:1 ratio)

**Good examples:**
- Dark gray text (#595959) on white background (7.0:1 ratio - AAA)
- Blue button (#0056B3) with white text (4.6:1 ratio - AA)

**Fix:** Maintain 4.5:1 ratio for normal text, 3:1 for large text and UI components. Use contrast checker tools.

### 17. Click Targets Too Small

**Problem:** Buttons, links, or interactive elements too small to accurately tap.

**Why it's bad:** Users miss targets, hit wrong elements, frustrating on mobile, fails WCAG.

**Bad example:**
- Touch targets 30x30 pixels
- Closely spaced links with no padding

**Good example:**
- Minimum 44x44 pixels (iOS) or 48x48 pixels (Android)
- Adequate spacing between targets (8px minimum)

**Fix:** Ensure all interactive elements meet minimum touch target sizes with adequate spacing.

### 18. Keyboard Navigation Broken

**Problem:** Can't navigate or use interface with keyboard only.

**Why it's bad:** Blocks users who can't use mouse (motor disabilities, power users). Fails WCAG.

**Bad example:**
- Modal can't be closed with Escape key
- Tab order jumps around illogically
- No visible focus indicators
- Dropdown requires mouse hover

**Good example:**
- All interactive elements reachable via Tab
- Logical tab order (top to bottom, left to right)
- Clear focus indicators (outline or highlight)
- Escape closes modals
- Enter/Space activates buttons

**Fix:** Ensure complete keyboard navigation. Test by using site without mouse.

## Mobile-Specific Anti-Patterns

### 19. Unreadable Text

**Problem:** Text too small to read on mobile.

**Why it's bad:** Forces zooming, poor experience, often indicates non-responsive design.

**Bad example:**
- Body text at 12px on mobile
- Fine print at 8px
- User must pinch-zoom to read

**Good example:**
- Body text minimum 16px on mobile
- Headlines 24px+
- All text readable without zooming

**Fix:** Use responsive typography. Minimum 16px for body text on mobile.

### 20. Blocking Content with Overlays

**Problem:** Fixed headers, footers, or popups that block content on mobile.

**Why it's bad:** Reduces already-limited screen space, prevents accessing content.

**Bad example:**
- Fixed header (60px) + sticky footer (80px) + cookie banner (100px) = 240px blocked
- On 667px phone, only 427px visible (36% content area)

**Good example:**
- Minimal or collapsing header on scroll
- Dismissible banners
- No sticky footer on mobile
- 90%+ of screen available for content

**Fix:** Minimize fixed elements on mobile. Make overlays dismissible. Prioritize content area.

### 21. Desktop Site on Mobile

**Problem:** No responsive design, desktop site shown on mobile.

**Why it's bad:** Tiny text, unusable navigation, horizontal scrolling, poor experience.

**Bad example:**
- Desktop site with 1200px min-width on 375px phone
- User must pinch-zoom and scroll horizontally
- Buttons too small to tap
- Forms impossible to fill

**Good example:**
- Responsive design that adapts to screen size
- Single-column layout on mobile
- Touch-friendly targets
- Mobile-optimized forms

**Fix:** Use responsive design. Mobile-first approach. Test on real devices.

## Performance Anti-Patterns

### 22. No Performance Optimization

**Problem:** Slow load times, laggy interactions, heavy pages.

**Why it's bad:** Users abandon slow sites (53% leave if load takes >3 seconds). Impacts SEO, conversions, satisfaction.

**Bad example:**
- 5MB homepage with unoptimized images
- Loads all data upfront instead of lazy loading
- No caching
- 8 second load time

**Good example:**
- Optimized images (<200KB)
- Lazy loading for below-fold content
- Caching strategy
- <2 second load time

**Fix:** Optimize images, lazy load, cache assets, measure with Lighthouse.

## Visual Design Anti-Patterns

### 23. Cluttered Interface

**Problem:** Too many elements, information, options visible at once.

**Why it's bad:** Overwhelming, hard to focus, slow task completion, decision paralysis.

**Bad example:**
- Dashboard with 40 widgets all visible
- Homepage with 30 CTAs
- Form with 20 fields all required upfront

**Good example:**
- Dashboard with 4-6 key metrics, "View all" for more
- Homepage with single clear primary CTA
- Multi-step form showing 3-5 fields per step

**Fix:** Apply "aesthetic and minimalist design" heuristic. Hide secondary information behind progressive disclosure.

### 24. Poor Visual Hierarchy

**Problem:** All elements same size/weight, unclear what's important.

**Why it's bad:** Users don't know where to look or what to do first. Increases cognitive load.

**Bad example:**
- All headings same size
- Primary and secondary buttons styled identically
- No use of whitespace to group related items

**Good example:**
- Clear heading hierarchy (H1 > H2 > H3)
- Primary button prominent, secondary subtle
- Whitespace groups related elements

**Fix:** Use size, weight, color, and spacing to create clear hierarchy. Guide user attention.

## Preventing Anti-Patterns

**Process improvements:**
1. **User testing**: Test with real users early and often
2. **Accessibility audits**: Use automated tools + manual testing
3. **Analytics review**: Identify where users struggle
4. **Heuristic evaluation**: Systematically check against best practices
5. **Competitive analysis**: Learn from others' mistakes
6. **Design system**: Enforce consistency and best practices
7. **Code reviews**: Catch anti-patterns before production

**Questions to ask:**
- Is this deceptive or manipulative in any way?
- Would I be frustrated by this as a user?
- Does this respect user's time and attention?
- Is this accessible to all users?
- Am I asking for more than I need?
- Is this pattern proven and familiar?
- Have I tested this with real users?

**When in doubt:** Choose the user-friendly option. Short-term growth hacks damage long-term trust.
