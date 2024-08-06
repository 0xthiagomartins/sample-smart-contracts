// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeGymToken} from "../src/token/DGYM.sol";
import {Crowdfund} from "../src/token/Crowdfund.sol";
import {MockAuthority} from "./MockAuthority.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdfundTest is Test {
    DeGymToken private token;
    Crowdfund private crowdsale;
    MockAuthority private authority;
    address private owner = address(0x123);
    address private user = address(0x456);
    address private wallet = address(0x789);

    function setUp() public {
        authority = new MockAuthority();
        token = new DeGymToken(1_000_000_000 ether, 10_000_000_000 ether);
        crowdsale = new Crowdfund(address(token), wallet, address(authority));
        authority.setManager(owner, true);

        // Allocate some tokens to the crowdsale contract
        vm.startPrank(owner);
        token.mint(address(crowdsale), 500_000_000 ether); // Allocate half of the cap for the sale
        vm.stopPrank();
    }

    function testSetPhase() public {
        vm.startPrank(owner);
        crowdsale.activatePhase("Pre-seed sale");
        (
            uint256 rate,
            uint256 allocation,
            uint256 sold,
            bool burnable,
            uint256 startTime,
            uint256 endTime,
            bool active
        ) = crowdsale.phases("Pre-seed sale");

        assertEq(rate, 0.3 ether);
        assertEq(allocation, 30_000_000 ether); // 3% of 1,000,000,000 total supply
        assertEq(sold, 0);
        assertEq(burnable, true);
        assertEq(active, true);
        vm.stopPrank();
    }

    function testActivatePhase() public {
        vm.startPrank(owner);
        crowdsale.activatePhase("Private sale");
        (, , , , , , bool active) = crowdsale.phases("Private sale");
        assertEq(active, true);
        vm.stopPrank();
    }

    function testBuyTokensPreSeed() public {
        vm.startPrank(owner);
        crowdsale.activatePhase("Pre-seed sale");
        vm.stopPrank();

        vm.deal(user, 3 ether); // User buys 10 tokens at 0.3 ether each
        vm.startPrank(user);
        crowdsale.buyTokens{value: 3 ether}(user);

        address vestingWallet = crowdsale.vestingWallets(user);
        assertEq(IERC20(address(token)).balanceOf(vestingWallet), 10 ether);
        vm.stopPrank();
    }

    function testBuyTokensPrivateSale() public {
        vm.startPrank(owner);
        crowdsale.activatePhase("Private sale");
        vm.stopPrank();

        vm.deal(user, 39 ether); // User buys 100 tokens at 0.39 ether each (30% above pre-seed price)
        vm.startPrank(user);
        crowdsale.buyTokens{value: 39 ether}(user);

        address vestingWallet = crowdsale.vestingWallets(user);
        assertEq(IERC20(address(token)).balanceOf(vestingWallet), 100 ether);
        vm.stopPrank();
    }

    function testBuyTokensPublicSale() public {
        vm.startPrank(owner);
        crowdsale.activatePhase("Public sale");
        vm.stopPrank();

        vm.deal(user, 169 ether); // User buys 100 tokens at 1.69 ether each (30% above private sale price)
        vm.startPrank(user);
        crowdsale.buyTokens{value: 169 ether}(user);

        assertEq(token.balanceOf(user), 100 ether);
        vm.stopPrank();
    }

    function testBuyTokensExceedsAllocation() public {
        vm.startPrank(owner);
        crowdsale.activatePhase("Pre-seed sale");
        vm.stopPrank();

        vm.deal(user, 100 ether);
        vm.startPrank(user);
        vm.expectRevert("Exceeds phase allocation");
        crowdsale.buyTokens{value: 100 ether}(user);
        vm.stopPrank();
    }

    function testWithdrawTokens() public {
        vm.startPrank(owner);
        crowdsale.withdrawTokens(IERC20(address(token)));

        assertEq(token.balanceOf(wallet), 500_000_000 ether);
        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(owner);
        vm.deal(address(crowdsale), 1 ether);
        crowdsale.withdraw();

        assertEq(wallet.balance, 1 ether);
        vm.stopPrank();
    }
}
