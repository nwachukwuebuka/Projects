// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Test,console } from "forge-std/Test.sol";
import { EelToken } from "../src/EelToken.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
import { DeployMerkleAirdrop } from "../script/DeployMerkleAirdrop.s.sol";
import { ZkSyncChainChecker } from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

/**
* @title AirDrop Test
* @author Nwachukwu Chukwuebuka
* @notice 
* 
*/


contract MerkleAirdropTest is Test, ZkSyncChainChecker{


    uint256 private constant AMOUNT_TO_CLAIM = 25e18; 
    uint256 private constant AMOUNT_TO_SEND = 25e18;//4 * AMOUNT_TO_CLAIM; 
    bytes32 private constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;

    bytes32[] PROOF = [proofOne, proofTwo];
    address user;
    uint256 userPrivKey;
    address gasPayer;
    EelToken eelToken;
    MerkleAirdrop merkleAirdrop;

    function setUp() public{
        if(!isZkSyncChain()){
            DeployMerkleAirdrop deploy = new DeployMerkleAirdrop();
            (eelToken, merkleAirdrop) = deploy.deployMerkleAirdrop();
        }
        else{

            eelToken = new EelToken();
            merkleAirdrop = new MerkleAirdrop(ROOT, eelToken);

            eelToken.mint(eelToken.owner(), AMOUNT_TO_SEND);
            eelToken.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");

    }

    // function testUserCanClaim() public{
    //     uint256 merkleBalance = eelToken.balanceOf(address(merkleAirdrop));

    //     merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);
    //     uint256 userBalance = eelToken.balanceOf(user);
    //     uint256 merkleBalanceAfterClaim = eelToken.balanceOf(address(merkleAirdrop));

    //     assertEq(merkleBalance - AMOUNT_TO_CLAIM, merkleBalanceAfterClaim);
    //     assertEq(userBalance, AMOUNT_TO_CLAIM);


    // }
    function testClaimOnBehalfOfUser() public{
        uint256 merkleBalance = eelToken.balanceOf(address(merkleAirdrop));
        bytes32 digest = merkleAirdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        //user giving another address permission to claim on it's behalf
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r ,s);
        uint256 userBalance = eelToken.balanceOf(user);
        uint256 merkleBalanceAfterClaim = eelToken.balanceOf(address(merkleAirdrop));

        assertEq(merkleBalance - AMOUNT_TO_CLAIM, merkleBalanceAfterClaim);
        assertEq(userBalance, AMOUNT_TO_CLAIM);

    }

}