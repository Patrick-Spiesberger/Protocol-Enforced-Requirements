// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";

abstract contract BlockHeaderCondition is ICondition {
    uint256 public expectedBlockNumber;
    address public expectedCoinbase;
    uint256 public expectedGasLimit;
    uint256 public expectedBaseFee;
    uint256 public expectedChainId;
    uint256 public expectedPrevRandao;
    uint256 public expectedTimestamp;

    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    function getCoinbase() internal view returns (address) {
        return block.coinbase;
    }

    function getGasLimit() internal view returns (uint256) {
        return block.gaslimit;
    }

    function getBaseFee() internal view returns (uint256) {
        return block.basefee;
    }

    function getChainId() internal view returns (uint256) {
        return block.chainid;
    }

    function getPrevRandao() internal view returns (uint256) {
        return block.prevrandao;
    }

    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
}

contract BlockHeaderConditions is BlockHeaderCondition {

    constructor(
        uint256 _expectedBlockNumber,
        address _expectedCoinbase,
        uint256 _expectedGasLimit,
        uint256 _expectedBaseFee,
        uint256 _expectedChainId,
        uint256 _expectedPrevRandao,
        uint256 _expectedTimestamp
    ) {
        expectedBlockNumber = _expectedBlockNumber;
        expectedCoinbase = _expectedCoinbase;
        expectedGasLimit = _expectedGasLimit;
        expectedBaseFee = _expectedBaseFee;
        expectedChainId = _expectedChainId;
        expectedPrevRandao = _expectedPrevRandao;
        expectedTimestamp = _expectedTimestamp;
    }

    function evaluateBlockNumber() internal view returns (bool) {
        return getBlockNumber() == expectedBlockNumber;
    }

    function evaluateCoinbase() internal view returns (bool) {
        return getCoinbase() == expectedCoinbase;
    }

    function evaluateGasLimit() internal view returns (bool) {
        return getGasLimit() == expectedGasLimit;
    }

    function evaluateBaseFee() internal view returns (bool) {
        return getBaseFee() == expectedBaseFee;
    }

    function evaluateChainId() internal view returns (bool) {
        return getChainId() == expectedChainId;
    }

    function evaluatePrevRandao() internal view returns (bool) {
        return getPrevRandao() == expectedPrevRandao;
    }

    function evaluateTimestamp() internal view returns (bool) {
        return getTimestamp() == expectedTimestamp;
    }

    function isFulfilled() public view override returns (bool) {
        return (
            evaluateBlockNumber() &&
            evaluateCoinbase() &&
            evaluateGasLimit() &&
            evaluateBaseFee() &&
            evaluateChainId() &&
            evaluatePrevRandao() &&
            evaluateTimestamp()
        );
    }
}
