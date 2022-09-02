const VoteV2 = artifacts.require('VoteV2');
const { upgradeProxy, erc1967 } = require('@openzeppelin/truffle-upgrades');
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')

module.exports = async function (deployer) {
    let config = await jsonfile.readFile(configFile);
    console.log(config.DID.Did.proxy);

    let voteProxy = await upgradeProxy(config.DID.Vote.proxy, VoteV2, { deployer });
    console.log("vote proxy:", voteProxy.address);
    config.DID.Vote.proxy = voteProxy.address;

    let proxyAdmin = await erc1967.getAdminAddress(voteProxy.address);
    console.log("proxy admin:", proxyAdmin);
    config.DID.Vote.proxyAdmin = proxyAdmin;
   
    let voteImplement = await erc1967.getImplementationAddress(voteProxy.address);
    console.log("implement:", voteImplement);
    config.DID.Vote.implement = voteImplement;
  
    console.log("deploy successful");
  
    await jsonfile.writeFile(configFile, config, {spaces: 2});
    console.log("update config success");
};