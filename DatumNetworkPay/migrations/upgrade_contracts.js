const DatumNetworkPayV2 = artifacts.require('DatumNetworkPayV2');
const { upgradeProxy, erc1967 } = require('@openzeppelin/truffle-upgrades');
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')

module.exports = async function (deployer) {
    let config = await jsonfile.readFile(configFile);
    console.log(config.DatumNetworkPay);

    let datumNetworkPayProxy = await upgradeProxy(config.DatumNetworkPay.proxy, DatumNetworkPayV2, { deployer });
    console.log("DatumNetworkPay proxy:", datumNetworkPayProxy.address);
    config.DatumNetworkPay.proxy = datumNetworkPayProxy.address;

    let proxyAdmin = await erc1967.getAdminAddress(datumNetworkPayProxy.address);
    console.log("proxy admin:", proxyAdmin);
    config.DatumNetworkPay.proxyAdmin = proxyAdmin;
   
    let datumNetworkPayImplement = await erc1967.getImplementationAddress(datumNetworkPayProxy.address);
    console.log("implement:", datumNetworkPayImplement);
    config.DatumNetworkPay.implement = datumNetworkPayImplement;
  
    console.log("deploy successful");
  
    await jsonfile.writeFile(configFile, config, {spaces: 2});
    console.log("update config success");
};