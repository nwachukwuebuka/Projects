# Study Notes

## The full stack mental model

```text
HTML
  ↓
CSS
  ↓
JavaScript
  ↓
Wallet
  ↓
RPC
  ↓
ABI
  ↓
Solidity contract
  ↓
EVM storage/events
```

### When you click Supply

1. HTML captures the form.
2. JavaScript validates the amount.
3. JavaScript converts the human amount into base units.
4. JavaScript checks ERC-20 allowance.
5. Wallet signs `approve()` if needed.
6. JavaScript waits for confirmation.
7. JavaScript sends `supply()`.
8. Wallet signs the transaction.
9. The EVM executes Solidity.
10. The token moves.
11. StudyLend updates accounting.
12. StudyLend emits `Supplied`.
13. JavaScript waits for the receipt.
14. JavaScript reads fresh state.
15. HTML updates the dashboard.

That chain is the core idea of full-stack Web3 development.

## Questions to ask while studying

### HTML
"What does this element mean?"

### CSS
"Which layout algorithm is controlling this?"

### JavaScript
"What data type am I holding, and is this operation asynchronous?"

### Solidity
"What invariant must always remain true?"

### Foundry
"How do I prove that invariant with a test?"

### DeFi
"Where does the money/accounting risk enter the system?"

## Recommended daily loop

1. Read one file.
2. Run the code.
3. Change one thing.
4. Break it intentionally.
5. Read the compiler/test error.
6. Fix it.
7. Add a test.
8. Explain the change in your own words.

Do this repeatedly instead of trying to memorize syntax.
