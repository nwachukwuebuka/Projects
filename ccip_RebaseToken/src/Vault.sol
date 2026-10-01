// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;


import {IRebaseToken} from "./interfaces/IRebaseToken.sol";


contract Vault{

    //errors
    error Vault__RedeemFailed();

    //varaibles
    IRebaseToken private immutable i_rebaseToken;


    //events
    event Deposit(address indexed user, uint256 value);
    event RedeemSuccess(address indexed user, uint256 value);



    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

     // allows the contract to receive rewards
    receive() external payable {}



    function deposit() external payable{
        uint256 interest = i_rebaseToken.getInterestRate();
    
        i_rebaseToken.mint(msg.sender, msg.value, interest);

        emit Deposit(msg.sender, msg.value);
    }


    function redeem(uint256 _amount) external{
        if(_amount == type(uint256).max){
             _amount = i_rebaseToken.balanceOf(msg.sender);
         }

        i_rebaseToken.burn(msg.sender, _amount);

        // payable(msg.sender).transfer(_amount);
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if(!success){
            revert Vault__RedeemFailed();
        }

        emit RedeemSuccess(msg.sender, _amount);


    }

    function getRebaseTokenAddress() external view returns(address){
        return address(i_rebaseToken);
    }

}