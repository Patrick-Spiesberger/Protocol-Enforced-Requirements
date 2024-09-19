// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Requirement.sol";
import "./BLSHelper.sol";

contract RequirementManager {
    // Define a constant for the finalization block threshold
    uint256 private constant FINALIZATION_THRESHOLD = 48;

    // Mapping from sender's address to their encoded requirements (as bytes) and the block number
    struct RequirementData {
        bytes encodedRequirements;
        uint256 blockNumber;
    }

    mapping(address => RequirementData) public requirements;

    /**
     * @notice Registers an encoded requirement set for the caller.
     * @param encodedRequirementsData The encoded requirement data.
     */
    function registerEncodedRequirement(bytes memory encodedRequirementsData) external {
        // Store the encoded requirements and the current block number
        requirements[msg.sender] = RequirementData({
            encodedRequirements: encodedRequirementsData,
            blockNumber: block.number
        });
    }

    /**
     * @notice Fetches the encoded requirements and block number for a specific address.
     * @param entity The address of the entity.
     * @return The encoded requirements data and the block number.
     */
    function getRequirementData(address entity) external view returns (bytes memory, uint256) {
        RequirementData storage data = requirements[entity];
        return (data.encodedRequirements, data.blockNumber);
    }

    /**
     * @notice Deletes the PreRequirement for the caller.
     */
    function deletePreRequirement() external {
        RequirementData storage data = requirements[msg.sender];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");

        // Decode the requirement data
        (
            ,
            MainRequirement mainReq,
            PostRequirement postReq
        ) = Requirement(address(0)).decodeRequirement(data.encodedRequirements);

        // Create a new encoded data with PreRequirement nullified
        bytes memory newEncodedData = abi.encode(
            PreRequirement(address(0)),
            mainReq,
            postReq
        );

        // Update the stored encoded requirements and block number
        requirements[msg.sender] = RequirementData({
            encodedRequirements: newEncodedData,
            blockNumber: block.number
        });
    }

    /**
     * @notice Deletes the MainRequirement for the caller.
     */
    function deleteMainRequirement() external {
        RequirementData storage data = requirements[msg.sender];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");

        // Decode the requirement data
        (
            PreRequirement preReq,
            ,
            PostRequirement postReq
        ) = Requirement(address(0)).decodeRequirement(data.encodedRequirements);

        // Create a new encoded data with MainRequirement nullified
        bytes memory newEncodedData = abi.encode(
            preReq,
            MainRequirement(address(0)),
            postReq
        );

        // Update the stored encoded requirements and block number
        requirements[msg.sender] = RequirementData({
            encodedRequirements: newEncodedData,
            blockNumber: block.number
        });
    }

    /**
     * @notice Deletes the PostRequirement for the caller.
     */
    function deletePostRequirement() external {
        RequirementData storage data = requirements[msg.sender];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");

        // Decode the requirement data
        (PreRequirement preReq, MainRequirement mainReq, ) = Requirement(address(0)).decodeRequirement(data.encodedRequirements);

        // Create a new encoded data with PostRequirement nullified
        bytes memory newEncodedData = abi.encode(
            preReq,
            mainReq,
            PostRequirement(address(0))
        );

        // Update the stored encoded requirements and block number
        requirements[msg.sender] = RequirementData({
            encodedRequirements: newEncodedData,
            blockNumber: block.number
        });
    }

    /**
     * @notice Deletes all requirements for the caller.
     */
    function deleteRequirement() external {
        delete requirements[msg.sender];
    }

    /**
     * @notice Copies the requirements from another user to the caller.
     * @param source The address of the user whose requirements are to be copied.
     */
    function copyRequirement(address source) external {
        RequirementData storage sourceData = requirements[source];
        require(sourceData.encodedRequirements.length > 0, "No encoded requirements found for the source address");

        // Store the copied encoded requirements and the current block number
        requirements[msg.sender] = RequirementData({
            encodedRequirements: sourceData.encodedRequirements,
            blockNumber: block.number
        });
    }

    /**
     * @notice Checks if the requirement is finalized based on the block number.
     * @param entity The address of the entity.
     * @return True if the requirement is finalized (i.e., the block number plus the threshold is less than or equal to the current block number).
     */
    function isRequirementFinalized(address entity) public view returns (bool) {
        RequirementData storage data = requirements[entity];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");

        return (block.number >= data.blockNumber + FINALIZATION_THRESHOLD);
    }

    /**
     * @notice Retrieves the commitment indicators for Pre and Main requirements.
     * @param entity The address of the entity.
     * @return preCommitment True if the PreRequirement is fulfilled.
     * @return mainCommitment True if the MainRequirement is fulfilled.
     */
    function getBlockCommitmentIndicators(address entity) external view returns (bool preCommitment, bool mainCommitment) {
        RequirementData storage data = requirements[entity];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");
        require(isRequirementFinalized(entity), "Requirement is not finalized yet");

        // Decode the requirement data
        (PreRequirement preReq, MainRequirement mainReq, ) = Requirement(address(0)).decodeRequirement(data.encodedRequirements);

        preCommitment = preReq.isFulfilled();
        mainCommitment = mainReq.isFulfilled();
    }

    /**
     * @notice Retrieves the commitment indicator for Post requirement.
     * @param entity The address of the entity.
     * @return postCommitment True if the PostRequirement is fulfilled.
     */
    function getStateCommitmentIndicators(address entity) external view returns (bool postCommitment) {
        RequirementData storage data = requirements[entity];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");
        require(isRequirementFinalized(entity), "Requirement is not finalized yet");

        // Decode the requirement data
        (
            ,
            ,
            PostRequirement postReq
        ) = Requirement(address(0)).decodeRequirement(data.encodedRequirements);

        postCommitment = postReq.isFulfilled();
    }

    /**
     * @notice Executes failure if PostRequirement is not fulfilled.
     * @param entity The address of the entity.
     * @param blsSignatures Array of BLS signatures from CSC members.
     * @param publicKeys Array of public keys of CSC members who signed.
     */
    function executeFailureIfConditionNotFulfilled(
        address entity,
        bytes[] memory blsSignatures,
        bytes32[] memory publicKeys
    ) external {
        RequirementData storage data = requirements[entity];
        require(data.encodedRequirements.length > 0, "No requirement found for this address");
        require(isRequirementFinalized(entity), "Requirement is not finalized yet");

        // Decode the requirement data
        (
            PreRequirement preReq,
            ,
            PostRequirement postReq
        ) = Requirement(address(0)).decodeRequirement(data.encodedRequirements);

        // Check if the PreRequirement is fulfilled
        if (!preReq.isFulfilled()) {
            require(
                BLSHelper.verifyBLSSignatures(blsSignatures, publicKeys),
                "Not enough valid signatures from CSC members"
            );

            // Execute failure in the PreRequirement
            preReq.executeFailure();
        }

        // Check if the PostRequirement is fulfilled
        if (!postReq.isFulfilled()) {
            require(
                BLSHelper.verifyBLSSignatures(blsSignatures, publicKeys),
                "Not enough valid signatures from CSC members"
            );

            // Execute failure in the PostRequirement
            postReq.executeFailure();
        }
    }

}
