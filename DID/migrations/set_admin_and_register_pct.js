var Vote = artifacts.require("Vote");
var Pct = artifacts.require("Pct");
const configFile = process.cwd() + "/config.json";
const jsonfile = require('jsonfile')


module.exports = async function(deployer) {
  let config = await jsonfile.readFile(configFile);

  voteProxy = await Vote.at(config.DID.Vote.proxy);
  pctProxy = await Pct.at(config.DID.Pct.proxy);

  // register node pct
  const res = await pctProxy.registerPct(config.nodePCT.jsonSchema, '0x01');
  const RegisterPctLog = res.logs.find(
    element => element.event.match('RegisterPct') &&
      element.address.match(pctProxy.address)
  );
  config.nodePCT.pctId = RegisterPctLog.args.pctId.toNumber();
  await voteProxy.setAdmin(config.admin.address, config.admin.serviceUrl);

  console.log("set admin and register pct successful");

  await jsonfile.writeFile(configFile, config, {spaces: 2});
  console.log("deploy DID contract config success");
};