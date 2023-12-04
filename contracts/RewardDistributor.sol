// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract RewardDistributor is Pausable {
    address payable public faucet;
    uint256 public totalEvents;
    uint256 public totalSupply;
    uint256 public totalFaucetSupply;
    mapping(address => uint256) public events;

    event Distributed(
        address indexed _wallet,
        uint256 indexed _events,
        uint256 indexed _at
    );
    event SupplyUpdated(
        uint256 indexed _totalSupply,
        uint256 indexed _totalFaucetSupply,
        uint256 indexed _at
    );

    function eventsOf(address _wallet) external view returns (uint256) {
        return events[_wallet];
    }

    function coinsOf(address _wallet) external view returns (uint256) {
        return events[_wallet] * 2 ether;
    }

    function _safeFaucetTransfer(uint256 _amount) internal {
        (bool success, ) = faucet.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function distribute(
        address payable _wallet,
        uint256 _events
    ) external whenNotPaused onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(_events > 0, "Invalid events amount");

        uint256 _amount = _events * 2 ether;
        uint256 _faucetAmount = _events * 8 ether;

        _safeFaucetTransfer(_faucetAmount);
        _wallet.transfer(_amount);

        totalEvents += _events;
        events[_wallet] += _events;

        totalFaucetSupply += _faucetAmount;
        totalSupply += _amount + _faucetAmount;

        emit Distributed(_wallet, _events, block.timestamp);
        emit SupplyUpdated(totalSupply, totalFaucetSupply, block.timestamp);
    }

    function setFaucet(
        address payable _faucet
    ) external whenNotPaused onlyOwner {
        require(_faucet != address(0), "Invalid faucet address");
        require(_faucet != faucet, "Faucet already set");
        faucet = _faucet;
    }
}
