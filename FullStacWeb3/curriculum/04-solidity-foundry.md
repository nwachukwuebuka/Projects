# SOLIDITY + EVM + FOUNDRY EXPERT CURRICULUM — COMPLETE MAP

This is the deepest section of the learning project.

The active contracts intentionally remain small. Topics that would make the
starter protocol too complicated are documented as commented patterns and
future exercises.

---

# PART A — SOLIDITY LANGUAGE

## 1. Pragmas

```solidity
pragma solidity ^0.8.24;
```

Understand compiler version ranges and reproducible builds.

---

## 2. Contracts

```solidity
contract StudyLend {
}
```

A contract is code + persistent storage deployed to the EVM.

---

## 3. State variables

```solidity
uint256 public totalSupplied;
```

Learn:
- storage
- visibility
- mutability
- packing

---

## 4. Data locations

Master:

```text
storage
memory
calldata
```

Example:

```solidity
function example(bytes calldata data) external {}
```

Understand why calldata is often efficient for external inputs.

---

## 5. Value vs reference types

Value types:

```text
uint
int
bool
address
bytesN
enum
```

Reference types:

```text
arrays
structs
strings
bytes
mappings
```

---

## 6. Integer types

Learn:

```solidity
uint8
uint16
...
uint256
int8
...
int256
```

Usually:

```solidity
uint256
```

is the default.

---

## 7. Arithmetic

Learn:
- overflow
- underflow
- checked arithmetic
- unchecked arithmetic

Modern Solidity checks arithmetic by default.

Legacy:

```solidity
// unchecked { ... }
```

Production:
Use `unchecked` only when the bounds are proven.

---

## 8. Fixed-point math

Solidity has no general floating-point type.

Learn scaled integers:

```text
1e18 = 1.0
5e17 = 0.5
```

Also study:
- WAD
- RAY
- basis points
- rounding

---

## 9. Rounding

Critical DeFi topic.

```solidity
uint256 result = a * b / denominator;
```

Study:
- round down
- round up
- precision loss
- multiplication before division
- overflow-safe multiplication

---

## 10. Full precision multiplication

Advanced production math:

```text
mulDiv
```

Study OpenZeppelin Math utilities and proven implementations.

Do not invent complicated fixed-point math casually.

---

## 11. Addresses

Learn:

```solidity
address
address payable
```

Also:

```solidity
msg.sender
msg.value
tx.origin
```

Never use `tx.origin` for authorization.

---

## 12. Address calls

Study:

```solidity
call
staticcall
delegatecall
```

These are advanced and dangerous.

---

## 13. ABI encoding

Learn:

```solidity
abi.encode()
abi.encodePacked()
abi.encodeWithSelector()
abi.encodeCall()
abi.decode()
```

Understand hash collisions possible with poorly constructed `abi.encodePacked`.

---

## 14. Strings and bytes

Study:

```solidity
string
bytes
bytes32
```

Understand when fixed bytes are cheaper/more convenient.

---

## 15. Arrays

```solidity
uint256[] values;
uint256[10] fixedValues;
```

Learn:
- dynamic arrays
- fixed arrays
- storage arrays
- memory arrays
- calldata arrays

---

## 16. Mappings

```solidity
mapping(address => uint256) public debt;
```

Study:
- nested mappings
- keys
- storage slots
- inability to enumerate mappings directly

---

## 17. Structs

```solidity
struct Position {
    uint256 collateral;
    uint256 debt;
}
```

Learn storage layout and packing.

---

## 18. Enums

```solidity
enum Status {
    Active,
    Paused
}
```

---

## 19. Functions

Master:

```text
public
external
internal
private
view
pure
payable
```

---

## 20. Constructors

```solidity
constructor(address asset_) {
    ...
}
```

---

## 21. Modifiers

Pattern 1:

```solidity
modifier onlyOwner() {
    require(msg.sender == owner);
    _;
}
```

Pattern 2:

Use custom errors and/or established access-control libraries.

