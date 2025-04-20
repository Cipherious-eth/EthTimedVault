# ⏳ TimeVault

A simple Ethereum-based vault smart contract that allows users to lock their ETH for a specified duration. Designed for learning and experimentation.

---

## 📜 Description

**TimeVault** is a smart contract built in Solidity that allows users to deposit ETH into a vault and lock it for a defined period. After the lock period expires, users can withdraw their funds.

---

## 👨‍💻 Author

- **Cipherious.xyz**

---

## 🚀 Features

- Deposit ETH with a custom lock duration.
- Fallback and `receive()` functions support direct ETH transfers (with default lock duration).
- Withdraw funds only after the lock time has elapsed.
- Custom errors for gas efficiency.
- View functions for deposited amount and lock status.

---

## 🔐 Lock Mechanism

- Each deposit is associated with a **lock duration** (in seconds).
- ETH is locked until the current block timestamp surpasses the recorded unlock time.
- Default lock duration is `1000 seconds` for fallback and direct payments.

---

## 📦 Contract Functions

### 🔹 deposit(uint256 lockDuration)
Deposits ETH and sets a custom lock duration.

```solidity
function deposit(uint256 lockDuration) public payable
