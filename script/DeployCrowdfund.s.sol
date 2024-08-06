// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {Crowdfund} from "../src/token/Crowdfund.sol";

contract DeployCrowdfund is Script {
    function run() external {
        address tokenAddress = vm.envAddress("DEPLOYED_TOKEN_ADDRESS");
        address walletAddress = vm.envAddress("WALLET_ADDRESS");
        address initialAuthority = msg.sender; // Initial authority

        vm.startBroadcast();

        Crowdfund crowdsale = new Crowdfund(
            tokenAddress,
            walletAddress,
            initialAuthority
        );

        console.log("Crowdfund deployed at:", address(crowdsale));

        vm.stopBroadcast();
    }
}
