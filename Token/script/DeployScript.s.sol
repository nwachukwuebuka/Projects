// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Token} from "../src/Token.sol";
import {Script} from "forge-std/Script.sol";



contract DeployScript is Script{

    uint256 INITIAL_SUPPLY = 19_000_000e18;

    function run() external returns(Token){
        vm.startBroadcast();
        Token TKN = new Token(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return TKN;
    }
}