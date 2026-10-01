// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 *@title
 *@author Luiz Toreno
 *Collateral: BTC & ETh
 *Minting/mechanism: algorithmic
 *Relative Stability: Pegged to the USD;
 *Governance: ------
 */
contract DecentralisedStablecoin is ERC20Burnable, Ownable {
    ////////////////////////////////////////////
    //              ERRORS                    //
    ////////////////////////////////////////////
    error DecentralizedStableCoin__ZeroAddress();
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();

    ////////////////////////////////////////////
    //           STATE VARIABLES              //
    ////////////////////////////////////////////

    constructor(/*address initialOwner*/) ERC20("Decentralized Stablecoin", "DSC")  {
    //Ownable(initialOwner)

    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin__ZeroAddress();
        }

        if (_amount <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }

        _mint(_to, _amount);
        return true;
    }

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);

        if (_amount <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }

        if (balance < _amount) {
            revert DecentralizedStableCoin__BurnAmountExceedsBalance();
        }

        super.burn(_amount);
    }
}
