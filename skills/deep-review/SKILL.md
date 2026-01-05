---
name: "deep-review"
description: "This skill should be used when the user asks to 'deep review', 'gap analysis', 'analyze codebase against requirements', 'check compliance', 'review against guardrails', or 'audit code against work items'. Performs comprehensive codebase analysis against TarkaFlow guardrails, requirements, and work items."
---

# Deep Review

Perform a critical analysis of a repository's codebase against all active guardrails and all work items and requirements (open and completed/deployed) from TarkaFlow.

**Key Feature**: Findings are recorded directly to TarkaFlow as a Governance Audit entity, enabling tracking, trending, and auto-remediation.

## Prerequisites

Before starting a deep review:

1. **Select the EA Agent**: Execute `select_agent(agent_email='ea@tarka.internal')` to operate as the Enterprise Architect agent
2. **Identify the Target Repository**: Determine which repository to analyze
3. **Identify the TarkaFlow Project**: Match the repository to its TarkaFlow project for requirements/work items

## Deep Review Process

### Phase 1: Context Gathering

#### Step 1.1: Select Agent
```
Use: mcp__tflo__select_agent with agent_email='ea@tarka.internal'
```

#### Step 1.2: Identify TarkaFlow Resources

1. **List Projects**: Use `mcp__tflo__list_projects` to find the relevant project
2. **Select Project**: Use `mcp__tflo__select_project` with the matching project_id
3. **Identify Repository**: Use `mcp__tflo__list_repositories` to get repository_id

#### Step 1.3: Check Previous Audits (Optional)

Check for prior audit trends before starting:
```
Use: mcp__tflo__list_governance_audits with repository_id
Use: mcp__tflo__get_repeat_violations with repository_id to identify recurring issues
```

#### Step 1.4: Create Governance Audit

Create a new audit record to track findings:
```
Use: mcp__tflo__create_audit with:
  - repository_id: UUID of the repository
  - executed_by: "deep-review-skill"
```

Save the returned `audit_id` for recording findings.

#### Step 1.5: Gather All Artifacts

Collect these in parallel:

**Guardrails:**
```
Use: mcp__tflo__list_guardrails with organization_id and status='active'
For each guardrail: mcp__tflo__get_guardrail to get full content
```

**Requirements Hierarchy:**
```
Use: mcp__tflo__list_requirements with project_id to get all requirements
For each requirement type (epic, component, feature, requirement, imp):
  - Use mcp__tflo__get_requirement for full content including acceptance criteria
```

**Work Items (All States):**
```
Use: mcp__tflo__list_work_items with project_id and include_completed=true
For each work item: mcp__tflo__get_work_item for full context
```

### Phase 2: Codebase Analysis

#### Step 2.1: Understand Codebase Structure

Use the Explore agent to map the repository structure:
- Entry points and main modules
- Directory organization
- Key configuration files
- Test coverage structure
- Documentation locations

#### Step 2.2: Guardrail Compliance Check

For each active guardrail, analyze the codebase for compliance:

| Category | Analysis Focus |
|----------|----------------|
| Security | Auth patterns, input validation, secrets handling, OWASP compliance |
| Architecture | Layer boundaries, dependency directions, pattern adherence |
| Business | Domain logic placement, business rule implementation |

**Record each violation immediately using batch recording:**
```
Use: mcp__tflo__record_findings_batch with:
  - audit_id: UUID from Step 1.4
  - findings: [
      {
        "finding_id": "V-001",  # Sequential within audit
        "category": "guardrail_violation",
        "severity": "critical|major|minor",
        "description": "Description of the violation",
        "guardrail_id": "GUARD-XXX-NNN",  # HRID of violated guardrail
        "location": {"file": "path/to/file.py", "start_line": 42, "end_line": 45},
        "remediation": "How to fix"
      },
      ...
    ]
```

Finding categories:
- `guardrail_violation` - Code violates a guardrail
- `requirement_gap` - Requirement not implemented
- `work_item_drift` - Implementation differs from work item intent

#### Step 2.3: Requirements Traceability

For each requirement with acceptance criteria:

1. **Locate Implementation**: Find where the requirement is implemented in code
2. **Verify Coverage**: Check if all acceptance criteria have corresponding tests
3. **Assess Completeness**: Determine if implementation fully satisfies the requirement
4. **Check for Drift**: Compare current implementation against original requirement intent

Document gaps:
- Requirement ID and title
- Implementation status (implemented/partial/missing)
- AC coverage (which ACs are met, which are not)
- Code locations

#### Step 2.4: Work Item Alignment

For each work item (CR, bug, debt):

1. **Trace Changes**: Identify code changes attributable to the work item
2. **Verify Completion**: For completed items, confirm implementation matches intent
3. **Check Dependencies**: Verify blocked_by relationships are resolved
4. **Assess Technical Debt**: For debt items, evaluate current state

### Phase 3: Complete Audit in TarkaFlow

#### Step 3.1: Complete the Governance Audit

