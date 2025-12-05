---
name: "implement-feature"
description: "Implement a specific feature from RaaS requirements system. Handles implementation, testing, deployment, and status updates with quality standards enforcement."
---

# Skill: Implement Feature

Implement a specific feature from the RaaS requirements system. This skill assumes you already know which feature to implement (either from find-ready-features skill or from conversation context).

## Usage

This skill expects the feature ID to be provided in conversation context. You can invoke it by:

1. Using find-ready-features first, then invoking this skill
2. Directly saying "implement feature RAAS-FEAT-XXX"
3. Providing the feature UUID

## What This Skill Does

1. **Load Feature Context** (if not already loaded)
   - Fetches complete feature details with full content
   - Fetches all child requirements recursively
   - Displays the feature hierarchy for confirmation

2. **Assess Clarity**
   - Reviews feature and child requirements for completeness
   - Checks if all requirements are properly specified
   - Identifies ambiguities or missing information
   - Asks user for clarification if needed

3. **Verify MCP Tool Quality** (if applicable)
   - Checks if feature involves MCP tools
   - Verifies tool descriptions meet RAAS-FEAT-020 standard
   - Ensures comprehensive documentation

4. **Implement**
   - Creates todo list tracking all child requirements
   - Implements each requirement systematically
   - Follows proper coding practices and existing patterns
   - Ensures no over-engineering or unnecessary features

5. **Test**
   - Runs relevant test suites
   - Performs manual validation if needed
   - Verifies implementation meets acceptance criteria

6. **Deploy & Update Status**
   - Commits changes with proper commit message
   - Pushes to repository (triggers automatic deployment)
   - Waits for deployment to complete
   - Transitions feature through proper status flow to `deployed`
   - Transitions all child requirements to `deployed`

## Instructions

You are implementing a specific feature from the RaaS requirements system.

### Step 0: Set Your Persona

Before starting any implementation work, set your persona using the MCP tool:

```
Use MCP tool: select_persona(persona='developer')
```

This establishes your session persona for status transitions. The developer persona authorizes:
- `draft` → `review` (submitting for review)
- `in_progress` → `implemented` (marking implementation complete)

**Note**: Other transitions require different personas (see Step 9 for details).

### Step 1: Identify Feature to Implement

Check the conversation for the feature to implement:

- Look for feature ID mentioned by user (RAAS-FEAT-XXX or UUID)
- Check if find-ready-features was just run
- If no feature specified, ask user which feature to implement

```bash
# If user provided human-readable ID like RAAS-FEAT-020
bash .claude/raas-curl.sh "/requirements/?human_readable_id=RAAS-FEAT-020" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data['items'][0]['id'] if data['items'] else 'Not found')"

# If user provided UUID directly
FEATURE_ID="<uuid>"
```

### Step 2: Load Full Feature Context

Fetch the complete feature with full content:

```bash
FEATURE_ID="<id from step 0>"
bash .claude/raas-curl.sh "/requirements/$FEATURE_ID" | python3 -m json.tool
```

Fetch all child requirements with full details:

```bash
bash .claude/raas-curl.sh "/requirements/$FEATURE_ID/children" > /tmp/children.json

# Fetch full content for each child
python3 << 'EOF'
import json
import subprocess

with open('/tmp/children.json') as f:
    children = json.load(f)

all_children = []
for child in children:
    result = subprocess.run(
        ['bash', '.claude/raas-curl.sh', f'/requirements/{child["id"]}'],
        capture_output=True,
        text=True
    )
    all_children.append(json.loads(result.stdout))

# Save for later use
with open('/tmp/children_full.json', 'w') as f:
    json.dump(all_children, f, indent=2)

# Display
for child in all_children:
    print(f"\n{child['human_readable_id']}: {child['title']}")
    print(f"Status: {child['status']}")
    print(f"Description: {child.get('description', 'N/A')[:200]}...")
EOF
```

### Step 3: Display Context to User

Present the feature hierarchy clearly for confirmation:

