
//SPDX-License-Identifier: MIT

pragma solidity  ^0.8.24;

  /*//////////////////////////////////////////////////////
                         IMPORTS
  /////////////////////////////////////////////////////*/




/**
* @title
* @author 
* @notice
* @dev
* @param 
 */
contract Register{

    /*//////////////////////////////////////////////////////
            CONSTANTS, IMMUTABLES AND STATE VARIABLES
    ////////////////////////////////////////////////////*/

    address[] private s_customerAddresses;

        /*//////////////////////////////////////////////////////
                            CUSTOM ERRORS
        ////////////////////////////////////////////////////*/
        error Err_addressInUse();

    function createAccount(){


        /**
        * @notice Go through the list of already resgistered addresses, if user is already available the flag an error
         */
        for(int i = 0; i < s_customerAddresses.length; i++){
             if(msg.sender == s_customerAddresses[i]){
                revert Err_addressInUse();
             }else{
                 s_customerAddresses.push(msg.sender);
             }
        }

    }
    function deposite(){}
    function makeTranser(){}
    function checkBalance(){}
    function accessDetails(){}
    function deleteAccount(){}

}