let vote
let did
let pct 
let credential 
var Vote = artifacts.require("Vote");
var Did = artifacts.require("Did");
var Pct = artifacts.require("Pct");
var Credential = artifacts.require("Credential");
const configFile = process.cwd() + "/migrations/config.json";
const jsonfile = require('jsonfile')

contract('initialize', (accounts) => {

  beforeEach(async () => {
    let config = await jsonfile.readFile(configFile);
    vote = await Vote.at(config.DID.Vote.proxy);
    did = await Did.at(config.DID.Did.proxy);
    pct = await Pct.at(config.DID.Pct.proxy);
    credential = await Credential.at(config.DID.Credential.proxy);
  })

  it('test initialize information', async () => {
    let config = await jsonfile.readFile(configFile);
    const adminInfo = await vote.getAdmin();
    assert.strictEqual(config.admin.address, adminInfo['0']);
    assert.strictEqual(config.admin.serviceUrl, adminInfo['1']);

    const pctInfo = await pct.getPctInfo(config.nodePCT.pctId);
    assert.strictEqual(accounts[0], pctInfo['0']);
    assert.strictEqual(config.nodePCT.jsonSchema, pctInfo['1']);
  });

});