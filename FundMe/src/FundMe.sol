// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {EthConverter} from "./EthConverter.sol";




/**
 * @title Fund Me contract
 * @author Luiz Toreno
 * @notice This is a simple contract, that allows addresses to fund the deploying address, but only deploting address and withdraw
 */

contract FundMe {
    // ================================================================
    //                  TYPE DECLARATION
    // ================================================================
    using EthConverter for uint256;
    AggregatorV3Interface private s_priceFeed;


    // ================================================================
    //             STATE VARIABLES, CONSTANTS & IMMUTABLES
    // ================================================================
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_funderToAmount;
    uint256 public constant MIN_USD = 5e18;
    address private immutable i_owner; 

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // ================================================================
    //                       ERRORS                   
    // ================================================================
      error FundMe_NotOwner(address owner);

    
    // ================================================================
    //                       FUNDS MANAGEMENT                      
    // ================================================================
    function fund() public payable {
        require((msg.value).convertingDepositedEthToUSD(s_priceFeed) >= MIN_USD, "Didn't send enough eth");
        s_funders.push(msg.sender);
        s_funderToAmount[msg.sender] += msg.value;
    }

    modifier ownerOnly() {
        //  require(msg.sender == i_owner, "Must be owner");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner(msg.sender);
        }
        _;
    }

    function withdraw() public ownerOnly {
        address[] memory funders = s_funders;
        uint256 fundersLength = funders.length;

        for (uint256 index = 0; index < fundersLength; index++) {
            address eachFunder = s_funders[index];

            // deleting mapping records one after the other
            s_funderToAmount[eachFunder] = 0;
        }

        // reset array
        s_funders = new address[](0);

        // three ways to withdraw funds
        //transfer
        // payable(msg.sender).transfer(address(this).balance);

        //send
        //  bool sendSuccess = payable(msg.sender).send(address(this).balance);\
        //  require(sendSucess, "Transaction Failed");

        //call
        (bool sendTransation,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sendTransation, "failed"); // if transaction fails revert
    }
    // =================================================================================
    

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }


    // ================================================================
    //                       GETTERS AND SETTERS                      
    // ================================================================
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_funderToAmount[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
