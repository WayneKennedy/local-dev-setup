---
name: picking-up-work
description: >
  Activates when starting implementation work, reviewing a CR, picking up a work
  item, asking what to work on, or beginning any TarkaFlow development task.
  Use before writing any code to ensure CR readiness and full context gathering.
---

# Picking Up Work

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

Before writing any code, you MUST understand the full scope of the work. Gather context and proceed to test-readiness unless blocked.

## Session Context

This skill expects to be invoked with a Work Item identifier:
- Explicit: "Load skill picking-up-work for CR-042"
- Via resumed session with prior context

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item status is `unblocked`):**
- The work item was previously blocked at some gate
- Fetch `blocking_context` to understand what failed before
- Apply extra diligence to the previously-failed condition
- Check `retry_count` and `previous_blocks` for history

## Step 0: Select Agent Identity

```
select_agent(agent_email='code@tarka.internal')
```

## Step 1: Check Readiness (Single Call)

Use the efficient readiness endpoint:

```
check_work_item_readiness(work_item_id='<CR-ID>')
```

This returns:
- `ready`: boolean - overall readiness
- `checks`: work_item_approved, all_requirements_approved, dependencies_met, has_conflicts, has_drift
- `blocking_reasons`: array of human-readable strings if not ready
- `acceptance_criteria_summary`: counts per requirement

**If `ready` is false**: Skip to Blocking section below.

**If `ready` is true**: Continue to Step 2.

## Step 2: Get Full Context (Single Call)

```
get_work_item_context(work_item_id='<CR-ID>')
```

This returns everything needed:
- Work item details with `blocking_context` (for retry awareness)
- All affected requirements with full content, status, ACs, and semantic tags
- Related LDM and Interface artifacts (from `uses:` tags)
- Embedded readiness check

## Step 3: Analyze Acceptance Criteria Quality

```
analyze_acceptance_criteria(work_item_id='<CR-ID>')
```

Review the `flagged_for_review` array for ACs with:
- Vague language (fast, easy, flexible, etc.)
- No measurable thresholds

**For each flagged AC**, apply semantic judgment:
- Is it actually testable despite the flag?
- Or does it genuinely need clarification?

**If any AC is not testable**: This is a blocking condition.

## Step 4: Transition to In Progress

If work item status is `approved` or `unblocked`:

```
transition_work_item(work_item_id='<CR-ID>', new_status='in_progress')
```

## Step 5: Summarise Understanding

Output your understanding:

```
## Work Item: <CR-ID>
**Title:** <title>
**Status:** in_progress

### Scope
<Brief description of what this CR accomplishes>

### Affected Requirements
1. <HRID>: <title>
   - ACs: <total> (<flagged> flagged for review)
   - Dependencies: met

### Key Data Models
- <LDM entries from context>

### Interfaces
- <Interface specs from context>

### Implementation Approach
<Your high-level approach to implementing this>

### Risks/Questions
- <Any uncertainties or clarifications needed>
```

## Blocking (STOP)

- CR is not approved (status must be `approved` or `in_progress`)
- CR not found
- Requirements not approved
- Dependencies not code-complete
- Conflicts detected
- Version drift detected
- AC fundamentally not testable (after semantic review)

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "picking-up-work",
    "reason": "<short reason from blocking_reasons or your assessment>",
    "details": {
      // Include relevant details based on failure type:
      // For approval issues:
      "requirement_id": "<HRID>",
      "current_status": "<status>",
      // For dependency issues:
      "blocking_requirements": ["<HRID-1>", "<HRID-2>"],
      // For AC issues:
      "requirement_id": "<HRID>",
      "ac_ordinal": <n>,
      "ac_text": "<text>",
      "issue": "<why not testable>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: picking-up-work] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Minor AC ambiguity (interpret reasonably, note assumption)
- Missing optional LDM/interface details (implement what you can)
- Unclear implementation approach (choose sensible option)

## Completion

If all conditions are met:
1. Work item is `in_progress`
2. All requirements are `approved`
3. All dependencies are code-complete
4. No conflicts or drift
5. All ACs are testable (after semantic review)

**Output:**
```
[GATE_PASS: picking-up-work]
```

Proceed immediately to test-readiness phase. **Do NOT wait for confirmation.**
