---
name: preparing-release
description: >
  Activates when preparing for deployment, creating a release, checking deployment
  readiness, or when validated work items need to be deployed. Use when work is
  validated and ready for production, or when checking release status before
  pushing code.
---

# Preparing Release

Work items are `validated` and ready for deployment. Deployment requires an
approved Release.

## The Deployment Gate

**You CANNOT deploy (push to main/production) without an approved Release.**

This is not a suggestion. The release provides:
- Change coordination
- Deployment approval
- Audit trail
- Rollback reference

## Step 1: Check for Existing Release

```
list_work_items(
  project_id='<project>',
  work_item_type='release',
  status='approved'
)
```

**If approved release exists:**
- Verify your work items are included
- Proceed to deployment

**If no approved release:**
- Create a new release
- Get it approved before deploying

## Step 2: Create a Release (If Needed)

```
create_work_item(
  organization_id='<org>',
  project_id='<project>',
  work_item_type='release',
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

## Step 3: Release Approval

The release must be approved before deployment.

**Check release status:**
```
get_work_item(work_item_id='<RELEASE-ID>')
```

**If not approved:**
- Inform user that release needs approval
- Developer cannot approve releases (requires appropriate authority)
- Wait for approval before proceeding

## Step 4: Pre-Deployment Checks

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

## Step 5: Deploy

Only when:
- Release is approved
- All work items are validated
- Tests pass
- No conflicts or drift

**Push to production branch:**
```bash
git push origin main
```

**Transition release to deployed:**
```
transition_work_item(work_item_id='<RELEASE-ID>', new_status='deployed')
```

This automatically transitions included work items to `deployed`.

## Step 6: Complete Release

After deployment is verified in production:

```
transition_work_item(work_item_id='<RELEASE-ID>', new_status='completed')
```

This cascades `completed` to all included work items that are `validated`.

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
- [ ] Release transitioned to `deployed`
- [ ] Deployment verified in production

### Post-Deployment
- [ ] Release transitioned to `completed`
- [ ] All work items now `completed`
```

## Common Issues

**Work item not in release:**
```
update_work_item(
  work_item_id='<RELEASE-ID>',
  includes=['<existing>', '<new-CR-ID>']  # Add to includes
)
```

**Release has conflicts:**
- Review conflict report
- Resolve in code
- Re-validate affected work items
- Re-check conflicts

**Work item not validated:**
- Cannot deploy unvalidated work
- Return to validation phase
- Or remove from release and deploy without it

## Gate: Do Not Deploy If

- No approved release exists
- Work items not validated
- Tests failing
- Conflicts detected
- Release not approved

## After Deployment

Monitor production for issues. If problems arise:
- Release ID provides audit trail
- Included work items show what changed
- Implementation refs link to specific commits for rollback
