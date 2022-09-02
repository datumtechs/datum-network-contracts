# DataToken

did 相关合约。

## deploy

did 合约部署过程为：

1. 执行命令`truffle migrate --network platondev`, 先部署 Vote 合约， 调用 Vote 合约 initialize 方法设置当前地址为 admin 地址。 部署 Did 合约。 部署 Pct 合约， 调用  Pct 合约 initialize 方法设置 Vote 合约地址。部署 Credential 合约， 调用  Credential 合约 initialize 方法设置 Vote 合约地址。

2. 各个组织启动成功，并且生成 did document 成功。

3. 将 set_admin_and_register_pct.js 改名为 3_set_admin_and_register_pct.js， 将 DID/migrations/config.json 中的 admin 的 address 和 serviceUrl 设置为官方组织的内置钱包地址和 carrier vc 申请和下载的 rpc 服务地址。

4. 执行`truffle migrate --network platondev`, 注册组织 pct 信息，并获取 pctId， 更改 admin 信息为 config.json 中的 admin 的 address 和 serviceUrl。

5. config.json 中的合约地址更新为新部署的合约地址。

6. 更新合约， 将 upgrade_contracts.js 改名为 4_upgrade_contracts.js,  `truffle migrate --network platondev -f 4`。 更新之后合约的 `proxy` 和 `proxyAdmin` 地址不变，`implement` 地址变为最新的地址。
