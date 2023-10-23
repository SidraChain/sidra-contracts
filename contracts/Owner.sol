// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Owner {
    address public owner;
    address public superOwner;
    address public pendingOwner;

    event SuperOwnerChanged(address indexed _old, address indexed _new);
    event OwnerChanged(address indexed _old, address indexed _new);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlySuperOwner() {
        require(msg.sender == superOwner, "You are not the super owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner != address(0), "No pending owner");
        require(msg.sender == pendingOwner, "You are not the pending owner");
        _;
    }

    function transferOwnership(address _newOwner) external onlySuperOwner {
        require(_newOwner != owner, "You are already the owner");
        require(_newOwner != address(0), "New owner address cannot be zero");
        pendingOwner = _newOwner;
    }

    function changeOwner(address _newOwner) external onlySuperOwner {
        require(_newOwner != owner, "Owner address cannot be the same");
        require(_newOwner != address(0), "New owner address cannot be zero");
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    function acceptOwnership() external onlyPendingOwner {
        emit SuperOwnerChanged(owner, pendingOwner);
        superOwner = pendingOwner;
        delete pendingOwner;
    }

    function revertPendingOwnership() external onlySuperOwner {
        require(pendingOwner != address(0), "No pending owner");
        delete pendingOwner;
    }
}