After recording all findings, complete the audit:
```
Use: mcp__tflo__complete_audit with:
  - audit_id: UUID from Step 1.4
  - guardrails_analyzed: Total number of guardrails checked
  - violations_found: Total findings recorded
  - critical_count: Count of critical severity findings
  - major_count: Count of major severity findings
  - minor_count: Count of minor severity findings
```

#### Step 3.2: Auto-Remediation (Optional)

Generate work items from critical/major findings:
```
Use: mcp__tflo__action_audit with:
  - audit_id: UUID from Step 1.4
  - limit: 3  # Top 3 findings by severity
  - preview: true  # First preview candidates
```

If preview looks good, run again with `preview: false` to create work items.

### Phase 4: Generate Report

#### Step 4.1: Create Report Structure

Create the report at `{repo_root}/docs/DEEP-REVIEW-{PROJECT_SLUG}-{YYYY-MM-DD}.md`

Where `{PROJECT_SLUG}` is the TarkaFlow project slug (e.g., TFLO, AOS, PLAT, INFRA).

#### Step 4.2: Report Template

```markdown
# Deep Review Report

**Repository**: {repo_name}
**TarkaFlow Project**: {project_name} ({project_id})
**Review Date**: {date}
**Reviewed By**: Enterprise Architect Agent (ea@tarka.internal)

## Executive Summary

Brief overview of findings:
- Total guardrails analyzed: X
- Guardrail violations found: Y (critical: A, major: B, minor: C)
- Requirements coverage: X%
- Acceptance criteria met: Y/Z
- Work items verified: X/Y

## Guardrail Compliance

### Violations by Category

#### Security Violations
| ID | Guardrail | Location | Severity | Description |
|----|-----------|----------|----------|-------------|

#### Architecture Violations
| ID | Guardrail | Location | Severity | Description |
|----|-----------|----------|----------|-------------|

#### Business Rule Violations
| ID | Guardrail | Location | Severity | Description |
|----|-----------|----------|----------|-------------|

### Compliant Guardrails
List of guardrails with no violations found.

## Requirements Traceability

### Coverage Summary

| Requirement Type | Total | Implemented | Partial | Missing |
|------------------|-------|-------------|---------|---------|
| Epic             |       |             |         |         |
| Component        |       |             |         |         |
| Feature          |       |             |         |         |
| Requirement      |       |             |         |         |
| IMP              |       |             |         |         |

### Gap Details

#### Missing Implementations
Requirements with no corresponding code found.

#### Partial Implementations
Requirements where some but not all ACs are satisfied.

#### Untested Requirements
Requirements lacking test coverage for acceptance criteria.

## Work Item Analysis

### Completed Work Items
Verification of deployed/completed work items.

### In-Progress Work Items
Current state and blocking issues.

### Technical Debt Items
Assessment of debt items and remediation priority.

## Recommendations

### Critical (Address Immediately)
1. ...

### High Priority (Next Sprint)
1. ...

### Medium Priority (Backlog)
1. ...

### Low Priority (Technical Improvement)
1. ...

## Appendix

### Analyzed Guardrails
Full list of guardrails included in analysis.

### Analyzed Requirements
Full hierarchy of requirements analyzed.

### Work Items Reviewed
Complete list of work items checked.
```

### Phase 5: Finalize

1. **Write Report**: Save the completed report to `/docs/DEEP-REVIEW-{PROJECT_SLUG}-{YYYY-MM-DD}.md`
2. **Summarize**: Provide a brief verbal summary of key findings
3. **Reference TarkaFlow**: Include the audit HRID in the summary for traceability
4. **Recommend Next Steps**:
   - For critical findings: suggest running `action_audit` to create work items
   - For trending issues: reference `get_repeat_violations` output
   - For follow-up: note that findings are queryable via `list_audit_findings`

## Additional Resources

### TarkaFlow Governance Audit Tools

| Tool | Purpose |
|------|---------|
| `create_audit` | Start a new governance audit |
| `record_finding` | Record a single finding |
| `record_findings_batch` | Record multiple findings atomically |
| `complete_audit` | Finalize audit with counts |
| `list_governance_audits` | Query previous audits |
| `list_audit_findings` | Query findings across audits |
| `get_audit_trends` | Monthly violation time series |
| `get_repeat_violations` | Identify recurring issues |
| `action_audit` | Auto-generate work items from findings |

### Reference Files

For detailed guidance on specific analysis areas:
- **`references/guardrail-categories.md`** - Detailed guardrail analysis patterns
- **`references/traceability-patterns.md`** - Requirement traceability techniques

## Usage Examples

**Basic invocation:**
```
/deep-review
```
Then provide the repository path when prompted.

**With specific project:**
```
/deep-review for project TFLO
```

**For current directory:**
```
Run deep review on this codebase
```

## Error Handling

If TarkaFlow resources are not found:
1. Confirm the organization and project exist
2. Check if the repository is registered in TarkaFlow
3. Verify agent permissions for the project

If codebase analysis fails:
1. Ensure the repository root is accessible
2. Check for unusual directory structures
3. Fall back to manual file exploration
