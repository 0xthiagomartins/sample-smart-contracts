// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeGymToken} from "../src/token/DGYM.sol";
import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DGYMTest is Test {
    DeGymToken private token;
    address private owner = address(0xE6339c6f56d44719b6ae1264ea9B4f5eD1710bbE);
    address private ecosystemDevelopmentAddress =
        0x609D40C1d5750ff03a3CafF30152AD03243c02cB;
    address private teamGrowthAddress =
        0xaDcB2f54F652BFD7Ac1d7D7b12213b4519F0265D;
    address private communityEngagementAddress =
        0x139780E08d3DAF2f72D10ccC635593cDB301B4bC;
    address private marketingPromotionAddress =
        0x6BC8906aD6369bD5cfe7B4f2f181f0759A3D53b6;

    function setUp() public {
        vm.startPrank(owner);
        token = new DeGymToken();
        vm.stopPrank();
    }

    function testInitialization() public {
        assertEq(token.name(), "DeGym Token");
        assertEq(token.symbol(), "DGYM");
        assertEq(token.totalSupply(), 1_000_000_000 * 10 ** 18);
        assertEq(token.cap(), 10_000_000_000 * 10 ** 18);
    }

    function testMinting() public {
        uint256 amount = 1_000_000 * 10 ** 18;
        vm.startPrank(owner);
        token.mint(owner, amount);
        assertEq(token.balanceOf(owner), amount + token.balanceOf(owner));
        vm.stopPrank();
    }

    function testBurning() public {
        uint256 amount = 1_000_000 * 10 ** 18;
        vm.startPrank(owner);
        token.mint(owner, amount);
        token.burn(amount);
        assertEq(token.balanceOf(owner), 0);
        vm.stopPrank();
    }

    function testCapExceeded() public {
        uint256 amount = 10_000_000_000 * 10 ** 18;
        vm.startPrank(owner);
        vm.expectRevert("ERC20Capped: cap exceeded");
        token.mint(owner, amount);
        vm.stopPrank();
    }

    function testSetCap() public {
        uint256 newCap = 15_000_000_000 * 10 ** 18;
        vm.startPrank(owner);
        token.setCap(newCap);
        assertEq(token.cap(), newCap);
        vm.stopPrank();
    }

    function testVestingWallets() public {
        address ecosystemDevelopmentVesting = address(
            new VestingWallet(
                ecosystemDevelopmentAddress,
                uint64(block.timestamp + 30 days),
                uint64(11 * 30 days)
            )
        );

        address teamGrowthVesting = address(
            new VestingWallet(
                teamGrowthAddress,
                uint64(block.timestamp + 30 days),
                uint64(11 * 30 days)
            )
        );

        address communityEngagementVesting = address(
            new VestingWallet(
                communityEngagementAddress,
                uint64(block.timestamp + 14 days),
                uint64(11 * 30 days)
            )
        );

        address marketingPromotionVesting = address(
            new VestingWallet(
                marketingPromotionAddress,
                uint64(block.timestamp + 30 days),
                uint64(11 * 30 days)
            )
        );

        uint256 ecosystemDevelopmentBalance = token.balanceOf(
            ecosystemDevelopmentVesting
        );
        uint256 teamGrowthBalance = token.balanceOf(teamGrowthVesting);
        uint256 communityEngagementBalance = token.balanceOf(
            communityEngagementVesting
        );
        uint256 marketingPromotionBalance = token.balanceOf(
            marketingPromotionVesting
        );

        assertEq(ecosystemDevelopmentBalance, (token.totalSupply() * 20) / 100);
        assertEq(teamGrowthBalance, (token.totalSupply() * 15) / 100);
        assertEq(
            communityEngagementBalance,
            (token.totalSupply() * 125) / 1000
        );
        assertEq(marketingPromotionBalance, (token.totalSupply() * 125) / 1000);
    }
}
