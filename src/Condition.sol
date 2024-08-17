// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICondition.sol";

contract Condition is ICondition {

    /**
     * @notice Checks whether the condition is fulfilled.
     * @return bool Returns true if the condition is fulfilled, otherwise false.
     */
    function isFulfilled() public view override returns (bool) {
        return true;
    }
}
