// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "hardhat/console.sol";

contract Signs {
    using ECDSA for bytes32;

    struct Signer {
        address signAccount;
        string callMethod;
        address callAccount;
    }
    struct Sign {
        bytes signature; // ECDSA sign for target account
        address signer;
        address truster;
        address payChecker;
        uint fee; //wei
    }

    uint payCheckerCount;
    mapping(address => uint) address2PayCheckerId;

    mapping(address => Signer) signerMapping;
    mapping(address => Sign) signMapping;

    function insertOrUpdateSigner(
        address signAccount,
        string memory callMethod,
        address callAccount
    ) public {
        require(msg.sender == tx.origin, "need update call directry");
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
        bytes memory signature,
        address target,
        address truster,
        uint fee
    ) public returns (bool) {
        require(
            signerMapping[truster].signAccount == tx.origin,
            "truster or signer is invalid"
        );
        bytes memory bytesTarget = abi.encodePacked(target);

        require(
            MessageHashUtils.toEthSignedMessageHash(bytesTarget).recover(
                signature
            ) == tx.origin,
            "invalid signature"
        );

        signMapping[target].signature = signature;
        signMapping[target].signer = tx.origin;
        signMapping[target].truster = truster;
        signMapping[target].fee = fee;

        return true;
    }

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
