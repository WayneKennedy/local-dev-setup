---
name: test-readiness
description: >
  Activates after CR scope is understood, before writing implementation code.
  Use when preparing to implement, setting up tests, establishing test coverage,
  or when TDD red phase is needed. Ensures tests exist and fail before coding.
---

# Test Readiness

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

You understand the CR scope. Now establish test coverage BEFORE writing implementation. Write tests and proceed to implementation unless blocked.

## Session Context

This skill expects:
- Work Item context from a resumed session (after picking-up-work), OR
- Explicit invocation: "Load skill test-readiness for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "test-readiness", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## The TDD Contract

**Red -> Green -> Refactor**

You MUST have failing tests before writing implementation code. This is not optional.

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

Confirm status is `in_progress`. If not, this skill was invoked out of order.

## Step 2: Get Context (if not in session)

If resuming a session, you already have the context from picking-up-work.

If not, fetch it:
```
get_work_item_context(work_item_id='<CR-ID>')
```

Extract the acceptance criteria for each affected requirement.

## Step 3: Identify Existing Test Coverage

**Find test files related to affected code:**
- Look in `tests/`, `__tests__/`, `spec/`, or alongside source files
- Identify test files for modules you'll be changing

**Assess current coverage:**
- Which behaviours are already tested?
- Which ACs have existing test coverage?
- What gaps exist?

## Step 4: Map ACs to Tests

For each Acceptance Criterion:

| AC | Existing Test? | Gap? |
|----|----------------|------|
| AC1: <description> | Yes/No | <what's missing> |
| AC2: <description> | Yes/No | <what's missing> |

**Every AC needs at least one test that:**
- Passes when the AC is met
- Fails when the AC is not met
- Is automated (not manual verification)

## Step 5: Write Tests for Gaps

For each AC without coverage:

1. **Write the test first**
   - Test should be specific to the AC
   - Test should currently FAIL (behaviour doesn't exist yet)
   - Test name should reference the AC or requirement

2. **Use clear test naming:**
   ```
   test_<feature>_<scenario>_<expected_outcome>

   # Examples:
   test_user_login_with_valid_credentials_returns_token
   test_order_total_with_discount_applies_percentage
   test_api_rate_limit_exceeded_returns_429
   ```

3. **Structure tests clearly:**
   ```
   # Arrange - set up preconditions
   # Act - perform the action
   # Assert - verify the outcome
   ```

## Step 6: Run Tests - Verify RED

Run the test suite:

```bash
# Adjust for your test framework
pytest tests/
npm test
go test ./...
```

**Expected outcome:** New tests FAIL

**If tests pass:**
- Either the behaviour already exists (verify this is intentional)
- Or the test is not correctly asserting the new behaviour
- Fix the test to properly fail before proceeding (2 attempts max)

## Step 7: Document Test Plan

Output your test readiness summary:

```
## Test Readiness: <CR-ID>

### AC Coverage
| AC | Test | Status |
|----|------|--------|
| <AC1> | test_xxx | RED |
| <AC2> | test_yyy | RED |

### Test Commands
- Run all: `<command>`
- Run specific: `<command>`

### Gaps
- <Any ACs that could not be tested and why>
```

## Blocking (STOP)

- Test suite won't run (environment broken)
- AC fundamentally untestable and cannot be clarified
- Cannot determine what to test (requirement too vague)
- New test passes when expected to fail (after 2 fix attempts)
- Unrelated test failures in suite (must fix first)

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "test-readiness",
    "reason": "<short reason>",
    "details": {
      // For missing test coverage:
      "requirement_id": "<HRID>",
      "ac_ordinal": <n>,
      "ac_text": "<text>",
      "issue": "Cannot write automated test - <reason>"
      // For test suite issues:
      "failing_tests": ["test_x", "test_y"],
      "issue": "Unrelated test failures must be fixed first"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: test-readiness] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Test naming convention unclear (follow existing patterns)
- Not sure which test file to use (pick sensible location)
- AC wording imprecise but testable intent is clear
- Some tests passing when expected to fail (verify behaviour exists, proceed if intentional)

## Completion

If all conditions are met:
1. Every AC has a corresponding test
2. All new tests are RED (failing)
3. No unrelated test failures in the suite

**Output:**
```
[GATE_PASS: test-readiness]
```

Proceed immediately to implementation phase. **Do NOT wait for confirmation.**

## Common Patterns

**Testing API endpoints:**
```python
def test_endpoint_returns_expected_status():
    response = client.post('/api/resource', json={...})
    assert response.status_code == 201
    assert 'id' in response.json()
```

**Testing state transitions:**
```python
def test_order_transitions_from_pending_to_confirmed():
    order = Order(status='pending')
    order.confirm()
    assert order.status == 'confirmed'
```

**Testing error conditions:**
```python
def test_invalid_input_raises_validation_error():
    with pytest.raises(ValidationError):
        process_input(invalid_data)
```
