// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";

contract DeployMinimal is Script {
    function deployMinimal() public returns (MinimalAccount, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();

        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        console.log("========== DEBUG ==========");
        console.log("Chain ID:", block.chainid);
        console.log("Account:", config.account);
        console.log("========== DEBUG ==========");

        vm.startBroadcast(config.account);
        MinimalAccount minaccount = new MinimalAccount(config.entryPoint);
        vm.stopBroadcast();
        return (minaccount, helperconfig);
    }

    function run() external {
        deployMinimal();
    }
}
