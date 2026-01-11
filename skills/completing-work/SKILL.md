---
name: completing-work
description: >
  Activates after local and remote testing pass. Use when finishing work,
  wrapping up a CR, preparing to mark implemented, creating implementation
  notes, updating data models, or adding semantic tags. MUST complete before
  transitioning work item to implemented.
---

# Completing Work

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

Local and remote testing passed. Implementation is verified working in production. Complete documentation and transition to implemented.

## Session Context

This skill expects:
- Work Item context from a resumed session (after remote-test), OR
- Explicit invocation: "Load skill completing-work for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "completing-work", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

Confirm status is `in_progress`. If not, this skill was invoked out of order.

## Completion Checklist

Before transitioning to `implemented`, ALL of the following must be done:

- [ ] Implementation notes (imp) created
- [ ] LDM updated (if data model changed)
- [ ] Interface specs updated (if APIs changed)
- [ ] Semantic tags added to requirements
- [ ] All tests passing
- [ ] Work item updated with implementation refs

## Step 2: Create Implementation Notes

For each affected requirement, create an `imp` artifact documenting key decisions:

**Get the template:**
```
get_requirement_template(type='imp')
```

**Create the imp:**
```
create_requirement(
  content='<filled template>',
  type='imp',
  project_id='<project>'
)
```

**What to include in imp notes:**
- Key architectural decisions made
- Patterns used and why
- Deviations from original design (and justification)
- Known limitations or technical debt
- Dependencies introduced
- Configuration required

**Example imp content:**
```markdown
---
title: User Authentication Implementation
parent_id: <feature-id>
tags:
  - repo:auth-service
  - uses:PROJ-LDM-001
---

# Implementation Notes

## Approach
Used JWT tokens with refresh token rotation for session management.

## Key Decisions
- Chose bcrypt over argon2 for password hashing (broader library support)
- Token expiry set to 15 minutes based on security requirements in PROJ-REQ-042

## Dependencies
- Added `pyjwt` package for token handling
- Requires `AUTH_SECRET` environment variable

## Known Limitations
- Token revocation requires Redis (not implemented, see PROJ-FEAT-089)
```

## Step 3: Update LDM (If Data Model Changed)

If you added or modified data structures:

**Check for existing LDM:**
```
list_requirements(project_id='<project>', type='ldm')
```

**Create new LDM if needed:**
```
get_requirement_template(type='ldm')
create_requirement(content='...', type='ldm', project_id='<project>')
```

**Or update existing:**
```
get_requirement(requirement_id='<LDM-ID>')
# Modify content
update_requirement(requirement_id='<LDM-ID>', content='...')
```

**LDM should document:**
- Entity definitions
- Field types and constraints
- Relationships between entities
- Validation rules

## Step 4: Update Interfaces (If APIs Changed)

If you added or modified APIs:

**Check for existing interface:**
```
list_requirements(project_id='<project>', type='interface')
```

**Create or update interface spec:**
```
get_requirement_template(type='interface')
create_requirement(content='...', type='interface', project_id='<project>')
```

**Interface should document:**
- Endpoints (method, path)
- Request/response schemas
- Authentication requirements
- Error responses
- Rate limits

## Step 5: Add Semantic Tags

Update affected requirements with relationship tags:

```
get_requirement(requirement_id='<REQ-ID>')
```

**Add appropriate tags in the frontmatter:**
- `uses:PROJ-LDM-001` - If requirement uses this data model
- `uses:PROJ-INT-001` - If requirement uses this interface
- `owns:PROJ-LDM-002` - If requirement owns/defines this data model
- `repo:service-name` - Which repository contains implementation

```
update_requirement(requirement_id='<REQ-ID>', content='<updated content with tags>')
```

## Step 6: Update Work Item with Implementation Refs

```
update_work_item(
  work_item_id='<CR-ID>',
  implementation_refs={
    'pr_urls': ['https://github.com/org/repo/pull/123'],
    'commit_shas': ['abc123', 'def456'],
    'github_issue_url': 'https://github.com/org/repo/issues/42'
  }
)
```

## Step 7: Final Verification

Run full test suite one more time:
```bash
pytest tests/
npm test
go test ./...
```

**Verify:**
- All tests pass
- No unrelated test failures introduced
- Linting passes
- Type checking passes (if applicable)

## Step 8: Transition to Implemented

Only after ALL checklist items are complete:

```
transition_work_item(work_item_id='<CR-ID>', new_status='implemented')
```

## Summary Template

```
## Completion Summary: <CR-ID>

### Artifacts Created
- IMP: <PROJ-IMP-XXX> - <title>
- LDM: <PROJ-LDM-XXX> - <title> (if applicable)
- INT: <PROJ-INT-XXX> - <title> (if applicable)

### Tags Added
- <REQ-ID>: added uses:PROJ-LDM-XXX, repo:service-name

### Implementation Refs
- PR: <url>
- Commits: <shas>

### Test Status
All tests passing
```

## Blocking (STOP)

- Tests now failing (regression introduced)
- Cannot determine what was implemented (shouldn't happen)
- MCP tools failing repeatedly

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "completing-work",
    "reason": "<short reason>",
    "details": {
      "missing_artifact": "imp|ldm|interface",
      "issue": "<why it cannot be created>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: completing-work] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Imp notes could be more detailed (write what you know)
- LDM structure choices (follow existing patterns)
- Tag naming unclear (use sensible conventions)
- Interface format questions (match existing specs)

## Completion

After documentation is complete:
1. Transition to `implemented`
2. Proceed immediately to validation phase

**Output:**
```
[GATE_PASS: completing-work]
```

**Do NOT wait for confirmation.**
