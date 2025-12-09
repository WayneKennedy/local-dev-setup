---
name: validation
description: >
  Activates when a work item is implemented and needs validation, when testing
  implementation against acceptance criteria, when verifying a CR is complete,
  or when marking ACs as met. Requires tester agent identity. Use to validate
  work before it can proceed to deployment.
---

# Validation

A work item is `implemented` and needs validation against acceptance criteria.

## Agent Identity: Tester

**IMPORTANT:** Validation requires the tester agent identity.

```
select_agent(agent_email='tester@tarka.internal')
```

The developer agent CANNOT transition to `validated`. Only the tester agent can.

## Step 1: Fetch Work Item and Requirements

```
get_work_item(work_item_id='<CR-ID>')
```

**Verify status is `implemented`** - Cannot validate work that isn't implemented.

For each affected requirement:
```
get_requirement(requirement_id='<REQ-ID>')
list_acceptance_criteria(requirement_id='<REQ-ID>')
```

## Step 2: Verify Each Acceptance Criterion

For EACH acceptance criterion:

### 2a. Understand the Criterion

- What specific behaviour does this AC require?
- What is the success condition?
- How can it be verified?

### 2b. Verify Implementation

**Check the code:**
- Does the implementation address this AC?
- Review the relevant code paths

**Check the tests:**
- Is there a test for this AC?
- Does the test actually verify the AC?
- Run the test, confirm it passes

**Check manually (if applicable):**
- Can you demonstrate the behaviour?
- Does it work as specified?

### 2c. Record AC Status

```
update_acceptance_criteria(ac_id='<AC-UUID>', met=true)
```

Or if not met:
```
update_acceptance_criteria(ac_id='<AC-UUID>', met=false)
```

**Document why if unmet:**
- What's missing?
- What's incorrect?
- What needs to change?

## Step 3: Check Implementation Artifacts

**Verify imp notes exist:**
```
list_requirements(parent_id='<feature-id>', type='imp')
```

**Verify LDM updated (if data changed):**
- Are new data structures documented?
- Do LDM entries match implementation?

**Verify interfaces updated (if APIs changed):**
- Are new endpoints documented?
- Do interface specs match implementation?

**Verify semantic tags added:**
- Do requirements have appropriate `uses:`, `owns:` tags?
- Is the `repo:` tag present?

## Step 4: Validation Decision

### All ACs Met

If every AC is met and artifacts are complete:

```
## Validation Report: <CR-ID>

### Acceptance Criteria
| AC | Description | Status |
|----|-------------|--------|
| 1 | <description> | ✅ Met |
| 2 | <description> | ✅ Met |
| 3 | <description> | ✅ Met |

### Artifacts
- ✅ Implementation notes present
- ✅ LDM updated (or N/A)
- ✅ Interface specs updated (or N/A)
- ✅ Semantic tags added

### Validation Result
✅ PASSED - All acceptance criteria met

### Transition
Work item transitioned to `validated`
```

Then:
```
transition_work_item(work_item_id='<CR-ID>', new_status='validated')
```

### ACs Not Met

If any AC is not met:

```
## Validation Report: <CR-ID>

### Acceptance Criteria
| AC | Description | Status |
|----|-------------|--------|
| 1 | <description> | ✅ Met |
| 2 | <description> | ❌ Not Met |
| 3 | <description> | ✅ Met |

### Issues Found

#### AC 2: <description>
**Status:** Not Met
**Reason:** <what's wrong>
**Evidence:** <how you determined this>
**Required Fix:** <what needs to change>

### Validation Result
❌ FAILED - <count> acceptance criteria not met

### Next Steps
Work item remains `implemented`. Developer must address issues and re-request validation.
```

Do NOT transition to validated. Return to developer with specific issues.

## Step 5: Edge Cases

**AC is ambiguous:**
- Document the ambiguity
- Make reasonable interpretation
- Note assumption in validation report
- Consider creating clarification task for future

**Test exists but doesn't cover AC fully:**
- Note gap in validation report
- Recommend additional test coverage
- AC may still be met if behaviour is correct

**Implementation correct but AC poorly written:**
- Validate against intent, not literal wording
- Note discrepancy in report
- Recommend AC refinement for future

## Gate: Cannot Validate If

- Work item is not `implemented`
- Using developer agent (must be tester)
- Cannot verify ACs (missing access, broken environment)

## After Validation

Once `validated`, the work item can proceed to deployment via a Release.
The tester agent cannot deploy - that requires an approved Release.
