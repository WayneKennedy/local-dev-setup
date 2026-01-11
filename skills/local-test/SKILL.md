---
name: local-test
description: >
  Activates after implementation is complete and tests are green. Sets deployment
  mode to local, spins up Docker containers, and runs system tests locally.
  Catches issues before GitHub Actions deployment. Requires tester agent identity.
---

# Local Test

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

Tests are GREEN in isolation. Now verify the system works end-to-end locally before pushing to remote. Run local system tests and proceed to remote-test unless blocked.

## Session Context

This skill expects:
- Work Item context from a resumed session (after implementation), OR
- Explicit invocation: "Load skill local-test for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "local-test", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## Agent Identity: Tester

**IMPORTANT:** Local testing requires the tester agent identity.

```
select_agent(agent_email='tester@tarka.internal')
```

The developer agent validates their own unit tests pass. The tester agent validates system behaviour.

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

Confirm status is `in_progress`. If not, this skill was invoked out of order.

## Step 2: Check Current Deployment Mode

```bash
cat .deployment-mode
```

Note the current mode so you can restore it if needed.

## Step 3: Switch to Local Mode

Update `.deployment-mode` file:

```bash
cat > .deployment-mode << 'EOF'
MODE=local
API_BASE=http://localhost:8000/api/v1
MCP_URL=http://localhost:8000/mcp
EOF
```

## Step 4: Start Local Containers

```bash
docker compose up -d
```

Wait for containers to be healthy:

```bash
docker compose ps
```

**All containers must be running.** If any are unhealthy or exited, this is a blocking condition.

## Step 5: Run Migrations (If Applicable)

```bash
docker compose run --rm migrations
```

If migrations fail, this is a blocking condition.

## Step 6: Verify Local Health

Check the health endpoint:

```bash
curl -s http://localhost:8000/health | jq .
```

**Expected:** Health check passes. If not, check container logs:

```bash
docker compose logs --tail 50
```

## Step 7: Run System Tests

Run the full test suite against local containers:

```bash
# Adjust for your test framework
pytest tests/ -v
# or
pytest tests/integration/ tests/system/ -v
```

**All tests must pass.** Track failures for retry logic.

## Step 8: Smoke Test Implementation

Based on your implementation knowledge from the previous phases, perform targeted smoke tests:

**For API changes:**
```bash
# Test new/modified endpoints
curl -s http://localhost:8000/api/v1/<endpoint> | jq .
```

**For data model changes:**
- Verify data persists correctly
- Check relationships work as expected

**For MCP tool changes:**
- Test MCP tools via the local MCP endpoint
- Verify tool responses match expectations

**Document what you tested:**
```
## Local Smoke Tests: <CR-ID>

### API Tests
- POST /api/v1/resource - Created successfully
- GET /api/v1/resource/{id} - Returns created resource

### Data Verification
- <Entity> persists with correct fields
- <Relationship> links work correctly

### MCP Tools
- <tool_name> returns expected response
```

## Step 9: Clean Up (Optional)

You may leave containers running for remote-test phase reference, or:

```bash
docker compose down
```

## Blocking (STOP)

- Containers won't start
- Migrations fail
- Health check fails
- System tests fail after 3 attempts
- Critical smoke test fails (cannot demonstrate core functionality)

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "local-test",
    "reason": "<short reason>",
    "details": {
      // For container issues:
      "container": "<name>",
      "status": "<status>",
      "logs": "<relevant log snippet>"
      // For test failures:
      "test_name": "<test>",
      "failure_reason": "<why it failed>",
      "attempts": <n>
      // For smoke test issues:
      "endpoint": "<endpoint>",
      "expected": "<expected>",
      "actual": "<actual>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: local-test] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Minor test flakiness that passes on retry
- Non-critical smoke test edge cases
- Warnings in logs (not errors)
- Slow startup times (as long as eventual health)

## Retry Logic

| Failure Type | Retry Attempts | Then |
|--------------|----------------|------|
| Container startup | 2 attempts | Block |
| Test failure | 3 attempts | Block |
| Health check | 3 attempts (with wait) | Block |
| Smoke test | 2 attempts | Block |

## Completion

If all conditions are met:
1. Containers running and healthy
2. Migrations applied successfully
3. All system tests pass
4. Smoke tests demonstrate expected behaviour

**Output:**
```
[GATE_PASS: local-test]
```

Proceed immediately to remote-test phase. **Do NOT wait for confirmation.**
