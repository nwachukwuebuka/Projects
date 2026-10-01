// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20Minimal} from "./IERC20Minimal.sol";

/*
  STUDYLEND — EDUCATIONAL LENDING POOL

  Core model:

  Liquidity providers:
      assets -> pool -> shares

  Borrowers:
      collateral -> pool -> debt

  This is NOT a production lending protocol.

  ------------------------------------------------------------
  PATTERN 1 — LEGACY
  ------------------------------------------------------------

  Older Solidity commonly used:
      require(condition, "message");

  Example:

      // require(amount > 0, "ZERO_AMOUNT");

  This is still valid.

  ------------------------------------------------------------
  PATTERN 2 — RECOMMENDED
  ------------------------------------------------------------

  Custom errors:

      if (amount == 0) revert ZeroAmount();

  Benefits:
  - cheaper than long revert strings
  - easier to standardize
  - easier for clients to decode

  ------------------------------------------------------------
  PATTERN 3 — ALTERNATIVE
  ------------------------------------------------------------

  OpenZeppelin Contracts can provide standard ERC-20 and access-control
  implementations rather than writing them yourself.

  ------------------------------------------------------------
  PATTERN 4 — PRODUCTION
  ------------------------------------------------------------

  A real lending market needs much more:
  - robust oracle design
  - liquidation mechanics
  - interest accrual
  - bad-debt handling
  - caps
  - pause/emergency controls
  - isolation modes
  - market configuration
  - governance
  - extensive invariant testing
  - audits
*/

