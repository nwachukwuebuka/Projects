// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DecentralisedStablecoin} from "../../src/DecentralisedStablecoin.sol";

contract DecentralisedStablecoinTest is Test {
    DecentralisedStablecoin dsc; //created once and use against all tests

    address USER = makeAddr("user");
    address OWNER = address(this);

    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        dsc = new DecentralisedStablecoin();
    }

    ////////////////////////////////////////////
    //              CONSTRUCTOR               //
    ////////////////////////////////////////////

    function testOwnerIsSetCorrectly() public view {
        assertEq(dsc.owner(), OWNER);
    }

    ////////////////////////////////////////////
    //                 MINT                   //
    ////////////////////////////////////////////

    function testMintWorks() public {
        bool success = dsc.mint(USER, STARTING_BALANCE);

        assertTrue(success);
        assertEq(dsc.balanceOf(USER), STARTING_BALANCE);
    }

    function testMintRevertsIfToIsZeroAddress() public {
        vm.expectRevert(
            DecentralisedStablecoin
                .DecentralizedStableCoin__ZeroAddress
                .selector
        );

        dsc.mint(address(0), STARTING_BALANCE);
    }

    function testMintRevertsIfAmountIsZero() public {
        vm.expectRevert(
            DecentralisedStablecoin
                .DecentralizedStableCoin__MustBeMoreThanZero
                .selector
        );

        dsc.mint(USER, 0);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(USER);

        vm.expectRevert();
        dsc.mint(USER, STARTING_BALANCE);
    }

    ////////////////////////////////////////////
    //                 BURN                   //
    ////////////////////////////////////////////

    function testBurnWorks() public {
        dsc.mint(OWNER, STARTING_BALANCE);

        dsc.burn(50 ether);

        assertEq(dsc.balanceOf(OWNER), 50 ether);
    }

    function testBurnRevertsIfAmountIsZero() public {
        dsc.mint(OWNER, STARTING_BALANCE);

        vm.expectRevert(
            DecentralisedStablecoin
                .DecentralizedStableCoin__MustBeMoreThanZero
                .selector
        );
        dsc.burn(0);
    }

    function testBurnRevertsIfAmountExceedsBalance() public {
        dsc.mint(OWNER, STARTING_BALANCE);

        vm.expectRevert(
            DecentralisedStablecoin
                .DecentralizedStableCoin__BurnAmountExceedsBalance
                .selector
        );

        dsc.burn(200 ether);
    }

    ////////////////////////////////////////////
    //        CONSTRUCTOR BURNING             //
    ////////////////////////////////////////////

    function testNonOwnerCannotBurn() public {
        dsc.mint(USER, STARTING_BALANCE);

        vm.prank(USER);
        vm.expectRevert();
        dsc.burn(10 ether);
    }
}
