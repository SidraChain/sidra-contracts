// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Owner {
    address public owner;
    address public superOwner;
    address public pendingSuperOwner;

    event SuperOwnerChanged(address indexed _old, address indexed _new);
    event OwnerChanged(address indexed _old, address indexed _new);
    event SuperOwnershipTransferInitiated(address indexed _pendingSuperOwner);

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

    function initiateSuperOwnershipTransfer(
        address _superOwner
    ) external onlySuperOwner {
        require(_superOwner != superOwner, "You are already the owner");
        require(_superOwner != address(0), "New owner address cannot be zero");
        pendingSuperOwner = _superOwner;
        emit SuperOwnershipTransferInitiated(_superOwner);
    }

    function transferOwnership(address _owner) external onlySuperOwner {
        require(_owner != address(0), "New owner address cannot be zero");
        require(_owner != owner, "Owner address cannot be the same");
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    function acceptSuperOwnership() external {
        require(pendingSuperOwner != address(0), "No pending owner");
        require(
            pendingSuperOwner == msg.sender,
            "You are not the pending owner"
        );

        emit SuperOwnerChanged(owner, pendingSuperOwner);
        superOwner = pendingSuperOwner;
        delete pendingSuperOwner;
    }

    function cancelSuperOwnershipTransfer() external onlySuperOwner {
        require(pendingSuperOwner != address(0), "No pending owner");
        delete pendingSuperOwner;
        emit SuperOwnershipTransferInitiated(address(0));
    }
}
