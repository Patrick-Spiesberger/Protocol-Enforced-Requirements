// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";

abstract contract ExecutionPayloadCondition is ICondition {
    bytes32 public expectedParentHash;
    address public expectedFeeRecipient;
    bytes32 public expectedStateRoot;
    bytes32 public expectedReceiptsRoot;
    bytes32 public expectedLogsBloom;
    uint256 public expectedPrevRandao;
    uint256 public expectedBlockNumber;
    uint256 public expectedGasLimit;
    uint256 public expectedGasUsed;
    uint256 public expectedTimestamp;
    bytes32 public expectedExtraData;
    uint256 public expectedBaseFeePerGas;
    bytes32 public expectedBlockHash;
    bytes32 public expectedTransactionsRoot;
    bytes32 public expectedWithdrawalRoot;

    function getParentHash() internal view returns (bytes32) {
        return blockhash(block.number - 1);
    }

    function getPrevRandao() internal view returns (uint256) {
        return block.prevrandao;
    }

    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    function getGasLimit() internal view returns (uint256) {
        return block.gaslimit;
    }

    function getGasUsed() internal view returns (uint256) {
        return block.gaslimit - gasleft();
    }

    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    function getBaseFeePerGas() internal view returns (uint256) {
        return block.basefee;
    }

    function getBlockHash() internal view returns (bytes32) {
        return blockhash(block.number);
    }
}

contract ExecutionPayloadConditions is ExecutionPayloadCondition {

    constructor(
        bytes32 _expectedParentHash,
        address _expectedFeeRecipient,
        bytes32 _expectedStateRoot,
        bytes32 _expectedReceiptsRoot,
        bytes32 _expectedLogsBloom,
        uint256 _expectedPrevRandao,
        uint256 _expectedBlockNumber,
        uint256 _expectedGasLimit,
        uint256 _expectedGasUsed,
        uint256 _expectedTimestamp,
        bytes32 _expectedExtraData,
        uint256 _expectedBaseFeePerGas,
        bytes32 _expectedBlockHash,
        bytes32 _expectedTransactionsRoot,
        bytes32 _expectedWithdrawalRoot
    ) {
        expectedParentHash = _expectedParentHash;
        expectedFeeRecipient = _expectedFeeRecipient;
        expectedStateRoot = _expectedStateRoot;
        expectedReceiptsRoot = _expectedReceiptsRoot;
        expectedLogsBloom = _expectedLogsBloom;
        expectedPrevRandao = _expectedPrevRandao;
        expectedBlockNumber = _expectedBlockNumber;
        expectedGasLimit = _expectedGasLimit;
        expectedGasUsed = _expectedGasUsed;
        expectedTimestamp = _expectedTimestamp;
        expectedExtraData = _expectedExtraData;
        expectedBaseFeePerGas = _expectedBaseFeePerGas;
        expectedBlockHash = _expectedBlockHash;
        expectedTransactionsRoot = _expectedTransactionsRoot;
        expectedWithdrawalRoot = _expectedWithdrawalRoot;
    }

    function evaluateParentHash() internal view returns (bool) {
        return getParentHash() == expectedParentHash;
    }

    function evaluatePrevRandao() internal view returns (bool) {
        return getPrevRandao() == expectedPrevRandao;
    }

    function evaluateBlockNumber() internal view returns (bool) {
        return getBlockNumber() == expectedBlockNumber;
    }

    function evaluateGasLimit() internal view returns (bool) {
        return getGasLimit() == expectedGasLimit;
    }

    function evaluateGasUsed() internal view returns (bool) {
        return getGasUsed() == expectedGasUsed;
    }

    function evaluateTimestamp() internal view returns (bool) {
        return getTimestamp() == expectedTimestamp;
    }


    function evaluateBaseFeePerGas() internal view returns (bool) {
        return getBaseFeePerGas() == expectedBaseFeePerGas;
    }

    function evaluateBlockHash() internal view returns (bool) {
        return getBlockHash() == expectedBlockHash;
    }

    function isFulfilled() public view override returns (bool) {
        return (
            evaluateParentHash() &&
            evaluatePrevRandao() &&
            evaluateBlockNumber() &&
            evaluateGasLimit() &&
            evaluateGasUsed() &&
            evaluateTimestamp() &&
            evaluateBaseFeePerGas() &&
            evaluateBlockHash()
        );
    }
}
