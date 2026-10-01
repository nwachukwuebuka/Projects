// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployScript} from "../script/DeployScript.s.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test{
    DeployScript public deploy;
    Token public token;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;


    function setUp() public{
        deploy = new DeployScript();
        token = deploy.run();

        vm.prank(address(msg.sender));
        token.transfer(bob, STARTING_BALANCE);
    }

    function test_bobBalance() public{
        assertEq(STARTING_BALANCE, token.balanceOf(bob));
    }

    function test_AllowanceWorks() public{
        uint256 allowance = 1000;

        vm.prank(bob);
        token.approve(alice, allowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);

        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);



    }


}