---
name: completing-work
description: >
  Activates when tests are green and implementation is functionally complete.
  Use when finishing work, wrapping up a CR, preparing to mark implemented,
  creating implementation notes, updating data models, or adding semantic tags.
  MUST complete before transitioning work item to implemented.
---

# Completing Work

Tests are GREEN. Implementation is functionally complete. 

But you are NOT done yet. You MUST complete documentation and artifacts before
marking the work item as implemented.

## Completion Checklist

Before transitioning to `implemented`, ALL of the following must be done:

- [ ] Implementation notes (imp) created
- [ ] LDM updated (if data model changed)
- [ ] Interface specs updated (if APIs changed)
- [ ] Semantic tags added to requirements
- [ ] All tests passing
- [ ] Work item updated with implementation refs

## Step 1: Create Implementation Notes

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

## Step 2: Update LDM (If Data Model Changed)

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

## Step 3: Update Interfaces (If APIs Changed)

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

## Step 4: Add Semantic Tags

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

## Step 5: Update Work Item with Implementation Refs

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

## Step 6: Final Verification

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

## Step 7: Transition to Implemented

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
✅ All tests passing

### Status
Work item transitioned to `implemented`
```

## Gate: Do Not Transition If

- Imp notes not created
- Data model changes not documented in LDM
- API changes not documented in Interface
- Semantic tags not added
- Tests failing
- Implementation refs not recorded

The work is not complete until documentation is complete.
