
// SPDX-License-Identifier: MIT


pragma solidity ^0.8.24;

import {Pool} from "@ccip/contracts/src/v0.8/ccip/libraries/Pool.sol";
import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";
import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";


contract RebaseTokenPool is TokenPool{

    // This tokenPool acts a manager to move token from one chain to another different chain, eg: ETH to BNB
    constructor(IERC20 _token, address[] memory _allowList, address _rmnproxy, address _router) 
         TokenPool(_token, _allowList, _rmnproxy, _router) {}


    function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn) public returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut){

        _validateLockOrBurn(lockOrBurnIn);
        uint256 userInteresrRate = IRebaseToken(address(i_token)).getUserInterestRate(lockOrBurnIn.originalSender);    
        IRebaseToken(address(i_token)).burn(address(this), lockOrBurnIn.amount);
        lockOrBurnOut = Pool.LockOrBurnOutV1({
            // destTokenAddress: abi.encode(address(i_token)),
            destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector),
            destPoolData: abi.encode(userInteresrRate)
        });

    }

    function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn) public returns (Pool.ReleaseOrMintOutV1 memory){

        _validateReleaseOrMint(releaseOrMintIn);
        address receiver = releaseOrMintIn.receiver;
        (uint256 userInterestRate) = abi.decode(releaseOrMintIn.sourcePoolData, (uint256));
        // Mint rebasing tokens to the receiver on the destination chain
        // This will also mint any interest that has accrued since the last time the user's balance was updated.
        IRebaseToken(address(i_token)).mint(receiver, releaseOrMintIn.amount, userInterestRate);

        return Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.amount});


    }

   
}



