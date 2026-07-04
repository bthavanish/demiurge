# Make Mode

Build or modify code based on user instructions. This is the default mode.

## Workflow

1. **Understand the request.** Read the user's instructions fully. Trace every file the change touches. Understand the real flow end to end before writing anything.

2. **Climb the ponytail ladder.** Before writing code:
   - Does this need to exist?
   - Is it already in the codebase?
   - Can stdlib do it?
   - Can the platform do it?
   - Can an installed dependency do it?
   - Can it be one line?
   - Then: minimum code that works.

3. **Read existing code.** Examine the files you will modify. Understand their conventions, patterns, naming, and architecture. Mimic the existing style exactly.

4. **Build.** Write the code following all base rules from SKILL.md.

5. **Verify.** Run lint, typecheck, or test commands if available. Check the code compiles and passes any existing checks.

## Rules

- Fewest files possible. Shortest working diff wins.
- No unrequested abstractions. No interface with one implementation. No factory for one product.
- No boilerplate or scaffolding "for later." Later can scaffold for itself.
- Deletion over addition. Boring over clever.
- Reuse existing patterns, utilities, and components before inventing new ones.
- Respect the existing architecture. Do not invent new database schemas, state management paradigms, or rules that conflict with the given environment.
- If a DESIGN.md exists, follow it strictly for any UI work.

## Output

Code first. Then at most three short lines: what was skipped, when to add it. No essays, no feature tours, no design notes.

Pattern: `[code] -> skipped: [X], add when [Y].`

If the user explicitly asks for explanation, give it in full. The rule is only against unrequested prose.

## When the request is vague

Ask one targeted question, not five. Pick the highest-impact ambiguity. Better: ship the lazy version that covers the common case and name what was skipped.

## Edge cases

- **Multi-file changes:** Only touch what the request requires. Do not "clean up" adjacent code unless asked.
- **New files:** Check if a similar file exists. Reuse its structure.
- **Dependencies:** Never add a new dependency for what a few lines of code or stdlib can do.
- **Configuration:** Use environment variables or config files. Never hardcode.
