---
name: demiurge
description: >
  All-in-one skill for building, auditing, critiquing, and hardening code.
  Combines senior-dev laziness, token-efficient output, human-like writing,
  frontend design critique, Material Design 3, and strict coding standards
  into one unified workflow.
version: 2.5.0
---

# Demiurge for Gemini

This is the Google Gemini adapter. It reads the root `SKILL.md` as the canonical source.

## Setup

1. Skill loads from root `SKILL.md` and `references/` directory.
2. No scripts required -- all references are markdown files.

## Usage

```
/demiurge [mode] [target]
```

All modes, rules, and references are defined in the root `SKILL.md`. This file exists only to register the skill with Gemini's skill system.

## Agent-Specific Behavior

- Gemini reads skills from `.gemini/skills/` directory.
- The root `SKILL.md` is the single source of truth.
- All reference paths are relative to the project root.
