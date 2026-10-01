// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";


contract CreateSubscription is Script{

    function createSubscriptionUsingConfig() public returns (uint256, address){
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfcoordinator;
        (uint256 subscriptionId,) = createSubscription(vrfCoordinator);
        return (subscriptionId, vrfCoordinator);
        
    }   
    function createSubscription(address vrfCoordinator) public returns (uint256, address){
        
        console.log("Creating subscription on chain %d", block.chainid);
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription(); // what happened here, how is  VRFCoordinatorV2_5Mock accepting the vrfCoordinator but i can't see it's constructor asking for anything like that, lastly is ........ VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription() does this mean the fuction createSubscription is calling itself again?
        vm.stopBroadcast();

        // when exactly do we need to use the vm.startBroadcast(); and vm.stopBroadcast();

        console.log("Subscription is", subscriptionId);
        console.log("update subId in helperConfig");
        return (subscriptionId, vrfCoordinator);
    }

    function run() public{
        createSubscriptionUsingConfig();
    }
}


contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;


    function fundSubscriptionUsingconfig() public{
        HelperConfig helperconfig = new HelperConfig();
        address vrfcoordinator = helperconfig.getConfig().vrfcoordinator;
        
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subId,
        address linkToken
    ) public {
        if (block.chainid == 31337) {
            // Local network (Anvil)
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            // Testnet (Sepolia, etc.)
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
        uint64 subId = uint64(vm.envUint("SUBSCRIPTION_ID"));
        address linkToken = vm.envAddress("LINK_TOKEN");

        vm.startBroadcast();
        fundSubscription(vrfCoordinator, subId, linkToken);
        vm.stopBroadcast();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address mostRecentlyDeployed) public{
        HelperConfig helperconfig = new HelperConfig();
        uint256 subId = helperconfig.getConfig().subscriptionId;
        address vrfcoordinator = helperconfig.getConfig().vrfcoordinator;
        addConsumer(mostRecentlyDeployed,vrfcoordinator, subId);
        
    }

    function addConsumer(
        address contractToAddVrf,
        address vrfCoordinator,
        uint256 subId
    ) public {
        console.log("Adding consumer to subscription on chain %d", block.chainid);
        console.log("Consumer contract address:", contractToAddVrf);
        console.log("VRF Coordinator address:", vrfCoordinator);


        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, contractToAddVrf);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
             "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}

