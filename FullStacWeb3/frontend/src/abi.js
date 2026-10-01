/*
  Minimal ABI used by the frontend.
  An ABI is the interface description that tells JavaScript how to encode calls.

  PATTERN 1 — LEGACY:
  Copying an entire generated ABI into the browser.

  PATTERN 2 — RECOMMENDED FOR THIS LESSON:
  Keep only the functions/events the page needs.

  PATTERN 3 — ALTERNATIVE:
  Import generated ABI JSON from a build system.

  PATTERN 4 — PRODUCTION:
  Generate typed contract clients from your canonical Solidity ABI.
*/

export const TOKEN_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function approve(address spender, uint256 amount) returns (bool)",
  "function allowance(address owner, address spender) view returns (uint256)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)"
];

export const LENDING_ABI = [
  "function totalSupplied() view returns (uint256)",
  "function totalBorrowed() view returns (uint256)",
  "function userShares(address) view returns (uint256)",
  "function collateral(address) view returns (uint256)",
  "function debt(address) view returns (uint256)",
  "function supply(uint256) returns (uint256)",
  "function withdraw(uint256) returns (uint256)",
  "function borrow(uint256,uint256)",
  "function repay(uint256)",
  "function utilizationBps() view returns (uint256)",
  "function shareValue(uint256) view returns (uint256)",
  "event Supplied(address indexed user, uint256 assets, uint256 shares)",
  "event Withdrawn(address indexed user, uint256 assets, uint256 shares)",
  "event Borrowed(address indexed user, uint256 collateralAmount, uint256 debtAmount)",
  "event Repaid(address indexed user, uint256 amount)"
];
