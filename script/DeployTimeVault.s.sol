//SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Script} from "forge-std/Script.sol";
import {TimeVault} from "../src/TimeVault.sol";

contract DeployTimeVault is Script {
    function run() external returns (TimeVault) {
        vm.startBroadcast();
        TimeVault timeVault = new TimeVault();
        vm.stopBroadcast();
        return timeVault;
    }
}
