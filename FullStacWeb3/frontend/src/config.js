/*
  CONTRACT CONFIGURATION

  After running the Foundry deployment script, put the local addresses here.

  PATTERN 1 — LEGACY:
  Older Web3 projects often kept addresses in a hard-coded global:
      const LENDING_POOL = "0x...";

  PATTERN 2 — RECOMMENDED:
  Keep configuration in a dedicated module and export immutable values.

  PATTERN 3 — ALTERNATIVE:
  Use environment/build-time configuration with Vite, Next.js, etc.

  PATTERN 4 — PRODUCTION:
  Maintain separate configs for local/testnet/mainnet and validate chain IDs.
*/

export const CONFIG = Object.freeze({
  chainId: 31337,
  rpcUrl: "http://127.0.0.1:8545",

  // Replace these after deployment.
  tokenAddress: "0x0000000000000000000000000000000000000000",
  lendingAddress: "0x0000000000000000000000000000000000000000",

  tokenDecimals: 18,
  tokenSymbol: "STUDY"
});
