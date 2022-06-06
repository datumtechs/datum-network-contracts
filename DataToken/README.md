# DataToken

data token 相关合约。

## deploy

DataToken 部署过程为：

1. 部署模板合约 DataTokenTemplate，对应 config.json 中的 DataTokenTemplate。

2. 部署 datatoken 工厂合约 DataTokenFactory，对应 config.json 中的 DataTokenFactory，DAPP直接交互的合约地址。

>- 部署成功之后， config.json 中 DataTokenTemplate，DataTokenFactory 的地址会更新为新部署的合约的地址。
