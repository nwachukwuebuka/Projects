// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

///@title Zhevezius Vault
///@author Nwachukwu Chukwuebuka
///@notice The Vault is reponsible for depositing: sending collaterals to the token.
///                                    USD covertion: calculating the value of collaterals in USD.
///                                    minting: using the deposited collateral and mint ZVS tokens based on 150% overcollaterization.
///                                    burning: coverting the ZVS tokens back to worth of collateral.
///                                    redeeming: withdrawing collaterals out of the protocol.
///@dev IZVStoken interface is used to communicate with the ZVStoken contract.
///     Chainlink price feeds for realtime price conversion.
///
/// N/B: Debt is only inquired by the minting addresses...............token transfers are debt free.
///      Minting 2/3 as tokens and 1/3 stands as fixed collateral.

////////////////////////////////////////////////
//////////////////// IMPORTS ////////////////////
////////////////////////////////////////////////
import {IZVStoken} from "src/interfaces/IZVStoken.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {ITreasury} from "src/interfaces/ITreasury.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is Ownable {
    ////////////////////////////////////////////////
    //////////////////// ERRORS ////////////////////
    ////////////////////////////////////////////////
    error Vault__AmountCannotBeZero();
    error Vault__RedeemAmountCantBeGreaterThanBalance(uint256 amount, uint256 userBalance);
    error Vault__RedeemFailed();
    error Vault__InvalidPrice();
    error Vault__MaxDebtObtained(uint256 maxDebt, uint256 newDebt);
    error Vault__StalePrice();
    error Vault__BurnAmountGreaterThanDebt();
    error Vault__BurnAndRedeemFailed();
    error Vault__SelfLiquidationDetected();
    error Vault__HealthFactorIsSafe();
    error Vault__TransferToTreasuryFailed();

    ////////////////////////////////////////////////
    //////////////////// EVENTS ////////////////////
    ////////////////////////////////////////////////
    event Deposited(address indexed user, uint256 amount);
    event Redeemed(address user, uint256 amount);
    event Minted(address user, uint256 amount);
    event Burned(address user, uint256 amount);
    event BurntAndRedeemed(address user, uint256 amount);
    event Liquidated(address liquidator, address debtor, uint256 amountToCover);

    ////////////////////////////////////////////////
    //////////////////// VARAIBLES ////////////////////
    ////////////////////////////////////////////////
    uint256 private constant PRECISION = 1e18;
    uint256 private constant PRICE_FEED_PRECISION = 1e8;
    uint256 private constant COLLATERAL_RATIO = 200;
    uint256 private constant LIQUIDATION_THRESHOLD = 80;
    uint256 private constant LIQUIDATION_THRESHOLD_PRECISION = 100;
    uint256 private constant MAX_PRICE_TIMEOUT = 1 hours;
    mapping(address user => uint256 amount) public collateralBalance;
    mapping(address user => uint256 amount) public totalDebt;
    uint256 public feesSentToTreasury;

    IZVStoken private immutable i_zvsToken;
    AggregatorV3Interface private immutable i_priceFeed;
    ITreasury private treasury;

    ////////////////////////////////////////////////
    //////////////////// MODIFIERS ////////////////////
    ////////////////////////////////////////////////
    modifier zeroCheck(uint256 _amount) {
        if (_amount == 0) {
            revert Vault__AmountCannotBeZero();
        }
        _;
    }

    ////////////////////////////////////////////////
    //////////////////// FUNCTIONS ////////////////////
    ////////////////////////////////////////////////

    ///@dev The constructor recieves the:
    ///@param _zvsToken Address of the token contract... which will be type casted into the interface(IZVStoken),
    ///                 because the full token implemenattion is not needed.
    ///@param _priceFeed Address of the chainlink, for realtime collateral valuation in USD,
    ///                  which will be type casted into the AggregatorV3Interface.
    constructor(address _zvsToken, address _priceFeed) Ownable(msg.sender) {
        i_zvsToken = IZVStoken(_zvsToken);
        i_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    //helper function
    function setTreasuryAddress(address _treasury) external onlyOwner {
        treasury = ITreasury(_treasury);
    }

    ///@notice Gets collateral into the protocol.
    ///@dev Needs two parameter to make the call:
    ///     "user" The address making the deposit
    ///     "amount" Amount of collateral to deposit
    function deposit() external payable zeroCheck(msg.value) {
        address user = msg.sender;
        uint256 amount = msg.value;

        collateralBalance[user] += amount;
        emit Deposited(user, amount);
    }

    ///@notice Withdraws the collateral out of the protocol.
    ///@param _amount The amount of collateral you want to withdraw
    ///@dev Checks before redeeming:
    ///         1. "_amount" must be less than zero.
    ///         2. "_amount" must not be greater than the collateral balance of user.
    ///         3. Vault itself will have enough Collateral.
    function redeem(uint256 _amount) external zeroCheck(_amount) {
        if (_amount > collateralBalance[msg.sender]) {
            revert Vault__RedeemAmountCantBeGreaterThanBalance(_amount, collateralBalance[msg.sender]);
        }

        collateralBalance[msg.sender] -= _amount;

        // payable(msg.sender).transfer(_amount);
        (bool success,) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }

        emit Redeemed(msg.sender, _amount);
    }

    ///@notice Mints the ZVS tokens if it has enough collateral.....MUST mint only MAX of 2/3 of total collateral value.
    ///@dev user calls the mint function here in the Vault contract, then Vault calls the ZVStoken contract
    ///@param _amount The amount of ZVS token to be minted
    function mint(uint256 _amount) external zeroCheck(_amount) {
        // this refers to the MAX amount of ZVS tokens a user can minting following their collateral value.
        //i.e mint 2/3 of total collateral value, leaving 1/3 as fixed collateral
        uint256 maxDebt = getMaxDebt(msg.sender); // the total collateral is been converted to USD,
        //with that the toatl number of zvs to minted is determined.

        uint256 newDebt = totalDebt[msg.sender] + _amount;

        totalDebt[msg.sender] = newDebt;
        if (newDebt > maxDebt) {
            revert Vault__MaxDebtObtained(maxDebt, newDebt);
        }

        i_zvsToken.mint(msg.sender, _amount);

        emit Minted(msg.sender, _amount);
    }

    function getMaxDebt(address _user) public view returns (uint256) {
        return (getValueOfCollateralInUsd(_user) * 200) / COLLATERAL_RATIO;
    }

    function burnCheck(address _user, uint256 _amount) internal {
        uint256 debt = totalDebt[_user];

        if (_amount > debt) {
            revert Vault__BurnAmountGreaterThanDebt();
        }
    }

    ///@notice Burns the tokens of the user
    ///@param _amount Amount of ZVS tokens user wants to burn
    ///@dev address is msg.sender, perforsm few checks before burn:
    ///              1. amount should not be zero (zeroCheck)
    ///              2. address should bot burn more than the number of token it has
    function burn(uint256 _amount) public zeroCheck(_amount) {
        burnCheck(msg.sender, _amount);

        totalDebt[msg.sender] -= _amount;
        i_zvsToken.burn(msg.sender, _amount);

        uint256 collateralToken = convertBurnAmountToCollateral(_amount);
        collateralBalance[msg.sender] += collateralToken;

        emit Burned(msg.sender, _amount);
    }

    ///@notice A function that burns and redeems at once
    function burnAndRedeem(uint256 _amount) external zeroCheck(_amount) {
        burn(_amount);
        uint256 convertedBurnAmount = convertBurnAmountToCollateral(_amount);

        collateralBalance[msg.sender] -= convertedBurnAmount;

        (bool success,) = msg.sender.call{value: convertedBurnAmount}("");
        if (!success) {
            revert Vault__BurnAndRedeemFailed();
        }
        emit BurntAndRedeemed(msg.sender, _amount);
    }

    function convertBurnAmountToCollateral(uint256 _amount) internal view returns (uint256) {
        return (_amount * PRICE_FEED_PRECISION) / getEthPriceInUsd();
    }

    ////////////////////////////////////////////////
    //////////////////// LIQUIDATION ////////////////////
    ////////////////////////////////////////////////

    ///@notice Liquidation helps the protocol to stay safe, making other users cover the debt of an unsafe position
    ///        Health Factor
    function healthFactor(address _user) public view returns (bool _safe, uint256 _healthfactor) {
        uint256 currentDebt = totalDebt[_user];

        if (currentDebt == 0) {
            return (true, type(uint256).max);
        }

        uint256 maxdebt = getMaxDebt(_user);

        _healthfactor = maxdebt * PRECISION / currentDebt;

        _safe = _healthfactor >= 1e18;
    }

    function liquidate(address _user, uint256 _positionToCover) external zeroCheck(_positionToCover) {
        if (msg.sender == _user) {
            revert Vault__SelfLiquidationDetected();
        }

        (bool safe,) = healthFactor(_user);

        if (safe) {
            revert Vault__HealthFactorIsSafe(); // revert only works if the condition is true
        }

        //insures the _positionToCover is not more than _user debt
        burnCheck(_user, _positionToCover);

        //getting tokens from liquidator
        i_zvsToken.transferFrom(msg.sender, address(this), _positionToCover);

        //burn liquidator's token
        i_zvsToken.burn(msg.sender, _positionToCover);

        //reduce debt of debtor
        totalDebt[_user] -= _positionToCover;

        //LIQUIDATION BONUS
        // eg: postionToCover 100 ZVS
        uint256 liquidationReward = (_positionToCover * 10) / 100; // reward 10 ZVS

        uint256 protocolFee = (liquidationReward * 5) / 100; //5% of 10 ZVS = 0.5 ZVS

        uint256 rewardAfterFee = liquidationReward - protocolFee; //10 - 0.5 = 9.5 ZVS

        uint256 totalCalculatedReward = _positionToCover + rewardAfterFee; // 100 + 9.5 = 109.5

        uint256 tokenToCollateral = convertBurnAmountToCollateral(totalCalculatedReward);
        uint256 protocolFeeToCollateral = convertBurnAmountToCollateral(protocolFee);

        // deduct the positionCovered + bonus from debtor's collateralBalance
        collateralBalance[_user] -= tokenToCollateral;

        //update liqudator's balance
        collateralBalance[msg.sender] += tokenToCollateral;

        //send protocolFeeCollateral to the Treasury
        // (bool success,) = payable(address(i_treasury)).call{value: protocolFeeToCollateral}("");
        // if(!success){
        //     revert Vault__TransferToTreasuryFailed();
        // }
        treasury.recieveFees{value: protocolFeeToCollateral}();

        //update total fees sent to treasury
        feesSentToTreasury += protocolFeeToCollateral;

        emit Liquidated(msg.sender, _user, _positionToCover);
    }

    ////////////////////////////////////////////////
    //////////////////// CHAINLINK ORACLE ////////////////////
    ////////////////////////////////////////////////

    /// @notice Returns the current ETH price in USD.
    /// @dev Chainlink ETH/USD feeds return prices with 8 decimals.
    /// @return The ETH price with 8 decimal precision.
    function getEthPriceInUsd() public view returns (uint256) {
        (, int256 price,, uint256 updatedAt,) = i_priceFeed.latestRoundData();

        if (price <= 0) {
            revert Vault__InvalidPrice();
        }
        if (block.timestamp - updatedAt > MAX_PRICE_TIMEOUT) {
            revert Vault__StalePrice();
        }
        return uint256(price);
    }

    ///@notice Converting each user collaterals to value in USD.
    ///@param _user Address of the user whose collateral value is ti be calculated.
    ///@dev we needed:
    ///        "PRICE_FEED_PRECISION" because the chainlink returns answers in 8 decimals,
    ///         and it's meant to be cancelled out.
    function getValueOfCollateralInUsd(address _user) public view returns (uint256) {
        uint256 collateralDeposited = collateralBalance[_user];

        return collateralDeposited * getEthPriceInUsd() / PRICE_FEED_PRECISION;
    }

    function getZVSTokenAddress() public returns (address) {
        return address(i_zvsToken);
    }

    function getPriceFeedAddress() public returns (address) {
        return address(i_priceFeed);
    }

    function getTreasuryAddress() public returns (address) {
        return address(treasury);
    }
}
