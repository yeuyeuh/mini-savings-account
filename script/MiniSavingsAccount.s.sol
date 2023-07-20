// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "forge-std/Script.sol";
import "../src/MiniSavingsAccount.sol";

contract MiniSavingsAccountScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MiniSavingsAccount msa = new MiniSavingsAccount();

        vm.stopBroadcast();
    }
}