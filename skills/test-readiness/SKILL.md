---
name: test-readiness
description: >
  Activates after CR scope is understood, before writing implementation code.
  Use when preparing to implement, setting up tests, establishing test coverage,
  or when TDD red phase is needed. Ensures tests exist and fail before coding.
---

# Test Readiness

You understand the CR scope. Now establish test coverage BEFORE writing implementation.

## The TDD Contract

**Red → Green → Refactor**

You MUST have failing tests before writing implementation code. This is not optional.

## Step 1: Identify Existing Test Coverage

**Find test files related to affected code:**
- Look in `tests/`, `__tests__/`, `spec/`, or alongside source files
- Identify test files for modules you'll be changing

**Assess current coverage:**
- Which behaviours are already tested?
- Which ACs have existing test coverage?
- What gaps exist?

## Step 2: Map ACs to Tests

For each Acceptance Criterion:

| AC | Existing Test? | Gap? |
|----|----------------|------|
| AC1: <description> | Yes/No | <what's missing> |
| AC2: <description> | Yes/No | <what's missing> |

**Every AC needs at least one test that:**
- Passes when the AC is met
- Fails when the AC is not met
- Is automated (not manual verification)

## Step 3: Write Tests for Gaps

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

## Step 4: Run Tests - Verify RED

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
- Fix the test to properly fail before proceeding

## Step 5: Document Test Plan

Before proceeding to implementation:

```
## Test Readiness: <CR-ID>

### AC Coverage
| AC | Test | Status |
|----|------|--------|
| <AC1> | test_xxx | 🔴 RED |
| <AC2> | test_yyy | 🔴 RED |

### Test Commands
- Run all: `<command>`
- Run specific: `<command>`

### Ready for Implementation
✅ All ACs have failing tests
```

## Gate: Do Not Proceed If

- Any AC lacks a corresponding test
- Any new test is passing (should be RED)
- Test suite has unrelated failures (fix these first)

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

Only proceed to implementation phase when all AC tests are RED.
