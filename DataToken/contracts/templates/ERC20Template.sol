// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

pragma solidity ^0.8.0;

import '../interfaces/IERC20Template.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

/**
* @title ERC20Template
*  
* @dev ERC20Template is an ERC20 compliant token template
*      Used by the factory contract as a bytecode reference to 
*      deploy new DataTokens.
*/
contract ERC20Template is IERC20Template, ERC20("Template", "TemplateSymbol") {
    string  private _name;
    string  private _symbol;
    string  private _proof;
    uint256 private _cap;
    uint256 private _initial;
    uint8 private constant _decimals = 18;
    bool    private initialized = false;
    address private _minter;
    string  private _justice;

    modifier onlyNotInitialized() {
        require(
            !initialized,
            'ERC20Template: token instance already initialized'
        );
        _;
    }
    
    modifier onlyMinter() {
        require(
            msg.sender == _minter,
            'ERC20Template: invalid minter' 
        );
        _;
    }

    event SetJusticeInfo(
        uint256 key,
        bytes32 value
    );
    
    /**
     * @dev initialize
     *      Called prior contract initialization (e.g creating new DataToken instance)
     *      Calls private _initialize function. Only if contract is not initialized.
     * @param tokenName refers to a new DataToken name
     * @param tokenSymbol refers to a nea DataToken symbol
     * @param minterAddress refers to an address that has minter rights
     * @param tokenCap the total ERC20 cap
     * @param initialSupply the initial ERC20 supply
     * @param tokenProof proof represents the relationship between data and token
     */
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        address minterAddress,
        uint256 tokenCap,
        uint256 initialSupply,
        string memory tokenProof
    ) 
        external
        override
        onlyNotInitialized
        returns(bool)
    {
        return _initialize(
            tokenName,
            tokenSymbol,
            minterAddress,
            tokenCap,
            initialSupply,
            tokenProof
        );
    }

    /**
     * @dev _initialize
     *      Private function called on contract initialization.
     * @param tokenName refers to a new DataToken name
     * @param tokenSymbol refers to a nea DataToken symbol
     * @param minterAddress refers to an address that has minter rights
     * @param tokenCap the total ERC20 cap
     * @param initialSupply the initial ERC20 supply
     * @param tokenProof proof represents the relationship between data and token
     */
    function _initialize(
        string memory tokenName,
        string memory tokenSymbol,
        address minterAddress,
        uint256 tokenCap,
        uint256 initialSupply,
        string memory tokenProof
    )
        private
        returns(bool)
    {
        require(
            minterAddress != address(0), 
            'ERC20Template: Invalid minter, zero address'
        );

        require(
            tokenCap != 0,
            'ERC20Template: Invalid cap value'
        );

        require(
            initialSupply != 0,
            'ERC20Template: Invalid initialSupply value'
        );

        _cap = tokenCap;
        _initial = initialSupply;
        _name = tokenName;
        _proof = tokenProof;
        _symbol = tokenSymbol;
        _minter = minterAddress;
        _mint(minterAddress, initialSupply);
        initialized = true;
        _exchangeId = 0;
        return initialized;
    }

    /**
     * @dev mint
     *      Only the minter address can call it.
     *      msg.value should be higher than zero and gt or eq minting fee
     * @param account refers to an address that token is going to be minted to.
     * @param value refers to amount of tokens that is going to be minted.
     */
    function mint(
        address account,
        uint256 value
    ) 
        external 
        override 
        onlyMinter 
    {
        require(
            SafeMath.add(totalSupply(), value) <= _cap, 
            'ERC20Template: cap exceeded'
        );
        _mint(account, value);
    }

    /**
     * @dev name
     *      It returns the token name.
     * @return DataToken name.
     */
    function name() public view override returns(string memory) {
        return _name;
    }

    /**
     * @dev symbol
     *      It returns the token symbol.
     * @return DataToken symbol.
     */
    function symbol() public view override returns(string memory) {
        return _symbol;
    }

    /**
     * @dev proof
     *       proof represents the relationship between data and token.
     * @return DataToken proof.
     */
    function proof() external view override returns (string memory) {
        return _proof;
    }

    /**
     * @dev decimals
     *      It returns the token decimals.
     *      how many supported decimal points
     * @return DataToken decimals.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev cap
     *      it returns the capital.
     * @return DataToken cap.
     */
    function cap() external view override returns (uint256) {
        return _cap;
    }

    /**
     * @dev isMinter
     *      It takes the address and checks whether it has a minter role.
     * @param account refers to the address.
     * @return true if account has a minter role.
     */
    function isMinter(address account) external view override returns(bool) {
        return (_minter == account);
    } 

    /**
     * @dev minter
     * @return minter's address.
     */
    function minter()
        external
        view 
        override
        returns(address)
    {
        return _minter;
    }

    /**
     * @dev isInitialized
     *      It checks whether the contract is initialized.
     * @return true if the contract is initialized.
     */ 
    function isInitialized() external view override returns(bool) {
        return initialized;
    }

    /**
     * @dev justice Institution
     *      It returns the justice Institution.
     * @return the justice Institution of metadata.
     */
    function justice() external view override returns(string memory) {
        return _justice;
    }

    /**
     * @dev set Justice Institution
     *      Only the minter address can call it.
     *      msg.value should be higher than zero and gt or eq minting fee
     * @param oneJustice refers to Justice Institution
     */
    function setJustice(string memory oneJustice) 
        external
        override
        onlyMinter
    {
        _justice = oneJustice;
    }

    /**
     * @dev set Justice Institution information
     *      Only the minter address can call it.
     *      msg.value should be higher than zero and gt or eq minting fee
     * @param key Justice Institution information key
     * @param value Justice Institution information value
     */
    function setJusticeInfo(uint256 key, bytes32 value) 
        external
        override
        onlyMinter
    {
        emit SetJusticeInfo(
            key,
            value
        );
    }

    ////////////////////////////////////

    uint256 public constant BASE = 10**18;
    uint256 public constant USAGE_FEE = BASE;

    struct Exchange {
        address user;
        address userAgency;
        uint256 value;
        bool freeze;
        bool used;
    }

    // maps an exchangeId to an exchange
    uint256 private _exchangeId;
    mapping(uint256 => Exchange) private exchanges;
    uint256[] private exchangeIds;

    enum ExchangeState{ NOTEXIST, FREEZE, USED, END }

    event ExchangeFreeze(
        uint256 indexed exchangeId,
        address indexed exchangeUser,
        address indexed exchangeUserAgency,
        uint256 value
    );

    event ExchangeCommit(
        uint256 indexed exchangeId,
        address indexed exchangeUser,
        address indexed exchangeUserAgency
    );

    event ExchangeRollback(
        uint256 indexed exchangeId,
        address indexed exchangeUser,
        address indexed exchangeUserAgency
    );

    event ExchangeSettle(
        uint256 indexed exchangeId,
        address indexed exchangeUser,
        address indexed exchangeUserAgency,
        uint256 value
    );

    function freezeExchange(address userAgency) external override returns (uint256){
        _exchangeId = _exchangeId + 1;

        require(balanceOf(msg.sender) > USAGE_FEE, 'not enough tokens');

        _transfer(msg.sender, address(this), USAGE_FEE);

        exchanges[_exchangeId] = Exchange({
            user: msg.sender,
            userAgency: userAgency,
            value: USAGE_FEE,
            freeze: true,
            used: false
        });
        exchangeIds.push(_exchangeId);

        emit ExchangeFreeze (
            _exchangeId,
            msg.sender,
            userAgency,
            USAGE_FEE
        );

        return _exchangeId;
    }

    function verifyFreezeExchange(uint256 exchangeId) external view override returns (bool){
        uint256 length = exchangeIds.length;
        bool find = false;
        for (uint256 i = 0; i < length; i++){
            if (exchangeIds[i] == exchangeId){
                find = true;
            }
        }

        if(find){
            if(exchanges[exchangeId].freeze && !exchanges[exchangeId].used) {
                return true;
            }
        }

        return false;
    }

    function commitExchange(uint256 exchangeId) external override  returns (bool){
        uint256 length = exchangeIds.length;
        bool find = false;
        for (uint256 i = 0; i < length; i++){
            if (exchangeIds[i] == exchangeId){
                find = true;
            }
        }

        require(find, "invalid exchange id");
        require(exchanges[exchangeId].freeze, "No frozen amount");
        require(msg.sender == exchanges[exchangeId].userAgency, "Only agency can do this");
        require(!exchanges[exchangeId].used, "data has been used");

        exchanges[exchangeId].used = true;

        emit ExchangeCommit(
            exchangeId,
            exchanges[exchangeId].user,
            msg.sender
        );

        return true;
    }

    function rollbackExchange(uint256 exchangeId) external override  returns (bool){
        uint256 length = exchangeIds.length;
        bool find = false;
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++){
            if (exchangeIds[i] == exchangeId){
                index = i;
                find = true;
            }
        }

        require(find, "invalid exchange id");
        require(exchanges[exchangeId].freeze, "No frozen amount");
        require(msg.sender == exchanges[exchangeId].userAgency, "Only agency can do this");
        require(!exchanges[exchangeId].used, "data has been used");

        exchanges[exchangeId].freeze = false;

        // 退钱到使用者账户
        _transfer(address(this), exchanges[exchangeId].user, USAGE_FEE);

        emit ExchangeRollback(
            exchangeId,
            exchanges[exchangeId].user,
            msg.sender
        );

        for (uint256 i = index; i < length - 1; i++) {
            exchangeIds[i] = exchangeIds[i+1];
        }

        delete exchangeIds[length - 1];
        exchangeIds.pop();

        delete exchanges[exchangeId];

        return true;
    }

    function settleExchange(uint256 exchangeId) external override  returns (bool){
        uint256 length = exchangeIds.length;
        bool find = false;
        uint256 index = 0;
        for (uint256 i = 0; i < length; i++){
            if (exchangeIds[i] == exchangeId){
                index = i;
                find = true;
            }
        }

        require(find, "invalid exchange id");
        require(exchanges[exchangeId].freeze, "No frozen amount");
        require(msg.sender == exchanges[exchangeId].userAgency, "Only agency can do this");
        require(exchanges[exchangeId].used, "data has not been used");


        exchanges[exchangeId].freeze = false;

        // 提取金额到 minter 账户
        _transfer(address(this), _minter, exchanges[exchangeId].value);

            emit ExchangeSettle(
                exchangeId,
                exchanges[exchangeId].user,
                exchanges[exchangeId].userAgency,
                exchanges[exchangeId].value
            );

        for (uint256 i = index; i < length - 1; i++) {
            exchangeIds[i] = exchangeIds[i+1];
        }

        delete exchangeIds[length - 1];
        exchangeIds.pop();

        delete exchanges[exchangeId];

        return true;
    }


    function exchangeState(uint256 exchangeId) external view override  returns (uint){
        ExchangeState state;
        uint256 length = exchangeIds.length;
        bool find = false;
        for (uint256 i = 0; i < length; i++){
            if (exchangeIds[i] == exchangeId){
                find = true;
            }
        }

        // 不存在
        if(!find){
            state = ExchangeState.NOTEXIST;
        } else if(exchanges[exchangeId].freeze){
            if(!exchanges[exchangeId].used) {
                state = ExchangeState.FREEZE;
            }else {
                state = ExchangeState.USED;
            }
        } else {
            state = ExchangeState.END;
        }

        return uint(state);
    }
}
