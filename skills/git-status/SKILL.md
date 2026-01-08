---
name: "git-status"
description: "Extended git status that audits working tree, local/remote branches, staleness, and merge status. Use when checking repository health or before starting work."
---

# Git Status (Extended)

Perform a comprehensive git repository health check that goes beyond `git status` to include branch auditing, staleness detection, and merge status analysis.

## When to Use

- Before starting work on a repository
- When asked for "git status", "branch status", or "repo health"
- To identify stale branches needing cleanup
- To check which branches have unmerged changes
- To verify sync status with remote

## Extended Status Report

### Phase 1: Working Tree Status

Standard git status information:

```bash
# Current branch and tracking info
git status --short --branch

# Detailed status if changes exist
git status
```

Report:
- Current branch name
- Tracking branch (if any)
- Ahead/behind status
- Staged changes
- Unstaged changes
- Untracked files

### Phase 2: Local Branch Audit

Analyze all local branches:

```bash
# List all local branches with last commit info
git for-each-ref --sort=-committerdate refs/heads/ \
  --format='%(refname:short)|%(committerdate:relative)|%(committerdate:iso)|%(subject)|%(authorname)'
```

For each local branch, determine:

| Metric | Command | Interpretation |
|--------|---------|----------------|
| Last commit age | `git log -1 --format=%cr <branch>` | Staleness indicator |
| Commits ahead of main | `git rev-list --count main..<branch>` | Unmerged work |
| Commits behind main | `git rev-list --count <branch>..main` | Needs rebase/merge |
| Has remote tracking | `git config branch.<branch>.remote` | Pushed or local-only |

### Phase 3: Remote Branch Audit

Sync and analyze remote branches:

```bash
# Fetch latest remote state (without pulling)
git fetch --all --prune

# List remote branches with last commit info
git for-each-ref --sort=-committerdate refs/remotes/origin/ \
  --format='%(refname:short)|%(committerdate:relative)|%(committerdate:iso)|%(subject)'
```

Identify:
- Remote branches without local tracking
- Local branches deleted on remote
- Remote branches ahead of local

### Phase 4: Staleness Analysis

Categorize branches by age:

| Category | Age Threshold | Recommendation |
|----------|---------------|----------------|
| Active | < 7 days | Current work |
| Recent | 7-30 days | Review status |
| Stale | 30-90 days | Consider cleanup |
| Abandoned | > 90 days | Delete candidate |

```bash
# Find branches older than 90 days
git for-each-ref --sort=committerdate refs/heads/ \
  --format='%(refname:short) %(committerdate:short)' | \
  while read branch date; do
    if [[ $(date -d "$date" +%s) -lt $(date -d "90 days ago" +%s) ]]; then
      echo "$branch ($date)"
    fi
  done
```

### Phase 5: Merge Status Analysis

For each non-main branch, determine merge status:

```bash
# Check if branch is merged into main
git branch --merged main

# Check if branch is NOT merged into main
git branch --no-merged main

# For each unmerged branch, check merge conflicts
git merge-tree $(git merge-base main <branch>) main <branch>
```

Categories:
- **Merged**: Safe to delete
- **Unmerged, clean**: Can merge without conflicts
- **Unmerged, conflicts**: Will require conflict resolution

---

## Output Format

### Summary View

```
Repository: local-dev-setup
Main Branch: main

WORKING TREE
  Branch: main
  Tracking: origin/main (up to date)
  Status: Clean

LOCAL BRANCHES (5 total)
  Active (2):
    feature/new-skill      3 hours ago   +12/-0 vs main
    fix/typo               1 day ago     +1/-0 vs main (merged)

  Stale (2):
    old-experiment         45 days ago   +8/-0 vs main
    archived-feature       67 days ago   +24/-0 vs main

  Abandoned (1):
    legacy-migration       142 days ago  +156/-0 vs main

REMOTE BRANCHES
  Orphaned local (no remote):
    old-experiment

  Orphaned remote (no local):
    origin/dependabot/npm-update

MERGE STATUS
  Ready to merge:
    fix/typo (already merged, safe to delete)

  Needs rebase:
    feature/new-skill (3 commits behind main)

  Has conflicts:
    old-experiment (conflicts in: src/config.ts)

RECOMMENDATIONS
  1. Delete merged branch: fix/typo
  2. Rebase before merge: feature/new-skill
  3. Review or delete stale: old-experiment (45 days)
  4. Delete abandoned: legacy-migration (142 days, never pushed)
```

