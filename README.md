# 🏦 CryptoBank: Secure State Management & Reentrancy Protection

A secure implementation of a decentralized banking protocol on the EVM, focusing on preventing Reentrancy attacks and optimizing state storage costs.

## 🚀 Engineering Context

As a **Java Software Engineer**, creating a "Bank" application typically involves managing thread safety and ACID transactions. In **Solidity**, the paradigm shifts entirely towards **Gas Optimization** and **Reentrancy Protection**.

This project translates classic OOP state management into smart contract logic, highlighting the critical security differences required when handling value on a public blockchain versus a centralized backend.

## 💡 Project Overview

**CryptoBank** allows users to securely deposit and withdraw Ether. Unlike a standard implementation, this contract enforces strict business rules and administrative controls using low-level optimization techniques rather than high-level abstractions.

### 🔍 Key Technical Features:

* **Security Pattern: Checks-Effects-Interactions (CEI):**
    * **Defense Strategy:** The `withdrawEther` function strictly follows the CEI pattern: validating inputs first, updating the state (Effect) second, and performing the external call (Interaction) last.
    * **Why:** This architectural choice is mandatory to prevent **Reentrancy attacks**, ensuring that even if the recipient is a malicious contract, it cannot re-enter the function to drain funds before the balance is updated.

* **Efficient State Management:**
    * **Mappings vs. HashMaps:** Utilized `mapping(address => uint256)` for O(1) balance lookups. Unlike Java's `HashMap`, Solidity mappings are not iterable, which necessitated specific design choices for data retrieval and updating.

* **Gas Optimization (Custom Errors):**
    * **Bytecode Reduction:** Replaced expensive `require` strings with **Custom Errors** (e.g., `error MaxBalanceReached()`). This significantly reduces deployment costs and runtime gas consumption compared to storing ASCII strings on-chain.

* **Access Control:**
    * Implemented a reusable `modifier onlyAdmin` to guard sensitive configuration functions, ensuring separation of duties.

## 🛠️ Stack & Tools

* **Language:** Solidity `^0.8.24`.
* **Security:** CEI Pattern, Modifiers.
* **Concepts:** State Management, Gas Profiling.
* **License:** GPL-3.0.

---

*This project demonstrates secure financial logic implementation on the Ethereum Virtual Machine.*