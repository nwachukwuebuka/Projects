// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  Minimal ERC-20 interface for the learning protocol.

  PATTERN 1 — LEGACY:
  Importing a huge interface/library when only a few methods are needed.

  PATTERN 2 — RECOMMENDED FOR THIS LESSON:
  Use a minimal interface at the boundary.

  PATTERN 3 — ALTERNATIVE:
  Use OpenZeppelin's IERC20 interface.

  PATTERN 4 — PRODUCTION:
  Prefer battle-tested OpenZeppelin contracts for standard token behavior.
*/
interface IERC20Minimal {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);
}
