// SPDX-License-Identifier: MIT


pragma solidity ^0.8.24;


interface IRebaseToken{

    function mint(address _user, uint256 _amount, uint256 _interest) external;
    function burn(address _user, uint256 _amount) external;
    function balanceOf(address _user) external view returns(uint256);
    function getUserInterestRate(address _user) external view returns(uint256);
    function getInterestRate() external view returns(uint256);
    function grantMintAndBurnRole(address _address) external;
    




}