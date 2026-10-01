// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  STUDY TOKEN

  A deliberately small ERC-20-like token for local learning.

  PATTERN 1 — LEGACY:
  Some early token examples used public state variables and simple require strings.

  PATTERN 2 — RECOMMENDED LEARNING:
  Explicit custom errors + events + checks.

  PATTERN 3 — PRODUCTION ALTERNATIVE:
  OpenZeppelin ERC20:
      import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

  PATTERN 4 — PRODUCTION:
  Do not reinvent standards unless the educational goal is to understand
  the internals. In production, prefer audited implementations.
*/

contract StudyToken {
    string public constant name = "Study Token";
    string public constant symbol = "STUDY";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    error InsufficientBalance();
    error InsufficientAllowance();
    error ZeroAddress();

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        if (spender == address(0)) revert ZeroAddress();

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];

        if (currentAllowance < amount) revert InsufficientAllowance();

        // PATTERN 2 — RECOMMENDED:
        // Decrease allowance before the external-facing transfer completes.
        // This keeps accounting explicit.
        allowance[from][msg.sender] = currentAllowance - amount;

        emit Approval(from, msg.sender, currentAllowance - amount);

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        if (balanceOf[from] < amount) revert InsufficientBalance();

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
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
