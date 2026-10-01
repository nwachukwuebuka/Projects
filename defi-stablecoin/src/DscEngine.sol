// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DecentralisedStablecoin} from "./DecentralisedStablecoin.sol";

contract DscEngine is ReentrancyGuard {
      ////////////////////////////////////////////
     //              ERRORS                    //
    ////////////////////////////////////////////
        error DscEngine__TokenAddressANDpriceFeedAddressMUSTmatchSameLength();
        error DscEngine__NeedsMoreThanZero();
        error DscEngine__TransferFailed();
        error DSCEngine__BreaksHealthFactor(uint256 userHealthFactor);
        error DscEngine__MintFailed();
        error DscEngine__NotAllowedToken();
        error DscEngine__HealthFactorOk();
        error DscEngine__HealthFactorNotImproved();

      ////////////////////////////////////////////
     //           STATE VARIABLES              //
    ////////////////////////////////////////////
        uint256 private constant PRECISION = 1e18;
        uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
        uint256 private constant LIQUIDATION_THRESHOLD = 50;
        uint256 private constant LIQUIDATION_PRECISION = 100; // means 100%
        uint256 private constant MIN_HEALTH_FACTOR = 1e18;
        uint256 private constant LIQUIDATION_BONUS = 10; //means 10%

        mapping(address tokenAddress => address priceFeed) private s_priceFeedAddresses; //(weth, btc) = (2e18, 7e18);

        mapping(address user => mapping(address token => uint256 amountCollateral)) private s_collateralDeposited; 
        mapping(address user => uint256 amountDscMinted) private s_DscMinted;
        address[] private s_collateralTokens; 

        DecentralisedStablecoin private immutable i_dsc;

      ////////////////////////////////////////////
     //              EVENTS                    //
    ////////////////////////////////////////////
        event CollateralDeposited(address indexed user, address indexed token, uint256 amount);
        event CollateralRedeemed(address fromliquidated, address indexed toliquidator, address indexed tokenCollateralAddress, uint256 amountCollateral);


      ////////////////////////////////////////////
     //             MODIFIERS                  //
    ////////////////////////////////////////////
        modifier moreThanZero(uint256 amount) {
            if (amount == 0) {
                revert DscEngine__NeedsMoreThanZero();
            }
            _;
        }
        modifier isAllowedToken(address tokenAddress) {
            if (s_priceFeeds[tokenAddress] == address(0)) {
                revert DscEngine__NotAllowedToken();
            }
            _;
        }


      ////////////////////////////////////////////
     //              CONSTRUCTOR               //
    ////////////////////////////////////////////

    /** 
    * @notice Initializes the DSC Engine
    * @param tokenAddresses Array of collateral token addresses
    * @param priceFeedAddresses Array of Chainlink price feed addresses
    * @param dscAddress Address of the Decentralized Stable Coin contract
    *
    * Requirements:
    * - tokenAddress.length must equal priceFeedAddress.length
    * - Each collateral token must have a corresponding price feed
    */

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DscEngine__TokenAddressANDpriceFeedAddressMUSTmatchSameLength();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralisedStablecoin(dscAddress);
    }


      ////////////////////////////////////////////
     //            DEPOSIT AND MINT            //   
    ////////////////////////////////////////////     

    // using SafeERC20 for IERC20;
    function depositCollateral(address tokenAddress, uint256 amountCollateral)
        public
        moreThanZero(amountCollateral)
        isAllowedToken(tokenAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenAddress, amountCollateral);

        bool success = IERC20(tokenAddress).transferFrom(msg.sender, address(this), amountCollateral);

        if (!success) {
            revert DscEngine__TransferFailed();
        }
    //  IERC20 token = IERC20(tokenAddress);

    //  require(
    //     token.balanceOf(msg.sender) >= amountCollateral,
    //     "Not enough balance"
    //  );

    //  s_collateralDeposited[msg.sender][tokenAddress] += amountCollateral;
    //  emit CollateralDeposited(msg.sender, tokenAddress, amountCollateral);

    //  token.safeTransferFrom(msg.sender, address(this), amountCollateral);

    }

    function mintDsc(uint256 amountDscToMint) public moreThanZero(amountDscToMint) nonReentrant {
        s_DscMinted[msg.sender] += amountDscToMint;

        _revertIfHealthFactorIsBroken(msg.sender);

        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DscEngine__MintFailed();
        }
    }
    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
        
    }

    function __healthFactor(address user) private view returns (uint256) {

        (uint256 totalDscMinted, uint256 collateralValueInUsd) = __accountInformation(user);
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
    }
            function _calculateHealthFactor(uint256 totalDscMinted, uint256 collateralValueInUsd) internal pure returns (uint256){

                    if (totalDscMinted == 0) return type(uint256).max;

                    uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
                    return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
            }


    function __accountInformation(address user) private view returns (uint256 totalDscMinted, uint256 collateralValueInUsd){
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = totalAccountCollateralValue(user);
    }
            function _totalAccountCollateralValue(address user) external view returns (uint256) {
                for (uint256 index = 0; index < s_collateralTokens.length; index++) {
                    address token = s_collateralTokens[index];
                    uint256 amount = s_collateralDeposited[user][token];
                    totalCollateralValueInUsd += _usdValue(token, amount);
                }
                return totalCollateralValueInUsd;
            }

            function __usdValue(address tokenAddress, uint256 amount) private view returns (uint256) {
                AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeedAddresses[tokenAddress]);
                (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
                // 1 ETH = 1000 USD
                // The returned value from Chainlink will be 1000 * 1e8
                // Most USD pairs have 8 decimals, so we will just pretend they all do
                // We want to have everything in terms of WEI, so we add 10 zeros at the end
                return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
            }

    function _depositCollateralAndMintDsc(address tokenAddress, uint256 amountCollateral, uint256 amountDscToMint) external {
        depositCollateral(tokenAddress, amountCollateral);
        mintDsc(amountDscToMint);
    }


      ////////////////////////////////////////////
     //            BURN AND REDEEM             //
    ////////////////////////////////////////////

    /**
     * @notice Burns DSC tokens from a user's account
     * @param amountToBurn The amount of DSC to burn
     * @param onBehalfOf The address of the user whose tokens to burn
     * @param toLiquidator The address of the liquidator receiving the tokens
     * @dev This function is private and only used during liquidation.
     */
    function __burnDsc(uint256 amountToBurn, address onBehalfOf, address toLiquidator) private{
        s_DscMinted[onBehalfOf] -= amountToBurn;
        bool success = i_dsc.transferFrom(onBehalfOf, toLiquidator, amountToBurn);
        if (!success) {
            revert DscEngine__TransferFailed();
        }
        i_dsc.burn(amountToBurn);
    }

    function burnDsc(uint256 amount) public moreThanZero(amount) nonReentrant {
        __burnDsc(amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender); // I don't think this would ever hit...
    }


     function __redeemCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        address from,
        address to
    )
        private
    {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        emit CollateralRedeemed(from, to, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateral(address tokenAddress, uint256 amount) public moreThanZero(amount) nonReentrant{
        _redeemCollateral(tokenAddress, amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }


    function eBurnAndRedeemCollateral(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToBurn) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress){
        __burnDsc(amountDscToBurn, msg.sender, msg.sender);
        _redeemCollateral(tokenCollateralAddress, amountCollateral, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }


      ////////////////////////////////////////////
     //                LIQUIDATE               //
    ////////////////////////////////////////////

    function eLiquidate(address tokenCollateral, address user, uint256 debtAmountToCover) external moreThanZero(debtAmountToCover) nonReentrant{

        uint256 startingHealthFactor = _healthFactor(user);
        
        if (startingHealthFactor >= MIN_HEALTH_FACTOR){
            revert DscEngine__HealthFactorOk();
        }

        uint256 amountOfBackingToken = getTokenAmountFromUsd(tokenCollateral, debtAmountToCover);

        uint256 bonusCollateral = (amountOfBackingToken * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;


         _redeemCollateral(tokenCollateral, debtToCoverInUsd + bonusCollateral, user, msg.sender);
        _burnDsc(debtAmountToCover, user, msg.sender);

        uint256 endingHealthFactor = _healthFactor(user);
        // This conditional should never hit, but just in case
        if (endingHealthFactor <= startingHealthFactor) {
            revert DscEngine__HealthFactorNotImproved();
        }
        _revertIfHealthFactorIsBroken(msg.sender);

        }
            function tokenAmountFromUsd(address tokenAddress, uint256 usdAmount) public view returns (uint256){
                AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeedAddresses[tokenAddress]);

                (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();

                return (usdAmount * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION);
            }


      ////////////////////////////////////////////
     //                GETTERS                 //
    ////////////////////////////////////////////

    function getHealthFactorCalculation (uint256 totalDscMinted, uint256 collateralValueInUsd) external view returns (uint256) {
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);;
    }
    
    function getTotalAccountCollateralValue(address user) external view returns (uint256) {
        return totalAccountCollateralValue(user);
    }

    function getAccountInformation( address user) external view returns (uint256 totalDscMinted, uint256 collateralValueInUsd) {
        (totalDscMinted, collateralValueInUsd) = _accountInformation(user);
    }

    function getUsdValue(address token, uint256 amount) external view returns (uint256) {
        return _usdValue(token, amount);
    }
    
    function getCollateralBalanceOfUser(address user, address token) external view returns (uint256) {
        return s_collateralDeposited[user][token];
    }

    function getTokenAmountFromUsd(address token, uint256 usdAmount) external view returns (uint256) {
        return tokenAmountFromUsd(token, usdAmount);
    } 

     function getPrecision() external pure returns (uint256) {
        return PRECISION;
    }

    function getAdditionalFeedPrecision() external pure returns (uint256) {
        return ADDITIONAL_FEED_PRECISION;
    }

    function getLiquidationThreshold() external pure returns (uint256) {
        return LIQUIDATION_THRESHOLD;
    }

    function getLiquidationBonus() external pure returns (uint256) {
        return LIQUIDATION_BONUS;
    }

    function getLiquidationPrecision() external pure returns (uint256) {
        return LIQUIDATION_PRECISION;
    }

    function getMinHealthFactor() external pure returns (uint256) {
        return MIN_HEALTH_FACTOR;
    }

    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokens;
    }

    function getDsc() external view returns (address) {
        return address(i_dsc);
    }

    function getCollateralTokenPriceFeed(address token) external view returns (address) {
        return s_priceFeeds[token];
    }

    function getHealthFactor(address user) external view returns (uint256) {
        return _healthFactor(user);
    }
 

}
