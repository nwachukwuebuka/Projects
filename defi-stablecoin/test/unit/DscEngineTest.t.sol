// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";

import {DscEngine} from "src/DscEngine.sol";
import {DecentralisedStablecoin} from "src/DecentralisedStablecoin.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DeployDscEngine} from "script/DeployDscEngine.s.sol";

import { ERC20Mock } from "../mocks/ERC20Mock.sol";

contract DscEngineTest is Test{
   
    DscEngine dscEngine;
    DecentralisedStablecoin dsc;
    DeployerDscEngine deployer;
    HelperConfig public helperConfig;

    address ethUsdPriceFeed;
    address weth;
    address wbtc;
    address btcUsdPriceFeed;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;


    function setUp() public{
        depoloyer = new DeployDscEngine();
        (dsc, dscEngine) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, ) = deployer.activeNetworkConfig();
        ERC20Mock(weth).mint(USER, STARTING_BALANCE);
    
    }


    ////////////////////////////////////////////
    //           PriceFeed TEST               //
    ////////////////////////////////////////////
    function testGetPriceFeed() public {
        address priceFeed = dscEngine.getPriceFeed(weth);
        assertEq(priceFeed, ethUsdPriceFeed);
    }

    ////////////////////////////////////////////
    //             CONSTRUCTOR                //
    ////////////////////////////////////////////

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;



    function testRevertIfTokenAddressANDPriceFeedAddressLengthMismatch() public {

        // tokenAddresses[0] = makeAddr("weth"); // = address(1);
        // tokenAddresses[1] = makeAddr("wbtc"); // = address(2);

        tokenAddresses.push(weth);
        tokenAddresses.push(wbtc);
        priceFeedAddresses.push(ethUsdPriceFeed);

        vm.expectRevert(
            DscEngine
                .DscEngine__TokenAddressANDpriceFeedAddressMUSTmatchSameLength
                .selector
        );

        new DscEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(dsc)
        );

   

         // Create only 1 token address.


        // Create only 1 price feed address.
        address[] memory priceFeedAddresses = new address[](1);
        priceFeedAddresses[0] = makeAddr("ethUsdFeed"); // address(3);

        // Assert
        // We expect the constructor to revert with the custom error.
        vm.expectRevert(
            DscEngine
                .DscEngine__TokenAddressANDpriceFeedAddressMUSTmatchSameLength
                .selector
        );

        // Act
        new DscEngine(
            tokenAddresses,
            priceFeedAddresses,
            address(dsc)
        );

    }


    function testDepositIsMoreThanZero() public{

         address tokenAddress = makeAddr("token");
         uint256 amount = 0;


        vm.expectRevert(
            DscEngine.DscEngine__NeedsMoreThanZero().selector
            );
    
        dsc.depositCollateral(tokenAddress, amount);
    }

    function testIfTokenIsAllowed() public{
          address token  = address(0);
           uint256 amount = 100;

           vm.expertRevert(
            DscEngine.DscEngine__NotAllowedToken()
            );

          dsc.depositCollateral(token, amount);

    }
    function testIfCollateralDepositIsEmitted() public{}
    
    function testTransferFailed() public{
        address tokenAddress = makeAddr("token");
        uint256 amount = 100;

           // Arrange
    MockFailedTransfer badToken = new MockFailedTransfer();

    // We need the token to be allowed
    // so you'd deploy a new DscEngine using this token
    // as collateral.

    vm.expectRevert(
        DscEngine.DscEngine__TransferFailed.selector
    );

    // Act
    dscEngine.depositCollateral(
        address(badToken),
        100
    );


    }
    
}

contract MockFailedTransfer {
    function transferFrom(
        address,
        address,
        uint256
    ) external pure returns (bool) {
        return false;
    }
}