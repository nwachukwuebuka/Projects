# Exercise 04 — Solidity

1. Implement `withdrawCollateral`.
2. Add an interest index.
3. Add a `repay()` test for the exact debt amount.
4. Add fuzz tests around LTV.
5. Add a test proving a borrower cannot withdraw unsafe collateral.
6. Add a pause mechanism.
7. Add access control for risk parameters.

Security challenge:
Write a test that would fail if the contract accidentally updated accounting after an external token call.
