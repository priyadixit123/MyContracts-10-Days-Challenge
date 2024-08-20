//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.9.0;


contract MultiSigWallet {
    uint256 private _transactionCount;
    mapping(uint256 => Transaction) private _transactions;
    mapping(uint256 => mapping(address => bool)) private _approvals;

    struct Transaction {
        address payable to;
        uint256 value;
        bool executed;
        uint256 approvals;
    }

    modifier onlyValidTransaction(uint256 transactionId) {
        require(transactionId <= _transactionCount, "Invalid transaction ID");
        require(!_transactions[transactionId].executed, "Transaction already executed");
        _;
    }

    function submitTransaction(address payable to, uint256 value) public returns (uint256) {
        uint256 transactionId = _transactionCount + 1;
        _transactions[transactionId] = Transaction(to, value, false, 0);
        _transactionCount++;
        return transactionId;
    }

    function approveTransaction(uint256 transactionId) public {
        require(!_approvals[transactionId][msg.sender], "Already approved");
        require(!_transactions[transactionId].executed, "Transaction already executed");
        _approvals[transactionId][msg.sender] = true;
        _transactions[transactionId].approvals++;

        if (_transactions[transactionId].approvals >= 2) {
            executeTransaction(transactionId);
        }
    }

    function executeTransaction(uint256 transactionId) public onlyValidTransaction(transactionId) {
        require(_transactions[transactionId].approvals >= 2, "Insufficient approvals");
        Transaction storage transaction = _transactions[transactionId];
        transaction.executed = true;
        transaction.to.transfer(transaction.value);
    }

    function getTransactionStatus(uint256 transactionId) public view returns (bool) {
        return _transactions[transactionId].executed;
    }
}
