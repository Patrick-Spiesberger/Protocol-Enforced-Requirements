// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PreRequirement.sol";
import "./MainRequirement.sol";
import "./PostRequirement.sol";

contract Requirement {
    // Public variables to store the Pre, Main, and Post requirements
    PreRequirement public preRequirement;
    MainRequirement public mainRequirement;
    PostRequirement public postRequirement;

    /**
     * @notice Constructor to initialize the Requirement contract with pre-, main-, and post-requirements.
     * @param _preRequirement The pre-requirement contract.
     * @param _mainRequirement The main requirement contract.
     * @param _postRequirement The post-requirement contract.
     */
    constructor(
        PreRequirement _preRequirement,
        MainRequirement _mainRequirement,
        PostRequirement _postRequirement
    ) {
        preRequirement = _preRequirement;
        mainRequirement = _mainRequirement;
        postRequirement = _postRequirement;
    }

    /**
     * @notice Encodes the requirement data into bytes.
     * @return bytes Encoded requirement data.
     */
    function encodeRequirement() external view returns (bytes memory) {
        return abi.encode(preRequirement, mainRequirement, postRequirement);
    }

    /**
     * @notice Decodes the requirement data from bytes.
     * @param data Encoded requirement data.
     * @return preReq Decoded PreRequirement contract.
     * @return mainReq Decoded MainRequirement contract.
     * @return postReq Decoded PostRequirement contract.
     */
    function decodeRequirement(bytes memory data) external pure returns (PreRequirement preReq, MainRequirement mainReq, PostRequirement postReq) {
        (preReq, mainReq, postReq) = abi.decode(data, (PreRequirement, MainRequirement, PostRequirement));
    }

    /**
     * @notice Allows updating of the PreRequirement.
     * @param _preRequirement The new PreRequirement contract.
     */
    function updatePreRequirement(PreRequirement _preRequirement) external {
        preRequirement = _preRequirement;
    }

    /**
     * @notice Allows updating of the MainRequirement.
     * @param _mainRequirement The new MainRequirement contract.
     */
    function updateMainRequirement(MainRequirement _mainRequirement) external {
        mainRequirement = _mainRequirement;
    }

    /**
     * @notice Allows updating of the PostRequirement.
     * @param _postRequirement The new PostRequirement contract.
     */
    function updatePostRequirement(PostRequirement _postRequirement) external {
        postRequirement = _postRequirement;
    }
}
