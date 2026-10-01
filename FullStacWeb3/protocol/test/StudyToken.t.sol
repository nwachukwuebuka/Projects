// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {StudyToken} from "../src/StudyToken.sol";

contract StudyTokenTest is Test {
    StudyToken token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new StudyToken(1_000 ether);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1_000 ether);
        assertEq(token.balanceOf(address(this)), 1_000 ether);
    }

    function testTransfer() public {
        token.transfer(alice, 100 ether);

        assertEq(token.balanceOf(alice), 100 ether);
    }

    function testApproveAndTransferFrom() public {
        token.transfer(alice, 100 ether);

        vm.prank(alice);
        token.approve(bob, 40 ether);

        vm.prank(bob);
        token.transferFrom(alice, bob, 40 ether);

        assertEq(token.balanceOf(alice), 60 ether);
        assertEq(token.balanceOf(bob), 40 ether);
        assertEq(token.allowance(alice, bob), 0);
    }

    function testCannotTransferTooMuch() public {
        vm.expectRevert(StudyToken.InsufficientBalance.selector);
        token.transfer(alice, 2_000 ether);
    }
}
