---
name: demiurge
description: >
  All-in-one skill for building, auditing, critiquing, and hardening code.
  Combines senior-dev laziness, token-efficient output, human-like writing,
  frontend design critique, Material Design 3, and strict coding standards
  into one unified workflow.
version: 2.5.0
user-invocable: true
argument-hint: "[mode] [target]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
  - AskUserQuestion
---

# Demiurge for OpenCode

This is the OpenCode adapter. It reads the root `SKILL.md` as the canonical source.

## Setup

1. Skill loads from root `SKILL.md` and `references/` directory.
2. No scripts required -- all references are markdown files.

## Usage

```
/demiurge [mode] [target]
```

All modes, rules, and references are defined in the root `SKILL.md`. This file exists only to register the skill with OpenCode's skill system.

## Agent-Specific Behavior

- OpenCode reads skills from `.opencode/skills/` directory.
- The root `SKILL.md` is the single source of truth.
- All reference paths are relative to the project root.