contract StudyLend {
    IERC20Minimal public immutable asset;

    // Pool accounting.
    uint256 public totalSupplied;
    uint256 public totalBorrowed;

    // User accounting.
    mapping(address => uint256) public userShares;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;

    uint256 public constant BPS = 10_000;
    uint256 public constant MAX_BORROW_BPS = 5_000; // 50% LTV for the lesson.

    error ZeroAmount();
    error InsufficientShares();
    error InsufficientLiquidity();
    error BorrowTooLarge();
    error RepayTooLarge();
    error TransferFailed();
    error UnsafeWithdrawal();
    error ZeroAddress();

    event Supplied(address indexed user, uint256 assets, uint256 shares);
    event Withdrawn(address indexed user, uint256 assets, uint256 shares);
    event Borrowed(address indexed user, uint256 collateralAmount, uint256 debtAmount);
    event Repaid(address indexed user, uint256 amount);

    constructor(IERC20Minimal asset_) {
        if (address(asset_) == address(0)) revert ZeroAddress();
        asset = asset_;
    }

    /*
      SHARE ACCOUNTING

      First deposit:
          shares = assets

      Later deposits:
          shares = assets * totalShares / totalAssets

      This is the same general idea used by many vault designs.

      PATTERN 1 — LEGACY:
          if (totalSupplied == 0) { ... }

      PATTERN 2 — RECOMMENDED:
          Keep conversion math in dedicated functions.

      PATTERN 3 — ALTERNATIVE:
          Use an ERC-4626 vault implementation.

      PATTERN 4 — PRODUCTION:
          Study ERC-4626 inflation/donation attacks and rounding direction.
    */
    function convertToShares(uint256 assets) public view returns (uint256) {
        if (totalSupplied == 0) return assets;
        return assets * totalShares() / totalSupplied;
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        uint256 sharesTotal = totalShares();

        if (sharesTotal == 0) return 0;

        return shares * totalSupplied / sharesTotal;
    }

    function totalShares() public view returns (uint256) {
        // This educational implementation derives total shares from balances.
        // A production vault normally stores total shares explicitly.
        return _totalShares;
    }

    uint256 private _totalShares;

    /*
      SUPPLY

      CEI = Checks → Effects → Interactions

      PATTERN 1 — LEGACY:
      It is common in old examples to perform an external token transfer
      before updating local accounting.

      PATTERN 2 — RECOMMENDED:
      Calculate/check first, update accounting, then interact.

      Note: standard ERC-20 transferFrom itself is an external call, so the
      safest production implementation also considers reentrancy and token
      behavior. This demo keeps the contract simple and tests its assumptions.
    */
    function supply(uint256 assets) external returns (uint256 shares) {
        if (assets == 0) revert ZeroAmount();

        shares = convertToShares(assets);
        if (shares == 0) revert ZeroAmount();

        // Effects.
        totalSupplied += assets;
        _totalShares += shares;
        userShares[msg.sender] += shares;

        // Interaction.
        bool success = asset.transferFrom(msg.sender, address(this), assets);
        if (!success) revert TransferFailed();

        emit Supplied(msg.sender, assets, shares);
    }

    /*
      WITHDRAW

      A share represents a proportional claim on supplied assets.

      Important lesson:
      "shares" and "assets" are not necessarily the same number.
    */
    function withdraw(uint256 shares) external returns (uint256 assets) {
        if (shares == 0) revert ZeroAmount();
        if (userShares[msg.sender] < shares) revert InsufficientShares();

        assets = convertToAssets(shares);

        // Keep enough liquidity for borrowers.
        uint256 available = totalSupplied - totalBorrowed;
        if (assets > available) revert InsufficientLiquidity();

        // Effects first.
        userShares[msg.sender] -= shares;
        _totalShares -= shares;
        totalSupplied -= assets;

        // Interaction.
        bool success = asset.transfer(msg.sender, assets);
        if (!success) revert TransferFailed();

        emit Withdrawn(msg.sender, assets, shares);
    }

    /*
      BORROW

      Simplified risk model:
          maximum debt = collateral * 50%

      This intentionally uses the same asset as collateral and debt so the
      learning model has no oracle dependency.

      A real protocol would not assume collateral and debt have the same
      price. It would use a robust oracle and risk parameters.
    */
    function borrow(uint256 collateralAmount, uint256 debtAmount) external {
        if (collateralAmount == 0 || debtAmount == 0) revert ZeroAmount();

        uint256 available = totalSupplied - totalBorrowed;
        if (debtAmount > available) revert InsufficientLiquidity();

        uint256 newCollateral = collateral[msg.sender] + collateralAmount;
        uint256 newDebt = debt[msg.sender] + debtAmount;

        if (newDebt * BPS > newCollateral * MAX_BORROW_BPS) {
            revert BorrowTooLarge();
        }

        // Effects.
        collateral[msg.sender] = newCollateral;
        debt[msg.sender] = newDebt;
        totalBorrowed += debtAmount;

        // Interaction.
        bool success = asset.transferFrom(msg.sender, address(this), collateralAmount);
        if (!success) revert TransferFailed();

        success = asset.transfer(msg.sender, debtAmount);
        if (!success) revert TransferFailed();

        emit Borrowed(msg.sender, collateralAmount, debtAmount);
    }

    /*
      REPAY

      PATTERN 1 — LEGACY:
          require(amount <= debt[msg.sender], "TOO MUCH");

      PATTERN 2 — RECOMMENDED:
          custom error + explicit effects + interaction.

      PATTERN 3 — ALTERNATIVE:
          Permit-style approvals can reduce the number of user transactions.

      PATTERN 4 — PRODUCTION:
          Interest makes repayment more complex because debt grows over time.
    */
    function repay(uint256 amount) external {
        if (amount == 0) revert ZeroAmount();
        if (amount > debt[msg.sender]) revert RepayTooLarge();

        // Effects.
        debt[msg.sender] -= amount;
        totalBorrowed -= amount;

        // Interaction.
        bool success = asset.transferFrom(msg.sender, address(this), amount);
        if (!success) revert TransferFailed();

        emit Repaid(msg.sender, amount);
    }

    /*
      COLLATERAL WITHDRAWAL IS INTENTIONALLY OMITTED.

      This is a useful lesson:
      adding a function is not enough. You must define and enforce the
      solvency invariant before allowing users to remove collateral.

      Exercise:
      Implement withdrawCollateral() with:
          remainingCollateral * MAX_BORROW_BPS >= debt * BPS
    */

    function utilizationBps() public view returns (uint256) {
        if (totalSupplied == 0) return 0;
        return totalBorrowed * BPS / totalSupplied;
    }

    function shareValue(uint256 shares) external view returns (uint256) {
        return convertToAssets(shares);
    }
}


/*
=============================================================
STUDY MODE — "YOU CAN ALSO DO IT THIS WAY"
=============================================================

Whenever you modify this file, keep this convention:

PATTERN 1 — LEGACY
------------------
Show the older/common approach in comments.

PATTERN 2 — CURRENT / RECOMMENDED
---------------------------------
Keep the approach actually used by the project.

PATTERN 3 — ALTERNATIVE
-----------------------
Comment another valid implementation and explain the trade-off.

PATTERN 4 — PRODUCTION
----------------------
Comment what a serious production system would additionally require.

Example JavaScript:

// PATTERN 1 — LEGACY
// button.onclick = handleClick;

// PATTERN 2 — CURRENT
// button.addEventListener("click", handleClick);

// PATTERN 3 — ALTERNATIVE
// event delegation can be better for many dynamic buttons.

// PATTERN 4 — PRODUCTION
// centralize UI state and handle loading/error/disabled states.

Example Solidity:

// PATTERN 1 — LEGACY
// require(amount > 0, "ZERO");

// PATTERN 2 — CURRENT
// if (amount == 0) revert ZeroAmount();

// PATTERN 3 — ALTERNATIVE
// use a library/helper for repeated validation.

// PATTERN 4 — PRODUCTION
// prove the invariant with fuzz/invariant tests and audit assumptions.

The goal is not to use every pattern in production.
// The goal is to recognize the family of solutions and understand why
// one was selected.
=============================================================
*/
