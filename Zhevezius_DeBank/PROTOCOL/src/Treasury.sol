// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

/// @title Treasury
/// @author Nwachukwu Chukwuebuka
/// @notice Contract recieving protocol's transaction fees
/// @

contract Treasury {
    ////////////////////////////////////////////////
    //////////////////// ERRORS ////////////////////
    ////////////////////////////////////////////////
    error Treasury__OnlyVaultShouldDeposit();

    uint256 public liquidationFeesRecieved;
    address private immutable i_vault;

    constructor(address _vault) {
        i_vault = _vault;
    }

    modifier onlyVault() {
        if (msg.sender != i_vault) {
            revert Treasury__OnlyVaultShouldDeposit();
        }
        _;
    }

    // recieve() external payable{

    //     liquadationFeesRecieved += msg.value;

    // }

    function recieveFees() external payable onlyVault {
        liquidationFeesRecieved += msg.value;
    }
}
