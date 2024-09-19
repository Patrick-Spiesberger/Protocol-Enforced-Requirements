// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICondition.sol";

interface IRequirement {
    /**
     * @notice Adds a new condition to the requirement.
     * @param _condition The condition contract to add.
     */
    function addCondition(ICondition _condition) external;

    /**
     * @notice Removes a condition from the requirement.
     * @param index The index of the condition to remove.
     */
    function removeCondition(uint index) external;

    /**
     * @notice Checks if all conditions in the list are fulfilled.
     * @return bool Returns true if all conditions are fulfilled, otherwise false.
     */
    function isFulfilled() external view returns (bool);

    /**
     * @notice Encodes the list of conditions into bytes.
     * @return bytes The encoded condition data.
     */
    function encodeConditions() external view returns (bytes memory);

    /**
     * @notice Decodes the list of conditions from bytes.
     * @param data The encoded condition data.
     */
    function decodeConditions(bytes memory data) external;
}
