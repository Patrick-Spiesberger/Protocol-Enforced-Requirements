// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRequirement {
    /**
     * @notice Checks if the requirement is fulfilled.
     * @return bool Returns true if the requirement is fulfilled, otherwise false.
     */
    function isFulfilled() external view returns (bool);
}
