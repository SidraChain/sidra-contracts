// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "../Owner.sol";

contract Pausable {
    Owner public owner;
    bool public paused;

    event Paused(uint256 indexed _at);
    event Unpaused(uint256 indexed _at);

    function _onlyOwner() internal view {
        require(owner.owner() == msg.sender, "You are not the owner");
    }

    function _whenNotPaused() internal view {
        require(!paused, "Contract is paused");
    }

    function _whenPaused() internal view {
        require(paused, "Contract is not paused");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    modifier whenNotPaused() {
        _whenNotPaused();
        _;
    }

    modifier whenPaused() {
        _whenPaused();
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
