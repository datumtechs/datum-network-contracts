pragma solidity ^0.8.0;

// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import '../interfaces/IERC721Template.sol';

contract ERC721Template is IERC721Template, ERC721("Template", "TemplateSymbol"), ERC721Enumerable, ERC721URIStorage{
    string private _name;
    string private _symbol;
    string  private _proof;
    address private _admin;
    uint8   private _cipherFlag;
    bool    private initialized = false;

    // 明文算法
    uint8  private constant PLAINTEXT = 1;
    // 密文算法
    uint8  private constant CIPHERTEXT = 2;

    function initialize(
        address admin_,
        string calldata name_,
        string calldata symbol_,
        string calldata proof_,
        uint8 cipherFlag_
    )  external override returns (bool){
        require( !initialized, 'ERC721Template: token instance already initialized');
        return _initialize(admin_, name_, symbol_, proof_, cipherFlag_);
    }

    function _initialize(
        address admin_,
        string memory name_,
        string memory symbol_,
        string memory proof_,
        uint8 cipherFlag_
    ) private returns (bool){
        require(
            admin_ != address(0), 
            'ERC721Template: Invalid admin, zero address'
        );

        _name = name_;
        _symbol = symbol_;
        _proof = proof_;
        _admin = admin_;
        _cipherFlag = cipherFlag_;
        _tokenId = 0;
        initialized = true;

        return initialized;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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

    function admin() public view override returns(address) {
        return _admin;
    }

    function cipherFlag() external view override returns(uint8){
        return _cipherFlag;
    }

    // 属性信息，主要期限和是否可以应用密文算法
    struct Character {
        string term;
        bool cipher;
    }

    // map an tokenId to an Character
    uint256 private _tokenId;
    mapping(uint256 => Character) private characters;
    uint256[] private tokenIds;

    function createToken(string memory term, bool cipher_, string memory tokenURI_) public override returns (uint256) {
        require(msg.sender == _admin, 'ERC721Template: invalid msg sender');

        if(cipher_) {
            require(_cipherFlag & CIPHERTEXT == CIPHERTEXT, 'metadata does not support ciphertext algorithms');
        } else {
            require(_cipherFlag & PLAINTEXT == PLAINTEXT, 'metadata does not support plaintext algorithms');
        }

        uint256 newId = _tokenId;

        characters[newId] = Character({
            term: term,
            cipher: cipher_
        });

        tokenIds.push(newId);

        _safeMint(msg.sender, newId);
        _setTokenURI(newId, tokenURI_);

        _tokenId = _tokenId + 1;
        return newId;
    }

    function getCharacter(uint256 tokenId) public view override returns (string memory, bool){
        return (
            characters[tokenId].term,
            characters[tokenId].cipher
        );
    }

    function getExtInfo(uint256 tokenId) public view returns (address owner, string memory term, bool forEncryptAlg){
        return (
            ownerOf(tokenId),
            characters[tokenId].term,
            characters[tokenId].cipher
        );
    }

}

