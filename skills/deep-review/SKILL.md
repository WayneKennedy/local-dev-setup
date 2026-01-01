---
name: "deep-review"
description: "This skill should be used when the user asks to 'deep review', 'gap analysis', 'analyze codebase against requirements', 'check compliance', 'review against guardrails', or 'audit code against work items'. Performs comprehensive codebase analysis against TarkaFlow guardrails, requirements, and work items."
---

# Deep Review

Perform a critical analysis of a repository's codebase against all active guardrails and all work items and requirements (open and completed/deployed) from TarkaFlow.

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

1. **List Organizations**: Use `mcp__tflo__list_organizations` to find the relevant org
2. **List Projects**: Use `mcp__tflo__list_projects` with the organization_id
3. **Select Project**: Use `mcp__tflo__select_project` with the matching project_id
4. **Identify Repository**: Use `mcp__tflo__list_repositories` to confirm repo linkage

#### Step 1.3: Gather All Artifacts

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

Document each violation with:
- Guardrail reference (ID and title)
- Specific code location (file:line)
- Nature of violation
- Severity (critical/major/minor)
- Recommended remediation

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

### Phase 3: Gap Analysis Report

#### Step 3.1: Create Report Structure

Create the report at `{repo_root}/docs/DEEP-REVIEW-{PROJECT_SLUG}-{YYYY-MM-DD}.md`

Where `{PROJECT_SLUG}` is the TarkaFlow project slug (e.g., TFLO, AOS, PLAT, INFRA) obtained from the project selected in Step 1.3.

#### Step 3.2: Report Template

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

### Phase 4: Finalize

1. **Write Report**: Save the completed report to `/docs/DEEP-REVIEW-{PROJECT_SLUG}-{YYYY-MM-DD}.md`
2. **Summarize**: Provide a brief verbal summary of key findings
3. **Recommend Next Steps**: Suggest immediate actions based on critical findings

## Additional Resources

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
