
const {deployProxy, erc1967} = require('@openzeppelin/truffle-upgrades');
const DatumNetworkPay = artifacts.require("DatumNetworkPay");
var WLAT = artifacts.require("WLAT");
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')

async function deployDatumNetworkPay(deployer) {
  let config = await jsonfile.readFile(configFile);

  // wlat = await deployer.deploy(WLAT);
  // console.log("wlat address:", wlat.address);
  // config.DatumNetworkPay.wlatAddress = wlat.address;

  let datumNetworkPayProxy = await deployProxy(DatumNetworkPay, [config.DatumNetworkPay.wlatAddress], { deployer: deployer, initializer: 'initialize'});
  console.log('DatumNetworkPay proxy:', datumNetworkPayProxy.address);
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
}

module.exports = async function(deployer) {
  await deployDatumNetworkPay(deployer);
};

