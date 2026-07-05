# Entry Point Analysis

Systematically identify all state-changing entry points in a smart contract codebase to guide security audits. Detects externally callable functions that modify state, categorizes them by access level, and generates structured audit reports.

---

## Scope: State-Changing Functions Only

Excludes read-only functions (view/pure) — they cannot directly cause loss of funds or state corruption.

| Language | Excluded Patterns |
|----------|-------------------|
| Solidity | `view`, `pure` functions |
| Vyper | `@view`, `@pure` functions |
| Solana | Functions without `mut` account references |
| Move | Non-entry `public fun` (module-callable only) |
| TON | `get` methods (FunC), read-only receivers (Tact) |
| CosmWasm | `query` entry point and its handlers |

---

## Language Detection

| Extension | Language | Key Indicators |
|-----------|----------|----------------|
| `.sol` | Solidity | `pragma solidity`, `contract`, `interface` |
| `.vy` | Vyper | `@version`, `@external`, `@view` |
| `.rs` + `Cargo.toml` with `solana-program` | Solana (Rust) | `#[program]`, `#[account]`, `#[derive(Accounts)]` |
| `.move` + `Move.toml` with `edition` | Move (Sui) | `module`, `entry fun`, `#[access_control]` |
| `.move` + `Move.toml` with `Aptos` | Move (Aptos) | `module`, `public fun`, `entry fun` |
| `.fc`, `.func`, `.tact` | TON | `recv_internal`, `recv_external`, `receive` |
| `.rs` + `Cargo.toml` with `cosmwasm-std` | CosmWasm | `#[entry_point]`, `execute`, `instantiate` |

---

## Access Classifications

### 1. Public (Unrestricted)

Functions callable by anyone without restrictions. Highest attack surface priority.

**Solidity indicators:** `public` visibility, no access modifier, no `require` on `msg.sender`
**Vyper indicators:** `@external` without `@only`
**Solana indicators:** No `has_one` or `constraint` on authority account
**Move indicators:** `public fun` without `entry` + role check
**TON indicators:** `recv_internal` without sender validation
**CosmWasm indicators:** `execute` handler without authority check

### 2. Role-Restricted

Functions limited to specific roles. Common patterns:

| Pattern | Example |
|---------|---------|
| Explicit role names | `admin`, `owner`, `governance`, `guardian`, `operator`, `minter`, `pauser`, `keeper`, `relayer` |
| Role-checking modifiers | `onlyRole`, `hasRole`, `require(msg.sender == X)`, `assert_owner` |
| Access control decorators | `#[access_control]` (Move) |
| Capability tokens | Pass `Cap` or `Proof` object |

When role is ambiguous, flag as **"Restricted (review required)"** with the restriction pattern noted.

### 3. Contract-Only (Internal Integration Points)

Functions callable only by other contracts, not EOAs.

**Indicators:**
- Callbacks: `onERC721Received`, `uniswapV3SwapCallback`, `flashLoanCallback`
- Interface implementations with contract-caller checks
- Functions that revert if `tx.origin == msg.sender`
- Cross-contract hooks
- CosmWasm reply handlers

---

## Language-Specific Entry Point Detection

### Solidity

**Entry point patterns:**

| Pattern | State-Changing | Notes |
|---------|----------------|-------|
| `function X() external` | Yes | External = callable from other contracts |
| `function X() public` | Yes | Public = callable from EOAs and contracts |
| `function X() internal` | No | Internal = only within contract/inheritance |
| `function X() private` | No | Private = only within contract |
| `function X() external view` | No | View = read-only |
| `function X() external pure` | No | Pure = no state access |
| `receive() external payable` | Yes | Fallback ETH receive |
| `fallback() external payable` | Yes | Fallback function |
| `constructor()` | Yes | Deployment entry point |

**Access control detection:**

```solidity
// Pattern: modifier-based
function X() external onlyOwner { }
function X() external onlyRole(ADMIN_ROLE) { }

// Pattern: require-based
function X() external {
    require(msg.sender == owner, "Not owner");
}

// Pattern: custom check
function X() external {
    require(roles[msg.sender] & ADMIN != 0, "No admin");
}
```

**Callback detection:**

```solidity
// ERC standards
function onERC721Received(...) external returns (bytes4)
function onERC1155Received(...) external returns (bytes4)
function onERC1155BatchReceived(...) external returns (bytes4)

// DeFi callbacks
function uniswapV3SwapCallback(...) external
function flashLoanCallback(...) external
function onAaveFlashLoan(...) external
```

### Vyper

**Entry point patterns:**

| Pattern | State-Changing | Notes |
|---------|----------------|-------|
| `@external` | Yes | External callable |
| `@external @view` | No | Read-only |
| `@external @pure` | No | Pure function |
| `@internal` | No | Internal only |

**Access control detection:**

```vyper
@external
@onlyOwner
def set_config(value: uint256): ...

@external
def withdraw(amount: uint256):
    assert msg.sender == owner, "Not owner"
```

### Solana (Rust)

**Entry point patterns:**

```rust
#[program]
pub mod my_program {
    pub fn initialize(ctx: Context<Initialize>, amount: u64) -> Result<()> {
        // State-changing entry point
    }

    pub fn transfer(ctx: Context<Transfer>, amount: u64) -> Result<()> {
        // State-changing entry point
    }
}
```

**Account constraints (access control):**

```rust
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,

    #[account(
        init,
        payer = payer,
        space = 8 + 64,
        seeds = [b"config"],
        bump
    )]
    pub config: Account<'info, Config>,

    pub system_program: Program<'info, System>,
}
```

