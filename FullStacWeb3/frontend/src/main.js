/*
  STUDYLEND FRONTEND

  This file teaches:
  - ES modules
  - DOM selection
  - events
  - async/await
  - error handling
  - BigInt
  - wallet providers
  - contract reads/writes
  - transaction lifecycle

  The frontend uses ethers v6 from a CDN.

  PATTERN 1 — LEGACY:
      web3.js + callback-heavy code

  PATTERN 2 — RECOMMENDED HERE:
      ethers v6 + async/await + ES modules

  PATTERN 3 — ALTERNATIVE:
      viem/wagmi in a modern React application

  PATTERN 4 — PRODUCTION:
      Add wallet abstraction, typed clients, chain validation,
      transaction simulation, error decoding, and state management.
*/

import { ethers } from "https://cdn.jsdelivr.net/npm/ethers@6.15.0/+esm";
import { CONFIG } from "./config.js";
import { TOKEN_ABI, LENDING_ABI } from "./abi.js";

const $ = (selector) => document.querySelector(selector);

let browserProvider = null;
let signer = null;
let token = null;
let lending = null;
let account = null;

/*
  PATTERN 1 — LEGACY:
      document.getElementById("connectButton")

  PATTERN 2 — RECOMMENDED:
      querySelector("#connectButton")

  Both are valid. querySelector is more flexible because it accepts CSS selectors.
*/
const connectButton = $("#connectButton");
const activityLog = $("#activityLog");

function setText(selector, value) {
  const element = $(selector);
  if (element) element.textContent = value;
}

function shortenAddress(address) {
  return address ? `${address.slice(0, 6)}…${address.slice(-4)}` : "—";
}

function formatUnits(value) {
  try {
    return ethers.formatUnits(value, CONFIG.tokenDecimals);
  } catch {
    return "0";
  }
}

function logActivity(message, txHash = null) {
  const item = document.createElement("div");
  item.className = "activity-item";

  const text = document.createElement("span");
  text.textContent = message;

  item.appendChild(text);

  if (txHash) {
    const link = document.createElement("a");
    link.href = `https://etherscan.io/tx/${txHash}`;
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    link.textContent = ` ${shortenAddress(txHash)}`;
    item.appendChild(link);
  }

  if (activityLog.firstElementChild?.textContent === "No transactions yet.") {
    activityLog.replaceChildren();
  }

  activityLog.prepend(item);
}

/*
  PATTERN 1 — LEGACY:
      provider.send("eth_requestAccounts")

  PATTERN 2 — MODERN:
      BrowserProvider + getSigner()

  PATTERN 3 — ALTERNATIVE:
      WalletConnect or another injected-wallet abstraction.

  Important:
  A browser provider lets you request accounts and read chain state.
  A signer is required to authorize state-changing transactions.
*/
async function connectWallet() {
  if (!window.ethereum) {
    throw new Error("No injected wallet found. Install a browser wallet such as MetaMask.");
  }

  browserProvider = new ethers.BrowserProvider(window.ethereum);

  // Request permission from the wallet.
  await browserProvider.send("eth_requestAccounts", []);

  signer = await browserProvider.getSigner();
  account = await signer.getAddress();

  const network = await browserProvider.getNetwork();

  setText("#walletAddress", shortenAddress(account));
  setText("#chainId", `Chain ID: ${network.chainId}`);
  setText("#networkName", network.chainId === BigInt(CONFIG.chainId) ? "Local Anvil" : "Wrong / other network");

  token = new ethers.Contract(CONFIG.tokenAddress, TOKEN_ABI, signer);
  lending = new ethers.Contract(CONFIG.lendingAddress, LENDING_ABI, signer);

  connectButton.textContent = shortenAddress(account);

  await refreshDashboard();
}

/*
  Reads do not create transactions.

  PATTERN 1 — LEGACY:
      const result = await contract.methods.totalSupply().call();

  PATTERN 2 — ethers:
      const result = await contract.totalSupplied();

  PATTERN 3 — viem:
      publicClient.readContract(...)

  PATTERN 4 — PRODUCTION:
  Batch independent reads using multicall where appropriate.
*/
async function refreshDashboard() {
  if (!lending || !account) return;

  const [
    totalSupplied,
    totalBorrowed,
    utilization,
    shares,
    collateralAmount,
    debtAmount,
    balance
  ] = await Promise.all([
    lending.totalSupplied(),
    lending.totalBorrowed(),
    lending.utilizationBps(),
    lending.userShares(account),
    lending.collateral(account),
    lending.debt(account),
    token.balanceOf(account)
  ]);

  setText("#totalSupply", formatUnits(totalSupplied));
  setText("#totalBorrowed", formatUnits(totalBorrowed));
  setText("#utilization", `${Number(utilization) / 100}%`);

  setText("#userShares", formatUnits(shares));
  setText("#userCollateral", formatUnits(collateralAmount));
  setText("#userDebt", formatUnits(debtAmount));
  setText("#userSupply", formatUnits(await lending.shareValue(shares)));
  setText("#walletBalance", `Balance: ${formatUnits(balance)} ${CONFIG.tokenSymbol}`);
}

