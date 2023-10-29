// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract WalletAccessControl is Pausable {
    // Mapping to track the enabled wallets
    uint256 public whitelistCount; // 0 - default value
    uint256 public greylistCount; // 0 - default value

    enum Status {
        Blacklisted, // 0 - default value
        Whitelisted, // 1
        Greylisted // 2
    }

    mapping(address => Status) public status;

    // These events are used to track the status of a wallet
    event Blacklisted(address indexed _wallet, uint256 indexed _at);
    event Whitelisted(address indexed _wallet, uint256 indexed _at);
    event Greylisted(address indexed _wallet, uint256 indexed _at);

    function _setStatus(address _addr, Status _status) internal {
        if (status[_addr] != _status) {
            if (_status == Status.Blacklisted) {
                delete status[_addr]; // Reset to default value
                emit Blacklisted(_addr, block.timestamp);
            } else if (_status == Status.Whitelisted) {
                whitelistCount++;
                status[_addr] = Status.Whitelisted;
                emit Whitelisted(_addr, block.timestamp);
            } else if (_status == Status.Greylisted) {
                greylistCount++;
                status[_addr] = Status.Greylisted;
                emit Greylisted(_addr, block.timestamp);
            }
        }
    }

    function setWalletStatus(
        address _addr,
        Status _status
    ) external whenNotPaused onlyOwner {
        _setStatus(_addr, _status);
    }

    function batchSetWalletStatus(
        address[] calldata _addrs,
        Status _status
    ) external whenNotPaused onlyOwner {
        require(_addrs.length > 0, "Empty list");
        require(
            _addrs.length <= 100,
            "Only 100 wallets can be processed at a time"
        );
        for (uint8 i = 0; i < _addrs.length; ) {
            _setStatus(_addrs[i], _status);
            unchecked {
                ++i;
            }
        }
    }

    function isBlacklisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.Blacklisted;
    }

    function isWhitelisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.Whitelisted;
    }

    function isGreylisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.Greylisted;
    }
}
