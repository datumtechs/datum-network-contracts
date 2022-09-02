// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// 只有 authority 才可以发起提案（增加成员，踢出成员，主动退出），注册 Credential claim template，签发证书。
// authority 委员会采用去中心化治理的方法，决定是由成员投票完成。
contract VoteV2 is Initializable, OwnableUpgradeable{

    function initialize(address adminAddress, string memory serviceUrl) public initializer {
        _proposalId = 0;

        // 设置 _authorityList 列表的第一个元素为 admin
        AuthorityInfo memory newAuthority = AuthorityInfo(adminAddress, serviceUrl, block.timestamp);
        _authorityList.push(newAuthority);

        emit AuthorityAdd(
            adminAddress,
            serviceUrl,
            block.timestamp
        );

        // 增加成员和踢出成员开始投票间隔是1天
        _intervalBeginVote = 24 * 60 * 60;

        // 增加成员和踢出成员投票时长是 1 周
        _intervalVote = 7 * 24 * 60 * 60;

        // 主动退出生效时长是 12 小时
        _intervalQuit = 12 * 60 * 60;
    }

    // Authority 列表
    struct AuthorityInfo{
        address addr;
        string serviceUrl;
        uint256 joinTime;
    }

    event AuthorityDelete(
        address addr,
        string serviceUrl,
        uint256 joinTime
    );

    event AuthorityAdd(
        address addr,
        string serviceUrl,
        uint256 joinTime
    );

    AuthorityInfo[] private _authorityList;

    // 提案的类型
    uint8 constant private ADD_AUTHORITY= 1;
    uint8 constant private KICK_OUT_AUTHORITY= 2;
    uint8 constant private AUTO_QUIT_AUTHORITY= 3;

    // 这些地方要可以进行动态设置
    // 发起提案到开始投票的区块间隔
    uint256  private _intervalBeginVote;

    // 开始投票到结束投票的区块间隔，左右都是闭的，比如[7000, 7500]
    uint256  private _intervalVote;

    // 开始提出退出申请到申请生效的块高
    uint256  private _intervalQuit;

    function getInterval(uint8 flag) public view returns (uint256) {
        if(0 != (flag & 0x01)){
           return  _intervalBeginVote;
        }

        if(0 != (flag & 0x02)){
            return _intervalVote;
        }

        if(0 != (flag & 0x04)){
            return _intervalQuit;
        }

        return 0;
    }

    function setInterval(uint8 flag, uint256 interval) public {
        require(msg.sender == _authorityList[0].addr, "Only admin can do this");
        if(0 != (flag & 0x01)){
           _intervalBeginVote = interval;
        }

        if(0 != (flag & 0x02)){
            _intervalVote = interval;
        }

        if(0 != (flag & 0x04)){
            _intervalQuit = interval;
        }
    }

    struct Proposal {
        uint8 proposalType;
        string proposalUrl;
        address submitter;
        address candidate;
        string candidateServiceUrl;
        uint256 submitBlockNo;
        address[] voters;
    }

    uint256 private _proposalId;
	uint256[] private _proposalIdList;
	
    mapping(uint256 => Proposal) private _proposalMap;
    

    event NewProposal(
        uint256 indexed proposalId,
        uint8 indexed proposalType,
        address indexed submitter,
        address candidate,
        string candidateServiceUrl,
        string proposalUrl,
        uint256 submitBlockNo
    );

    event WithdrawProposal(
        uint256 indexed proposalId,
        uint256 blockNo
    );

    event VoteProposal(
        uint256 indexed proposalId,
        address voter
    );

    event ProposalResult(
        uint256 indexed proposalId,
        bool result
    );

    // 提交提案
    function submitProposal(uint8 proposalType, string memory proposalUrl, address candidate, string memory candidateServiceUrl) public{
        // 判断提案类型是否有效
        require(proposalType == ADD_AUTHORITY || proposalType == KICK_OUT_AUTHORITY || proposalType == AUTO_QUIT_AUTHORITY,  "Invalid Proposal type");

        // 判断 msg.sender 是否有效
        bool findSubmitter = false;
        uint256 authorityLength = _authorityList.length;
        for (uint256 i = 0; i < authorityLength; i++){
            if (_authorityList[i].addr == msg.sender){
                findSubmitter = true;
                break;
            }
        }

        require(findSubmitter, "invalid msg.sender");

        // 判断 candidate 是否有效
        bool findCandidate = false; 
        for (uint256 i = 0; i < authorityLength; i++){
            if (_authorityList[i].addr == candidate){
                findCandidate = true;
                break;
            }
        }     

        if(ADD_AUTHORITY == proposalType){
            require(!findCandidate, "candidate is already in the authority list");
        } else {
            require(findCandidate, "candidate is not in the authority list");
            require(candidate != _authorityList[0].addr, "admin is the project party and cannot withdraw from the committee");
        }

        // 不能有重复提交同一个成员的提案
        uint256 proposalIdLength = _proposalIdList.length;
        for (uint256 i = 0; i < proposalIdLength; i++){
            require(_proposalMap[_proposalIdList[i]].candidate != candidate, "candidate is already in one open proposal");
        }
    
        // 删除或者退出的不能有未结束的提案
        if(proposalType == KICK_OUT_AUTHORITY || proposalType == AUTO_QUIT_AUTHORITY){
            for (uint256 i = 0; i < proposalIdLength; i++){   
                require(_proposalMap[_proposalIdList[i]].submitter != candidate, "candidate has open proposals.");
            }
        }

        // 增加一个新提案      
        _proposalMap[_proposalId] = Proposal({
            proposalType: proposalType,
            proposalUrl: proposalUrl,
            submitter: msg.sender,
            candidate: candidate,
            candidateServiceUrl: candidateServiceUrl,
            submitBlockNo: block.number,
            voters: new address[](0)
        });

        _proposalIdList.push(_proposalId);

        emit NewProposal(
            _proposalId,
            proposalType,
            msg.sender,
            candidate,
            candidateServiceUrl,
            proposalUrl,
            block.number
        );

        _proposalId = _proposalId + 1;
    }

    // 撤销提案
    function withdrawProposal(uint256 proposalId)  public{
        // 判断提案 ID 是否有效
        bool find = false;
        uint256 proposalIndex = 0;
        uint256 proposalIdLength = _proposalIdList.length;
        for (uint256 i = 0; i < proposalIdLength; i++){
            if (_proposalIdList[i] == proposalId){
                find = true;
                proposalIndex = i;
                break;
            }
        }

        require(find, "invalid proposal id");
        require(_proposalMap[proposalId].submitter == msg.sender, "invalid msg.sender");
        if(_proposalMap[proposalId].proposalType == AUTO_QUIT_AUTHORITY){
            require(block.number < _proposalMap[proposalId].submitBlockNo + _intervalQuit, "proposal is effective");
        }else{
            require(block.number < _proposalMap[proposalId].submitBlockNo + _intervalBeginVote, "Voting has already started and cannot be withdrawed");
        }

        // 删除提案
        for(uint256 i = proposalIndex; i < proposalIdLength - 1; i++){
            _proposalIdList[i] = _proposalIdList[i+1];
        }

        delete _proposalIdList[proposalIdLength-1];
        _proposalIdList.pop();

        delete _proposalMap[proposalId];

        emit WithdrawProposal(
            proposalId,
            block.number
        );
    }

    // 投票提案
    function voteProposal(uint256 proposalId)  public{
        // 判断提案 ID 是否有效
        bool find = false;
        uint256 proposaIdLength = _proposalIdList.length;
        for (uint256 i = 0; i < proposaIdLength; i++){
            if (_proposalIdList[i] == proposalId){
                find = true;
                break;
            }
        }

        require(find, "invalid proposal id");

        // 自动退出不需要投票
        require(AUTO_QUIT_AUTHORITY != _proposalMap[proposalId].proposalType, "Automatic exit does not require a vote");

        // 判断投票人是否有效
        bool isValidVoter = false;
        uint256 authorityLength = _authorityList.length;
        for (uint256 i = 0; i < authorityLength; i++){
            if (_authorityList[i].addr == msg.sender){
                isValidVoter = true;
                break;
            }
        }

        require(isValidVoter, "invalid msg.sender");

        // 在投票有效期内进行投票
        require(block.number >= _proposalMap[proposalId].submitBlockNo + _intervalBeginVote && 
            block.number <= _proposalMap[proposalId].submitBlockNo + _intervalBeginVote + _intervalVote, 
            "Voting should be within the specified period");

        // 不能重复投票
        bool isVoted = false;
        uint256 voterLength = _proposalMap[proposalId].voters.length;
        for (uint256 i = 0; i < voterLength; i++){
            if (_proposalMap[proposalId].voters[i] == msg.sender){
                isVoted = true;
                break;
            }
        }

        require(!isVoted, "Can't vote again");

        // 投票
        _proposalMap[proposalId].voters.push(msg.sender);

        emit VoteProposal(
            proposalId,
            msg.sender
        );
    }

    // 根据投票结果生效提案
    function effectProposal(uint256 proposalId)  public{
        // 判断提案 ID 是否有效
        bool find = false;
        uint256 proposalIndex = 0;
        uint256 proposaIdLength = _proposalIdList.length;
        for (uint256 i = 0; i < proposaIdLength; i++){
            if (_proposalIdList[i] == proposalId){
                find = true;
                proposalIndex = i;
                break;
            }
        }

        require(find, "invalid proposal id");
        require(_proposalMap[proposalId].submitter == msg.sender, "invalid msg.sender");

        // 如果是自动退出，不用投票和统计投票数量
        bool voteResult = false;
        uint256 authorityLength = _authorityList.length;
        if(AUTO_QUIT_AUTHORITY == _proposalMap[proposalId].proposalType){
            require(block.number >= _proposalMap[proposalId].submitBlockNo + _intervalQuit, "Not reaching the effective period");
            uint256 authorityIndex = 0;
            bool findAuthority = false;
            for (uint256 i = 0; i < authorityLength; i++){
                if (_authorityList[i].addr == _proposalMap[proposalId].candidate){
                    findAuthority = true;
                    authorityIndex = i;
                    break;
                }
            }
            
            require(findAuthority, "invalid candidate");

            emit AuthorityDelete(
                _authorityList[authorityIndex].addr,
                _authorityList[authorityIndex].serviceUrl,
                _authorityList[authorityIndex].joinTime
            );

            for(uint256 i = authorityIndex; i < authorityLength - 1; i++){
                _authorityList[i] = _authorityList[i+1];
            }

            delete _authorityList[authorityLength-1];
            _authorityList.pop();

            // 提案成功生效
            voteResult = true;
        } else{
            // 申请加入和申请踢出需要统计票数
            require(block.number > _proposalMap[proposalId].submitBlockNo + _intervalBeginVote + _intervalVote, "Voting has not ended");

            // 统计结果
            uint256 voterLength = _proposalMap[proposalId].voters.length;
        
            // 投票超过 66.6% 才算通过
            uint256 waterLevel = (authorityLength * 2) / 3;
            voteResult = voterLength >= waterLevel;

            // 根据结果处理 authority 列表
            if(voteResult){
                if(ADD_AUTHORITY == _proposalMap[proposalId].proposalType){
                    AuthorityInfo memory newAuthority = AuthorityInfo(_proposalMap[proposalId].candidate, _proposalMap[proposalId].candidateServiceUrl, block.timestamp);
                _authorityList.push(newAuthority);

                    emit AuthorityAdd(
                        _proposalMap[proposalId].candidate,
                        _proposalMap[proposalId].candidateServiceUrl,
                        block.timestamp
                    );
                } else {
                    uint256 authorityIndex = 0;
                    bool findAuthority = false;
                    for (uint256 i = 0; i < authorityLength; i++){
                        if (_authorityList[i].addr == _proposalMap[proposalId].candidate){
                            findAuthority = true;
                            authorityIndex = i;
                            break;
                        }
                    }
                    
                    require(findAuthority, "invalid candidate");

                    emit AuthorityDelete(
                        _authorityList[authorityIndex].addr,
                        _authorityList[authorityIndex].serviceUrl,
                        _authorityList[authorityIndex].joinTime
                    );

                    for(uint256 i = authorityIndex; i < authorityLength - 1; i++){
                        _authorityList[i] = _authorityList[i+1];
                    }

                    delete _authorityList[authorityLength-1];
                    _authorityList.pop();
                }
            }
        }

        // 删除提案信息
        for(uint256 i = proposalIndex; i < proposaIdLength - 1; i++){
            _proposalIdList[i] = _proposalIdList[i+1];
        }

        delete _proposalIdList[proposaIdLength-1];
        _proposalIdList.pop();

        delete _proposalMap[proposalId];

        // 发送事件
        emit ProposalResult(
            proposalId,
            voteResult
        );
    }

    // 设置管理员
    function setAdmin(address adminAddress, string memory serviceUrl) public{
        require(_authorityList.length > 0, "Contract not initialized");
        require(_authorityList[0].addr == msg.sender, "Only admin has permission to change admin");

        _authorityList[0].addr = adminAddress;
        _authorityList[0].serviceUrl = serviceUrl;
        _authorityList[0].joinTime = block.timestamp;
    }

    // 获取管理员
    function getAdmin() public view returns (address, string memory, uint256){
        return (
            _authorityList[0].addr,
            _authorityList[0].serviceUrl, 
            _authorityList[0].joinTime
        );
    }

    // 获取所有的 authority 列表
    function getAllAuthority() public view returns (address[] memory, string[] memory, uint256[] memory){
        uint256 authorityLength = _authorityList.length;
        address[] memory allAddress = new address[](authorityLength);
        string[] memory allUrl = new string[](authorityLength);
        uint256[] memory allJoinTime = new uint256[](authorityLength);
        for (uint256 i = 0; i < authorityLength; i++){
            allAddress[i] = _authorityList[i].addr;
            allUrl[i] = _authorityList[i].serviceUrl;
            allJoinTime[i] = _authorityList[i].joinTime;
        }

        return (
            allAddress,
            allUrl,
            allJoinTime
        );
    }

    // 获取所有未结束投票的提案
    function getAllProposalId() public view returns (uint256[] memory){
        return _proposalIdList;
    }

	// 获取提案id
    function getProposalId(uint256 blockNo)  public view returns (uint256[] memory){
        uint256 proposalIdLength = _proposalIdList.length;
        
        uint256 realLength = 0;
        for (uint256 i = 0; i < proposalIdLength; i++){
            if (_proposalMap[_proposalIdList[i]].submitBlockNo >= blockNo){
                realLength++;
            }
        }

        uint256[] memory result = new uint256[](realLength);

        realLength = 0;
        for (uint256 i = 0; i < proposalIdLength; i++){
            if (_proposalMap[_proposalIdList[i]].submitBlockNo >= blockNo){
                result[realLength] = _proposalIdList[i];
                realLength++;
            }
        }

        return result;
    }
	
    // 获取提案详情
    function getProposal(uint256 proposalId)  public view returns (uint8,
        string memory,
        address,
		string memory,
        address,
        uint256,
        address[] memory){
        return (
            _proposalMap[proposalId].proposalType,
            _proposalMap[proposalId].proposalUrl,           
            _proposalMap[proposalId].candidate,
			_proposalMap[proposalId].candidateServiceUrl,
			_proposalMap[proposalId].submitter,
            _proposalMap[proposalId].submitBlockNo,
            _proposalMap[proposalId].voters
        );
    }

}
