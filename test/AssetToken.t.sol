// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

import {Test, console} from "forge-std/Test.sol";
import {AssetToken} from "../src/AssetToken.sol";
import {AssetTokenV2} from "../src/AssetTokenV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AssetTokenTest is Test {
    AssetToken public implementationV1;
    AssetTokenV2 public implementationV2;
    ERC1967Proxy public proxy;
    
    // Interface wrappers for ABI compatibility
    AssetToken public tokenV1; 
    AssetTokenV2 public tokenV2;

    address public admin = address(1);
    address public minter = address(2);
    address public user = address(3);

    function setUp() public {
        implementationV1 = new AssetToken();

        // Encode initialization call (Order: Name, Symbol, Admin, Minter, Supply)
        bytes memory initData = abi.encodeWithSelector(
            AssetToken.initialize.selector,
            "Xaults Asset Token",
            "XAT",
            admin,    
            minter,    
            1_000_000 * 10**18 
        );

        proxy = new ERC1967Proxy(address(implementationV1), initData);

        // Point V1 interface to the proxy address
        tokenV1 = AssetToken(address(proxy));
    }

    function testUpgradeLifecycle() public {
        //  Verify V1 Minting
        vm.startPrank(minter);
        tokenV1.mint(user, 100 ether);
        vm.stopPrank();

        assertEq(tokenV1.balanceOf(user), 100 ether);
        assertEq(tokenV1.s_maxSupply(), 1_000_000 ether);

        //  Upgrade to V2
        implementationV2 = new AssetTokenV2();

        vm.startPrank(admin);
        // Upgrade Call
        tokenV1.upgradeToAndCall(address(implementationV2), "");
        vm.stopPrank();

        //  Verify State Persistence & V2 Interface
        tokenV2 = AssetTokenV2(address(proxy));

        assertEq(tokenV2.balanceOf(user), 100 ether); // Balance must persist
        assertEq(tokenV2.paused(), false);           // New storage initialized to default

        //  Verify PAUSE
        
        // Transfer Succesfully when not paused
        vm.prank(user);
        tokenV2.transfer(address(4), 10 ether);
        assertEq(tokenV2.balanceOf(address(4)), 10 ether);

        // Admin enables pause
        vm.prank(admin);
        tokenV2.pause();
        assertEq(tokenV2.paused(), true);

        // Ensure transfers revert when paused
        vm.startPrank(user);
        vm.expectRevert(AssetTokenV2.AlreadyPaused.selector); // Matches V2 error definition
        tokenV2.transfer(address(4), 10 ether);
        vm.stopPrank();
    }
}