// SPDX-License-Identifier:AGPL-3.0
pragma solidity ^0.8.24;

contract DelegateValidation {
    constructor(address operationValidater) {
        _operationValidater = operationValidater;
    }

    /** default operation  */
    address _operationValidater;

    function updateOperationValidater(
        address operationValidater
    ) external _checkOperationPermission {
        _operationValidater = operationValidater;
    }

    modifier _checkOperationPermission() {
        require(_operationValidater == msg.sender, "not permited");
        _;
    }
    /**
     * default permissions
     */
    address defaultOperationValidater;

    function _checkDefaultOperationValidater() public view returns (bool) {
        return msg.sender == defaultOperationValidater;
    }

    /** default permssion  */
    mapping(string => mapping(address => bool)) _defaultPermission;

    function _updateDefaultPermission(
        string memory key,
        address validater,
        bool permission
    ) external _checkOperationPermission {
        _defaultPermission[key][validater] = permission;
    }

    function _checkDefaultPermssion(
        string memory key
    ) public view returns (bool) {
        return _defaultPermission[key][msg.sender];
    }

    /**
     * Account permission
     *
     *
     */

    // account operation

    mapping(address => mapping(address => uint8)) _accountOperationValidaters; // 0 undefined 1 allow 2 denay

    function updateAccountOperationValidater(
        address account,
        address operationValidater
    ) external _checkAccountOperationPermission(account) {
        _operationValidater = operationValidater;
    }

    modifier _checkAccountOperationPermission(address account) {
        uint8 accountPermssion = _accountOperationValidaters[account][
            msg.sender
        ];
        require(accountPermssion != 2, "validater denayed");

        require(
            defaultOperationValidater == msg.sender || accountPermssion == 1,
            "not permited"
        );
        _;
    }

    mapping(address => mapping(string => mapping(address => uint8))) _acountPermission; // 0 unset ,1 permit 2 denay

    modifier delegateValidate(address account, string memory key) {
        require(_checkPermission(account, key), "invalid validater");
        _;
    }

    function _updateAccountPermission(
        string memory key,
        address account,
        address validater,
        uint8 permission
    ) external _checkAccountOperationPermission(account) {
        require(
            permission == 1 || permission == 2,
            "invalid permsion valiue. 1 is allow 2 is denay"
        );
        _acountPermission[account][key][validater] = permission;
    }

    function _checkAccountPermission(
        address account,
        string memory key
    ) public view returns (bool, bool) {
        uint8 permission = _acountPermission[account][key][msg.sender];
        bool allow = permission == 1;
        bool denay = permission == 2;
        return (allow, denay);
    }

    modifier isPermited(address account, string memory key) {
        require(_checkPermission(account, key), "permision denayed");
        _;
    }

    function _checkPermission(
        address account,
        string memory key
    ) public view returns (bool) {
        bool allow;
        bool denay;

        (allow, denay) = _checkAccountPermission(account, key);
        if (allow == true) {
            return true;
        }
        if (denay == true) {
            return false;
        }
        return _checkDefaultPermssion(key);
    }
}
