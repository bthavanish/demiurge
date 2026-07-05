# Testing Reference

Property-based testing and mutation testing.

---

## Property-Based Testing

### Property Catalog

| Property | Formula | When |
|---|---|---|
| Roundtrip | `decode(encode(x)) == x` | Serialization, conversion pairs |
| Idempotence | `f(f(x)) == f(x)` | Normalization, formatting |
| Invariant | Property holds before/after | Any transformation |
| Commutativity | `f(a, b) == f(b, a)` | Binary/set operations |
| Identity | `f(x, identity) == x` | Operations with neutral element |
| Inverse | `f(g(x)) == x` | encrypt/decrypt, compress/decompress |
| Oracle | `new_impl(x) == reference(x)` | Optimization, refactoring |

### Strength Hierarchy

Weakest to strongest: No Exception -> Type Preservation -> Invariant -> Idempotence -> Roundtrip. Always push for the strongest applicable property.

### Pattern Detection

| Pattern | Property |
|---|---|
| encode/decode pair | Roundtrip |
| Pure function | Multiple |
| Validator | Valid after normalize |
| Sorting/ordering | Idempotence + ordering |
| Normalization | Idempotence |

### When NOT to Use

Simple CRUD, one-off scripts, side effects that can't be isolated, integration/E2E testing.

### Refactoring for Testability

- Extract pure core from I/O-mixed logic
- Add inverse operations for roundtrip testing
- Inject dependencies instead of hardcoding config
- Return new values instead of in-place mutation

### Failure Classification

- Fails on edge case not in spec -> clarify spec before reporting
- Property contradicts docstring -> fix the property
- Clear violation of documented guarantee -> genuine bug

### Libraries

| Language | Library |
|---|---|
| Python | Hypothesis |
| JS/TS | fast-check |
| Rust | proptest |
| Go | rapid |
| Java | jqwik |
| Scala | ScalaCheck |
| C# | FsCheck |
| Haskell | QuickCheck |
| Kotlin | Kotest |

### Quality Checklist

- Not tautological
- Strong assertion (not just "no crash")
- Not vacuous (inputs not over-filtered)
- Good coverage (edge cases via `@example`)
- No reimplementation of function logic

---

## Mutation Testing

Tools: mewt (Rust, Solidity, Go, TS, JS) / muton (TON: Tact, Tolk, FunC).

### 5-Phase Workflow

1. **Initialize**: `mewt init`, `mewt print config`, `mewt print targets`
2. **Generate**: `mewt mutate src/`, `mewt status`
3. **Optimize**: < 1hr proceed, 1-16hr ask user, > 16hr explore options
4. **Validate**: test command verified, timeout set
5. **Final**: all checks pass

### Duration Calculation

`mutant_count x test_duration` = worst-case duration.

### Per-File Targeting

Use when tests are organized by module and targeted runs are significantly faster:

```toml
[[test.per_target]]
glob = "src/auth/*.rs"
cmd = "cargo test auth::unit"
timeout = 10
```

### Severity Filtering

Filter to high/medium only: `mewt results --severity high,medium`. ~30-40% of mutants. Low severity still provides value, just lower priority.

### Two-Phase Campaigns

For integration-heavy suites only. Phase 1: targeted tests on critical code. Phase 2: re-test uncaught mutants with full suite.

### Essential Commands

```bash
mewt init                    # Create config + DB
mewt mutate [paths]          # Generate mutants
mewt run [paths]             # Full campaign
mewt print config            # View config
mewt print targets           # Targeted files
mewt status                  # Mutant count
mewt print mutants --severity high  # Filter by severity
mewt results                 # Final results
```

### Results

| Result | Meaning |
|---|---|
| Caught/TestFail | Tests detected mutation (good) |
| Uncaught | Mutation survived (untested logic) |
| Timeout | Tests too long (inconclusive) |
| Skipped | More severe mutant already failed on same line |
