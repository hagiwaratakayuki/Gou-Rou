// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;


//import "hardhat/console.sol";
import {DelegateValidation} from "../auth/DelegateValidation.sol";
import {StrSlice, toSlice} from "@dk1a/solidity-stringutils/src/StrSlice.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
using Strings for address;

// authorise keyword update

string constant PAYMENT = "payment";
string constant SIGN = "sign";

//delimiter
string constant _ADDRESS_URI_DELIMITER = unicode"_";

contract SignStorage is DelegateValidation {
    struct TrustChain {
        uint length;
        mapping(uint => address) iterater;
        mapping(address => bool) index;   
    }
    struct  Trust{
        TrustChain chain;
        string format;
        bytes sign;        
    }

    struct Declare {
        string format;
        string evidence;
        bytes signature;
    }

    constructor(
        address validaterChangeValidater,
        address defaultUpdateValidater,
        address paymentValidater,
        address signValidater
    ) DelegateValidation(validaterChangeValidater, defaultUpdateValidater) {
        
        _updateDefaultPermission(PAYMENT, paymentValidater, true);
        _updateDefaultPermission
    }

   

    mapping(uint => Declare) declareMapL;
    uint declaresCount;

    mapping(string => uint) declareIndex;

    function sign(
        string memory uri,
        string memory format,
        string memory evidence,
        bytes memory signature,
        address[] memory singners
    ) public {
        bool isValid;
        isValid = super._checkDefaultPermssion(SIGN);
        if (isValid == false) {
            for (uint i = 0; i < singners.length; ) {
                address signer;
                signer = singners[i];
                isValid =
                    isValid ||
                    super._checkAccountPermission(signer, SIGN);
                if (isValid == true) {
                    break;
                }
                unchecked {
                    i++;
                }
            }
        }
        require(isValid, "vealidater does not authoraised");

        declareMapL[declaresCount] = Declare(format, evidence, signature);
        StrSlice uriSlice = toSlice(uri);
        for (uint i = 0; i < singners.length; i++) {
            address signer;
            signer = singners[i];
            StrSlice[] memory slices = new StrSlice[](2);
            string memory key;
            slices[0] = toSlice(signer.toHexString());
            slices[1] = uriSlice;
            key = toSlice(_ADDRESS_URI_DELIMITER).join(slices);
            declareIndex[key] = declaresCount;
        }
        declaresCount++;
    }
}
