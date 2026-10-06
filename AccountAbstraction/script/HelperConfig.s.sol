// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {Script, console, console2} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {EntryPoint} from "@eth-infinitism/account-abstraction/contracts/core/EntryPoint.sol";

contract HelperConfig is Script {
    ///////////////////////////////////////////////////////
    ///    ERRORS
    ///////////////////////////////////////////////////////
    error HelperConfig__InvalidChainId();

    ///////////////////////////////////////////////////////
    ///    CUSTOM TYPES
    ///////////////////////////////////////////////////////
    struct NetworkConfig {
        address entryPoint;
        address account;
        address token;
    }

    ///////////////////////////////////////////////////////
    ///    VARIABLES
    ///////////////////////////////////////////////////////

    //chain IDs
    uint256 private constant ETH_MAINNET = 1;
    uint256 private constant ETH_SEPOLIA = 11155111;
    uint256 private constant ZKSYNC_MAINNET = 324;
    uint256 private constant ZKSYNC_SEPOLIA = 300;
    uint256 private constant ARBITRUM_MAINNET = 42161;
    uint256 private constant ARB_SEPOLIA = 421614;
    uint256 private constant LOCAL_ANVIL = 31337;

    address private constant BURNER_WALLET = 0xF6C66AE2effe075aD541053D665C793905D9ad90;
    address private constant ANVIL_WALLET = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address private immutable i_entryPoint;

    NetworkConfig public localAnvil;
    mapping(uint256 chainId => NetworkConfig) public networkHolder;

    ERC20Mock erc = new ERC20Mock();

    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    constructor() {
        networkHolder[ETH_MAINNET] = getEthMainnet();
        networkHolder[ETH_SEPOLIA] = getEthSepolia();
        networkHolder[ARBITRUM_MAINNET] = getArbitrumMainnet();
        networkHolder[ARB_SEPOLIA] = getArbitrumSepolia();
        networkHolder[ZKSYNC_MAINNET] = getZksyncMainnet();
        networkHolder[ZKSYNC_SEPOLIA] = getZksyncSepolia();

        if (block.chainid == LOCAL_ANVIL) {
            localAnvil = getOrCreateAnvilChain();
        }

    }

    function getConfig() public view returns (NetworkConfig memory) {
        uint256 chainId = block.chainid;

        if (chainId == LOCAL_ANVIL) {
            return localAnvil;
        } else if (networkHolder[chainId].account != address(0)) {
            return networkHolder[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    ///////////////////////////////////////////////////////
    ///    NETWORK CONFIGS
    ///////////////////////////////////////////////////////

    function getEthMainnet() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032, // v7
            account: BURNER_WALLET,
            token: address(erc)
        });
    }

    function getEthSepolia() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, account: BURNER_WALLET, token: address(erc)});
    }

    function getArbitrumMainnet() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032, account: BURNER_WALLET, token: address(erc)});
    }

    function getArbitrumSepolia() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: 0x0000000071727De22E5E9d8BAf0edAc6f37da032, account: BURNER_WALLET, token: address(erc)});
    }

    function getZksyncMainnet() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET,token: address(erc)});
    }

    function getZksyncSepolia() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET, token: address(erc)});
    }

    function getOrCreateAnvilChain() public returns (NetworkConfig memory) {
        if(localAnvil.account != address(0)){
            return localAnvil;
        }

        //deploying mocks
        console2.log("Deploying mocks......");
        vm.startBroadcast(ANVIL_WALLET);
        EntryPoint entry = new EntryPoint();
        ERC20Mock erc20 = new ERC20Mock();
        vm.stopBroadcast();
        console2.log("Mocks deployed!");

        localAnvil = NetworkConfig({
            entryPoint: address(entry),
            account: ANVIL_WALLET,
            token: address(erc20)
            });

        return localAnvil;
    }

}
