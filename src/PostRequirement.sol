// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IRequirement.sol";
import "./ICondition.sol";

contract PostRequirement is IRequirement {
    ICondition[] public conditions;
    address public onFailureAddress;  // Address to call on failure
    bytes public onFailureCode;       // Alternative code to execute on failure

    /**
     * @notice Adds a new condition to the post requirement.
     * @param _condition The condition contract to add.
     */
    function addCondition(ICondition _condition) external {
        conditions.push(_condition);
    }

    /**
     * @notice Removes a condition from the main requirement.
     * @param index The index of the condition to remove.
     */
    function removeCondition(uint index) external {
        require(index < conditions.length, "Index out of bounds");

        // Move the last condition to the position of the one being removed
        conditions[index] = conditions[conditions.length - 1];
        conditions.pop();
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

    /**
     * @notice Encodes the list of conditions into bytes.
     * @return bytes The encoded condition data.
     */
    function encodeConditions() external view returns (bytes memory) {
        bytes[] memory encodedConditions = new bytes[](conditions.length);

        for (uint i = 0; i < conditions.length; i++) {
            encodedConditions[i] = abi.encode(conditions[i]);
        }

        return abi.encode(encodedConditions);
    }

    /**
     * @notice Decodes the list of conditions from bytes.
     * @param data The encoded condition data.
     */
    function decodeConditions(bytes memory data) external {
        bytes[] memory encodedConditions = abi.decode(data, (bytes[]));
        delete conditions;

        for (uint i = 0; i < encodedConditions.length; i++) {
            ICondition condition = abi.decode(encodedConditions[i], (ICondition));
            conditions.push(condition);
        }
    }

    // Execute either the address or code in case of not meeting requirements
    function executeFailure() internal {
        if (onFailureAddress != address(0)) {
            // Call the address if set
            (bool success, ) = onFailureAddress.call("");
            require(success, "Execution of failure address failed");
        } else if (onFailureCode.length > 0) {
            // Execute the stored code if no address is set
            (bool success, ) = address(this).call(onFailureCode);
            require(success, "Execution of failure code failed");
        }
    }

    // Set the failure action: either an address or code
    function setFailureAction(address _address, bytes memory _code) external {
        onFailureAddress = _address;
        onFailureCode = _code;
    }

    // Getter for onFailureAddress
    function getFailureAddress() external view returns (address) {
        return onFailureAddress;
    }

    // Getter for onFailureCode
    function getFailureCode() external view returns (bytes memory) {
        return onFailureCode;
    }
}
