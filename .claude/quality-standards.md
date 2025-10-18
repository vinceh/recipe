# Claude Code Quality Standards

This document defines quality standards and best practices for all work in this project.

**CRITICAL** ALL DOCUMENTS MUST BE FULLY REREAD AFTER THEY HAVE BEEN EDITED TO MAKE SURE THEY ADHERE TO THE STANDARDS SET IN THIS DOCUMENT, AND THE QUALITY CHECK-LIST MUST BE MET BEFORE THE TASK CAN BE MARKED AS FINISHED AND PRESENTED TO THE USER.

## Document Management Standards

### 1. Reference Integrity

**Always verify and update all references when editing documents:**

- ✅ **Check all file references** - Ensure linked files actually exist
- ✅ **Update cross-references** - When renaming or moving files, update all documents that reference them
- ✅ **Verify relative paths** - Ensure paths are correct from the referencing document's location
- ✅ **Complete reference context** - Provide enough context so the user knows what the link points to

**Before saving any document with file references:**
```bash
# Verify each referenced file exists
ls path/to/referenced/file.md
```

**Examples:**
```markdown
# Good - Complete reference with context
See [smart-scaling-system.md](technical-designs/smart-scaling-system.md) for complete technical design with pseudo-code

# Bad - Incomplete reference
See smart-scaling-system.md

# Good - Verified path
[nutrition-data-strategy.md](technical-designs/nutrition-data-strategy.md)

# Bad - Unverified path that might not exist
[nutrition-strategy.md](docs/nutrition-strategy.md)
```

---

### 2. Document Organization

**Every document must be logically organized and easy to read:**

#### Document Structure Hierarchy:
```
# Main Title
## Executive Summary / Overview
## Core Content Sections (logical grouping)
### Subsections
#### Sub-subsections (if needed)
## Related Resources / References
## Conclusion / Next Steps
```

#### Organization Checklist:
- ✅ **Logical flow** - Information presented in order that makes sense (general → specific, overview → details)
- ✅ **Consistent hierarchy** - Heading levels used consistently throughout
- ✅ **Clear sections** - Each section has a clear purpose and distinct topic
- ✅ **No duplication** - Same information not repeated in multiple places
- ✅ **Findable information** - User can quickly locate specific information via headings/ToC

