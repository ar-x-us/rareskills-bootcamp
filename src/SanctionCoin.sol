// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Assignment: Token with sanctions. Create a fungible token that allows an admin to ban specified addresses from sending and receiving tokens.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SanctionCoin is ERC20 {
    address private admin;
    mapping(address => bool) banned;

    event AccountBanned(address account);
    event AccountUnbanned(address account);

    constructor() ERC20("SC", "SanctionCoin") {
        admin = msg.sender;
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == admin, "Only admin can mint");
        require(banned[to] == false, "Receiver is banned");
        _mint(to, amount);
    }

    function give(address to, uint256 amount) public {
        require(banned[msg.sender] == false, "Sender account is banned");
        require(banned[to] == false, "Receiver account is banned");
        require(balanceOf(msg.sender) >= amount);
        transfer(to, amount);
    }

    function ban(address account) public {
        require(msg.sender == admin, "Only admin can ban accounts");
        require(account != admin, "Admin cannot be banned");
        require(banned[account] == false, "Account already banned");
        banned[account] = true;
        emit AccountBanned(account);
    }

    function unban(address account) public {
        require(msg.sender == admin, "Only admin can ban accounts");
        require(account != admin, "Admin cannot be banned");
        require(banned[account] == true, "Account is not banned");
        banned[account] = false;
        emit AccountUnbanned(account);
    }
}
