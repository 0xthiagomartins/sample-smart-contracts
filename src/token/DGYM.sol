// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";

contract DeGymToken is
    ERC20,
    ERC20Burnable,
    AccessManaged,
    ERC20Permit,
    ERC20Votes
{
    /**
     * The total supply of the token is set to 1_000_000_000. This establishes the upper limit
     * of tokens that will ever be in circulation on Ethereum network.
     */
    uint256 private _totalSupply = 1_000_000_000 * (10 ** 18);

    /**
     *
     * Allocating 20% to the "Ecosystem Development Fund" is crucial for funding ongoing
     * development, research, and innovation within the token's ecosystem.
     */
    uint256 private _ecosystemDevelopment = (_totalSupply * 20) / 100;

    /**
     * Allocating 15% of the total supply to the "Team Growth Fund" supports the team's
     * long-term commitment and incentivizes their continuous contribution to the project's
     * success.
     */
    uint256 private _teamGrowth = (_totalSupply * 15) / 100;

    /**
     * Allocating 12.5% for the "Community Engagement Fund" fosters a strong, interactive
     * community. This fund can be used for community rewards or other engagement
     * initiatives.
     */
    uint256 private _communityEngagement = (_totalSupply * 125) / 1000;

    /**
     * Allocating 12.5% for the "Marketing and Promotion Fund" ensures ample resources are available
     * for advertising, partnerships, and other promotional activities to increase the token's
     * visibility and adoption.
     */
    uint256 private _marketingPromotion = (_totalSupply * 125) / 1000;

    /**
     * The remaining 52% of the tokens, referred to as _remainingTokens, are allocated to the
     * Deployer for purposes such as public sale and ensuring liquidity post-listing. This large
     * allocation allows for significant market penetration and liquidity provision.
     */
    uint256 private _remainingTokens =
        _totalSupply -
            (_teamGrowth +
                _communityEngagement +
                _marketingPromotion +
                _ecosystemDevelopment);

    uint256 private _cap = 10_000_000_000 * (10 ** 18);

    event CapUpdated(uint256 newCap);

    constructor()
        ERC20("DeGym Token", "DGYM")
        AccessManaged(msg.sender)
        ERC20Permit("DeGym Token")
        ERC20Votes()
    {
        address ecosystemDevelopmentVesting = address(
            new VestingWallet(
                0xA043BC356A11f548f77F716e8d3c31b1e8beDf7a,
                uint64(block.timestamp),
                365 days
            )
        );

        address teamGrowthVesting = address(
            new VestingWallet(
                0xa81AA52EA19ef26739B0762C03381f9a84c8b05d,
                uint64(block.timestamp),
                365 days
            )
        );

        address communityEngagementVesting = address(
            new VestingWallet(
                0x49d125cA46997e3C90ebB0cc9940e033487F8FA4,
                uint64(block.timestamp),
                365 days
            )
        );

        address marketingPromotionVesting = address(
            new VestingWallet(
                0x8126A70a57B44d32e6eB9F41c8DF4A2A47Ff4Be7,
                uint64(block.timestamp),
                365 days
            )
        );

        _mint(ecosystemDevelopmentVesting, _ecosystemDevelopment);
        _mint(teamGrowthVesting, _teamGrowth);
        _mint(communityEngagementVesting, _communityEngagement);
        _mint(marketingPromotionVesting, _marketingPromotion);
        _mint(msg.sender, _remainingTokens);
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function setCap(uint256 newCap) public restricted {
        require(
            newCap >= totalSupply(),
            "New cap must be greater than or equal to total supply"
        );
        _cap = newCap * (10 ** decimals());
        emit CapUpdated(_cap);
    }

    function mint(address to, uint256 amount) public restricted {
        _mintCapped(to, amount);
    }

    function _mintCapped(address account, uint256 amount) internal {
        require(totalSupply() + amount <= _cap, "ERC20Capped: cap exceeded");
        _mint(account, amount);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    // Override the nonces function
    function nonces(
        address owner
    ) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }

    function _mint(address account, uint256 amount) internal override(ERC20) {
        super._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal override(ERC20) {
        super._burn(account, amount);
    }
}

interface IDGYM is IERC20 {
    event CapUpdated(uint256 newCap);

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function cap() external view returns (uint256);

    function setCap(uint256 newCap) external;

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
