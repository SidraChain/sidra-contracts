// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract WalletAccessControl is Pausable {
    // Mapping to track the enabled wallets
    uint256 public whitelistCount; // 0 - default value
    uint256 public sendGreylistCount; // 0 - default value
    uint256 public receiveGreylistCount; // 0 - default value

    enum Status {
        Blacklisted, // 0 - default value
        Whitelisted, // 1
        SendingGreylisted, // 2
        ReceivingGreylisted // 3
    }

    mapping(address => Status) public status;

    // These events are used to track the status of a wallet
    event Blacklisted(address indexed _wallet, uint256 indexed _at);
    event Whitelisted(
        address indexed _wallet,
        uint256 indexed _at,
        uint256 indexed _count
    );
    event SendingGreylisted(
        address indexed _wallet,
        uint256 indexed _at,
        uint256 indexed _count
    );
    event ReceivingGreylisted(
        address indexed _wallet,
        uint256 indexed _at,
        uint256 indexed _count
    );

    function _resetCounter(address _addr) internal {
        if (status[_addr] == Status.Blacklisted) {
            return;
        }
        if (status[_addr] == Status.Whitelisted) {
            unchecked {
                --whitelistCount;
            }
            return;
        }
        if (status[_addr] == Status.SendingGreylisted) {
            unchecked {
                --sendGreylistCount;
            }
            return;
        }
        if (status[_addr] == Status.ReceivingGreylisted) {
            unchecked {
                --receiveGreylistCount;
            }
        }
    }

    function _setBlacklisted(address _addr) internal {
        _resetCounter(_addr);
        delete status[_addr];
        emit Blacklisted(_addr, block.timestamp);
    }

    function _setWhitelisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.Whitelisted;
        unchecked {
            ++whitelistCount;
        }
        emit Whitelisted(_addr, block.timestamp, whitelistCount);
    }

    function _setSendingGreylisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.SendingGreylisted;
        unchecked {
            ++sendGreylistCount;
        }
        emit SendingGreylisted(_addr, block.timestamp, sendGreylistCount);
    }

    function _setReceivingGreylisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.ReceivingGreylisted;
        unchecked {
            ++receiveGreylistCount;
        }
        emit ReceivingGreylisted(_addr, block.timestamp, receiveGreylistCount);
    }

    function _setStatus(address _addr, Status _status) internal {
        if (status[_addr] == _status) {
            return;
        }
        if (_status == Status.Blacklisted) {
            return _setBlacklisted(_addr);
        }
        if (_status == Status.Whitelisted) {
            return _setWhitelisted(_addr);
        }
        if (_status == Status.SendingGreylisted) {
            return _setSendingGreylisted(_addr);
        }
        if (_status == Status.ReceivingGreylisted) {
            return _setReceivingGreylisted(_addr);
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
        return status[_addr] > Status.Whitelisted;
    }

    function isSendingGreylisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.SendingGreylisted;
    }

    function isReceivingGreylisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.ReceivingGreylisted;
    }
}
