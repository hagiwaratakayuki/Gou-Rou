// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

//import "hardhat/console.sol";
import {DelegateValidation} from "../auth/DelegateValidation.sol";
import {StrSlice, toSlice} from "@dk1a/solidity-stringutils/src/StrSlice.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
using Strings for address;

// authorise keyword update

string constant PAYMENT = "payment";
string constant DECLARE = "declare";
string constant TRUST = "trust";

//delimiter
string constant _ADDRESS_URI_DELIMITER = unicode"_";

contract SignStorage is DelegateValidation {
    /** Trust */

    struct Trust {
        string format;
        string evidence;
        address[] witnesses;
        bytes signature;
        uint chainsCount;
    }

    mapping(address => Trust) trustIndex;
    mapping(string => uint) trustChainCountMap;
    mapping(string => address) trustChainMap;

    /**
     * Declare
     */
    struct Declare {
        string format;
        string evidence;
        bytes signature;
    }

    constructor(
        address operationValidater,
        address defaultUpdateValidater,
        address paymentValidater,
        address declareValidater,
        address trustVlidater
    ) DelegateValidation(operationValidater) {}

    mapping(uint => Declare) declareMapL;
    uint declaresCount;

    mapping(string => uint) declareIndex;

    function declare(
        string memory uri,
        string memory format,
        string memory evidence,
        bytes memory signature,
        address[] memory witnesses
    ) public {
        _checkPermssionFromMultiAccount(witnesses, DECLARE);

        declareMapL[declaresCount] = Declare(format, evidence, signature);
        StrSlice uriSlice = toSlice(uri);
        for (uint i = 0; i < witnesses.length; i++) {
            address witness;
            witness = witnesses[i];
            StrSlice[] memory slices = new StrSlice[](2);
            string memory key;
            slices[0] = toSlice(witness.toHexString());
            slices[1] = uriSlice;
            key = toSlice(_ADDRESS_URI_DELIMITER).join(slices);
            declareIndex[key] = declaresCount;
        }
        declaresCount++;
    }

    function trust(
        address target,
        string memory format,
        string memory evidence,
        bytes memory signature,
        address[] memory witnesses
    ) public {
        _checkPermssionFromMultiAccount(witnesses, TRUST);
        Trust storage trust = trustIndex[target];
        trust.format = format;
        trust.evidence = evidence;
        trust.signature = signature;
        trust.witnesses = witnesses;
        StrSlice targetSlice = toSlice(target.toHexString());
        uint chainCout = 0;
        for (uint i = 0; i < witnesses.length; i++) {
            address witness = witnesses[i];
            StrSlice witnessSlice = toSlice(witness.toHexString());
            Trust memory witessTrust = trustIndex[witness];

            for (uint j = 0; j < witessTrust.chainsCount; j++) {
                StrSlice chainCoutSlice = toSlice(Strings.toString(chainCout));

                uint witenessChainCout = trustChainCountMap[witenssKey];
                StrSlice chainKeySliceHeader = toSlice(witenssKey);
                for (uint k = 0; k < witenessChainCout; k++) {}
            }
        }
    }

    function _joinPath(
        StrSlice startPath,
        string memory next
    ) returns (string) {
        StrSlice[] memory pathSlices = new StrSlice[](2);

        pathSlices[0] = startPath;
        pathSlices[1] = toSlice(next);
        return toSlice(_ADDRESS_URI_DELIMITER).join(startPath);
    }

    function updateDefaultPayment(
        address validater,
        bool permission
    ) external _checkOperationPermission {
        _updateDefaultPermission(PAYMENT, validater, permission);
    }

    function updateAccountPayment(
        address account,
        address validater,
        uint8 permission
    ) external _checkAccountOperationPermission(account) {
        _updateAccountPermission(PAYMENT, account, validater, permission);
    }

    function updateDefaultDeclareVlidater(
        address validater,
        bool permission
    ) external _checkOperationPermission {
        _updateDefaultPermission(DECLARE, validater, permission);
    }

    function updateAccpuntDeclareValidater(
        address account,
        address validater,
        uint8 permission
    ) external _checkAccountOperationPermission(account) {
        _updateAccountPermission(DECLARE, account, validater, permission);
    }

    function updateDefaultTrustValidater(
        address validater,
        bool permission
    ) external _checkOperationPermission {
        _updateDefaultPermission(TRUST, validater, permission);
    }

    function updateAccountTrustValidater(
        address account,
        address validater,
        uint8 permission
    ) external _checkAccountOperationPermission(account) {
        _updateAccountPermission(TRUST, account, validater, permission);
    }
}
