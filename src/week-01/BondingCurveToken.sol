// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Implement linear bonding curve
contract BondingCurveToken is ERC20 {
    mapping(address => bool) sanctioned;

    constructor() ERC20("BCT", "BondingCurveToken") {}

    function mint(uint256 amount) public {
        super._mint(address(this), amount);
    }

    function calculateCost(uint256 amount) public view returns (uint256, uint256, uint256) {
        uint256 supply = super.totalSupply();
        uint256 value = ((supply + amount) ** 2 - (supply ** 2)) * 1 ether / 2;
        return (supply + amount, supply, value);
    }

    function calculateValue(uint256 amount) public view returns (uint256, uint256, uint256) {
        uint256 supply = super.totalSupply();
        require(amount < supply, "amount provided goes below current supply");
        uint256 value = ((supply ** 2) - (supply - amount) ** 2) * 1 ether / 2;
        return (supply, supply - amount, value);
    }
}
