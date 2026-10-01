// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {Script} from "forge-std/Script.sol";
import {IEntryPoint} from "@eth-infinitism/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {PackedUserOperation} from "@eth-infinitism/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MinimalAccount} from "src/MinimalAccount.sol";



contract SendPackedUserOp is Script{
    using MessageHashUtils for bytes32;
    address constant SPENDER = 0xF6C66AE2effe075aD541053D665C793905D9ad90;



    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    function run() external{
        HelperConfig config = new HelperConfig();
        uint256 value = 0;
        address spendToken = config.getConfig().token;
        address latestMinimalAccountDeployed = DevOpsTools.get_most_recent_deployment("MinimalAccount", block.chainid);



        bytes memory functionDataOrApproval = abi.encodeWithSelector(IERC20.approve.selector, SPENDER, value);

        bytes memory callDataOrExecute = abi.encodeWithSelector(MinimalAccount.execute.selector, spendToken, value, functionDataOrApproval);

        PackedUserOperation memory signedUserOp = generateSignedUserOperation(callDataOrExecute, config.getConfig(), latestMinimalAccountDeployed);

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = signedUserOp;

        
        address ent = config.getConfig().entryPoint;
        address acc = config.getConfig().account;

        vm.startBroadcast();
        IEntryPoint(ent).handleOps(ops, payable(acc));
        vm.stopBroadcast();

    }

    function generateSignedUserOperation(
        bytes memory callData,
        HelperConfig.NetworkConfig memory config,
        address minimalAccount
    ) public view returns (PackedUserOperation memory){

        //generate unsigned data
        uint256 nonce = IEntryPoint(config.entryPoint).getNonce(minimalAccount, 0);
        PackedUserOperation memory structUserOp = _generateUserUnsignedOperation(callData, minimalAccount, nonce);

        //get userOp Hash
        bytes32 userOpHash =  IEntryPoint(config.entryPoint).getUserOpHash(structUserOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();
        //bytes32 digest = MessageHashUtils.toEthSignedMessageHash(userOpHash);


        //sign it
        uint8 v;
        bytes32 r;
        bytes32 s;
        
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        if(block.chainid == 31337){
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        }
        else{
            (v, r, s) = vm.sign(config.account, digest);

            structUserOp.signature = abi.encodePacked(r, s, v);
        }
        return structUserOp;
    }

    function _generateUserUnsignedOperation(bytes memory callData, address sender, uint256 nonce) internal pure returns (PackedUserOperation memory){
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;

         return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
         });

    }

}