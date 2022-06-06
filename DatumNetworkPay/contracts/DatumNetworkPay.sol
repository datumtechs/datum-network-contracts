// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract DatumNetworkPay is Initializable,OwnableUpgradeable {

    // lat wrapper contarct address
    address private _metisLat;

    /**
     * @dev initialize
     *      Called on contract deployment. Could not be called with zero address parameters.
     * @param metisLat refers to the address of a deployed metisLat contract.
     */
    function initialize(address metisLat) public initializer {
        _metisLat = metisLat;
    }

    // whitelist
    mapping(address => address[]) private _user2Agency;
    address[] private _users;

    function authorize(address userAgency) public returns (bool success){
        return addWhitelist(userAgency);
    }

    /**
     * @dev whitelist
     *      
     *      
     * @param userAddress refers to an user address.
     * @return whitelist quota.
     */
    function whitelist(address userAddress) public view returns (address[] memory){
        address[] memory result;

        for (uint256 i = 0; i < _users.length; i++){
            if (_users[i] == userAddress){
                result =  _user2Agency[userAddress];
                break;
            }
        }

        return result;
    }

    /**
     * @dev Add an address to the whitelist
     *      
     *      
     * @param userAgency Users to be added to the user whitelist.
     * @return success true if the addition is successful, false if it fails.
     */
    function addWhitelist(address userAgency) public returns (bool success){
        bool find = false;
        for (uint256 i = 0; i <  _users.length; i++){
            if (_users[i] == msg.sender){
                find = true;
            }
        }

        if(find){
            uint256 agencyLength = _user2Agency[msg.sender].length;
            bool existAgency = false;
            for (uint256 i = 0; i < agencyLength; i++){
                if (_user2Agency[msg.sender][i] == userAgency){
                    existAgency = true;
                }
            }

            if(!existAgency){
                _user2Agency[msg.sender].push(userAgency);
            }
        } else {
            _users.push(msg.sender);
            _user2Agency[msg.sender].push(userAgency);
        }

        return true;
    }

    /**
     * @dev Remove an address from the whitelist
     *      
     *      
     * @param userAgency the address in the whitelist to be removed.
     * @return success true true if the deletion is successful, false if the deletion fails.
     */
    function deleteWhitelist(address userAgency) public returns (bool success){
        bool find = false;
        uint256 userIndex = 0;
        uint256 userLength = _users.length;
        for (uint256 i = 0; i < userLength; i++){
            if (_users[i] == msg.sender){
                find = true;
                userIndex = i;
            }
        }
        require(find, "invalid user");

        bool existAgency = false;
        uint256 agencyIndex = 0;
        uint256 agencyLength = _user2Agency[msg.sender].length;
        for(uint256 i = 0; i < agencyLength; i++){
            if (_user2Agency[msg.sender][i] == userAgency){
                existAgency = true;
                agencyIndex = i;
            }
        }
        require(existAgency, "invalid agency");

        if(agencyLength > 1){
            for(uint256 i = agencyIndex; i < agencyLength - 1; i++){
                _user2Agency[msg.sender][i] = _user2Agency[msg.sender][i+1];
            }

            delete _user2Agency[msg.sender][agencyLength-1];
            _user2Agency[msg.sender].pop();
        } else {
            for(uint256 i = userIndex; i < userLength - 1; i++){
                _users[i] = _users[i+1];
            }

            delete _users[userLength-1];
            _users.pop();

            delete _user2Agency[msg.sender];
        }

        return true;
    }

    // task information
    // constant int8 private NOTEXIST = -1;
    // constant int8 private BEGIN = 0;
    // constant int8 private PREPAY = 1;
    // constant int8 private SETTLE = 2;
    // constant int8 private END = 3;

    struct TaskInfo {
        address userAddress;
        address agencyAddress;
        uint256 fee;
        address[] tokenAddressList;
        uint256[] tokenValueList;
        int8 state;
    }

    mapping(uint256 => TaskInfo) private _taskInfo;
    uint256[] private _taskList;

    event PrepayEvent(
        uint256 indexed taskId,
        address indexed user,
        address indexed userAgency,
        uint256 fee,
        address[] tokenAddressList,
        uint256[] tokenValueList
    );

    event SettleEvent(
        uint256 indexed taskId,
        address indexed user,
        address indexed userAgency,
        uint256 Agencyfee,
        uint256 refundOrAdd,
        address[] tokenAddressList,
        uint256[] tokenValueList
    );

    function allowance(address tokenAddress, address owner, address spender) internal view returns (uint256 remaining) {
        (bool success, bytes memory data) = tokenAddress.staticcall(abi.encodeWithSignature("allowance(address,address)", owner, spender));
        require(success, "staticcall allowance failed");

        uint256 callerUintResult = abi.decode(data,(uint256));
        return callerUintResult;
    }

    // datatoken usage fee
    function prepay(uint256 taskId, address user, uint256 fee, address[] memory tokenAddressList, uint256[] memory tokenValueList)  public returns (bool success){
        // check One-to-one correspondence between the address list and the value list
        require(tokenAddressList.length == tokenValueList.length, "invalid token information");

        // Check the whitelist
        bool exist = false;
        uint256 length = _users.length;
        for (uint256 i = 0; i < length; i++){
            if (_users[i] == user){
                exist = true;
            }
        }
        require(exist, "user's whitelist does not exist");

        exist = false;
        length = _user2Agency[user].length;
        for (uint256 i = 0; i < length; i++){
            if (_user2Agency[user][i] == msg.sender){
                exist = true;
            }
        }
        require(exist, "agency is not authorized");

        // Check for duplicate payments
        exist = false;
        length = _taskList.length;
        for (uint256 i = 0; i < length; i++){
            if (_taskList[i] == taskId){
                exist = true;
            }
        }
        require(!exist, "task id already exists");

        // verify uer approve to DatumNetworkPay lat amount
        uint256 value = allowance(_metisLat, user, address(this));
        require(value >= fee, 'wlat insufficient balance');

        // verify user approve to DatumNetworkPay data token amount
        length = tokenAddressList.length;
        for (uint256 i = 0; i < length; i++){
            value = allowance(tokenAddressList[i], user, address(this));
            require(value >= fee, 'data token insufficient balance');
        }

        // transferFrom lat from user to DatumNetworkPay
        bool transferFromSuccess = false;
        bytes memory transferFromData;
        bool transferFromResult = false;
        (transferFromSuccess, transferFromData) = _metisLat.call(abi.encodeWithSignature(
            "transferFrom(address,address,uint256)", user, address(this), fee));
        require(transferFromSuccess, "call transferFrom failed");

        transferFromResult =  abi.decode(transferFromData,(bool));
        require(transferFromResult, "The return of transferfrom is failure");

        // transferFrom data token from user to DatumNetworkPay
        for (uint256 i = 0; i < length; i++){
            (transferFromSuccess, transferFromData) = tokenAddressList[i].call(
                abi.encodeWithSignature("transferFrom(address,address,uint256)", user, address(this), tokenValueList[i])
            );
            require(transferFromSuccess, "call transferFrom failed");

            transferFromResult =  abi.decode(transferFromData,(bool));
            require(transferFromResult, "The return of transferfrom is failure");
        }

        // create task information
        _taskInfo[taskId] = TaskInfo({
            userAddress: user,
            agencyAddress: msg.sender,
            fee: fee,
            tokenAddressList: tokenAddressList,
            tokenValueList: tokenValueList,
            state: 1
        });

        _taskList.push(taskId);

        emit PrepayEvent(
            taskId,
            user,
            msg.sender,
            fee,
            tokenAddressList,
            tokenValueList
        );

        return true;
    }

    function settle(uint256 taskId, uint256 fee)  public returns (bool success){
        uint256 taskLength = _taskList.length;
        bool find =  false;
        uint256 taskIndex = 0;
        for (uint256 i = 0; i < taskLength; i++){
            if (_taskList[i] == taskId){
                find = true;
                taskIndex = i;
            }
        }
        
        require(find, "invalid task id");
        require(msg.sender == _taskInfo[taskId].agencyAddress, 'Only user agent can do this');
        require(_taskInfo[taskId].state == 1, "prepay not completed or repeat settle");

        // transfer lat fee from DatumNetworkPay to user or transferFrom lat from user to DatumNetworkPay
        bool transferSuccess = false;
        bytes memory transferData;
        uint256 refundOrAddAmount = 0;
        if(_taskInfo[taskId].fee > fee){
            refundOrAddAmount =  _taskInfo[taskId].fee-fee;
            (transferSuccess, transferData) = _metisLat.call(abi.encodeWithSignature(
                "transfer(address,uint256)", _taskInfo[taskId].userAddress, refundOrAddAmount));
            require(transferSuccess, "call transfer failed");
            require(abi.decode(transferData,(bool)), "The return of transfer is failure");  
        }else if(_taskInfo[taskId].fee < fee){
            refundOrAddAmount =  fee - _taskInfo[taskId].fee;
            (transferSuccess, transferData) = _metisLat.call(abi.encodeWithSignature(
            "transferFrom(address,address,uint256)", _taskInfo[taskId].userAddress, address(this), refundOrAddAmount));
            require(transferSuccess, "call transferFrom failed");
            require(abi.decode(transferData,(bool)), "The return of transfer is failure");
        }

        // transfer lat fee from DatumNetworkPay to agency
        (transferSuccess, transferData) = _metisLat.call(abi.encodeWithSignature(
            "transfer(address,uint256)", _taskInfo[taskId].agencyAddress, fee));
    
        require(transferSuccess, "call transfer failed");
        require(abi.decode(transferData,(bool)), "The return of transfer is failure");


        // transfer data token from DatumNetworkPay to minter
        address oneMinter;
        address [] memory tokenAddressList = _taskInfo[taskId].tokenAddressList;
        uint256 [] memory tokenValueList =  _taskInfo[taskId].tokenValueList;
        uint256 length = tokenAddressList.length;
        for (uint256 i = 0; i < length; i++){
            (transferSuccess, transferData) =  tokenAddressList[i].staticcall(abi.encodeWithSignature("minter()"));
            require(transferSuccess, "call minter failed");

            oneMinter = abi.decode(transferData,(address));

            (transferSuccess, transferData) = tokenAddressList[i].call(abi.encodeWithSignature(
                "transfer(address,uint256)", oneMinter, tokenValueList[i]));        
            require(transferSuccess, "call transfer failed");
            require(abi.decode(transferData,(bool)), "The return of transfer is failure");
        }

        emit SettleEvent(
            taskId,
            _taskInfo[taskId].userAddress,
            _taskInfo[taskId].agencyAddress,
            fee,
            refundOrAddAmount,
            tokenAddressList,
            tokenValueList
        );

        for (uint i = taskIndex; i < taskLength - 1; i++) {
            _taskList[i] = _taskList[i+1];
        }

        delete _taskList[taskLength - 1];
        _taskList.pop();

        delete _taskInfo[taskId];

        return true;
    }

    function getTaskInfo(uint256 taskId) public view returns (
        address,
        address,
        uint256,
        address[] memory,
        uint256[] memory,
        int8
    ) {
        uint256 length = _taskList.length;
        bool find = false;
        for (uint256 i = 0; i < length; i++){
            if (_taskList[i] == taskId){
                find = true;
            }
        }

        if(!find){
            address[] memory invalidAddress = new address[](1);
            invalidAddress[0] = address(0);
            uint256[] memory invalidValue = new uint256[](1);
            invalidValue[0] = uint256(0);
            return (
                address(0),
                address(0),
                uint256(0),
                invalidAddress,
                invalidValue,
                int8(-1)
            );
        }

        return (
            _taskInfo[taskId].userAddress,
            _taskInfo[taskId].agencyAddress,
            _taskInfo[taskId].fee,
            _taskInfo[taskId].tokenAddressList,
            _taskInfo[taskId].tokenValueList,
            _taskInfo[taskId].state
        );
    }

    function taskState(uint256 taskId) external view returns (int8){
        int8 state;
        uint256 length = _taskList.length;
        bool find = false;
        for (uint256 i = 0; i < length; i++){
            if (_taskList[i] == taskId){
                find = true;
            }
        }

        if(!find){
            state = -1;
        } else {
            state = _taskInfo[taskId].state;
        }

        return state;
    }
}
