// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "forge-std/Script.sol";
import "../src/MsaToken.sol";

contract MsaTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MsaToken msaToken = new MsaToken("MsaToken", "MSA");

        vm.stopBroadcast();
    }
}