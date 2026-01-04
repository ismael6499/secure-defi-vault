# 🛡️ Secure DeFi Vault: Reentrancy-Hardened Protocol

![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?style=flat-square&logo=solidity)
![Security](https://img.shields.io/badge/Pattern-Checks_Effects_Interactions-green?style=flat-square)
![License](https://img.shields.io/badge/License-GPL_3.0-blue?style=flat-square)

A secure reference implementation of a decentralized custody protocol (Vault). This project focuses on **architectural defense** against reentrancy vectors and state inconsistency.

Unlike traditional centralized ledgers where database transactions provide ACID properties, smart contracts require explicit ordering of operations to prevent malicious callbacks. This repository demonstrates the rigorous application of the **Checks-Effects-Interactions (CEI)** pattern to secure native Ether withdrawals without relying on heavy external libraries.

## 🏗 Architecture & Design Decisions

### 1. Defensive Architecture (CEI Pattern)
- **Reentrancy Mitigation:**
  - The `withdrawEther` logic is strictly ordered to update the internal state (`userBalance[msg.sender] -= _amount`) *before* triggering the external low-level call.
  - **Impact:** This structural decision neutralizes reentrancy attacks. Even if the recipient is a malicious contract attempting to re-enter `withdrawEther` upon receiving funds, the state has already been decremented, causing the subsequent check (`if (_amount > userBalance)`) to fail (Revert).

### 2. Gas Optimization Strategy
- **Zero-Cost Validation:**
  - Replaced standard string-based requirements (`require(cond, "Reason")`) with **Custom Errors** (`error MaxBalanceReached()`).
  - **Efficiency:** This reduces deployment bytecode size and eliminates runtime gas costs associated with memory allocation for ASCII encoding during reverts.
- **Event Indexing:**
  - Implemented `indexed` parameters in `EtherDeposit` and `EtherWithdraw` events to enable efficient off-chain filtering and historical data reconstruction by subgraphs.

### 3. Access Control
- **Role-Based Security:**
  - Utilizes a reusable `onlyAdmin` modifier to enforce separation of duties for critical parameter changes (`modifyMaxBalance`).

## 🛠 Tech Stack

* **Core:** Solidity `^0.8.24`
* **Security:** CEI (Checks-Effects-Interactions), Low-level Calls
* **License:** GNU GPL v3

## 📝 Contract Interface

The system exposes a secure vault interface for ETH custody:

```solidity
// Secure withdrawal pattern
function withdrawEther(uint256 _amount) external {
    // 1. Check
    if (_amount > userBalance[msg.sender]) revert InsufficientBalance();

    // 2. Effect (State Update)
    userBalance[msg.sender] -= _amount;

    // 3. Interaction (External Call)
    (bool success, ) = msg.sender.call{value: _amount}("");
    if (!success) revert TransferFailed();
}
