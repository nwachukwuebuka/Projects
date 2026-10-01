// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../../src/BasicNFT.sol";

contract BasicNftTest is Test{
    DeployBasicNFT public deployer;
    BasicNFT public basicNft;
    address public USER = makeAddr("USER");

    string public constant PUG = "ipfs://QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8";


    function setUp() public{
       deployer = new DeployBasicNFT();
       basicNft = deployer.run();

    }

    function test_tokenNameIsCorrect() public view{
        string memory expectedName = "Dogie";
        string memory assignedName = basicNft.name();

        assert(
            keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(assignedName))
            );
    }

    function test_canMintAndHaveTokenURI() public{
        vm.prank(USER);
        basicNft.mintNft(PUG);
        
        assert(basicNft.balanceOf(USER) == 1);
        assert(
            keccak256(abi.encodePacked(PUG)) == keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
    }
}