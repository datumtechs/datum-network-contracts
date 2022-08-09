# DataToken

did 相关合约。

## deploy

did 合约部署过程为：

1. 将 DID/migrations/config.json 中的 admin 的 address 和 serviceUrl 设置为官方组织的内置钱包地址和 carrier vc 申请和下载的 rpc 服务地址。

2. 先部署 Vote 合约， 调用 Vote 合约 initialize 方法设置当前地址为 admin 地址。 部署 Did 合约。 部署 Pct 合约， 调用  Pct 合约 initialize 方法设置 Vote 合约地址。 注册组织 pct 信息，并获取 pctId， 更改 admin 信息为 config.json 中的 admin 的 address 和 serviceUrl。 部署 Credential 合约， 调用  Credential 合约 initialize 方法设置 Vote 合约地址。

3. config.json 中的合约地址更新为新部署的合约地址。
