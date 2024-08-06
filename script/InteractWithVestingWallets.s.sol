// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";
import {DeGymToken} from "../src/token/DGYM.sol";

contract InteractWithVestingWallets is Script {
    function run() external {
        address tokenAddress = vm.envAddress("DEPLOYED_TOKEN_ADDRESS");

        vm.startBroadcast();

        DeGymToken token = DeGymToken(tokenAddress);

        // Interact with vesting wallets if needed
        // Example: address ecosystemDevelopmentVesting = vm.envAddress("ECOSYSTEM_DEVELOPMENT_VESTING");
        // uint256 vestedBalance = token.balanceOf(ecosystemDevelopmentVesting);
        // console.log("Vested balance of Ecosystem Development:", vestedBalance);

        vm.stopBroadcast();
    }
}
