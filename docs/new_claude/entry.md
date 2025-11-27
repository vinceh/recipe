# Recipe App - Quick Start

Rails API + Vue 3 SPA with PostgreSQL. 7 languages: en, ja, ko, zh-tw, zh-cn, es, fr.

## Golden Rule
**ACs → Tests → Code → 100% Pass → Docs → Commit**

## Backend Workflow

- **Before:** Write ACs (GIVEN-WHEN-THEN format) in acceptance-criteria.md if missing
- **Before:** Check api-reference.md for existing endpoints
- **During:** Write RSpec tests for each AC (reference AC IDs in test names)
- **During:** Implement with I18n.t() for all user-facing text (7 languages)
- **After:** Run `bundle exec rspec` → must be 100% pass (0 failures, 0 pending)
- **After:** Update api-reference.md if endpoints changed
- **After:** Commit with AC IDs in message

## Frontend Workflow

- **Before:** Write ACs (GIVEN-WHEN-THEN format) in acceptance-criteria.md if missing
- **Before:** Check component-library.md for existing reusable components
- **During:** Implement with $t() for all text (add to all 7 locale JSON files)
- **During:** Use CSS variables from variables.css (never hardcode colors/spacing)
- **During:** Write Playwright tests for each AC (reference AC IDs in test names)
- **After:** Run `npm run check:i18n` → must be 100%
- **After:** Test in browser: switch through all 7 languages, verify no `[missing.key]`
- **After:** Run `npm run test:e2e` → must be 100% pass (0 failures)
- **After:** Update component-library.md with props, emits, examples
- **After:** Commit

## Key Documentation

- **architecture.md** - Tech stack, database schema, design system, CSS variables
- **api-reference.md** - All API endpoints with cURL examples
- **component-library.md** - All Vue components with props and usage
- **acceptance-criteria.md** - All ACs in GIVEN-WHEN-THEN format
- **i18n-workflow.md** - Translation workflow and best practices
- **database-architecture.md** - Complete DB field documentation

## Never

- Hardcode user-facing text (use I18n.t() or $t())
- Hardcode CSS values (use var(--spacing-md), var(--color-text), etc.)
- Code without ACs
- Commit with failing tests (<100% pass)
- Skip component or API documentation
