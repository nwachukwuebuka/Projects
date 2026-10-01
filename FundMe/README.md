# 📘 FundMe Smart Contract
<br>

## 📖 Overview
**FundMe** is a decentralized crowdfunding smart contract built with **Solidity** and the **Foundry** framework.  
It allows users to fund a project with ETH while enforcing a minimum USD value using **Chainlink Price Feeds**.  
Only the contract owner can withdraw the funds.

This project demonstrates secure smart contract development, testing, deployment, and CI integration.

---

<br><br>

## ✨ Features

- 💰 Accept ETH funding from multiple users  
- 📉 Minimum funding requirement in USD  
- 🔗 Real-time ETH/USD conversion using Chainlink Price Feeds  
- 🔐 Owner-only withdrawal function  
- 🧪 Comprehensive unit tests with Foundry  

---

<br><br>

## 💻REQUIREMENTS
- kgit
- foundry(solidity framework)
---
<br><br>


## ⚙️ Installation & Setup

### 1️⃣ *Clone the Repository*

```bash
git clone https://github.com/LuizToren120/Foundry_FundMe.git
cd Foundry_FundMe
```

<br>

### 2️⃣ *Install Dependencies*
```bash
forge install
```

>! NOTE
It installs two dependencies needed from the foundry.toml, needed in testing and pricefeeds(from ChainLin)

    
#### Can be installed individually:
```bash
forge install foundry-rs/forge-std 
forge install smartcontractkit/chainlink-brownie-contracts
```
---
<br><br>


## ▶️ Usage
Run at the root directory 

Deploy contract:
```bash
forge fmt
forge build
forge test -vv
make deploy
```
<br>

## Recommendation
Check the Makefile for more bash commands

---
<br><br><br>

# THANK YOU

