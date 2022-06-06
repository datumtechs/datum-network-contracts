# DatumNetworkPay

metis 业务支付相关合约，支持升级。

## deploy

DatumNetworkPay 部署过程为：

1. 部署业务逻辑合约 DatumNetworkPay，对应 config.json 中的 implement

2. 部署代理管理合约 ProxyAdmin，对应 config.json 中的 proxyAdmin

3. 部署代理合约 TransparentUpgradeableProxy 并运行初始化函数，对应 config.json 中的 proxy， DAPP直接交互的合约地址。

>- 部署成功之后， config.json 中implement，proxyAdmin， proxy 的地址会更新为新部署的合约的地址。

## update

DatumNetworkPay 升级过程为：

1. 部署新的业务逻辑合约 DatumNetworkPayV2。

2. 调用 ProxyAdmin 合约进行升级， upgrade 传入新的逻辑合约地址， upgradeAndCall 传入新的逻辑合约地址，初始化调用数据。

>- 升级成功之后， config.json 中 implement 的地址会更新为新部署的合约的地址， 其他地址不变。
