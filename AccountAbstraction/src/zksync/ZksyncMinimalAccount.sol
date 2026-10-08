// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;



///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {IAccount} from "@zksync-era/contracts/interfaces/IAccount.sol";
import {Transaction} from "@zksync-era/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "@zksync-era/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT} from "@zksync-era/contracts/Constants.sol";
import {INonceHolder} from "@zksync-era/contracts/interfaces/INonceHolder.sol";



contract ZksyncMinimalAccount is IAccount {

    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////
    function validateTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction memory _transaction
    ) external payable returns (bytes4 magic) {

        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()), 
            address(NONCE_HOLDER_SYSTEM_CONTRACT),
            0, 
            abi.encodeCall(INonceHolder.incrementMinNonceIfEquals, (_transaction.nonce))
        );
    }

    function executeTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction memory _transaction
    ) external payable {}

    function executeTransactionFromOutside(
        Transaction memory _transaction
    ) external payable {}

    function payForTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction memory _transaction
    ) external payable {}

    function prepareForPaymaster(
        bytes32 _txHash,
        bytes32 _possibleSignedHash,
        Transaction memory _transaction
    ) external payable {}
}
