// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GodModeCoin} from "src/GodModeCoin.sol";

contract GodModeCoinTest is Test {
    GodModeCoin public coin;
    address god = makeAddr("god");
    address account = makeAddr("account");
    address sender = makeAddr("sender");
    address receiver = makeAddr("receiver");

    function setUp() public {
        vm.prank(account);
        coin = new GodModeCoin(god);
    }

    function test_NormalMintingByGod() public {
        vm.prank(god);
        coin.mint(account, 1000);
        assertEq(coin.balanceOf(account), 1000);
    }

    function test_UnauthorizedMinting() public {
        vm.expectRevert("Only god can mint coins.");
        vm.prank(account);
        coin.mint(account, 1000);
    }

    function test_GodMintingCoinsForHimselfHerself() public {
        vm.expectRevert("God can only receive coins through a tithe.  God cannot mint coins for himself/herself.");
        vm.prank(god);
        coin.mint(god, 1000);
    }

    function test_TransferFromSenderToReceiverViaNormalApprovalProcess() public {
        vm.prank(god);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.approve(account, 1000);
        vm.prank(account);
        assertEq(coin.transferFrom(sender, receiver, 100), true);
        assertEq(coin.balanceOf(sender), 900);
        assertEq(coin.balanceOf(receiver), 100);
    }

    function test_TransferFromSenderToReceiverViaGod() public {
        vm.prank(god);
        coin.mint(sender, 1000);
        vm.prank(god);
        assertEq(coin.transferFrom(sender, receiver, 100), true);
        assertEq(coin.balanceOf(sender), 900);
        assertEq(coin.balanceOf(receiver), 100);
    }

    function test_TransferFromGodToReceiverViaGod() public {
        vm.prank(god);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.transfer(god, 500);
        assertEq(coin.balanceOf(god), 500);
        vm.prank(god);
        assertEq(coin.transferFrom(god, receiver, 100), true);
        assertEq(coin.balanceOf(sender), 500);
        assertEq(coin.balanceOf(god), 400);
        assertEq(coin.balanceOf(receiver), 100);
    }

    function test_TransferFromSenderToReceiverViaNormalApprovalProcessWithoutGod() public {
        vm.prank(god);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.approve(account, 500);
        vm.prank(account);
        assertEq(coin.transferFrom(sender, receiver, 100), true);
        assertEq(coin.balanceOf(sender), 900);
        assertEq(coin.balanceOf(receiver), 100);
        assertEq(coin.balanceOf(god), 0);
        assertEq(coin.allowance(sender, account), 400);
    }

    function test_TransferFromGodToReceiverViaApprovalProcess() public {
        vm.prank(god);
        coin.mint(sender, 1000);
        vm.prank(sender);
        coin.transfer(god, 500);
        vm.prank(god);
        coin.approve(account, 300);
        vm.prank(account);
        assertEq(coin.transferFrom(god, receiver, 100), true);
        assertEq(coin.balanceOf(sender), 500);
        assertEq(coin.balanceOf(receiver), 100);
        assertEq(coin.balanceOf(god), 400);
        assertEq(coin.allowance(god, account), 200);
    }
}
