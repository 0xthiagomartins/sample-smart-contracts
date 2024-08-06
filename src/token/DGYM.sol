// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeGymToken is
    ERC20,
    ERC20Burnable,
    AccessManaged,
    ERC20Permit,
    ERC20Votes
{
    uint256 private _cap;

    event CapUpdated(uint256 newCap);

    constructor(
        uint256 initialSupply,
        uint256 initialCap
    )
        ERC20("DeGymToken", "DGYM")
        AccessManaged(msg.sender)
        ERC20Permit("DeGymToken")
        ERC20Votes()
    {
        require(initialCap > 0, "ERC20Capped: cap is 0");
        _cap = initialCap * (10 ** decimals());
        _mint(msg.sender, initialSupply * 10 ** decimals());
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
