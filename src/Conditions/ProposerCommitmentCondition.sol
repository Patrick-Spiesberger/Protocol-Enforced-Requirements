// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";
import "../RequirementManager.sol";

contract ProposerCommitmentCondition is ICondition {
    address public requiredPreRequirement;
    address public requiredMainRequirement;
    address public requiredPostRequirement;
    address public requirementManager;

    /**
     * @notice Constructor to initialize the ProposerCommitmentCondition contract.
     * @param _requiredPreRequirement The pre-requirement the proposer must be committed to.
     * @param _requiredMainRequirement The main requirement the proposer must be committed to.
     * @param _requiredPostRequirement The post-requirement the proposer must be committed to.
     * @param _requirementManager The RequirementManager contract that manages commitments.
     */
    constructor(
        address _requiredPreRequirement,
        address _requiredMainRequirement,
        address _requiredPostRequirement,
        address _requirementManager
    ) {
        requiredPreRequirement = _requiredPreRequirement;
        requiredMainRequirement = _requiredMainRequirement;
        requiredPostRequirement = _requiredPostRequirement;
        requirementManager = _requirementManager;
    }

    /**
     * @notice Checks if the current block proposer is committed to the required requirements.
     * @return bool True if the current proposer is committed to the required requirements, false otherwise.
     */
    function isFulfilled() public view override returns (bool) {
        // Get the address of the current block proposer (this corresponds to block.coinbase)
        address currentProposer = block.coinbase;

        // Get the registered requirements for the proposer from the RequirementManager
        (address registeredPreReq, address registeredMainReq, address registeredPostReq) = RequirementManager(requirementManager).getRequirement(currentProposer);

        // Check if the proposer is committed to the required pre, main, and post requirements
        return (
            registeredPreReq == requiredPreRequirement &&
            registeredMainReq == requiredMainRequirement &&
            registeredPostReq == requiredPostRequirement
        );
    }
}
