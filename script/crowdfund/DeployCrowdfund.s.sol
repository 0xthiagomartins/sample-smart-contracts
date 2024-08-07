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
            "Pre-seed sale",
            0.3 ether,
            (totalSupply * 3) / 100,
            block.timestamp,
            block.timestamp + 2 weeks,
            true,
            60 days,
            365 days
        );

        // Transfer the amount for pre-seed
        token.transfer(address(crowdfund), (totalSupply * 3) / 100);

        console.log("Crowdfund contract deployed at:", address(crowdfund));

        vm.stopBroadcast();
    }
}
