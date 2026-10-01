//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstants{
    uint256 public constant ETH_MAINNET_CHAINID = 1;
    uint256 public constant SEPOLIA_CHAINID = 11155111;
    uint256 public constant ANVIL_CHAINID = 31337;

    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int256 public MOCK_WEI_PER_UNIT_LINK = 4e15;

    address public constant FOUNDRY_DEFAULT_SENDER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
}


contract HelperConfig is CodeConstants, Script{
 
     /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig_InvalidChainId();


     /*//////////////////////////////////////////////////////////////
                            TYPE DECLARATION
    //////////////////////////////////////////////////////////////*/

    struct NetworkConfig{
        uint256 subscriptionId,
        bytes32 gasLane, //keyHash
        uint32 callbackGasLimit

        uint256 interval,
        uint256 entranceFee,    
        address vrfCoordinatorV2,
        
        address link;
    }

   
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    NetworkConfig public localNetworkConfig;

    mapping(uint256 chainID => NetworkConfig) public networkConfigs;



     /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets Sepolia config to a map pointer
     * @param networkConfigs the mapping varaible
     */
    constructor(){
        //set as default chainId
        networkConfigs[SEPOLIA_CHAINID] = getSepoliaNetworkConfig();
    }


     /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getConfigByChainID(uint256 chainId) public returns(NetworkConfig memory){
        if(networkConfigs[chainId].vrfcoordinator != address(0)){
            return networkConfigs[chainId];
           
        }else if(chainId == ETH_MAINNET_CHAINID){
            return getMainnetEthConfig();

        }else if(chainId == ANVIL_CHAINID){
            return getOrCreateAnvilChain();

        }else{
            revert HelperConfig_InvalidChainId();
        }
    }

    function getConfig() public returns(NetworkConfig memory){
        return getConfigByChainID(block.chainid);
    }
 

     function getMainnetEthConfig() public pure returns (NetworkConfig memory mainnetNetworkConfig){
        mainnetNetworkConfig = NetworkConfig({
            
            subscriptionId: 0,
            gasLane: 0x9fe0eebf5e446e3c998ec9bb19951541aee00bb90ea201ae456421a2ded86805,
            callbackGasLimit: 500000, // 500,000 gas

            interval: 30, // 30 seconds
            entranceFee: 0.01 ether,    
            vrfCoordinatorV2: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909,
            
            link: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
            account: 0x643315C9Be056cDEA171F4e7b2222a4ddaB9F88D
            
        });
    }
    

    function getSepoliaNetworkConfig() public pure returns(NetworkConfig memory){
      
        return NetworkConfig({
            raffleMoney: 0.01 ether,
            interval: 30, // seconds
            vrfcoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, // 
            // keyHash: 0x787d74caea10b2b357790d5d5b247c2f63dd19572a9b46f7a606e4d953677ae,
            // keyHash: bytes32(0x787d74caea10b2b357790d5d5b247c2f63dd19572a9b46f7a606e4d953677ae),
            keyHash: 0x0476f1b7e1b9a5c1c9b8b87b84d888fffbe671c5f3cf1911091cf07bba4682c7,
            callbackGasLimit: 50000,
            subscriptionId: 0, // update this with actual subscriptionId after creating one
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }


    function getOrCreateAnvilChain() public returns(NetworkConfig memory){

        if(localNetworkConfig.vrfcoordinator != address(0)){
            return localNetworkConfig;
        }

        // If has not been  deployed on anvil before, then do
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            raffleMoney: 0.01 ether,
            interval: 30, // 30 seconds
            vrfcoordinator: address(vrfCoordinatorMock),
            keyHash: 0x87f7c4eae1b2b537790b55427c361d491572af046f700e6d964965f3566377ae,
            callbackGasLimit: 500000, // 500,000 gas
            subscriptionId: 0,
            link: address(linkToken)
        });
        return localNetworkConfig;

    }


}
  