---
name: picking-up-work
description: >
  Activates when starting implementation work, reviewing a CR, picking up a work
  item, asking what to work on, or beginning any TarkaFlow development task.
  Use before writing any code to ensure CR readiness and full context gathering.
---

# Picking Up Work

Before writing any code, you MUST understand the full scope of the work.

## Step 1: Verify CR Exists and Is Approved

```
get_work_item(work_item_id='<CR-ID>')
```

**Check:**
- Status is `approved` or `in_progress`
- If `created` → CR needs approval, do not proceed
- If no CR exists → stop and inform user

## Step 2: Fetch All Affected Requirements

For each requirement ID in the CR's `affects` list:

```
get_requirement(requirement_id='<ID>')
```

**Extract and note:**
- Title and description
- Full content (the specification)
- Status (should be `approved`)
- Semantic tags (uses:, owns:, depends:)

## Step 3: Fetch Acceptance Criteria

For each affected requirement:

```
list_acceptance_criteria(requirement_id='<ID>')
```

**Assess each AC:**
- Is it specific? (not vague like "should be fast")
- Is it measurable? (has concrete success condition)
- Is it testable? (can write a test that passes/fails)

**If ACs are inadequate:**
- Note which ACs need clarification
- Consider creating clarification tasks
- Do not proceed until ACs are testable

## Step 4: Check Dependencies

For each affected requirement:

```
list_requirements(blocked_by='<requirement_id>')
```

**Check dependency status:**
- Are blocking dependencies code-complete? (has `deployed_version`)
- If dependencies are unmet → work is blocked, inform user

Also check the requirement's own `depends:` tags for explicit dependencies.

## Step 5: Gather Related Artifacts

**Find LDM entries:**
```
list_requirements(project_id='<project>', type='ldm')
```

Look for LDM entries referenced by `uses:` tags in affected requirements.

**Find Interface specs:**
```
list_requirements(project_id='<project>', type='interface')
```

Look for interfaces referenced by `uses:` tags.

**Fetch full content for relevant artifacts:**
```
get_requirement(requirement_id='<LDM-ID>')
get_requirement(requirement_id='<INTERFACE-ID>')
```

## Step 6: Summarise Understanding

Before proceeding, state your understanding:

```
## Work Item: <CR-ID>
**Title:** <title>
**Status:** <status>

### Scope
<Brief description of what this CR accomplishes>

### Affected Requirements
1. <HRID>: <title>
   - ACs: <count> (<testable count> testable)
   - Dependencies: <met/unmet>

### Key Data Models
- <LDM entries relevant to this work>

### Interfaces
- <Interface specs relevant to this work>

### Implementation Approach
<Your high-level approach to implementing this>

### Risks/Questions
- <Any uncertainties or clarifications needed>
```

## Gate: Do Not Proceed If

- CR is not approved
- Any AC is not testable (needs clarification first)
- Dependencies are not code-complete
- You don't understand the scope

Only proceed to test-readiness phase when you have full clarity.
