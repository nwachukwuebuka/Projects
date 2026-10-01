//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address test_user = makeAddr("user"); // creating a fake user/funder
    uint256 constant FUND_AMOUNT = 1 ether;
    uint256 constant INITIAL_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(*************......);

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        vm.deal(test_user, INITIAL_BALANCE); //funding the fake user, so it's been funded immdiately this contract runs
    }

    function testCheckMinUSD() public view {
        assertEq(fundMe.MIN_USD(), 5e18);
    }

    function test_OwnerIsDeployer() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_PriceFeedVersionMatchesNetwork() public {
        uint256 version = fundMe.getVersion();
        console.log("Chain ID:", block.chainid);

        if (block.chainid == 1) {
            version = fundMe.getVersion();
            assertEq(version, 6);
        } else if (block.chainid == 11155111) {
            version = fundMe.getVersion();
            assertEq(version, 4);
        }
    }

    // FUNDME functions TESTS
    function test_FundingFailsWithoutEnoughEth() public {
        vm.expectRevert();

        fundMe.fund();
    }

    modifier m_fund_test_user() {
        vm.prank(test_user); //next transaction will be from this address
        fundMe.fund{value: FUND_AMOUNT}();

        _;
    }

    function test_FundingUpdatesMapping() public m_fund_test_user {
        uint256 addressToAmout = fundMe.getAddressToAmountFunded(test_user);
        assertEq(addressToAmout, FUND_AMOUNT);
    }

    function test_funderAddedToFundersArray() public m_fund_test_user {
        address funder = fundMe.getFunder(0);
        assertEq(test_user, funder);
    }

    function test_ifOnlyOwnerWithDraws() public m_fund_test_user {
        vm.expectRevert();
        vm.prank(test_user);
        fundMe.withdraw();
    }

    function test_withdrawForSingleFunder() public m_fund_test_user {
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeBalanceBeforeWithdrawal = address(fundMe).balance;

        uint256 startingGas = gasleft();

        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingGas = gasleft();

        uint256 priceOfGasUsed = (startingGas - endingGas) * tx.gasprice;

        console.log(startingGas);
        console.log(endingGas);
        console.log(priceOfGasUsed);

        uint256 ownerEndingBalance = fundMe.getOwner().balance; //all funds will go to deploying address
        uint256 fundMeBalanceAfterWithdrawal = address(fundMe).balance; // contract will have zero fund 0

        assertEq(fundMeBalanceAfterWithdrawal, 0);
        assertEq(ownerStartingBalance + fundMeBalanceBeforeWithdrawal, ownerEndingBalance);
    }

    function test_withDrawForMultipleFunders() public {
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            vm.startPrank(address(i));

            vm.deal(address(i), INITIAL_BALANCE);
            fundMe.fund{value: FUND_AMOUNT}();

            vm.stopPrank();

            // hoax(address(i), INITIAL_BALANCE);
            // fundMe.fund{value: FUND_AMOUNT}();
        }
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeBalanceBeforeWithdrawal = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(ownerStartingBalance + fundMeBalanceBeforeWithdrawal, address(fundMe.getOwner()).balance);
    }
}
