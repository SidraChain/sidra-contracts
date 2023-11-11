// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Owner {
    address public owner;
    address public superOwner;
    // TODO: pendingSuperOwner
    address public pendingOwner;

    event SuperOwnerChanged(address indexed _old, address indexed _new);
    event OwnerChanged(address indexed _old, address indexed _new);

    function _onlyOwner() internal view {
        require(owner == msg.sender, "You are not the owner");
    }

    function _onlySuperOwner() internal view {
        require(superOwner == msg.sender, "You are not the super owner");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    modifier onlySuperOwner() {
        _onlySuperOwner();
        _;
    }

    function transferSuperOwnership(address _newOwner) external onlySuperOwner {
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

    function acceptSuperOwnership() external {
        require(pendingOwner != address(0), "No pending owner");
        require(pendingOwner == msg.sender, "You are not the pending owner");

        emit SuperOwnerChanged(owner, pendingOwner);
        superOwner = pendingOwner;
        delete pendingOwner;
    }

    function revertPendingSuperOwnership() external onlySuperOwner {
        require(pendingOwner != address(0), "No pending owner");
        delete pendingOwner;
    }
}
