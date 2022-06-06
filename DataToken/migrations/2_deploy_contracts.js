
var DataTokenTemplate = artifacts.require("DataTokenTemplate");
var DataTokenFactory = artifacts.require("DataTokenFactory");
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')

module.exports = async function(deployer) {
  let config = await jsonfile.readFile(configFile);

  dataTokenTemplate = await deployer.deploy(DataTokenTemplate);
  console.log('DataTokenTemplate: ', dataTokenTemplate.address);
  config.DataToken.DataTokenTemplate = dataTokenTemplate.address;

  dataTokenFactory = await deployer.deploy(DataTokenFactory, dataTokenTemplate.address);
  console.log('DataTokenFactory: ', dataTokenFactory.address);
  config.DataToken.DataTokenFactory = dataTokenFactory.address;

  console.log("deploy successful");

  await jsonfile.writeFile(configFile, config, {spaces: 2});
  console.log("update config success");
};

