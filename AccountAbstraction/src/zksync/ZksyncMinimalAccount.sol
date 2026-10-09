// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;



///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {IAccount} from "@zksync-era/contracts/interfaces/IAccount.sol";
import {Transaction, MemoryTransactionHelper} from "@zksync-era/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "@zksync-era/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT} from "@zksync-era/contracts/Constants.sol";
import {INonceHolder} from "@zksync-era/contracts/interfaces/INonceHolder.sol";
import {Ownable} from "@openzepplin/contracts/access/Ownable.sol";
import {Utils} from "@zsync-era/contracts/interfaces/utils.sol";



contract ZksyncMinimalAccount is IAccount, Ownable{
    using MemoryTransactionHelper for Transaction;

    ///////////////////////////////////////////////////////
    ///    ERRORS
    ///////////////////////////////////////////////////////
    error ZksyncMinimalAccount__NotEnoughBalance();
    error ZksyncMinimalAccount__PaymentToBootloaderFailed();

    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    constructor()
        Ownable(msg.sender)
    {

    }


    function validateTransaction(
        bytes32 _txHash,
        /*bytes32 _suggestedSignedHash,*/
        Transaction memory _transaction
    ) external payable returns (bytes4 magic) {

        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()), 
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0, 
            abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (_transaction.nonce))
        );

        //fee check
        uint256 totalRequiredBalance = MemoryTransactionHelper.totalRequiredBalance(_transaction);
        if(totalRequiredBalance > address(this).balance){
            revert ZksyncMinimalAccount__NotEnoughBalance();
        } 

        //checking signatures
        bytes32 txHash = _transaction.encodeHash();
        address signer = ECDSA.recover(txHash, _transaction.signature);

        bool isValidSigner = (signer == owner());

        if(isValidSigner){
            magic = ACCOUNT_VALIDATION_SUCCESS_MAGIC;
        }
        else{
            magic = bytes(0);
        }
        return magic;
        
    }

    function executeTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction memory _transaction
    ) external payable {}

    function executeTransactionFromOutside(
        Transaction memory _transaction
    ) external payable {
        address to = address(uint160(_transaction.to));

        uint128 value = Utils.safeCastToU128(_transaction.value);
        bytes memory data = _transaction.data;

        if(to == DEPLOYER_SYSTEM_CONTRACT){
            uint32 gas = Utils.safeCastToU32(gasleft());
            SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
         }
         else{
            bool success;

            assembly{
                success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0);
            }
      
            if (!success) {
                revert ZkMinimalAccount__ExecutionFailed();
            }
         }
    }

    function payForTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction memory _transaction
    ) external payable {
        
        bool success = _transaction.payToTheBootloader();

        if(!success){
            revert ZksyncMinimalAccount__PaymentToBootloaderFailed();
        }
    }

    function prepareForPaymaster(
        bytes32 _txHash,
        bytes32 _possibleSignedHash,
        Transaction memory _transaction
    ) external payable {}
}
