pragma solidity ^0.8.24;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{
    using SafeERC20 for IERC20;



    address[] claimers;
    mapping(address claimer => bool) private s_hasClaimed;

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_eelToken;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim{
        address account;
        uint256 amount;
    }


    //errors
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__HasAlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    //events
    event Claimed( address _account, uint256 _amount);



    constructor(bytes32 merkleRoot, IERC20 eelToken)
        EIP712("MerkleAirdrop", "Version1")
    
    {

        i_merkleRoot = merkleRoot;
        i_eelToken = eelToken;

    }



    function claim(address _account, uint256 _amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external{

        if(s_hasClaimed[_account]){
            revert MerkleAirdrop__HasAlreadyClaimed();
        }
        if(!_isValidSignature(_account, getMessageHash(_account, _amount), v, r, s)){
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));


    //         bytes32 leaf = keccak256(
    //     bytes.concat(
    //         keccak256(
    //             abi.encode(
    //                 bytes32(uint256(uint160(_account))),
    //                 bytes32(_amount)
    //             )
    //         )
    //     )
    // );

        if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[_account] = true;
        emit Claimed(_account, _amount);
        i_eelToken.safeTransfer(_account, _amount);

    }


    // this creates a digest
    function getMessageHash(address account, uint256 amount) public view returns (bytes32){
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount})))
        );
    }
    
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool){
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);

        return actualSigner == account;
    }

    function getMerkleRoot() external view returns (bytes32){
        return i_merkleRoot;
    }
    function getAirdropToken() external view returns (IERC20){
        return i_eelToken;
    }
     
}