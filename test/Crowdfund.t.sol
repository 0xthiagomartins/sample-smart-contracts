// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/token/DGYM.sol";
import "../src/token/Crowdfund.sol";
import "./MockAuthority.sol";

contract CrowdfundTest is Test {
    DeGymToken private token;
    Crowdfund private crowdsale;
    MockAuthority private authority;
    address private owner = address(0x123);
    address private user = address(0x456);
    address private wallet = address(0x789);

    function setUp() public {
        authority = new MockAuthority();
        token = new DeGymToken(1000 ether, 2000 ether);
        crowdsale = new Crowdfund(address(token), wallet, address(authority));
        authority.setManager(owner, true);

        // Allocate some tokens to the crowdsale contract
        vm.startPrank(owner);
        token.mint(address(crowdsale), 500 ether);
        vm.stopPrank();
    }

    function testSetPhase() public {
        vm.startPrank(owner);
        crowdsale.setPhase(
            "Phase1",
            1000,
            100 ether,
            block.timestamp + 1,
            block.timestamp + 10,
            true
        );
        (
            uint256 rate,
            uint256 allocation,
            uint256 sold,
            bool burnable,
            uint256 startTime,
            uint256 endTime,
            bool active
        ) = crowdsale.phases("Phase1");

        assertEq(rate, 1000);
        assertEq(allocation, 100 ether);
        assertEq(sold, 0);
        assertEq(burnable, true);
        assertEq(startTime, block.timestamp + 1);
        assertEq(endTime, block.timestamp + 10);
        assertEq(active, false);
        vm.stopPrank();
    }

    function testActivatePhase() public {
        vm.startPrank(owner);
        crowdsale.setPhase(
            "Phase1",
            1000,
            100 ether,
            block.timestamp,
            block.timestamp + 10,
            true
        );
        crowdsale.activatePhase("Phase1");

        (, , , , , , bool active) = crowdsale.phases("Phase1");
        assertEq(active, true);
        vm.stopPrank();
    }

    function testBuyTokens() public {
        vm.startPrank(owner);
        crowdsale.setPhase(
            "Phase1",
            1000,
            100 ether,
            block.timestamp,
            block.timestamp + 10,
            true
        );
        crowdsale.activatePhase("Phase1");
        vm.stopPrank();

        vm.deal(user, 1 ether);
        vm.startPrank(user);
        crowdsale.buyTokens{value: 1 ether}(user);

        assertEq(token.balanceOf(user), 1000 ether);
        vm.stopPrank();
    }

    function testBuyTokensExceedsAllocation() public {
        vm.startPrank(owner);
        crowdsale.setPhase(
            "Phase1",
            1000,
            100 ether,
            block.timestamp,
            block.timestamp + 10,
            true
        );
        crowdsale.activatePhase("Phase1");
        vm.stopPrank();

        vm.deal(user, 2 ether);
        vm.startPrank(user);
        vm.expectRevert("Exceeds phase allocation");
        crowdsale.buyTokens{value: 2 ether}(user);
        vm.stopPrank();
    }

    function testCreateVestingWallet() public {
        vm.startPrank(owner);
        crowdsale.createVestingWallet(
            user,
            uint64(block.timestamp),
            uint64(1 weeks)
        );

        address vestingWallet = crowdsale.vestingWallets(user);
        assertTrue(vestingWallet != address(0));
        vm.stopPrank();
    }

    function testTransferToVestingWallet() public {
        vm.startPrank(owner);
        crowdsale.createVestingWallet(
            user,
            uint64(block.timestamp),
            uint64(1 weeks)
        );
        address vestingWallet = crowdsale.vestingWallets(user);

        crowdsale.transferToVestingWallet(user, 100 ether);
        assertEq(token.balanceOf(vestingWallet), 100 ether);
        vm.stopPrank();
    }

    function testWithdrawTokens() public {
        vm.startPrank(owner);
        crowdsale.withdrawTokens(IERC20(address(token)));

        assertEq(token.balanceOf(wallet), 500 ether);
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
