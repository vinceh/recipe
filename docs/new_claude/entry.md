# Quick Start Guide for AI & Developers

**Last Updated:** 2025-10-19

This folder contains the essential documentation for AI-assisted development of the Recipe App.

---

## MANDATORY Development Workflows

### Backend Development

**BEFORE starting development:**
1. ✅ **Check [acceptance-criteria.md](acceptance-criteria.md)** for existing ACs covering your feature
2. ✅ **If no ACs exist** → STOP and write comprehensive ACs first (GIVEN-WHEN-THEN format)
3. ✅ **Review [api-reference.md](api-reference.md)** → understand existing endpoints to avoid duplication

**AFTER development is complete:**
1. ✅ **Write RSpec tests** for EVERY AC (test-driven development)
2. ✅ **Run `bundle exec rspec`** → 100% pass required (zero failures, zero pending)
3. ✅ **Update [api-reference.md](api-reference.md)** if endpoints were added/modified
4. ✅ **Update other relevant docs** (architecture.md, etc.)
5. ✅ **Mark task complete** in [development-checklist.md](development-checklist.md)

**DO NOT commit if:**
- Any RSpec test fails
- Any AC is missing tests
- API docs are out of date

---

### Frontend Development

**BEFORE starting development:**
1. ✅ **Check [component-library.md](component-library.md)** for existing components
2. ✅ **Reuse existing components** whenever possible (avoid creating duplicates)
3. ✅ **Review [architecture.md](architecture.md)** → understand design system and folder structure

**AFTER development is complete:**
1. ✅ **Document new components** in [component-library.md](component-library.md)
   - Props, emits, slots
   - At least 2 usage examples
2. ✅ **Ensure 100% i18n coverage** (all 7 languages: en, ja, ko, zh-tw, zh-cn, es, fr)
   - See [i18n-workflow.md](i18n-workflow.md) for details
3. ✅ **Run `npm run check:i18n`** → must pass with 100% coverage
4. ✅ **Test in browser** → switch through all 7 languages, verify no `[missing.key]` brackets
5. ✅ **Update [architecture.md](architecture.md)** if new folders/CSS patterns added
6. ✅ **Mark task complete** in [development-checklist.md](development-checklist.md)

**DO NOT commit if:**
- i18n coverage < 100%
- Component not documented
- Missing translations in any language

---

## Quick Navigation

### Core Development Docs

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[development-workflow.md](development-workflow.md)** | Detailed step-by-step workflows | Read this first for comprehensive process |
| **[development-checklist.md](development-checklist.md)** | Master task tracker | Track progress, mark tasks complete |
| **[pre-commit-checklist.md](pre-commit-checklist.md)** | Pre-commit verification | Before EVERY commit |

### Backend Docs

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[acceptance-criteria.md](acceptance-criteria.md)** | All ACs in GIVEN-WHEN-THEN format | BEFORE coding, check for ACs; write new ACs if missing |
| **[api-reference.md](api-reference.md)** | Complete API documentation (50+ endpoints) | Reference when calling APIs; UPDATE when modifying endpoints |
| **[api-documentation-guide.md](api-documentation-guide.md)** | How to document APIs | When adding/modifying API endpoints |
| **[architecture.md](architecture.md)** (Backend section) | Database schema, models, API structure | Understand backend architecture |

### Frontend Docs

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[component-library.md](component-library.md)** | Component catalog with props & examples | Check BEFORE creating new components; UPDATE after building |
| **[architecture.md](architecture.md)** (Frontend section) | Design system, folder structure, styling | Understand design tokens, component organization |
| **[i18n-workflow.md](i18n-workflow.md)** | Complete i18n guide (7 languages) | When adding user-facing text, translations |

### Project Overview

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[project-overview.md](project-overview.md)** | High-level project summary, tech stack | New developers, AI context initialization |

---

## Common Tasks

| I need to... | Use this document |
|-------------|-------------------|
| Find out what to build next | [development-checklist.md](development-checklist.md) |
| Write acceptance criteria | [acceptance-criteria.md](acceptance-criteria.md) (see examples) |
| Find existing API endpoints | [api-reference.md](api-reference.md) |
| Document a new API endpoint | [api-documentation-guide.md](api-documentation-guide.md) |
| Find existing components | [component-library.md](component-library.md) |
| Add translations | [i18n-workflow.md](i18n-workflow.md) |
| Understand design system (colors, spacing, fonts) | [architecture.md](architecture.md#frontend-architecture) → Design System |
| Check pre-commit requirements | [pre-commit-checklist.md](pre-commit-checklist.md) |

---

## Document Organization

```
docs/new_claude/
├── 00-START-HERE.md              ← You are here
├── development-workflow.md       ← Detailed workflows (MANDATORY processes)
├── development-checklist.md      ← Master task list
├── pre-commit-checklist.md       ← Checklist before EVERY commit
├── acceptance-criteria.md        ← All ACs (GIVEN-WHEN-THEN)
├── architecture.md               ← Backend + Frontend architecture
├── api-reference.md              ← Complete API docs
├── api-documentation-guide.md    ← How to document APIs
├── component-library.md          ← Component catalog
└── i18n-workflow.md              ← Translation workflow
```

---

## Golden Rules

### Backend
1. **ACs FIRST** → Write acceptance criteria BEFORE coding
2. **Tests ALWAYS** → RSpec test for EVERY AC
3. **100% Pass** → All tests must pass before commit
4. **Document APIs** → Update api-reference.md when endpoints change

### Frontend
1. **Reuse Components** → Check component-library.md BEFORE creating new ones
2. **100% i18n** → All 7 languages required (no exceptions)
3. **Design Tokens** → Never hardcode colors/spacing (use CSS variables)
4. **Document While Building** → Update component-library.md as you code

---

## Additional Documentation

Other documentation lives in parent folders:

- **[../reference/](../reference/)** - Reference data (dietary tags, cuisines, technical designs, AI prompts)
- **[../planning/](../planning/)** - Historical planning docs (PRD, technical spec, epics)

---

**Last Updated:** 2025-10-19
