// SPDX-License-Identifier:AGPL-3.0
pragma solidity ^0.8.24;

string constant VALIDATER_CHANGE_VALIDATER = "validater change validater";
string constant DEFAULT_UPDATE_VALIDATER = "default update validater";

contract DelegateValidation {
    mapping(string => address) _defaultOperationPermission;

    mapping(string => mapping(address => bool)) _defaultPermission;
    mapping(address => mapping(string => mapping(address => uint8))) _addressPermission; // 0 unset ,1 permit 2 denay

    constructor(
        address validaterChangeValidater,
        address defaultUpdateValidater
    ) {
        _defaultOperationPermission[
            VALIDATER_CHANGE_VALIDATER
        ] = validaterChangeValidater;
        _defaultOperationPermission[
            DEFAULT_UPDATE_VALIDATER
        ] = defaultUpdateValidater;
    }

    function updateValidaterChangeValidater(address validater) public {
        require(
            _defaultOperationPermission[VALIDATER_CHANGE_VALIDATER] ==
                msg.sender,
            "forbidden"
        );
        _defaultOperationPermission[VALIDATER_CHANGE_VALIDATER] = validater;
    }

    function updateDefaultUpdateValidater(address validater) public {
        require(
            _defaultOperationPermission[VALIDATER_CHANGE_VALIDATER] ==
                msg.sender,
            "forbidden"
        );
        _defaultOperationPermission[DEFAULT_UPDATE_VALIDATER] = validater;
    }

    function _updateDefaultPermission(
        string memory key,
        address validater,
        bool permission
    ) private {
        require(
            _defaultOperationPermission[DEFAULT_UPDATE_VALIDATER] == msg.sender,
            "not permited"
        );
        _defaultPermission[key][validater] = permission;
    }

    function _checkAccountPermssion(
        string memory key,
        address target
    ) private view returns (bool) {
        return _defaultPermission[key][target] == true;
    }

    function _updateAccountPermssion(
        string memory key,
        address account,
        address target,
        uint8 permission
    ) private {
        require(permission == 1 || permission == 2, "invalid");
        _addressPermission[account][key][target] = permission;
    }

    function _checkAccountPermission(
        address account,
        string memory key
    ) private view returns (bool) {
        return _addressPermission[account][key][msg.sender] == 1;
    }
}
