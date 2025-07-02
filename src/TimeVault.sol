//  SPDX-License-Identifier:MIT
pragma solidity 0.8.21;
/**
 * @title TimeVault
 * @author cipheriousxyz
 * @notice A  vault that locks up eth for a certain period of time
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TimeVault {
    using SafeERC20 for IERC20;

    error TimeVault__MustDepositMoreThanZero();
    error TimeVault__InsufficientBalance();
    error TimeVault__FundsLocked();
    error TimeVault__TransferFailed();
    error TimeVault__InvalidToken();

    mapping(address user => mapping(address token => uint256 lockedDuration)) private s_userToLockDuration;
    mapping(address user => mapping(address token => uint256 balance)) private s_userBalances;
    uint256 private constant DEFAULT_LOCK_DURATION = 1000;

    event Deposited(address indexed user, address indexed token, uint256 amount, uint256 lockDuration);
    event WithDrawn(address indexed user, address indexed token, uint256 amount);
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////  ETHER             VAULT /////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function depositEth(uint256 lockDuration) public payable {
        if (msg.value == 0) {
            revert TimeVault__MustDepositMoreThanZero();
        }
        s_userBalances[msg.sender][address(0)] += msg.value;

        s_userToLockDuration[msg.sender][address(0)] == 0
            ? s_userToLockDuration[msg.sender][address(0)] = block.timestamp + lockDuration
            : s_userToLockDuration[msg.sender][address(0)] += lockDuration;
        uint256 lockEndAt = s_userToLockDuration[msg.sender][address(0)];
        emit Deposited(msg.sender, address(0), msg.value, lockEndAt);
    }

    function withDrawEth(uint256 amount) public {
        if (amount > s_userBalances[msg.sender][address(0)]) {
            revert TimeVault__InsufficientBalance();
        }
        if (block.timestamp < s_userToLockDuration[msg.sender][address(0)]) {
            revert TimeVault__FundsLocked();
        }
        s_userBalances[msg.sender][address(0)] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) {
            revert TimeVault__TransferFailed();
        }
        emit WithDrawn(msg.sender, address(0), amount);
    }
    ////////////////////////////////////////////////////////`///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////  TOKEN  VAULT ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function depositTokens(address token, uint256 amount, uint256 lockDuration) public {
        if (token == address(0)) revert TimeVault__InvalidToken();
        //allow people to deposit tokens
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        //we update the state for the user
        s_userBalances[msg.sender][token] += amount;
        s_userToLockDuration[msg.sender][token] == 0
            ? s_userToLockDuration[msg.sender][token] = block.timestamp + lockDuration
            : s_userToLockDuration[msg.sender][token] += lockDuration;
        uint256 lockEndAt = s_userToLockDuration[msg.sender][token];
        emit Deposited(msg.sender, token, amount, lockEndAt);

        //
    }

    function withdrawTokens(address token, uint256 amount) public {
        if (token == address(0)) revert TimeVault__InvalidToken();
        //make sure enough time has pass for the user
        uint256 lockEndAt = s_userToLockDuration[msg.sender][token];
        if (lockEndAt > block.timestamp) revert TimeVault__FundsLocked();
        //get user balance
        uint256 balance = s_userBalances[msg.sender][token];
        if (amount > balance) revert TimeVault__InsufficientBalance();
        //send the tokens to the user
        s_userBalances[msg.sender][token] -= amount;

        IERC20(token).safeTransfer(msg.sender, amount);
        emit WithDrawn(msg.sender, token, amount);
    }

    fallback() external payable {
        depositEth(DEFAULT_LOCK_DURATION);
    }

    receive() external payable {
        depositEth(DEFAULT_LOCK_DURATION);
    }
    /////////////////////////////////////////////////////////
    ////  GETTERS                    ////////////////////////
    /////////////////////////////////////////////////////////

    function getDepositedAmount(address user, address token) public view returns (uint256) {
        return s_userBalances[user][token];
    }

    function getLockDuration(address user, address token) public view returns (uint256) {
        return s_userToLockDuration[user][token];
    }

    function getDefaultLockedDuration() public pure returns (uint256) {
        return DEFAULT_LOCK_DURATION;
    }
}
