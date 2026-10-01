# Zhevezius DeFi — Full-Stack Web3 Learning Protocol

A deliberately educational DeFi protocol built from scratch with:

- Solidity + Foundry for the smart contracts
- HTML5 for the page structure
- CSS3 for layout, responsive design, animations, and UI states
- Vanilla JavaScript for DOM manipulation, application state, async code, modules, and Web3 integration
- ethers.js for browser-to-wallet/contract communication

Later, this project can be migrated to Tailwind CSS, React, and Next.js without throwing away the protocol concepts.

> This is a learning protocol, NOT production-ready financial software. Do not deploy it with real funds.

---

## 1. What you will build

The project is a small lending/borrowing DeFi protocol:

1. Users deposit ETH as collateral.
2. The protocol values collateral using a Chainlink-style price feed interface.
3. Users can mint ZVUSD against their collateral.
4. A minimum collateral ratio protects the protocol.
5. Users can repay ZVUSD.
6. Users can redeem collateral after repaying enough debt.
7. A liquidator can cover an unhealthy borrower's debt and receive collateral plus a bonus.
8. The frontend displays balances, collateral, debt, health factor and protocol state.
9. JavaScript listens for contract events and refreshes the UI.
10. Foundry tests cover normal behavior, reverts, access control, fuzzing and invariants.

---

## 2. Folder structure

```text
web3-defi-learning-protocol/
├── src/
│   ├── core/
│   │   ├── ZVUSD.sol
│   │   └── DeFiVault.sol
│   ├── interfaces/
│   │   └── AggregatorV3Interface.sol
│   └── mocks/
│       └── MockV3Aggregator.sol
├── test/
│   ├── unit/
│   │   └── DeFiVault.t.sol
│   ├── invariant/
│   │   └── DeFiVault.invariant.t.sol
│   └── mocks/
│       └── Handler.sol
├── script/
│   └── Deploy.s.sol
├── frontend/
│   ├── index.html
│   ├── css/
│   │   ├── reset.css
│   │   ├── variables.css
│   │   ├── layout.css
│   │   ├── components.css
│   │   └── responsive.css
│   ├── js/
│   │   ├── config.js
│   │   ├── state.js
│   │   ├── utils.js
│   │   ├── abi.js
│   │   ├── web3.js
│   │   ├── ui.js
│   │   ├── events.js
│   │   └── app.js
│   └── assets/
├── foundry.toml
└── README.md
```

---

# 3. Prerequisites

Install:

