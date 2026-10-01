// SPDX-License-Identifier: MIT


pragma solidity ^0.8.19;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract MockFailedTransferFrom is ERC20, ERC20Burnable{

    constructor() ERC20("Decentralised Stablecoin", "DSC"){

    }

    

}



