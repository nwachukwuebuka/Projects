// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {StudyToken} from "../src/StudyToken.sol";
import {StudyLend} from "../src/StudyLend.sol";

/*
  DEPLOYMENT SCRIPT

  PATTERN 1 — LEGACY:
      Deploy manually from a block explorer UI.

  PATTERN 2 — RECOMMENDED:
      Version-controlled deployment scripts.

  PATTERN 3 — ALTERNATIVE:
      Foundry broadcasts + CI/CD deployment.

  PATTERN 4 — PRODUCTION:
      Deterministic deployment, multisigs, timelocks, environment-specific
      configuration, verification, and deployment records.
*/
contract Deploy is Script {
    function run() external returns (StudyToken token, StudyLend lend) {
        vm.startBroadcast();

        token = new StudyToken(1_000_000 ether);
        lend = new StudyLend(token);

        vm.stopBroadcast();
    }
}