Pattern 3:

OpenZeppelin Ownable / AccessControl.

Pattern 4:

Multisig + timelock + governance.

---

## 22. Custom errors

Modern:

```solidity
error ZeroAmount();

if (amount == 0) revert ZeroAmount();
```

Legacy:

```solidity
// require(amount > 0, "ZERO_AMOUNT");
```

---

## 23. Events

```solidity
event Supplied(
    address indexed user,
    uint256 assets,
    uint256 shares
);
```

Study:
- indexed topics
- data fields
- event logs
- off-chain indexing

---

## 24. Inheritance

```solidity
contract Child is Parent {}
```

Learn:
- virtual
- override
- abstract contracts

---

## 25. Interfaces

```solidity
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}
```

---

## 26. Libraries

Study:

```solidity
library MathLib {
}
```

Understand deployed libraries and `using for`.

---

## 27. Imports

Learn:
- relative imports
- package imports
- remappings
- dependency management

---

## 28. Constants and immutables

```solidity
uint256 public constant BPS = 10_000;
IERC20 public immutable asset;
```

Understand deployment-time vs compile-time values.

---

## 29. Receive and fallback

Study:

```solidity
receive() external payable {}
fallback() external payable {}
```

Know when each executes.

---

# PART B — EVM

## 30. EVM fundamentals

Understand:

```text
stack
memory
storage
calldata
returndata
logs
program counter
gas
```

---

## 31. Storage slots

Learn how:

```solidity
uint256 value;
mapping(address => uint256) balances;
```

map to storage.

Advanced:
Calculate mapping storage locations with `keccak256`.

---

## 32. Storage packing

Understand why variable ordering can affect gas.

---

## 33. Memory

Temporary execution memory.

---

## 34. Calldata

Read-only transaction input.

---

## 35. Stack

EVM uses a stack machine.

Study stack limits and compiler-generated code.

---

## 36. Gas

Learn:
- gas units
- gas price
- base fee
- priority fee
- gas estimation
- out-of-gas failures

---

## 37. Opcodes

Advanced:

```text
PUSH
POP
MLOAD
MSTORE
SLOAD
SSTORE
CALL
DELEGATECALL
STATICCALL
RETURN
REVERT
LOG0-LOG4
```

Use opcode knowledge to understand compiler output.

---

## 38. Contract creation

Understand:
- creation bytecode
- runtime bytecode
- constructor execution

---

## 39. Call types

Study:

```text
CALL
STATICCALL
DELEGATECALL
```

Especially understand why `delegatecall` preserves the caller's storage context.

---

## 40. Revert behavior

Learn:
- revert data
- custom errors
- panic codes
- bubbling
- low-level calls

---

# PART C — ERC STANDARDS

## 41. ERC-20

Master:
- balanceOf
- transfer
- approve
- allowance
- transferFrom
- decimals
- events

---

## 42. ERC-20 edge cases

Study:
- tokens that return false
- tokens that return no bool
- fee-on-transfer
- rebasing tokens
- blacklistable tokens
- pausable tokens

---

## 43. SafeERC20

Production pattern:

Use established SafeERC20 helpers rather than assuming every token behaves identically.

---

## 44. ERC-165

Interface detection.

---

## 45. ERC-721

NFT standard.

Understand:
- ownership
- approval
- safe transfer

---

## 46. ERC-1155

Multi-token standard.

---

## 47. ERC-4626

Extremely important for DeFi.

Study:

```text
deposit
mint
withdraw
redeem
previewDeposit
previewMint
previewWithdraw
previewRedeem
```

Also study:
- share inflation attacks
- donation attacks
- rounding

---

## 48. ERC-2612 Permit

Learn signatures that can approve without a separate approval transaction.

---

## 49. EIP-712

Typed structured data signing.

Critical for:
- permits
- off-chain authorization
- signatures

---

## 50. Account abstraction

Study:
- smart accounts
- UserOperations
- paymasters
- bundlers
- ERC-4337 concepts

