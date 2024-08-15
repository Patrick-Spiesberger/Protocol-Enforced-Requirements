// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICondition {
    /**
     * @notice Checks if the condition is fulfilled.
     * @return bool Returns true if the condition is fulfilled, otherwise false.
     */
    function isFulfilled() external view returns (bool);
}
