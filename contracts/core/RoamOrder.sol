// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Like {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract RoamOrder {
    struct Order {
        uint256 amount;
        uint256 createdAt;
        uint256 quotaMultiple;
        uint256 quotaMax;
    }

    address public owner;
    address public usdtToken;
    address public platform;

    mapping(address => uint256) public totalStaked;
    mapping(address => Order[]) private userOrders;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 quotaMultiple,
        uint256 quotaMax,
        uint256 createdAt
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _usdtToken, address _platform) {
        require(_usdtToken != address(0), "invalid usdt");
        require(_platform != address(0), "invalid platform");
        owner = msg.sender;
        usdtToken = _usdtToken;
        platform = _platform;
    }

    function setPlatform(address _platform) external onlyOwner {
        require(_platform != address(0), "invalid platform");
        platform = _platform;
    }

    function stakeUSDT(uint256 amount) external {
        uint256 unit = 100 * 10 ** 6; // 100 USDT, 6 decimals

        require(amount >= unit, "min 100 usdt");
        require(amount % unit == 0, "must be multiple of 100 usdt");

        bool ok = IERC20Like(usdtToken).transferFrom(msg.sender, platform, amount);
        require(ok, "transferFrom failed");

        uint256 quotaMultiple = getQuotaMultiple(amount);
        uint256 quotaMax = amount * quotaMultiple / 10;

        userOrders[msg.sender].push(
            Order({
                amount: amount,
                createdAt: block.timestamp,
                quotaMultiple: quotaMultiple,
                quotaMax: quotaMax
            })
        );

        totalStaked[msg.sender] += amount;

        emit Staked(msg.sender, amount, quotaMultiple, quotaMax, block.timestamp);
    }

    function getQuotaMultiple(uint256 amount) public pure returns (uint256) {
        uint256 one = 10 ** 6;

        if (amount >= 3000 * one) {
            return 30; // 3.0x
        } else if (amount >= 1000 * one) {
            return 25; // 2.5x
        } else {
            return 20; // 2.0x
        }
    }

    function getUserOrderCount(address user) external view returns (uint256) {
        return userOrders[user].length;
    }

    function getUserOrder(address user, uint256 index) external view returns (Order memory) {
        require(index < userOrders[user].length, "index out of bounds");
        return userOrders[user][index];
    }
}