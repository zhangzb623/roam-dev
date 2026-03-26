// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract RoamWithdrawSimple {

    address public owner;

    address public roamToken;

    address public feePool;

    address public fundAddress;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(
        address _roamToken,
        address _feePool,
        address _fundAddress
    ) {
        owner = msg.sender;
        roamToken = _roamToken;
        feePool = _feePool;
        fundAddress = _fundAddress;
    }

    function withdrawSimple(
        address user,
        uint256 totalAmount
    ) external onlyOwner {

        uint256 userAmount = totalAmount * 855 / 1000;

        uint256 feeAmount = totalAmount * 50 / 1000;

        uint256 fundAmount = totalAmount * 95 / 1000;

        require(
            userAmount + feeAmount + fundAmount == totalAmount,
            "calc error"
        );

        IERC20(roamToken).transfer(user, userAmount);

        IERC20(roamToken).transfer(feePool, feeAmount);

        IERC20(roamToken).transfer(fundAddress, fundAmount);
    }
}