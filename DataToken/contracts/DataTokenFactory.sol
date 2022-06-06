pragma solidity 0.5.7;

import './utilitys/Deployer.sol';
import './interfaces/IERC20Template.sol';

/**
 * @title DataTokenFactory contract
 * @author Metis Network Team
 *
 * @dev Implementation of DataTokenFactory
 *
 *      DataTokenFactory deploys DataToken proxy contracts.
 *      New DataToken proxy contracts are links to the template contract's bytecode.
 *      Proxy contract functionality is based on implementation of ERC1167 standard.
 */
contract DataTokenFactory is Deployer {
    address private tokenTemplate;

    event TokenCreated(
        address indexed newTokenAddress, 
        address indexed templateAddress, 
        string indexed tokenName  
    );

    event TokenRegistered(
        address indexed tokenAddress,
        string tokenName,
        string tokenSymbol,
        uint256 tokenCap,
        uint256 initialSupply,
        address indexed registeredBy,
        string proof
    );

    /**
     * @dev constructor
     *      Called on contract deployment. Could not be called with zero address parameters.
     * @param _template refers to the address of a deployed DataToken contract.
     */
    constructor(
        address _template
    ) public {
        require(
            _template != address(0),
            'DataTokenFactory: Invalid template address'
        );
        tokenTemplate = _template;
    }

    /**
     * @dev Deploys new DataToken proxy contract.
     *      Template contract address could not be a zero address.
     * @param name token name
     * @param symbol token symbol
     * @param cap the maximum total supply
     * @param initialSupply the initial supply
     * @param proof proof represents the relationship between data and token
     * @return address of a new proxy DataToken contract
     */
    function createToken(
        string memory name,
        string memory symbol,
        uint256 cap,
        uint256 initialSupply,
        string memory proof
    )
        public
        returns (address token)
    {
        require(
            cap != 0,
            'DataTokenFactory: zero cap is not allowed'
        );

        token = deploy(tokenTemplate);

        require(
            token != address(0),
            'DataTokenFactory: Failed to perform minimal deploy of a new token'
        );

        IERC20Template tokenInstance = IERC20Template(token);
        require(
            tokenInstance.initialize(
                name,
                symbol,
                msg.sender,
                cap,
                initialSupply,
                proof
            ),
            'DataTokenFactory: Unable to initialize token instance'
        );
        emit TokenCreated(token, tokenTemplate, name);
        emit TokenRegistered(
            token,
            name,
            symbol,
            cap,
            initialSupply,
            msg.sender,
            proof
        );
    }

    /**
     * @dev get the token template address
     * @return the template address
     */
    function getTokenTemplate() external view returns (address) {
        return tokenTemplate;
    }
}