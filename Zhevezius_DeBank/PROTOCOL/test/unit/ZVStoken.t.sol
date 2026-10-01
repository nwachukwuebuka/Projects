// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

////////////////////////////////////////////////
//////////////////// IMPORTS ////////////////////
////////////////////////////////////////////////
import {Test, console} from "forge-std/Test.sol";
import {ZVStoken} from "src/ZVStoken.sol";

contract ZVStokenTest is Test {
    ////////////////////////////////////////////////
    //////////////////// VARAIBLES ////////////////////
    ////////////////////////////////////////////////

    uint256 public constant MINT_VALUE = 1 ether;
    uint256 public constant BURN_VALUE = 1e15;
    address owner = makeAddr("owner");
    address vault = makeAddr("vault");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    ZVStoken zvs;

    ////////////////////////////////////////////////
    //////////////////// FUNCTIONS ////////////////////
    ////////////////////////////////////////////////

    function setUp() public {
        vm.prank(owner);
        zvs = new ZVStoken();
    }

    function grantAndMintIn() public {
        vm.startPrank(owner);
        zvs.grantRole(zvs.MINTER_ROLE(), vault);
        vm.stopPrank();

        vm.prank(vault);
        zvs.mint(alice, MINT_VALUE);
    }

    function grantBurnRole() public {
        vm.startPrank(owner);
        zvs.grantRole(zvs.BURNER_ROLE(), vault);
        vm.stopPrank();
    }

    function testDeployerIsAdmin() public {
        assertTrue(zvs.hasRole(zvs.DEFAULT_ADMIN_ROLE(), owner));
    }

    function testMintWorks() public {
        grantAndMintIn();
        uint256 aliceBalance = zvs.balanceOf(alice);
        assertEq(aliceBalance, MINT_VALUE);
    }

    function testOnlyMINTER_ROLECanMint() public {
        grantAndMintIn();

        vm.prank(alice);
        vm.expectRevert();
        zvs.mint(bob, MINT_VALUE);
    }

    function testMintCannotBeZero() public {
        grantAndMintIn();

        vm.prank(vault);
        vm.expectRevert(ZVStoken.ZVStoken__AmountCantBeZero.selector);
        zvs.mint(alice, 0);
    }

    function testMintMax() public {
        grantAndMintIn();
        uint256 maxSupply = zvs.MAX_SUPPLY();

        vm.startPrank(vault);
        vm.expectRevert(ZVStoken.ZVStoken__MaxSupplyExceeded.selector);
        zvs.mint(bob, maxSupply);

        vm.stopPrank();
    }

    function testBurnWorks() public {
        grantAndMintIn();
        grantBurnRole();

        vm.prank(vault);
        zvs.burn(alice, BURN_VALUE);

        uint256 aliceBalance = zvs.balanceOf(alice);

        assertEq(aliceBalance, MINT_VALUE - BURN_VALUE);
    }

    function testOnlyBURNER_ROLECanBurn() public {
        grantAndMintIn();
        grantBurnRole();

        vm.prank(alice);
        vm.expectRevert();
        zvs.burn(alice, BURN_VALUE);
    }

    function testBurnCannotBeZero() public {
        grantAndMintIn();
        grantBurnRole();

        vm.prank(vault);

        vm.expectRevert(ZVStoken.ZVStoken__AmountCantBeZero.selector);

        zvs.burn(alice, 0);
    }

    function testCannotBurnMoreThanBalance() public {
        grantAndMintIn();
        grantBurnRole();

        vm.prank(vault);

        vm.expectRevert();

        zvs.burn(alice, 100 ether);
    }

    ////////////////////////////////////////////////
    ///////////SECURITY ASSUMPTIONS ////////////////
    ////////////////////////////////////////////////

    function testIfDeployerCanMintWithoutRole() public {
        vm.prank(owner);
        vm.expectRevert();
        zvs.mint(alice, MINT_VALUE);
    }

    function testMinterCanRenounceRole() public {
        grantAndMintIn();

        vm.startPrank(vault);
        zvs.renounceRole(zvs.MINTER_ROLE(), vault);
        vm.stopPrank();

        assertFalse(zvs.hasRole(zvs.MINTER_ROLE(), vault));
    }
}