#### When to Reorganize:
If you notice any of these issues while editing, **fix them immediately**:
- Information scattered across multiple sections that should be together
- Sections appearing in illogical order
- Redundant content in different parts of the document
- Poor heading hierarchy (jumping from # to ####, or using wrong levels)
- Related information separated by unrelated content

**Example of poor organization:**
```markdown
# Recipe App

## Search Features
(content about search)

## Database Schema
(content about database)

## More Search Features  ❌ (scattered, should be with other search content)
(content about filtering)

## Tech Stack
(content about Rails/Vue)

## Database Migrations  ❌ (should be near Database Schema section)
(content about migrations)
```

**Same content, well-organized:**
```markdown
# Recipe App

## Technical Architecture
### Tech Stack
### Database Schema
### Database Migrations

## Core Features
### Search & Filtering
(all search content together)
```

---

### 3. Subagent File Creation Verification

**When using Task tool with subagents that are supposed to create files:**

#### Step 1: Immediately after subagent completes, verify the file was created:
```bash
ls -lh /path/to/expected/file.md
```

#### Step 2: If file doesn't exist:
- **Do NOT assume it was created**
- **Manually create the file** with content from the subagent's output

#### Step 3: Check file size:
```bash
# If file is huge (>500 lines or >50KB):
wc -l /path/to/file.md
ls -lh /path/to/file.md
```

#### Step 4: For large files, ask the user:
> "The subagent created a [X line / Y KB] file. Would you like me to create a more concise version instead? I can condense it to ~400 lines while keeping all critical information."

**Wait for user confirmation before creating concise version.**

#### File Size Guidelines:
- **< 400 lines**: Keep as-is, concise enough
- **400-800 lines**: Mention size, ask if user wants condensed version
- **> 800 lines**: Strongly recommend creating concise version, explain why

**Example interaction:**
```
Claude: The bmm-technical-evaluator created a 16,000-word document (1,200+ lines)
analyzing the nutrition data strategy. This is quite comprehensive but may be
overwhelming. Would you like me to create a concise ~400 line version that includes:
- Executive summary with recommendation
- Key comparisons and decision factors
- Implementation roadmap
- Database schema
- Cost analysis

The full analysis will still be available if you need the deep details later.

User: yes please

Claude: [creates concise version]
```

---

### 4. Quality Checklist for Every Edit

Before completing any file edit, verify:

**References:**
- [ ] All file references point to existing files
- [ ] All relative paths are correct from this file's location
- [ ] Cross-references are bidirectional (if A links to B, does B link back when relevant?)
- [ ] External URLs are valid (if applicable)

**Organization:**
- [ ] Heading hierarchy is logical and consistent
- [ ] Related information is grouped together
- [ ] No duplicate/scattered content
- [ ] Clear section boundaries
- [ ] Information flows logically (overview → details)

**Completeness:**
- [ ] All promised sections/references are present
- [ ] No "TODO" or placeholder text left behind
- [ ] Examples provided where helpful
- [ ] Context provided for technical decisions

**Readability:**
- [ ] Headings clearly describe section content
- [ ] Paragraphs are concise (3-5 sentences)
- [ ] Code blocks have proper syntax highlighting
- [ ] Lists used for scannable content
- [ ] Important information highlighted (bold/italics used appropriately)

---

## When to Apply These Standards

**Apply these standards:**
- ✅ Every time you edit an existing document
- ✅ Every time you create a new document
- ✅ When a subagent completes a task that should create files
- ✅ When the user asks you to review or update documentation
- ✅ When you notice organization issues while reading a file

**Proactive application:**
- If you read a file and notice poor organization, **fix it** (unless you're in read-only mode for analysis)
- If you see broken references while editing nearby content, **fix them**
- If a subagent's output seems too verbose, **ask the user about condensing it**

---

## Examples of Quality Standard Application

### Example 1: Broken Reference
```markdown
# Before (BAD)
See the nutrition strategy document for details.

# After (GOOD) - verified file exists, added complete reference
See [nutrition-data-strategy.md](technical-designs/nutrition-data-strategy.md)
for complete analysis including API comparison, database schema, and implementation roadmap.
```

### Example 2: Poor Organization
```markdown
# Before (BAD)
## Features
### Smart Scaling
(content)
### Translation
(content)

## Technical Details
### More About Scaling  ❌ (should be with Smart Scaling)
(content)

# After (GOOD)
## Features
### Smart Scaling
(original content)

#### Advanced Scaling Details
(moved from "More About Scaling")

### Translation
(content)
```

### Example 3: Subagent File Creation
```markdown
# After subagent completes:

Claude: *runs ls to check file*
Claude: The file wasn't created by the subagent. Let me create it now with the
content from the analysis.

*creates file manually*

Claude: *checks file size*
Claude: The file is 1,100 lines. Would you like me to create a more concise
~400 line version that keeps all the key decisions and implementation details
but removes some of the deep analysis?
```

---

## Document-Specific Standards

### Brainstorming Documents
- Must have clear Resources Created section listing all generated documents
- All referenced documents must be verified to exist
- Cross-references between related sections
- Clear next steps and action items

### Technical Design Documents
- Executive summary at the top with clear recommendation
- Code examples with proper syntax highlighting
- Database schemas in proper SQL/pseudocode format
- Implementation roadmap with timeline
- Cost analysis (if applicable)
- References to related documents

### Data Reference Documents
- Standardized format for easy parsing
- Examples provided for each category
- AI prompt integration guidance
- Validation rules clearly stated

---

**Remember: Quality is not optional. Taking 2 extra minutes to verify references and organization saves hours of confusion later.**

**If you're unsure whether a document meets these standards, err on the side of being thorough - check references, verify organization, and ask clarifying questions.**
