// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {IDGYM} from "./DGYM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdfund is AccessManaged {
    using SafeERC20 for IERC20;

    IDGYM public token;
    address public wallet;
    string[] public phaseNames;

    struct Phase {
        uint256 rate;
        uint256 allocation;
        uint256 sold;
        bool burnable;
        uint256 startTime;
        uint256 endTime;
        bool active;
    }

    mapping(string => Phase) public phases;
    mapping(address => address) public vestingWallets;

    event TokensPurchased(
        address indexed purchaser,
        uint256 value,
        uint256 amount
    );
    event PhaseEnded(string phaseName, uint256 unsoldTokensBurned);

    constructor(
        address tokenAddress,
        address walletAddress,
        address initialAuthority
    ) AccessManaged(initialAuthority) {
        token = IDGYM(tokenAddress);
        wallet = walletAddress;
    }

    receive() external payable {
        buyTokens(msg.sender);
    }

    function setPhase(
        string memory phaseName,
        uint256 rate,
        uint256 allocation,
        uint256 startTime,
        uint256 endTime,
        bool burnable
    ) external restricted {
        require(endTime > startTime, "End time must be after start time");
        require(
            startTime > block.timestamp,
            "Start time must be in the future"
        );

        phases[phaseName] = Phase({
            rate: rate,
            allocation: allocation,
            sold: 0,
            burnable: burnable,
            startTime: startTime,
            endTime: endTime,
            active: false
        });
        phaseNames.push(phaseName);
    }

    function activatePhase(string memory phaseName) external restricted {
        Phase storage phase = phases[phaseName];
        require(
            phase.startTime <= block.timestamp,
            "Phase has not started yet"
        );
        require(phase.endTime > block.timestamp, "Phase has ended");
        require(!phase.active, "Phase is already active");

        phase.active = true;
    }

    function deactivatePhase(string memory phaseName) external restricted {
        Phase storage phase = phases[phaseName];
        require(phase.active, "Phase is not active");

        phase.active = false;

        if (phase.burnable) {
            uint256 unsoldTokens = phase.allocation - phase.sold;
            if (unsoldTokens > 0) {
                token.burn(unsoldTokens);
                emit PhaseEnded(phaseName, unsoldTokens);
            }
        }
    }

    function buyTokens(address beneficiary) public payable {
        uint256 weiAmount = msg.value;
        uint256 tokens;

        require(beneficiary != address(0), "Beneficiary address cannot be 0");
        require(weiAmount != 0, "Wei amount cannot be 0");

        string memory activePhaseName = getActivePhase();
        require(bytes(activePhaseName).length > 0, "No active sale phase");

        Phase storage phase = phases[activePhaseName];
        tokens = weiAmount * phase.rate;
        require(
            phase.sold + tokens <= phase.allocation,
            "Exceeds phase allocation"
        );

        phase.sold += tokens;

        IERC20(address(token)).safeTransfer(beneficiary, tokens);
        emit TokensPurchased(beneficiary, weiAmount, tokens);

        payable(wallet).transfer(weiAmount);
    }

    function getActivePhase() public view returns (string memory) {
        for (uint i = 0; i < phaseNames.length; i++) {
            Phase storage phase = phases[phaseNames[i]];
            if (phase.active) {
                return phaseNames[i];
            }
        }
        return "";
    }

    function createVestingWallet(
        address beneficiary,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) external restricted {
        require(
            vestingWallets[beneficiary] == address(0),
            "Vesting wallet already exists for beneficiary"
        );
        VestingWallet vestingWallet = new VestingWallet(
            beneficiary,
            startTimestamp,
            durationSeconds
        );
        vestingWallets[beneficiary] = address(vestingWallet);
    }

    function transferToVestingWallet(
        address beneficiary,
        uint256 amount
    ) external restricted {
        require(
            vestingWallets[beneficiary] != address(0),
            "Vesting wallet does not exist for beneficiary"
        );
        IERC20(address(token)).safeTransfer(
            vestingWallets[beneficiary],
            amount
        );
    }

    function withdrawTokens(IERC20 tokenAddress) external restricted {
        uint256 balance = tokenAddress.balanceOf(address(this));
        tokenAddress.safeTransfer(wallet, balance);
    }

    function withdraw() external restricted {
        payable(wallet).transfer(address(this).balance);
    }
}
