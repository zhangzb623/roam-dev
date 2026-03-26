// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockROAM {
    string public name = "Mock ROAM";
    string public symbol = "ROAM";
    uint8 public decimals = 6;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
    挖矿（假挖矿），用户调用这个方法就能给自己增加余额
    */
    function mint(address to, uint256 amount) external {
        require(to != address(0), "zero address");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(to != address(0), "zero address");
        require(balanceOf[msg.sender] >= amount, "insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
        授权给roam一定额度，才能进行转账，这里后续是调用RoamWithdrawSimple.sol中的withdrawSimple方法
        ，所以这个是用户来调用，传RoamOrder.sol的合约地址
    */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(from != address(0), "zero from");
        require(to != address(0), "zero to");
        require(balanceOf[from] >= amount, "insufficient balance");
        require(allowance[from][msg.sender] >= amount, "insufficient allowance");

        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }
}