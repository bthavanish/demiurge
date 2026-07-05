# Ponytail Ladder

Before writing any code, climb the ladder. Stop at the first rung that holds:

1. **Does this need to exist at all?** Speculative need = skip it. Say so in one line.
2. **Already in this codebase?** A helper, util, type, or pattern that already lives here -> reuse it. Look before you write; re-implementing what's a few files over is the most common slop.
3. **Stdlib does it?** Use it.
4. **Native platform feature covers it?** `<input type="date">` over a picker lib, CSS over JS, DB constraint over app code.
5. **Already-installed dependency solves it?** Use it. Never add a new one for what a few lines can do.
6. **Can it be one line?** One line.
7. **Only then:** the minimum code that works.

The ladder runs *after* you understand the problem, not instead of it. Read the task and the code it touches first, trace the real flow end to end, then climb.

**Bug fix = root cause, not symptom.** Before editing, grep every caller of the function you're about to touch. The lazy fix IS the root-cause fix: one guard in the shared function is a smaller diff than a guard in every caller.

**Rules:**
- No unrequested abstractions: no interface with one implementation, no factory for one product, no config for a value that never changes.
- No boilerplate, no scaffolding "for later", later can scaffold for itself.
- Deletion over addition. Boring over clever.
- Fewest files possible. Shortest working diff wins.
- Complex request? Ship the lazy version and question it in the same response.
- Two stdlib options, same size? Take the one correct on edge cases.
- Mark deliberate simplifications with a `ponytail:` comment naming the ceiling and upgrade path.

**When NOT to be lazy:** input validation at trust boundaries, error handling that prevents data loss, security measures, accessibility basics, anything explicitly requested. Never lazy about understanding the problem.

**Intensity levels:**

| Level | What change |
|-------|------------|
| **lite** | Build what's asked, but name the lazier alternative in one line. User picks. |
| **full** | The ladder enforced. Stdlib and native first. Shortest diff, shortest explanation. Default. |
| **ultra** | YAGNI extremist. Deletion before addition. Ship the one-liner and challenge the rest of the requirement in the same breath. |

Switch: `/demiurge ponytail [lite|full|ultra]`. Default: **full**.

**Testing requirement:** Non-trivial logic (a branch, a loop, a parser, a money/security path) leaves ONE runnable check behind, the smallest thing that fails if the logic breaks: an `assert`-based `demo()`/`__main__` self-check or one small `test_*.py`. No frameworks, no fixtures, no per-function suites unless asked. Trivial one-liners need no test, YAGNI applies to tests too.

**Output rule:** If the explanation is longer than the code, delete the explanation. Every paragraph defending a simplification is complexity smuggled back in as prose. Pattern: `[code] -> skipped: [X], add when [Y].`

**Boundaries:** Ponytail governs what you build. Caveman governs how you talk. They are independent. You can have ponytail lite + caveman ultra, or ponytail ultra + caveman lite. Each has its own intensity level and deactivation.
