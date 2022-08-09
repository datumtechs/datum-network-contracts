pragma solidity ^0.8.0;

// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

interface IERC721Template {
    function initialize(
        address admin_,
        string calldata name_,
        string calldata symbol_,
        string calldata proof_,
        uint8 cipherFlag_
    ) external returns (bool);

    // ERC721 的管理员
    function admin() external view returns(address);

    // 证据表示数据和 token 之间的关系
    function proof() external view returns(string memory);

    // 数据支持明文和密文算法的 flag
    function cipherFlag() external view returns(uint8);

    // 铸币，有效期， 是否支持密文算法， tokenURI
    function createToken(string calldata term, bool cipher_, string calldata tokenURI_) external returns (uint256);

    // 获取 NFT 的属性， NFT 的有效期， 是否支持密文算法
    function getCharacter(uint256 tokenId) external view returns (string memory, bool);

    // 获取 NFT 的 owner, NFT 的有效期， 是否支持密文算法
    function getExtInfo(uint256 tokenId) external view returns (address owner, string memory term, bool forEncryptAlg);
}