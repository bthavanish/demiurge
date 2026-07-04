---
name: demiurge
description: >
  All-in-one skill for building, auditing, critiquing, and hardening code.
  Combines senior-dev laziness, token-efficient output, human-like writing,
  frontend design critique, Material Design 3, and strict coding standards
  into one unified workflow.
version: 2.5.0
---

# Demiurge for Claude Code

This is the Claude Code adapter. It reads the root `SKILL.md` as the canonical source.

## Setup

1. Skill loads from root `SKILL.md` and `references/` directory.
2. No scripts required -- all references are markdown files.

## Usage

```
/demiurge [mode] [target]
```

All modes, rules, and references are defined in the root `SKILL.md`. This file exists only to register the skill with Claude Code's plugin system.

## Agent-Specific Behavior

- Claude Code uses `PostToolUse` hooks for auto-detection.
- The root `SKILL.md` is the single source of truth.
- All reference paths are relative to the project root.
