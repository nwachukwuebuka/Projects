// // SPDX-License-Identifier: MIT



// pragma solidity ^0.8.18;

// import {StdInvaraint} from "forge-std/StdInvariant.sol";
// import {Test} from "forge-std/Test.sol";
// import {DeployDscEngine} from "";
// import {DecentralisedStabelecoin} from "";
// import {DscEngine} from "";
// import {HelperConfig} from "";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract OpenInvariantTest is StdInvariant, Test{

//     DeployerDscEngine deployer;
//     DecentralisedStablecoin dsc;
//     DscEngine dsce;
//     HelperConfig config;


//     function setUp() public{

//         deployer = new DeployerDscEngine();
//         (dcs, dsce, config) = deployer.run();
//         (,, weth, wbtc,) = config.activeNetworkConfig();
//         targetContract(address(dsce));

//     }


//     function Invariant_ProtocolMustHaveMoreCollateralValueThanTotalSupply() public view{
//         uint256 totalSupply = dsc.totalSupply();
//         uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
//         uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

//         uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
//         uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

//         assert(wethValue+wbtcValue >= totalSupply);

//          }




// }