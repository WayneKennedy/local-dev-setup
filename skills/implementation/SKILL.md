---
name: implementation
description: >
  Activates when tests are red and ready to write implementation code. Use during
  active coding, making tests pass, implementing features, fixing bugs, or when
  in TDD green phase. Focuses on minimum code to satisfy failing tests.
---

# Implementation

Tests are RED. Now write the minimum code to make them GREEN.

## The Green Phase

**Goal:** Make failing tests pass with the simplest implementation.

**Not the goal:** Write perfect, fully-featured code on first pass.

## Step 1: Pick One Failing Test

Don't try to make all tests pass at once.

1. Choose the simplest failing test
2. Focus only on that test
3. Write minimum code to pass it
4. Run tests, verify GREEN
5. Move to next failing test

## Step 2: Write Minimum Code

**YAGNI - You Aren't Gonna Need It**

Only implement what's needed for the current test. Do not:
- Add features "while you're in there"
- Optimise prematurely
- Build abstractions you don't need yet
- Handle edge cases not covered by tests

**If you think you need more:**
- Is there a test requiring it?
- If no test, you don't need it yet

## Step 3: Run Tests Frequently

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

## Step 4: One Test at a Time

```
🔴 test_a - FAIL
🔴 test_b - FAIL  
🔴 test_c - FAIL

[Write code for test_a]

🟢 test_a - PASS
🔴 test_b - FAIL
🔴 test_c - FAIL

[Write code for test_b]

🟢 test_a - PASS
🟢 test_b - PASS
🔴 test_c - FAIL

[Continue until all green]
```

## Step 5: Refactor (Only When Green)

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
- 🟢 test_user_creates_account (PASS)
- 🟢 test_user_receives_welcome_email (PASS)
- 🔴 test_user_can_reset_password (FAIL) ← working on this
- 🔴 test_password_reset_expires (FAIL)

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

## Gate: Do Not Proceed If

- Any test is still RED (keep implementing)
- You've added untested code (write a test or remove it)
- Tests are flaky/inconsistent (fix reliability first)

## Completion Criteria

All tests GREEN → Proceed to completing-work phase
