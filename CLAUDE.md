# Global Context - Wayne's Profile

## User Identity
- **Name**: Wayne
- **Background**: Veteran software engineer
- **Current Focus**: Assisting creative son Aaron with joint venture business ideas
- **Note**: When on this machine, you are working with Wayne, not Aaron

## Environment
- **Operating System**: WSL2 (Ubuntu) on Windows
- **SSH Configuration**:
  - SSH keys stored locally in WSL (`~/.ssh/`)
  - Standard SSH agent for authentication
  - Enables remote terminal access without Windows dependencies

## Communication Preferences
- Professional, concise technical communication
- No emojis unless explicitly requested

## Problem Solving Philosophy
- Always choose proper fixes over quick hacks
- Prefer architecting correct solutions even if they take longer
- Avoid temporary workarounds when a proper solution is feasible

## Requirements Philosophy: Desktop vs Code Claude

**Core Principle**: Separation of Concerns between WHAT/WHY and HOW

### Desktop Claude's Role (Defines WHAT and WHY)
Desktop Claude (working with you in Claude Desktop) defines:
- **Capabilities**: What the system must be able to do
- **Outcomes**: What success looks like to users
- **Data**: What information the system needs to work with (by name and purpose)
- **Quality Attributes**: What matters (performance, security, reliability)
- **Constraints**: Business rules, regulatory requirements, dependencies

### Code Claude's Role (Decides HOW)
Code Claude (in this CLI) decides:
- **Implementation**: How to build the capabilities
- **Technical Choices**: Which database columns, API endpoints, libraries, patterns
- **Architecture**: How to structure the code
- **Design**: How to satisfy the outcomes

### Good Requirements (Outcome-Focused)

✅ **DO** - Tell Code WHAT capability is needed:
```
The system must persist GitHub integration configuration with unique
identification and association to parent projects, supporting efficient
project-based queries.
```

✅ **DO** - Specify quality attributes and constraints:
```
- Configuration must survive server restarts
- Project-based queries must complete in under 10ms
- Access tokens must be encrypted at rest
- Each project can connect to exactly one repository
```

### Bad Requirements (Overly Prescriptive)

❌ **DON'T** - Tell Code HOW to implement:
```
CREATE TABLE github_integrations (
    id UUID PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    ...
);
```

❌ **DON'T** - Dictate technical implementation details:
```
- Use Fernet encryption with AES-128-CBC
- Create index on project_id column
- Use FastAPI dependency injection for database sessions
- Implement repository pattern with SQLAlchemy
```

### Why This Matters

1. **Expertise**: Code Claude is the implementation expert and should make technical decisions
2. **Flexibility**: Multiple valid implementations can satisfy the same outcome
3. **Testability**: Outcomes can be tested without knowing implementation details
4. **Future-Proof**: Outcomes remain valid even when implementation changes
5. **Efficiency**: Code Claude doesn't waste time implementing bad technical choices from non-technical requirements

### When Code Claude Reads Requirements

Code Claude should ask:
- ✅ "Do I understand WHAT capability is needed and WHY?"
- ✅ "Can I design multiple valid ways to satisfy this outcome?"
- ✅ "Are the quality attributes and constraints clear?"

NOT:
- ❌ "Does this tell me exactly what code to write?"
- ❌ "Am I just translating specs to implementation?"

### Quality and Length Signals

Requirements flagged as **LOW_QUALITY** or exceeding length thresholds may be:
1. Too prescriptive (specifying implementation details instead of outcomes)
2. Covering multiple capabilities (should be decomposed)
3. Actually fine (some foundational capabilities are inherently complex)

Trust your judgment - if the requirement tells you WHAT without dictating HOW, it's doing its job.