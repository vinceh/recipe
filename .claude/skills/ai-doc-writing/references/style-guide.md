# AI-Optimized Documentation Style Guide

**Core Principles:** Completeness + Efficiency + Zero Fluff

Documentation should be optimized for AI consumption (LLM context), not human reading. This means:
- **Atomic bullet points** over prose paragraphs
- **Structured data** (YAML/code blocks) over explanations
- **No meta-commentary**, transition phrases, or justifications
- **Proper hierarchy** so AI can understand relationships
- **Examples only when they reveal behavior** not obvious from description

---

## 1. Structure & Format

### Use bullets for atomic information
Each bullet = one self-contained idea that will be chunked separately by passage-level indexing.

**❌ Bad: Prose**
```
The system uses dedicated translation tables for each model.
This approach provides better queryability than JSONB storage.
```

**✅ Good: Atomic bullets**
```
**Storage:** Dedicated translation tables (not JSONB)
**Benefit:** Better queryability and transaction isolation
```

### Use structured data when describing configuration/relationships
YAML/JSON blocks are more scannable than explanatory prose.

**❌ Bad: Explanation**
```
We support 6 languages with a fallback chain. Japanese falls back to English,
Korean falls back to English, Traditional Chinese falls back to Simplified Chinese,
and so on.
```

**✅ Good: Structured**
```
**Fallback chain:**
- ja → en
- ko → en
- zh-tw → zh-cn → en
- zh-cn → zh-tw → en
- es → en
- fr → en
```

### Code examples should have minimal context
No "Here's how to do X" preamble if the example is self-explanatory.

**❌ Bad: Explanatory preamble**
```
To read a translation in a specific locale, you wrap your code in
an I18n.with_locale block, which sets the locale context for all
translatable fields accessed within it:

I18n.with_locale(:ja) { recipe.name }
```

**✅ Good: Minimal context**
```
**Read translation:**
```ruby
I18n.with_locale(:ja) { recipe.name }
```
```

---

## 2. Heading Hierarchy

AI builds mental models from heading structure. **Never skip levels** (e.g., H2 → H4 is forbidden).

**❌ Bad: Skipped levels**
```
## Configuration

The system uses...

#### Translation Tables
```

**✅ Good: Proper progression**
```
## Configuration

### Translation System
#### Translation Tables
```

**Rule:** Always progress H1 → H2 → H3 → H4 without skipping.

---

## 3. Consistency

Use one term consistently. Synonym variation confuses AI's mental model.

**❌ Bad: Synonym variation**
```
The system uses the Mobility gem (also called the i18n library, translation system,
or locale handler) to manage translations.
```

**✅ Good: Single term**
```
The system uses Mobility (the translation system) to manage translations.
```

**Common terms in this project:**
- "Mobility" (not "i18n library", "translation system", "locale handler")
- "Translation table" (not "translation storage", "locale table", "i18n table")
- "Locale" (not "language", "translation context")
- "Fallback chain" (not "fallback behavior", "locale fallback")

---

## 4. Zero Fluff Checklist

Remove all of these before committing documentation:

### Meta-commentary (🔴 Critical)
```
❌ "Last Updated: 2025-10-24"
❌ "We recently migrated to..."
❌ "We chose this because..."
❌ "This is now fixed! ✅"
❌ "CRITICAL FIX:" / "NEW:" / "UPDATED!"
❌ "As mentioned in the installation guide..."
❌ "See examples above"
❌ "If you're migrating old code..."
```

### Conversational language (⚠️ Warning)
```
❌ "for those who want to understand..."
❌ "You'll want to..."
❌ "You should do..."
❌ "keep this in mind"
❌ "Questions? Ask the team!"
❌ "Gotchas:" / "Heads up:"
❌ "So here's the deal..."
❌ "TLDR:" / "Quick summary:"
```

### Transition phrases (⚠️ Warning)
```
❌ "Additionally..."
❌ "Furthermore..."
❌ "As you can see..."
❌ "Here's what happens..."
❌ "The trickier part is..."
```

