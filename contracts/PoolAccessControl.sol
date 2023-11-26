// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";

contract PoolAccessControl is Pausable {
    // Mapping of list of wallets in a pool
    mapping(address => uint256[]) public pools;

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

    function _isInPool(
        address _addr,
        uint256 _poolId
    ) internal view returns (bool) {
        uint256[] storage pool = pools[_addr];
        uint256 poolLength = pool.length;
        if (poolLength == 0) {
            return false;
        }
        for (uint256 i = 0; i < poolLength; ) {
            if (pool[i] == _poolId) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    function _addInPool(uint256 _poolId, address _addr) internal {
        if (_isInPool(_addr, _poolId)) {
            return;
        }
        pools[_addr].push(_poolId);
        emit AddedToPool(_poolId, _addr, block.timestamp);
    }

    function _removeFromPool(uint256 _poolId, address _addr) internal {
        if (!_isInPool(_addr, _poolId)) {
            return;
        }
        uint256[] storage pool = pools[_addr];
        uint256 poolLength = pool.length;
        for (uint256 i = 0; i < poolLength; ) {
            if (pool[i] == _poolId) {
                pool[i] = pool[poolLength - 1];
                pool.pop();
                emit RemovedFromPool(_poolId, _addr, block.timestamp);
                return;
            }
            unchecked {
                ++i;
            }
        }
    }

    function _removeFromAllPools(address _addr) internal {
        uint256[] storage pool = pools[_addr];
        uint256 poolLength = pool.length;
        if (poolLength == 0) {
            return;
        }
        for (uint256 i = 0; i < poolLength; ) {
            emit RemovedFromPool(pool[i], _addr, block.timestamp);
            unchecked {
                ++i;
            }
        }
        delete pools[_addr];
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

    function removeFromAllPools(
        address _addr
    ) external whenNotPaused onlyOwner {
        _removeFromAllPools(_addr);
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

    function batchRemoveFromAllPools(
        address[] calldata _addrs
    ) external whenNotPaused onlyOwner {
        require(_addrs.length > 0, "Empty list");
        require(
            _addrs.length <= 100,
            "Only 100 wallets can be processed at a time"
        );
        for (uint8 i = 0; i < _addrs.length; ) {
            _removeFromAllPools(_addrs[i]);
            unchecked {
                ++i;
            }
        }
    }

    function isInPool(
        address _addr,
        uint256 _poolId
    ) public view returns (bool) {
        return _isInPool(_addr, _poolId);
    }

    function getPoolCount(address _addr) external view returns (uint256) {
        return pools[_addr].length;
    }

    function isInSomePool(
        address _addrA,
        address _addrB
    ) external view returns (bool) {
        uint256[] storage poolA = pools[_addrA];
        uint256[] storage poolB = pools[_addrB];
        uint256 poolA_length = poolA.length;
        uint256 poolB_length = poolB.length;
        if (poolA_length == 0 || poolB_length == 0) {
            return false;
        }
        for (uint256 i = 0; i < poolA_length; ) {
            for (uint256 j = 0; j < poolB_length; ) {
                if (poolA[i] == poolB[j]) {
                    return true;
                }
                unchecked {
                    ++j;
                }
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }
}