### Detailed View (when requested)

Include for each branch:
- Full commit log since divergence from main
- File change summary
- Conflict file list (if applicable)
- PR status (if pushed to remote)

---

## Implementation Commands

### Core Commands

```bash
# Get main branch name (handles main vs master)
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"

# Current branch
git branch --show-current

# All branches with details
git for-each-ref --sort=-committerdate refs/heads/ refs/remotes/origin/ \
  --format='%(refname:short)|%(objectname:short)|%(committerdate:relative)|%(committerdate:unix)|%(upstream:trackshort)|%(subject)'

# Ahead/behind for current branch
git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "0 0"

# Check if branch is merged
git branch --merged main | grep -q "branch-name" && echo "merged" || echo "unmerged"

# Commits unique to branch
git rev-list --count main..branch-name

# Check for merge conflicts (dry run)
git merge --no-commit --no-ff branch-name 2>&1 | grep -q "CONFLICT" && echo "conflicts" || echo "clean"
git merge --abort 2>/dev/null  # Clean up dry run
```

### GitHub CLI Integration (Optional)

If `gh` is available, enhance with PR status:

```bash
# Check if branch has open PR
gh pr list --head branch-name --json number,state,title --jq '.[0]'

# Get PR review status
gh pr view branch-name --json reviewDecision,reviews
```

---

## Error Handling

### Not a Git Repository

```
Error: Not a git repository

Please run this command from within a git repository, or specify a path:
  /git-status /path/to/repo
```

### No Remote Configured

```
Warning: No remote 'origin' configured

Local-only repository detected. Remote branch analysis skipped.
Showing local branches only.
```

### Network Unavailable

```
Warning: Could not fetch from remote (network unavailable)

Showing cached remote state. Remote data may be stale.
Last fetch: 2 hours ago
```

---

## Usage Examples

**Basic invocation:**
```
/git-status
```

**With specific repository:**
```
/git-status /path/to/repo
```

**Quick summary only:**
```
/git-status --summary
```

**Include PR status (requires gh):**
```
/git-status --with-prs
```

---

## Configuration

The skill respects these thresholds (can be overridden):

| Setting | Default | Description |
|---------|---------|-------------|
| `stale_days` | 30 | Days before branch is "stale" |
| `abandoned_days` | 90 | Days before branch is "abandoned" |
| `fetch_remote` | true | Whether to fetch before analysis |
| `check_conflicts` | true | Whether to do merge conflict detection |

---

## Your Responsibilities

1. **Run fetch first** - Always fetch to get current remote state (unless offline)
2. **Identify main branch** - Handle both `main` and `master` conventions
3. **Categorize clearly** - Use consistent staleness categories
4. **Provide actionable recommendations** - Tell user what to do, not just what exists
5. **Handle edge cases** - New repos, detached HEAD, bare repos, submodules
6. **Be concise** - Summary first, details on request

---

## Example Session

```
User: /git-status

Agent:
Fetching latest remote state...

Repository: local-dev-setup (main)
Working Tree: Clean

BRANCHES SUMMARY
  Local: 4 branches (2 active, 1 stale, 1 abandoned)
  Remote: 3 branches (1 orphaned)

ATTENTION NEEDED
  Ready to delete (merged):
    fix/readme-typo

  Needs rebase (5 commits behind):
    feature/git-status-skill

  Stale (no activity 45 days):
    experiment/old-approach

  Abandoned (no activity 120 days, never pushed):
    wip/forgotten-feature

Run with --details for full branch information.
```
