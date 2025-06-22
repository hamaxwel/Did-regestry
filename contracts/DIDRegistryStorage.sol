// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract DIDRegistryStorage {
    struct DIDRecord {
        address owner;
        string metadata;
        bool active;
    }
    struct MetadataHistory {
        uint256 timestamp;
        string metadata;
    }
    mapping(string => DIDRecord) internal didRecords;
    mapping(string => MetadataHistory[]) internal didHistory;
} 