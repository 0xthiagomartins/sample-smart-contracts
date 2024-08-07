// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Crowdfund} from "../../src/token/Crowdfund.sol";
import {DeGymToken} from "../../src/token/DGYM.sol";

contract DeployCrowdfund is Script {
    function run() external {
        vm.startBroadcast();

        address tokenAddress = vm.envAddress("DEPLOYED_TOKEN_ADDRESS");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");
        address initialAuthority = vm.envAddress("INITIAL_AUTHORITY");

        Crowdfund crowdfund = new Crowdfund(
            tokenAddress,
            walletAddress,
            initialAuthority
        );

        DeGymToken token = DeGymToken(tokenAddress);
        uint256 totalSupply = token.totalSupply();

        crowdfund.initializePhase(
            "Pre-seed sale", // phaseName
            0.3 ether, // rate (each DGYM costs 0.3 ether)
            (totalSupply * 3) / 100, // allocation
            1725192000, // startDate - September 1, 2024 12:00:00 PM in timestamp
            30 days, // duration
            true, // burnable
            60 days, // cliffDuration
            365 days // vestingDuration
        );

        // Transfer the amount for pre-seed
        token.transfer(address(crowdfund), (totalSupply * 3) / 100);

        console.log("Crowdfund contract deployed at:", address(crowdfund));

        vm.stopBroadcast();
    }
}
