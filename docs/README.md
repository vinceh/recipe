# Documentation Guide

**Last Updated:** 2025-10-19

Welcome to the Recipe App (Ember) documentation. This guide will help you navigate all project documentation.

---

## Quick Start

### For AI-Assisted Development
👉 **Start here:** [new_claude/00-START-HERE.md](new_claude/00-START-HERE.md)

This folder contains streamlined documentation optimized for AI context:
- Mandatory development workflows (backend + frontend)
- Quick navigation guide
- All essential development docs

### For Human Developers
1. Read [new_claude/project-overview.md](new_claude/project-overview.md) - High-level project summary
2. Review [new_claude/architecture.md](new_claude/architecture.md) - System architecture
3. Check [new_claude/development-checklist.md](new_claude/development-checklist.md) - Current tasks

---

## Folder Structure

```
docs/
├── README.md                      ← You are here
├── new_claude/                    ← AI CONTEXT (start here!)
│   ├── 00-START-HERE.md          ← Quick navigation + workflows
│   ├── development-workflow.md   ← MANDATORY processes
│   ├── development-checklist.md  ← Master task list
│   ├── pre-commit-checklist.md   ← Checklist before commits
│   ├── acceptance-criteria.md    ← All ACs (GIVEN-WHEN-THEN)
│   ├── architecture.md           ← Backend + Frontend architecture
│   ├── api-reference.md          ← Complete API docs (50+ endpoints)
│   ├── api-documentation-guide.md ← How to document APIs
│   ├── component-library.md      ← Component catalog
│   ├── i18n-workflow.md          ← Translation workflow (7 languages)
│   └── project-overview.md       ← High-level project summary
│
├── reference/                     ← Reference data (rarely changes)
│   ├── data/                     ← Dietary tags, cuisines, dish types, recipe types
│   ├── technical-designs/        ← Nutrition strategy, scaling system
│   └── ai-prompts/               ← AI prompt templates
│
└── planning/                      ← Historical planning docs
    ├── PRD.md                    ← Product Requirements Document
    ├── technical-specification.md ← Detailed tech spec
    ├── epics.md                  ← Epic breakdown
    ├── traceability-matrix.md    ← Requirements traceability
    ├── recipe-app.md             ← Original system specification
    └── project-workflow-analysis.md ← One-time project analysis
```

---

## new_claude/ Folder (AI Context)

**Purpose:** Streamlined documentation for AI-assisted development.

**10 Core Files:**

| File | Purpose | Use When |
|------|---------|----------|
| **[00-START-HERE.md](new_claude/00-START-HERE.md)** | Quick navigation + mandatory workflows | Starting new AI session |
| **[development-workflow.md](new_claude/development-workflow.md)** | Step-by-step backend/frontend workflows | Before starting any development |
| **[development-checklist.md](new_claude/development-checklist.md)** | Master task list with progress tracking | Finding what to build next |
| **[pre-commit-checklist.md](new_claude/pre-commit-checklist.md)** | Pre-commit verification checklist | Before EVERY commit |
| **[acceptance-criteria.md](new_claude/acceptance-criteria.md)** | All ACs in GIVEN-WHEN-THEN format | Writing ACs, writing tests |
| **[architecture.md](new_claude/architecture.md)** | Unified backend + frontend architecture | Understanding system design |
| **[api-reference.md](new_claude/api-reference.md)** | Complete API documentation (50+ endpoints) | Calling APIs, documenting endpoints |
| **[api-documentation-guide.md](new_claude/api-documentation-guide.md)** | How to document APIs | Adding/modifying API endpoints |
| **[component-library.md](new_claude/component-library.md)** | Component catalog with props & examples | Finding components, documenting new ones |
| **[i18n-workflow.md](new_claude/i18n-workflow.md)** | Translation workflow (7 languages) | Adding user-facing text |

---

## reference/ Folder

**Purpose:** Reference data that rarely changes.

### reference/data/
- **[dietary-tags.md](reference/data/dietary-tags.md)** - 40 dietary tags (vegan, gluten-free, etc.)
- **[cuisines.md](reference/data/cuisines.md)** - 99 cuisines (Italian, Japanese, etc.)
- **[dish-types.md](reference/data/dish-types.md)** - 16 dish types (breakfast, dinner, etc.)
- **[recipe-types.md](reference/data/recipe-types.md)** - 74 recipe types (baking, grilling, etc.)
- **[units-and-conversions.md](reference/data/units-and-conversions.md)** - Unit conversion reference

