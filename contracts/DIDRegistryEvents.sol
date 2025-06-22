// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract DIDRegistryEvents {
    event DIDRegistered(string indexed did, address indexed owner, string metadata);
    event DIDUpdated(string indexed did, string metadata);
    event DIDRevoked(string indexed did);
    event DIDOwnershipTransferred(string indexed did, address indexed previousOwner, address indexed newOwner);
    event DIDForceRevoked(string indexed did, address indexed admin);
    event RegistryPaused(address indexed admin);
    event RegistryUnpaused(address indexed admin);
} 