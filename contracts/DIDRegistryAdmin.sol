// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DIDRegistryEvents.sol";
import "./DIDRegistryStorage.sol";

abstract contract DIDRegistryAdmin is DIDRegistryStorage, DIDRegistryEvents {
    // bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // These functions are meant to be called from the main contract with access control enforced there
    function _pauseRegistry() internal {
        emit RegistryPaused(msg.sender);
    }

    function _unpauseRegistry() internal {
        emit RegistryUnpaused(msg.sender);
    }

    function _forceRevokeDID(string calldata did, address admin) internal {
        require(didRecords[did].active, "DID not active");
        didRecords[did].active = false;
        emit DIDForceRevoked(did, admin);
    }
} 