### reference/technical-designs/
- **[nutrition-data-strategy.md](reference/technical-designs/nutrition-data-strategy.md)** - Nutrition data strategy (Nutritionix → proprietary DB)
- **[smart-scaling-system.md](reference/technical-designs/smart-scaling-system.md)** - Smart scaling algorithm design

### reference/ai-prompts/
- **[generate-step-variants.md](reference/ai-prompts/generate-step-variants.md)** - AI prompt for generating step variants

---

## planning/ Folder

**Purpose:** Historical planning documents (for reference).

| File | Purpose | When to Read |
|------|---------|--------------|
| **[PRD.md](planning/PRD.md)** | Product Requirements Document | Understanding product vision |
| **[technical-specification.md](planning/technical-specification.md)** | Detailed tech spec | Deep technical details |
| **[epics.md](planning/epics.md)** | Epic breakdown | Understanding feature scope |
| **[traceability-matrix.md](planning/traceability-matrix.md)** | Requirements traceability | Connecting requirements to implementation |
| **[recipe-app.md](planning/recipe-app.md)** | Original system specification | Historical context |
| **[project-workflow-analysis.md](planning/project-workflow-analysis.md)** | One-time project analysis | Historical context |

---

## Common Tasks

| I need to... | Read this document |
|-------------|-------------------|
| **Start a new AI development session** | [new_claude/00-START-HERE.md](new_claude/00-START-HERE.md) |
| **Find out what to build next** | [new_claude/development-checklist.md](new_claude/development-checklist.md) |
| **Understand mandatory workflows** | [new_claude/development-workflow.md](new_claude/development-workflow.md) |
| **Write acceptance criteria** | [new_claude/acceptance-criteria.md](new_claude/acceptance-criteria.md) (see examples) |
| **Find existing API endpoints** | [new_claude/api-reference.md](new_claude/api-reference.md) |
| **Document a new API endpoint** | [new_claude/api-documentation-guide.md](new_claude/api-documentation-guide.md) |
| **Find existing components** | [new_claude/component-library.md](new_claude/component-library.md) |
| **Add translations** | [new_claude/i18n-workflow.md](new_claude/i18n-workflow.md) |
| **Understand system architecture** | [new_claude/architecture.md](new_claude/architecture.md) |
| **Check pre-commit requirements** | [new_claude/pre-commit-checklist.md](new_claude/pre-commit-checklist.md) |
| **Look up dietary tags or cuisines** | [reference/data/](reference/data/) |
| **Understand nutrition strategy** | [reference/technical-designs/nutrition-data-strategy.md](reference/technical-designs/nutrition-data-strategy.md) |
| **Review product requirements** | [planning/PRD.md](planning/PRD.md) |

---

## Documentation Philosophy

### For AI Context (new_claude/)
- **Streamlined** - 10 essential files only
- **No duplication** - Single source of truth
- **Consolidated** - Related content merged
- **Actionable** - Clear workflows and processes
- **Up-to-date** - Living documents, updated as we build

### For Reference (reference/)
- **Static data** - Rarely changes
- **Lookup tables** - Dietary tags, cuisines, etc.
- **Technical designs** - Deep-dive design docs

### For Planning (planning/)
- **Historical** - Initial planning documents
- **Reference only** - Not actively used in day-to-day development
- **Context** - Understanding "why" decisions were made

---

## Golden Rules

### Backend Development
1. **ACs FIRST** → Write acceptance criteria BEFORE coding
2. **Tests ALWAYS** → RSpec test for EVERY AC
3. **100% Pass** → All tests must pass before commit
4. **Document APIs** → Update api-reference.md when endpoints change

### Frontend Development
1. **Reuse Components** → Check component-library.md BEFORE creating new ones
2. **100% i18n** → All 7 languages required (no exceptions)
3. **Design Tokens** → Never hardcode colors/spacing (use CSS variables)
4. **Document While Building** → Update component-library.md as you code

### Both
- **NO hardcoded text** - Use I18n.t() (backend) or $t() (frontend)
- **Document as you build** - Not after
- **Check pre-commit checklist** - Before EVERY commit

---

## Need Help?

1. **For AI sessions:** Start with [new_claude/00-START-HERE.md](new_claude/00-START-HERE.md)
2. **For workflows:** Read [new_claude/development-workflow.md](new_claude/development-workflow.md)
3. **For architecture:** Review [new_claude/architecture.md](new_claude/architecture.md)
4. **For tasks:** Check [new_claude/development-checklist.md](new_claude/development-checklist.md)

---

**Last Updated:** 2025-10-19
