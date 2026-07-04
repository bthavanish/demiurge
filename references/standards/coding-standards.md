# Coding Standards

Based on Wikipedia's "Coding Best Practices" and system instructions for code generation. These rules apply to ALL modes.

## Prerequisites

- **Understand before coding.** Read the task and the code it touches. Trace the real flow end to end. Never start coding without comprehension.
- **Know the requirements.** Establish what the code must do (functional) and how well it must do it (non-functional: performance, security, maintainability).
- **Respect the architecture.** Do not invent new schemas, state management paradigms, or rules that conflict with the existing environment.

## Simplicity (KISS)

- Do not over-engineer. Choose the most readable, straightforward solution.
- Avoid unnecessary abstractions or complex design patterns for trivial problems.
- Follow Single Responsibility Principle: every function, class, module does exactly one thing.
- Break large tasks into small, highly cohesive, loosely coupled helper functions.
- Three similar lines is better than a premature `createHelper()`.

## Naming Conventions

- Use strictly descriptive, self-explanatory names for all variables, functions, and classes.
- Never use single-letter variables (except loop counters `i`, `j`, `k` in pure math or standard loops).
- Never use arbitrary names (`data2`, `temp`, `flag`, `result`, `handler`).
- Maintain 100% consistency with the naming conventions of the existing codebase.
- Names should reveal intent. A name should answer: what does it hold? what does it do?

## Constants and Immutability

- Eliminate all magic numbers and hard-coded literals. Declare named constants.
- Example: `const MAX_RETRIES = 3` instead of bare `3` in a loop.
- Default to immutability. Make variables, parameters, and classes final/const wherever practical.
- If a value never changes, make it a constant. If a reference never reassigns, make it const.

## Comments and Documentation

- Code must be self-documenting through clear naming and structure.
- Only comment the **why** (business logic, edge cases, reasons for a specific approach).
- Never comment the **what** (do not explain standard language syntax or basic operations).
- See `references/comment-standards.md` for the full comment guidelines.

## Portability

- Never hard-code environmental parameters (URLs, absolute file paths, IP addresses, credentials).
- Assume these will be passed via configuration or environment variables.
- Parametrize values outside the code (properties, config files, env vars).

## No Hallucinations

- Only use standard language features or explicitly provided libraries/dependencies.
- Do not invent deprecated, non-existent, or hypothetical functions.
- If required information is missing to write a robust function, stop and ask for clarification. Do not guess.
- Before using a library, check that the codebase already uses it. Do not assume availability.

## Error Handling

- Never swallow exceptions silently. At minimum, log the error.
- Handle errors at the appropriate boundary: user-facing errors explain what happened, developer errors include technical cause.
- Use typed error returns or exceptions consistently. Do not mix paradigms without reason.
- Clean up resources in error paths (use finally, defer, try-with-resources, or equivalent).
- Every retry has a max. Every queue has a size limit. Every poll has a timeout.

## Immutability and Data

- Prefer immutable data structures. Pass values, not references to mutable shared state.
- Validate at system edges. Internal functions trust callers.
- Do not encode uncertainty as adapters, defaults, optionals, or catches. Resolve it into contracts.

## Testing

- Plan test cases before and during coding, not just at the end.
- Assert on observable outcomes, not mock call counts.
- Default to durable tests attached to real product boundaries.
- Mock external systems you do not control. Do not mock your own modules.
- One runnable check for non-trivial logic. No frameworks required for simple cases.

## Dead Code

- If something is replaced, remove it in the same change.
- No commented-out code blocks. If code is no longer needed, delete it entirely.
- No backwards-compatibility shims for internal code. Update all callers.
- Clean up dead imports, unused variables, and outdated comments when editing.

## Build and Test

- Implement continuous integration or daily builds.
- Plan deployment strategy: automate, rollback-ready, no on-the-fly script changes.
- Use multi-stage processes to recreate real environments for testing.
