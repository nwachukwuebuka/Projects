// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

////////////////////////////////////////////////
//////////////////// IMPORTS ////////////////////
////////////////////////////////////////////////
import {Test, console} from "forge-std/Test.sol";
import {Vault} from "src/Vault.sol";
import {ZVStoken} from "src/ZVStoken.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.sol";
import {Treasury} from "src/Treasury.sol";

contract VaultTest is Test {
    Vault vault;

    ZVStoken zvs;
    MockV3Aggregator priceFeed;
    Treasury treasury;

    uint256 private constant FUND_AMOUNT = 1e18;
    uint256 private constant REDEEM_AMOUNT = 1e17;
    uint256 private constant MINT_AMOUNT = 1000e18;
    uint256 private constant BURN_AMOUNT = 500e18;
    uint256 private constant GREATER_REDEEM = 2e18;
    uint256 private constant COVER_POSITION = 100e18;
    uint256 private constant EXPECTED_ETH_PRICE = 2000e8;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address owner = makeAddr("owner");

    function setUp() public {
        zvs = new ZVStoken();
        priceFeed = new MockV3Aggregator(8, 2000e8);
        vault = new Vault(address(zvs), address(priceFeed));
        zvs.grantRole(zvs.MINTER_ROLE(), address(vault));
        zvs.grantRole(zvs.BURNER_ROLE(), address(vault));
        treasury = new Treasury(address(vault));

        vault.setTreasuryAddress(address(treasury));

        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    modifier aliceDeposit() {
        vm.prank(alice);
        vault.deposit{value: FUND_AMOUNT}();

        _;
    }

    modifier aliceMint() {
        uint256 balanceBeforeMint = zvs.balanceOf(alice);
        uint256 getCollateralValue = vault.getValueOfCollateralInUsd(alice);
        console.log("Collateral Value in USD: ", getCollateralValue);

        console.log("Initial ZVS tokens: ", balanceBeforeMint);
        assertEq(balanceBeforeMint, 0);

        vm.prank(alice);
        vault.mint(MINT_AMOUNT);

        _;
    }

    function aliceMaxMintAndPriceFall() private {
        uint256 maxdebt = vault.getMaxDebt(alice);
        vm.prank(alice);
        vault.mint(maxdebt);
        (bool safe, uint256 factor) = vault.healthFactor(alice);
        console.log("Initial health factor: ", factor);

        priceFeed.updateAnswer(1000e8);

        (bool safe2, uint256 factor2) = vault.healthFactor(alice);
        console.log("Health Factor after price fall: ", factor2);

        assertLt(factor2, 1e18);
    }

    ////////////////////////////////////////////////
    //////////////////// DEPOSIT ////////////////////
    ////////////////////////////////////////////////

    function testVaultCanBeDepositedTo() public aliceDeposit {
        assertEq(address(vault).balance, FUND_AMOUNT);

        assertEq(vault.collateralBalance(alice), FUND_AMOUNT);
    }

    function testDepositRevertsWhenZero() public {
        vm.prank(alice);

        vm.expectRevert(Vault.Vault__AmountCannotBeZero.selector);
        vault.deposit{value: 0}();
    }

    ////////////////////////////////////////////////
    //////////////////// REDEEM ////////////////////
    ////////////////////////////////////////////////

    function testVaultCanRedeem() public aliceDeposit {
        vm.prank(alice);

        uint256 initialVaultBalance = address(vault).balance;
        vault.redeem(REDEEM_AMOUNT);
        uint256 balanceAfterRedeem = address(vault).balance;

        assertEq(initialVaultBalance, balanceAfterRedeem + REDEEM_AMOUNT);
    }

    function testRedeemRevertsWhenAmountIsZero() public aliceDeposit {
        vm.expectRevert();
        vm.prank(alice);
        vault.redeem(0);
    }

    function testRedeemRevertsIfGreaterThanBalance() public aliceDeposit {
        vm.expectRevert(
            abi.encodeWithSelector(
                Vault.Vault__RedeemAmountCantBeGreaterThanBalance.selector,
                GREATER_REDEEM,
                vault.collateralBalance(alice)
            )
        );
        vm.prank(alice);
        vault.redeem(GREATER_REDEEM);
    }

    function testIfRedeemFailed() public aliceDeposit {
        ReceiveRevert receiveRevert = new ReceiveRevert();

        vm.deal(address(receiveRevert), 1 ether);

        vm.startPrank(address(receiveRevert));
        vault.deposit{value: 1 ether}();

        vm.expectRevert(Vault.Vault__RedeemFailed.selector);
        vault.redeem(0.25 ether);
    }

    ////////////////////////////////////////////////
    //////////////////// MINT ////////////////////
    ////////////////////////////////////////////////

    function testVaultCanMint() public aliceDeposit aliceMint {
        uint256 balanceAfterMint = zvs.balanceOf(alice);
        console.log("ZVS balance after minting: ", balanceAfterMint);

        assertEq(balanceAfterMint, MINT_AMOUNT);
    }

    function testMintAmountIsNotZero() public aliceDeposit {
        vm.expectRevert(Vault.Vault__AmountCannotBeZero.selector);
        vm.prank(alice);
        vault.mint(0);
    }

    function testMaxDebtObatianed() public aliceDeposit {
        uint256 maxdebt = vault.getMaxDebt(alice);

        vm.startPrank(alice);
        vault.mint(maxdebt);
        assertEq(maxdebt, zvs.balanceOf(alice));

        vm.expectRevert(
            abi.encodeWithSelector(Vault.Vault__MaxDebtObtained.selector, maxdebt, vault.totalDebt(alice) + 0.1e18)
        );
        vault.mint(0.1 ether);
        vm.stopPrank();
    }

    ////////////////////////////////////////////////
    //////////////////// BURN ////////////////////
    ////////////////////////////////////////////////

    function testIfVaultCanBurn() public aliceDeposit aliceMint {
        uint256 initialBalance = zvs.balanceOf(alice);
        console.log("Balance before burn: ", initialBalance);

        vm.prank(alice);
        vault.burn(BURN_AMOUNT);

        uint256 balanceAfterBurn = zvs.balanceOf(alice);
        console.log("Balance after burn: ", balanceAfterBurn);

        assertEq(balanceAfterBurn, BURN_AMOUNT);
    }

    function testBurnAmountIsZero() public aliceDeposit aliceMint {
        vm.expectRevert();
        vm.prank(alice);
        vault.burn(0);
    }

    function testBurnAmountGreaterThanDebt() public aliceDeposit aliceMint {
        vm.expectRevert();
        vm.prank(alice);
        vault.burn(MINT_AMOUNT + 0.1 ether);
    }

    ////////////////////////////////////////////////
    //////////////////// BURN AND REDEEM ////////////////////
    ////////////////////////////////////////////////

    function testBurnAndRedeem() public aliceDeposit aliceMint {
        // deposited 1e18///2000e18
        // minted 1000e18
        ///burned 500e18
        /// 500/2000 = 0.25

        console.log("Alice initial Eth balance: ", alice.balance);
        vm.prank(alice);
        vault.burnAndRedeem(BURN_AMOUNT);
        console.log("Alice Final Eth Balance: ", alice.balance);

        assertEq(alice.balance, 0.25 ether);
    }

    function testBurnAndRedeemAmountIsZero() public aliceDeposit aliceMint {
        vm.expectRevert();
        vm.prank(alice);
        vault.burnAndRedeem(0);
    }

    function testBurnAndRedeemfailed() public {
        ReceiveRevert receiveRevert = new ReceiveRevert();

        vm.deal(address(receiveRevert), 2 ether);

        vm.startPrank(address(receiveRevert));
        vault.deposit{value: 1 ether}();

        vault.mint(MINT_AMOUNT);

        vm.expectRevert();
        vault.burnAndRedeem(MINT_AMOUNT);
        vm.stopPrank();
    }

    ////////////////////////////////////////////////
    //////////////////// HEALTH FACTOR ////////////////////
    ////////////////////////////////////////////////

    function testHealthFactorIsGreaterThanOne() public aliceDeposit aliceMint {
        //13333e18
        (bool safe, uint256 factor) = vault.healthFactor(alice);
        console.log("Health factor: ", factor);

        assertGt(factor, 1e18);
    }

    function testHealthFactorIsOne() public aliceDeposit {
        uint256 maxdebt = vault.getMaxDebt(alice);
        vm.prank(alice);
        vault.mint(maxdebt);
        (bool safe, uint256 factor) = vault.healthFactor(alice);
        console.log("Health factor: ", factor);

        assertEq(factor, 1e18);
    }

    function testHealthFactorLessThanOne() public aliceDeposit {
        aliceMaxMintAndPriceFall();
    }

    function testHealthFactorWhenDebtIsZero() public aliceDeposit {
        (bool safe, uint256 factor) = vault.healthFactor(alice);

        assertTrue(safe);
        assertEq(factor, type(uint256).max);
    }

    ////////////////////////////////////////////////
    //////////////////// LIQUIDATION ////////////////////
    ////////////////////////////////////////////////

    function testLiquidationAmountIsZero() public aliceDeposit {
        aliceMaxMintAndPriceFall();

        vm.startPrank(bob);
        vault.deposit{value: 1 ether}();
        uint256 maxdebt2 = vault.getMaxDebt(bob);
        console.log("bob max debt: ", maxdebt2);

        vault.mint(MINT_AMOUNT);

        vm.expectRevert();
        vault.liquidate(alice, 0);
        vm.stopPrank();
    }

    function testSelfLiquidation() public aliceDeposit {
        aliceMaxMintAndPriceFall();

        vm.expectRevert();
        vm.prank(alice);
        vault.liquidate(alice, 100e18);
    }

    function testHealthFactorIsSafe() public aliceDeposit aliceMint {
        (bool safe, uint256 factor) = vault.healthFactor(alice);
        console.log("alice health factor: ", factor);

        vm.startPrank(bob);
        vault.deposit{value: 1 ether}();
        vault.mint(MINT_AMOUNT);

        vm.expectRevert();
        vault.liquidate(alice, COVER_POSITION);
        vm.stopPrank();
    }

    ////////////////////////////////////////////////
    //////////////////// CHAINLINK ////////////////////
    ////////////////////////////////////////////////

    function testEthPriceInUsd() public {
        uint256 expectedEthPrice = 2000e8;

        uint256 price = vault.getEthPriceInUsd();

        assertEq(price, expectedEthPrice);
    }

    function testEthPriceIsZero() public {
        priceFeed.updateAnswer(0);

        vm.expectRevert();
        vault.getEthPriceInUsd();
    }

    function testPriceIsStale() public {
        priceFeed.updateAnswer(2000e8); //updatedAt

        vm.warp(block.timestamp + 1 hours + 1); // current block.timestamp

        vm.expectRevert();
        vault.getEthPriceInUsd();
    }

    function testValueOfCollateralInUsd() public aliceDeposit {
        uint256 aliceCollateral = vault.collateralBalance(alice);
        assertEq(aliceCollateral, FUND_AMOUNT);

        uint256 aliceCollateralValueInUsd = vault.getValueOfCollateralInUsd(alice);

        assertEq(aliceCollateralValueInUsd, 2000e18);
    }

    ////////////////////////////////////////////////
    //////////////////// GETTERS ////////////////////
    ////////////////////////////////////////////////

    function testGetZVSTokenAddress() public {
        address zvsAddress = address(zvs);

        address zvsInVault = vault.getZVSTokenAddress();
        assertEq(zvsAddress, zvsInVault);
    }

    function testPriceFeedAddress() public {
        address mockAddress = address(priceFeed);

        address mockAddressInVault = vault.getPriceFeedAddress();

        assertEq(mockAddress, mockAddressInVault);
    }

    function testTreasuryAddress() public {
        address treasuryAddress = address(treasury);

        address treasuryInVault = vault.getTreasuryAddress();

        assertEq(treasuryAddress, treasuryInVault);
    }

    ////////////////////////////////////////////////
    //////////////////// EVENTS ////////////////////
    ////////////////////////////////////////////////

    function testDepositedEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Vault.Deposited(alice, 1 ether);
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
    }

    function testRedeemedEmitsEvent() public aliceDeposit {
        vm.expectEmit(true, false, false, true);
        emit Vault.Redeemed(alice, FUND_AMOUNT);
        vm.prank(alice);
        vault.redeem(FUND_AMOUNT);
    }

    function testMintedEmitsEvent() public aliceDeposit {
        vm.expectEmit(true, false, false, true);
        emit Vault.Minted(alice, MINT_AMOUNT);
        vm.prank(alice);
        vault.mint(MINT_AMOUNT);
    }

    function testBurnedEmitsEvent() public aliceDeposit aliceMint {
        vm.expectEmit(true, false, false, true);
        emit Vault.Burned(alice, BURN_AMOUNT);

        vm.prank(alice);
        vault.burn(BURN_AMOUNT);
    }

    function testBurntAndRedeemedEmitsEvents() public aliceDeposit aliceMint {
        vm.expectEmit(true, false, false, true);
        emit Vault.BurntAndRedeemed(alice, BURN_AMOUNT);

        vm.prank(alice);
        vault.burnAndRedeem(BURN_AMOUNT);
    }

    // function testLiquidateEmitsEvent() public{

    // }
}

contract ReceiveRevert {
    receive() external payable {
        revert();
    }
}
