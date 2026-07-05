# Compress Mode

Compresses natural language files into terse format to save input tokens. Compressed version overwrites original. Backup saved as `FILE.original.md`.

## Trigger

`/demiurge compress <filepath>` or when user asks to compress a memory file.

## Process

1. Read the file.
2. Detect file type. Only compress natural language files (.md, .txt, .typ, .tex, extensionless).
3. Never modify: .py, .js, .ts, .json, .yaml, .yml, .toml, .env, .lock, .css, .html, .xml, .sql, .sh.
4. If file has mixed content (prose + code), compress ONLY the prose sections.
5. Back up original as `FILE.original.md`.
6. Write compressed version.

## Compression Rules

### Remove
- Articles: a, an, the
- Filler: just, really, basically, actually, simply, essentially, generally
- Pleasantries: "sure", "certainly", "of course", "happy to", "I'd recommend"
- Hedging: "it might be worth", "you could consider", "it would be good to"
- Redundant phrasing: "in order to" -> "to", "make sure to" -> "ensure", "the reason is because" -> "because"
- Connective fluff: "however", "furthermore", "additionally", "in addition"

### Preserve EXACTLY (never modify)
- Code blocks (fenced ``` and indented)
- Inline code (backtick content)
- URLs and links
- File paths
- Commands (npm install, git commit, docker build)
- Technical terms, library names, API names, protocols
- Proper nouns, dates, version numbers, numeric values
- Environment variables ($HOME, NODE_ENV)

### Preserve Structure
- All markdown headings (keep exact heading text, compress body below)
- Bullet point hierarchy (keep nesting level)
- Numbered lists (keep numbering)
- Tables (compress cell text, keep structure)
- Frontmatter/YAML headers

### Compress
- Short synonyms: "big" not "extensive", "fix" not "implement a solution for"
- Fragments OK: "Run tests before commit" not "You should always run tests before committing"
- Drop "you should", "make sure to", "remember to" -- just state the action
- Merge redundant bullets that say the same thing differently
- Keep one example where multiple examples show the same pattern

**CRITICAL:** Anything inside ``` must be copied EXACTLY. Do not remove comments, spacing, reorder lines, or simplify code.

## Example

**Original:**
> You should always make sure to run the test suite before pushing any changes to the main branch. This is important because it helps catch bugs early and prevents broken builds from being deployed to production.

**Compressed:**
> Run tests before push to main. Catch bugs early, prevent broken prod deploys.
