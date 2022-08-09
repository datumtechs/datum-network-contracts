// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Did is Initializable, OwnableUpgradeable{

    // 操作类型
    // create key
    uint8 constant CREATE = 0;
    // public key key
    uint8 constant PUBLICKEY = 1;
    // service key
    uint8 constant SERVICE = 2;

    // status 不同值表示不同状态
    // -1 表示不存在
    // 0 表示激活状态
    // 1 表示失活状态
    struct DocumentInfo {
        uint256 blockNumber;
        int8 status;
    }

    mapping(address => DocumentInfo) private _documentInfo;
    address[] private _documentList;

    event DIDAttributeChange (
        address indexed identity,
        uint8 fieldKey,
        string fieldValue,
        uint256 blockNumber,
        string  updateTime
    );

    function createDid(
        string memory createTime, 
        string memory publicKey, 
        string memory updateTime
    ) public returns (bool success){
        bool find = false;
        uint256 documentLength = _documentList.length;
        for (uint256 i = 0; i < documentLength; i++){
            if (_documentList[i] == msg.sender){
                find = true;
                break;
            }
        }

        require(!find, "document already exists");

        // record create time field change
        emit DIDAttributeChange(
            msg.sender,
            CREATE,
            createTime,
            0,
            updateTime
        );

        // record public key field change
        emit DIDAttributeChange(
            msg.sender,
            PUBLICKEY,
            publicKey,
            0,
            updateTime
        );

        // set document information
         _documentInfo[msg.sender] = DocumentInfo({
            blockNumber: block.number,
            status: 0
        });

        _documentList.push(msg.sender);

        return true;
    }

    function setAttribute(
        uint8 fieldKey, 
        string memory fieldValue, 
        string memory updateTime
    ) public returns (bool success){
        bool find = false;
        uint256 documentLength = _documentList.length;
        for (uint256 i = 0; i < documentLength; i++){
            if (_documentList[i] == msg.sender){
                find = true;
                break;
            }
        }

        require(find, "document does not exist");

        emit DIDAttributeChange(
            msg.sender,
            fieldKey,
            fieldValue,
            _documentInfo[msg.sender].blockNumber,
            updateTime
        );

        _documentInfo[msg.sender].blockNumber = block.number;

        return true;
    }

    function getStatus(address identify) public view returns (int8){
        int8 result = -1;
        uint256 documentLength = _documentList.length;
        for (uint256 i = 0; i < documentLength; i++){
            if (_documentList[i] == identify){
                result = _documentInfo[identify].status;
                break;
            }
        }

        return result;
    }


    function changeStatus(int8 status) public{
        bool find = false;
        uint256 documentLength = _documentList.length;
        for (uint256 i = 0; i < documentLength; i++){
            if (_documentList[i] == msg.sender){
                find = true;
                break;
            }
        }

        require(find, "document does not exist");

        _documentInfo[msg.sender].status = status;
    }

    function isIdentityExist(address identify) public view returns (bool success){
        bool find = false;
        uint256 documentLength = _documentList.length;
        for (uint256 i = 0; i < documentLength; i++){
            if (_documentList[i] == identify){
                find = true;
                break;
            }
        }

        return find;
    }

    function getLatestBlock(address identify) public view returns (uint256){
        uint256 result = 0;
        uint256 documentLength = _documentList.length;
        for (uint256 i = 0; i < documentLength; i++){
            if (_documentList[i] == identify){
                result = _documentInfo[identify].blockNumber;
                break;
            }
        }

        return result;
    }

}