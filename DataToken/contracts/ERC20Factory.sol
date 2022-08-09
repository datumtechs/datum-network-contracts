pragma solidity ^0.8.0;
// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import './interfaces/IERC20Template.sol';
import "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @title ERC20Factory contract
 * @author Metis Network Team
 *
 * @dev Implementation of ERC20Factory
 *
 *      ERC20Factory deploys DataToken proxy contracts.
 *      New DataToken proxy contracts are links to the template contract's bytecode.
 *      Proxy contract functionality is based on implementation of ERC1167 standard.
 */
contract ERC20Factory {
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
    constructor( address _template) {
        require(
            _template != address(0),
            'ERC20Factory: Invalid template address'
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
     * @return token address of a new proxy DataToken contract
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
            'ERC20Factory: zero cap is not allowed'
        );

        token = Clones.clone(tokenTemplate);

        require(
            token != address(0),
            'ERC20Factory: Failed to perform minimal deploy of a new token'
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
            'ERC20Factory: Unable to initialize token instance'
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