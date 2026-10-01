// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {IAccount} from "@eth-infinitism/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "@eth-infinitism/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {
    SIG_VALIDATION_FAILED,
    SIG_VALIDATION_SUCCESS
} from "@eth-infinitism/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "@eth-infinitism/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    ///////////////////////////////////////////////////////
    ///    ERRORS
    ///////////////////////////////////////////////////////
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromOwnerOrEntrypoint();
    error MinimalAccount__ExecutionFailed(bytes);

    ///////////////////////////////////////////////////////
    ///    VARAIBLES
    ///////////////////////////////////////////////////////
    IEntryPoint private immutable i_entryPoint;

    ///////////////////////////////////////////////////////
    ///    MODIFIERS
    ///////////////////////////////////////////////////////
    modifier entryPointCheck() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }
    modifier entryPointAndOwnerCheck() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromOwnerOrEntrypoint();
        }
        _;
    }

    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {}

    ///////////////////////////////////////////////////////
    ///     EXTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////

    // Only the EntryPoint can call this function.
    // The signature is valid if it was signed by the MinimalAccount owner.
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        entryPointCheck
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);

        // validateNonce();

        _payPrefund(missingAccountFunds);
    }

    function execute(address tokenContract, uint256 amount, bytes calldata functionData) external entryPointAndOwnerCheck() {
        (bool success, bytes memory result) = tokenContract.call{value: amount}(functionData);
        if (!success) {
            revert MinimalAccount__ExecutionFailed(result);
        }
    }

    ///////////////////////////////////////////////////////
    ///    INTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);

        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }
}
