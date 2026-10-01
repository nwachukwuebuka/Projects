// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721{

// ERRORS
    error MoodNft__notAuthorised();


    enum Mood{
        HAPPY,
        SAD
    }
    uint256 private s_tokenCounter;
    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;

    mapping(uint256  => Mood)  s_tokenIdToMood; 
    

    constructor(
        string memory happySvg, 
        string memory sadSvg) ERC721("MoodNFT", "MOOD")
        {
        s_tokenCounter = 0;
        s_happySvgImageUri = happySvg;
        s_sadSvgImageUri = sadSvg;

    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }   

    function flipMood(uint256 tokenId) public {
        // Fetch the owner of the token
        address owner = ownerOf(tokenId);
        // Only want the owner of NFT to change the mood.
        _checkAuthorized(owner, msg.sender, tokenId);

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        string memory imageURI;

        if(s_tokenIdToMood[tokenId] == Mood.HAPPY){
            imageURI = s_happySvgImageUri;
        }else{
            imageURI = s_sadSvgImageUri;
        }

        return 
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "Mood NFT",
                                '", "description":"An NFT that changes based on the mood of the owner.", "attributes":[{"trait_type":"mood","value":"',
                                s_tokenIdToMood[tokenId] == Mood.HAPPY ? "happy" : "sad",
                                '"}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
            
      
    }
    function _baseURI() internal pure override returns (string memory){
        return "data:application/json;base64,";
    }

}