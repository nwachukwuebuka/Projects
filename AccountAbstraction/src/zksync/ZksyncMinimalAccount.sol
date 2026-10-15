// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;



///////////////////////////////////////////////////////
///    IMPORTS
///////////////////////////////////////////////////////
import {IAccount, ACCOUNT_VALIDATION_SUCCESS_MAGIC} from "@zksync-era/contracts/interfaces/IAccount.sol";
import {Transaction, MemoryTransactionHelper} from "@zksync-era/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from "@zksync-era/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT, BOOTLOADER_FORMAL_ADDRESS , DEPLOYER_SYSTEM_CONTRACT} from "@zksync-era/contracts/Constants.sol";
import {INonceHolder} from "@zksync-era/contracts/interfaces/INonceHolder.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Utils} from "@zksync-era/contracts/libraries/Utils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



contract ZksyncMinimalAccount is IAccount, Ownable{
    using MemoryTransactionHelper for Transaction;

    ///////////////////////////////////////////////////////
    ///    ERRORS
    ///////////////////////////////////////////////////////
    error ZksyncMinimalAccount__NotEnoughBalance();
    error ZksyncMinimalAccount__NotFromBootLoader();
    error ZksyncMinimalAccount__NotFromBootLoaderOrOwner();
    error ZksyncMinimalAccount__PaymentToBootloaderFailed();
    error ZksyncMinimalAccount__InvalidSignature();
    error ZksyncMinimalAccount__ExecutionFailed();


    ///////////////////////////////////////////////////////
    ///    FUNCTIONS
    ///////////////////////////////////////////////////////

    constructor()
        Ownable(msg.sender)
    {

    }

    receive() external payable{}

    ///////////////////////////////////////////////////////
    ///    MODIFIERS
    ///////////////////////////////////////////////////////
    modifier requireFromBootLoader() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS) {
            revert ZksyncMinimalAccount__NotFromBootLoader();
        }
        _;
    }

    
    modifier requireFromBootLoaderOrOwner() {
        if (msg.sender != BOOTLOADER_FORMAL_ADDRESS && msg.sender != owner()) {
            revert ZksyncMinimalAccount__NotFromBootLoaderOrOwner();
        }
        _;
    }




    ///////////////////////////////////////////////////////
    ///    EXTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////
    
    function validateTransaction(
        bytes32, /*_txHash*/
        bytes32, /*_suggestedSignedHash*/
        Transaction memory _transaction
    ) external payable requireFromBootLoader returns (bytes4 magic) {
        return _validateTransaction(_transaction);

    }

       function executeTransaction(
        bytes32, /*_txHash*/
        bytes32, /* _suggestedSignedHash*/
        Transaction memory _transaction
    ) external payable  requireFromBootLoaderOrOwner {
        _executeTransaction(_transaction);

    }

    function executeTransactionFromOutside(
        Transaction memory _transaction
    ) external payable {
        bytes4 magic = _validateTransaction(_transaction);

        if(magic !=  ACCOUNT_VALIDATION_SUCCESS_MAGIC){
            revert ZksyncMinimalAccount__InvalidSignature();
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



    ///////////////////////////////////////////////////////
    ///    INTERNAL FUNCTIONS
    ///////////////////////////////////////////////////////

    function _validateTransaction(Transaction memory _transaction) internal  returns (bytes4 magic) {

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
            magic = bytes4(0);
        }
        return magic;
        
    }

    function _executeTransaction(Transaction memory _transaction) internal {
        address to = address(uint160(_transaction.to));

        uint128 value = Utils.safeCastToU128(_transaction.value);
        bytes memory data = _transaction.data;

        if(to == address(DEPLOYER_SYSTEM_CONTRACT)){
            uint32 gas = Utils.safeCastToU32(gasleft());
            SystemContractsCaller.systemCallWithPropagatedRevert(gas, to, value, data);
        }
         else{
            bool success;

            assembly{
                success := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)
            }
      
            if (!success) {
                revert ZksyncMinimalAccount__ExecutionFailed();
            }
        }

    }
}


// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.24;

// import {Test, console2} from "forge-std/Test.sol";
// import {ZkMinimalAccount} from "src/zksync/ZkMinimalAccount.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

// // Era Imports
// import {
//     Transaction,
//     MemoryTransactionHelper
// } from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
// import {BOOTLOADER_FORMAL_ADDRESS} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
// import {
//     ACCOUNT_VALIDATION_SUCCESS_MAGIC
// } from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";

// // OZ Imports
// import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// // Foundry Devops
// import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

// contract ZkMinimalAccountTest is Test, ZkSyncChainChecker {
//     using MessageHashUtils for bytes32;

//     ZkMinimalAccount minimalAccount;
//     ERC20Mock usdc;
//     bytes4 constant EIP1271_SUCCESS_RETURN_VALUE = 0x1626ba7e;

//     uint256 constant AMOUNT = 1e18;
//     bytes32 constant EMPTY_BYTES32 = bytes32(0);
//     address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

//     function setUp() public {
//         minimalAccount = new ZkMinimalAccount();
//         minimalAccount.transferOwnership(ANVIL_DEFAULT_ACCOUNT);
//         usdc = new ERC20Mock();
//         vm.deal(address(minimalAccount), AMOUNT);
//     }

//     function testZkOwnerCanExecuteCommands() public {
//         // Arrange
//         address dest = address(usdc);
//         uint256 value = 0;
//         bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

//         Transaction memory transaction =
//             _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value, functionData);

//         // Act
//         vm.prank(minimalAccount.owner());
//         minimalAccount.executeTransaction(EMPTY_BYTES32, EMPTY_BYTES32, transaction);

//         // Assert
//         assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
//     }

//     // You'll also need --system-mode=true to run this test
//     function testZkValidateTransaction() public onlyZkSync {
//         // Arrange
//         address dest = address(usdc);
//         uint256 value = 0;
//         bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
//         Transaction memory transaction =
//             _createUnsignedTransaction(minimalAccount.owner(), 113, dest, value, functionData);
//         transaction = _signTransaction(transaction);

//         // Act
//         vm.prank(BOOTLOADER_FORMAL_ADDRESS);
//         bytes4 magic = minimalAccount.validateTransaction(EMPTY_BYTES32, EMPTY_BYTES32, transaction);

//         // Assert
//         assertEq(magic, ACCOUNT_VALIDATION_SUCCESS_MAGIC);
//     }

//     /*//////////////////////////////////////////////////////////////
//                                 HELPERS
//     //////////////////////////////////////////////////////////////*/
//     function _signTransaction(Transaction memory transaction) internal view returns (Transaction memory) {
//         bytes32 unsignedTransactionHash = MemoryTransactionHelper.encodeHash(transaction);
//         // bytes32 digest = unsignedTransactionHash.toEthSignedMessageHash();
//         uint8 v;
//         bytes32 r;
//         bytes32 s;
//         uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
//         (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, unsignedTransactionHash);
//         Transaction memory signedTransaction = transaction;
//         signedTransaction.signature = abi.encodePacked(r, s, v);
//         return signedTransaction;
//     }

//     function _createUnsignedTransaction(
//         address from,
//         uint8 transactionType,
//         address to,
//         uint256 value,
//         bytes memory data
//     ) internal view returns (Transaction memory) {
//         uint256 nonce = vm.getNonce(address(minimalAccount));
//         bytes32[] memory factoryDeps = new bytes32[](0);
//         return Transaction({
//             txType: transactionType, // type 113 (0x71).
//             from: uint256(uint160(from)),
//             to: uint256(uint160(to)),
//             gasLimit: 16777216,
//             gasPerPubdataByteLimit: 16777216,
//             maxFeePerGas: 16777216,
//             maxPriorityFeePerGas: 16777216,
//             paymaster: 0,
//             nonce: nonce,
//             value: value,
//             reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
//             data: data,
//             signature: hex"",
//             factoryDeps: factoryDeps,
//             paymasterInput: hex"",
//             reservedDynamic: hex""
//         });
//     }
// }
