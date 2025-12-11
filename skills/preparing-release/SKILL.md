---
name: preparing-release
description: >
  Activates when preparing for deployment, creating a release, checking deployment
  readiness, or when validated work items need to be deployed. Use when work is
  validated and ready for production, or when checking release status before
  pushing code.
---

# Preparing Release

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

Work items are `validated` and ready for deployment. Create release, deploy, and complete unless blocked.

## Session Context

This skill expects:
- Work Item context from a resumed session (after validation), OR
- Explicit invocation: "Load skill preparing-release for CR-042"

If no Work Item context is available, ask for the Work Item ID before proceeding.

**If this is a retry (work item was previously blocked at this gate):**
- Check `blocking_context.gate` - if it was "preparing-release", review what failed
- Focus extra attention on the previously-blocked condition
- Check `blocking_context.previous_blocks` for recurring patterns

## Agent Identity: Release Manager

**IMPORTANT:** Release operations require the release manager agent identity.

```
select_agent(agent_email='release_manager@tarka.internal')
```

## The Deployment Gate

**You CANNOT deploy (push to main/production) without an approved Release.**

This is not a suggestion. The release provides:
- Change coordination
- Deployment approval
- Audit trail
- Rollback reference

## Step 1: Verify Work Item Status

```
get_work_item(work_item_id='<CR-ID>')
```

Confirm status is `validated`. If not, this skill was invoked out of order.

## Step 2: Check for Existing Release

```
list_releases(
  project_id='<project>',
  status='approved'
)
```

**If approved release exists:**
- Verify your work items are included
- Proceed to deployment

**If no approved release:**
- Create a new release
- Get it approved before deploying

## Step 3: Create a Release (If Needed)

```
create_release(
  organization_id='<org>',
  project_id='<project>',
  title='Release <version> - <summary>',
  description='<what this release includes>',
  includes=['<CR-ID-1>', '<CR-ID-2>']  # Work items in this release
)
```

**Release title conventions:**
- `Release v1.2.3 - User authentication improvements`
- `Release 2024-01-15 - Sprint 42 deliverables`

**The `includes` field is critical:**
- Only work items explicitly in `includes` can be deployed via this release
- Tags do NOT create release membership
- Add all validated work items that should deploy together

## Step 4: Release Approval

The release must be approved before deployment.

**Check release status:**
```
get_release(release_id='<RELEASE-ID>')
```

**If not approved:**
- Inform user that release needs approval
- Developer cannot approve releases (requires appropriate authority)
- Wait for approval before proceeding

**Transition to approved (if authorized):**
```
transition_release(release_id='<RELEASE-ID>', new_status='approved')
```

## Step 5: Pre-Deployment Checks

Before deploying, verify:

**All included work items are validated:**
```
# For each work item in release.includes
get_work_item(work_item_id='<CR-ID>')
# Status should be 'validated'
```

**Tests pass on deployment branch:**
```bash
git checkout main  # or deployment branch
git pull
pytest tests/      # run full test suite
```

**No conflicts:**
```
check_work_item_conflicts(work_item_id='<RELEASE-ID>')
```

**No version drift:**
```
check_work_item_drift(work_item_id='<RELEASE-ID>')
```

## Step 6: Deploy

Only when:
- Release is approved
- All work items are validated
- Tests pass
- No conflicts or drift

**Push to production branch:**
```bash
git push origin main
```

**Transition release to completed (cascades to work items):**
```
transition_release(release_id='<RELEASE-ID>', new_status='completed')
```

This automatically transitions included work items through `deployed` to `completed`.

## Release Checklist

```
## Release: <RELEASE-ID>

### Pre-Deployment
- [ ] Release created with correct `includes`
- [ ] Release approved
- [ ] All included work items validated
- [ ] Tests passing on deployment branch
- [ ] No conflicts detected
- [ ] No version drift detected

### Deployment
- [ ] Code pushed to production
- [ ] Release transitioned to `completed`
- [ ] Deployment verified in production

### Post-Deployment
- [ ] All work items now `completed`
```

## Blocking (STOP)

- Release not approved (must wait for approval)
- Work items not validated
- Tests failing on deployment branch
- Conflicts detected (must resolve first)
- Deployment fails after 2 attempts

If blocked, transition work item:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "preparing-release",
    "reason": "<short reason>",
    "details": {
      "release_id": "<RELEASE-ID>",
      "issue": "<what's wrong>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: preparing-release] <reason>
```

Then STOP. A Task will be automatically created to notify the appropriate human.

## Non-Blocking (PROCEED)

- Release naming conventions (use sensible defaults)
- Minor pre-deployment check warnings (note and proceed if not critical)
- Version numbering (follow existing pattern or use date-based)

## Retry Logic

If deployment fails:
1. Check logs: `gh run view --log-failed`
2. Fix the issue
3. Push again

After 2 attempts, **STOP** and transition to blocked.

## Completion

After successful deployment:
1. Transition release to `completed`
2. Verify in production
3. Report completion with summary

**Output:**
```
[GATE_PASS: preparing-release]
```

**Do NOT wait for confirmation at each step.**

## After Deployment

Monitor production for issues. If problems arise:
- Release ID provides audit trail
- Included work items show what changed
- Implementation refs link to specific commits for rollback
