# UX Evaluation Framework

Comprehensive methodologies for evaluating user experience quality through heuristic evaluation and cognitive walkthrough. Use these frameworks to identify usability issues systematically and document findings effectively.

## Choosing an Evaluation Method

Different evaluation methods serve different purposes. Select based on your goals, resources, and constraints.

| Method | Best For | Time | Evaluators | Output |
|--------|----------|------|------------|--------|
| Heuristic Evaluation | Broad usability issues across interface | 1-4 hours | 3-5 UX experts | Comprehensive issue list with severity |
| Cognitive Walkthrough | Task learnability for new users | 2-6 hours | 2-3 people (can be non-experts) | Task-specific barriers and confusion points |
| Combined Approach | Complete picture of UX quality | 4-8 hours | 3-5 evaluators | Broad + task-specific issues |

## Heuristic Evaluation

Heuristic evaluation systematically reviews an interface against established usability principles (Nielsen's 10 heuristics) to identify violations.

### Preparation

Before beginning evaluation:

1. **Define scope**: What are you evaluating? (specific feature, page, flow, or entire product)
2. **Gather context**: Who are the users? What are their goals?
3. **Set up environment**: Access to the system, accounts with appropriate permissions
4. **Prepare documentation**: Template for recording findings
5. **Review heuristics**: Refresh understanding of Nielsen's 10

### Evaluation Process

#### Step 1: Individual Review

Each evaluator independently reviews the interface against each heuristic.

**Review approach:**
1. Go through interface naturally, noting violations
2. Then systematically check each heuristic
3. Document every issue found

**For each heuristic, ask:**
- Where is this heuristic violated?
- How severe is the violation?
- What specifically is the problem?
- What would fix it?

#### Step 2: Document Findings

For each issue found, record:

**Required fields:**
- **Heuristic violated**: Which of Nielsen's 10
- **Location**: Where in the interface (page, screen, element)
- **Description**: What is the problem
- **Severity**: Critical, Major, or Minor (see rating scale below)

**Recommended fields:**
- **Screenshot**: Visual evidence
- **User impact**: How this affects users
- **Recommendation**: How to fix
- **Frequency**: How often users encounter this

**Example finding:**
```
Heuristic: #1 Visibility of system status
Location: Checkout page, form submission
Description: After clicking "Place Order" button, no feedback is provided. Button remains clickable and users may click multiple times, potentially creating duplicate orders.
Severity: Critical
Impact: Users don't know if order was placed, may create duplicates, lose trust
Recommendation:
- Add loading spinner on button during processing
- Disable button after first click
- Show confirmation message when complete
- Redirect to order confirmation page
```

#### Step 3: Consolidate Findings

If multiple evaluators, combine results:

1. **Merge duplicates**: Same issue found by multiple evaluators
2. **Discuss discrepancies**: Different severity ratings
3. **Reach consensus**: Final severity and recommendations
4. **Calculate coverage**: What percentage of issues did each evaluator find?

**Research shows:** 5 evaluators find ~75% of usability problems. Diminishing returns after 5.

### Severity Rating Scale

Assign severity based on frequency, impact, and persistence.

**Critical (P0 - Must Fix)**
- Blocks users from completing core tasks
- Causes data loss or security issues
- Affects majority of users
- No workaround exists

**Examples:**
- Cannot submit payment (blocks purchase)
- Deletes data without confirmation
- Broken authentication
- Inaccessible to screen reader users (WCAG violation)

**Major (P1 - Should Fix)**
- Significantly frustrates users
- Impacts efficiency or satisfaction
- Workaround exists but not obvious
- Affects substantial portion of users

**Examples:**
- Confusing error messages with unclear recovery
- Slow performance (>3 second load)
- Inconsistent interaction patterns
- Missing keyboard shortcuts for frequent actions

**Minor (P2 - Nice to Fix)**
- Small annoyances
- Minimal impact on completion
- Affects edge cases or few users
- Clear workaround available

**Examples:**
- Typos or grammar issues
- Inconsistent visual styling
- Helpful tooltip missing
- Suboptimal default values

### Severity Calculation Formula

For more objective severity ratings, calculate based on:

**Severity = (Frequency × Impact × Persistence) / 3**

Where:
- **Frequency**: 0 = Rare (<10% users), 1 = Occasional (10-50%), 2 = Frequent (>50%)
- **Impact**: 0 = Minor annoyance, 1 = Significant frustration, 2 = Blocks task completion
- **Persistence**: 0 = One-time issue, 1 = Repeated issue, 2 = Every encounter

**Score interpretation:**
- 1.5-2.0 = Critical
- 0.8-1.4 = Major
- 0.0-0.7 = Minor

### Heuristic Evaluation Checklist

Use this checklist to ensure thorough evaluation:

**#1 Visibility of System Status**
- [ ] Loading states for operations >100ms?
- [ ] Progress indicators for long operations?
- [ ] Confirmation for completed actions?
- [ ] Current location shown in navigation?
- [ ] Real-time updates reflected immediately?

**#2 Match Between System and Real World**
- [ ] Language matches user's vocabulary?
- [ ] Metaphors make sense to users?
- [ ] Information follows natural order?
- [ ] Icons are recognizable?
- [ ] Conventions match user expectations?

**#3 User Control and Freedom**
- [ ] Undo/redo available?
- [ ] Cancel option on forms/dialogs?
- [ ] Back navigation works correctly?
- [ ] Can exit multi-step processes?
- [ ] Emergency exits clearly marked?

**#4 Consistency and Standards**
- [ ] UI elements consistent throughout?
- [ ] Terminology used consistently?
- [ ] Visual design consistent?
- [ ] Platform conventions followed?
- [ ] Internal patterns maintained?

**#5 Error Prevention**
- [ ] Inline validation?
- [ ] Confirmations for destructive actions?
- [ ] Constraints prevent invalid input?
- [ ] Smart defaults provided?
- [ ] Invalid actions disabled?

**#6 Recognition Rather Than Recall**
- [ ] Options visible, not hidden?
- [ ] Instructions visible when needed?
- [ ] Previous inputs remembered?
- [ ] Help text available inline?
- [ ] Tooltips for complex UI?

**#7 Flexibility and Efficiency**
- [ ] Keyboard shortcuts available?
- [ ] Customization options?
- [ ] Recent items accessible?
- [ ] Power user features available?
- [ ] Works for novice and expert?

**#8 Aesthetic and Minimalist Design**
- [ ] No unnecessary elements?
- [ ] Visual hierarchy clear?
- [ ] Whitespace used effectively?
- [ ] One primary action per screen?
- [ ] Secondary info hidden/minimized?

**#9 Help Users Recognize, Diagnose, and Recover from Errors**
- [ ] Plain language errors (no codes)?
- [ ] Specific problem identified?
- [ ] Solution suggested?
- [ ] Error messages constructive?
- [ ] Recovery path provided?

**#10 Help and Documentation**
- [ ] Contextual help available?
- [ ] Help searchable?
- [ ] Task-focused documentation?
- [ ] Concrete examples provided?
- [ ] Documentation concise?

## Cognitive Walkthrough

Cognitive walkthrough evaluates how easy it is for users to learn and complete specific tasks, focusing on learnability and discoverability.

### Preparation

Before beginning walkthrough:

1. **Define tasks**: 3-5 representative tasks new users must complete
2. **Define users**: Who are they? What knowledge do they have?
3. **Determine starting point**: Where do users begin?
4. **List correct actions**: Step-by-step path to task completion

### Task Selection Criteria

Choose tasks that are:
- **Representative**: Common, important tasks
- **Critical**: Necessary for success
- **Learnable**: Users must figure out without training
- **Specific**: Clear success criteria

**Good tasks:**
- "Create a new account"
- "Find and purchase red running shoes in size 9"
- "Export last month's sales report as PDF"

**Poor tasks:**
- "Explore the dashboard" (too vague)
- "Understand the data model" (not action-oriented)
- "Find the best product" (success criteria unclear)

### Walkthrough Process

For each task:

#### Step 1: List Correct Action Sequence

Document the ideal path to task completion.

**Example task:** "Reset forgotten password"

Correct actions:
1. Click "Forgot password?" link on login page
2. Enter email address in form
3. Click "Send reset link" button
4. Open email and click reset link
5. Enter new password
6. Enter new password again to confirm
7. Click "Reset password" button

#### Step 2: For Each Action, Ask 4 Questions

**Question 1: Will users try to achieve the right effect?**
- Do users know what they want to accomplish at this step?
- Is the goal clear?

**Question 2: Will users notice the correct action is available?**
- Is the control/option visible?
- Does it stand out?
- Is it in an expected location?

**Question 3: Will users associate the correct action with their goal?**
- Does the label/icon make sense?
- Is it clear what will happen?
- Does it match user's mental model?

**Question 4: If the correct action is performed, will users see that progress is being made?**
- Is there feedback?
- Does the result match expectations?
- Do users know what to do next?

#### Step 3: Document Issues

For each "no" answer, document:

**Issue fields:**
- **Step number**: Which action in sequence
- **Question failed**: Which of the 4 questions
- **Description**: What's the problem
- **User perspective**: What users think/feel
- **Recommendation**: How to fix

**Example issue:**
```
Task: Reset forgotten password
Step: 1 (Click "Forgot password?" link)
Question failed: Q2 (Will users notice?)
Description: "Forgot password?" link is small (12px), light gray text, positioned in footer. Most users look for it near the password field.
User perspective: "Where do I reset my password? I've looked everywhere."
Severity: Major
Recommendation:
- Move link directly below password field
- Make link normal size (16px) and primary color
- Add icon to increase visibility
```

### Cognitive Walkthrough Template

Use this template for each task:

```
Task: [Task name and description]
User: [User type/persona]
Starting point: [Where task begins]

Correct action sequence:
1. [Action 1]
2. [Action 2]
3. [Action 3]
...

Analysis:

Action 1: [Description]
Q1: Will users try to achieve the right effect?
    [Yes/No + explanation]
Q2: Will users notice the correct action is available?
    [Yes/No + explanation]
Q3: Will users associate the correct action with their goal?
    [Yes/No + explanation]
Q4: Will users see that progress is being made?
    [Yes/No + explanation]
Issues: [Document any problems]

[Repeat for each action]

Summary:
Total actions: [Number]
Actions with issues: [Number]
Issue severity breakdown: [X critical, Y major, Z minor]
```

## UX Scoring Rubric

Assign an overall UX quality score based on heuristic evaluation results.

### Scoring Formula

```
UX Score = 10 - (Critical × 2.0 + Major × 0.5 + Minor × 0.1)
```

Where Critical, Major, Minor are the count of issues at each severity.

**Score interpretation:**
- **9.0-10.0**: Excellent UX, minor polish needed
- **7.5-8.9**: Good UX, some improvements recommended
- **6.0-7.4**: Fair UX, significant issues to address
- **4.0-5.9**: Poor UX, major redesign needed
- **<4.0**: Critical UX problems, not production-ready

**Example calculation:**
- 2 critical issues
- 8 major issues
- 15 minor issues

UX Score = 10 - (2×2.0 + 8×0.5 + 15×0.1) = 10 - (4.0 + 4.0 + 1.5) = **0.5/10**

This indicates critical UX problems requiring immediate attention.

### Alternative Rubric: By Category

Score each category 0-10, then average:

**Categories:**
1. **Usability**: Can users accomplish their goals efficiently?
2. **Learnability**: How easy is it for new users to learn?
3. **Error handling**: Are errors prevented and handled well?
4. **Consistency**: Are patterns consistent throughout?
5. **Accessibility**: Is it usable by people with disabilities?
6. **Aesthetics**: Is the design clean and appealing?

**Overall Score = Average of 6 categories**

## Prioritization Framework

Not all issues are equal. Prioritize fixes based on severity, impact, and effort.

### Impact-Effort Matrix

```
Impact (User Benefit)
High  │  P1: Quick wins    │  P0: Major projects
      │  (Fix next sprint) │  (Fix this sprint)
      │─────────────────────┼──────────────────
Low   │  P3: Fill-ins      │  P2: Time sinks
      │  (Backlog)         │  (Consider not doing)
      └────────────────────────────────────────
         Low                    High
              Effort (Development Time)
```

**Prioritization:**
- **P0**: High impact, high effort → Critical projects, allocate resources
- **P1**: High impact, low effort → Quick wins, do these first
- **P2**: Low impact, high effort → Reconsider if worth doing
- **P3**: Low impact, low effort → Fill-in work, backlog

### Issue Filtering

When presenting findings to stakeholders, consider filtering by:

**By severity:**
- Show only Critical + Major for executive summary
- Include Minor in full report

**By frequency:**
- Highlight issues affecting >50% of users
- De-prioritize edge cases

**By user journey:**
- Group by key flows (onboarding, purchase, etc.)
- Prioritize core journey issues

## Documentation and Reporting

Effective communication of findings is critical for driving change.

### Executive Summary Format

For stakeholders who need overview:

```markdown
# UX Evaluation Summary: [Product Name]

**Overall Score:** 6.5/10 (Fair - Significant improvements needed)

**Issues Found:**
- Critical: 3 (Must fix before launch)
- Major: 12 (Fix within next sprint)
- Minor: 28 (Address over time)

**Top 3 Critical Issues:**
1. [Issue with user impact]
2. [Issue with user impact]
3. [Issue with user impact]

**Recommendation:** Address critical issues before launch. Major issues should be fixed within 2 weeks to improve user retention.
```

### Detailed Report Format

For designers and developers who need specifics:

```markdown
# UX Evaluation: [Product Name]

## Methodology
- Heuristic evaluation (3 evaluators)
- 5 tasks tested via cognitive walkthrough
- WCAG 2.2 AA accessibility check

## Findings by Severity

### Critical Issues (3)

#### Issue #1: No feedback after form submission
**Heuristic:** #1 Visibility of system status
**Location:** Contact form, all pages
**Description:** After clicking "Submit", no loading state or confirmation. Users click multiple times, creating duplicate submissions.
**Impact:** 60% of users submit multiple times, creating support burden
**Recommendation:**
- Add loading spinner to button during submission
- Disable button after first click
- Show success message when complete
- Clear form after success

[Continue for each issue...]

## Appendix
- Detailed scoring rubric
- Evaluator notes
- Screenshots
```

## Evaluation Best Practices

**Do:**
- Involve 3-5 evaluators for comprehensive coverage
- Combine methods (heuristic + cognitive walkthrough)
- Focus on user impact, not just compliance
- Provide specific, actionable recommendations
- Test with representative users when possible
- Document everything with screenshots

**Don't:**
- Rely on single evaluator (misses 50% of issues)
- Only report problems without solutions
- Use technical jargon in recommendations
- Evaluate in isolation (understand user context)
- Ignore accessibility (WCAG 2.2 is minimum)
- Present findings without prioritization