### Redundant restatements (⚠️ Warning)
```
❌ Explaining old way then new way (instead, just show new way)
❌ "DON'T DO THIS ANYMORE!" after showing old vs new
❌ Restating what a code example does when code is clear
❌ "We chose... because..." (show what it does, not why)
```

### Emoji for emphasis (⚠️ Warning)
```
❌ ✅ ✓ 🎉 ⚠️ 🔴 (Use only in progress lists, not in documentation text)
```

---

## 5. When to Include Examples

Examples should reveal behavior **not obvious from description**. Include when:
- Edge case or counterintuitive behavior
- Concrete usage that requires code to clarify
- Fallback/error handling behavior
- Complex data structure (show actual structure, not just schema)

**✅ Good: Example reveals non-obvious behavior**
```
**Fallback behavior (missing translation):**
```ruby
I18n.with_locale(:ja) { recipe.name }  # Returns 'en' translation if 'ja' missing
```

**❌ Bad: Example just restates description**
```
**Definition:** To read a translation, use I18n.with_locale

Example:
```ruby
I18n.with_locale(:ja) { recipe.name }
```
(The code doesn't add new information beyond "use I18n.with_locale")
```

---

## 6. Document Type Patterns

### API Documentation
- Endpoint path and method (concise)
- Request parameters (structured)
- Response structure (code block)
- Error codes (bullet list)
- Examples only for non-obvious behavior
- No prose explaining what REST is

### Workflow Documentation
- Sequence as numbered steps (not prose narrative)
- Triggers clearly stated
- Decision points as bullets (not if-then prose)
- Inputs/outputs structured
- No "then the system does..." prose

### Architecture Documentation
- Relationships as YAML/structured data (not prose)
- Diagrams/ASCII art over verbal explanation
- Code examples showing actual usage patterns
- No "we chose this because..." explanations

### Configuration Documentation
- Structure as YAML/code blocks
- Required vs optional fields clearly marked
- No "here's what each setting does" prose (put that in comments)
- Values and defaults explicit

---

## 7. Progressive Disclosure

Load information in layers:

1. **Metadata (heading)** - What is this?
2. **Atomic bullets** - Key facts
3. **Structured data** - Relationships and configuration
4. **Code examples** - Concrete behavior
5. **References** - Detailed information in separate files

**DO NOT** load all detail into SKILL.md. Use references/ directory for expansive guides.

---

## 8. Common Mistakes to Avoid

| Mistake | Example | Fix |
|---------|---------|-----|
| Explaining design choice | "We chose Table backend because queryability" | "Backend: Table (UUID foreign keys)" |
| Restating old way | "Previously JSONB, now translation tables" | Only describe current way |
| Conversational setup | "For those who want to understand..." | Jump directly to content |
| Synonym variation | "Mobility (i18n gem, translation system)" | Pick one term: "Mobility" |
| Status markers | "THIS IS NOW FIXED ✅" | Remove entirely |
| Prose examples | "Here's how to read a translation:" then code | Put code directly under heading |
| Skipped hierarchy | H2 → H4 without H3 | Always progress: H2 → H3 → H4 |
| Redundant section | Explain concept in prose, then show same concept in code | Choose one format only |

---

## 9. Self-Check Before Committing

- [ ] No date stamps ("Last Updated", "2025-10-24")
- [ ] No "we/us" statements ("We chose", "We fixed", "We added")
- [ ] No transition phrases ("As mentioned", "Additionally", "Furthermore")
- [ ] No conversational language ("You'll want to", "For those who")
- [ ] No explanation of changes ("Previously...", "Now we...")
- [ ] No unnecessary status markers (✅, ⚠️, 🎉)
- [ ] Heading hierarchy is strict (no skipped levels)
- [ ] One term used consistently (no synonyms)
- [ ] Examples only show non-obvious behavior
- [ ] All information is essential (no "nice to know")
- [ ] Structured data used for configuration/relationships
- [ ] Atomic bullets (each one independent idea)

---

## 10. When in Doubt

Ask: **"Would removing this sentence/emoji/explanation change what an AI can do?"**

If no → Remove it.
