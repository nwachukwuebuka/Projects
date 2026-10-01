// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";
import { DeployContract } from "../script/DeployContract.s.sol";
import { UpgradeContract } from "../script/UpgradeContract.s.sol";
import { ContractV1 } from "../src/ContractV1.sol";
import { ContractV2 } from "../src/ContractV2.sol";


contract DeployAndUpgradeTest is Test {

    DeployContract deploy; 
    UpgradeContract upgrade;
    address proxy;
    



    function setUp() public{

        deploy = new DeployContract();
        upgrade = new UpgradeContract();
        proxy = deploy.run();

    }

    function testUpgrade() public{
        ContractV2 contract2 = new ContractV2();
        upgrade.upgradeContract(proxy, address(contract2));

        uint8 expectedValue = 2;

        assertEq(expectedValue, ContractV2(proxy).getVersion());



    }
    

}