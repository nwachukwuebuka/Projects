# DeFi Learning Lab — HTML + CSS + JavaScript + Solidity/Foundry

A deliberately educational DeFi protocol project designed so you can learn the frontend and smart-contract stack together.

## What you will build

This project is a small lending/borrowing protocol called **StudyLend**:

- Users deposit an ERC-20 asset into a pool.
- Users receive pool shares.
- Users can borrow against collateral.
- Users repay loans.
- Users can withdraw supplied liquidity.
- The frontend reads contract state and sends transactions.
- Foundry tests cover the Solidity protocol.
- Every important concept has comments and "Pattern" sections.

> Educational project. Do not deploy this code with real funds without a professional security review.

## Learning philosophy

For important operations, this repository shows several approaches:

- **Pattern 1 — Legacy:** an older/common way, often commented out.
- **Pattern 2 — Recommended:** the modern approach used by the project.
- **Pattern 3 — Alternative:** another valid approach and when you might use it.
- **Pattern 4 — Production note:** the additional engineering/security concern you should learn next.

The legacy examples are intentionally commented out so the project still compiles.

## Curriculum map

### HTML
See `curriculum/01-html.md` for the expanded expert curriculum: document structure, semantic HTML, forms, tables, lists, images, responsive images, audio, video, captions/WebVTT, transcripts, iframe, dialog, details/summary, progress/meter, SVG, canvas, templates, accessibility, ARIA, metadata, security, SEO, performance, internationalization, progressive enhancement and Web Components.

### CSS
See `curriculum/02-css.md` for the expanded expert curriculum: selectors, cascade, specificity, inheritance, box model, sizing, units, typography, fonts, backgrounds, borders, display, positioning, Flexbox, Grid, subgrid, container queries, responsive design, logical properties, forms, animations, transitions, accessibility, themes, layers, nesting, math functions, modern CSS, architecture, frameworks, preprocessors, performance and DevTools.

### JavaScript
See `curriculum/03-javascript.md` for the expanded expert curriculum: language fundamentals, scope/closures, objects/prototypes, arrays, modules, DOM, events, forms, Fetch, async programming, Promise combinators, browser APIs, storage, Web Crypto, workers, WebSockets, security, Web3 providers, ethers, ABI encoding, contract reads/writes, events, state management, TypeScript, testing, build tools, performance and DevTools.

### Solidity + Foundry
See `curriculum/04-solidity-foundry.md` for the expanded expert curriculum: Solidity language, storage/memory/calldata, arithmetic and rounding, ABI, EVM internals, gas, calls, ERC standards, ERC-4626, permits/EIP-712, account abstraction, lending, interest, oracles, liquidations, AMMs, stablecoins, vaults, protocol fees, reentrancy, access control, MEV, upgradeability, governance, Foundry tests, fuzzing, invariants, fork testing, gas snapshots, coverage, static analysis and formal verification.

## Run it

### 1. Install Foundry

Install Foundry from the official documentation:
https://book.getfoundry.sh/

Then:

```bash
forge --version
cast --version
anvil --version
```

### 2. Run the smart-contract tests

```bash
cd foundry
forge test -vv
```

For more detail:

```bash
forge test -vvvv
```

### 3. Start a local chain

In terminal 1:

```bash
cd foundry
anvil
```

Keep Anvil running.

### 4. Deploy locally

In terminal 2:

```bash
cd foundry
forge script script/Deploy.s.sol:Deploy \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast
```

Copy the deployed addresses into `frontend/src/config.js`.

### 5. Run the frontend

From `frontend/` you can use any static server. For example:

```bash
cd frontend
python3 -m http.server 5173
```

Open:

http://127.0.0.1:5173

The frontend is intentionally dependency-light: plain HTML, CSS and browser JavaScript.

## Study order

Do not try to memorize everything.

1. Read `frontend/index.html`.
2. Read `frontend/src/styles.css`.
3. Read `frontend/src/main.js`.
4. Read `foundry/src/StudyToken.sol`.
5. Read `foundry/src/StudyLend.sol`.
6. Run `forge test`.
7. Change one contract function.
8. Add a test for the change.
9. Update the frontend to expose the feature.
10. Repeat.

## Pattern rule

When you encounter a major concept, look for:

```text
PATTERN 1 — LEGACY
PATTERN 2 — RECOMMENDED
PATTERN 3 — ALTERNATIVE
PATTERN 4 — PRODUCTION
```

Not every operation has four genuinely different forms. Where there is no meaningful fourth implementation, the comments explain why.

## Suggested progression

### Level 1 — Web foundations
- HTML sections
- CSS layout
- JS DOM events

### Level 2 — Web3 foundations
- wallet connection
- chain ID
- addresses
- ABI
- read vs write calls
- transaction lifecycle

### Level 3 — Solidity foundations
- storage
- mappings
- structs
- events
- custom errors
- modifiers

### Level 4 — DeFi accounting
- shares
- collateral
- debt
- utilization
- interest model

### Level 5 — Security
- reentrancy
- checks-effects-interactions
- oracle manipulation
- rounding
- approval/allowance
- flash-loan assumptions
- access control

### Level 6 — Foundry mastery
- unit tests
- fuzz tests
- invariant tests
- scripts
- local deployment
- traces

### Level 7 — Production engineering
- OpenZeppelin
- oracle integrations
- upgradeability trade-offs
- monitoring
- formal verification
- audits
- mainnet deployment

## Important limitations

This is a learning protocol, not a production money market.

The demo deliberately uses simplified assumptions:

- One lending asset.
- One collateral asset.
- A simplified oracle.
- A simplified interest model.
- No liquidation auction.
- No flash-loan defense beyond basic accounting.
- No governance.
- No upgradeability.
- No production oracle integration.

Those omissions are intentional: each is a future lesson.
