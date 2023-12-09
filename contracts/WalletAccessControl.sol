// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract WalletAccessControl is Pausable {
    // Mapping to track the enabled wallets
    uint256 public blackListCount; // 0 - default value
    uint256 public whitelistCount; // 0 - default value
    uint256 public sendGreylistCount; // 0 - default value
    uint256 public receiveGreylistCount; // 0 - default value
    uint256 public poolGreylistCount; // 0 - default value

    enum Status {
        UNLISTED, // 0
        WHITELISTED, // 1
        BLACKLISTED, // 2
        SEND_GREYLISTED, // 3
        RECEIVE_GREYLISTED, // 4
        POOL_GREYLISTED // 5
    }

    mapping(address => Status) public status;

    // These events are used to track the status of a wallet
    event StatusChanged(
        address indexed _wallet,
        Status indexed _status,
        uint256 indexed _at
    );

    function _resetCounter(address _addr) internal {
        if (status[_addr] == Status.UNLISTED) {
            return;
        }
        if (status[_addr] == Status.BLACKLISTED) {
            unchecked {
                --blackListCount;
            }
            return;
        }
        if (status[_addr] == Status.WHITELISTED) {
            unchecked {
                --whitelistCount;
            }
            return;
        }
        if (status[_addr] == Status.SEND_GREYLISTED) {
            unchecked {
                --sendGreylistCount;
            }
            return;
        }
        if (status[_addr] == Status.RECEIVE_GREYLISTED) {
            unchecked {
                --receiveGreylistCount;
            }
        }
        if (status[_addr] == Status.POOL_GREYLISTED) {
            unchecked {
                --poolGreylistCount;
            }
        }
    }

    function _setUnlisted(address _addr) internal {
        _resetCounter(_addr);
        delete status[_addr];
        emit StatusChanged(_addr, Status.UNLISTED, block.timestamp);
    }

    function _setBlacklisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.BLACKLISTED;
        unchecked {
            ++blackListCount;
        }
        emit StatusChanged(_addr, Status.BLACKLISTED, block.timestamp);
    }

    function _setWhitelisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.WHITELISTED;
        unchecked {
            ++whitelistCount;
        }
        emit StatusChanged(_addr, Status.WHITELISTED, block.timestamp);
    }

    function _setSendingGreylisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.SEND_GREYLISTED;
        unchecked {
            ++sendGreylistCount;
        }
        emit StatusChanged(_addr, Status.SEND_GREYLISTED, block.timestamp);
    }

    function _setReceivingGreylisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.RECEIVE_GREYLISTED;
        unchecked {
            ++receiveGreylistCount;
        }
        emit StatusChanged(_addr, Status.RECEIVE_GREYLISTED, block.timestamp);
    }

    function _setPoolGreylisted(address _addr) internal {
        _resetCounter(_addr);
        status[_addr] = Status.POOL_GREYLISTED;
        unchecked {
            ++poolGreylistCount;
        }
        emit StatusChanged(_addr, Status.POOL_GREYLISTED, block.timestamp);
    }

    function _setStatus(address _addr, Status _status) internal {
        if (status[_addr] == _status) {
            return;
        }
        if (_status == Status.UNLISTED) {
            return _setUnlisted(_addr);
        }
        if (_status == Status.BLACKLISTED) {
            return _setBlacklisted(_addr);
        }
        if (_status == Status.WHITELISTED) {
            return _setWhitelisted(_addr);
        }
        if (_status == Status.SEND_GREYLISTED) {
            return _setSendingGreylisted(_addr);
        }
        if (_status == Status.RECEIVE_GREYLISTED) {
            return _setReceivingGreylisted(_addr);
        }
        if (_status == Status.POOL_GREYLISTED) {
            return _setPoolGreylisted(_addr);
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
        return
            status[_addr] == Status.BLACKLISTED ||
            status[_addr] == Status.UNLISTED;
    }

    function isWhitelisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.WHITELISTED;
    }

    function isGreylisted(address _addr) public view returns (bool) {
        return status[_addr] > Status.WHITELISTED;
    }

    function isSendingGreylisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.SEND_GREYLISTED;
    }

    function isReceivingGreylisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.RECEIVE_GREYLISTED;
    }

    function isPoolGreylisted(address _addr) public view returns (bool) {
        return status[_addr] == Status.POOL_GREYLISTED;
    }
}
