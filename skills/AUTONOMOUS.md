# Autonomous Operation Guide

All TarkaFlow skills run **autonomously by default**. This guide defines when to stop vs proceed.

## Core Principle

**Proceed unless blocked.** Do not ask for confirmation. Do not pause to summarize and wait. Complete the work.

## Blocking Issues (MUST Stop)

Only stop and ask the user when you encounter these situations:

| Category | Examples |
|----------|----------|
| **Missing Identity** | CR ID not provided, requirement not found |
| **Security Decisions** | Auth approach unclear, data exposure questions, permission model undefined |
| **Architectural Ambiguity** | Multiple valid approaches with significantly different trade-offs |
| **Conflicting Requirements** | ACs contradict each other, requirements conflict |
| **Stuck Failures** | Tests fail after 3 fix attempts, deployment fails after 2 attempts |
| **Missing Prerequisites** | CR not approved, dependencies not met, release not approved |
| **Cannot Verify** | Environment broken, missing access, tests won't run |

## Non-Blocking Issues (Proceed with Judgment)

Make a reasonable decision and document it. Do NOT stop.

| Situation | Action |
|-----------|--------|
| Minor spec ambiguity | Choose sensible default, note in commit/summary |
| Missing error message text | Use clear, helpful defaults |
| Style/approach choice between equivalents | Pick one, proceed |
| Unspecified UI details | Match existing patterns |
| Missing optional details | Implement core functionality |
| AC wording unclear but intent obvious | Implement the intent, note interpretation |
| Test naming conventions | Follow existing patterns |

## Phase-Specific Autonomy

### picking-up-work
- **Proceed**: When CR exists, is approved/in_progress, and you can fetch requirements
- **Block**: CR missing, not approved, requirements not found

### test-readiness (tester agent)
- **Proceed**: When you can write tests for ACs, even if test naming is a judgment call
- **Block**: AC fundamentally untestable, cannot run test suite

### implementation
- **Proceed**: When making tests green, choosing between equivalent implementations
- **Block**: Test won't pass after 3 attempts, fundamental design question

### local-test (tester agent)
- **Proceed**: Containers healthy, system tests pass, smoke tests demonstrate functionality
- **Block**: Containers won't start, migrations fail, system tests fail after 3 attempts

### remote-test (tester agent)
- **Proceed**: Deployment passes, health checks pass, smoke tests match local behaviour
- **Block**: Deployment fails, health check fails, critical smoke test fails

### completing-work
- **Proceed**: Creating imp notes, updating LDM/interfaces, adding tags
- **Block**: Unsure what was actually implemented (shouldn't happen)

### validation (tester agent)
- **Proceed**: Verifying ACs, marking met/unmet
- **Block**: Cannot verify AC (env broken), AC ambiguous with no reasonable interpretation

### preparing-release
- **Proceed**: Creating release, running pre-deployment checks
- **Block**: Release not approved (must wait), tests failing, conflicts detected

## Documenting Assumptions

When you make a judgment call on a non-blocking issue:

1. **In commit messages**: Add "Assumptions:" section
2. **In summaries**: List decisions made
3. **In imp notes**: Document key decisions

Example:
```
Assumptions made:
- Error messages use sentence case (no existing convention found)
- Rate limit set to 100/min (spec said "reasonable limit")
- Validation runs on blur, not on change (UX judgment)
```

## Retry Logic

| Failure Type | Retry Attempts | Then |
|--------------|----------------|------|
| Test failure | 3 attempts | Block, ask for help |
| Deployment failure | 2 attempts | Block, ask for help |
| MCP tool error | 1 retry | Report and continue if possible |
| Git push conflict | 1 rebase attempt | Block if still failing |

## The "Shall I Proceed?" Anti-Pattern

**Never ask:**
- "Shall I proceed with implementation?"
- "Does this look correct?"
- "Are you ready for me to continue?"
- "Let me know when you want me to start"

**Instead:**
- Proceed immediately
- Report what you did when done
- Only stop for blocking issues

## Summary

```
if blocking_issue:
    stop_and_ask()
else:
    proceed()
    document_assumptions()
    report_when_done()
```
