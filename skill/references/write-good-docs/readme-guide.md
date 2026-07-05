# README Guide

Crafting effective READMEs matched to audience and project type.

## Core Principle

READMEs answer questions your audience will have. Different audiences need different information. **Always ask:** Who will read this, and what do they need to know?

## Process

### Step 1: Identify the Task

| Task | When |
|------|------|
| **Creating** | New project, no README yet |
| **Adding** | Need to document something new |
| **Updating** | Capabilities changed, content is stale |
| **Reviewing** | Checking if README is still accurate |

### Step 2: Task-Specific Questions

**Creating:** What type of project? What problem does it solve in one sentence? Quickest path to "it works"?

**Adding:** What needs documenting? Where in the existing structure? Who needs this info most?

**Updating:** What changed? Read current, identify stale sections. Propose specific edits.

**Reviewing:** Read current README. Check against actual project state. Flag outdated. Update "Last reviewed" date.

### Step 3: After Drafting

Ask: **"Anything else to highlight or include that I might have missed?"**

## Project Types

| Type | Audience | Key Sections | Template |
|------|----------|--------------|----------|
| **Open Source** | Contributors, users worldwide | Install, Usage, Contributing, License | oss.md |
| **Personal** | Future you, portfolio | What it does, Tech stack, Learnings | personal.md |
| **Internal** | Teammates, new hires | Setup, Architecture, Runbooks | internal.md |
| **Config** | Future you (confused) | What's here, Why, How to extend, Gotchas | xdg-config.md |

## Section Checklist

| Section | OSS | Personal | Internal | Config |
|---------|-----|----------|----------|--------|
| Name/Description | Yes | Yes | Yes | Yes |
| Badges | Yes | Optional | No | No |
| Installation | Yes | Yes | Yes | No |
| Usage/Examples | Yes | Yes | Yes | Brief |
| What's Here | No | No | No | Yes |
| How to Extend | No | No | Optional | Yes |
| Contributing | Yes | Optional | Yes | No |
| License | Yes | Optional | No | No |
| Architecture | Optional | No | Yes | No |
| Gotchas/Notes | Optional | Optional | Yes | Yes |
| Last Reviewed | No | No | Optional | Yes |

## Style Guide

### Common Mistakes
- **No install steps** -- Never assume setup is obvious
- **No examples** -- Show, don't just tell
- **Wall of text** -- Use headers, tables, lists
- **Stale content** -- Add "last reviewed" date
- **Generic tone** -- Write for YOUR audience

### Prose Quality

For general writing advice -- clear prose, Strunk's rules, and AI patterns to avoid -- use the `writing-clearly-and-concisely` skill.

## Essential Sections (All Types)

Every README needs at minimum:
1. **Name** -- Self-explanatory title
2. **Description** -- What + why in 1-2 sentences
3. **Usage** -- How to use it (examples help)

## OSS Template

```markdown
# [Project Name]
[One-line description]

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/[user]/[repo]/ci.yml)](https://github.com/[user]/[repo]/actions)

## About
[2-3 sentences: what problem, why use it, what makes it different.]

## Features
- [Key feature 1]
- [Key feature 2]

## Installation
```bash
[package manager install command]
```

### Requirements
- [Runtime requirement, e.g., Node.js >= 18]

## Usage
```[language]
[Minimal working example]
```

### More Examples
[Link to examples directory]

## Contributing
Contributions are welcome! Please see `CONTRIBUTING.md` for guidelines.

### Development Setup
```bash
[Commands to clone and set up for development]
```

### Running Tests
```bash
[test command]
```

## License
[Project name] is licensed under the [License name] license. See `LICENSE` for more.
```

## Internal Template

```markdown
# [Service/Project Name]
[One-line description]

**Team**: [Team name or slack channel]
**On-call**: [Rotation or contact info]

## Overview
[2-3 sentences: what, why, where in architecture.]

### Dependencies
- **Upstream**: [Services this depends on]
- **Downstream**: [Services that depend on this]

## Local Development Setup

### Prerequisites
- [Required tool 1 with version]
- Access to [internal system/VPN]

### Environment Variables
| Variable | Description | Where to get it |
|----------|-------------|-----------------|
| `DATABASE_URL` | [Description] | [1Password/Vault] |

### Running Locally
```bash
[Step-by-step commands]
```

### Running Tests
```bash
[test commands]
```

## Architecture
[Brief description. Link to diagrams if they exist.]

### Key Files
| Path | Purpose |
|------|---------|
| `src/[important-file]` | [What it does] |

## Deployment

### Environments
| Environment | URL | Notes |
|-------------|-----|-------|
| Development | [URL] | [Notes] |
| Staging | [URL] | [Notes] |
| Production | [URL] | [Notes] |

## Runbooks
### [Common Task 1]
```bash
[Commands or steps]
```

## Troubleshooting
### [Common Problem 1]
**Symptom**: [What you see]
**Cause**: [Why it happens]
**Fix**: [How to resolve]

## Related Docs
- [Link to design doc]
- [Link to API docs]
```

## Using References

Templates are your primary tool. References provide depth for edge cases.

- **art-of-readme.md** -- Philosophy behind great READMEs, cognitive funneling, brevity as feature
- **make-a-readme.md** -- Practical section-by-section guidance
- **standard-readme-spec.md** -- Formal specification for consistency/compliance
