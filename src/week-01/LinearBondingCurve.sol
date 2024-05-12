// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LinearBondingCurve is ERC20 {
    address public owner;
    uint256 public slopeNumerator;
    uint256 public slopeDenominator;
    uint256 public constant BASE_PRICE_IN_WEI = 1;

    event Purchase(address buyer, uint256 amountOfTokensPurchased, uint256 totalCostInWei);
    event Sold(address seller, uint256 amountOfTokensSold, uint256 totalValueInWei);

    constructor(uint256 _slopeNumerator, uint256 _slopeDenominator) ERC20("LinearBondingCurve", "LBC") {
        owner = msg.sender;
        slopeNumerator = _slopeNumerator;
        slopeDenominator = _slopeDenominator;
    }

    function buy(uint256 _amount) external payable {
        (uint256 totalCost, uint256 amountToMint) = calculatePurchase(_amount);
        require(msg.value >= totalCost, "Insufficient ether sent");

        // we must calculate the amount to mint because of integer math
        require(amountToMint > 0, "Nothing to mint");
        _mint(msg.sender, _amount);

        // Refund excess ether
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        emit Purchase(msg.sender, _amount, totalCost);
    }

    /// @dev _amount is the smallet unit of a token 1/18th of a token
    function sell(uint256 _amount) external {
        require(balanceOf(msg.sender) >= _amount, "Insufficient tokens");

        uint256 amountInWei = calculateSale(_amount);

        _burn(msg.sender, _amount);

        // Transfer ether to the seller
        payable(msg.sender).transfer(amountInWei);

        emit Sold(msg.sender, _amount, amountInWei);
    }

    function calculatePurchase(uint256 _amount) public view returns (uint256 totalCost, uint256 amountToMint) {
        uint256 currentPrice = calculatePrice(totalSupply());
        uint256 futurePrice = calculatePrice(totalSupply() + _amount);
        // area under the line
        totalCost = (_amount * (currentPrice + futurePrice)) / 2;
        // calculate amountToMint because of integer math
        amountToMint = (totalCost * 2) / (currentPrice + futurePrice);
        return (totalCost, amountToMint);
    }

    function calculateSale(uint256 _amount) public view returns (uint256 totalSale) {
        require(_amount <= totalSupply(), "Not enough token units to be sold");
        uint256 currentPrice = calculatePrice(totalSupply());
        uint256 futurePrice = calculatePrice(totalSupply() - _amount);
        // area under the line
        totalSale = (_amount * (currentPrice + futurePrice)) / 2;
        return totalSale;
    }

    function calculatePrice(uint256 _amount) public view returns (uint256) {
        return ((_amount * slopeNumerator) / (slopeDenominator) + 1) * BASE_PRICE_IN_WEI;
    }
}
