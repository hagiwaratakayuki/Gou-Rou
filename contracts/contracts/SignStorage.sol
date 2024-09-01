// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "hardhat/console.sol";

contract Storage {
    using ECDSA for bytes32;

    struct Signer {
        address signAccount;
        string callMethod;
        address callAccount;
    }
    struct Sign {
        bytes acceptSignature; // ECDSA sign for target account
        bytes requstSignature;
        address signer;
        address truster;
        address payChecker;
        uint fee; //wei
    }

    uint payCheckerCount;
    mapping(address => uint) address2PayCheckerId;

    mapping(address => Signer) signerMapping;
    mapping(address => Sign) signMapping;

    mapping(address => bool) _signerUpdateAuthorityContracts;
    mapping(address => bool) _trustAuthorityAccont;
    mapping(address => bool) _decrareOwnershipAuthorityAccount;

    mapping(address => bool) _defaultSignerUpdateAuthorityContracts;
    mapping(address => bool) _defaultrustAuthorityAccont;

    address _defaultOperater;

    constructor(address defaultOperater) {
        _defaultOperater = defaultOperater;
    }

    function getDefaultOperater() public view returns (address) {
        return _defaultOperater;
    }

    function insertOrUpdateSigner(
        address signAccount,
        string memory callMethod,
        address callAccount
    ) public {
        require(
            _signerUpdateAuthorityContracts[msg.sender],
            "authoraization failed"
        );
        signerMapping[tx.origin].signAccount = signAccount;
        signerMapping[tx.origin].callAccount = callAccount;
        signerMapping[tx.origin].callMethod = callMethod;
    }

    function getSignAccount() public view returns (address) {
        Signer memory signer = signerMapping[tx.origin];
        address signerAccount = signer.signAccount;
        return signerAccount;
    }

    function addTrust(
        //bytes32 message,
        bytes memory requestSignature,
        bytes memory acceptSignature,
        address target,
        address truster,
        uint fee
    ) public returns (bool) {
        require(
            signerMapping[truster].signAccount == tx.origin,
            "truster or signer is invalid"
        );

        require(
            MessageHashUtils
                .toEthSignedMessageHash(abi.encodePacked(tx.origin))
                .recover(requestSignature) == target,
            "invalid accept signature"
        );
        require(
            MessageHashUtils
                .toEthSignedMessageHash(abi.encodePacked(target))
                .recover(acceptSignature) == tx.origin,
            "invalid accept signature"
        );

        signMapping[target].acceptSignature = acceptSignature;
        signMapping[target].signer = tx.origin;
        signMapping[target].truster = truster;
        signMapping[target].fee = fee;

        return true;
    }

    function declareCotractOwnership(
        address owner,
        address cotractAddress
    ) public {}

    function checkTrust(
        address owner,
        address contAdress,
        address truster
    ) external payable returns (bool) {
        require(signMapping[owner].truster == truster, "truster invalid");
        require(signMapping[contAdress].truster == owner, "owner invalid");

        require(
            signMapping[owner].fee + signMapping[contAdress].fee == msg.value,
            "fee is not enough"
        );
        (bool trusterSent, ) = signerMapping[truster].callAccount.call{
            value: signMapping[contAdress].fee
        }(abi.encodeWithSignature(signerMapping[truster].callMethod));
        require(trusterSent);
        (bool ownerSent, ) = owner.call{value: signMapping[owner].fee}(
            abi.encodeWithSignature(signerMapping[truster].callMethod)
        );
        require(ownerSent);
        return true;
    }
}
