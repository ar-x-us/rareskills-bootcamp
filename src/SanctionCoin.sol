// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Assignment: Token with sanctions. Create a fungible token that allows an admin to ban specified addresses from sending and receiving tokens.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SanctionCoin is ERC20 {
    address private admin;
    mapping(address => bool) banned;

    constructor() ERC20("SC", "SanctionCoin") {
        admin = msg.sender;
    }

    function ban(address addr) public {
        require(msg.sender == admin, "only admin can ban");
        require(addr != admin, "admin cannot be banned");
        require(banned[addr] == false, "user already banned");

        banned[addr] = true;
        // TODO: emit event
    }

    function unban(address addr) public {
        require(msg.sender == admin, "only admin can ban");
        require(addr != admin, "admin cannot be banned");
        require(banned[addr] == true, "user is not banned");

        banned[addr] = false;
        // TODO: emit event
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == admin, "only admin can mint");
        require(banned[to] == false, "receiver is banned");
        _mint(to, amount);
        // TODO: emit event
    }

    function give(address to, uint256 amount) public {
        require(banned[msg.sender] == false, "sender is banned");
        require(banned[to] == false, "receiver is banned");
        require(balanceOf(msg.sender) >= amount);
        transfer(to, amount);
        // TODO: emit event
    }
}
