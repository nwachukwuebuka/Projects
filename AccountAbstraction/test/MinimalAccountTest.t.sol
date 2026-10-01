// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {Test} from "forge-std/Test.sol";
import {DeployMinimal} from "script/DeployMinimal.s.sol";
import {MinimalAccount} from "src/MinimalAccount.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract MinimalAccountTest is Test {
    ///////////////////////////////////////////////////////
    ///    VARIABLES
    ///////////////////////////////////////////////////////
    uint256 private constant AMOUNT = 1e18;
    MinimalAccount minaccount;
    HelperConfig helperconfig;
    ERC20Mock usdc;

    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    function setUp() public {
        DeployMinimal deploy = new DeployMinimal();
        (minaccount, helperconfig) = deploy.deployMinimal();
        usdc = new ERC20Mock();
    }

    ///////////////////////////////////////////////////////
    ///    TEST FUNCTIONS
    ///////////////////////////////////////////////////////

    function testOwnerCanExecute() public {
        assertEq(usdc.balanceOf(address(minaccount)), 0);
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minaccount), AMOUNT);

        vm.prank(minaccount.owner());
        minaccount.execute(address(usdc), AMOUNT, functionData);

        assertEq(usdc.balanceOf(address(minaccount)), AMOUNT);

    }

    function testNonOwnerCannotExecute() public {
        address randomUser = makeAddr("randomUser");
        assertEq(usdc.balanceOf(address(minaccount)), 0);
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minaccount), AMOUNT);

        vm.prank(randomUser);
        vm.expectRevert(
            MinimalAccount.MinimalAccount__NotFromOwnerOrEntrypoint.selector
        );
        minaccount.execute(address(usdc), AMOUNT, functionData); 
    }
}
    
