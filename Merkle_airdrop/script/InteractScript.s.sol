// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import { Script } from "forge-std/Script.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";

contract InteractScript is Script {

    //errors
    error InteractScript__InvalidSignatureLength();


    address claimingAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 claimingAmount = 25e18;

    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;

    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    bytes32[] proof = [proofOne, proofTwo];

    bytes private SIGNATURE = hex"86895b177b7ff2c1bd3d4712d8afd1db91869f39fe74972b84d4f2cd9fb2bbc50fb029721344d302bdd31aafbbac8aa0cbe1d545df59da5279fdbc95731348221b";



    function claimAirDrop(address airdrop) public{
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(claimingAddress, claimingAmount, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s){
        if(sig.length != 65){
            revert InteractScript__InvalidSignatureLength();
        }
        assembly{
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }




    function run() external{

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirDrop(mostRecentlyDeployed);


    }

}
