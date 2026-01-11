---
name: remote-test
description: >
  Activates after local testing passes. Sets deployment mode to remote, commits
  and pushes changes, monitors GitHub Actions deployment, then runs smoke tests
  against production. Requires tester agent identity.
---

# Remote Test

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

Local tests passed. Now deploy to remote and verify the system works in production. Commit, push, monitor deployment, smoke test, and proceed to completing-work unless blocked.

## Session Context

This skill expects:
- Work Item context from a resumed session (after local-test), OR
- Explicit invocation: "Load skill remote-test for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "remote-test", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## Agent Identity: Tester

**IMPORTANT:** Remote testing requires the tester agent identity.

```
select_agent(agent_email='tester@tarka.internal')
```

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

Confirm status is `in_progress`. If not, this skill was invoked out of order.

## Step 2: Switch to Remote Mode

Update `.deployment-mode` file:

```bash
cat > .deployment-mode << 'EOF'
MODE=remote
API_BASE=<project-specific-remote-url>
MCP_URL=<project-specific-remote-mcp-url>
EOF
```

**Note:** Get the correct URLs from the project's CLAUDE.md file.

## Step 3: Stop Local Containers

If local containers are still running:

```bash
docker compose down
```

## Step 4: Stage and Commit Changes

```bash
git add -A
git status
```

Review what's being committed. Ensure no secrets or `.env` files are staged.

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<CR-ID>: <CR title>

<summary of changes>

Tested:
- Local system tests: PASS
- Local smoke tests: PASS

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Step 5: Push to Remote

```bash
git push origin <branch>
```

If pushing to main triggers deployment:
```bash
git push origin main
```

## Step 6: Monitor Deployment

Watch the GitHub Actions workflow:

```bash
gh run watch
```

**Wait for deployment to complete.**

- If workflow fails, this is a blocking condition
- Capture the failure reason for blocking_context

**Alternative monitoring:**
```bash
# List recent runs
gh run list --limit 5

# View specific run
gh run view <run-id>

# View logs
gh run view <run-id> --log-failed
```

## Step 7: Verify Remote Health

Once deployment completes, check the remote health endpoint:

```bash
curl -s <remote-health-url> | jq .
```

**Expected:** Health check passes. Allow up to 60 seconds for service restart.

```bash
# Retry with delay if needed
for i in {1..6}; do
  curl -s <remote-health-url> && break
  echo "Waiting for service... attempt $i"
  sleep 10
done
```

## Step 8: Remote Smoke Tests

Perform targeted smoke tests against production, based on your implementation knowledge:

**For API changes:**
```bash
# Use PAT for authentication
PAT=$(cat .claude/pat.txt)
curl -s -H "X-API-Key: $PAT" <remote-api-url>/<endpoint> | jq .
```

**For MCP tool changes:**
- Test via MCP tools (they use remote URLs automatically)
- Verify tool responses match local testing results

**For data model changes:**
- Verify migrations applied correctly
- Test CRUD operations on new/modified entities

**Document what you tested:**
```
## Remote Smoke Tests: <CR-ID>

### Deployment
- GitHub Actions: PASS
- Health check: PASS

### API Tests
- POST <remote>/api/v1/resource - Works
- GET <remote>/api/v1/resource/{id} - Returns data

### MCP Tools
- <tool_name> returns expected response

### Observations
- <Any differences from local behaviour>
- <Performance observations>
```

## Step 9: Compare Local vs Remote

Briefly verify remote behaviour matches local:

- Same responses for equivalent requests?
- No unexpected errors in remote logs?
- Data integrity maintained?

If significant differences exist, investigate before proceeding.

## Blocking (STOP)

- Commit fails (merge conflicts, pre-commit hooks)
- Push fails (authentication, branch protection)
- GitHub Actions deployment fails
- Health check fails after deployment
- Critical smoke test fails (core functionality broken)
- Significant behaviour difference between local and remote

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "remote-test",
    "reason": "<short reason>",
    "details": {
      // For deployment failure:
      "workflow_run_id": "<id>",
      "failure_step": "<step name>",
      "error": "<error message>"
      // For health check failure:
      "endpoint": "<url>",
      "status_code": <code>,
      "response": "<response>"
      // For smoke test failure:
      "test": "<what was tested>",
      "expected": "<expected>",
      "actual": "<actual>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: remote-test] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Minor latency differences between local and remote
- Non-blocking warnings in deployment logs
- Flaky health check that passes on retry
- Edge case smoke tests (if core functionality works)

## Retry Logic

| Failure Type | Retry Attempts | Then |
|--------------|----------------|------|
| Push conflict | 1 rebase attempt | Block |
| Deployment failure | 2 attempts (re-run workflow) | Block |
| Health check | 3 attempts (with 10s wait) | Block |
| Smoke test | 2 attempts | Block |

## Completion

If all conditions are met:
1. Changes committed with proper message
2. Push successful
3. GitHub Actions deployment passed
4. Remote health check passes
5. Smoke tests demonstrate expected behaviour
6. Local and remote behaviour match

**Output:**
```
[GATE_PASS: remote-test]
```

Proceed immediately to completing-work phase. **Do NOT wait for confirmation.**
