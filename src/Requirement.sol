// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PreRequirement.sol";
import "./MainRequirement.sol";
import "./PostRequirement.sol";

contract Requirement {
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
     * @notice Checks if pre, main requirements are fulfilled.
     * @return bool Returns true if requirements are fulfilled, otherwise false.
     */
    function isFulfilled() external view returns (bool) {
        return preRequirement.isFulfilled() &&
               mainRequirement.isFulfilled();
    }

        /**
     * @notice Checks if post requirement is fulfilled.
     * @return bool Returns true if post requirements is fulfilled, otherwise false.
     */
    function isPostReequirementFulfilled() external view returns (bool) {
        return postRequirement.isFulfilled();
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
}
