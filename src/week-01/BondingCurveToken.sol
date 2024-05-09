// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Implement a simple linear bonding curve: y = x
contract BondingCurveToken is ERC20 {
    // work with smaller numbers first (and build it out from here)
    // 1000 units = 1 BCT (4 decimal places)
    // 1 unit = 0.001 BCT
    uint8 public decimal = 2;
    uint256 public scale = 10 ** decimal;
    // reserve must be initialized to non-zero value
    uint256 public reserveBalance = 10 * scale; // 1 ETH
    address public admin;

    // 1 BCT = 1 eth
    // 2 BCT = 2 eth
    // 3 BCT = 3 eth ... etc

    // bonding curve is linear, reserve ratio is 50% = 1/2

    constructor() ERC20("BCT", "BondingCurveToken") {
        // supply must be initialized to non-zero value
        // admin receives a single token to seed the bonding curve, but can never sell the token
        admin = msg.sender;
        super._mint(msg.sender, 1 * scale);
        // owner gets 1 BCT = 1000 uints
    }

    function buy() public payable {
        // calculate tokens one can receive
        // mint tokens received in fractions

        // TODO: use cast to exercise transactions
        uint256 tokensToMint = calculateTokensToMint(msg.value);

        require(tokensToMint > 0, "Not enough to mint a single unit of the token");

        reserveBalance += msg.value; // increase the reserve balance

        super._mint(msg.sender, tokensToMint);
    }

    function sell() public payable {
        // calculate payment one can redeem
        // burn tokens received

        // return ETH to sender from the reserve (got to make sure there is enough money in the contract to return to the user, probably use call() or send(), to return the money, but need to check for re-entrancy)
    }

    function mint(uint256 amount) private {
        super._mint(address(this), amount); // mint amount * 10^18
    }

    // TODO: consideration for slippage

    /// @dev This is used to calculate how many tokens once can receive for ETH sent
    function calculateTokensToMint(uint256 paymentInReserveToken) public view returns (uint256) {
        uint256 supply = totalSupply();
        // but balanceInWei may be zero here, which is a problem
        // how do we deal with balance in with of zero
        // since reserveRatio is 1/2, we use use sqrt
        return supply * (sqrt(1 + paymentInReserveToken / reserveBalance) - 1);
    }

    /// @dev This is used to calculate how much ETH is received for tokens sold and returned to contract
    function calculatePaymentForTokens() public view {
        //
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

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
