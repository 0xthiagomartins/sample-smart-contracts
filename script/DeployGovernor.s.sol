// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Governor.sol";
import "../src/token/DGYM.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract DeployGovernor is Script {
    function run() external {
        vm.startBroadcast();

        address tokenAddress = 0xYourDeployedTokenAddress; // Replace with the actual deployed token address
        address proposer = msg.sender;
        address executor = msg.sender;
        address admin = msg.sender;

        TimelockController timelock = new TimelockController(
            1 days, // Min delay
            new address ,
            new address ,
            admin
        );

        IVotes token = IVotes(tokenAddress);
        GovernorContract governor = new GovernorContract(token, timelock);

        console.log("TimelockController deployed at:", address(timelock));
        console.log("GovernorContract deployed at:", address(governor));

        vm.stopBroadcast();
    }
}