**Entry point detection:** Any function under `#[program]` with `Context` parameter is an entry point. `has_one`, `constraint`, `seeds`, and `Signer` constraints are access control.

### Move (Sui / Aptos)

**Sui entry point patterns:**

```move
public entry fun transfer(
    object: &mut Object,
    recipient: address,
    ctx: &mut TxContext
) {
    // Entry point — callable from transactions
}

public fun get_value(object: &Object): u64 {
    // NOT entry — only callable from other Move functions
}
```

**Aptos entry point patterns:**

```move
public entry fun initialize(account: &signer) {
    // Entry point
}

public fun transfer(from: &signer, to: address, amount: u64) {
    // Public but not entry — only callable from other modules
}
```

**Access control detection:**

```move
// Role check pattern
public entry fun admin_only(account: &signer) {
    assert!(role_of(account) == ADMIN, ENOT_ADMIN);
}

// Capability pattern
public entry fun do_thing(cap: &AdminCap) {
    // AdminCap must be owned by caller
}
```

### TON (FunC / Tact)

**FunC entry point patterns:**

```func
() recv_internal(slice sender_address, int balance, slice msg) {
    // State-changing entry point — incoming internal message
}

() recv_external(slice msg) {
    // State-changing entry point — incoming external message
}
```

**Tact entry point patterns:**

```tact
receive("transfer", msg: Transfer) {
    // State-changing entry point
}

receive("mint", msg: Mint) {
    // State-changing entry point
}
```

**Access control:** Check sender address validation, `stdlib` sender checks, or Tact `require` statements on sender.

### CosmWasm

**Entry point patterns:**

```rust
#[entry_point]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    // State-changing entry point
}

#[entry_point]
pub fn instantiate(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    // Deployment entry point
}

#[entry_point]
pub fn reply(deps: DepsMut, env: Env, msg: Reply) -> Result<Response, ContractError> {
    // Reply handler — state-changing
}

// NOT entry points:
#[entry_point]
pub fn query(deps: Deps, env: Env, msg: QueryMsg) -> StdResult<Binary> {
    // Read-only
}
```

**Access control detection:**

```rust
// Authority check
if info.sender != config.owner {
    return Err(ContractError::Unauthorized {});
}

// Contract-only (reply handler)
#[entry_point]
pub fn reply(...) -> Result<Response, ContractError> {
    // Only callable by the blockchain itself
}
```

---

## Output Format

```markdown
# Entry Point Analysis: [Project Name]

**Analyzed**: [timestamp]
**Scope**: [directories analyzed or "full codebase"]
**Languages**: [detected languages]
**Focus**: State-changing functions only (view/pure excluded)

## Summary

| Category | Count |
|----------|-------|
| Public (Unrestricted) | X |
| Role-Restricted | X |
| Restricted (Review Required) | X |
| Contract-Only | X |
| **Total** | **X** |

---

## Public Entry Points (Unrestricted)

| Function | File | Notes |
|----------|------|-------|
| `functionName(params)` | `path/to/file.sol:L42` | Brief note |

---

## Role-Restricted Entry Points

### Admin / Owner
| Function | File | Restriction |
|----------|------|-------------|
| `setFee(uint256)` | `Config.sol:L15` | `onlyOwner` |

### Governance
| Function | File | Restriction |
|----------|------|-------------|

### Guardian / Pauser
| Function | File | Restriction |
|----------|------|-------------|

### Other Roles
| Function | File | Restriction | Role |
|----------|------|-------------|------|

---

## Restricted (Review Required)

| Function | File | Pattern | Why Review |
|----------|------|---------|------------|
| `execute(bytes)` | `Executor.sol:L88` | `require(trusted[msg.sender])` | Dynamic trust list |

---

## Contract-Only (Internal Integration Points)

| Function | File | Expected Caller |
|----------|------|-----------------|
| `onFlashLoan(...)` | `Vault.sol:L200` | Flash loan provider |

---

## Files Analyzed

- `path/to/file1.sol` (X state-changing entry points)
- `path/to/file2.sol` (X state-changing entry points)
```

---

## Common Role Patterns by Protocol Type

| Protocol Type | Common Roles |
|---------------|--------------|
| DEX | `owner`, `feeManager`, `pairCreator` |
| Lending | `admin`, `guardian`, `liquidator`, `oracle` |
| Governance | `proposer`, `executor`, `canceller`, `timelock` |
| NFT | `minter`, `admin`, `royaltyReceiver` |
| Bridge | `relayer`, `guardian`, `validator`, `operator` |
| Vault/Yield | `strategist`, `keeper`, `harvester`, `manager` |

---

## Slither Integration (Solidity)

For Solidity codebases, check if Slither is available and use it for entry point extraction:

```bash
which slither
slither . --print entry-points
```

Slither outputs a table of all state-changing entry points with contract name, function name, visibility, and modifiers. Cross-reference with manual inspection for access control classification. Fall back to manual analysis if Slither is unavailable or fails.

---

## Analysis Guidelines

1. **Be thorough**: Every state-changing externally callable function matters
2. **Be conservative**: When uncertain about access level, flag for review
3. **Skip read-only**: Exclude view, pure, and equivalent read-only functions
4. **Note inheritance**: If access control comes from parent contract, note it
5. **Track modifiers**: List all access-related modifiers/decorators
6. **Identify patterns**: Initializer functions (often unrestricted on first call), upgrade functions (high-privilege), emergency/pause functions (guardian-level), fee/parameter setters (admin-level)
