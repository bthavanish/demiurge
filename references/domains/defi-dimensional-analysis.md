# DeFi Dimensional Analysis Reference

Dimensional analysis for codebases performing numeric computations with mixed units, precisions, or scaling factors. Prevents dimensional mismatches and catches formula bugs early.

## Annotation Format

### Notation

- `{A}` - A semantic unit (e.g., `{tok}`, `{share}`, `{UoA}`)
- `D18` - A precision prefix indicating 18 decimal places
- `D18{A}` - A value with unit `{A}` and precision D18
- `{A/B}` - A derived unit (A per B)
- `{A*B}` - A compound unit (A times B)
- `{1}` - Dimensionless (pure ratio)

### Formal Grammar

```
annotation     := scale? "{" dimension "}"
scale          := "D" number
dimension      := base_dim | derived_dim | "1"
derived_dim    := dimension "/" dimension | dimension "*" dimension
base_dim       := identifier
```

### Comment Placement Patterns

**Variable Declarations:**
```solidity
uint256 public totalAssets;  // D18{UNDERLYING}
```

**Function Parameters (NatSpec):**
```solidity
/// @param assets D18{UNDERLYING} Amount to deposit
/// @return shares D18{SHARE} Shares minted
function deposit(uint256 assets) external returns (uint256 shares);
```

**Struct Fields:**
```solidity
struct Position {
    uint256 collateral;    // D18{COLLATERAL} Collateral deposited
    uint256 debt;          // D18{DEBT} Amount borrowed
    uint256 lastUpdate;    // {s} Timestamp of last interest accrual
}
```

**Formula Verification Comments:**
```solidity
// shares = assets * totalSupply / totalAssets
// {SHARE} = {UNDERLYING} * {SHARE} / {UNDERLYING}
//         = {SHARE} ✓
shares = assets.mulDiv(totalSupply(), totalAssets());
```

## 12 Bug Patterns

### Critical Bugs (P0)

**Pattern 1: Unit Mismatch in Price Feeds**
Oracle returns price in different precision than expected.
```solidity
// Contract assumes D27 prices
uint256 price; // D27{UoA/tok}
// But Chainlink returns D8!
price = uint256(answer); // BUG: D8 assigned to D27 variable
// Correct:
price = uint256(answer) * 1e19; // Scale D8 to D27
```

**Pattern 2: Cross-Contract Dimension Assumption Mismatch**
Caller assumes different dimension than callee returns.
```solidity
// Protocol A returns D18{tok/share}
// Protocol B assumes D27{tok/share}
sharePrice = vaultA.getSharePrice(); // BUG: D18 value in D27 variable
```

**Pattern 3: Adding Incompatible Dimensions**
Adding values with different semantic meanings.
```solidity
// BUG: Can't add tokens and shares!
uint256 totalPosition = tokenBalance + shareBalance;
// Correct: Convert to common dimension
uint256 totalTokens = tokenBalance + convertToAssets(shareBalance);
```

**Pattern 4: Wrong Precision Causing Overflow**
Multiplication without scaling causes overflow or precision explosion.
```solidity
// BUG: D18 * D27 = D45, overflows!
uint256 value = amount * price;
// Correct:
uint256 value = Math.mulDiv(amount, price, 1e27);
```

### High Severity Bugs (P1)

**Pattern 5: Missing Scaling Factor**
Calculation omits necessary precision adjustment.
```solidity
// BUG: Missing D18 scaling
uint256 shares = assets * supply / totalAssets;
// Actually: D18 * D18 / D18 = D18, but intermediate is D36!
// Correct:
uint256 shares = Math.mulDiv(assets, supply, totalAssets);
```

**Pattern 6: Wrong Scaling Direction**
Multiply when should divide, or vice versa.
```solidity
// BUG: Multiplied instead of divided
uint256 priceD18 = priceD27 * 1e9; // Now D36!
// Correct:
uint256 priceD18 = priceD27 / 1e9;
```

**Pattern 7: Inconsistent Return Path Dimensions**
Different code paths return values with different dimensions.
```solidity
function getValue(bool useOracle) returns (uint256) {
    if (useOracle) {
        return oracle.getPrice(token); // D8{UoA/tok}
    } else {
        return cachedPrice; // D18{UoA/tok} - DIFFERENT DIMENSION!
    }
}
```

**Pattern 8: Implicit Precision Truncation**
High precision value assigned to lower precision variable.
```solidity
uint256 preciseValue; // D27{UoA}
uint256 result;       // D18{UoA}
// BUG: Truncates 9 decimal places
result = preciseValue / 1e9;
```

### Medium Severity Bugs (P2)

**Pattern 9: Redundant Scaling**
Unnecessary conversion that wastes gas or introduces rounding.
```solidity
uint256 temp = priceD18 * 1e9;  // D27
uint256 result = temp / 1e9;    // Back to D18 - redundant
```

**Pattern 10: Fee Applied to Wrong Dimension**
Fee percentage applied to value instead of amount, or vice versa.
```solidity
// BUG: Fee on USD value, not token amount
uint256 fee = depositAmount * pricePerToken * feePercent / 1e45;
// Correct: Fee on token amount
uint256 fee = depositAmount * feePercent / 1e18;
```

**Pattern 11: Time Unit Confusion**
Mixing seconds with other time units.
```solidity
// BUG: Applying annual rate to seconds
uint256 accrued = principal * ratePerYear * elapsed / 1e18;
// Correct: Convert to per-second rate
uint256 ratePerSecond = ratePerYear / SECONDS_PER_YEAR;
```

