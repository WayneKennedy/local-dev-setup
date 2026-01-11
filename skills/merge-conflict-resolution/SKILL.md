---
name: merge-conflict-resolution
description: >
  Activates when merging feature branches into release branches encounters conflicts.
  Use during release preparation when GitHub API merge fails due to conflicts.
  Provides resolution strategies and ensures clean merges without data loss.
---

# Merge Conflict Resolution

**Autonomous by default.** See [AUTONOMOUS.md](../AUTONOMOUS.md) for blocking vs non-blocking guidance.

A merge conflict occurred while merging a feature branch into a release branch. Resolve the conflict and complete the merge.

## Session Context

This skill expects:
- Context from `preparing-release` skill when a merge conflict is detected, OR
- Explicit invocation: "Load skill merge-conflict-resolution for TFLO-REL-042"

**Required context:**
- `release_id`: The release being processed (e.g., TFLO-REL-042)
- `release_branch`: Target branch (e.g., release/TFLO-REL-042)
- `feature_branch`: Source branch with the feature (e.g., tflo-cr-001)
- `hrid`: Work item HRID (e.g., TFLO-CR-001)

If context is missing, ask for the release ID and feature branch before proceeding.

## Agent Identity

```
select_agent(agent_email='code@tarka.internal')
```

Merge conflict resolution is a development task.

## Step 1: Checkout Release Branch

Ensure you're on the latest release branch:

```bash
git fetch origin
git checkout {release_branch}
git pull origin {release_branch}
```

## Step 2: Attempt the Merge

Try the merge locally:

```bash
git merge origin/{feature_branch} --no-ff -m "Merge {hrid} into {release_branch}"
```

If no conflicts, skip to Step 5 (push).

## Step 3: Identify Conflicted Files

If conflicts occur:

```bash
git status
```

List all files with conflicts. For each conflicted file, note:
- File path
- Type of conflict (content, rename, deletion)

## Step 4: Resolve Conflicts

For each conflicted file:

### 4a. Read and Understand Both Versions

Open the file and examine the conflict markers:

```
<<<<<<< HEAD
(release branch version)
=======
(feature branch version)
>>>>>>> origin/{feature_branch}
```

### 4b. Apply Resolution Strategy

**Code conflicts:**
- Analyze the semantic intent of both changes
- If both add different functionality, keep both
- If they modify the same logic, prefer the feature branch version (newer work)
- Ensure the merged result is syntactically and semantically correct

**Import conflicts:**
- Include all imports from both branches
- Remove duplicates
- Sort alphabetically (follow project conventions)

**Configuration conflicts:**
- Merge configuration objects
- Prefer newer values for duplicate keys
- Ensure no conflicting settings

**Test conflicts:**
- Keep ALL tests from both branches
- Never delete tests during conflict resolution
- If test names conflict, rename to distinguish

**Documentation conflicts:**
- Combine documentation
- Keep the most complete version
- Ensure accuracy for both feature sets

### 4c. Stage Resolved Files

After resolving each file:

```bash
git add <file>
```

### 4d. Complete the Merge

Once all conflicts are resolved:

```bash
git commit -m "Merge {hrid} into {release_branch} (conflict resolved)"
```

## Step 5: Push the Resolved Merge

```bash
git push origin {release_branch}
```

## Step 6: Document Resolution

Report what was resolved:

```
## Merge Conflict Resolution: {hrid} into {release_branch}

### Conflicts Resolved
| File | Conflict Type | Resolution |
|------|---------------|------------|
| src/api/routes.py | Both added endpoints | Kept both, no overlap |
| src/models/user.py | Field modifications | Merged field additions |
| tests/test_auth.py | Both added tests | Kept all tests |

### Merge Commit
SHA: <commit-sha>

### Verification
- [ ] All tests pass on release branch
- [ ] No test files deleted
- [ ] No functionality removed
```

## Resolution Strategies Reference

| Conflict Type | Strategy | Example |
|---------------|----------|---------|
| Both add code | Keep both | Two new functions - include all |
| Both modify same line | Prefer feature | Feature has latest intent |
| One deletes, one modifies | Keep modification | Don't lose work |
| Formatting conflicts | Use project formatter | Run `black` or `prettier` |
| Rename conflicts | Keep both names | May need refactoring later |

## Blocking (STOP)

- Cannot understand semantic intent of both changes
- Resolution would delete significant functionality
- Resolution would remove tests
- Fundamental architectural disagreement between branches
- Push fails due to permissions or protected branch rules
- Tests fail after resolution

If blocked:

```
transition_work_item(
  work_item_id='<CR-ID>',
  new_status='blocked',
  blocking_context={
    "gate": "merge-conflict-resolution",
    "reason": "<short reason>",
    "details": {
      "release_id": "<RELEASE-ID>",
      "feature_branch": "<branch>",
      "conflicted_files": ["<file1>", "<file2>"],
      "issue": "<why resolution is not possible>"
    }
  }
)
```

**Output:**
```
[GATE_FAIL: merge-conflict-resolution] <reason>
```

Then STOP. Human intervention required for complex architectural conflicts.

## Non-Blocking (PROCEED)

- Minor formatting differences (apply formatter)
- Whitespace conflicts (standardize)
- Comment conflicts (keep most informative)
- Import order differences (sort consistently)
- Test name overlaps (rename to distinguish)

## Completion

When merge is successful:
1. Conflicts resolved
2. Merge commit pushed
3. No tests deleted
4. All tests pass on release branch

**Output:**
```
[GATE_PASS: merge-conflict-resolution]

MERGE_SHA: <commit-sha>
FILES_RESOLVED: <list>
```

Return to `preparing-release` to continue the release process.

## Common Conflict Patterns

### Database Migration Conflicts

When both branches add migrations:

```bash
# List migrations
ls alembic/versions/

# Check for sequence conflicts
# Rename if needed to maintain order
```

Resolution: Keep both migrations, ensure sequence is correct.

### Package Dependency Conflicts

When `requirements.txt` or `package.json` conflicts:

```bash
# Merge both sets of dependencies
# Check for version conflicts
# Use higher version if compatible
```

### API Schema Conflicts

When OpenAPI/GraphQL schemas conflict:

- Merge endpoints (both add = keep both)
- Merge types (combine fields)
- Check for breaking changes

### Configuration Conflicts

When `.env.example` or config files conflict:

- Keep all configuration options
- Note new required variables
- Update documentation
