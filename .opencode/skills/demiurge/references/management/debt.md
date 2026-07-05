# Debt Mode

Harvests `ponytail:` comment markers into a tracked debt ledger. Every deliberate ponytail shortcut is marked with a `ponytail:` comment naming its ceiling and upgrade path.

## Scan

Grep the repo for comment markers, skipping `node_modules`, `.git`, and build output:

```
grep -rnE '(#|//) ?ponytail:' .
```

Each hit is one ledger row.

## Output Format

One row per marker, grouped by file:

```
<file>:<line>, <what was simplified>. ceiling: <the limit named>. upgrade: <the trigger to revisit>.
```

Flag the rot risk: any `ponytail:` comment that names no upgrade path or trigger gets a `no-trigger` tag. These silently rot.

End with `<N> markers, <M> with no trigger.` Nothing found: `No ponytail: debt. Clean ledger.`

## Example

```
src/cache.ts:42, global lock for rate limiting. ceiling: single-process only. upgrade: if throughput matters, switch to per-account locks.
src/utils.ts:18, O(n^2) scan for duplicates. ceiling: dataset <10k items. upgrade: if dataset grows, use index/map.
src/config.ts:7, hardcoded max retries. ceiling: never. upgrade: if configurable, move to env var.

3 markers, 1 with no trigger (src/config.ts:7).
```

## Boundaries

Reads and reports only. Changes nothing. One-shot. To persist, write to `PONYTAIL-DEBT.md`.
