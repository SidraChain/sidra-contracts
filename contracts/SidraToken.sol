// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./WalletAccessControl.sol";

contract SidraToken is Pausable {
    WalletAccessControl public wac;

    string public symbol = "ST";
    string public name = "Sidra Token";

    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public totalMiners;
    uint256 public convertedSupply;

    // As mapping is public, we get a free getter function
    // Like miner(address) outside of this contract to check if a wallet is miner
    mapping(address => bool) public miner;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastMiningTime;

    // These events are used to track token supply and converted supply
    event TokenSupply(uint256 indexed _amount, uint256 indexed _at);
    event ConvertedSupply(uint256 indexed _amount, uint256 indexed _at);

    //  These events are used to track mining activities and token minting
    event Mined(address indexed _miner, uint256 indexed _at);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // This event is used to track coin minting
    event MintedByOwner(
        address indexed _to,
        uint256 indexed _amount,
        uint256 indexed _at
    );

    // This event is used to track token conversion
    event Converted(
        address indexed _wallet,
        uint256 indexed _amount,
        uint256 indexed _at
    );

    // This event is used to track miner status (Activated or Deactivated)
    event MinerStatus(
        address indexed _wallet,
        bool indexed _status,
        uint256 indexed _at
    );

    // This event is used to track total active miners
    event ActiveMiners(uint256 indexed _count, uint256 indexed _at);

    modifier onlyMiner() {
        require(miner[msg.sender], "You are not a miner");
        _;
    }

    modifier OnlyWhitelisted() {
        // It means greylisted and whitelisted wallets can use this function
        require(
            !wac.isWhitelisted(msg.sender),
            "Your wallet is not whitelisted"
        );
        _;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    function mine() external whenNotPaused onlyMiner {
        // Miners can only mine once a day
        require(
            (lastMiningTime[msg.sender] + 1 days) < block.timestamp,
            "You can only mine once a day"
        );
        // Update last mining time
        lastMiningTime[msg.sender] = block.timestamp;
        // Update balances of the sender with 2 ST reward
        balances[msg.sender] += 2 ether;
        // Update balances of the contract with 8 ST
        balances[address(this)] += 8 ether;
        // Update total supply
        totalSupply += 10 ether;
        // Emit events
        emit Mined(msg.sender, block.timestamp);
        emit Transfer(address(0), msg.sender, 2 ether);
        emit Transfer(address(0), address(this), 8 ether);
        emit TokenSupply(totalSupply, block.timestamp);
    }

    function convert(uint256 _amount) external whenNotPaused OnlyWhitelisted {
        /************* Convert function will convert Sidra Tokens to Coins *************/
        // Convert function will convert Sidra Tokens to Coins
        // 1 Sidra Token = 1 Coin
        // As this is genesis smart contract the coin conversation is handled in consensus layer
        /******************************************************************************/

        // Check if the sender has enough balances
        require(balances[msg.sender] >= _amount, "Insufficient balances");

        // Check if the amount is more than 14 and multiple of 14
        require(
            _amount >= 14 ether && _amount % 14 ether == 0,
            "Amount must be more than or equal to 14 and multiple of 14"
        );

        // Calculate the amount of main faucet tokens to be converted
        uint256 _mainFaucetAmount = _amount * 4;

        // Update balances
        balances[msg.sender] -= _amount;
        balances[address(this)] -= _mainFaucetAmount;

        // Calculate the total supply
        uint256 _supply = _amount + _mainFaucetAmount;

        // Update total supply and circulating supply
        totalSupply -= _supply;
        convertedSupply += _supply;

        // Emit events
        emit Transfer(msg.sender, address(0), _amount);
        emit Transfer(address(this), address(0), _mainFaucetAmount);

        // Converted Events
        emit Converted(msg.sender, _amount, block.timestamp);

        // Supply Events
        emit TokenSupply(totalSupply, block.timestamp);
        emit ConvertedSupply(convertedSupply, block.timestamp);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external whenNotPaused onlyOwner {
        /************* Mint function will mint Sidra Coins to a wallet *************/
        // These coins are exactly same as the coins minted by the miners before KYC
        // 1 Sidra Token = 1 Coin
        // As this is genesis smart contract the coin conversation is handled in consensus layer
        /******************************************************************************/

        // Check if the sender has enough balances
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than 0");

        // Calculate main faucet amount
        uint256 _mainFaucetAmount = _amount * 4;

        // Update balances
        convertedSupply += _amount + _mainFaucetAmount;

        // Emit events for consistency
        emit Transfer(address(0), _to, _amount);
        emit Transfer(address(0), address(this), _mainFaucetAmount);

        // Emit Transfer event for consistency
        emit Transfer(_to, address(0), _amount);
        emit Transfer(address(this), address(0), _mainFaucetAmount);

        // Emit TokenSupply event for consistency
        emit TokenSupply(
            totalSupply + _amount + _mainFaucetAmount,
            block.timestamp
        );

        // Emit MintedByOwner event to be transparent about the coin minting

        // Emit Converted Supply event
        emit TokenSupply(totalSupply, block.timestamp);
        emit ConvertedSupply(convertedSupply, block.timestamp);

        // Emit MintedByOwner event to be transparent about the coin minting
        emit MintedByOwner(_to, _amount, block.timestamp);
    }

    /*** Miner Functions ***/
    function _addMiner(address _addr) internal {
        if (!miner[_addr]) {
            // Activate miner
            miner[_addr] = true;
            // Set last mining time to current block timestamp to avoid mining immediately
            lastMiningTime[_addr] = block.timestamp;
            // Increment total miner
            totalMiners++;
            // Emit events
            emit MinerStatus(_addr, true, block.timestamp);
            emit ActiveMiners(totalMiners, block.timestamp);
        }
    }

    function _removeMiner(address _addr) internal {
        if (miner[_addr]) {
            delete miner[_addr];
            delete lastMiningTime[_addr];
            totalMiners--;
            emit MinerStatus(_addr, false, block.timestamp);
            emit ActiveMiners(totalMiners, block.timestamp);
        }
    }

    function addMiner(address _addr) external whenNotPaused onlyOwner {
        _addMiner(_addr);
    }

    function removeMiner(address _addr) external whenNotPaused onlyOwner {
        _removeMiner(_addr);
    }

    function batchAddMiner(
        address[] calldata _addrs
    ) external whenNotPaused onlyOwner {
        require(_addrs.length > 0, "Empty list");
        require(_addrs.length <= 100, "Only 100 miners can be added at a time");

        for (uint8 i = 0; i < _addrs.length; ) {
            _addMiner(_addrs[i]);
            unchecked {
                ++i;
            }
        }
    }

    function batchRemoveMiner(
        address[] calldata _addrs
    ) external whenNotPaused onlyOwner {
        require(_addrs.length > 0, "Empty list");
        require(
            _addrs.length <= 100,
            "Only 100 miners can be removed at a time"
        );
        for (uint8 i = 0; i < _addrs.length; ) {
            _removeMiner(_addrs[i]);
            unchecked {
                ++i;
            }
        }
    }
}
