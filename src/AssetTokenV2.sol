// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

import {AssetToken} from "./AssetToken.sol";

contract AssetTokenV2 is AssetToken {
    bool public paused;//APPENDED SAFELY AT THE END

    event Paused(address account);
    event Unpaused(address account);

    error AlreadyPaused();
   


    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function _update(address from, address to, uint256 value) internal override {
        if (paused) {
            revert AlreadyPaused();
        }
        super._update(from, to, value);
    }

    
    function version() public pure returns (string memory) {
        return "V2";
    }


}