// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {Test} from "forge-std/Test.sol";
import {DeployMinimal} from "script/DeployMinimal.s.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, IEntryPoint} from "script/SendPackedUserOp.s.sol";
import {PackedUserOperation} from "@eth-infinitism/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    ///////////////////////////////////////////////////////
    ///    VARIABLES
    ///////////////////////////////////////////////////////
    uint256 private constant AMOUNT = 1e18;
    MinimalAccount minaccount;
    HelperConfig helperconfig;
    ERC20Mock usdc;
    SendPackedUserOp sendPack;
    address randomuser = makeAddr("randomUser");



    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    function setUp() public {
        DeployMinimal deploy = new DeployMinimal();
        (minaccount, helperconfig) = deploy.deployMinimal();
        usdc = new ERC20Mock();
        sendPack = new SendPackedUserOp();
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
        assertEq(usdc.balanceOf(address(minaccount)), 0);
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minaccount), AMOUNT);

        vm.prank(randomuser);
        vm.expectRevert(
            MinimalAccount.MinimalAccount__NotFromOwnerOrEntrypoint.selector
        );
        minaccount.execute(address(usdc), AMOUNT, functionData); 
    }

    function testRecoverAddressSignedOp() public{
        uint256 value = 0;
        address point = helperconfig.getConfig().entryPoint;

        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minaccount), AMOUNT);
        bytes memory executeCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, address(usdc), value, functionData);

        PackedUserOperation memory signedUserOp = sendPack.generateSignedUserOperation(executeCallData, helperconfig.getConfig(), address(minaccount));
        bytes32 signedUserOpHash = IEntryPoint(point).getUserOpHash(signedUserOp);
        address actualSigner = ECDSA.recover(signedUserOpHash.toEthSignedMessageHash(), signedUserOp.signature);

        // Assert
        assertEq(actualSigner, minaccount.owner());
    }

    function testValidationOfUserOps() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minaccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minaccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOp = sendPack.generateSignedUserOperation(
            executeCallData, helperconfig.getConfig(), address(minaccount)
        );
        bytes32 userOperationHash = IEntryPoint(helperconfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;

        // Act
        vm.deal(address(minaccount), 1e18);
        vm.prank(helperconfig.getConfig().entryPoint);
        uint256 validationData = minaccount.validateUserOp(packedUserOp, userOperationHash, missingAccountFunds);
        assertEq(validationData, 0);
    }

    function testEntryPointCanExecute() public{
         // Arrange
        assertEq(usdc.balanceOf(address(minaccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minaccount), AMOUNT);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory packedUserOp = sendPack.generateSignedUserOperation(
            executeCallData, helperconfig.getConfig(), address(minaccount)
        );
        // bytes32 userOperationHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        vm.deal(address(minaccount), 1e18);

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        // Act
        vm.prank(randomuser);
        IEntryPoint(helperconfig.getConfig().entryPoint).handleOps(ops, payable(randomuser));

        // Assert
        assertEq(usdc.balanceOf(address(minaccount)), AMOUNT);
    

    }

}
    
