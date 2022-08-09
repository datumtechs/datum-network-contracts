pragma solidity ^0.8.0;
// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import './interfaces/IERC721Template.sol';
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ERC721Factory {
    address private tokenTemplate;

    event NFTContractCreated(
        address indexed newTokenAddress,
        address indexed templateAddress,
        address indexed admin,
        string name,
        string symbol,
        string proof,
        uint8 cipherFlag
    );

    constructor( address _template) {
        require(
            _template != address(0),
            'ERC721Factory: Invalid template address'
        );
        tokenTemplate = _template;
    }

    /**
     * @dev deployERC721Contract
     *      Deploy ERC721 contracts.
     * @param name refers to a new DataToken name
     * @param symbol refers to a nea DataToken symbol
     * @param proof proof represents the relationship between data and token
     * @param cipherFlag To support those algorithms, you need to set 1 for plaintext, 2 for ciphertext, and 3 for both plaintext and ciphertext support.
     * @return token ERC721 contract address.
     */
    function deployERC721Contract(
        string memory name,
        string memory symbol,
        string memory proof,
        uint8 cipherFlag
    ) public returns (address token){
        token = Clones.clone(tokenTemplate);

        require(
            token != address(0),
            'ERC721Factory: Failed to perform minimal deploy of a new token'
        );

        IERC721Template tokenInstance = IERC721Template(token);

        require(
            tokenInstance.initialize(
                msg.sender,
                name,
                symbol,
                proof,
                cipherFlag
            ),
            'ERC721Factory: Unable to initialize token instance'
        );

        emit NFTContractCreated(
            token,
            tokenTemplate,
            msg.sender,
            name,
            symbol,
            proof,
            cipherFlag
        );
    }
}