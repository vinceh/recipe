# User Feedback Patterns & Learned Preferences

**Purpose:** Captures recurring feedback patterns from user V to improve quality proactively.

**Format:** Super concise. One-liners with context. Date-stamped for learning velocity.

---

## Document Quality Patterns

**2025-10-07:** User pointed out nutrition strategy wasn't in proper section, just listed at bottom → **Always place new content in logical sections within the document, not just appended at end**

**2025-10-07:** User noticed brainstorming file needed reorganization → **Before declaring document complete, review full structure for logical flow, not just the section you edited**

**2025-10-07:** User said "i don't see the file" twice for subagent-created files → **Always verify subagent file creation with `ls` immediately after task completes**

**2025-10-07:** User: "you haven't updated the tech spec file... the tech spec now has data not congruent with current status" → **When updating reference files, IMMEDIATELY update tech spec to match. Documents must stay synchronized**

---

## Reference & Completeness Patterns

**2025-10-07:** User asked "why nutritionix over something else?" → **Major technical decisions need rationale/comparison section, not just the decision itself**

**2025-10-07:** User wanted all references "updated, clear, and complete" → **Every file reference should include brief description of what it contains, not just filename**

---

## Communication Patterns

**2025-10-07:** User prefers concise responses → **Match verbosity to task complexity. Simple tasks = brief confirmation. Complex tasks = summary with key points only**

---

## Work Habits & Preferences

**2025-10-07:** User needs to easily hand-adjust UI → **Frontend architecture must prioritize simplicity and adjustability: component-based, clear separation, minimal abstractions, easy to understand and modify**

**2025-10-07:** User pointed out "i don't see anything about volt primevue" after it was mentioned in tech stack → **When a technology is mentioned in tech stack/decisions, it MUST have a dedicated section with: what it is, why chosen, setup code, usage examples, customization guide. Don't just list it - explain it fully**

**2025-10-07:** User: "in the AI integrations section, there's still hardcoded prompts, they should be updated to use references - this is a large quality standards gap" → **When adding a new system/pattern (like database-driven prompts), ALL related code sections must be updated to use it. Search entire document for old patterns and replace them. Document-wide consistency is critical**

---

## Anti-patterns (Things User Dislikes)

<!-- Add patterns here as they emerge -->

---

**Note:** This document auto-evolves. Keep entries atomic and actionable. Remove redundant patterns once they're internalized into quality-standards.md or other guidance docs.
