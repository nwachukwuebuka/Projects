// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";



contract ContractV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable{

    uint256 number;

     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(){
        _disableInitializers();

    }
    function initialize() public initializer{
        __Ownable_init(msg.sender);
    }


    function getNumber() external view returns (uint256){
        return number;

    }
    function getVersion() external pure returns(uint8){
        return 2;
    }

    function setNumber() external{}

     function _authorizeUpgrade(address newImplementation) internal override{}



}