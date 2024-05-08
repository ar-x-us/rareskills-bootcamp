// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/// @title ERC20 Sanction Coin
/// @dev This fungible token allows the admin (the person that deploys the coin) to
/// sanction/unsanction specific account addresses from sending or receiving tokens.
contract SanctionCoin is ERC20 {
    address private admin;
    mapping(address => bool) sanctioned;

    event AccountSanctioned(address account);
    event AccountUnsanctioned(address account);

    /// @dev Assigns deployer of the contract as the admin of the contract.
    constructor() ERC20("SC", "SanctionCoin") {
        admin = msg.sender;
    }

    /// @notice Mint coins to account.
    /// @param to Account to receive the newly minted coins.
    /// @param amount Amount of coins to mint.
    /// @dev Accounts that are sanctioned are not able to receive coins.
    /// Only admin account can mint coins.
    function mint(address to, uint256 amount) public {
        require(msg.sender == admin, "Only admin can mint");
        require(sanctioned[to] == false, "Receiver account is sanctioned");
        super._mint(to, amount);
    }

    /// @notice Transfer coins to account.
    /// @param to Account to receive coins.
    /// @param amount Amount of coins to transfer.
    /// @return success Returns true if transfer is successful.
    /// @dev Both sender and receiving accounts must not be sanctioned.
    function transfer(address to, uint256 amount) public override returns (bool success) {
        require(sanctioned[msg.sender] == false, "Sender account is sanctioned");
        require(sanctioned[to] == false, "Receiver account is sanctioned");
        return super.transfer(to, amount);
    }

    /// @notice Transfer coins from one account to another.
    /// @param from Account to send coins.
    /// @param to Account to receive coins.
    /// @param amount Amount of coins to transfer.
    /// @return success Returns true if transfer is successful.
    /// @dev Both sender and receiving accounts must not be sanctioned.
    function transferFrom(address from, address to, uint256 amount) public override returns (bool success) {
        require(sanctioned[from] == false, "Sender account is sanctioned");
        require(sanctioned[to] == false, "Receiver account is sanctioned");
        return super.transferFrom(from, to, amount);
    }

    /// @notice Sanction an account.
    /// @param account Account to be sanctioned.
    /// @dev Account to be sanctioned cannot be sanctioned again.
    /// Only admin can sanction an account.
    function sanction(address account) public {
        require(msg.sender == admin, "Only admin can sanction accounts");
        require(account != admin, "Admin cannot be sanctioned");
        require(sanctioned[account] == false, "Account already sanctioned");
        sanctioned[account] = true;
        emit AccountSanctioned(account);
    }

    /// @notice Unsanction an account.
    /// @param account Account to be unsanctioned.
    /// @dev Account to be unsanctioned cannot be unsanctioned again.
    /// Only admin can sanction an account.
    function unsanction(address account) public {
        require(msg.sender == admin, "Only admin can sanction accounts");
        require(account != admin, "Admin cannot be sanctioned");
        require(sanctioned[account] == true, "Account is not sanctioned");
        sanctioned[account] = false;
        emit AccountUnsanctioned(account);
    }

    /// @notice Check if account is sanctioned.
    /// @param account Account to check.
    /// @return Returns true if account is sanctioned, otherwise false.
    /// @dev Used ot check if an account is sanctioned.
    function isSanctioned(address account) public view returns (bool) {
        return sanctioned[account];
    }
}
