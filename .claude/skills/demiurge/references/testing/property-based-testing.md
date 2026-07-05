# Property-Based Testing Reference

## Property Catalog

| Property | Formula | When to Use |
|----------|---------|-------------|
| **Roundtrip** | `decode(encode(x)) == x` | Serialization, conversion pairs |
| **Idempotence** | `f(f(x)) == f(x)` | Normalization, formatting, sorting |
| **Invariant** | Property holds before/after | Any transformation |
| **Commutativity** | `f(a, b) == f(b, a)` | Binary/set operations |
| **Associativity** | `f(f(a,b), c) == f(a, f(b,c))` | Combining operations |
| **Identity** | `f(x, identity) == x` | Operations with neutral element |
| **Inverse** | `f(g(x)) == x` | encrypt/decrypt, compress/decompress |
| **Oracle** | `new_impl(x) == reference(x)` | Optimization, refactoring |
| **Easy to Verify** | `is_sorted(sort(x))` | Complex algorithms |
| **No Exception** | No crash on valid input | Baseline property |
| **Type Preservation** | `isinstance(f(x), ExpectedType)` | Typed functions |
| **Length Preservation** | `len(f(xs)) == len(xs)` | Collections |
| **Element Preservation** | `set(f(xs)) == set(xs)` | Sorting, shuffling |
| **Ordering** | `all(f(xs)[i] <= f(xs)[i+1])` | Sorting |

## Strength Hierarchy

Weakest to strongest:

```
No Exception → Type Preservation → Invariant → Idempotence → Roundtrip
```

Always push for the strongest property applicable to the code under test. "No crash" is the weakest guarantee.

## Pattern Detection

PBT is strongest when code exhibits these patterns:

| Pattern | Property | Priority |
|---------|----------|----------|
| encode/decode pair | Roundtrip | HIGH |
| Pure function | Multiple | HIGH |
| Validator | Valid after normalize | MEDIUM |
| Sorting/ordering | Idempotence + ordering | MEDIUM |
| Normalization | Idempotence | MEDIUM |
| Builder/factory | Output invariants | LOW |
| Smart contract | State invariants | HIGH |

**Auto-detect triggers:**
- Serialization pairs: `encode`/`decode`, `serialize`/`deserialize`, `toJSON`/`fromJSON`, `pack`/`unpack`
- Parsers: URL, config, protocol, string-to-structured-data
- Normalization: `normalize`, `sanitize`, `clean`, `canonicalize`, `format`
- Validators: `is_valid`, `validate`, `check_*`
- Data structures: Custom collections with `add`/`remove`/`get`
- Mathematical/algorithmic: Pure functions, sorting, comparators

## When NOT to Use

- Simple CRUD without complex validation
- One-off scripts or throwaway code
- Side effects that cannot be isolated (network, DB writes)
- Tests where specific examples suffice and edge cases are well-understood
- Integration or end-to-end testing

## Refactoring Patterns for Testability

| Pattern | Problem | Solution | Properties Enabled |
|---------|---------|----------|-------------------|
| I/O mixed with logic | Can't test without mocks | Extract pure core | Multiple |
| Encode without decode | No roundtrip possible | Add inverse operation | Roundtrip |
| Hardcoded config | Can't test edge cases | Inject dependencies | Full coverage |
| In-place mutation | Hard to verify before/after | Return new value | Comparison properties |
| String building | Can't verify structure | Structured + render | Roundtrip |
| Implicit invariants | Can't test constraints | Make explicit with validation | Invariant |

### Key Refactoring: Extract Pure Core

```python
# BEFORE - hard to test
def process_order(order_id: str) -> None:
    order = db.fetch(order_id)
    discount = calculate_discount(order)
    total = apply_discount(order, discount)
    db.save(order_id, total)

# AFTER - pure core extracted
def calculate_order_total(order: Order, rules: DiscountRules) -> Decimal:
    discount = calculate_discount(order, rules)
    return apply_discount(order, discount)

def process_order(order_id: str) -> None:
    order = db.fetch(order_id)
    total = calculate_order_total(order, get_discount_rules())
    db.save(order_id, total)
```

### Key Refactoring: Add Inverse Operations

```python
# BEFORE - only encode
def encode_message(msg: dict) -> bytes:
    return msgpack.packb(msg)

# AFTER - add decode for roundtrip testing
def decode_message(data: bytes) -> dict:
    return msgpack.unpackb(data)
```

