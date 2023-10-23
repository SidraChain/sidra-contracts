// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "../Owner.sol";

contract Pausable {
    Owner public owner;

    bool public paused;

    event Paused(uint256 indexed _at);
    event Unpaused(uint256 indexed _at);

    modifier onlyOwner() {
        require(owner.owner() == msg.sender, "You are not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    function pause() external whenNotPaused onlyOwner {
        paused = true;
        emit Paused(block.timestamp);
    }

    function unpause() external whenPaused onlyOwner {
        paused = false;
        emit Unpaused(block.timestamp);
    }
}
