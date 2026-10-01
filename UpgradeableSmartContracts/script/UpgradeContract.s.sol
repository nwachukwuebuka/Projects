// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { ContractV2 } from "../src/ContractV2.sol";
import { ContractV1 } from "../src/ContractV1.sol";
import { DevOpsTools } from "../lib/foundry-devops/src/DevOpsTools.sol";



contract UpgradeContract is Script{

    function upgradeContract(address proxyAddress, address newContract) public returns (address){
        vm.startBroadcast();
        ContractV1 proxy = ContractV1(proxyAddress);
        proxy.upgradeToAndCall(newContract, "");
        vm.stopBroadcast();

        return address(proxy);        
    }


    function deployUpgrade() public returns (address){
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        
        vm.startBroadcast();
        ContractV2 contract2 = new ContractV2();
        vm.stopBroadcast();
        address proxy = upgradeContract(mostRecentDeployed, address(contract2));

        return proxy;

    }

    function run() external returns(address){
        return deployUpgrade();

    }

}