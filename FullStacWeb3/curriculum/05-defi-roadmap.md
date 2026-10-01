# DeFi Protocol Roadmap

The project is intentionally a ladder.

## Phase 1 — Simple pool

Already included:
- token
- supply
- shares
- borrow
- repay
- basic collateral ratio

## Phase 2 — Interest

Implement:

```text
borrowRate = baseRate + utilization * slope
```

Track debt growth over time.

Questions:
- What is an index?
- What is accrued interest?
- Who receives interest?

## Phase 3 — Real collateral

Separate:
- collateral token
- debt token

Now you need an oracle.

## Phase 4 — Liquidations

Add:

```text
health factor = collateral value * liquidation threshold / debt value
```

When health factor falls below 1, liquidators can repay debt and seize collateral.

## Phase 5 — ERC-4626

Replace the custom share logic with an ERC-4626 vault.

Study:
- deposit
- mint
- withdraw
- redeem
- preview functions
- rounding
- inflation attacks

## Phase 6 — Multiple markets

Create market configuration:

```text
asset
collateral factor
liquidation threshold
reserve factor
borrow cap
supply cap
oracle
interest model
```

## Phase 7 — Governance

Add:
- roles
- timelock
- proposal system

Never let one hot wallet silently change critical risk parameters in a production system.

## Phase 8 — Production

Learn:
- multisig
- monitoring
- alerting
- pause controls
- audits
- formal verification
- bug bounties
- deployment verification
- incident response
