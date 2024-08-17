// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";

contract InclusionListCondition is ICondition {
    // Array to store the inclusion list of transaction hashes
    bytes32[] public inclusionList;
    // State variable to store whether the condition has been fulfilled
    bool public isConditionFulfilled;

    // Event to emit when the inclusion list is set
    event InclusionListSet(bytes32[] inclusionList);

    // Event to emit when the inclusion list is fulfilled
    event InclusionListFulfilled(bool fulfilled);

    // Constructor to initialize the contract with an inclusion list
    constructor(bytes32[] memory _inclusionList) {
        inclusionList = _inclusionList;
        emit InclusionListSet(_inclusionList);
    }

    /// @notice Function to check if the provided transactions match the inclusion list
    /// @param _transactions Array of transaction hashes to be checked
    /// @return bool True if all transactions match the inclusion list, false otherwise
    function checkInclusionList(bytes32[] memory _transactions) public returns (bool) {
        require(_transactions.length == inclusionList.length, "Transaction count does not match inclusion list");
        
        for (uint i = 0; i < _transactions.length; i++) {
            if (_transactions[i] != inclusionList[i]) {
                // If any transaction does not match, return false and mark as not fulfilled
                isConditionFulfilled = false;
                emit InclusionListFulfilled(false);
                return false;
            }
        }
        
        // If all transactions match, mark the condition as fulfilled
        isConditionFulfilled = true;
        emit InclusionListFulfilled(true);
        return true;
    }

    /// @notice Function to check if the inclusion list condition is fulfilled
    /// @return bool True if the condition is fulfilled, false otherwise
    function isFulfilled() public view override returns (bool) {
        return isConditionFulfilled;
    }
}
