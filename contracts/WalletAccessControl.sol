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
        BLACKLISTED, // 0
        WHITELISTED, // 1
        SEND_GREYLISTED, // 2
        RECEIVE_GREYLISTED, // 3
        POOL_GREYLISTED // 4
    }

    mapping(address => Status) public status;
    mapping(address => bool) public blackListed;

    // Mapping of countries pool
    mapping(uint256 => mapping(address => bool)) public pools;

    // These events are used to track the status of a wallet
    event StatusChanged(
        address indexed _wallet,
        Status indexed _status,
        uint256 indexed _at
    );
    event AddedToPool(
        uint256 indexed _poolId,
        address indexed _wallet,
        uint256 indexed _at
    );
    event RemovedFromPool(
        uint256 indexed _poolId,
        address indexed _wallet,
        uint256 indexed _at
    );

    function _resetCounter(address _addr) internal {
        if (status[_addr] == Status.BLACKLISTED && blackListed[_addr]) {
            unchecked {
                --blackListCount;
            }
            delete blackListed[_addr];
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
    }

    function _setBlacklisted(address _addr) internal {
        _resetCounter(_addr);
        delete status[_addr];
        blackListed[_addr] = true;
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

    function _setStatus(address _addr, Status _status) internal {
        if (status[_addr] == _status) {
            return;
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
    }

    function setWalletStatus(
        address _addr,
        Status _status
    ) external whenNotPaused onlyOwner {
        _setStatus(_addr, _status);
    }

    function _addInPool(uint256 _poolId, address _addr) internal {
        if (pools[_poolId][_addr]) {
            return;
        }
        if (_poolId == 0) {
            return;
        }
        pools[_poolId][_addr] = true;
        unchecked {
            ++poolGreylistCount;
        }
        emit AddedToPool(_poolId, _addr, block.timestamp);
    }

    function _removeFromPool(uint256 _poolId, address _addr) internal {
        if (!pools[_poolId][_addr]) {
            return;
        }
        if (_poolId == 0) {
            return;
        }
        delete pools[_poolId][_addr];
        unchecked {
            --poolGreylistCount;
        }
        emit RemovedFromPool(_poolId, _addr, block.timestamp);
    }

    function addInPool(
        uint256 _poolId,
        address _addr
    ) external whenNotPaused onlyOwner {
        _addInPool(_poolId, _addr);
    }

    function removeFromPool(
        uint256 _poolId,
        address _addr
    ) external whenNotPaused onlyOwner {
        _removeFromPool(_poolId, _addr);
    }

    function batchAddInPool(
        uint256 _poolId,
        address[] calldata _addrs
    ) external whenNotPaused onlyOwner {
        require(_addrs.length > 0, "Empty list");
        require(
            _addrs.length <= 100,
            "Only 100 wallets can be processed at a time"
        );
        for (uint8 i = 0; i < _addrs.length; ) {
            _addInPool(_poolId, _addrs[i]);
            unchecked {
                ++i;
            }
        }
    }

    function batchRemoveFromPool(
        uint256 _poolId,
        address[] calldata _addrs
    ) external whenNotPaused onlyOwner {
        require(_addrs.length > 0, "Empty list");
        require(
            _addrs.length <= 100,
            "Only 100 wallets can be processed at a time"
        );
        for (uint8 i = 0; i < _addrs.length; ) {
            _removeFromPool(_poolId, _addrs[i]);
            unchecked {
                ++i;
            }
        }
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
        return status[_addr] == Status.BLACKLISTED;
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

    function isInPool(
        uint256 _poolId,
        address _addr
    ) public view returns (bool) {
        return pools[_poolId][_addr];
    }
}
