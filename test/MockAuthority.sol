// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAuthority {
    mapping(address => bool) public managers;

    function setManager(address manager, bool status) public {
        managers[manager] = status;
    }

    function canCallWithDelay(
        address,
        address caller,
        address,
        bytes4
    ) external view returns (bool, uint32) {
        return (managers[caller], 0);
    }

    function consumeScheduledOp(address, bytes calldata) external {}
}