/*
  Token approval is a two-step flow:

  1. approve(pool, amount)
  2. pool.supply(amount)

  PATTERN 1 — LEGACY:
  ERC-20 approve was sometimes followed by immediately assuming the
  transaction was mined.

  PATTERN 2 — RECOMMENDED:
  Wait for the transaction receipt before relying on the state change.
*/
async function ensureApproval(amount) {
  const allowance = await token.allowance(account, CONFIG.lendingAddress);

  if (allowance >= amount) return;

  logActivity("Approval transaction submitted…");
  const approvalTx = await token.approve(CONFIG.lendingAddress, amount);
  await approvalTx.wait();
  logActivity("Approval confirmed.", approvalTx.hash);
}

async function supply(amountText) {
  if (!lending) throw new Error("Connect your wallet first.");

  const amount = ethers.parseUnits(amountText, CONFIG.tokenDecimals);

  await ensureApproval(amount);

  logActivity("Supply transaction submitted…");
  const tx = await lending.supply(amount);
  await tx.wait();

  logActivity("Supply confirmed.", tx.hash);
  await refreshDashboard();
}

async function borrow(collateralText, borrowText) {
  if (!lending) throw new Error("Connect your wallet first.");

  const collateralAmount = ethers.parseUnits(collateralText, CONFIG.tokenDecimals);
  const borrowAmount = ethers.parseUnits(borrowText, CONFIG.tokenDecimals);

  await ensureApproval(collateralAmount);

  logActivity("Borrow transaction submitted…");
  const tx = await lending.borrow(collateralAmount, borrowAmount);
  await tx.wait();

  logActivity("Borrow confirmed.", tx.hash);
  await refreshDashboard();
}

function showError(error) {
  console.error(error);

  const reason =
    error?.shortMessage ||
    error?.reason ||
    error?.message ||
    "Unknown error";

  logActivity(`Error: ${reason}`);
}

connectButton.addEventListener("click", async () => {
  try {
    await connectWallet();
  } catch (error) {
    showError(error);
  }
});

$("#supplyForm").addEventListener("submit", async (event) => {
  event.preventDefault();

  try {
    const amount = $("#supplyAmount").value;
    if (!amount || Number(amount) <= 0) throw new Error("Enter a positive amount.");
    await supply(amount);
  } catch (error) {
    showError(error);
  }
});

$("#borrowForm").addEventListener("submit", async (event) => {
  event.preventDefault();

  try {
    const collateral = $("#collateralAmount").value;
    const borrowAmount = $("#borrowAmount").value;

    if (!collateral || Number(collateral) <= 0) {
      throw new Error("Enter collateral.");
    }

    if (!borrowAmount || Number(borrowAmount) <= 0) {
      throw new Error("Enter a borrow amount.");
    }

    await borrow(collateral, borrowAmount);
  } catch (error) {
    showError(error);
  }
});

/*
  PATTERN 1 — LEGACY:
      window.addEventListener("load", ...)

  PATTERN 2 — MODERN:
      type="module" scripts are deferred automatically.
      This file can safely query DOM elements because module execution
      happens after parsing.

  PATTERN 3 — ALTERNATIVE:
      DOMContentLoaded is useful for classic scripts.
*/

if (window.ethereum) {
  window.ethereum.on("accountsChanged", async (accounts) => {
    if (!accounts.length) {
      account = null;
      signer = null;
      token = null;
      lending = null;
      setText("#walletAddress", "Not connected");
      return;
    }

    try {
      await connectWallet();
    } catch (error) {
      showError(error);
    }
  });

  window.ethereum.on("chainChanged", () => {
    window.location.reload();
  });
}

logActivity("StudyLend frontend loaded. Connect a wallet to begin.");


/*
=============================================================
STUDY MODE — "YOU CAN ALSO DO IT THIS WAY"
=============================================================

Whenever you modify this file, keep this convention:

PATTERN 1 — LEGACY
------------------
Show the older/common approach in comments.

PATTERN 2 — CURRENT / RECOMMENDED
---------------------------------
Keep the approach actually used by the project.

PATTERN 3 — ALTERNATIVE
-----------------------
Comment another valid implementation and explain the trade-off.

PATTERN 4 — PRODUCTION
----------------------
Comment what a serious production system would additionally require.

Example JavaScript:

// PATTERN 1 — LEGACY
// button.onclick = handleClick;

// PATTERN 2 — CURRENT
// button.addEventListener("click", handleClick);

// PATTERN 3 — ALTERNATIVE
// event delegation can be better for many dynamic buttons.

// PATTERN 4 — PRODUCTION
// centralize UI state and handle loading/error/disabled states.

Example Solidity:

// PATTERN 1 — LEGACY
// require(amount > 0, "ZERO");

// PATTERN 2 — CURRENT
// if (amount == 0) revert ZeroAmount();

// PATTERN 3 — ALTERNATIVE
// use a library/helper for repeated validation.

// PATTERN 4 — PRODUCTION
// prove the invariant with fuzz/invariant tests and audit assumptions.

The goal is not to use every pattern in production.
// The goal is to recognize the family of solutions and understand why
// one was selected.
=============================================================
*/
