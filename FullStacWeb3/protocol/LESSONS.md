# Curriculum checkpoints

Use this file as your checklist.

## HTML

- [ ] Document structure
- [ ] `<!DOCTYPE html>`
- [ ] `<html lang="">`
- [ ] `<head>`
- [ ] metadata
- [ ] semantic sections
- [ ] header
- [ ] nav
- [ ] main
- [ ] section
- [ ] article
- [ ] aside
- [ ] footer
- [ ] headings
- [ ] paragraphs
- [ ] links
- [ ] buttons
- [ ] forms
- [ ] labels
- [ ] inputs
- [ ] validation attributes
- [ ] tables
- [ ] accessibility
- [ ] `aria-label`
- [ ] `aria-live`
- [ ] `data-*` attributes
- [ ] script modules
- [ ] SEO basics

## CSS

- [ ] selectors
- [ ] classes
- [ ] specificity
- [ ] cascade
- [ ] inheritance
- [ ] box model
- [ ] width/height
- [ ] margin/padding
- [ ] border
- [ ] display
- [ ] block/inline
- [ ] flexbox
- [ ] grid
- [ ] gap
- [ ] position
- [ ] sticky
- [ ] z-index
- [ ] variables
- [ ] pseudo-classes
- [ ] pseudo-elements
- [ ] transitions
- [ ] transforms
- [ ] animations
- [ ] media queries
- [ ] responsive design
- [ ] dark UI
- [ ] focus states
- [ ] reduced motion
- [ ] component architecture

## JavaScript

- [ ] `let` / `const`
- [ ] primitive values
- [ ] objects
- [ ] arrays
- [ ] functions
- [ ] arrow functions
- [ ] scope
- [ ] closures
- [ ] conditions
- [ ] loops
- [ ] array methods
- [ ] destructuring
- [ ] spread/rest
- [ ] template literals
- [ ] modules
- [ ] imports
- [ ] exports
- [ ] DOM selection
- [ ] DOM manipulation
- [ ] event listeners
- [ ] form submission
- [ ] validation
- [ ] browser events
- [ ] promises
- [ ] async/await
- [ ] try/catch
- [ ] errors
- [ ] JSON
- [ ] fetch
- [ ] localStorage
- [ ] timers
- [ ] BigInt
- [ ] browser wallet API
- [ ] ethers.js
- [ ] contract reads
- [ ] contract writes
- [ ] transactions
- [ ] events
- [ ] logs
- [ ] RPC

## Solidity

- [ ] contract syntax
- [ ] SPDX
- [ ] pragma
- [ ] state variables
- [ ] visibility
- [ ] constructors
- [ ] functions
- [ ] modifiers
- [ ] custom errors
- [ ] events
- [ ] mappings
- [ ] arrays
- [ ] structs
- [ ] interfaces
- [ ] inheritance
- [ ] libraries
- [ ] payable
- [ ] `msg.sender`
- [ ] `msg.value`
- [ ] ETH transfers
- [ ] ERC-20
- [ ] mint
- [ ] burn
- [ ] allowance
- [ ] `transferFrom`
- [ ] access control
- [ ] CEI
- [ ] reentrancy
- [ ] oracle integration
- [ ] decimal scaling
- [ ] health factor
- [ ] collateral ratio
- [ ] liquidation
- [ ] gas
- [ ] storage
- [ ] memory
- [ ] calldata
- [ ] external calls
- [ ] fuzz tests
- [ ] invariant tests
- [ ] fork tests
- [ ] deployment scripts

## Advanced exercises

### Exercise 1
Add an ERC-20 allowance system to ZVUSD:

- approve
- allowance
- transferFrom

Then change liquidation/repayment flows to use `transferFrom`.

### Exercise 2
Add a stale-price check.

Use `updatedAt` from the oracle.

Reject prices older than your chosen timeout.

### Exercise 3
Add a liquidation threshold distinct from the minimum collateral ratio.

### Exercise 4
Prevent self-liquidation.

### Exercise 5
Add multiple collateral assets.

### Exercise 6
Add protocol fees.

### Exercise 7
Add interest accrual.

### Exercise 8
Add an indexer.

Store events in a local database and expose historical activity efficiently.

### Exercise 9
Build charts from indexed data.

### Exercise 10
Migrate the UI to React.

### Exercise 11
Replace the CSS system with Tailwind.

### Exercise 12
Move the application to Next.js.

The goal is not simply to finish these checkboxes.

The goal is to understand why each layer exists.
