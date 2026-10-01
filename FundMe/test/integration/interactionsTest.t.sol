// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";

/**
 * @title Interactions Test
 * @author Luiz Toreno
 * @notice Allows sending and withdrawiing funds
 * @dev Prevents running the DeployFundMe.sol multiple times, in oder to call the fundMe.fund() and fundMe.withdraw()
 */

// contract InteractionsTest is Test{
//     FundMe fundMe;

//     address test_user = makeAddr("user");
//     uint256 constant INITIAL_BALANCE = 10 ether;

//     function setUp() external{
//         DeployFundMe deploy = new DeployFundMe();
//         fundMe = deploy.run();
//         vm.deal(test_user, INITIAL_BALANCE);
//     }

//     function test_userCanInteract() public{
//         FundFundMe ffm = new FundFundMe();
//         // vm.deal(address(ffm), 1 ether);
//         ffm.fundFundMe(address(fundMe));

//         WithdrawFundMe wfm = new WithdrawFundMe();
//         wfm.withdrawFundMe(address(fundMe));

//         assert(address(fundMe).balance == 0);
//     }
// }

contract InteractionsTest is Test {
    FundMe fundMe;

    address test_user = makeAddr("user");
    uint256 constant INITIAL_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();

        vm.deal(test_user, INITIAL_BALANCE);
    }

    function test_userCanInteract() public {
        FundFundMe ffm = new FundFundMe();
        WithdrawFundMe wfm = new WithdrawFundMe();

        // ✅ Give the script ETH so it can fund
        vm.deal(address(ffm), 1 ether);

        // fund contract
        ffm.fundFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0.5 ether);

        // withdraw
        wfm.withdrawFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}
