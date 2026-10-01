// SPDX-License-Identifier: MIT


import {Test} from "forge-std/Test.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {DecentralisedStablecoin} from "../../src/DecentralisedStablecoin.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../../mocks/Mock;


contract Handler is Test{
    DscEngine dsce;
    DecentralisedStablecoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 MAX_DEPOSIT = type(uint96).max;
    uint256 public timesMinted;
    uint256[] public users;
    MockV3Aggregator public ethprice;


    constructor( DscEngine _dsce, DecentralisedStablecoin _dsc){

        dsce = _dsce;
        dsc = _dsc;

        address[] memory tokenAddresses = dsce.getCollateralTokens();

        weth = ERC20Mock(tokenAddresses[0]);
        wbtc = ERC20Mock(tokenAddresses[1]);

        ethPrice = dsce.getCollateralTokenPriceFeed(address(weth));
        
    }

    function depositCollateral(uint256 seed, uint256 amountCollateral) public{
        ERC20Mock collateral = _getCollateralFromSeed(seed);
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(dsce), amountCollateral);
        dsce.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        users.push(msg.sender);
    }

    function mintDsc(uint256 amount, uint256 addressSeed) public{
        if(users.length == 0){
            return;
        }
        address sender = users[addressSeed % users.length];

        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _accountInformation(sender);

        // for over-collateral purpose, you only have to mint upto 50% of your deposited collateral in USD
        // then the already minted amount in USD will be subtracted
        int256 maxDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);
        if(maxDscToMint < 0) {
            return;
        }
        amount = bound(amount, 0, MAX_DEPOSIT);
        if(amount == 0) {
            return;
        }

        vm.startPrank(sender);
        dsce.mintDsc(amount);
        vm.stopPrank();
        timesMinted++;
    }

    function redeemCollateral( uint256 addressSeed, uint256 amountCollateral) public{
        
        ERC20Mock collateral = _getCollateralFromSeed(addressSeed);
        uint256 maxCollateral = dsce.getCollateralbalanceOfUser(address(collateral), msg.sender);

        amountCollateral = bound(amountCollateral, 0, MAX_DEPOSIT);
        if(amountCollateral == 0){
            return;
        }

        dsce.redeemCollateral(address(collateral), amountCollateral);
       
    }

    // function updateCollateralPrice(uint256 newPrice) public{
    //     int256 currentPrice = int256(uint256(newPrice));
     
    //     ethPrice.updateAnswer(newPrice);
    // }

    function _getCollateralFromSeed(uint256 seed) public view returns (ERC20Mock){
        if((seed % 2) == 0) {
            return weth;
        }
        return wbtc;

    }
    
}