---

# PART D — DEFI

## 51. Lending accounting

Study:

```text
supplied assets
shares
borrowed assets
debt
collateral
LTV
liquidation threshold
health factor
utilization
```

---

## 52. Interest rates

Typical simplified model:

```text
borrowRate = baseRate + utilization * slope
```

Advanced:
- kinked curves
- jump rates
- supply APR
- borrow APR
- reserve factor

---

## 53. Interest indexes

Learn:
- borrow index
- supply index
- scaled balances
- time-based accrual

---

## 54. Oracles

Study:
- spot price
- TWAP
- Chainlink-style feeds
- oracle heartbeat
- stale data
- decimals
- price bounds

---

## 55. Oracle manipulation

Understand:
- flash-loan price manipulation
- low-liquidity markets
- stale prices
- sandwiching
- incorrect decimals

---

## 56. Liquidations

Learn:

```text
health factor
liquidation threshold
liquidation bonus
close factor
bad debt
```

---

## 57. Flash loans

Understand:
- uncollateralized atomic borrowing
- same-transaction repayment
- attack surfaces
- legitimate arbitrage

---

## 58. AMMs

Even though StudyLend is a lending protocol, learn:

```text
constant product
x * y = k
liquidity
LP tokens
slippage
price impact
```

---

## 59. DEX routing

Study:
- swaps
- routes
- aggregators
- slippage limits
- deadlines

---

## 60. Stablecoins

Learn:
- overcollateralized
- fiat-backed
- crypto-backed
- algorithmic designs
- depegging risk

---

## 61. Vaults

Study:
- deposits
- shares
- yield
- strategies
- harvest
- fees

---

## 62. Protocol fees

Study:
- reserve factor
- performance fee
- withdrawal fee
- treasury
- fee accounting

---

# PART E — SECURITY

## 63. Reentrancy

Classic vulnerable pattern:

```solidity
// BAD EDUCATIONAL EXAMPLE:
//
// uint256 amount = balances[msg.sender];
// (bool ok,) = msg.sender.call{value: amount}("");
// balances[msg.sender] = 0;
```

Pattern 2:

```text
Checks
Effects
Interactions
```

Pattern 3:

ReentrancyGuard.

Pattern 4:

Design the protocol so dangerous external interactions are minimized and
state invariants remain correct even under reentrant calls.

---

## 64. Checks-effects-interactions

Memorize:

```text
CHECK
  ↓
EFFECT
  ↓
INTERACTION
```

But understand that CEI is not a complete security strategy.

---

## 65. Access control

Study:
- Ownable
- AccessControl
- multisigs
- timelocks
- governance

---

## 66. Oracle attacks

Study extensively before implementing real collateral.

---

## 67. Precision attacks

Study:
- rounding
- share price
- dust
- division by zero
- truncation

---

## 68. Donation attacks

Important for vaults.

---

## 69. Front-running

Learn:
- mempool
- MEV
- sandwich attacks
- transaction ordering

---

## 70. Commit-reveal

Study as one possible mitigation for some ordering-sensitive designs.

---

## 71. Denial of service

Learn:
- unbounded loops
- gas griefing
- malicious tokens
- failed external calls
- storage bloat

---

## 72. Timestamp dependence

Understand:

```solidity
block.timestamp
```

It is not a perfect clock.

---

## 73. Randomness

Do not assume:

```solidity
uint256(block.timestamp)
```

is secure randomness.

Study verifiable randomness.

---

## 74. Delegatecall hazards

Study storage collisions, authorization and upgrade risks.

---

## 75. Proxy patterns

Learn:

```text
Transparent Proxy
UUPS
Beacon
Diamond
```

Then understand why upgradeability increases complexity.

---

## 76. Selfdestruct history

Understand changing EVM semantics and why historical tutorials may be misleading.

---

## 77. Denial through token behavior

Consider tokens that:
- revert
- return false
- charge fees
- rebase
- change balances

---

# PART F — FOUNDRY