```
Implementing Feature:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RAAS-FEAT-XXX: <title> (Status: <status>)

Description:
<feature description>

Child Requirements (X):
  1. RAAS-REQ-YYY: <title> (Status: <status>)
  2. RAAS-REQ-ZZZ: <title> (Status: <status>)
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Read through all requirement content carefully.

### Step 4: Assess Clarity

Analyze the requirements:

- Are all child requirements clearly specified?
- Are acceptance criteria well-defined?
- Are there any ambiguities or missing details?
- Are there any dependencies or prerequisites not mentioned?
- Do you understand what needs to be implemented?

**IMPORTANT**: If anything is unclear or underspecified:
1. Use the AskUserQuestion tool to clarify
2. List specific questions about ambiguous requirements
3. Do NOT proceed with implementation until clarity is achieved

If everything is clear, inform the user you're ready to proceed.

### Step 5: MCP Tool Quality Check (If Applicable)

**IMPORTANT**: If this feature involves creating or modifying MCP tools, you MUST verify the tool descriptions meet the quality standard defined in RAAS-FEAT-020.

Fetch the quality standard:

```bash
bash .claude/raas-curl.sh "/requirements/5f617868-58cf-4a49-a938-a11c57762486"
```

Check that each MCP tool description includes:

- [ ] **Common Patterns** section showing typical usage sequences with arrows (→)
- [ ] **Related Tools** references to tools that work together
- [ ] **Returns** section clarifying what's included vs. excluded
- [ ] **Required Workflow** with numbered steps (if applicable)
- [ ] **Errors** section documenting common error scenarios
- [ ] **When to Use** or **Why Use This** section (for complex tools)
- [ ] State machine constraints documented (if applicable)
- [ ] Deprecated parameters with clear migration guidance (if applicable)

Compare your planned MCP tool descriptions against existing high-quality examples:
- `get_requirement_template` (raas-core/src/raas_mcp/server.py)
- `create_requirement`
- `update_requirement`
- `transition_status`

If your tool descriptions don't meet this standard, enhance them BEFORE implementing.

### Step 6: Create Implementation Plan

Use the TodoWrite tool to create a structured task list:

```json
[
  {"content": "Review feature and child requirements", "status": "completed", "activeForm": "Reviewing requirements"},
  {"content": "Implement RAAS-REQ-XXX: <description>", "status": "pending", "activeForm": "Implementing RAAS-REQ-XXX"},
  {"content": "Implement RAAS-REQ-YYY: <description>", "status": "pending", "activeForm": "Implementing RAAS-REQ-YYY"},
  {"content": "Test implementation", "status": "pending", "activeForm": "Testing implementation"},
  {"content": "Commit and deploy changes", "status": "pending", "activeForm": "Committing and deploying"},
  {"content": "Update requirements to deployed status", "status": "pending", "activeForm": "Updating requirement statuses"}
]
```

**Important**: Only create todos for requirements that aren't already deployed. Filter the children:

```bash
python3 << 'EOF'
import json

with open('/tmp/children_full.json') as f:
    children = json.load(f)

pending = [c for c in children if c['status'] != 'deployed']
completed = [c for c in children if c['status'] == 'deployed']

print(f"Already deployed: {len(completed)}")
print(f"Need to implement: {len(pending)}")
print("\nPending requirements:")
for req in pending:
    print(f"  - {req['human_readable_id']}: {req['title']} (Status: {req['status']})")
EOF
```

### Step 7: Implement Each Requirement

For each child requirement that's not already deployed:

1. Mark it as `in_progress` in the todo list
2. Read the full requirement specification carefully
3. Identify which files need to be modified or created
4. Implement the requirement following:
   - Existing code patterns and conventions
   - Proper error handling
   - Security best practices (no SQL injection, XSS, etc.)
   - Avoid over-engineering (only implement what's specified)
   - Don't add extra features or "improvements" not in the spec
5. Mark it as `completed` in the todo list when done

**Critical Rules**:
- NEVER create files unless absolutely necessary
- ALWAYS prefer editing existing files
- NEVER add features beyond what's specified
- ONLY add error handling for actual error conditions
- Don't add documentation files unless explicitly required
- Follow the principle of minimum necessary complexity

### Step 8: Test the Implementation

Based on the feature requirements:

1. Identify what testing is appropriate:
   - Unit tests if test files exist and are mentioned
   - Integration tests if applicable
   - Manual API testing for API endpoints
   - End-to-end testing if UI changes

2. Run the tests:
   ```bash
   # Example for Python tests
   python3 -m pytest tests/

   # Example for manual API testing
   bash .claude/raas-curl.sh "/endpoint" | python3 -m json.tool
   ```

3. Verify all acceptance criteria from the requirements are met

4. If tests fail, fix the issues and re-test

### Step 9: Commit and Deploy

Create proper commit messages following this format:

```bash
git add <modified files>
git commit -m "feat: <concise description of feature>

Implements <FEATURE-ID>: <feature title>

Changes:
- <bullet point list of changes>
- ...

