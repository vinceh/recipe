# UX Design Principles

Core principles for creating effective, usable, and accessible user experiences based on research-backed heuristics and laws of human perception and cognition.

## Nielsen's 10 Usability Heuristics (2025)

Jakob Nielsen's usability heuristics, originally developed in 1990 and refined in 1994, remain the foundation of UX evaluation and design in 2025. These principles apply across all platforms: web, mobile, VR, and AI-powered interfaces.

### 1. Visibility of System Status

The system should always keep users informed about what is going on through appropriate feedback within reasonable time.

**Why it matters:** Users need to understand the current state to make informed decisions about what to do next. Uncertainty creates anxiety and reduces trust.

**Examples:**
- **Good**: Loading spinner with "Uploading... 60%" during file upload
- **Bad**: No feedback after clicking "Submit", leaving users wondering if it worked
- **Good**: "Last saved 2 minutes ago" on a document
- **Bad**: No indication whether edits are auto-saved or not

**Guidelines:**
- Show loading states for operations taking >100ms
- Display progress for operations taking >2 seconds
- Confirm completed actions (checkmark, success message)
- Show current location in multi-step processes (Step 2 of 4)
- Update in real-time (typing indicators, live data updates)

### 2. Match Between System and Real World

The system should speak the users' language, using words, phrases, and concepts familiar to the user, rather than system-oriented terms. Follow real-world conventions.

**Why it matters:** Users understand familiar concepts faster and make fewer mistakes when the interface matches their mental model.

**Examples:**
- **Good**: "Shopping Cart" for e-commerce (familiar metaphor)
- **Bad**: "Item Aggregation Container"
- **Good**: Calendar view that looks like a physical calendar
- **Bad**: Date selection requiring manual text entry in ISO format
- **Good**: "Trash" or "Recycle Bin" for deleted items (can be restored)
- **Bad**: "Terminate instance" without explanation

**Guidelines:**
- Use domain-specific vocabulary users know
- Avoid jargon and technical terms unless user base is technical
- Organize information logically (chronological, alphabetical, spatial)
- Use familiar icons (trash, save, search) with labels when ambiguous
- Match physical world conventions (red = stop/danger, green = go/success)

### 3. User Control and Freedom

Users often choose system functions by mistake and need a clearly marked "emergency exit" to leave the unwanted state without having to go through an extended dialogue. Support undo and redo.

**Why it matters:** Mistakes are inevitable. Users need confidence they can explore without consequence.

**Examples:**
- **Good**: Undo/Redo buttons always visible in editor
- **Bad**: No way to undo accidental deletion
- **Good**: "Cancel" button on forms before submission
- **Bad**: Form submission with no confirmation or way to cancel
- **Good**: 30-day trash bin before permanent deletion
- **Bad**: Immediate permanent deletion

**Guidelines:**
- Provide undo/redo for all reversible actions
- Include clear "Cancel" or "Back" options
- Allow users to exit multi-step processes at any time
- Don't force users down a single path
- Make it easy to correct mistakes

### 4. Consistency and Standards

Users should not have to wonder whether different words, situations, or actions mean the same thing. Follow platform conventions and internal consistency.

**Why it matters:** Inconsistency increases cognitive load and error rates. Users rely on patterns.

**Examples:**
- **Good**: "Save" button always in top-right corner
- **Bad**: "Save" sometimes top-right, sometimes bottom-left
- **Good**: Blue color consistently means clickable links
- **Bad**: Blue text sometimes clickable, sometimes just emphasis
- **Good**: Following iOS Human Interface Guidelines on iOS apps
- **Bad**: Custom, non-standard interaction patterns on iOS

**Guidelines:**
- Use platform conventions (iOS, Android, Web standards)
- Maintain visual consistency (colors, typography, spacing)
- Keep interaction patterns consistent throughout
- Use standard terminology consistently
- Position common elements (navigation, actions) in expected locations

### 5. Error Prevention

Prevent errors from occurring in the first place through good design. Eliminate error-prone conditions or check for them and present users with a confirmation option before they commit to the action.

**Why it matters:** Prevention is better than recovery. Users should not be allowed to make critical mistakes easily.

**Examples:**
- **Good**: Disable "Submit" button until all required fields are valid
- **Bad**: Allow submission, then show error
- **Good**: "Are you sure you want to delete? This cannot be undone" confirmation
- **Bad**: Single-click permanent deletion
- **Good**: Inline form validation showing errors as user types
- **Bad**: Only showing errors after form submission

**Guidelines:**
- Validate input in real-time
- Disable invalid actions rather than allowing then rejecting
- Require confirmation for destructive actions (delete, overwrite)
- Provide constraints (date pickers instead of text entry)
- Use smart defaults to minimize user input

