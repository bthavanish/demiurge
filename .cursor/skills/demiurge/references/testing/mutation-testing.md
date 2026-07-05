# Mutation Testing Reference (mewt/muton)

> muton and mewt share identical interfaces but target different languages — mewt for general-purpose languages (Rust, Solidity, Go, TypeScript, JavaScript), muton for TON smart contracts (Tact, Tolk, FunC).

## 5-Phase Configuration Workflow

### Phase 1: Initialize and Validate Targets

```bash
mewt init                    # Create mewt.toml and mewt.sqlite
mewt print config            # Review auto-generated configuration
mewt print targets           # Verify target patterns
```

Target configuration in `mewt.toml`:

```toml
[targets]
include = ["src/**/*.rs"]      # Specific source directories only
ignore = ["test", "mock"]      # Exclude test/mock files within src/

[test]
cmd = "cargo test"
```

**Rules:**
- Include patterns should match only source code: `src/`, `lib/`, `contracts/`
- Ignore patterns use substring matching (e.g., `"test"` matches `tests/`, `test_utils.rs`)
- Never mutate tests, dependencies, or generated code

### Phase 2: Generate Mutants and Assess Scope

```bash
mewt mutate src/
mewt status           # View total mutant count
mewt print targets    # Pretty table showing which files were mutated
```

**Calculate worst-case duration:** `mutant_count × test_duration`

### Phase 3: Decide on Optimization Strategy

```
Estimated campaign duration?
|
+-- < 1 hour
|   └─> Proceed to Phase 4 (no optimization needed)
|
+-- 1-16 hours
|   └─> Consult user: Acceptable? Run overnight/end-of-day?
|
+-- > 16 hours
    └─> Explore optimization options
```

### Phase 4: Validate Test Command and Timeout

```bash
# Test with warm cache
time forge test

# Simulate mutation
touch src/Contract.sol

# Test again (includes recompilation)
time forge test

# If drastically different, set manual timeout
```

**Timeout:** Mewt auto-calculates (baseline × 2). Only set manual for recompilation-heavy languages (Solidity/Foundry).

### Phase 5: Final Validation

- [ ] `mewt print config` — valid syntax
- [ ] `mewt status` — expected mutant count
- [ ] `mewt print targets` — only intended files
- [ ] Test command verified
- [ ] Timeout set appropriately
- [ ] Scope acceptable

## Per-File Targeting

Use when tests are well-organized by module and targeted tests run significantly faster than full suite.

```toml
[[test.per_target]]
glob = "src/auth/*.rs"
cmd = "cargo test auth::unit"
timeout = 10

[[test.per_target]]
glob = "src/core/*.rs"
cmd = "cargo test core::unit"
timeout = 15

# Catch-all (first match wins — put most specific patterns first)
[[test.per_target]]
glob = "**/*.rs"
cmd = "cargo test"
timeout = 60
```

**Verify speedup:**
```bash
time go test ./...       # Full suite: 45s
time go test ./auth      # Targeted: 8s
```

## Severity Filtering

### Option C: High/Medium Severity Only

```toml
[run]
mutations = ["ER", "CR", "IF", "IT"]  # Specific types (high/medium)
```

After editing, full regeneration required:
```bash
mewt purge --all
mewt mutate src/
mewt status
```

Or filter during analysis without database changes:
```bash
mewt results --severity high,medium
mewt print mutants --severity high
```

**Trade-offs:**
- High/med severity: ~30-40% of mutants (varies by codebase)
- Low severity: ~60-70% of mutants (operator shuffles, edge cases)
- Low severity still provides value, just lower priority

## Two-Phase Campaigns

**Use ONLY for integration-heavy test suites.** Not recommended for well-organized unit tests.

### When to Use

**Good fit:**
- Integration tests dominate runtime
- Unit tests provide broad coverage but don't map cleanly to files
- Targeted test commands significantly faster than full suite

### Setup

```toml
# TWO-PHASE CAMPAIGN

# PHASE 2: Uncomment after phase 1 completes
# [test]
# cmd = "cargo test"
# timeout = 60

# PHASE 1: Targeted tests
[[test.per_target]]
glob = "src/auth/*.rs"
cmd = "cargo test auth::unit"
timeout = 10

[[test.per_target]]
glob = "src/core/*.rs"
cmd = "cargo test core::unit"
timeout = 15

[[test.per_target]]
glob = "**/*.rs"
cmd = "cargo test"
timeout = 60
```

### Execution

**Phase 1:**
```bash
mewt run
```

**Phase 2 (after phase 1 completes):**
```bash
# Extract uncaught mutants
mewt results --status Uncaught --format ids > uncaught_ids.txt

# Update mewt.toml: comment out per_target sections, uncomment [test] section

# Re-test with full suite
mewt test --ids-file uncaught_ids.txt

# Review final results
mewt results
```

**Example speedup:**
```
Naive: 2,000 mutants × 45s = 25 hours
Two-phase: Phase 1 (4.4h) + Phase 2 (5.6h) = ~10 hours (2.5× speedup)
```

## Essential Commands

```bash
# Initialize and mutate
mewt init                    # Create mewt.toml and mewt.sqlite
mewt mutate [paths]          # Generate mutants without running tests
mewt run [paths]             # Run the full campaign

# Inspect
mewt print config            # View effective configuration
mewt print targets           # Table of all targeted files
mewt print mutations --language [lang]  # Available mutation types
mewt status                  # Mutant count and per-file breakdown

# Investigate
mewt print mutants --target [path]   # All mutants for a file
mewt print mutants --severity high   # Filter by severity
mewt print mutant --id [id]          # View mutated code diff
mewt test --ids [ids]                # Re-test specific mutants
```

## What Results Mean

| Result | Meaning |
|--------|---------|
| Caught/TestFail | Tests detected the mutation (good) |
| Uncaught | Mutation survived — indicates untested logic |
| Timeout | Tests took too long, inconclusive |
| Skipped | A more severe mutant already failed on the same line |

## Optimization Priority

1. **Verify target selection** — most common issue is mutating non-source code
2. **Analyze project structure** — get mutant counts per component
3. **Choose optimization** — full campaign / target critical / high-severity only / two-phase
4. **After changes:** purge removed targets, then mutate newly included files

## Troubleshooting

### No Mutants Generated
```bash
mewt print mutations --language rust   # Check language support
mewt print config                      # Verify patterns match files
ls src/**/*.rs                         # Do files exist?
```

**Common causes:** Include pattern doesn't match, ignore pattern too broad, unsupported language.

### Test Command Fails
Run manually first. Check `Makefile`, `justfile`, `package.json`, `README.md` for correct command.

## Configuration Principles

- Configure via `mewt.toml` — not CLI flags (version control the config)
- Target source code specifically — exclude tests, dependencies, generated code
- Prefer limiting files over mutation types — better to assess critical code thoroughly
- Trust auto-calculated timeouts — 2× baseline accounts for incremental recompilation
- Measure before optimizing — profile actual test times before applying per-target config
- Document decisions — commit `mewt.toml` with comments explaining choices

## Campaign Execution Timing

- **< 1 hour:** Run anytime
- **1-16 hours:** Start end-of-day, results by morning
- **16-48 hours:** Start Friday evening, results Monday
- **Two-phase:** Phase 1 overnight, Phase 2 next day
