// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {TimeVault} from "../src/TimeVault.sol";
import {DeployTimeVault} from "../script/DeployTimeVault.s.sol";

/**
 * contract TimeVaultTest is Test {
 *     error TimeVault__MustDepositMoreThanZero();
 *     error TimeVault__InsufficientBalance();
 *     error TimeVault__FundsLocked();
 *     error TimeVault__TransferFailed();
 *
 *     TimeVault public timeVault;
 *     address public USER = makeAddr("user");
 *     address public USER2 = makeAddr("user2");
 *     uint256 public constant DEPOSIT_AMOUNT = 2 ether;
 *     uint256 public constant LOCK_DURATION = 2000;
 *     uint256 public constant WITHDRAW_AMOUNT = 1 ether;
 *     Food public food;
 *
 *     event Deposited(address indexed user, uint256 amount, uint256 lockDuration);
 *     event WithDrawn(address indexed user, uint256 amount);
 *
 *     function setUp() public {
 *         DeployTimeVault deployTimeVault = new DeployTimeVault();
 *         timeVault = deployTimeVault.run();
 *         food = new Food();
 *     }
 *
 *     function testUsersCanDepositFunds() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *     }
 *
 *     function testUsersCanWithDrawFunds() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *         vm.warp(block.timestamp + LOCK_DURATION + 200);
 *         bytes memory callData = abi.encodeWithSignature("withDrawEth(uint256)", DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         address(timeVault).call(callData);
 *         assertEq(timeVault.getDepositedAmount(USER, address(0)), 0);
 *     }
 *
 *     function testreceiveFunctionActCorrectly() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         (bool success,) = address(timeVault).call{value: DEPOSIT_AMOUNT}("");
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *     }
 *
 *     function testGetDepositedAmount() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         assert(timeVault.getDepositedAmount(USER, address(0)) == DEPOSIT_AMOUNT);
 *     }
 *
 *     function testGetLockedDuration() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         assert(timeVault.getLockDuration(USER, address(0)) == block.timestamp + LOCK_DURATION);
 *     }
 *
 *     function testDefaultLockedDurationIsCorrect() public view {
 *         assertEq(timeVault.getDefaultLockedDuration(), 1000);
 *     }
 *
 *     function testDepositingZeroEthReverts() public {
 *         vm.startPrank(USER);
 *         vm.expectRevert(TimeVault__MustDepositMoreThanZero.selector);
 *         timeVault.depositEth{value: 0}(LOCK_DURATION);
 *         vm.stopPrank();
 *     }
 *
 *     function testCanDepositEthAndEmitEvent() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.startPrank(USER);
 *         vm.expectEmit(true, false, false, false);
 *         emit Deposited(USER, DEPOSIT_AMOUNT, LOCK_DURATION);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         vm.stopPrank();
 *     }
 *
 *     function testCanWithDrawAndEmitEvent() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *         vm.warp(block.timestamp + LOCK_DURATION + 200);
 *         bytes memory callData = abi.encodeWithSignature("withDrawEth(uint256)", DEPOSIT_AMOUNT);
 *         vm.startPrank(USER);
 *         vm.expectEmit(true, false, false, false);
 *         emit WithDrawn(USER, DEPOSIT_AMOUNT);
 *         address(timeVault).call(callData);
 *         vm.stopPrank();
 *     }
 *
 *     function testRevertIfInsufficientEthToWithDraw() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *         vm.warp(block.timestamp + LOCK_DURATION + 200);
 *         bytes memory callData = abi.encodeWithSignature("withDrawEth(uint256)", 2 * DEPOSIT_AMOUNT);
 *         vm.startPrank(USER);
 *         vm.expectRevert(TimeVault__InsufficientBalance.selector);
 *         address(timeVault).call(callData);
 *         vm.stopPrank();
 *     }
 *
 *     function testWithDrawRevertsIfFundsAreStillLocked() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *         vm.warp(block.timestamp);
 *         bytes memory callData = abi.encodeWithSignature("withDrawEth(uint256)", DEPOSIT_AMOUNT);
 *         vm.startPrank(USER);
 *         vm.expectRevert(TimeVault__FundsLocked.selector);
 *         address(timeVault).call(callData);
 *     }
 *
 *     function testFallbackFunctionActCorrectly() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         bytes memory wrongCallData = abi.encodeWithSignature("sleep()", DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         (bool success,) = address(timeVault).call{value: DEPOSIT_AMOUNT}(wrongCallData);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(USER, address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *     }
 *
 *     function testUserToEthIsUpdatedCorrectlyWhenWithdrawing() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 initialBalance = timeVault.getDepositedAmount(USER, address(0));
 *         vm.warp(block.timestamp + LOCK_DURATION + 200);
 *         bytes memory callData = abi.encodeWithSignature("withDrawEth(uint256)", WITHDRAW_AMOUNT);
 *         vm.prank(USER);
 *         address(timeVault).call(callData);
 *         uint256 finalBalance = timeVault.getDepositedAmount(USER, address(0));
 *         assertEq(finalBalance + WITHDRAW_AMOUNT, initialBalance);
 *     }
 *
 *     function testStateUpdatesCorrectlyWhenUsersDeposit() public {
 *         vm.deal(USER, DEPOSIT_AMOUNT);
 *         uint256 initialBalance = timeVault.getDepositedAmount(USER, address(0));
 *         uint256 initialLockDuration = timeVault.getLockDuration(USER, address(0));
 *         vm.prank(USER);
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 finalBalance = timeVault.getDepositedAmount(USER, address(0));
 *         uint256 finalLockDuration = timeVault.getLockDuration(USER, address(0));
 *         assertGt(finalBalance, initialBalance);
 *         assertGt(finalLockDuration, initialLockDuration);
 *     }
 *
 *     function testRevertWithDrawRevertIfTransferFails() public {
 *         vm.deal(address(food), DEPOSIT_AMOUNT);
 *         vm.prank(address(food));
 *         timeVault.depositEth{value: DEPOSIT_AMOUNT}(LOCK_DURATION);
 *         uint256 depositedAmount = timeVault.getDepositedAmount(address(food), address(0));
 *         assert(depositedAmount == DEPOSIT_AMOUNT);
 *         vm.warp(block.timestamp + LOCK_DURATION + 200);
 *         bytes memory callData = abi.encodeWithSignature("withDrawEth(uint256)", DEPOSIT_AMOUNT);
 *         vm.startPrank(address(food));
 *         vm.expectRevert(TimeVault__TransferFailed.selector);
 *         address(timeVault).call(callData);
 *         vm.stopPrank();
 *     }
 * }
 *
 * contract Food {
 *     error Food__TransferFailed();
 *
 *     receive() external payable {
 *         revert Food__TransferFailed();
 *     }
 * }
 */
