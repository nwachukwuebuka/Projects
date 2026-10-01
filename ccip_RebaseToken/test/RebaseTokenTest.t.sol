// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";

contract RebaseTokenTest is Test {
    RebaseToken private rebaseToken;
    Vault private vault;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public{

        vm.startPrank(owner);
        rebaseToken = new RebaseToken();
        vault = new Vault(IRebaseToken(address(rebaseToken)));
        rebaseToken.grantMintAndBurnRole(address(vault));
        vm.stopPrank();

    }

    function addRewardsToVault(uint256 _amount) public {
        (bool success,) = payable(address(vault)).call{value: _amount}("");
      require(success, "Reward transfer failed");

    }

    modifier fundingUser(uint256 amount){ 
        amount = bound(amount, 1e5, type(uint96).max);
        console.log("Deposit: ", amount);

        vm.deal(user, amount);

        vm.startPrank(user);
        _;
        vm.stopPrank();
   
    }

    function testBalanceOfReturnsZeroIfUserHasNoTokens() public view{

       assertEq(rebaseToken.balanceOf(alice), 0);
    }


    function testDeposit(uint256 amount) public{

        amount = bound(amount, 1e5, type(uint96).max);
        

        vm.deal(user, amount);

        vm.startPrank(user);
        vault.deposit{value: amount}();
        uint256 addedBalance = rebaseToken.balanceOf(user);
        console.log("First added Balance: ", addedBalance);
        assertEq(addedBalance, amount);

        vm.warp(block.timestamp + 1 hours);
        uint256 middleBalance = rebaseToken.balanceOf(user);
        console.log("Middle Balance: ", middleBalance);
        assertGt(middleBalance, addedBalance);

        vm.warp(block.timestamp + 1 hours);
        uint256 finalBalance = rebaseToken.balanceOf(user);
        console.log("Final Balance: ", finalBalance);
        assertGt(finalBalance, middleBalance);

        assertApproxEqAbs(finalBalance - middleBalance, middleBalance - addedBalance, 1);
        vm.stopPrank();



    }

    function testRedeemStraightAway(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        console.log("Deposit: ", amount);

        vm.deal(user, amount);

        vm.startPrank(user);
      
        console.log("Balance before redeem: ", rebaseToken.balanceOf(user));
        vault.deposit{value: amount}();
        console.log("Balance after deposit; ", rebaseToken.balanceOf(user));
        assertEq(rebaseToken.balanceOf(user), amount);
        vault.redeem(type(uint256).max);
        console.log("Balance after redeem: ", rebaseToken.balanceOf(user));

        assertEq(rebaseToken.balanceOf(user), 0);
        assertEq(address(user).balance, amount);
        vm.stopPrank();

     }

     function testRedeemAfterSomeTime(uint256 _time, uint256 _amount) public {

        _time = bound(_time, 1000, type(uint32).max);
        _amount = bound(_amount, 1e5, type(uint96).max);

        vm.deal(user, _amount);
        vm.prank(user);
        vault.deposit{value: _amount}();
        console.log("Starting balance: ", rebaseToken.balanceOf(user));

        vm.warp(_time);

        uint256 balanceAfterTime = rebaseToken.balanceOf(user);
        console.log("Funded balance: ", balanceAfterTime);

        // Add rewards to the vault
        vm.deal(owner, balanceAfterTime - _amount);
        vm.prank(owner);
        addRewardsToVault(balanceAfterTime - _amount);

        vm.prank(user); 
        vault.redeem(balanceAfterTime);


        assertEq(address(user).balance, balanceAfterTime);
        assertGt(balanceAfterTime, _amount);



     }

     function testTransfer(uint256 _amount) public{

        _amount = bound(_amount, 1e5, type(uint96).max);
        uint256 amountToSend = _amount - 1e4; // Ensure Alice has enough to send to Bob
        

        vm.deal(alice, _amount);

        vm.startPrank(alice);
        vault.deposit{value: _amount}();
        uint256 initialBalance = rebaseToken.balanceOf(alice);
        console.log("Alice's initial balance: ", initialBalance);
        uint256 initialBobBalance = rebaseToken.balanceOf(bob);
        console.log("Bob's initial balance: ", initialBobBalance);
        assertEq(rebaseToken.balanceOf(alice), _amount);
        assertEq(initialBobBalance, 0);
       
        rebaseToken.transfer(bob, amountToSend);
   
        uint256 afterTransfer = rebaseToken.balanceOf(alice);
        console.log("Alice's balance after transfer: ", afterTransfer);
        console.log("Bob's balance after transfer: ", rebaseToken.balanceOf(bob));


        assertEq(amountToSend, rebaseToken.balanceOf(bob));
        assertEq(rebaseToken.balanceOf(alice), _amount - amountToSend );

        vm.stopPrank();

        vm.prank(owner);
        rebaseToken.setInterestRate(4e10);


     }


    function testTransferMaxAmount() public {
        uint256 amount = 1 ether;

        vm.deal(alice, amount);

        vm.startPrank(alice);

        vault.deposit{value: amount}();

        rebaseToken.transfer(bob, type(uint256).max);

        assertEq(rebaseToken.balanceOf(alice), 0);
        assertEq(rebaseToken.balanceOf(bob), amount);

        vm.stopPrank();
    }

    function testTransferFrom() public {
        // giving another address approval to send your funds
        uint256 amount = 1 ether;

        vm.deal(alice, amount);

        vm.startPrank(alice);
        vault.deposit{value: amount}();
        rebaseToken.approve(bob, amount);
        vm.stopPrank();

        vm.prank(bob);
        rebaseToken.transferFrom(alice, bob, amount);

        assertEq(rebaseToken.balanceOf(bob), amount);
    }

    function testTransferFromMax() public {

        uint256 amount = 1 ether;

        vm.deal(alice, amount);

        vm.startPrank(alice);
        vault.deposit{value: amount}();
        rebaseToken.approve(bob, amount);
        vm.stopPrank();

        vm.prank(bob);
        assertTrue(rebaseToken.transferFrom(alice, bob, type(uint256).max));

        assertEq(rebaseToken.balanceOf(alice), 0);
    }

     function testSetInterestRate(uint256 _interestRate) public{
        // Eg: the original interest rate is 0.5, but we reduced it to 0.4 as contract owner,
        //to see if the contract allows the owner to do that
        //The we deposit some fund, the rule is deposited funds takes the computed interest rate of the system
        // interest rate can only readuce from previously computed interest
        _interestRate = bound(_interestRate, 0, rebaseToken.getInterestRate() - 1);

        vm.prank(owner);
        rebaseToken.setInterestRate(_interestRate);

        uint256 setInterestRate = rebaseToken.getInterestRate();
        assertEq(_interestRate, setInterestRate);
        

        // check user's interest rate when they deposit
        uint256 newBalance = 1e17;
        vm.deal(user, newBalance);
        vm.prank(user);
        vault.deposit{value: newBalance}();

        uint256 userInterestRate = rebaseToken.getUserInterestRate(user);
        console.log("User interest rate: ", userInterestRate);
        assertEq(userInterestRate, setInterestRate);
     }

     function testCannotSetInteretRate(uint256 _newInterestRate) public{
        vm.prank(user);
        vm.expectRevert();
        rebaseToken.setInterestRate(_newInterestRate);
     }

     function testIntestRateCanOnlyReduceAndStopAtZero(uint256 _newInterestRate) public{
        // N/B: interest rates are updated manually by the owner of contract not automatically,
        //after deposit.

        //So it's been done manual, the protocol does not allow the owner to put an mount greater,
        //than the current system interest rate
        //Eg: current interest rate 0.5, new interest rate MUST be 0.5 > n
        
        uint256 currentInterestRate = rebaseToken.getInterestRate();
        console.log("Current interest rate: ", currentInterestRate);
        _newInterestRate = bound(_newInterestRate, currentInterestRate, type(uint96).max);

        vm.prank(owner);
        vm.expectPartialRevert(bytes4(RebaseToken.RebaseToken__InterestRateCanOnlyDecrease.selector));
        rebaseToken.setInterestRate(_newInterestRate);

     }

     function testGetPrincipalAmount(uint256 _amount) public{

        _amount = bound(_amount, 1e5, type(uint96).max);
        
        vm.deal(user, _amount);

        vm.prank(user);
        vault.deposit{value: _amount}();

        uint256 principal = rebaseToken.principalBalanceOf(user);
        
        assertEq(principal, _amount);


        // N/B: Principal MUST remain the same even if time has passed
        vm.warp(block.timestamp + 1 hours);
        uint256 principalAfterWarp = rebaseToken.principalBalanceOf(user);
        
        assertEq(principalAfterWarp, _amount);

     }

    function testIfMintingWorks() public{
      
         uint256 amount = 1e17;
         uint256 interestRate = 1e5;


         vm.prank(owner);
         rebaseToken.grantMintAndBurnRole(address(vault));

         vm.prank(address(vault));
         rebaseToken.mint(user, amount, interestRate);

         uint256 mintedAmount = rebaseToken.balanceOf(user);
         assertEq(amount, mintedAmount);


     }

    function testBurnWorks() public {

        uint256 amount = 1 ether;

        
        vm.prank(owner);
        rebaseToken.grantMintAndBurnRole(address(vault));

        vm.prank(address(vault));

        rebaseToken.mint(user, amount, 5e10);

        vm.prank(address(vault));

        rebaseToken.burn(user, amount);

        assertEq(rebaseToken.balanceOf(user),0);
    }

     function testIfOnlyAssignedRoleCanMintAndBurn() public{

      uint256 amount = 1e17;
      uint256 interestRate = 1e5;


      vm.prank(user);
      vm.expectRevert();
      rebaseToken.mint(user, amount, interestRate);

      vm.deal(bob, amount);
      vm.startPrank(bob);
      vault.deposit{value: amount}();
      vm.expectRevert();
      rebaseToken.burn(bob, 1e6);
      vm.stopPrank();



     }

    function testVaultReceiveWorks() public {


        vm.deal(user, 1 ether);

        vm.prank(user);

        (bool success,) = payable(address(vault)).call{value:1 ether}("");

        assertTrue(success);

        assertEq(address(vault).balance,1 ether);
    }

    function testGetTokenAddress() public view {
        assertEq(vault.getRebaseTokenAddress(), address(rebaseToken));
    }

    function testGrantRole() public {

        address newVault = makeAddr("newVault");
        bytes32 role = rebaseToken.MINT_AND_BURN_ROLE();

        vm.prank(owner);
        rebaseToken.grantMintAndBurnRole(newVault);
        assertTrue(rebaseToken.hasRole(role, newVault));
    }

     


}
