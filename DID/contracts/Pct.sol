// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Pct is Initializable, OwnableUpgradeable{

    uint256 constant AUTHORITY_ISSUER_START_ID = 1000; 

    struct PctInfo {
        address issuer;
        string jsonSchema;
        bytes extra;
    }

    event RegisterPct(
        uint256 indexed pctId,
        address indexed issuer,
        string jsonSchema,
        bytes extra
    );

    address private _voteAddress;

    uint256 private _currentPctId;
    mapping(uint256 => PctInfo) private _pctInfo;

    function initialize(address voteAddress) public initializer {
        _voteAddress = voteAddress;
        _currentPctId = AUTHORITY_ISSUER_START_ID;
    }

    function getAllAuthority(address voteContractAddress) internal view returns (address[] memory) {
        (bool success, bytes memory data) = voteContractAddress.staticcall(abi.encodeWithSignature("getAllAuthority()"));
        require(success, "staticcall allowance failed");

        (address[] memory allAddress, ,) = abi.decode(data,(address[], string[], uint256[]));
        return allAddress;
    }

    function registerPct(string memory jsonSchema, bytes memory extra) public returns (uint256 pctId){
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

        _pctInfo[_currentPctId] = PctInfo({
            issuer: msg.sender,
            jsonSchema: jsonSchema,
            extra: extra
        });

        emit RegisterPct(
            _currentPctId,
            msg.sender,
            jsonSchema,
            extra
        );

        _currentPctId = _currentPctId + 1;
        return _currentPctId - 1;
    }


    function getNextPctId() public view returns (uint256){
        return _currentPctId;
    }

    function getPctInfo(uint256 pctId) public view returns (address, string memory, bytes memory){
        return (
            _pctInfo[pctId].issuer,
            _pctInfo[pctId].jsonSchema,
            _pctInfo[pctId].extra
        );
    }
}