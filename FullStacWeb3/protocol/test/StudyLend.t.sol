// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {StudyToken} from "../src/StudyToken.sol";
import {StudyLend} from "../src/StudyLend.sol";

contract StudyLendTest is Test {
    StudyToken token;
    StudyLend lend;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 constant INITIAL = 1_000_000 ether;

    function setUp() public {
        token = new StudyToken(INITIAL);
        lend = new StudyLend(token);

        token.transfer(alice, 10_000 ether);
        token.transfer(bob, 10_000 ether);
    }

    function _approve(address user, uint256 amount) internal {
        vm.prank(user);
        token.approve(address(lend), amount);
    }

    /*
      PATTERN 1 — LEGACY:
      A test can use raw assert statements.

      PATTERN 2 — RECOMMENDED:
      Foundry's assertEq/assertGt/etc. produce useful failure output.

      PATTERN 3 — ALTERNATIVE:
      Use invariant/fuzz testing when you want broad state exploration.

      PATTERN 4 — PRODUCTION:
      Combine unit, fuzz, invariant, integration and fork tests.
    */
    function testSupplyMintsShares() public {
        uint256 amount = 1_000 ether;
        _approve(alice, amount);

        vm.prank(alice);
        uint256 shares = lend.supply(amount);

        assertEq(shares, amount);
        assertEq(lend.userShares(alice), amount);
        assertEq(lend.totalSupplied(), amount);
    }

    function testSecondSupplierGetsProportionalShares() public {
        _approve(alice, 1_000 ether);
        vm.prank(alice);
        lend.supply(1_000 ether);

        _approve(bob, 500 ether);
        vm.prank(bob);
        uint256 shares = lend.supply(500 ether);

        assertEq(shares, 500 ether);
        assertEq(lend.totalShares(), 1_500 ether);
    }

    function testWithdraw() public {
        _approve(alice, 1_000 ether);

        vm.prank(alice);
        lend.supply(1_000 ether);

        uint256 beforeBalance = token.balanceOf(alice);

        vm.prank(alice);
        lend.withdraw(400 ether);

        assertEq(token.balanceOf(alice), beforeBalance + 400 ether);
        assertEq(lend.userShares(alice), 600 ether);
    }

    function testBorrowAgainstCollateral() public {
        _approve(alice, 2_000 ether);

        vm.prank(alice);
        lend.supply(2_000 ether);

        // Alice needs liquidity to borrow from.
        _approve(bob, 200 ether);

        vm.prank(bob);
        lend.borrow(200 ether, 100 ether);

        assertEq(lend.collateral(bob), 200 ether);
        assertEq(lend.debt(bob), 100 ether);
        assertEq(lend.totalBorrowed(), 100 ether);
    }

    function testCannotBorrowAboveLTV() public {
        _approve(alice, 2_000 ether);

        vm.prank(alice);
        lend.supply(2_000 ether);

        _approve(bob, 200 ether);

        vm.prank(bob);
        vm.expectRevert(StudyLend.BorrowTooLarge.selector);
        lend.borrow(200 ether, 101 ether);
    }

    function testRepay() public {
        _approve(alice, 2_000 ether);

        vm.prank(alice);
        lend.supply(2_000 ether);

        _approve(bob, 200 ether);

        vm.prank(bob);
        lend.borrow(200 ether, 100 ether);

        _approve(bob, 50 ether);

        vm.prank(bob);
        lend.repay(50 ether);

        assertEq(lend.debt(bob), 50 ether);
        assertEq(lend.totalBorrowed(), 50 ether);
    }

    function testUtilization() public {
        _approve(alice, 2_000 ether);

        vm.prank(alice);
        lend.supply(2_000 ether);

        _approve(bob, 200 ether);

        vm.prank(bob);
        lend.borrow(200 ether, 100 ether);

        // 100 / 2000 = 5%.
        assertEq(lend.utilizationBps(), 500);
    }

    /*
      FUZZ TEST

      Foundry will generate many values for amount.

      PATTERN 1 — LEGACY:
      Hand-write a few example values.

      PATTERN 2 — RECOMMENDED:
      Fuzz numeric boundaries.

      PATTERN 3 — ALTERNATIVE:
      Invariant testing explores sequences of actions.

      PATTERN 4 — PRODUCTION:
      Add assumptions to keep fuzz cases meaningful without hiding bugs.
    */
    function testFuzzSupplyWithdraw(uint96 rawAmount) public {
        uint256 amount = bound(uint256(rawAmount), 1 ether, 5_000 ether);

        _approve(alice, amount);

        vm.prank(alice);
        uint256 shares = lend.supply(amount);

        vm.prank(alice);
        uint256 withdrawn = lend.withdraw(shares);

        assertEq(withdrawn, amount);
        assertEq(lend.userShares(alice), 0);
    }

    /*
      INVARIANT-STYLE CHECK

      For this simplified pool, debt can never exceed total supplied.
    */
    function testInvariantDebtCannotExceedSupply() public {
        assertLe(lend.totalBorrowed(), lend.totalSupplied());
    }
}
