# Feature Planning Command

Plan a new feature through collaborative requirements gathering and codebase analysis.

## Phase 0: Context Loading

1. Read `docs/new_claude/entry.md` to understand the project workflow
2. Launch parallel subagents to explore:
   - Backend: models, controllers, services in `backend/app/`
   - Frontend: components, views, stores in `frontend/src/`
3. Build mental model of current architecture before proceeding

## Phase 1: Requirements Clarification

Ask the user what they want to build, then:

1. Ask clarifying questions to understand:
   - What problem does this solve?
   - Who is the user (admin, public user, both)?
   - What are the core behaviors/interactions?
   - Are there any constraints or dependencies?

2. Continue back-and-forth until both parties agree on scope

3. Summarize the agreed feature in 1-2 sentences before proceeding

## Phase 2: Deep Codebase Analysis

Before writing the plan, thoroughly investigate:

**Backend:**
- Which existing models will be affected?
- What new models/migrations are needed?
- Which controllers need modification?
- Are there existing services to extend?
- What API endpoints are needed?

**Frontend:**
- Which existing components can be reused?
- What new components are needed?
- Which views need modification?
- What store changes are required?
- What i18n keys need to be added?

Use Task tool with Explore agents to gather this information.

## Phase 3: Write Development Plan

Create file: `current_dev/YYYYMMDD-feature-name.md`

Format:
```markdown
# Feature: [Feature Name]

**Description:** [1-2 sentence summary of what this feature does]

**Date:** YYYY-MM-DD

---

## Stories

### Backend

- [ ] Story 1: [Brief description]
  - AC: [What defines "done"]
  - Files: [Affected files]

- [ ] Story 2: [Brief description]
  - AC: [What defines "done"]
  - Files: [Affected files]

### Frontend

- [ ] Story 1: [Brief description]
  - AC: [What defines "done"]
  - Files: [Affected files]

- [ ] Story 2: [Brief description]
  - AC: [What defines "done"]
  - Files: [Affected files]

---

## Notes

[Any implementation notes, dependencies, or considerations]
```

## Rules

- Stories should be small, atomic units of work (1-2 hours each ideally)
- Each story must have clear acceptance criteria
- Stories should be ordered by dependency (what needs to be done first)
- Include file paths where changes will be made
- Do NOT start implementation - only output the plan file
