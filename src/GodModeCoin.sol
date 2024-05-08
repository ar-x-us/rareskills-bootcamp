// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title ERC20 God Mode Coin
/// @dev This fungible token allows a single designated account (a.k.a. "god") to
/// transfer tokens an anyone's behalf.
contract GodModeCoin is ERC20 {
    address god;

    /// @dev Assigns deployer of the contract as the admin of the contract.
    constructor(address theOneAndOnlyGod) ERC20("GMC", "GodModeCoin") {
        god = theOneAndOnlyGod;
    }

    /// @notice Mint coins to account.
    /// @param to Account to receive the newly minted coins.
    /// @param amount Amount of coins to mint.
    /// @dev Only "god" can mint coins, but annot mint coins for himself/herself.
    function mint(address to, uint256 amount) public {
        require(msg.sender == god, "Only god can mint coins.");
        require(to != god, "God can only receive coins through a tithe.  God cannot mint coins for himself/herself.");
        super._mint(to, amount);
    }

    /// @notice Transfer coins from one account to another.
    /// @param from Account to send coins.
    /// @param to Account to receive coins.
    /// @param amount Amount of coins to transfer.
    /// @return success Returns true if transfer is successful.
    /// @dev If msg.sender is "god", then he/she will be automatically be approved to send coins on the sender's behalf.
    function transferFrom(address from, address to, uint256 amount) public override returns (bool success) {
        if (msg.sender == god) {
            super._approve(from, msg.sender, amount);
        }
        return super.transferFrom(from, to, amount);
    }
}
