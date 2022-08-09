# DataToken

data token 相关合约。

## deploy

DataToken 部署过程为：

1. 部署模板合约 ERC20Template 或 ERC721Template，对应 config.json 中 DataToken 的 ERC20Template 或 ERC721Template 会设置为部署的合约地址。

2. 部署 datatoken 工厂合约 ERC20Factory 或 ERC721Factory，对应 config.json 中 DataToken 的 ERC20Factory 或 ERC721Factory，对应 会设置为部署的合约地址，DAPP直接交互的合约地址。
