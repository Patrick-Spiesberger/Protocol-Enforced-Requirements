// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Requirement.sol";
import "./PreRequirement.sol";
import "./MainRequirement.sol";
import "./PostRequirement.sol";

contract RequirementManager {
    // Mapping from address to encoded requirement data
    mapping(address => bytes) public requirements;

    /**
     * @notice Registers a new requirement by encoding it and linking it to the sender's address.
     * @param _preRequirement The pre-requirement contract.
     * @param _mainRequirement The main requirement contract.
     * @param _postRequirement The post requirement contract.
     */
    function registerRequirement(
        PreRequirement _preRequirement,
        MainRequirement _mainRequirement,
        PostRequirement _postRequirement
    ) external {
        // Encode the Requirement data
        bytes memory encodedRequirement = abi.encode(_preRequirement, _mainRequirement, _postRequirement);
        // Store the encoded requirement in the mapping associated with the sender's address
        requirements[msg.sender] = encodedRequirement;
    }

    /**
     * @notice Deletes the requirement associated with the sender's address.
     */
    function deleteRequirement() external {
        delete requirements[msg.sender];
    }

    /**
     * @notice Fetches and decodes the requirement associated with the specified address.
     * @param addr The address whose requirement should be fetched.
     * @return preReq Decoded PreRequirement contract.
     * @return mainReq Decoded MainRequirement contract.
     * @return postReq Decoded PostRequirement contract.
     */
    function getRequirement(address addr) 
        external 
        view 
        returns (
            PreRequirement preReq, 
            MainRequirement mainReq, 
            PostRequirement postReq
        ) 
    {
        bytes memory encodedRequirement = requirements[addr];
        require(encodedRequirement.length > 0, "No requirement found for this address");
        // Decode the requirement data
        (preReq, mainReq, postReq) = abi.decode(encodedRequirement, (PreRequirement, MainRequirement, PostRequirement));
    }

    /**
     * @notice Retrieves the commitment indicator function for the pre-, main-, and post-conditions for a specific address.
     * @param addr The address whose requirement commitments should be checked.
     * @return preCommitment The commitment status of the pre-requirement.
     * @return mainCommitment The commitment status of the main requirement.
     * @return postCommitment The commitment status of the post-requirement.
     */
    function getCommitmentIndicators(address addr)
        external
        view
        returns (
            bool preCommitment,
            bool mainCommitment,
            bool postCommitment
        )
    {
        (PreRequirement preReq, MainRequirement mainReq, PostRequirement postReq) = this.getRequirement(addr);
        
        preCommitment = preReq.isFulfilled();
        mainCommitment = mainReq.isFulfilled();
        postCommitment = postReq.isFulfilled();
    }
}
