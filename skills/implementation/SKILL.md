---
name: implementation
description: >
  Activates when tests are red and ready to write implementation code. Use during
  active coding, making tests pass, implementing features, fixing bugs, or when
  in TDD green phase. Focuses on minimum code to satisfy failing tests.
---

# Implementation

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

Tests are RED. Now write the minimum code to make them GREEN. Implement and proceed to completing-work unless blocked.

## Session Context

This skill expects:
- Work Item context from a resumed session (after test-readiness), OR
- Explicit invocation: "Load skill implementation for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "implementation", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

Confirm status is `in_progress`. If not, this skill was invoked out of order.

## The Green Phase

**Goal:** Make failing tests pass with the simplest implementation.

**Not the goal:** Write perfect, fully-featured code on first pass.

## Step 2: Pick One Failing Test

Don't try to make all tests pass at once.

1. Choose the simplest failing test
2. Focus only on that test
3. Write minimum code to pass it
4. Run tests, verify GREEN
5. Move to next failing test

## Step 3: Write Minimum Code

**YAGNI - You Aren't Gonna Need It**

Only implement what's needed for the current test. Do not:
- Add features "while you're in there"
- Optimise prematurely
- Build abstractions you don't need yet
- Handle edge cases not covered by tests

**If you think you need more:**
- Is there a test requiring it?
- If no test, you don't need it yet

## Step 4: Run Tests Frequently

After every small change:

```bash
pytest tests/ -x  # Stop on first failure
npm test -- --bail
go test ./... -failfast
```

**Tight feedback loop:**
- Write a few lines
- Run tests
- See result
- Adjust

## Step 5: One Test at a Time

```
test_a - FAIL
test_b - FAIL
test_c - FAIL

[Write code for test_a]

test_a - PASS
test_b - FAIL
test_c - FAIL

[Write code for test_b]

test_a - PASS
test_b - PASS
test_c - FAIL

[Continue until all green]
```

## Step 6: Refactor (Only When Green)

Once tests pass, you may refactor:

1. **Only refactor when GREEN** - Never refactor with failing tests
2. **Keep tests passing** - Run tests after each refactor step
3. **Small steps** - One refactor at a time, verify green, continue

**Refactoring candidates:**
- Extract repeated code into functions
- Rename unclear variables/functions
- Simplify complex conditionals
- Remove dead code

**Not refactoring:**
- Adding new features (needs a test first)
- Changing behaviour (needs a test first)

## Progress Tracking

As you implement:

```
## Implementation Progress: <CR-ID>

### Test Status
- test_user_creates_account (PASS)
- test_user_receives_welcome_email (PASS)
- test_user_can_reset_password (FAIL) <- working on this
- test_password_reset_expires (FAIL)

### Files Changed
- src/auth/user.py - Added create_account()
- src/email/notifications.py - Added send_welcome()

### Notes
- <Any implementation decisions worth noting>
```

## When You Get Stuck

**Test won't pass:**
1. Re-read the test - is it testing what you think?
2. Re-read the AC - do you understand the requirement?
3. Add debug output to see what's actually happening
4. Check if dependencies are mocked correctly

**Unsure how to implement:**
1. Review related LDM/Interface specs from picking-up-work phase
2. Look at similar patterns in the codebase
3. Start with the simplest approach, refactor later

**Scope creep temptation:**
- "I should also add..." → No, is there a test?
- "This would be better if..." → No, make it work first
- "While I'm here..." → No, stay focused on the CR

## Blocking (STOP)

- Test won't pass after 3 fix attempts
- Fundamental design question with no clear answer
- Security concern requiring explicit authorization

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "implementation",
    "reason": "<short reason>",
    "details": {
      "test_name": "<test>",
      "failure_reason": "<why it can't pass>",
      "issue": "<what's blocking>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: implementation] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Multiple valid implementation approaches (pick simplest)
- Naming decisions (follow existing patterns)
- Minor refactoring choices (make it work first)
- Edge case handling not in tests (don't add untested code)

## Retry Logic

If a test won't pass:
1. Re-read the test and AC
2. Debug to understand actual vs expected
3. Fix and retry

After 3 attempts, **STOP** and transition to blocked.

## Completion

All tests GREEN → Proceed immediately to completing-work phase.

**Output:**
```
[GATE_PASS: implementation]
```

**Do NOT wait for confirmation.**
