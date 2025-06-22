// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./DIDRegistryStorage.sol";
import "./DIDRegistryEvents.sol";
import "./DIDRegistryAdmin.sol";
import "./DIDRegistryMetaTx.sol";

/**
 * @title DIDRegistry (Modular, MetaTx, World-Class)
 * @dev Main registry logic, inherits all OpenZeppelin contracts and modular logic contracts.
 */
contract DIDRegistry is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    DIDRegistryStorage,
    DIDRegistryEvents,
    DIDRegistryAdmin,
    DIDRegistryMetaTx
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address private _trustedForwarder;

    function initialize(address admin, address trustedForwarder) public initializer {
        __Ownable_init();
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        _trustedForwarder = trustedForwarder;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    // ========== Modifiers ==========
    modifier onlyDIDOwner(string memory did) {
        require(didRecords[did].owner == _msgSender(), "Not DID owner");
        _;
    }
    modifier onlyActiveDID(string memory did) {
        require(didRecords[did].active, "DID not active");
        _;
    }

    // ========== DID Management ==========
    function registerDID(string calldata did, string calldata metadata) external whenNotPaused nonReentrant {
        require(bytes(did).length > 0, "DID required");
        require(didRecords[did].owner == address(0), "DID already registered");
        didRecords[did] = DIDRecord({
            owner: _msgSender(),
            metadata: metadata,
            active: true
        });
        didHistory[did].push(MetadataHistory({timestamp: block.timestamp, metadata: metadata}));
        emit DIDRegistered(did, _msgSender(), metadata);
    }

    function updateDID(string calldata did, string calldata metadata) external whenNotPaused nonReentrant onlyDIDOwner(did) onlyActiveDID(did) {
        didRecords[did].metadata = metadata;
        didHistory[did].push(MetadataHistory({timestamp: block.timestamp, metadata: metadata}));
        emit DIDUpdated(did, metadata);
    }

    function revokeDID(string calldata did) external whenNotPaused nonReentrant onlyDIDOwner(did) onlyActiveDID(did) {
        didRecords[did].active = false;
        emit DIDRevoked(did);
    }

    function transferDIDOwnership(string calldata did, address newOwner) external whenNotPaused nonReentrant onlyDIDOwner(did) onlyActiveDID(did) {
        require(newOwner != address(0), "Invalid new owner");
        address previousOwner = didRecords[did].owner;
        didRecords[did].owner = newOwner;
        emit DIDOwnershipTransferred(did, previousOwner, newOwner);
    }

    // ========== Admin/Emergency Functions ==========
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
        _pauseRegistry();
    }
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
        _unpauseRegistry();
    }
    function forceRevokeDID(string calldata did) external whenNotPaused onlyRole(ADMIN_ROLE) onlyActiveDID(did) {
        _forceRevokeDID(did, _msgSender());
    }

    // ========== Query Functions ==========
    function getDID(string calldata did) external view returns (address owner, string memory metadata, bool active) {
        DIDRecord storage record = didRecords[did];
        return (record.owner, record.metadata, record.active);
    }
    function getDIDHistory(string calldata did) external view returns (MetadataHistory[] memory) {
        return didHistory[did];
    }
    function isActive(string calldata did) external view returns (bool) {
        return didRecords[did].active;
    }

    // ========== Upgradeability ==========
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // ========== Meta-Transaction Support ==========
    function versionRecipient() external pure returns (string memory) {
        return "2.2.0";
    }

    // ========== Context Overrides ==========
    function _msgSender() internal view override returns (address sender) {
        if (msg.data.length >= 20 && msg.sender == _trustedForwarder) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            sender = msg.sender;
        }
    }
    function _msgData() internal view override returns (bytes calldata) {
        if (msg.data.length >= 20 && msg.sender == _trustedForwarder) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
} 