## 78. Project setup

```bash
forge init
forge build
forge test
```

---

## 79. forge build

Compile contracts.

---

## 80. forge test

Run tests.

```bash
forge test -vv
forge test -vvvv
```

---

## 81. Test setup

```solidity
function setUp() public {
}
```

---

## 82. Cheatcodes

Study:

```text
vm.prank
vm.startPrank
vm.stopPrank
vm.expectRevert
vm.expectEmit
vm.warp
vm.roll
vm.deal
vm.assume
bound
```

---

## 83. Assertions

Learn:

```text
assertEq
assertTrue
assertFalse
assertGt
assertGe
assertLt
assertLe
```

---

## 84. Revert testing

```solidity
vm.expectRevert(MyError.selector);
```

---

## 85. Event testing

```solidity
vm.expectEmit(true, true, false, true);
emit Supplied(alice, amount, shares);
```

---

## 86. Fuzz testing

```solidity
function testFuzzSomething(uint256 amount) public {
}
```

Learn:
- random inputs
- bounds
- assumptions
- shrinking

---

## 87. Invariant testing

Think in properties:

```text
totalBorrowed <= totalSupplied
```

Test sequences rather than one transaction.

---

## 88. Fork testing

Study:

```bash
forge test --fork-url $RPC_URL
```

Use real chain state carefully.

---

## 89. Scripts

```solidity
contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        ...
        vm.stopBroadcast();
    }
}
```

---

## 90. Broadcasting

Learn:
- RPC URLs
- private keys
- environment variables
- broadcast records

Never commit private keys.

---

## 91. Verification

Learn contract verification on supported explorers.

---

## 92. Gas snapshots

Study:

```bash
forge snapshot
```

Compare gas changes.

---

## 93. Traces

Use:

```bash
forge test -vvvv
```

to understand execution.

---

## 94. Coverage

Learn:

```bash
forge coverage
```

Coverage is useful but is not proof of security.

---

## 95. Static analysis

Know:
- Slither
- Mythril
- compiler warnings
- formatting/linting

---

## 96. Formal verification

Study:
- invariants
- symbolic execution
- SMT
- theorem proving
- Certora-style approaches

---

# PART G — PROTOCOL ARCHITECTURE

## 97. Separation of concerns

Eventually split:

```text
Pool
Market
Oracle
InterestRateModel
LiquidationEngine
FeeController
AccessController
```

---

## 98. Upgradeability

Ask:
- Why upgrade?
- Who can upgrade?
- How quickly?
- Can users exit?
- Is storage compatible?

---

## 99. Governance

Study:
- proposal
- voting
- quorum
- timelock
- execution

---

## 100. Emergency controls

Learn:
- pause
- guardian
- emergency withdrawal
- caps
- circuit breakers

---

## 101. Protocol invariants

Write them before writing complex code.

Examples:

```text
totalBorrowed <= totalSupplied
debt[user] >= 0
shares[user] <= totalShares
```

For a real protocol, define a much larger invariant set.

---

# PART H — STUDYLEND ADVANCED PROJECTS

## Project 1

Add `withdrawCollateral()` safely.

## Project 2

Add interest accrual.

## Project 3

Separate collateral and debt assets.

## Project 4

Integrate a price oracle.

## Project 5

Add liquidation.

## Project 6

Add an ERC-4626 vault.

## Project 7

Add multiple markets.

## Project 8

Add protocol fees.

## Project 9

Add role-based administration.

## Project 10

Add pause/emergency controls.

## Project 11

Add fuzz and invariant suites.

## Project 12

Add fork tests.

## Project 13

Build a TypeScript frontend.

## Project 14

Add event indexing.

## Project 15

Perform a self-audit.

---

# SECURITY RULE

The fact that code compiles, tests pass, and a local deployment works does NOT
mean a DeFi protocol is safe.

Production readiness requires threat modeling, extensive testing, independent
review/audit, monitoring, operational controls and a carefully constrained
deployment.
