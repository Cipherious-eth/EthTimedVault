//  SPDX-License-Identifier:MIT
pragma solidity 0.8.21;
/**
 * @title TimeVault
 * @author cipheriousxyz
 * @notice A  vault that locks up eth for a certain period of time
 */

contract TimeVault {
    error TimeVault__MustDepositMoreThanZero();
    error TimeVault__InsufficientBalance();
    error TimeVault__FundsLocked();
    error TimeVault__TransferFailed();

    mapping(address user => uint256 depositedAmount) private s_userToEthDeposited;
    mapping(address user => uint256 lockedDuration) private s_userToLockDuration;
    uint256 private constant DEFAULT_LOCK_DURATION = 1000;

    event Deposited(address indexed user, uint256 amount, uint256 lockDuration);
    event WithDrawn(address indexed user, uint256 amount);

    function deposit(uint256 lockDuration) public payable {
        if (msg.value == 0) {
            revert TimeVault__MustDepositMoreThanZero();
        }
        s_userToEthDeposited[msg.sender] += msg.value;
        s_userToLockDuration[msg.sender] = block.timestamp + lockDuration;
        emit Deposited(msg.sender, msg.value, lockDuration);
    }

    function withDraw(uint256 amount) public {
        if (amount > s_userToEthDeposited[msg.sender]) {
            revert TimeVault__InsufficientBalance();
        }
        if (block.timestamp < s_userToLockDuration[msg.sender]) {
            revert TimeVault__FundsLocked();
        }
        s_userToEthDeposited[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) {
            revert TimeVault__TransferFailed();
        }
        emit WithDrawn(msg.sender, amount);
    }

    fallback() external payable {
        deposit(DEFAULT_LOCK_DURATION);
    }

    receive() external payable {
        deposit(DEFAULT_LOCK_DURATION);
    }

    function getDepositedAmount(address user) public view returns (uint256) {
        return s_userToEthDeposited[user];
    }

    function getLockDuration(address user) public view returns (uint256) {
        return s_userToLockDuration[user];
    }

    function getDefaultLockedDuration() public pure returns (uint256) {
        return DEFAULT_LOCK_DURATION;
    }
}
