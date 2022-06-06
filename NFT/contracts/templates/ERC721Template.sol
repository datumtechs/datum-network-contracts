pragma solidity ^0.6.6;

// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '../interfaces/IERC721Template.sol';

contract ERC721Template is ERC721("Template", "TemplateSymbol"), IERC721Template {
    string private _name;
    string private _symbol;
    string  private _proof;
    uint256 private _cap;
    address private _admin;
    bool    private initialized = false;

    function initialize(
        address admin_,
        string calldata name_,
        string calldata symbol_,
        uint256 cap_,
        string calldata proof_
    )  external override returns (bool){
        require( !initialized, 'ERC721Template: token instance already initialized');
        return _initialize(admin_, name_, symbol_, cap_, proof_);
    }

    function _initialize(
        address admin_,
        string memory name_,
        string memory symbol_,
        uint256 cap_,
        string memory proof_
    ) private returns (bool){
        require(
            admin_ != address(0), 
            'ERC721Template: Invalid admin, zero address'
        );

        require(
            cap_ != 0,
            'ERC721Template: Invalid cap value'
        );

        _name = name_;
        _symbol = symbol_;
        _cap = cap_;
        _proof = proof_;
        _admin = admin_;
        _tokenId = 0;
        initialized = true;
        return initialized;
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
     * @return proof.
     */
    function proof() public view override returns(string memory) {
        return _proof;
    }

    /**
     * @dev cap
     *      it returns the capital.
     * @return DataToken cap.
     */
    function cap() public view override returns (uint256) {
        return _cap;
    }

    function admin() public view override returns(address) {
        return _admin;
    }

    struct Character {
        string term;
    }

    // map an tokenId to an Character
    uint256 private _tokenId;
    mapping(uint256 => Character) private characters;
    uint256[] private tokenIds;

    function createToken(string memory term, string memory tokenURI_) public override returns (uint256) {
        require(msg.sender == _admin, 'ERC721Template: invalid msg sender');
        require(totalSupply() < _cap, 'cap exceeded');

        uint256 newId = _tokenId;

        characters[newId] = Character({
            term: term
        });

        tokenIds.push(newId);

        _safeMint(msg.sender, newId);
        _setTokenURI(newId, tokenURI_);

        _tokenId = _tokenId + 1;
        return newId;
    }

    function getCharacter(uint256 tokenId) public view override returns (string memory){
        return characters[tokenId].term;
    }

}

