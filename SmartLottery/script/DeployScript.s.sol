// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "../src/Raffle.sol";
import {Script} from "forge-std/Script.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./interaction.s.sol";

contract DeployScript is Script{
    
    function run() public{
        deployContract();
    }

    function deployContract() public returns (HelperConfig, Raffle){ // why are we returning the two contracts 
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig(); 


        if(config.subscriptionId == 0){
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfcoordinator) = createSubscription.createSubscription(config.vrfcoordinator);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfcoordinator, config.subscriptionId, config.link);
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.raffleMoney,
            config.interval,
            config.vrfcoordinator,
            config.keyHash,
            uint32(config.subscriptionId),
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer( address(raffle),config.vrfcoordinator, config.subscriptionId);


        return (helperConfig, raffle);

    }
    
}

        //``` HelperConfig helperConfig = new HelperConfig();
        // HelperConfig.NetworkConfig memory config = helperConfig.getConfig();```

