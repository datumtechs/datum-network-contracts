var ERC721Template = artifacts.require("ERC721Template");
var ERC721Factory = artifacts.require("ERC721Factory");
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')

module.exports = async function(deployer) {
  let config = await jsonfile.readFile(configFile);

  erc721Template = await deployer.deploy(ERC721Template, "0xc115ceadf9e5923330e5f42903fe7f926dda65d2", "lat", "lat", 10, "ERC721proof");
  console.log('ERC721Template: ', erc721Template.address);
  config.DataToken.ERC721Template = erc721Template.address;

  erc721Factory = await deployer.deploy(ERC721Factory, ERC721Template.address);
  console.log('ERC721Factory: ', erc721Factory.address);
  config.DataToken.ERC721Factory = erc721Factory.address;

  console.log("deploy successful");

  await jsonfile.writeFile(configFile, config, {spaces: 2});
  console.log("update config success");
};