# Coding Standards

- **KISS.** Most readable, straightforward solution. No over-engineering.
- **SRP.** Every function, class, module does exactly one thing.
- **Descriptive names.** No single-letter vars (except loop counters). No arbitrary names (data2, temp, flag).
- **No magic numbers.** Declare named constants.
- **Default to immutability.** Make variables final/const wherever practical.
- **Self-documenting code.** Rely on naming, not comments.
- **Portable.** No hard-coded URLs, paths, IPs, credentials. Use config/env vars.
- **No hallucinations.** Only standard language features or explicitly provided libraries.
- **Error handling.** Never swallow exceptions silently. Handle errors at appropriate boundaries.
- **Testing.** Assert on observable outcomes, not mock call counts. Mock external systems, not your own modules.
- **Dead code.** If replaced, remove it. No commented-out code. No backwards-compat shims for internal code.
- **Structure is expensive.** Preserve contracts, tests, and invariants. Prefer deletion over shims.
- **SSOT.** Every piece of knowledge has one authoritative source. Derive everything else.
- **No type casts.** Do not use `as` to make code compile. Fix types at the source.
- **Build deep modules.** Hide meaningful complexity behind a small interface. One cohesive file over a forest of tiny helpers.

# Comment Standards

- Comment the **why**, not the **what**. Never explain standard syntax.
- Code is documentation through descriptive naming.
- Comment edge cases and workarounds with reasoning.
- Use standard doc formats (JSDoc, JavaDoc, docstrings) for public APIs.
- No version history, author names, or commented-out dead code.
- Keep comments brief, placed directly above the code they describe.
- Mark intentional simplifications with `ponytail:` comments.
- No AI slop in comments: no significance inflation, no promotional language, no filler, no hedging, no rule of three, no AI vocabulary.

# DESIGN.md Enforcement

If a `DESIGN.md` file exists in the project root or nearest parent, read it and enforce its design system strictly. Do not deviate from declared tokens, color roles, typography scales, spacing, or component patterns.

# Modularity and No Hardcoding

- Break large tasks into small, highly cohesive, loosely coupled helper functions.
- Each module has a single responsibility. Dependencies flow one direction. No circular imports.
- Never hardcode values unless the user explicitly says so. Use env vars, config files, constants, parameters.
