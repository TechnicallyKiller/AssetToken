// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.31;
import {Script, console} from "forge-std/Script.sol";
import {AssetToken} from "../src/AssetToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployAssetToken is Script {
    function run() external {
        vm.startBroadcast();
        AssetToken assetTokenImpl = new AssetToken();

        bytes memory data = abi.encodeWithSelector(
            AssetToken.initialize.selector,
            "Xaults Asset Token",
            "XAT",
            msg.sender,
            msg.sender,
            1_000_000_000 * 10 ** 18
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(assetTokenImpl), data);

        console.log("Implementation:", address(assetTokenImpl));
        console.log("Proxy Address: ", address(proxy));

        vm.stopBroadcast();
    }
}