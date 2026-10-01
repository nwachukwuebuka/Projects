// Layout of Contract:
//license
// version
// imports

/***the contract itself */
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


//1. license
// SPDX-License-Identifier: MIT

//2. version
pragma solidity ^0.8.24;


 
/*//////////////////////////////////////////////////////////////
                        IMPORTS
//////////////////////////////////////////////////////////////*/


/**
 * @notice CHECK IF TIME HAS PASSED, THEN PERFORM
 */
 import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

/**
 * @notice REQUEST RANDOMNESS
 */
 /// @dev structures randomness properly before sending
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
/// @dev sends a particular random number
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";



/**
 * @title First Raffle Smart Contract
 * @author Luiz Toreno
 * @notice
 * @dev 
 */
contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface{
    
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);
    error Raffle__AddMoreEthToEnterRaffle();
    error Raffle__FundingWinnerFailed();
    error Raffle__RaffleNotOpen();




    /*//////////////////////////////////////////////////////////////
                        TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    enum RaffleState{
        OPEN,
        CALCULATING
           
    }
    



    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /* Chainlink VRF Varaibles */
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_gaslane; // keyHash
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    /* lottery Varaibles */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_interval; 
    address private s_recentWinner;
    RaffleState private s_raffleState;




    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event RaffleEntered(address indexed player);
    event RaffleWinner(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);




    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes the raffle contract
     * @param subscriptionId Chainlink VRF subscription ID
     * @param gasLane The maximum amount of gas price you are willing to pay in Wei for a function call
     * @param callbackGasLimit Gas limit for fulfillRandomWords callback
     * @param entranceFee Minimum ETH required to enter raffle
     * @param interval Time interval between raffle draws
     * @param vrfCoordinatorV2 Address of the VRF Coordinator
     */

    constructor(
        uint256 subscriptionId,
        bytes32 gasLane, //keyHash
        uint32 callbackGasLimit

        uint256 interval,
        uint256 entranceFee,    
        address vrfCoordinatorV2,
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2) {
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;

        i_entranceFee = entranceFee;
        s_lastTimeStamp = block.timestamp;
        i_interval = interval;
        s_raffleState = RaffleState.OPEN;
    }




     /*//////////////////////////////////////////////////////////////
                             FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// EXTERNAL FUNCTIONS ///

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not Enough Eth");
        // require(msg.value >= i_entranceFee, NotEnoughEth());

        if (msg.value < i_entranceFee) {
            revert Raffle__AddMoreEthToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    ///@dev from ```import {AutomationCompatibleInterface}```
    function checkUpkeep(bytes memory /*checkData*/) public view override returns(bool upKeepNeeded, bytes memory /*performData*/){

        // What can make a player enetr raffle?
        bool timePassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0; 
        bool hasPlayers = s_players.length > 0;

        upKeepNeeded = timePassed && isOpen && hasBalance && hasPlayers;
        return (upKeepNeeded, "");
    }


    ///@dev from ```import {AutomationCompatibleInterface}```
    function performUpkeep(bytes calldata /*performdata*/) external {
        // if ((block.timestamp - s_lastTimeStamp) < i_interval) {
        //     revert Err_currentRaffleNotFinished();
        // }
        (bool upKeepNeeded,) = checkUpkeep("");
        if(!upKeepNeeded){
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState)
            );
        }

        s_raffleState = RaffleState.CALCULATING;
        //  requestId = s_vrfCoordinator.requestRandomWords(VRFV2PlusClient.RandomWordsRequest({


        ///@dev ```import {VRFV2PlusClient}```
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
            )
        });
       uint256  requestId = s_vrfCoordinator.requestRandomWords(request);
       emit RequestedRaffleWinner(requestId);
    }


    
    ///@notice Called by Chainlink Automation . should we pick a winner now
    ///@dev from ```import {VRFConsumerBaseV2Plus}```
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
       
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        
        s_recentWinner = recentWinner; // get a winner
        s_players = new address payable[](0); // clear addresses of players
        s_raffleState = RaffleState.OPEN; // open raffle
        s_lastTimeStamp = block.timestamp; // start counting time from when it opened
        emit RaffleWinner(s_recentWinner);

        // funding the winner's address
        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__FundingWinnerFailed();
        }

    }


    /// VIEW FUNCTIONS ///

    function getRaffleMoney() external view returns (uint256) {
        return i_raffleMoney;
    }

    function getRaffleState() external view returns(RaffleState){
        return s_raffleState;
    }

    function getPlayer(uint256 index) external view returns(address){
        return s_players[index];
    }

    function getLastTimeStamp()external view returns(uint256){
        return s_lastTimeStamp;
    }
}
