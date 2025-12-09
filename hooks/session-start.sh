#!/bin/bash
# TarkaFlow SessionStart Hook
# Injects core developer context into every Claude Code session

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
SKILLS_DIR="${SCRIPT_DIR}/../skills"

# Read the core context skill
if [[ -f "${SKILLS_DIR}/tarkaflow-developer-context/SKILL.md" ]]; then
    # Extract just the body (skip YAML frontmatter)
    skill_content=$(awk '/^---$/{n++; next} n==2' "${SKILLS_DIR}/tarkaflow-developer-context/SKILL.md" 2>/dev/null || echo "")
else
    skill_content="WARNING: tarkaflow-developer-context skill not found at ${SKILLS_DIR}"
fi

# Escape for JSON
escape_for_json() {
    local input="$1"
    # Escape backslashes, quotes, and newlines
    printf '%s' "$input" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])' 2>/dev/null || \
    printf '%s' "$input" | sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/g' | tr -d '\n'
}

skill_escaped=$(escape_for_json "$skill_content")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<TARKAFLOW_DEVELOPER_CONTEXT>\n${skill_escaped}\n</TARKAFLOW_DEVELOPER_CONTEXT>\n\n<IMPORTANT>\nYou are operating in a TarkaFlow-governed environment.\n\n1. Select your agent FIRST: select_agent(agent_email='code@tarka.internal')\n2. ALL implementation requires an approved CR\n3. Write tests BEFORE implementation (TDD)\n4. Create imp/ldm/interface artifacts BEFORE marking implemented\n\nUse the Skill tool to load phase-specific skills as needed:\n- picking-up-work\n- test-readiness\n- implementation\n- completing-work\n</IMPORTANT>"
  }
}
EOF
