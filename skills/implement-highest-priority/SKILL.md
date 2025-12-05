---
name: "implement-highest-priority"
description: "DEPRECATED: Use find-ready-features and implement-feature instead. This skill has been split for better workflow control."
---

# Skill: Implement Highest Priority (DEPRECATED)

⚠️ **This skill has been deprecated and split into two separate skills for better control:**

## Use Instead

### 1. `/find-ready-features` - Discovery Phase
- Finds features with status `approved` or `in_progress`
- Presents options and helps you select
- Displays full context and child requirements
- Outputs feature ID for implementation

**When to use:**
- Starting a new work session
- Exploring what's ready to work on
- Continuing previous work (finds in_progress features)

### 2. `/implement-feature` - Implementation Phase
- Takes a specific feature ID
- Implements, tests, and deploys
- Updates all statuses to deployed
- Handles full deployment workflow

**When to use:**
- After selecting from find-ready-features
- When you know exactly which feature to implement
- When continuing work on a specific feature

## Migration Guide

**Old workflow:**
```
/implement-highest-priority
```

**New workflow:**
```
/find-ready-features
[review options, select feature]
/implement-feature
```

**Or combined:**
```
User: Find ready features and implement the highest priority one
```
I'll run both skills in sequence.

## Why Split?

**Benefits of separation:**
- **Flexibility**: Can discover without committing to implement
- **Clarity**: Each skill has a focused purpose
- **Continuity**: Can continue in_progress features across sessions
- **Control**: User confirms before implementation starts

## Features of New Skills

**find-ready-features:**
- ✅ Checks both `approved` AND `in_progress` status
- ✅ Shows in_progress features first (likely continuing work)
- ✅ Displays child requirement statuses
- ✅ Provides feature ID for next steps
- ✅ Can be run standalone for discovery

**implement-feature:**
- ✅ Assumes feature already selected/known
- ✅ Skips already-deployed child requirements
- ✅ Full MCP tool quality enforcement (RAAS-FEAT-020)
- ✅ Proper state machine transitions
- ✅ Complete deployment workflow

---

**Action Required:** Please use `/find-ready-features` and `/implement-feature` instead of this deprecated skill.
