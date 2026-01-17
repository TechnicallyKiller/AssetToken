// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

import {Initializable} from "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";//INITIALIZABLE FOR UPGRADEABLE CONTRACTS
import {UUPSUpgradeable} from "@openzeppelin-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";//UUPS UPGRADEABLE PROXY
import {ERC20Upgradeable} from "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";//ERC20 STANDARD FOR UPGRADEABLE
import {AccessControlUpgradeable} from "@openzeppelin-upgradeable/contracts/access/AccessControlUpgradeable.sol";//FOR ROLES

contract AssetToken is Initializable, ERC20Upgradeable, UUPSUpgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
     uint256 public s_maxSupply;  //CONSTANTS ALWAYS IN UPPERCASE


    event TokenInitialized(string name, string symbol, address admin, address minter);
    event TokenMinted(address to, uint256 amount);
    

    error MaxSupplyExceeded(uint256 attemptedMint, uint256 maxSupply);

    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function initialize(string memory name , string memory symbol, address admin, address minter, uint256 _maxSupply) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
        s_maxSupply = _maxSupply;
        emit TokenInitialized(name, symbol, admin, minter);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE){
        if(totalSupply()+ amount > s_maxSupply){
            revert MaxSupplyExceeded(amount, s_maxSupply);
        }
        emit TokenMinted(to, amount);
        _mint(to, amount);
    }



}