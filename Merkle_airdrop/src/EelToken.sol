
pragma solidity ^0.8.24;


import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";


contract EelToken is ERC20, Ownable{

    constructor() 
    ERC20("EEL TOKEN", "EEL")
    Ownable(msg.sender)
    
    {

    }


    function mint(address _user, uint256 _amount) external{
        _mint(_user, _amount);
    }

}