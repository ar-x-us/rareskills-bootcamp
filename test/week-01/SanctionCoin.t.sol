// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SanctionCoin} from "src/week-01/SanctionCoin.sol";

contract SanctionCoinTest is Test {
    SanctionCoin public coin;
    address admin = makeAddr("admin");
    address account = makeAddr("account");
    address sender = makeAddr("sender");
    address receiver = makeAddr("receiver");

    function setUp() public {
        vm.prank(admin);
        coin = new SanctionCoin();
    }

    function test_NormalMinting() public {
        vm.prank(admin);
        coin.mint(account, 1000);
        assertEq(coin.balanceOf(account), 1000);
    }

    function test_UnauthorizedMinting() public {
        vm.expectRevert("Only admin can mint coins.");
        vm.prank(account);
        coin.mint(account, 1000);
    }

    function test_RevertOnSanctionedMinting() public {
        vm.prank(admin);
        coin.sanction(account);
        vm.expectRevert("Receiver account is sanctioned.");
        vm.prank(admin);
        coin.mint(account, 1000);
    }

    function test_Transfer() public {
        vm.prank(admin);
        coin.mint(sender, 1000);
        vm.prank(sender);
        assertEq(coin.transfer(receiver, 100), true);
        assertEq(coin.balanceOf(sender), 900);
        assertEq(coin.balanceOf(receiver), 100);
    }

    function test_TransferSanctionedSender() public {
        vm.prank(admin);
        coin.mint(sender, 1000);
        assertEq(coin.balanceOf(sender), 1000);
        vm.prank(admin);
        coin.sanction(sender);
        vm.expectRevert("Sender account is sanctioned.");
        vm.prank(sender);
        coin.transfer(receiver, 100);
    }

    function test_TransferSanctionedReceiver() public {
        vm.prank(admin);
        coin.mint(sender, 1000);
        assertEq(coin.balanceOf(sender), 1000);
        vm.prank(admin);
        coin.sanction(receiver);
        vm.expectRevert("Receiver account is sanctioned.");
        vm.prank(sender);
        coin.transfer(receiver, 100);
    }

    function test_TransferFrom() public {
        vm.prank(admin);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.approve(account, 1000);
        vm.prank(account);
        assertEq(coin.transferFrom(sender, receiver, 100), true);
        assertEq(coin.balanceOf(sender), 900);
        assertEq(coin.balanceOf(receiver), 100);
    }

    function test_TransferFromSanctionedSender() public {
        vm.prank(admin);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.approve(account, 1000);
        vm.prank(admin);
        coin.sanction(sender);
        vm.expectRevert("Sender account is sanctioned.");
        vm.prank(account);
        coin.transferFrom(sender, receiver, 100);
    }

    function test_TransferFromSanctionedReceiver() public {
        vm.prank(admin);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.approve(account, 1000);
        vm.prank(admin);
        coin.sanction(receiver);
        vm.expectRevert("Receiver account is sanctioned.");
        vm.prank(account);
        coin.transferFrom(sender, receiver, 100);
    }

    function test_Sanctioning() public {
        vm.prank(admin);
        coin.sanction(sender);
        assertEq(coin.isSanctioned(sender), true);
    }

    function test_DoubleSanctioning() public {
        vm.prank(admin);
        coin.sanction(sender);
        vm.expectRevert("Sanctioned account cannot be sanctioned.");
        vm.prank(admin);
        coin.sanction(sender);
    }

    function test_Unsanctioning() public {
        vm.prank(admin);
        coin.sanction(account);
        assertEq(coin.isSanctioned(account), true);
        vm.prank(admin);
        coin.unsanction(account);
        assertEq(coin.isSanctioned(account), false);
    }

    function test_DoubleUnanctioning() public {
        vm.prank(admin);
        coin.sanction(sender);
        vm.prank(admin);
        coin.unsanction(sender);
        vm.expectRevert("Unsanctioned account cannot be unsanctioned.");
        vm.prank(admin);
        coin.unsanction(sender);
    }

    function test_UnauthorizedSanctioning() public {
        vm.expectRevert("Only admin can sanction accounts.");
        vm.prank(account);
        coin.sanction(sender);
    }

    function test_SanctioningAdmin() public {
        vm.expectRevert("Admin cannot be sanctioned.");
        vm.prank(admin);
        coin.sanction(admin);
    }

    function test_IsSantioned() public {
        assertEq(coin.isSanctioned(account), false);
        vm.prank(admin);
        coin.sanction(account);
        assertEq(coin.isSanctioned(account), true);
    }
}
