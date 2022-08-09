var Vote = artifacts.require("Vote");
var Did = artifacts.require("Did");
var Pct = artifacts.require("Pct");
var Credential = artifacts.require("Credential");
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')
const HDWalletProvider = require('@truffle/hdwallet-provider');
const {deployProxy, erc1967} = require('@openzeppelin/truffle-upgrades');

module.exports = async function(deployer) {
  let config = await jsonfile.readFile(configFile);

  // vote contract
  var provider = new HDWalletProvider(config.platondev.mnemonic, 'ws://35.247.155.162:6790');
  let voteProxy = await deployProxy(Vote, [provider.getAddresses()[0], config.admin.serviceUrl], { deployer: deployer, initializer: 'initialize'});
  console.log('vote proxy:', voteProxy.address);
  config.DID.Vote.proxy = voteProxy.address;

  let voteProxyAdmin = await erc1967.getAdminAddress(voteProxy.address);
  console.log("vote proxy admin:", voteProxyAdmin);
  config.DID.Vote.proxyAdmin = voteProxyAdmin;
 
  let voteImplement = await erc1967.getImplementationAddress(voteProxy.address);
  console.log("vote implement:", voteImplement);
  config.DID.Vote.implement = voteImplement;

  // did contract
  let didProxy = await deployProxy(Did);
  console.log('did proxy:', didProxy.address);
  config.DID.Did.proxy = didProxy.address;

  let didProxyAdmin = await erc1967.getAdminAddress(didProxy.address);
  console.log("did proxy admin:", didProxyAdmin);
  config.DID.Did.proxyAdmin = didProxyAdmin;
 
  let didImplement = await erc1967.getImplementationAddress(didProxy.address);
  console.log("did implement:", didImplement);
  config.DID.Did.implement = didImplement;

  // pct contract
  let pctProxy = await deployProxy(Pct, [voteProxy.address], { deployer: deployer, initializer: 'initialize'});
  console.log('pct proxy:', pctProxy.address);
  config.DID.Pct.proxy = pctProxy.address;

  let pctProxyAdmin = await erc1967.getAdminAddress(pctProxy.address);
  console.log("pct proxy admin:", pctProxyAdmin);
  config.DID.Pct.proxyAdmin = pctProxyAdmin;
 
  let pctImplement = await erc1967.getImplementationAddress(pctProxy.address);
  console.log("pct implement:", pctImplement);
  config.DID.Pct.implement = pctImplement;

  // register node pct
  const res = await pctProxy.registerPct(config.nodePCT.jsonSchema, '0x01');
  const RegisterPctLog = res.logs.find(
    element => element.event.match('RegisterPct') &&
      element.address.match(pctProxy.address)
  );
  config.nodePCT.pctId = RegisterPctLog.args.pctId.toNumber();
  await voteProxy.setAdmin(config.admin.address, config.admin.serviceUrl);

  // credential contract
  let credentialProxy = await deployProxy(Credential, [voteProxy.address], { deployer: deployer, initializer: 'initialize'});
  console.log('credential proxy:', credentialProxy.address);
  config.DID.Credential.proxy = credentialProxy.address;

  let credentialProxyAdmin = await erc1967.getAdminAddress(credentialProxy.address);
  console.log("credential proxy admin:", credentialProxyAdmin);
  config.DID.Credential.proxyAdmin = credentialProxyAdmin;
 
  let credentialImplement = await erc1967.getImplementationAddress(credentialProxy.address);
  console.log("credential implement:", credentialImplement);
  config.DID.Credential.implement = credentialImplement;

  console.log("deploy successful");

  await jsonfile.writeFile(configFile, config, {spaces: 2});
  console.log("deploy DID contract config success");
};