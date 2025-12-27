# Requirement Traceability Patterns

Techniques for tracing TarkaFlow requirements to codebase implementation.

## Traceability Matrix Approach

### Building the Matrix

For each requirement, track:

| Field | Description |
|-------|-------------|
| Requirement ID | TarkaFlow HRID (e.g., TFLO-REQ-001) |
| Title | Requirement title |
| Type | epic/component/feature/requirement/imp |
| Status | draft/review/approved/deprecated |
| Code Locations | Files/functions implementing this requirement |
| Test Locations | Test files covering this requirement |
| AC Status | Which acceptance criteria are met |

### Locating Implementations

**Strategy 1: Naming Conventions**
```
# Search for requirement ID in comments/docstrings
grep -r "TFLO-REQ-001\|REQ-001" --include="*.py" --include="*.ts"

# Search for feature names
grep -ri "user authentication" --include="*.py" --include="*.ts"
```

**Strategy 2: Directory Mapping**
```
Feature: User Management -> /src/users/ or /src/features/users/
Component: API Gateway -> /src/api/ or /src/gateway/
```

**Strategy 3: Work Item References**
```
# Git commit messages often reference work items
git log --grep="TFLO-CR-" --oneline

# Search for work item IDs in code
grep -r "CR-\|BUG-\|DEBT-" --include="*.py" --include="*.ts"
```

## Acceptance Criteria Verification

### AC to Test Mapping

For each acceptance criterion:

1. **Identify Test Type Needed**
   - "WHEN user clicks X THEN Y happens" -> Integration/E2E test
   - "System must respond in < 100ms" -> Performance test
   - "Input must be validated" -> Unit test

2. **Search for Corresponding Tests**
   ```
   # Test file patterns
   grep -r "test.*login\|login.*test" --include="*test*.py" --include="*.spec.ts"

   # Assertion patterns matching AC language
   grep -r "should return\|expect.*to" --include="*test*.py" --include="*.spec.ts"
   ```

3. **Document Coverage**
   - Full: Test exists and exercises the AC
   - Partial: Test exists but doesn't fully cover AC
   - Missing: No test found for this AC

### Coverage Gap Patterns

**Common Gaps:**
- Happy path tested, edge cases missing
- Unit tests present, integration tests missing
- Functional tests present, performance tests missing
- Success cases tested, error handling untested

## Implementation Completeness

### Full Implementation Indicators
- Feature flag (if any) is enabled
- No TODO/FIXME comments related to feature
- Error handling for all failure modes
- Logging/monitoring in place
- Documentation updated

### Partial Implementation Indicators
- Core functionality works
- Edge cases not handled
- Error messages generic
- Missing validation
- No observability

### Missing Implementation Indicators
- Only stub/placeholder code
- Feature flag disabled
- Commented out code
- Only interface defined, no implementation

## Work Item Verification

### For Completed Work Items

**Verification Steps:**
1. Find the git commits associated with the work item
   ```
   git log --grep="TFLO-CR-XXX" --oneline
   ```

2. Review the changes introduced
   ```
   git show <commit-hash>
   ```

3. Verify changes match the work item description

4. Confirm tests were added/updated

5. Check for any regression risks

### For In-Progress Work Items

**Assessment Points:**
- Is the implementation on track?
- Are blocked_by items resolved?
- Is the approach aligned with requirements?
- Are there any blockers not captured?

### For Technical Debt Items

**Current State Assessment:**
- How severe is the debt currently?
- Is it getting worse (compounding)?
- What's the remediation effort?
- What's the risk of not addressing it?

## Drift Detection

### Implementation Drift

Over time, code may drift from original requirements:

**Signs of Drift:**
- Functionality differs from requirement description
- Additional undocumented behavior
- Missing documented behavior
- Changed interfaces

**Detection Approach:**
1. Re-read the requirement carefully
2. Trace through current implementation
3. Compare expected vs actual behavior
4. Document discrepancies

### Requirement Drift

Requirements may have evolved but code wasn't updated:

**Detection:**
```
# Compare requirement version in work item baseline vs current
Use: mcp__tflo__check_work_item_drift
```

## Report Integration

### Traceability Section Format

```markdown
## Requirement: {HRID} - {Title}

**Status**: {requirement_status}
**Type**: {type}

### Implementation Analysis

**Code Locations:**
- `src/module/file.py:123-456` - Main implementation
- `src/api/routes.py:78` - API endpoint

**Test Coverage:**
- `tests/test_module.py::test_feature` - Unit tests
- `tests/integration/test_api.py::test_endpoint` - Integration

### Acceptance Criteria Status

| AC | Description | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | User can... | Met | test_user_can.py |
| AC2 | System validates... | Partial | Missing edge cases |
| AC3 | Error handling... | Unmet | No test coverage |

### Gaps Identified

1. **AC2 partial**: Edge cases for validation not covered
   - Recommendation: Add tests for empty input, max length

2. **AC3 unmet**: Error handling not implemented
   - Recommendation: Add try/catch and error responses
```

## Tools and Techniques

### Code Search

Use Grep tool with patterns:
```
# Requirement references
pattern: "TFLO-\w+-\d+"

# Feature keywords from requirement title
pattern: "user.*(login|auth|session)"

# Test assertions
pattern: "(expect|assert|should).*feature_name"
```

### Git History

```bash
# Commits mentioning requirement/work item
git log --grep="TFLO-" --all --oneline

# Changes to specific files over time
git log -p -- src/feature/

# Blame for specific lines
git blame src/feature/file.py
```

### Dependency Analysis

For understanding implementation scope:
```bash
# What depends on this module?
grep -r "from.*module import\|import.*module" --include="*.py"

# What does this module depend on?
head -50 src/module/__init__.py | grep import
```
