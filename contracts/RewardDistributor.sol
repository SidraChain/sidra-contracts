// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract RewardDistributor is Pausable {
    address public faucet;
    uint256 public fees; // 0.01 ether must be added in genesis as for genesis storage is set to 0 by default
    uint256 public totalEvents;
    uint256 public totalSupply;
    uint256 public totalFaucetSupply;
    mapping(address => uint256) public coins;
    mapping(address => uint256) public events;
    mapping(address => uint256) public lastEvent;

    event Distributed(
        address indexed _wallet,
        uint256 indexed _events,
        uint256 indexed _at
    );
    event Received(
        address indexed _wallet,
        uint256 indexed _amount,
        uint256 indexed _at
    );
    event SupplyUpdated(
        uint256 indexed _totalSupply,
        uint256 indexed _totalFaucetSupply,
        uint256 indexed _at
    );

    event FaucetChanged(address indexed _faucet, uint256 indexed _at);
    event FeesChanged(uint256 indexed _fees, uint256 indexed _at);

    function eventsOf(address _wallet) external view returns (uint256) {
        return events[_wallet];
    }

    function coinsOf(address _wallet) external view returns (uint256) {
        return coins[_wallet];
    }

    function lastEventOf(address _wallet) external view returns (uint256) {
        return lastEvent[_wallet];
    }

    function _safeTransfer(address _to, uint256 _amount) internal {
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function distribute(
        address _wallet,
        uint256 _events
    ) external whenNotPaused onlyOwner {
        require(_wallet != address(0), "Invalid wallet address");
        require(_events >= 7 && _events <= 90, "Invalid event count");
        require(
            block.timestamp - lastEvent[_wallet] >= 7 days,
            "Wallet already used this week"
        );

        uint256 _amount = (_events * 2 ether) - fees;
        uint256 _faucetAmount = (_events * 8 ether);

        _safeTransfer(faucet, _faucetAmount);
        _safeTransfer(_wallet, _amount);
        _safeTransfer(msg.sender, fees);

        lastEvent[_wallet] = block.timestamp;

        totalEvents += _events;
        coins[_wallet] += _amount;
        events[_wallet] += _events;

        coins[faucet] += _faucetAmount;
        coins[msg.sender] += fees;

        totalFaucetSupply += _faucetAmount;
        totalSupply += _amount + _faucetAmount + fees;

        emit Received(_wallet, _amount, block.timestamp);
        emit Received(faucet, _faucetAmount, block.timestamp);

        emit Distributed(_wallet, _events, block.timestamp);
        emit SupplyUpdated(totalSupply, totalFaucetSupply, block.timestamp);
    }

    function setFaucet(address _faucet) external whenNotPaused onlyOwner {
        require(_faucet != address(0), "Invalid faucet address");
        require(_faucet != faucet, "Faucet already set");
        faucet = _faucet;
        emit FaucetChanged(_faucet, block.timestamp);
    }

    function setFees(uint256 _fees) external whenNotPaused onlyOwner {
        require(_fees > 0, "Invalid fees amount");
        require(_fees != fees, "Fees already set");
        fees = _fees;
        emit FeesChanged(_fees, block.timestamp);
    }
}
