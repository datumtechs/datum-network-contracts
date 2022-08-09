// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Credential is Initializable, OwnableUpgradeable{

    // 操作类型
    // signer public key
    uint8 constant SIGNERPUBLICKEY = 0;
    // signature data key
    uint8 constant SIGNATUREDATA = 1;

    // status 不同值表示不同状态
    // -1 表示不存在
    // 0 表示激活状态
    // 1 表示失活状态
    struct CredentialInfo {
        uint256 blockNumber;
        address issuer;
        int8 status;
    }

    mapping(bytes32 => CredentialInfo) private _credentialInfo;
    bytes32[] private _credentialList;

    event CredentialAttributeChange (
        bytes32 indexed credentialHash,
        uint8 fieldKey,
        string fieldValue,
        uint256 blockNumber,
        string  updateTime
    );

    address private _voteAddress;
    function initialize(address voteAddress) public initializer {
        _voteAddress = voteAddress;
    }

    function getAllAuthority(address voteContractAddress) internal view returns (address[] memory) {
        (bool success, bytes memory data) = voteContractAddress.staticcall(abi.encodeWithSignature("getAllAuthority()"));
        require(success, "staticcall allowance failed");

        (address[] memory allAddress, ,) = abi.decode(data,(address[], string[], uint256[]));
        return allAddress;
    }

    function createCredential(bytes32 credentialHash, string memory signerPublicKey, string memory signatureData, string memory updateTime) public returns (bool success){
        address[] memory authorityList = getAllAuthority(_voteAddress);

        bool find= false;
        uint256 authorityLength = authorityList.length;
        for (uint256 i = 0; i < authorityLength; i++){
            if (authorityList[i] == msg.sender){
                find = true;
                break;
            }
        }

        require(find, "invalid msg.sender");

        // record signer public key field change
        emit CredentialAttributeChange(
            credentialHash,
            SIGNERPUBLICKEY,
            signerPublicKey,
            0,
            updateTime
        );

        // record signature data field change
        emit CredentialAttributeChange(
            credentialHash,
            SIGNATUREDATA,
            signatureData,
            0,
            updateTime
        );

        // set credential information
         _credentialInfo[credentialHash] = CredentialInfo({
            blockNumber: block.number,
            issuer: msg.sender,
            status: 0
        });

        _credentialList.push(credentialHash);

        return true;
    }

    function getStatus(bytes32 credentialHash) public view returns (int8){
        int8 result = -1;
        uint256 credentialLength = _credentialList.length;
        for (uint256 i = 0; i < credentialLength; i++){
            if (_credentialList[i] == credentialHash){
                result = _credentialInfo[credentialHash].status;
                break;
            }
        }

        return result;
    }


    function changeStatus(bytes32 credentialHash, int8 status) public{
        bool find = false;
        uint256 credentialLength = _credentialList.length;
        uint256 credentialIndex = 0;
        for (uint256 i = 0; i < credentialLength; i++){
            if (_credentialList[i] == credentialHash){
                find = true;
                credentialIndex = i;
                break;
            }
        }

        require(find, "document does not exist");
        require( _credentialInfo[credentialHash].issuer == msg.sender, "Only the issuer can change the credential status");

        _credentialInfo[credentialHash].status = status;
    }

    function isHashExist(bytes32 credentialHash) public view returns (bool success){
        bool find = false;
        uint256 credentialLength = _credentialList.length;
        for (uint256 i = 0; i < credentialLength; i++){
            if (_credentialList[i] == credentialHash){
                find = true;
                break;
            }
        }

        return find;
    }

    function getLatestBlock(bytes32 credentialHash) public view returns (uint256){
        bool find = false;
        uint256 credentialLength = _credentialList.length;
        for (uint256 i = 0; i < credentialLength; i++){
            if (_credentialList[i] == credentialHash){
                find = true;
                break;
            }
        }

        if(find){
            return _credentialInfo[credentialHash].blockNumber;
        }

        return 0;
    }

}