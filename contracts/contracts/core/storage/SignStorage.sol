// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "hardhat/console.sol";
import {DelegateValidation} from "../auth/DelegateValidation.sol";

// update paycheck sign
contract SignStorage is DelegateValidation {
    using ECDSA for bytes32;

    constructor(address defaultOperater) DelegateValidation(defaultOperater) {}

    struct Signer {
        address signAccount;
    }
    struct SignOld {
        bytes acceptSignature; // ECDSA sign for target account
        bytes requstSignature;
        address signer;
        address truster;
        address payChecker;
        uint fee; //wei
    }

    uint payCheckerCount;

    struct Sign {
        string data;
        bytes signedMesage;
        bytes signatuter;
    }
    struct Signs {
        string format;
        string evidence;
        mapping(address => Sign) signs;
    }
    mapping(uint => Signs) signsMapL;
    uint signsCount;

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
}