**Pattern 12: Division Before Multiplication**
Dividing first causes precision loss.
```solidity
// BUG: Division truncates
uint256 result = a / b * c; // = 33 * 7 = 231
// Correct:
uint256 result = a * c / b; // = 700 / 3 = 233
```

## Dimension Algebra

### Basic Composition Rules

**Multiplication:**
```
{A} * {B} = {A*B}
{tok} * {UoA/tok} = {UoA}           # tokens × price = value
{share} * {tok/share} = {tok}       # shares × exchange rate = tokens
{1} * {A} = {A}                     # dimensionless preserves dimension
```

**Division:**
```
{A} / {B} = {A/B}
{tok} / {share} = {tok/share}       # exchange rate
{UoA} / {tok} = {UoA/tok}           # price
{A} / {A} = {1}                     # same dimensions cancel
```

**Addition/Subtraction:**
```
{A} + {A} = {A}                     # Valid
{A} + {B} = ERROR                   # Invalid! Dimension mismatch
```

### Precision Arithmetic

**Multiplication Precision (ADD):**
```
D18 * D18 = D36
D27 * D18 = D45
```

**Division Precision (SUBTRACT):**
```
D36 / D18 = D18
D27 / D18 = D9
```

**Scaling Operations:**
```
D18{A} * D9 = D27{A}                # Scale up precision
D27{A} / D9 = D18{A}                # Scale down precision
```

### Common Patterns

**Price Calculation:**
```solidity
// {UoA} = {tok} * D27{UoA/tok} / D27
uint256 value = Math.mulDiv(amount, price, D18);
```

**Share Conversion (ERC4626):**
```solidity
// {share} = {tok} * {share} / {tok}
uint256 shares = Math.mulDiv(assets, totalSupply, totalAssets);
```

**Fee Application:**
```solidity
// {tok} = {tok} * D18{1} / D18
uint256 fee = Math.mulDiv(amount, feeRate, D18);
```

## Common DeFi Units

### Universal Base Units

| Unit | Description | Typical Precision |
|------|-------------|-------------------|
| `{tok}` | Token amount | D6 (USDC), D8 (WBTC), D18 (most ERC20) |
| `{share}` | Vault/pool shares | D18 |
| `{s}` | Time in seconds | Integer |
| `{1}` | Dimensionless (ratios, percentages) | D18 or D4 (basis points) |
| `{UoA}` | Unit of account (typically USD) | Varies |

### Standard Derived Units

| Unit | Description | Example |
|------|-------------|---------|
| `{tok/share}` | Exchange rate | D18{tok/share} |
| `{UoA/tok}` | Price per token | D8{UoA/tok} (Chainlink) |
| `{tokA/tokB}` | Cross price | D18{tokA/tokB} |
| `{1/s}` | Rate per second | D18{1/s} |
| `{UoA/share}` | Value per share | D18{UoA/share} |

### Protocol-Specific Units

**Reserve Protocol:**
| Unit | Description |
|------|-------------|
| `{BU}` | Basket Unit |
| `{tok/BU}` | Tokens per basket |
| `{UoA/BU}` | Basket value |
| `{BU/share}` | Baskets per share |

**Lending Protocols (Aave, Compound):**
| Unit | Description |
|------|-------------|
| `{debt}` | Debt token amount |
| `{collateral}` | Collateral amount |
| `{aToken}` | Interest-bearing deposit token |

**AMM Protocols (Uniswap, Curve):**
| Unit | Description |
|------|-------------|
| `{liq}` | Liquidity units |
| `{LP}` | LP token amount |
| `{sqrtP}` | Square root price (Uniswap V3) |

## Precision Levels

| Prefix | Value | Common Usage |
|--------|-------|--------------|
| D4 | 1e4 | Basis points |
| D6 | 1e6 | USDC, USDT decimals |
| D8 | 1e8 | WBTC, Chainlink prices |
| D18 | 1e18 | Standard ERC20, most calculations |
| D27 | 1e27 | High-precision prices (Reserve) |
| Q96 | 2^96 | Uniswap V3 fixed-point |

## Detection Strategies

### Static Analysis

1. Parse annotations - Extract all dimensional comments
2. Build dimension graph - Map variable → dimension
3. Trace arithmetic - Apply algebra rules
4. Check assignments - LHS must match RHS dimension
5. Check function boundaries - Args match params, returns match declarations

### Code Patterns to Flag

```solidity
// Flag: Multiplication without mulDiv
a * b                           // Needs dimension check

// Flag: Direct oracle assignment
price = oracle.latestAnswer()   // Check precision match

// Flag: Addition of different variables
total = valueA + valueB         // Verify same dimension

// Flag: Return in conditional
if (x) return a; else return b; // Verify a and b same dimension

// Flag: Scaling literals
value * 1e9                     // Verify direction correct
value / 1e18                    // Verify scaling appropriate
```

### Human Review Triggers

- Cross-contract calls (external assumptions)
- Complex multi-step calculations
- Non-standard token decimals (not 18)
- Custom oracle implementations
- Protocol-specific units

## False Positive Avoidance

### Acceptable Patterns

```solidity
// Intentional dimensionless arithmetic
uint256 doubled = amount * 2;       // {tok} * {1} = {tok}

// Loop bounds
for (uint256 i = 0; i < length; i++)  // {1}

// Explicit documented conversion
// Intentionally converting D27 to D18 with precision loss
uint256 approxPrice = precisePrice / 1e9;

// Test contracts
contract MockOracle { ... }         // Ignore test code
```

### Context Clues

- Check for comments explaining intent
- Check for test file paths
- Check for "mock" or "test" in names
- Check for explicit precision documentation
