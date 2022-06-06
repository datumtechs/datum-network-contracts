pragma solidity ^0.6.6;

// Copyright metis network contributors
// SPDX-License-Identifier: (Apache-2.0 AND CC-BY-4.0)
// Code is Apache-2.0 and docs are CC-BY-4.0

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";

interface IERC721Template {
    function initialize(
        address admin_,
        string calldata name_,
        string calldata symbol_,
        uint256 cap_,
        string calldata proof_
    ) external returns (bool);

    // ERC721 的管理员
    function admin() external view returns(address);

    // 发行量，每个 metadata 发行的 NFT 数量进行限制
    function cap() external view returns (uint256);

    // 证据表示数据和token之间的关系
    function proof() external view returns(string memory);

    // 铸币，有效期， tokenURI
    function createToken(string calldata term, string calldata tokenURI_) external returns (uint256);

    // 获取 NFT 的属性， NFT 的有效期
    function getCharacter(uint256 tokenId) external view returns (string memory);
}