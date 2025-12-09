---
description: "Assess whether a Change Request is ready for implementation"
---

# Assess a TarkaFlow CR for Implementation Readiness

Assess whether a Change Request is ready for implementation.

**Usage:** `/tarka-assess <CR-ID>`

**Example:** `/tarka-assess CR-042`

## Steps

1. **Select agent identity**
   ```
   select_agent(agent_email='developer@tarka.internal')
   ```

2. **Fetch the CR**
   ```
   get_work_item(work_item_id='$ARGUMENTS')
   ```

3. **Check CR status**
   - Must be `approved` or `in_progress`
   - If `created`, inform user CR needs approval first

4. **For each affected requirement:**
   
   a. Fetch full requirement content:
   ```
   get_requirement(requirement_id='...')
   ```
   
   b. Fetch acceptance criteria:
   ```
   list_acceptance_criteria(requirement_id='...')
   ```
   
   c. Check for testable ACs (specific, measurable conditions)
   
   d. Check dependencies are code-complete:
   ```
   list_requirements(blocked_by='<requirement_id>')
   ```

5. **Fetch related artifacts:**
   - LDM entries referenced by `uses:` tags
   - Interface specs referenced by `uses:` tags

6. **Produce readiness summary:**

   ```
   ## CR Assessment: <CR-ID>
   
   **Status:** Ready / Blocked / Needs Clarification
   
   ### Affected Requirements
   - <HRID>: <title> - ✅ Ready / ⚠️ Issues
   
   ### Acceptance Criteria
   - Total: X
   - Testable: Y
   - Needing clarification: Z
   
   ### Dependencies
   - Blocking: <list any unmet dependencies>
   
   ### Related Artifacts
   - LDM: <list>
   - Interfaces: <list>
   
   ### Blockers (if any)
   1. <issue description>
   
   ### Ready to Proceed
   Yes / No - <reason>
   ```

## If Blocked

If the CR is not ready, explain what's needed:
- Missing ACs need clarification tasks created
- Dependencies need to be completed first
- CR needs approval

Do not proceed to implementation if blocked.
