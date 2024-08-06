// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/token/Crowdfund.sol";
import "../src/token/DGYM.sol";

contract DeployCrowdfund is Script {
    function run() external {
        vm.startBroadcast();

        address tokenAddress = 0xYourDeployedTokenAddress; // Replace with the actual deployed token address
        address walletAddress = 0xYourWalletAddress; // Replace with your wallet address
        address initialAuthority = msg.sender; // Initial authority

        Crowdfund crowdsale = new Crowdfund(tokenAddress, walletAddress, initialAuthority);

        console.log("Crowdfund deployed at:", address(crowdsale));

        vm.stopBroadcast();
    }
}
