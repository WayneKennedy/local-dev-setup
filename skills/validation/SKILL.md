---
name: validation
description: >
  Activates when a work item is implemented and needs validation, when testing
  implementation against acceptance criteria, when verifying a CR is complete,
  or when marking ACs as met. Requires tester agent identity. Use to validate
  work before it can proceed to deployment.
---

# Validation

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

A work item is `implemented` and needs validation against acceptance criteria. Validate and proceed to preparing-release unless blocked.

## Session Context

This skill expects:
- Work Item context from a resumed session (after completing-work), OR
- Explicit invocation: "Load skill validation for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "validation", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## Agent Identity: Tester

**IMPORTANT:** Validation requires the tester agent identity.

```
select_agent(agent_email='tester@tarka.internal')
```

The developer agent CANNOT transition to `validated`. Only the tester agent can.

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

**Verify status is `implemented`** - Cannot validate work that isn't implemented.

## Step 2: Get Context (if not in session)

If resuming a session, you already have the context from previous phases.

If not, fetch it:
```
get_work_item_context(work_item_id='<CR-ID>')
```

For each affected requirement:
```
list_acceptance_criteria(requirement_id='<REQ-ID>')
```

## Step 3: Verify Each Acceptance Criterion

For EACH acceptance criterion:

### 3a. Understand the Criterion

- What specific behaviour does this AC require?
- What is the success condition?
- How can it be verified?

### 3b. Verify Implementation

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

### 3c. Record AC Status

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

## Step 4: Check Implementation Artifacts

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

## Step 5: Validation Decision

### All ACs Met

If every AC is met and artifacts are complete:

```
## Validation Report: <CR-ID>

### Acceptance Criteria
| AC | Description | Status |
|----|-------------|--------|
| 1 | <description> | Met |
| 2 | <description> | Met |
| 3 | <description> | Met |

### Artifacts
- Implementation notes present
- LDM updated (or N/A)
- Interface specs updated (or N/A)
- Semantic tags added

### Validation Result
PASSED - All acceptance criteria met
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
| 1 | <description> | Met |
| 2 | <description> | Not Met |
| 3 | <description> | Met |

### Issues Found

#### AC 2: <description>
**Status:** Not Met
**Reason:** <what's wrong>
**Evidence:** <how you determined this>
**Required Fix:** <what needs to change>

### Validation Result
FAILED - <count> acceptance criteria not met
```

Do NOT transition to validated. This is a blocking condition.

## Step 6: Edge Cases

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

## Blocking (STOP)

- Work item is not `implemented`
- Cannot verify AC (environment broken, missing access)
- AC fundamentally ambiguous with no reasonable interpretation
- Any AC definitively not met (return to developer)

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "validation",
    "reason": "<short reason>",
    "details": {
      "requirement_id": "<HRID>",
      "ac_ordinal": <n>,
      "ac_text": "<text>",
      "issue": "<what's wrong with implementation>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: validation] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- AC wording imprecise but implementation clearly satisfies intent
- Minor gaps in test coverage (note, but AC can still be met)
- Documentation imperfect but adequate
- Interpretation judgment calls (document your interpretation)

## Completion

If all ACs are met:
1. Transition to `validated`
2. Proceed immediately to preparing-release phase

**Output:**
```
[GATE_PASS: validation]
```

**Do NOT wait for confirmation on pass/fail decision.**

## After Validation

Once `validated`, the work item can proceed to deployment via a Release.
The tester agent cannot deploy - that requires an approved Release.
