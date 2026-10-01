// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { EelToken } from "../src/EelToken.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DeployMerkleAirdrop is Script{

    bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 s_amountToTransfer = 4 * 25e18;


    function deployMerkleAirdrop() public returns (EelToken, MerkleAirdrop){
        vm.startBroadcast();
        EelToken eelToken = new EelToken();            
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop(merkleRoot, eelToken);
        eelToken.mint(eelToken.owner(), s_amountToTransfer);
        eelToken.transfer(address(merkleAirdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (eelToken, merkleAirdrop);

    }

    function run() external returns (EelToken, MerkleAirdrop){
        return deployMerkleAirdrop();

    }

}