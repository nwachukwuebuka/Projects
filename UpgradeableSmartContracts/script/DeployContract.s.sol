// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { ContractV1 } from "../src/ContractV1.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract DeployContract is Script{

    function deployContract() public returns (address){
        vm.startBroadcast();
        ContractV1 contractV1 = new ContractV1();
        bytes memory initData = abi.encodeCall(ContractV1.initialize, ());
        ERC1967Proxy proxy = new ERC1967Proxy(address(contractV1), initData); 
        vm.stopBroadcast();

        return address(proxy);
    }

    function run() external returns (address){
        return deployContract();

    }

}