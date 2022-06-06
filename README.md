# DataToken-Contracts

The DataToken Contracts

## compile

```shell
# 安装 truffle
sudo npm install -g truffle

# 切换到相应目录
# 部署 DataToken, cd DataToken 或者部署 DatumNetworkPay，cd DatumNetworkPay

# 下载 node 依赖项
npm install

# 编译合约（默认是增量编译的，要全部重新编译，加上 --all 选项即可）
truffle compile

# 配置链信息 truffle-config.js 增加新的链信息
# 配置连接的节点网络
# truffle-config.js 中 networks 配置自己的网络节点信息
# 如果用助记词，配置钱包助记词
# migrations/config.json 中配置网络对应的 mnemonic
# 比如： platondev 网络配置如下：

platondev: {
    provider: () => new HDWalletProvider(config.platondev.mnemonic, 'ws://35.247.155.162:6790'),
    // host: "35.247.155.162",
    // port: 6790,
    // from: "0xc115ceadf9e5923330e5f42903fe7f926dda65d2",
    // network_id: 210309,       // Ropsten's id
    network_id: 1,       // Ropsten's id
    gas: 5500000,        // Ropsten has a lower block limit than mainnet
    confirmations: 2,    // # of confs to wait between deployments. (default: 0)
    timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
    skipDryRun: true,     // Skip dry run before migrations? (default: false for public nets )
    networkCheckTimeout: 100000000,
    websockets: true
},

# 下面都以 platondev 网络为例。
# 部署合约到指定网络
# 如果是部署 DatumNetworkPay 合约，修改 migrations/config.json 中的 wlatAddress 为 wlat 合约的地址
truffle migrate --network platondev

# 如果是要升级 DatumNetworkPay 合约
# 将 migrations/upgrade_contracts.js 改为 migrations/3_upgrade_contracts.js
# migrations/config.json 中的参数保持和现网的一致
truffle migrate --network platondev -f 3

# 以下为可选项，需要单元测试时，执行以下步骤
# 单元测试
truffle test --network platondev

# 调用 console 和链进行交互
# truffle console --network platondev

# Ganache 能快速运行一个本地测试区块链
# npm install --save-dev ganache-cli

# --deterministic 参数是使用当前目录下的 networks.js 为配置启动本地测试区块链
# npx ganache-cli --deterministic
```
