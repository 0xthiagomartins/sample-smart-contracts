// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {GovernorContract} from "../src/Governor.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract DeployGovernor is Script {
    function run() external {
        address tokenAddress = vm.envAddress("DEPLOYED_TOKEN_ADDRESS");
        address proposer = msg.sender;
        address executor = msg.sender;
        address admin = msg.sender;

        address[] memory proposers = new address[](1);
        proposers[0] = proposer;
        address[] memory executors = new address[](1);
        executors[0] = executor;

        vm.startBroadcast();

        TimelockController timelock = new TimelockController(
            1 days, // Min delay
            proposers,
            executors,
            admin
        );

        IVotes token = IVotes(tokenAddress);
        GovernorContract governor = new GovernorContract(token, timelock);

        console.log("TimelockController deployed at:", address(timelock));
        console.log("GovernorContract deployed at:", address(governor));

        vm.stopBroadcast();
    }
}
