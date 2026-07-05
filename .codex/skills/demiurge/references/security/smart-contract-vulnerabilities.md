# Smart Contract Vulnerability Patterns Reference

## Solana

### Arbitrary CPI
Using `invoke()`/`invoke_signed()` with user-controlled program IDs. Validate all CPI program IDs: `program.key() == EXPECTED_PROGRAM_ID`. Anchor: use `Program<'info, T>` type.

### Improper PDA Validation
Multiple valid bumps for same seeds. Use `find_program_address()` for canonical bump. Store bump in account. Anchor: use `seeds` and `bump` constraints.

### Missing Ownership Check
Accounts without owner validation before deserialization. Check `account.owner == expected_program_id`. Anchor: use `Account<'info, T>` type.

### Missing Signer Check
Sensitive operations without `is_signer` validation. Check `account.is_signer == true`. Anchor: use `Signer<'info>` type.

### Sysvar Account Check (Pre-1.8.1)
Use `load_instruction_at_checked()` instead of `load_instruction_at()`. Validate sysvar account against known addresses.

### Improper Instruction Introspection
Use relative indexes (`get_instruction_relative(-1, ...)`), not absolute. Validate correlation between current and referenced instructions.

## TON (FunC)

### Integer as Boolean
FunC uses -1 for true, 0 for false. Positive integers (1, 2) as booleans cause logic errors with `~` operator. Return -1 for true, not 1.

### Fake Jetton Contract
`transfer_notification` can be sent by any contract. Validate sender address is expected Jetton wallet address stored at initialization.

### Forward TON Without Gas Check
User-specified `forward_ton_amount` without `msg_value >= tx_fee + forward_ton_amount` validation drains contract balance. Use fixed/bounded forward amounts.

## Cairo (StarkNet)

### felt252 Arithmetic Overflow/Underflow
`felt252` wraps in field [0, P]. Use `u128`/`u256` types instead, or explicit bounds checks.

### L1 to L2 Address Conversion
L1 addresses >= StarkNet field prime map to zero. Validate `0 < address < STARKNET_FIELD_PRIME` on L1.

### L1 to L2 Message Failure
Messages may not be processed. Implement cancellation mechanism (`startL1ToL2MessageCancellation`).

### Signature Replay
Include nonce (incremented per use) and domain separator (chain ID, contract address) in signatures.

### Unchecked from_address in L1 Handler
All `#[l1_handler]` functions must validate `from_address == expected_l1_contract_address`.

## Cosmos SDK

### Non-determinism
NO `range` over maps, goroutines, `select` with multiple channels, `rand`, `time.Now()`, `int`/`float64` types, or `&obj` in consensus code. Use sorted map keys, `ctx.BlockTime()`, `math.Int`.

### Slow ABCI Methods
`BeginBlock`/`EndBlock`/`PreBlock` must have bounded computational complexity. Process limited batch per block. No nested loops over unbounded collections.

### ABCI Methods Panic
`NewCoins` panics on invalid coins. Use error-returning math constructors, not `Must*` variants. Check for zero divisors.

### Incorrect Signer Annotation
`cosmos.msg.v1.signer` proto annotation must match the field used for authorization in `msg_server.go`.

### Missing msg_server Validation (ValidateBasic Deprecation)
In SDK v0.50+, `ValidateBasic()` is deprecated. Validate inputs directly in `msg_server.go` handlers.

### Missing Error Handler
ALL keeper method calls must check error return values. `bankKeeper.SendCoins()` errors always handled.

### AnteHandler Security
`SetUpContext` first in chain. Handle nested messages (authz `MsgExec`). Recurse into inner messages.

### IBC: Untrusted Counterparty
Validate source channel for IBC middleware/hooks acting on `sender`/`memo`.

### IBC: Channel Close Validation
`OnChanCloseInit` returns error if channels should not be closable.

### IBC: Non-deterministic JSON in Ack
Do NOT use `encoding/json` for IBC acknowledgements. Use protobuf or deterministic JSON marshaller.

### IBC: Reentrancy/CEI Violations
State mutation BEFORE external callbacks. Delete packet commitment BEFORE invoking callbacks.

### IBC: ICA Host Allow-All
`allow_messages` must be minimal whitelist, NEVER `"*"`.

## Algorand

### Rekeying Attack
Validate `Txn.rekey_to() == Global.zero_address()` in all approval logic.

### Closing Account/Asset
Validate `Txn.close_remainder_to() == Global.zero_address()` and `Txn.asset_close_to() == Global.zero_address()`.

### Group Size Check
Validate `Global.group_size()` matches expected size.

### Access Controls
`UpdateApplication`/`DeleteApplication` must check `Txn.sender() == creator/admin`.

### Asset ID Verification
All asset transfer validations include `Txn.xfer_asset() == expected_asset_id`.

### Clear State Transaction
Validate `Gtxn[i].on_completion() == OnComplete.NoOp`, not just `TxnType.ApplicationCall`.

## Substrate/FRAME

### Arithmetic Overflow
Use `checked_*`, `saturating_*`, or `overflowing_*` methods. No direct `+`, `-`, `*`, `/` on primitives in dispatchables.

### Don't Panic
No `unwrap()`, `expect()`, array indexing without bounds check, or `as` casts in dispatchables. Return `DispatchError`.

### Weights and Fees
Weight functions must account for input size. Enforce upper bounds on Vec/array parameters. Use benchmarking framework.

### Verify First, Write Last
All validation BEFORE storage writes. Use transactional storage (v0.9.25+) or `#[transactional]`.

### Bad Origin
Root-level operations use `ensure_root`. Privileged operations use custom origin types (`ForceOrigin`, `UpdateOrigin`).

## Token Integration (ERC20/ERC721)

### ERC20 Weird Patterns
Check for: missing return values (USDT, BNB), fee-on-transfer, rebasing tokens, ERC777 hooks, blocklists, upgradeability, flash minting, approval race conditions.

### Safe Transfer Pattern
Use `SafeERC20` wrapper. Verify return values. Check balance before and after transfer.

### ERC721 Issues
`safeTransferFrom` with `onERC721Received` callback reentrancy. Transfer to 0x0 should revert. `ownerOf` should revert for invalid/burned tokens.

## Code Maturity Assessment

Nine categories: Arithmetic, Auditing, Authentication/Access Controls, Complexity Management, Decentralization, Documentation, Transaction Ordering Risks, Low-Level Manipulation, Testing and Verification. Each rated WEAK/MODERATE/SATISFACTORY.
