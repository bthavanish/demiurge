# Humanize Mode

Audit code for AI-generated patterns and rewrite them to sound human. Based on the humanizer skill's detection of 33 AI writing patterns, applied to code artifacts.

## What This Mode Audits

### Code-Level AI Patterns

1. **Unnecessary abstractions.** Interface with one implementation. Factory for one product. Config for a value that never changes. Adapter wrapping a single adapter. Strategy pattern for two options.
   - Fix: Inline the abstraction. Use a function or a constant.

2. **Boilerplate scaffolding.** "For later" infrastructure that nothing uses. Empty base classes. Generic utility functions with one caller. Abstract factories before there are multiple products.
   - Fix: Delete it. Let later handle later.

3. **Over-documentation.** Comments that explain what the code does line by line. JSDoc on private functions. Docstrings on trivial getters. README sections for self-explanatory code.
   - Fix: Remove what-the-code-does comments. Keep why comments only where the reasoning is non-obvious.

4. **Performative naming.** Variables named for what they represent conceptually rather than what they hold. `userPreferencesManager` for a function that reads one config value. `DataProcessingPipeline` for a map-filter chain.
   - Fix: Name for what it does, not what it means.

5. **Template patterns.** Identical error handling across functions. Copy-pasted validation blocks. Synchronized try-catch structures where each branch does something different.
   - Fix: Extract the common handling into a shared function, or remove the ceremony if the branches are actually different.

6. **Defensive over-engineering.** Try-catch wrapping everything "just in case." Null checks on values that cannot be null by construction. Type guards on values already typed. Validation on internal functions that only receive validated input.
   - Fix: Trust the type system. Validate at boundaries, not everywhere.

7. **Import-everything patterns.** Importing entire libraries when only one function is used. Barrel imports from index files. Re-exporting everything.
   - Fix: Import what you use. No barrel files.

8. **Config proliferation.** Separate config files for values that never change. Environment variable reads for constants. Feature flags for permanent features.
   - Fix: Inline the value. Make it a constant.

9. **Circular type definitions.** Types that reference each other. Generic types that wrap other generic types. Type gymnastics where a simple interface suffices.
   - Fix: Flatten. Use simple, direct types.

10. **Generic utility functions.** Custom implementations of `groupBy`, `sortBy`, `uniqueBy`, `clamp` that add no value over a one-liner or stdlib.
    - Fix: Use stdlib. Write the one-liner.

### Comment-Level AI Patterns

Apply all 33 patterns from the humanizer skill to comments and documentation:
- Significance inflation in comments ("This crucial function...")
- Rule of three in listing features
- AI vocabulary (delve, leverage, utilize, streamline, facilitate)
- Sycophantic tone ("Note that this elegant solution...")
- Filler phrases ("It is important to note that...")
- Hedging ("This might potentially help to...")
- Generic conclusions ("This approach provides a robust foundation...")

### Variable and Function Name Patterns

- Generic suffixes: `Manager`, `Handler`, `Processor`, `Service`, `Factory` when the thing does one job
- Prefix patterns: `doX`, `handleX`, `processX` that add no meaning
- Abstract nouns: `facilitator`, `orchestrator`, `coordinator` for things with one caller
- Hungarian notation in languages that do not need it

## Workflow

1. **Scan code.** Read every source file. Identify instances of the patterns above.

2. **Classify findings.** Group by pattern type. Count instances.

3. **Fix.** Rewrite each instance to sound human. Apply the ponytail ladder: can it be deleted? Simplified? Inlined?

4. **Report.** Output findings and fixes.

## Report Template

```markdown
# Humanize Report

**Date:** [date]
**Files scanned:** [count]

## AI Patterns Found

| Pattern | Instances | Files affected |
|---------|-----------|----------------|
| Unnecessary abstractions | [n] | [files] |
| Boilerplate scaffolding | [n] | [files] |
| Over-documentation | [n] | [files] |
| Performative naming | [n] | [files] |
| Template patterns | [n] | [files] |
| Defensive over-engineering | [n] | [files] |
| Import-everything | [n] | [files] |
| Config proliferation | [n] | [files] |
| Circular types | [n] | [files] |
| Generic utilities | [n] | [files] |
| AI comment patterns | [n] | [files] |
| **Total** | **[n]** | |

## Fixes Applied

| # | File | Pattern | Before | After |
|---|------|---------|--------|-------|
| 1 | path/file:line | [pattern] | [what it was] | [what it is now] |
```

## Rules

- Fix every instance. Do not just report.
- Preserve functionality. The rewrite must behave identically.
- Apply the ponytail ladder to each fix: delete > simplify > inline > refactor.
- No em dashes in comments or documentation.
- Comment the why, not the what.
