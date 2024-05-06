// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

/**
 * @title IGasPool
 * @notice If you have a community // service pool to pay all fee, it must have this interface integrated
 * @dev is the feePayer is not the contract address, it will fallback to calling IGasPool::payTo()
 */
interface IGasPool {
    function payTo(address _to, uint256 _amount) external;
}