Implements:
- <REQ-ID>: <requirement title>
- <REQ-ID>: <requirement title>
- ...

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push
```

**For submodule changes** (raas-core):
1. Commit and push changes in the submodule first
2. Then commit the submodule update in the main repository
3. Then push the main repository

Watch the deployment:

```bash
gh run list --limit 1
gh run watch
```

### Step 10: Update Requirements Status

Transition the feature and all child requirements to `deployed` status using MCP tools with proper persona authorization.

**Persona Authorization**: Different transitions require different personas. Use the `transition_status` MCP tool with the appropriate persona for each step:

| Transition | Persona Required |
|------------|------------------|
| `draft` → `review` | `developer` |
| `review` → `approved` | `product_owner` |
| `approved` → `in_progress` | `developer` |
| `in_progress` → `implemented` | `developer` |
| `implemented` → `validated` | `tester` |
| `validated` → `deployed` | `release_manager` |

**REQUIRED: Set Persona Before Transitions**

You MUST call `select_persona()` before any status transitions. Without a persona, all transitions fail.

```
# Set developer persona for implementation-related transitions
Use MCP tool: select_persona(persona='developer')

# For each requirement, transition through the workflow:
# 1. Developer transitions: draft → review, approved → in_progress → implemented
Use MCP tool: transition_status(requirement_id='RAAS-REQ-XXX', new_status='review')

# 2. Product owner approves
Use MCP tool: select_persona(persona='product_owner')
Use MCP tool: transition_status(requirement_id='RAAS-REQ-XXX', new_status='approved')

# 3. Developer starts and completes work
Use MCP tool: select_persona(persona='developer')
Use MCP tool: transition_status(requirement_id='RAAS-REQ-XXX', new_status='in_progress')
Use MCP tool: transition_status(requirement_id='RAAS-REQ-XXX', new_status='implemented')

# 4. Tester validates
Use MCP tool: select_persona(persona='tester')
Use MCP tool: transition_status(requirement_id='RAAS-REQ-XXX', new_status='validated')

# 5. Release manager deploys
Use MCP tool: select_persona(persona='release_manager')
Use MCP tool: transition_status(requirement_id='RAAS-REQ-XXX', new_status='deployed')
```

**Transition Order**:
1. First, transition all child requirements to `deployed`
2. Then, transition the parent feature to `deployed`

**Managing Your Persona**:
```
Use MCP tool: get_persona()    # Check current session persona
Use MCP tool: clear_persona()  # Clear when done (WARNING: blocks all transitions)
```

### Step 11: Verify and Report

1. Verify the feature status in RaaS:
   ```bash
   bash .claude/raas-curl.sh "/requirements/$FEATURE_ID" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'{d[\"human_readable_id\"]}: {d[\"title\"]} → {d[\"status\"]}')"
   ```

2. Verify child statuses:
   ```bash
   bash .claude/raas-curl.sh "/requirements/$FEATURE_ID/children" | python3 -c "import sys, json; [print(f'{c[\"human_readable_id\"]}: {c[\"status\"]}') for c in json.load(sys.stdin)]"
   ```

3. Report completion to the user:
   ```
   ✅ Successfully implemented and deployed <FEAT-ID>: <title>

   Completed requirements:
   - <REQ-ID>: <title> → deployed
   - <REQ-ID>: <title> → deployed

   Deployment: <github actions run url>
   Feature status: deployed
   ```

## Important Notes

- **Always verify clarity before implementing** - unclear specs lead to wrong implementations
- **MCP tool quality is mandatory** - all MCP tool descriptions MUST meet RAAS-FEAT-020 standards
- **Follow state machine rules** - cannot skip states when updating requirements
- **Test thoroughly** - deployed code must work correctly
- **Minimal changes** - only implement what's specified, no extras
- **Security first** - watch for vulnerabilities in every change
- **Update todos frequently** - keep user informed of progress
- **Skip deployed children** - don't re-implement requirements already marked deployed

## Error Handling

1. **Feature not found**: Verify the feature ID and check if it exists
2. **Unclear specifications**: Ask user for clarification before proceeding
3. **Test failures**: Fix issues, don't proceed to deployment
4. **Deployment failures**: Check logs, fix issues, retry
5. **Status update failures**: Check state machine rules, transition properly

## Example Usage

```
User: implement feature RAAS-FEAT-020
```

The skill will:
1. Load RAAS-FEAT-020 and all child requirements
2. Display the feature for review
3. Verify MCP tool descriptions meet quality standard (if applicable)
4. Ask if anything is unclear
5. Implement all pending requirements systematically
6. Test the implementation
7. Deploy to production
8. Update all requirement statuses to deployed
9. Report completion

---

This skill handles the complete implementation workflow for a specific feature from requirements to deployed code.
