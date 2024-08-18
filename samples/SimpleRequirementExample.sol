// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Requirement.sol";
import "../src/PreRequirement.sol";
import "../src/MainRequirement.sol";
import "../src/PostRequirement.sol";
import "../src/Conditions/BlockHeaderCondition.sol";

contract SimpleRequirementExample {
    Requirement public requirement;

    /**
     * @notice Constructor to initialize the Requirement contract with pre-, main-, and post-requirements.
     */
    constructor() {
        // Initialize the empty PreRequirement
        PreRequirement preRequirement = new PreRequirement();

        MainRequirement mainRequirement = new MainRequirement();
        
        // Initialize the BlockHeaderConditions contract with provided parameters
        BlockHeaderConditions condition_example = new BlockHeaderConditions(
            42,
            address(0x1234567890abcdef1234567890abcdef12345678),
            8000000,
            1000000000,
            1,
            0,
            42
        );
        
        mainRequirement.addCondition(condition_example);

        PostRequirement postRequirement = new PostRequirement();
        
        // Create the Requirement contract with the initialized requirements
        requirement = new Requirement(
            preRequirement,
            mainRequirement,
            postRequirement
        );
    }
}
