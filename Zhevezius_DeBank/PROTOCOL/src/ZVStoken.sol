// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

/// @title Zhevezius Decentralized Banking
///@author Nwachukwu Chukwuebuka
///@notice This is a protocol having a token that acts like a stable coin eaxh representing $1,
///        recieves ETH as collateral and mints the tokens with 150% overcollaterization.
///         The Protocol will be upgraded with more advanced futures in upcoming versions.
///@dev Uses ERC20 token contract from openzeppelin.
///@dev Core functionalities: mint and burn

////////////////////////////////////////////////
//////////////////// IMPORTS ////////////////////
////////////////////////////////////////////////
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract ZVStoken is ERC20, AccessControl {
    ////////////////////////////////////////////////
    //////////////////// ERRORS ////////////////////
    ////////////////////////////////////////////////
    error ZVStoken__MaxSupplyExceeded();
    error ZVStoken__AmountCantBeZero();

    ////////////////////////////////////////////////
    //////////////////// VARIABLES ////////////////////
    ////////////////////////////////////////////////
    uint256 public constant MAX_SUPPLY = 19_000_000 ether;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    address immutable i_deployer;

    ///////////////////////////////////////////////////
    //////////////////// FUNCTIONS ////////////////////
    //////////////////////////////////////////////////
    constructor() ERC20("Zhevezuis Token", "ZVS") {
        i_deployer = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    ///@notice Mints/gives new tokens to the user
    ///@param _address The user's address where the token will be minted to
    ///@param _value Amount of ZVS tokens to be minted
    function mint(address _address, uint256 _value) external onlyRole(MINTER_ROLE) {
        //openzeppelin checks:
        // 1. address is not zero address

        // 3. equalsTo check
        if (_value == 0) {
            revert ZVStoken__AmountCantBeZero();
        }
        // require(
        //     totalSupply() + _value <= MAX_SUPPLY,
        //     "MAX SUPPLY EXCEEDED"
        // );

        if (totalSupply() + _value > MAX_SUPPLY) {
            revert ZVStoken__MaxSupplyExceeded();
        }

        _mint(_address, _value);
    }

    ///@notice Burns tokens from the user's address
    ///@param _address The user's address where the tokens will be burned
    ///@param _value Amount of ZVS tokens to burn
    function burn(address _address, uint256 _value) external onlyRole(BURNER_ROLE) {
        //openzeppelin checks:
        // 1. address is not zero address
        // 2. address has enough tokens to burn i.e balanceOf > _value

        // 3. equalsTo check
        if (_value == 0) {
            revert ZVStoken__AmountCantBeZero();
        }
        _burn(_address, _value);
    }
}
