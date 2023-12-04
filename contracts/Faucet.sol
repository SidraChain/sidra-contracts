// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract Faucet is Pausable {
    // Mapping to track the amount of coins sent to each wallet
    mapping(address => uint256) public sent;

    // Mapping to track the number of coins received by the contract
    mapping(address => uint256) public received;

    // Event to track the amount of coins sent to a wallet
    event Sent(
        address indexed _wallet,
        uint256 indexed _amount,
        uint256 indexed _at
    );

    // Event to track the number of times a wallet has been used
    event Received(
        address indexed _wallet,
        uint256 indexed _amount,
        uint256 indexed _at
    );

    function _safeTransfer(address _to, uint256 _amount) internal {
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // Function to transfer coins from the contract to a recipient
    function send(
        address _recipient,
        uint256 _amount
    ) external whenNotPaused onlyOwner {
        require(
            address(this).balance >= _amount,
            "Not enough balance in the contract"
        );
        require(_amount > 0, "Invalid amount");

        _safeTransfer(_recipient, _amount);
        // Track the amount of coins sent to the wallet
        sent[_recipient] += _amount;
        // Track the number of times the wallet has been used
        emit Sent(_recipient, _amount, block.timestamp);
    }

    // Fall back function to receive coins into the contract
    receive() external payable whenNotPaused {
        // Track the coins received by the contract
        received[msg.sender] += msg.value;
        // Track the amount of coins received by the contract
        emit Received(msg.sender, msg.value, block.timestamp);
    }

    // Function to get the balance of the contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
