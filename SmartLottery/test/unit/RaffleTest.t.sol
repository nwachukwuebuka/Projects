// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployScript} from "script/DeployScript.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 raffleMoney;
    uint256 interval;
    address vrfcoordinator;
    bytes32 keyHash;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    // simulating a transaction
    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_BALANCE = 10 ether;

    event Evt_raffleEntered(address indexed player);
    event Evt_raffleWinner(address indexed winner);

    // function setUp() public {
    //     // has no knowledge of the DeployScript, so we need to pass it's requirements
    //     // DeployScript deployer = new DeployScript();
    //     //
    //     helperConfig = new HelperConfig();
    //     HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

    //     raffle = new Raffle(
    //         config.raffleMoney,
    //         config.interval,
    //         config.vrfcoordinator,
    //         config.keyHash,
    //         uint32(config.subscriptionId),
    //         config.callbackGasLimit
    //     );

    //     raffleMoney = config.raffleMoney;
    //     interval = config.interval;
    //     vrfcoordinator = config.vrfcoordinator;
    //     keyHash = config.keyHash;
    //     callbackGasLimit = config.callbackGasLimit;
    //     subscriptionId = config.subscriptionId;

    //     vm.deal(PLAYER, STARTING_BALANCE); // give the player some eth to play with
    // }

    function setUp() public {
    helperConfig = new HelperConfig();
    HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
    
    VRFCoordinatorV2_5Mock vrfCoordinator = VRFCoordinatorV2_5Mock(config.vrfcoordinator);

    // 1. Create subscription
    // uint64 subId = vrfCoordinator.createSubscription();
    uint256 subId = vrfCoordinator.createSubscription();

    // 2. Fund it
    vrfCoordinator.fundSubscription(subId, 3 ether);

    // 3. Deploy raffle with CORRECT subId
    raffle = new Raffle(
        config.raffleMoney,
        config.interval,
        config.vrfcoordinator,
        config.keyHash,
        uint64(subId),
        config.callbackGasLimit
    );

    // 4. Add consumer (VERY IMPORTANT)
    vrfCoordinator.addConsumer(subId, address(raffle));

    raffleMoney = config.raffleMoney;
    interval = config.interval;
    vrfcoordinator = config.vrfcoordinator;
    keyHash = config.keyHash;
    callbackGasLimit = config.callbackGasLimit;
    subscriptionId = subId; // optional but better

    vm.deal(PLAYER, STARTING_BALANCE);
}
    function test_RaffleIsOpen() public view {
        // assertEq(raffle.getRaffleState(), Raffle.RaffleState.OPEN);
        Raffle.RaffleState state = raffle.getRaffleState();
        assertEq(uint256(state), uint256(Raffle.RaffleState.OPEN));
    }

    function test_HasEnoughRafflePay() public {
        vm.prank(PLAYER);

        vm.expectRevert(Raffle.Err_NotEnoughRaffleEthSent.selector);
        raffle.rafflePay();
    }

    function test_PlayerIsAddedToArray() public {
        //Arrange...........simulate a player entering the raffle
        vm.prank(PLAYER);
        //Act ...........pretending to enter the raffle with the required amount of eth
        raffle.rafflePay{value: raffleMoney}();
        //Assert...........check if the player was added to the array
        address playerInArray = raffle.getPlayer(0);
        assertEq(playerInArray, PLAYER);
    }

    function test_playerEnterEventEmit() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit Evt_raffleEntered(PLAYER);
        //Assert
        raffle.rafflePay{value: raffleMoney}();
    }

    function test_DoNotAllowEntranceWhenRaffleIsCalculating() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.rafflePay{value: raffleMoney}();

        // Act
        vm.warp(block.timestamp + interval + 1); // fast forward time to trigger upkeep
        vm.roll(block.number + 1); // mine a block to update the state of the contract
        raffle.performUpkeep("");

       
        //Assert
        vm.expectRevert();
        vm.prank(PLAYER);
        raffle.rafflePay{value: raffleMoney}();
    }

    function test_checkUpkeepFailIfZeroBalance() public{
        //Arrange .........no money was funded
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //Act
        (bool upKeepNeeded,) = raffle.checkUpkeep("");

        //Assert
        assert(!upKeepNeeded);

    }

    function test_failIfRaffleIsNotOpen() public{
         //Arrange
        vm.prank(PLAYER);
        raffle.rafflePay{value: raffleMoney}();
        vm.warp(block.timestamp + interval + 1); // fast forward time to trigger upkeep
        vm.roll(block.number + 1); // mine a block to update the state of the contract
        raffle.performUpkeep("");

        // Act
        (bool upKeepNeeded,) = raffle.checkUpkeep("");

        //Assert
        assert(!upKeepNeeded);

    }

    function test_PerformUpkeepWorksIfCheckUpkeepReturnsTrue() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.rafflePay{value: raffleMoney}();
        vm.warp(block.timestamp + interval + 1); // fast forward time to trigger upkeep
        vm.roll(block.number + 1); // mine a block to update the state of the contract

        //Act and Assert
        raffle.performUpkeep("");
       
    }

    function test_Err_UpkeepNotNeeded() public {

        //Arrange
        uint256 balance = 0;
        uint256 numberOfPlayers = 0;
        //   uint256 state = uint256(Raffle.RaffleState.OPEN);
        Raffle.RaffleState rstate = raffle.getRaffleState();

        vm.prank(PLAYER);
        raffle.rafflePay{value: STARTING_BALANCE}();
        balance += STARTING_BALANCE;
        numberOfPlayers = 1;

        //Act
        vm.expectRevert(
            abi.encodeWithSelector(Raffle.Err_RaffleNotOpen.selector, balance, numberOfPlayers, rstate);
        );
        raffle.performUpKeep("");

    }


    modifier rafflePayprankArrange(){
        vm.prank(PLAYER);
        raffle.rafflePay{value: raffleMoney}();
        vm.warp(block.timestamp + interval + 1); // fast forward time to trigger upkeep
        vm.roll(block.number + 1); // mine a block to update the state of the contract

        _;

    }
    function test_PerfomUpkeepEmitsRequestedId() public rafflePayprankArrange{

        //Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        //Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);

    }

    // stateless fuzz test
    function test_FufillrandomWordsCalledAfterPerformUpkeep(uint256 randomRequestId) public rafflePayprankArrange{


        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fufillRandomWords(randomRequestId, address(raffle));

    }


    funtion test_fufillRandomWordsSelectwinnerResetFundwinner() public rafflePayprankArrange{
        uint236 additionalEntrances = 3;
        uint256 startingIndex = 1;

        for(int256 i = startingIndex; i < (startingIndex + additionalEntrances); i++){
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether);
            raffle.rafflePay{value: raffleMoney}();
        }

        address expectedWinner = address(1);
        uint256 winnerStartingBalance = expectedWinner.balance();
        uint256 startingTimeStamp = raffle.getLastTimeStamp();

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fufillRandomWords(requestId, address(raffle));

        //Assert
        address recentWinner = raffle.getRecentWinner();
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        uint256 endingTimeStamp = raffle.getLastTimeStamp();
        uint256 Prize = raffleMoney * (additionalEntrances + 1);

        assert(recentWinner == expectedWinner);
        assert(uint256(raffleState) == 0);
        assert(winnerBalance == winnerStartingBalance + Prize);
        assert(endingTimesStamp > startingTimeStamp);

    }
}


