// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IRequirement.sol";
import "./Condition.sol";

contract MainRequirement is IRequirement {
    Condition[] public conditions;

    /**
     * @notice Adds a new condition to the main requirement.
     * @param _condition The condition contract to add.
     */
    function addCondition(Condition _condition) external {
        conditions.push(_condition);
    }

    /**
     * @notice Checks if all conditions in the list are fulfilled.
     * @return bool Returns true if all conditions are fulfilled, otherwise false.
     */
    function isFulfilled() external view override returns (bool) {
        for (uint i = 0; i < conditions.length; i++) {
            if (!conditions[i].isFulfilled()) {
                return false;
            }
        }
        return true;
    }
}
