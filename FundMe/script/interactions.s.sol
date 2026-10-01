// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/**
 * @title Interactions script
 * @author Luiz Toreno
 * @notice Allows sending and withdrawiing funds
 * @dev Prevents running the DeployFundMe.sol multiple times, in oder to call the fundMe.fund() and fundMe.withdraw()
 */

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 FUND_AMOUNT = 0.5 ether;

    /**
     * @notice sends ETH
     * @dev calls the fund() again without re-deploying
     */
    function fundFundMe(address recentAddress) public {
        FundMe(payable(recentAddress)).fund{value: FUND_AMOUNT}();
    }

    function run() external {
        /**
         * @dev Didn't re-deploy...... means we are still on the same network
         */
        address recentAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast();
        fundFundMe(recentAddress);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address latestAddress) public {
        vm.startBroadcast();
        FundMe(payable(latestAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        /**
         * @dev check the last contract address deploy, along side the blockchain ID
         */
        address latestAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(latestAddress);
    }
}
