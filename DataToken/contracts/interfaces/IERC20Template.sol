pragma solidity >=0.5.0;

interface IERC20Template {
    function initialize(
        string calldata name,
        string calldata symbol,
        address minter,
        uint256 cap,
        uint256 initialSupply,
        string calldata proof
    ) external returns (bool);

    function mint(address account, uint256 value) external;
    function minter() external view returns(address);    
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function cap() external view returns (uint256);
    function isMinter(address account) external view returns (bool);
    function isInitialized() external view returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);

    // 证据表示数据和token之间的关系
    function proof() external view returns(string memory);

    // 公证处相关接口
    function justice() external view returns(string memory);
    function setJustice(string calldata oneJustice) external;
    function setJusticeInfo(uint256 key, bytes32 value) external;

    // 加入密码学套件，保证一次订单的原子性和防止数据提供方和使用方作弊。
    // 确认数据提供方确实提供数据，数据使用方确实拿到并使用了数据。

    // 一次数据使用订单开始，事务开始，冻结资产。(任务发起的用户)
    function freezeExchange(address userAgency) external returns (uint256);

    // 一次数据使用订单校验，校验是否有冻结资产。（数据提供方的carrier）
    function verifyFreezeExchange(uint256 exchangeId) external view returns (bool);

    // 一次数据使用订单结束，事务结束，信息确认。（任务发起的carrier）
    function commitExchange(uint256 exchangeId) external returns (bool);

    // 回滚交易。（任务发起的carrier）
    function rollbackExchange(uint256 exchangeId) external returns (bool);

    // 一次数据使用订单结算，提交事务，交易结算。（数据提供方的carrier）
    function settleExchange(uint256 exchangeId) external returns (bool);

    // 获取交易状态
    function exchangeState(uint256 exchangeId) external view returns (uint);
}

// 代理花费 lat，任务发起的carrier， 代理用户。
// 用户花费和赚取 token
