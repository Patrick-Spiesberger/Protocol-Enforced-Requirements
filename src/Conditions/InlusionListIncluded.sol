// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";

contract InclusionListIncluded is ICondition {
    bytes32[] public inclusionList; // List of transaction hashes that must be included

    /**
     * @notice Constructor to set up the inclusion list.
     * @param _inclusionList The list of transaction hashes that must be included in the block.
     */
    constructor(bytes32[] memory _inclusionList) {
        inclusionList = _inclusionList;
    }

    /**
     * @notice Check if all transactions in the inclusion list are included in the current block.
     * @return bool True if all transactions are included, false otherwise.
     */
    function isFulfilled() public view override returns (bool) {
        for (uint i = 0; i < inclusionList.length; i++) {
            if (!isTransactionIncluded(inclusionList[i])) {
                return false;
            }
        }
        return true;
    }

    /**
     * @notice Check if a specific transaction hash is included in the current block.
     * @param txHash The hash of the transaction to check.
     * @return bool True if the transaction is included, false otherwise.
     */
    function isTransactionIncluded(bytes32 txHash) internal view returns (bool) {
        // Iterate through the transactions in the current block
        for (uint i = 0; i < block.number; i++) {
            if (blockhash(i) == txHash) {
                return true;
            }
        }
        return false;
    }
}
