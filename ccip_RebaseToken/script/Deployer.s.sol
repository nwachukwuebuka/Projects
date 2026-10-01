// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//Test tools
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

//Actual Infrastructure: manages the token administrators
import {RegistryModuleOwnerCustom} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";



import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";



import {Script} from "forge-std/Script.sol";
import {IRebaseToken} from "src/interfaces/IRebaseToken.sol";
import {RebaseToken} from "src/RebaseToken.sol";
import {RebaseTokenPool} from "src/RebaseTokenPool.sol";
import {Vault} from "src/Vault.sol";
import {TokenAdminRegistry} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";


contract DeployTokenAndPool is Script{

    function run() public returns (RebaseToken token, RebaseTokenPool pool){
        CCIPLocalSimulatorFork ccip = new CCIPLocalSimulatorFork();

        //block.chainid is gotten at runtime
        Register.NetworkDetails memory networkDetails = ccip.getNetworkDetails(block.chainid);

        vm.startBroadcast();
        token = new RebaseToken();
         pool = new RebaseTokenPool(
            IERC20(address(token)), new address[](0), networkDetails.rmnProxyAddress, networkDetails.routerAddress
        );

        token.grantMintAndBurnRole(address(pool));

        //registers the token contract as admin
        RegistryModuleOwnerCustom(networkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(token));

        // The token accepts the CCIP admin role, allowing the registry to manage its CCIP settings.
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(token));

        // Links the token to its CCIP token pool, telling CCIP which pool handles cross-chain transfers.
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(address(token), address(pool));
        vm.stopBroadcast();
        
    }

}

contract VaultTest is Script{

    function run(address _rebaseToken) public returns (Vault vault){
        vm.startBroadcast();

        vault = new Vault(IRebaseToken(_rebaseToken));
        IRebaseToken(_rebaseToken).grantMintAndBurnRole(address(vault));
        vm.stopBroadcast();

    }
}