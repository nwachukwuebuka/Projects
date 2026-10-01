
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";
import {RateLimiter} from "@ccip/contracts/src/v0.8/ccip/libraries/RateLimiter.sol";


contract ConfigureTokenScript is Script{


    function run(
        address localPool,
        uint64 remoteChainSelector,
        address remotePool,
        address remoteToken,
        bool outboundRateLimiterIsEnabled,//turns outgoing transfer ON and OFF
        uint128 outboundRateLimiterCapacity,// maximum number of tokens allowed to be sent at once eg 100RBT
        uint128 outboundRateLimiterRate,//how fast the transfer should be eg: 100RBT/minute
        bool inboundRateLimiterIsEnabled,
        uint128 inboundRateLimiterCapacity,
        uint128 inboundRateLimiterRate
    ) public{
        vm.startBroadcast();
        TokenPool.ChainUpdate[] memory chainsToAdd = new TokenPool.ChainUpdate[](1);
        chainsToAdd[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            allowed: true,
            remotePoolAddress: abi.encode(remotePool),
            remoteTokenAddress: abi.encode(remoteToken),
            outboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: outboundRateLimiterIsEnabled,
                capacity: outboundRateLimiterCapacity,
                rate: outboundRateLimiterRate
            }),
            inboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: inboundRateLimiterIsEnabled,
                capacity: inboundRateLimiterCapacity,
                rate: inboundRateLimiterRate
            })
        });
        TokenPool(localPool).applyChainUpdates(chainsToAdd);
        vm.stopBroadcast();
    }
    
}