## Failure Classification

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| Fails on edge case not mentioned in spec | Ambiguous specification | Clarify before reporting |
| Fails on input that violates documented preconditions | Over-constrained strategy | Fix the strategy |
| Property contradicts docstring or type hints | Wrong property | Fix the property |
| Clear violation of documented guarantee | Genuine bug | Report with evidence |
| Behavior differs from similar functions | Possible inconsistency | Investigate further |

### Grounding Checklist

Before reporting a failure as a bug:

1. Property matches documented return type
2. Property matches docstring guarantees
3. Input is within documented domain (preconditions met)
4. No `assume()` filtering out the failing case inappropriately
5. Existing tests don't contradict your property
6. Behavior contradicts docs, not just expectations

### Confidence Threshold

Report only when you can answer YES to all:

1. Reproduced with minimal example
2. Verified property against docs/types/docstrings
3. Can point to specific documented guarantee violated
4. Failing input is within documented domain
5. Ruled out test bugs and ambiguous specs

## Libraries by Language

| Language | Library | Import |
|----------|---------|--------|
| Python | Hypothesis | `from hypothesis import given, strategies as st` |
| JavaScript/TypeScript | fast-check | `import fc from 'fast-check'` |
| Rust | proptest | `use proptest::prelude::*` |
| Go | rapid | `import "pgregory.net/rapid"` |
| Java | jqwik | `@Property` annotations |
| Scala | ScalaCheck | `import org.scalacheck._` |
| C# | FsCheck | `using FsCheck; using FsCheck.Xunit;` |
| Elixir | StreamData | `use ExUnitProperties` |
| Haskell | QuickCheck | `import Test.QuickCheck` |
| Clojure | test.check | `[clojure.test.check :as tc]` |
| Ruby | PropCheck | `require 'prop_check'` |
| Kotlin | Kotest | `io.kotest.property.*` |
| C++ | RapidCheck | `#include <rapidcheck.h>` |

**Smart Contract (EVM/Solidity):**

| Tool | Description |
|------|-------------|
| Echidna | Property-based fuzzer for EVM contracts |
| Medusa | Next-gen fuzzer with parallel execution |

## Input Strategy Quick Reference (Python/Hypothesis)

| Type | Strategy |
|------|----------|
| `int` | `st.integers()` |
| `float` | `st.floats(allow_nan=False)` |
| `str` | `st.text()` |
| `list[T]` | `st.lists(strategy_for_T)` |
| `dict[K, V]` | `st.dictionaries(key_strategy, value_strategy)` |
| `Optional[T]` | `st.none() \| strategy_for_T` |
| Custom class | `st.builds(ClassName, field1=..., field2=...)` |
| Enum | `st.sampled_from(EnumClass)` |
| Email | `st.emails()` |
| Regex match | `st.from_regex(r"pattern")` |

**Composite strategy:**

```python
@st.composite
def valid_users(draw):
    name = draw(st.text(min_size=1, max_size=50))
    age = draw(st.integers(min_value=0, max_value=150))
    email = draw(st.emails())
    return User(name=name, age=age, email=email)
```

## Strategy Design Principles

1. **Constrain early**: Build constraints into strategy, not `assume()`
2. **Size limits**: Use `max_size` to prevent slow tests
3. **Realistic data**: Make strategies match real-world constraints
4. **Reuse strategies**: Define once, use across tests

## Settings Recommendations

```python
# Development (fast feedback)
@settings(max_examples=10)

# CI (thorough)
@settings(max_examples=200)

# Nightly/Release (exhaustive)
@settings(max_examples=1000, deadline=None)
```

## Quality Checklist

- [ ] Not tautological (assertion doesn't compare same expression)
- [ ] Strong assertion (not just "no crash")
- [ ] Not vacuous (inputs not over-filtered)
- [ ] Good coverage (edge cases via `@example`)
- [ ] No reimplementation of function logic
- [ ] Appropriate settings for context
- [ ] Good shrinking potential
- [ ] Deterministic (no flakiness risk)

## Anti-Patterns

- **Tautological**: `assert sorted(xs) == sorted(xs)` — always true regardless of implementation
- **Vacuous**: Contradictory `assume()` calls — no inputs pass
- **Weak**: No assertion or only type check
- **Reimplemented**: `assert add(a,b) == a + b` — tests nothing if add is just +
- **Over-filtered**: Multiple `assume()` calls — redesign strategy instead
