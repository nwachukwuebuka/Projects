// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

/// @title IZVSToken
/// @author Nwachukwu Chukwuebuka
/// @notice Interface for the Zhevezuis(ZVS).
/// @dev Used by the Vault to mint and burn ZVS without depending on the full token implementation.

interface IZVStoken {
    /// @notice Mints ZVS to a recipient.
    /// @param _address The receiving address
    /// @param _value The amount of ZVS to mint.
    function mint(address _address, uint256 _value) external;

    ///@notice Burns ZVS from an account
    ///@param _address The address where the burn happens
    ///@param _value ZVS amount to burn
    function burn(address _address, uint256 _value) external;

    function transferFrom(address _from, address _to, uint256 _amount) external;
}
