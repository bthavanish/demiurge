# Management Reference

Compress natural language files, harvest ponytail debt markers, human commit style.

---

## Compress

Compresses natural language files (.md, .txt, .typ, .tex) into terse format to save input tokens. Backup saved as `FILE.original.md`.

### Process

1. Read file. Detect type. Only compress natural language files.
2. Never modify: .py, .js, .ts, .json, .yaml, .toml, .css, .html, .xml, .sql, .sh.
3. If mixed content (prose + code), compress ONLY prose sections.
4. Back up original. Write compressed version.

### Rules

**Remove:** articles (a/an/the), filler (just/really/basically), pleasantries, hedging, redundant phrasing, connective fluff.

**Preserve EXACTLY:** code blocks, inline code, URLs, file paths, commands, technical terms, proper nouns, env vars.

**Preserve Structure:** markdown headings, bullet hierarchy, numbered lists, tables, frontmatter.

**Compress:** short synonyms, fragments OK, drop "you should"/"make sure to", merge redundant bullets, keep one example per pattern.

**CRITICAL:** Anything inside ``` must be copied EXACTLY. Do not modify code.

---

## Debt

Harvests `ponytail:` comment markers into a tracked debt ledger.

### Scan

```
grep -rnE '(#|//) ?ponytail:' .
```

### Output Format

```
<file>:<line>, <what was simplified>. ceiling: <the limit named>. upgrade: <the trigger to revisit>.
```

Flag `no-trigger` tags for markers without upgrade paths. End with `<N> markers, <M> with no trigger.`

### Boundaries

Reads and reports only. Changes nothing. One-shot.

---

## Human Committing Style

Each commit is a logical unit of work, not a mechanical dump of files.

### Principles

- One logical change per commit.
- Commit in the order a human would build: core first, features second, polish last.
- Never mention parts, batches, or sequencing.
- Use conventional commits format: `type(scope): description`
- No "WIP", no "fix stuff", no "updates".

### Types

| Type | When |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code restructuring, no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Build, tooling, config |
| `ci` | CI/CD changes |
| `revert` | Reverting a previous commit |

### Message Rules

- Subject: imperative mood, lowercase after colon, no period, <=50 chars
- Body: explain *why*, not *what*. Only when subject isn't enough.
- No AI attribution, no emoji in commit messages.
