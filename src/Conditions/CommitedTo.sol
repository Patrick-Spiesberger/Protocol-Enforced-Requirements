// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";
import "../RequirementManager.sol";

contract CommitedTo is ICondition {
    address public entity;
    address public preRequirement;
    address public mainRequirement;
    address public postRequirement;
    address public requirementManager;

    constructor(
        address _entity,
        address _preRequirement,
        address _mainRequirement,
        address _postRequirement,
        address _requirementManager
    ) {
        entity = _entity;
        preRequirement = _preRequirement;
        mainRequirement = _mainRequirement;
        postRequirement = _postRequirement;
        requirementManager = _requirementManager;
    }

    /// @notice Check if the entity is committed to the specific pre, main, and post requirements.
    /// @return bool True if the entity is committed to all specified requirements, false otherwise.
    function isFulfilled() public view override returns (bool) {
        // Get the registered requirements for the entity from the RequirementManager
        (address registeredPreReq, address registeredMainReq, address registeredPostReq) = RequirementManager(requirementManager).getRequirement(entity);

        // Check if the entity is committed to the specific requirements provided in the constructor
        return (registeredPreReq == preRequirement && registeredMainReq == mainRequirement && registeredPostReq == postRequirement);
    }
}
