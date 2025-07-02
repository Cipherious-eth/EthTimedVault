//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TimeVault} from "../src/TimeVault.sol";
import {DeployTimeVault} from "../script/DeployTimeVault.s.sol";

contract TimeVaultFuzz is Test {
    TimeVault public timeVault;
    DeployTimeVault public deployer;

    function setUp() public {
        deployer = new DeployTimeVault();
        timeVault = deployer.run();
    }

    function testUsersCanDepositFundsFuzz(uint256 _amount, uint256 _lock, address _user) public {
        _amount = bound(_amount, 1, type(uint112).max - 1);
        _lock = bound(_lock, 1, type(uint112).max - 1);
        vm.deal(_user, _amount);
        vm.prank(_user);
        timeVault.depositEth{value: _amount}(_lock);
        uint256 depositedAmount = timeVault.getDepositedAmount(_user, address(0));
        assert(depositedAmount == _amount);
    }

    function testUsersCanWithDrawFundsFuzz(uint256 _amount, uint256 _lock) public {
        _amount = bound(_amount, 1, type(uint112).max - 2);
        _lock = bound(_lock, 1, type(uint112).max - 2);
        address _user = makeAddr("user");
        vm.deal(_user, _amount);
        vm.prank(_user);
        timeVault.depositEth{value: _amount}(_lock);
        uint256 depositedAmount = timeVault.getDepositedAmount(_user, address(0));
        assert(depositedAmount == _amount);
        vm.warp(block.timestamp + _lock + 200);
        vm.prank(_user);
        timeVault.withDrawEth(_amount);
        assertEq(timeVault.getDepositedAmount(_user, address(0)), 0);
    }
}
