// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "../../src/MoodNft.sol";
import {DeployMoodNft} from "../../script/DeployMoodNft.s.sol";



contract MoodNftIntegrationTest is Test{
    MoodNft moodnft;
    DeployMoodNft deployer;

    string public constant HAPPY_SVG_IMAGE_URI = "data:image/svg+xml;base64,Cjxzdmcgdmlld0JveD0iMCAwIDIwMCAyMDAiIHdpZHRoPSI0MDAiICBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8Y2lyY2xlIGN4PSIxMDAiIGN5PSIxMDAiIGZpbGw9InllbGxvdyIgcj0iNzgiIHN0cm9rZT0iYmxhY2siIHN0cm9rZS13aWR0aD0iMyIvPgogIDxnIGNsYXNzPSJleWVzIj4KICAgIDxjaXJjbGUgY3g9IjcwIiBjeT0iODIiIHI9IjEyIi8+CiAgICA8Y2lyY2xlIGN4PSIxMjciIGN5PSI4MiIgcj0iMTIiLz4KICA8L2c+CiAgPHBhdGggZD0ibTEzNi44MSAxMTYuNTNjLjY5IDI2LjE3LTY0LjExIDQyLTgxLjUyLS43MyIgc3R5bGU9ImZpbGw6bm9uZTsgc3Ryb2tlOiBibGFjazsgc3Ryb2tlLXdpZHRoOiAzOyIvPgo8L3N2Zz4K";
        
    string public constant SAD_SVG_IMAGE_URI = "data:image/svg+xml;base64,Ni0zNzItMzcyLTM3MnpNMjg4IDQyMWE0OC4wMSA0OC4wMSAwIDAgMSA5NiAwIDQ4LjAxIDQ4LjAxIDAgMCAxLTk2IDB6bTM3NiAyNzJoLTQ4LjFjLTQuMiAwLTcuOC0zLjItOC4xLTcuNEM2MDQgNjM2LjEgNTYyLjUgNTk3IDUxMiA1OTdzLTkyLjEgMzkuMS05NS44IDg4LjZjLS4zIDQuMi0zLjkgNy40LTguMSA3LjRIMzYwYTggOCAwIDAgMS04LTguNGM0LjQtODQuMyA3NC41LTE1MS42IDE2MC0xNTEuNnMxNTUuNiA2Ny4zIDE2MCAxNTEuNmE4IDggMCAwIDEtOCA4LjR6bTI0LTIyNGE0OC4wMSA0OC4wMSAwIDAgMSAwLTk2IDQ4LjAxIDQ4LjAxIDAgMCAxIDAgOTZ6Ii8+CiAgPHBhdGggZmlsbD0iIzMzMyIgZD0iTTI4OCA0MjFhNDggNDggMCAxIDAgOTYgMCA0OCA0OCAwIDEgMC05NiAwem0yMjQgMTEyYy04NS41IDAtMTU1LjYgNjcuMy0xNjAgMTUxLjZhOCA4IDAgMCAwIDggOC40aDQ4LjFjNC4yIDAgNy44LTMuMiA4LjEtNy40IDMuNy00OS41IDQ1LjMtODguNiA5NS44LTg4LjZzOTIgMzkuMSA5NS44IDg4LjZjLjMgNC4yIDMuOSA3LjQgOC4xIDcuNEg2NjRhOCA4IDAgMCAwIDgtOC40QzY2Ny42IDYwMC4zIDU5Ny41IDUzMyA1MTIgNTMzem0xMjgtMTEyYTQ4IDQ4IDAgMSAwIDk2IDAgNDggNDggMCAxIDAtOTYgMHoiLz4KPC9zdmc+Cg== ";

    address public USER = makeAddr("USER");


    function setUp() public{
        deployer = new DeployMoodNft();
        moodnft = deployer.run();
    }

    function test_viewTokenUriIntegration() public{
        vm.prank(USER);
        moodnft.mintNft();
        console.log(moodnft.tokenURI(0));
    }

    function test_flipMoodToSad() public{
        vm.prank(USER);
        moodnft.mintNft();

        vm.prank(USER);
        moodnft.flipMood(0);

        assert
            (
                keccak256( abi.encodePacked(moodnft.tokenURI(0)) ) == keccak256( abi.encodePacked( SAD_SVG_URI ))
            );

    }
       



}