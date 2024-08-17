// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ICondition.sol";

abstract contract TransactionContextCondition is ICondition {
    address public expectedMsgSender;
    bytes4 public expectedMsgSig;
    uint256 public expectedMsgValue;
    uint256 public expectedTxGasPrice;
    address public expectedTxOrigin;

    function getMsgSender() internal view returns (address) {
        return msg.sender;
    }

    function getMsgSig() internal view returns (bytes4) {
        return msg.sig;
    }

    function getMsgValue() internal view returns (uint256) {
        return msg.value;
    }

    function getTxGasPrice() internal view returns (uint256) {
        return tx.gasprice;
    }

    function getTxOrigin() internal view returns (address) {
        return tx.origin;
    }
}

contract TransactionContextConditions is TransactionContextCondition {

    constructor(
        address _expectedMsgSender,
        bytes4 _expectedMsgSig,
        uint256 _expectedMsgValue,
        uint256 _expectedTxGasPrice,
        address _expectedTxOrigin
    ) {
        expectedMsgSender = _expectedMsgSender;
        expectedMsgSig = _expectedMsgSig;
        expectedMsgValue = _expectedMsgValue;
        expectedTxGasPrice = _expectedTxGasPrice;
        expectedTxOrigin = _expectedTxOrigin;
    }

    function evaluateMsgSender() internal view returns (bool) {
        return getMsgSender() == expectedMsgSender;
    }

    function evaluateMsgSig() internal view returns (bool) {
        return getMsgSig() == expectedMsgSig;
    }

    function evaluateMsgValue() internal view returns (bool) {
        return getMsgValue() == expectedMsgValue;
    }

    function evaluateTxGasPrice() internal view returns (bool) {
        return getTxGasPrice() == expectedTxGasPrice;
    }

    function evaluateTxOrigin() internal view returns (bool) {
        return getTxOrigin() == expectedTxOrigin;
    }

    function isFulfilled() public view override returns (bool) {
        return (
            evaluateMsgSender() &&
            evaluateMsgSig() &&
            evaluateMsgValue() &&
            evaluateTxGasPrice() &&
            evaluateTxOrigin()
        );
    }
}
