// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Requirement.sol";

contract RequirementManager {
    // Mapping from sender's address to their encoded requirements (as bytes)
    mapping(address => bytes) public encodedRequirements;

    // Mapping to store the decoded Requirement contracts for each address
    mapping(address => Requirement) public decodedRequirements;

    /**
     * @notice Registers an encoded requirement set for the caller.
     * @param encodedRequirementsData The encoded requirement data.
     */
    function registerEncodedRequirement(bytes memory encodedRequirementsData) external {
        // Store the encoded requirements
        encodedRequirements[msg.sender] = encodedRequirementsData;

        // Decode the requirement data and store the decoded Requirement contract
        (
            PreRequirement preReq, 
            MainRequirement mainReq, 
            PostRequirement postReq
        ) = Requirement(address(0)).decodeRequirement(encodedRequirementsData);

        decodedRequirements[msg.sender] = new Requirement(preReq, mainReq, postReq);
    }

    /**
     * @notice Fetches the decoded requirements for a specific address.
     * @param entity The address of the entity.
     * @return The decoded Requirement contract.
     */
    function getDecodedRequirement(address entity) external view returns (Requirement) {
        return decodedRequirements[entity];
    }

    /**
     * @notice Deletes the PreRequirement for the caller.
     */
    function deletePreRequirement() external {
        Requirement requirement = decodedRequirements[msg.sender];
        require(address(requirement) != address(0), "No requirement found for this address");

        // Create a new Requirement with PreRequirement set to a default address (nullifying it)
        decodedRequirements[msg.sender] = new Requirement(
            PreRequirement(address(0)),
            requirement.mainRequirement(),
            requirement.postRequirement()
        );

        // Update the encoded requirements as well
        encodedRequirements[msg.sender] = abi.encode(
            PreRequirement(address(0)),
            requirement.mainRequirement(),
            requirement.postRequirement()
        );
    }

    /**
     * @notice Deletes the MainRequirement for the caller.
     */
    function deleteMainRequirement() external {
        Requirement requirement = decodedRequirements[msg.sender];
        require(address(requirement) != address(0), "No requirement found for this address");

        // Create a new Requirement with MainRequirement set to a default address (nullifying it)
        decodedRequirements[msg.sender] = new Requirement(
            requirement.preRequirement(),
            MainRequirement(address(0)),
            requirement.postRequirement()
        );

        // Update the encoded requirements as well
        encodedRequirements[msg.sender] = abi.encode(
            requirement.preRequirement(),
            MainRequirement(address(0)),
            requirement.postRequirement()
        );
    }

    /**
     * @notice Deletes the PostRequirement for the caller.
     */
    function deletePostRequirement() external {
        Requirement requirement = decodedRequirements[msg.sender];
        require(address(requirement) != address(0), "No requirement found for this address");

        // Create a new Requirement with PostRequirement set to a default address (nullifying it)
        decodedRequirements[msg.sender] = new Requirement(
            requirement.preRequirement(),
            requirement.mainRequirement(),
            PostRequirement(address(0))
        );

        // Update the encoded requirements as well
        encodedRequirements[msg.sender] = abi.encode(
            requirement.preRequirement(),
            requirement.mainRequirement(),
            PostRequirement(address(0))
        );
    }

    /**
     * @notice Retrieves the commitment indicators for Pre and Main requirements.
     * @param entity The address of the entity.
     * @return preCommitment True if the PreRequirement is fulfilled.
     * @return mainCommitment True if the MainRequirement is fulfilled.
     */
    function getBlockCommitmentIndicators(address entity) external view returns (bool preCommitment, bool mainCommitment) {
        Requirement requirement = decodedRequirements[entity];
        require(address(requirement) != address(0), "No requirement found for this address");

        preCommitment = requirement.preRequirement().isFulfilled();
        mainCommitment = requirement.mainRequirement().isFulfilled();
    }

    /**
     * @notice Retrieves the commitment indicator for Post requirement.
     * @param entity The address of the entity.
     * @return postCommitment True if the PostRequirement is fulfilled.
     */
    function getStateCommitmentIndicators(address entity) external view returns (bool postCommitment) {
        Requirement requirement = decodedRequirements[entity];
        require(address(requirement) != address(0), "No requirement found for this address");

        postCommitment = requirement.postRequirement().isFulfilled();
    }

    /**
     * @notice Deletes all requirements for the caller.
     */
    function deleteRequirement() external {
        delete encodedRequirements[msg.sender];
        delete decodedRequirements[msg.sender];
    }
}
