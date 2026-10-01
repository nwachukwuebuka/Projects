// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DecentralisedStablecoin} from "../src/DecentralisedStablecoin.sol";
import {DscEngine} from "../src/DscEngine.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralisedStablecoin, DscEngine) {
        HelperConfig config = new HelperConfig();

        (address wethUsd, address wbtcUsd, address weth, address wbtc, uint256 deployerKey) =
            config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsd, wbtcUsd];

        vm.startBroadcast(deployerKey);
        DecentralisedStablecoin dsc = new DecentralisedStablecoin();
        DscEngine dscEngine = new DscEngine(tokenAddresses, priceFeedAddresses, address(dsc));

        dsc.transferOwnership(address(dscEngine));
        vm.stopBroadcast();
        return (dsc, dscEngine, config);
    }
}