- VS Code
- Git
- WSL/Ubuntu if you prefer Linux on Windows
- Foundry
- Node.js (only for the frontend's local development server/package tooling if you choose to add it later)
- MetaMask or another EVM wallet

You do NOT need Hardhat.
You do NOT need Remix.

The smart-contract side is intentionally Foundry-only.

---

# 4. Run the Solidity project

Open VS Code in this project:

```bash
cd web3-defi-learning-protocol
```

Then:

```bash
forge build
```

Run tests:

```bash
forge test
```

More verbose:

```bash
forge test -vvv
```

Format Solidity:

```bash
forge fmt
```

Run only unit tests:

```bash
forge test --match-path test/unit/DeFiVault.t.sol
```

Run invariant tests:

```bash
forge test --match-path test/invariant/DeFiVault.invariant.t.sol
```

---

# 5. Start a local blockchain

Terminal 1:

```bash
anvil
```

Keep this terminal running.

Anvil prints test accounts and private keys. Import one of the test accounts into your local wallet if you want to interact through the browser.

---

# 6. Deploy

Terminal 2:

```bash
forge script script/Deploy.s.sol:Deploy \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast
```

The deployment script prints contract addresses.

Copy the deployed addresses into:

```text
frontend/js/config.js
```

Example:

```js
export const CONTRACTS = {
    vault: "0x...",
    zvusd: "0x..."
};
```

---

# 7. Run the frontend

Do NOT double-click `index.html`.

Because ES modules and wallet APIs work better from an HTTP origin, run a local server.

If Python is installed:

```bash
cd frontend
python3 -m http.server 5500
```

Then open:

```text
http://127.0.0.1:5500
```

Alternatively use VS Code's Live Server extension.

---

# 8. Connect your wallet

In MetaMask:

1. Add the local Anvil network:
   - Network name: Anvil Local
   - RPC URL: http://127.0.0.1:8545
   - Chain ID: 31337
   - Currency symbol: ETH
2. Import one of Anvil's private keys.
3. Open the frontend.
4. Click Connect Wallet.

---

# 9. Learning path

Do not rush to React.

### HTML curriculum

Study:

- document structure
- semantic HTML
- headings
- paragraphs
- links
- images
- buttons
- forms
- inputs
- labels
- select
- textarea
- tables
- lists
- `data-*` attributes
- accessibility
- ARIA where appropriate
- forms and validation
- semantic sections
- responsive meta tags
- script loading
- module scripts

### CSS curriculum

Study:

- selectors
- specificity
- inheritance
- box model
- display
- positioning
- flexbox
- grid
- media queries
- pseudo-classes
- pseudo-elements
- CSS variables
- typography
- spacing
- borders
- shadows
- transitions
- transforms
- animations
- responsive design
- component styling
- state classes
- accessibility considerations
- reduced-motion preferences

### JavaScript curriculum

Study:

- variables
- primitive types
- objects
- arrays
- functions
- arrow functions
- scope
- closures
- conditionals
- loops
- array methods
- destructuring
- spread/rest
- template literals
- modules
- DOM selection
- DOM creation
- events
- event delegation
- forms
- validation
- local state
- localStorage
- JSON
- promises
- async/await
- try/catch
- fetch
- errors
- timers
- BigInt
- browser APIs
- Web3 providers
- wallet connection
- contract reads
- contract writes
- transaction lifecycle
- event listeners

### Solidity curriculum

Study:

- SPDX and pragma
- contracts
- state variables
- visibility
- constructors
- functions
- modifiers
- custom errors
- events
- structs
- mappings
- arrays
- enums
- inheritance
- interfaces
- libraries
- `msg.sender`
- `msg.value`
- `msg.data`
- `block.timestamp`
- payable functions
- ETH transfers
- ERC-20 concepts
- approvals
- `transferFrom`
- access control
- checks-effects-interactions
- reentrancy
- oracle reads
- fixed-point arithmetic
- precision
- health factors
- liquidation
- fuzz testing
- invariant testing
- gas
- storage
- calldata
- memory
- external calls
- deployment scripts

---

# 10. Suggested study order

### Phase 1 — Read the HTML

Open:

```text
frontend/index.html
```

Understand every element before changing the CSS.

### Phase 2 — Learn CSS

Open:

```text
frontend/css/
```

Start with:

1. reset.css
2. variables.css
3. layout.css
4. components.css
5. responsive.css

### Phase 3 — Learn JavaScript without Web3

Start with:

```text
frontend/js/state.js
frontend/js/utils.js
frontend/js/ui.js
```

Then study:

```text
app.js
```

### Phase 4 — Learn Web3 JavaScript

Study:

```text
config.js
abi.js
web3.js
events.js
```

### Phase 5 — Learn Solidity

Study:

```text
src/core/ZVUSD.sol
src/core/DeFiVault.sol
```

Then:

```text
test/unit/DeFiVault.t.sol
```

Finally:

```text
test/invariant/DeFiVault.invariant.t.sol
```

### Phase 6 — Full-stack flow

Understand:

```text
HTML
 ↓
CSS
 ↓
JavaScript
 ↓
ethers.js
 ↓
wallet
 ↓
RPC
 ↓
EVM
 ↓
Solidity contract
 ↓
event/log
 ↓
JavaScript
 ↓
DOM update
```

---

# 11. Important architecture lesson

The frontend does NOT permanently store blockchain history.

The blockchain stores contract state and transaction/event logs.

Your frontend can query:

- current state with contract view functions
- historical events through RPC/provider log queries

For serious production applications, an indexing system such as a subgraph or custom indexer is normally used when you need efficient historical queries.

That will be a later advanced phase.

---

# 12. Advanced upgrades you should eventually implement

After understanding this version, add:

1. ERC-20 permit
2. OpenZeppelin AccessControl
3. OpenZeppelin ReentrancyGuard
4. OpenZeppelin ERC20
5. Chainlink price feeds
6. stale-price protection
7. multiple collateral assets
8. multiple price feeds
9. debt ceilings
10. protocol fees
11. liquidation auctions
12. interest accrual
13. utilization rate
14. borrow rate
15. reserve factor
16. treasury
17. governance
18. timelock
19. emergency pause
20. oracle circuit breaker
21. flash-loan resistance analysis
22. fuzz testing
23. invariant testing
24. fork testing
25. gas optimization
26. frontend transaction queue
27. transaction history
28. indexed event history
29. charts
30. wallet network switching
31. mobile responsive UI
32. React migration
33. Tailwind migration
34. Next.js migration

---

# 13. The React/Next/Tailwind migration

Do this only after you understand the vanilla version.

The protocol should remain conceptually the same.

You will replace:

```text
HTML → React components
CSS → Tailwind
manual DOM state → React state
app.js → React hooks/components
```

Then Next.js can handle:

- application routing
- server/client boundaries
- production structure
- metadata
- API routes when needed
- optimized frontend architecture

You should NOT learn these frameworks by hiding the underlying HTML/CSS/JS concepts.

---

# 14. Security warning

This implementation is intentionally educational.

Before any real deployment, a protocol needs significantly more:

- formal threat modeling
- robust oracle design
- access-control review
- reentrancy analysis
- economic attack analysis
- invariant design
- fuzzing
- fork testing
- external audit
- deployment controls
- monitoring
- emergency procedures

Never treat an educational lending protocol as safe for real money.
