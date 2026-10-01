// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";




/**
*@title
*@author
*@notice
*@dev this has two formulats
balance = principal * (interestFactor)

where 1 + (interestRate * timeElapsed) is linearGrowth

 */

contract RebaseToken is ERC20, Ownable, AccessControl{

    
      /////////////////////////////////////////
     //            ERRORS                   //
    /////////////////////////////////////////
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 s_interestRate, uint256 _newInterestRate);


      /////////////////////////////////////////
     //            VARIABLES                //
    /////////////////////////////////////////
    uint256 private constant PRECISION_FACTOR = 1e18;
    bytes32 public constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");
    uint256 private s_interestRate = 5e10; // (5 * PRECISION_FACTOR) / 1e18; 
    mapping(address user => uint256) private s_userInterestRate;
    mapping(address user => uint256) private s_userLastUpdatedTimestamp;

     
      /////////////////////////////////////////
     //              EVENTS                 //
    /////////////////////////////////////////
    event InterestRate(uint256 indexed _newInterestRate);

    
      /////////////////////////////////////////
     //             FUNCTIONS               //
    /////////////////////////////////////////

    constructor() ERC20("Rebase Token", "RBT") Ownable(msg.sender){}

    function grantMintAndBurnRole(address _address) external onlyOwner{
        _grantRole(MINT_AND_BURN_ROLE, _address);
    }


    /**
    *@notice The interest the protocl gives as of deposit
    *@dev Interest is only set by owner of contract
    *@param _newInterestRate vale of the interest rate
    */
    function setInterestRate(uint256 _newInterestRate) external onlyOwner{
        if( _newInterestRate >= s_interestRate){
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit InterestRate(_newInterestRate);
    }

    /**
    *@notice This the money deposited to the protocol.
    *@dev this amount is not affected by the interest rate, amount remains constant
    *@param _user principal amount of each user in the protocol.
     */
    function principalBalanceOf(address _user) external view returns(uint256){
        return super.balanceOf(_user);
    }


    /**
    *@notice getting the RBT tokens, this been minted immidiately you deposite
    *@param _to address you are minting to
    *@param _amount amount of ETH deposited
    *@param _interestRate interest rate is been updated as you mint
     */
    function mint(address _to, uint256 _amount, uint256 _interestRate) public onlyRole(MINT_AND_BURN_ROLE){
        _mintAccuredInterest(_to);
        s_userInterestRate[_to] = _interestRate;
        _mint(_to, _amount);
    }

    function _mintAccuredInterest(address _user) internal{

        uint256 previousBalance = super.balanceOf(_user);
        uint256 currentBalance = balanceOf(_user);
        uint256 interestAccrued = currentBalance - previousBalance;
    
        _mint(_user, interestAccrued);    

        s_userLastUpdatedTimestamp[_user] = block.timestamp;


    }

    function balanceOf(address _user) public view override returns(uint256){

        uint256 currentPrincipal = super.balanceOf(_user);
        if(currentPrincipal == 0) return 0;

        return (currentPrincipal * _calculateInterestAccumulatedSinceLastTimestamp(_user))/ PRECISION_FACTOR;

    }
    
    function burn(address _from, uint256 _amount) public onlyRole(MINT_AND_BURN_ROLE){

        _mintAccuredInterest(_from);
        _burn(_from, _amount);

    }
    function transfer(address _to, uint256 _amount) public override returns(bool){
        if(_amount == type(uint256).max){
            _amount = balanceOf(msg.sender);
        }
        _mintAccuredInterest(msg.sender);
        _mintAccuredInterest(_to);
        return super.transfer(_to, _amount);
    }
    function transferFrom(address _from, address _to, uint256 _amount) public override returns(bool){
        _mintAccuredInterest(_from);
        _mintAccuredInterest(_to);
        if(_amount == type(uint256).max){
            _amount = balanceOf(_from);
        }
        return super.transferFrom(_from, _to, _amount);
    }



    function  _calculateInterestAccumulatedSinceLastTimestamp(address _user) internal view returns(uint256 linearGrowth){

        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        
        linearGrowth = PRECISION_FACTOR + (s_userInterestRate[_user] * timeElapsed) ;
    }

    function getInterestRate() external view returns(uint256){
        return s_interestRate;
    }
    function getUserInterestRate(address _user) external view returns(uint256){
        return s_userInterestRate[_user];
    }

}