### 6. Recognition Rather Than Recall

Minimize the user's memory load by making objects, actions, and options visible. The user should not have to remember information from one part of the dialogue to another.

**Why it matters:** Human working memory is limited (7±2 items). Recognition is easier than recall.

**Examples:**
- **Good**: Show password requirements alongside password field
- **Bad**: Show requirements only on error
- **Good**: Autocomplete with recent searches visible
- **Bad**: Requiring users to remember exact search terms
- **Good**: Show keyboard shortcuts in menu items
- **Bad**: Require memorization of all shortcuts

**Guidelines:**
- Make options visible (don't hide in menus unnecessarily)
- Provide helpful defaults and suggestions
- Show recently used items
- Use tooltips for additional context
- Keep instructions visible, not hidden in help docs

### 7. Flexibility and Efficiency of Use

Accelerators—unseen by novice users—may speed up interaction for expert users such that the system can cater to both inexperienced and experienced users. Allow users to tailor frequent actions.

**Why it matters:** Users grow from novices to experts. The interface should support both.

**Examples:**
- **Good**: Keyboard shortcuts for power users, mouse clicks for novices
- **Bad**: Keyboard-only interface
- **Good**: "Save as..." option plus ability to set default save location
- **Bad**: Forcing every user through same multi-click save dialog
- **Good**: Search with filters collapsed by default, expandable for power users
- **Bad**: All 20 filters always visible

**Guidelines:**
- Provide keyboard shortcuts for common actions
- Allow customization of frequent tasks
- Support both basic and advanced modes
- Use progressive disclosure (show basics, hide advanced)
- Remember user preferences and settings

### 8. Aesthetic and Minimalist Design

Dialogues should not contain information which is irrelevant or rarely needed. Every extra unit of information competes with relevant units and diminishes their relative visibility.

**Why it matters:** Clutter reduces comprehension and slows task completion. Focus enables speed.

**Examples:**
- **Good**: Dashboard showing only 4 key metrics prominently
- **Bad**: Dashboard with 40 metrics in tiny text
- **Good**: Form with 3 required fields, "More options" link for optional
- **Bad**: Form with 15 fields, only 3 required
- **Good**: Clean email with clear CTA button
- **Bad**: Email with 5 CTAs and decorative images

**Guidelines:**
- Remove unnecessary elements
- Use visual hierarchy to emphasize important content
- Hide rarely used options behind "Advanced" or "More"
- Use whitespace to create breathing room
- One primary action per screen/dialog

### 9. Help Users Recognize, Diagnose, and Recover from Errors

Error messages should be expressed in plain language (no codes), precisely indicate the problem, and constructively suggest a solution.

**Why it matters:** Errors are stressful. Good error messages reduce frustration and help users continue.

**Examples:**
- **Good**: "Email already registered. Try logging in or use a different email."
- **Bad**: "Error 422: Unprocessable Entity"
- **Good**: "Password must be at least 8 characters with 1 number"
- **Bad**: "Invalid password"
- **Good**: "File too large (5MB). Maximum size is 2MB. Try compressing the file."
- **Bad**: "Upload failed"

**Guidelines:**
- Use plain language, not error codes
- Explain what went wrong
- Suggest how to fix it
- Provide recovery paths
- Use appropriate severity (error vs. warning vs. info)

### 10. Help and Documentation

It's best if the system can be used without documentation. However, it may be necessary to provide help and documentation. Such information should be easy to search, focused on the user's task, list concrete steps, and not be too large.

**Why it matters:** Users rarely read documentation proactively. Help should be contextual and just-in-time.

**Examples:**
- **Good**: Contextual tooltips on hover
- **Bad**: Link to 50-page PDF manual
- **Good**: Inline help text: "Invoice number is on the top-right of your invoice"
- **Bad**: "Refer to documentation for invoice number location"
- **Good**: Searchable FAQ with task-based questions
- **Bad**: Alphabetical list of every feature

**Guidelines:**
- Provide contextual help (tooltips, inline hints)
- Make help searchable
- Focus on tasks, not features
- Provide concrete examples
- Keep help concise and scannable

## Gestalt Principles

Gestalt principles describe how humans perceive and group visual elements. Applying these creates intuitive, organized interfaces.

### Proximity

Elements close together are perceived as related. Use spacing to create visual groups.

**Application:** Group related form fields, separate sections with whitespace, place labels near their controls.

### Similarity

Similar elements are perceived as related. Use consistent styling for related items.

**Application:** All buttons styled similarly, all headings in same font, all errors in red.

### Closure

Humans mentally complete incomplete shapes. Use this for efficiency.

**Application:** Use icon outlines instead of filled icons, hamburger menu implies a list, loading spinners imply ongoing process.

### Continuity

Eyes follow lines and curves. Use this to guide attention.

**Application:** Align elements along invisible lines, use directional cues (arrows, eye gaze in photos), create reading flow top-to-bottom, left-to-right.

### Figure-Ground

Distinguish foreground from background through contrast.

**Application:** Modal overlays with darkened background, cards on colored backgrounds, highlighted selected items.

## Fitts's Law

The time to acquire a target is a function of the distance to and size of the target. Larger, closer targets are faster to click.

**Application:**
- Make primary actions larger (bigger buttons)
- Place frequently used controls closer to starting position
- Use screen edges and corners (infinite size in one direction)
- Increase touch targets to minimum 44x44 pixels (iOS) or 48x48 pixels (Material)

## Hick's Law

The time to make a decision increases logarithmically with the number of choices. More options = slower decisions.

**Application:**
- Limit menu items (5-7 is optimal)
- Use progressive disclosure (show fewer options initially)
- Provide smart defaults to reduce decisions
- Categorize large option sets
- Consider "More options" for rarely used features

## Cognitive Load

Human working memory is limited (7±2 items). Reduce cognitive load for better UX.

**Strategies:**
- **Chunk information**: Group related items (phone numbers: 555-123-4567 not 5551234567)
- **Use recognition over recall**: Show options instead of requiring memory
- **Provide defaults**: Reduce decisions users must make
- **Use progressive disclosure**: Don't show everything at once
- **Minimize distractions**: Remove irrelevant information

## Progressive Disclosure

Show only essential information initially, revealing details as needed. This reduces cognitive load and focuses attention.

**Techniques:**
- **Accordion menus**: Expand sections on demand
- **"Show more" links**: Reveal additional content
- **Tooltips**: Show details on hover
- **Advanced modes**: Hide complex features from beginners
- **Wizards**: Break complex tasks into simple steps

**Example:** Gmail compose—basic recipient/subject/body visible, CC/BCC/attachments hidden until needed.

## Accessibility as UX Foundation (WCAG 2.2)

Accessibility is not separate from UX—it's foundational. WCAG 2.2 Level AA is the minimum standard in 2025.

### Perceivable

**Color contrast:** 4.5:1 for text, 3:1 for UI components
**Alternative text:** All images need descriptive alt text
**Captions:** Videos need captions and transcripts

### Operable

**Keyboard navigation:** All features accessible via keyboard
**Focus indicators:** Clear visual focus on interactive elements
**Sufficient time:** Don't auto-advance without user control

### Understandable

**Plain language:** Clear, simple text
**Consistent navigation:** Predictable patterns
**Input assistance:** Help users avoid and correct errors

### Robust

**Semantic HTML:** Proper use of headings, landmarks, lists
**ARIA labels:** When semantic HTML insufficient
**Screen reader testing:** Test with VoiceOver (iOS), TalkBack (Android)

## Mobile-First UX (2025)

In 2025, mobile-first is not optional—mobile traffic exceeds desktop globally.

**Principles:**
- Design for smallest screen first, progressively enhance
- Use thumb-friendly zones (bottom third of screen)
- Touch targets minimum 44-48 pixels
- Minimize text entry (use pickers, autocomplete, biometrics)
- Consider one-handed use
- Optimize for spotty connectivity
- Use device capabilities (camera, location, biometrics)

## Applying Principles Together

Great UX results from applying multiple principles simultaneously:

1. **Start with user goals** (Match with real world)
2. **Design clear paths** (Recognition over recall)
3. **Show status** (Visibility of system status)
4. **Prevent errors** (Error prevention)
5. **Allow undo** (User control and freedom)
6. **Be consistent** (Consistency and standards)
7. **Minimize distractions** (Aesthetic and minimalist)
8. **Support all users** (Flexibility and efficiency)
9. **Handle errors gracefully** (Help users recover)
10. **Provide help contextually** (Help and documentation)

## Validation Checklist

Use this checklist to validate UX against core principles:

- [ ] Users always know system status
- [ ] Language matches user's mental model
- [ ] Users can undo mistakes easily
- [ ] Patterns are consistent throughout
- [ ] Critical errors are prevented
- [ ] Options are visible, not hidden
- [ ] Both novice and expert users supported
- [ ] Interface is clean and focused
- [ ] Errors are helpful and constructive
- [ ] Help is contextual and searchable
- [ ] Related elements are visually grouped
- [ ] Important targets are large and close
- [ ] Choices are limited to reduce decision time
- [ ] Information is chunked appropriately
- [ ] WCAG 2.2 AA standards met
