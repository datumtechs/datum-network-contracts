pragma solidity ^0.6.6;
// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import "./utils/Deployer.sol";
import './interfaces/IERC721Template.sol';


contract ERC721Factory is Deployer {
    address private tokenTemplate;

    event NFTContractCreated(
        address indexed newTokenAddress,
        address indexed templateAddress,
        address indexed admin,
        string name,
        string symbol,
        uint256 tokenCap,
        string proof
    );

    constructor(
        address _template
    ) public {
        require(
            _template != address(0),
            'ERC721Factory: Invalid template address'
        );
        tokenTemplate = _template;
    }

    function deployERC721Contract(
        string memory name,
        string memory symbol,
        uint256 tokenCap,
        string memory proof
    ) public returns (address token){
        require(
            tokenCap != 0,
            'ERC721Factory: zero cap is not allowed'
        );

        token = deploy(tokenTemplate);

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
                tokenCap,
                proof
            ),
            'ERC721Factory: Unable to initialize token instance'
        );

        emit NFTContractCreated(
            token,
            tokenTemplate,
            msg.sender,
            name,
            symbol,
            tokenCap,
            proof
        );
    }
}