
let vote
var Vote = artifacts.require("Vote");
var adminUrl = 'https://github.com';
var publicInfoUrl = 'https://www.json.cn/';
var serviceUrl = 'https://translate.google.cn/?hl=zh-CN&tab=TT';

const ADD_AUTHORITY= 1;
const KICK_OUT_AUTHORITY= 2;
const AUTO_QUIT_AUTHORITY= 3;

contract('Vote', (accounts) => {
  beforeEach(async () => {
    vote = await Vote.new();
    console.log('vote:', vote.address);

    await vote.initialize(adminUrl);
  })

  it('submitProposal: ADD_AUTHORITY  must be success', async () => {
    var res = await vote.submitProposal(ADD_AUTHORITY, publicInfoUrl, accounts[1], serviceUrl);
    var newProposalLog = res.logs.find(
    element => element.event.match('NewProposal') &&
        element.address.match(vote.address)
    );

    console.log(newProposalLog);
    assert.strictEqual(newProposalLog.args.proposalId.toString(), '0');
    assert.strictEqual(newProposalLog.args.proposalType.toString(), '1');
    assert.strictEqual(newProposalLog.args.sender, accounts[0]);
    assert.strictEqual(newProposalLog.args.operator, accounts[1]);
    assert.strictEqual(newProposalLog.args.operatorServiceUrl.toString(), serviceUrl);
    assert.strictEqual(newProposalLog.args.publicInfoUrl.toString(), publicInfoUrl);

    var allProposal = await vote.getAllProposal.call();
    assert.strictEqual(allProposal.length, 1);
    assert.strictEqual(allProposal[0].toNumber(), 0)

    var oneProposal = await vote.getProposalInfo.call(0);
    console.log(oneProposal);
    assert.strictEqual(oneProposal[0].toString(), '1');
    assert.strictEqual(oneProposal[1], publicInfoUrl);
    assert.strictEqual(oneProposal[2], accounts[0]);
    assert.strictEqual(oneProposal[3], accounts[1]);

    // web3.eth.getBlockNumber(function(error, result){ 
    //     if (!error){
    //         console.log("block number => ", result)
    //     }     
    // });

    // await vote.voteProposal(0);
    // await vote.effectProposal(0);

    // // 踢出
    // res = await vote.submitProposal(KICK_OUT_AUTHORITY, publicInfoUrl, accounts[1], serviceUrl);
    // newProposalLog = res.logs.find(
    // element => element.event.match('NewProposal') &&
    //     element.address.match(vote.address)
    // );

    // console.log(newProposalLog);
    // assert.strictEqual(newProposalLog.args.proposalId.toString(), '1');
    // assert.strictEqual(newProposalLog.args.proposalType.toString(), '2');
    // assert.strictEqual(newProposalLog.args.sender, accounts[0]);
    // assert.strictEqual(newProposalLog.args.operator, accounts[1]);
    // assert.strictEqual(newProposalLog.args.operatorServiceUrl.toString(), serviceUrl);
    // assert.strictEqual(newProposalLog.args.publicInfoUrl.toString(), publicInfoUrl);

    // allProposal = await vote.getAllProposal.call();
    // assert.strictEqual(allProposal.length, 2);
    // assert.strictEqual(allProposal[0].toNumber(), 0)
    // assert.strictEqual(allProposal[1].toNumber(), 1)

    // oneProposal = await vote.getProposalInfo.call(1);
    // console.log(oneProposal);
    // assert.strictEqual(oneProposal[0].toString(), '2');
    // assert.strictEqual(oneProposal[1], publicInfoUrl);
    // assert.strictEqual(oneProposal[2], accounts[0]);
    // assert.strictEqual(oneProposal[3], accounts[1]);

    // // 自动退出
    // res = await vote.submitProposal(AUTO_QUIT_AUTHORITY, publicInfoUrl, accounts[1], serviceUrl);
    // newProposalLog = res.logs.find(
    // element => element.event.match('NewProposal') &&
    //     element.address.match(vote.address)
    // );

    // console.log(newProposalLog);
    // assert.strictEqual(newProposalLog.args.proposalId.toString(), '2');
    // assert.strictEqual(newProposalLog.args.proposalType.toString(), '3');
    // assert.strictEqual(newProposalLog.args.sender, accounts[0]);
    // assert.strictEqual(newProposalLog.args.operator, accounts[1]);
    // assert.strictEqual(newProposalLog.args.operatorServiceUrl.toString(), serviceUrl);
    // assert.strictEqual(newProposalLog.args.publicInfoUrl.toString(), publicInfoUrl);

    // allProposal = await vote.getAllProposal.call();
    // assert.strictEqual(allProposal.length, 3);
    // assert.strictEqual(allProposal[0].toNumber(), 0)
    // assert.strictEqual(allProposal[1].toNumber(), 1)
    // assert.strictEqual(allProposal[2].toNumber(), 2)

    // oneProposal = await vote.getProposalInfo.call(2);
    // console.log(oneProposal);
    // assert.strictEqual(oneProposal[0].toString(), '3');
    // assert.strictEqual(oneProposal[1], publicInfoUrl);
    // assert.strictEqual(oneProposal[2], accounts[0]);
    // assert.strictEqual(oneProposal[3], accounts[1]);
  });
  
});


