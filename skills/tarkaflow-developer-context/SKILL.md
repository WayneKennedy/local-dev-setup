---
name: tarkaflow-developer-context
description: >
  Core context for TarkaFlow-governed development. Always relevant when working
  on code in repositories managed by TarkaFlow requirements. Provides MCP tool
  awareness, agent identity model, CR/Release workflow, and requirement hierarchy.
  Essential foundation for all development phases.
---

# TarkaFlow Developer Context

You are working in a TarkaFlow-governed development environment. All implementation
work is driven by requirements and governed by Change Requests (CRs) and Releases.

## First Action: Select Your Agent

Before any TarkaFlow operations, select your agent identity:

```
select_agent(agent_email='code@tarka.internal')
```

**Agent identities and permissions:**
- `code@tarka.internal` - Claude Code agent, can implement, transition to `review`, cannot approve
- `tester@tarka.internal` - Can validate, transition to `validated`
- `ea@tarka.internal` - Enterprise Architect, full permissions (Desktop only)

You are `code@tarka.internal`. Do not attempt to use other identities.

## The Development Model

### Nothing Without a CR

All implementation work requires an **approved Change Request (CR)**. Before writing
any code:

1. Verify a CR exists for the work
2. Check the CR is in `approved` status
3. Review all affected requirements listed in the CR

If no CR exists, stop and inform the user.

### Requirements Drive Implementation

Requirements define WHAT and WHY. You determine HOW.

**Hierarchy:**
```
Epic (strategic outcome)
  └── Component (bounded context)
        └── Feature (capability)
              └── Requirement (specific behaviour)
                    └── Imp (implementation notes - you create these)
```

**Catalogue types (no parent, project-scoped):**
- `LDM` - Logical Data Model definitions
- `Interface` - API and integration specifications

### Acceptance Criteria Are Your Contract

Every requirement has Acceptance Criteria (ACs). These are testable conditions that
define "done". Before implementing:

1. Read all ACs for affected requirements
2. Ensure each AC is testable
3. Write tests that verify each AC
4. Only then write implementation code

### Semantic Tags

Requirements use semantic tags to express relationships:

- `uses:HRID` - This requirement uses/consumes another artifact
- `owns:HRID` - This requirement owns/manages another artifact  
- `extends:HRID` - This requirement extends another concept
- `depends:HRID` - Blocking dependency
- `requires:{type}:{slug}` - Gap marker for undefined artifacts

When completing work, add appropriate tags to requirements.

## Work Item Lifecycle

```
CR created → approved → in_progress → implemented → validated → deployed → completed
```

**Your transitions as developer:**
- `approved` → `in_progress` (starting work)
- `in_progress` → `implemented` (code complete, tests pass)

**You cannot:**
- Transition to `validated` (requires tester agent)
- Transition to `deployed` (requires approved Release)
- Transition to `completed` (happens via Release)

## Before Marking Implemented

You MUST complete these before transitioning to `implemented`:

1. **Implementation notes (`imp`)** - Document key decisions, patterns, deviations
2. **LDM updates** - If data model changed, update or create LDM entries
3. **Interface updates** - If APIs changed, update or create Interface entries
4. **Semantic tags** - Add `uses:`, `owns:` tags to affected requirements
5. **All tests pass** - Green test suite
6. **Implementation refs** - Update CR with PR URL, commit SHAs

## Key MCP Tools

**Work Items:**
- `get_work_item(work_item_id)` - Fetch CR details
- `transition_work_item(work_item_id, new_status)` - Move through lifecycle
- `update_work_item(work_item_id, implementation_refs={...})` - Add PR/commit refs

**Requirements:**
- `get_requirement(requirement_id)` - Fetch full content including ACs
- `list_requirements(project_id, type, status)` - Query requirements
- `list_acceptance_criteria(requirement_id)` - Get ACs for a requirement
- `update_acceptance_criteria(ac_id, met=true/false)` - Mark AC status

**Creating artifacts:**
- `get_requirement_template(type)` - Get template for imp/ldm/interface
- `create_requirement(content, type, project_id)` - Create new artifact

## TDD Flow

1. **Red** - Write tests for ACs, verify they fail
2. **Green** - Write minimum code to pass tests
3. **Refactor** - Clean up while keeping tests green
4. Repeat for each AC

Do not write implementation code before you have a failing test.
