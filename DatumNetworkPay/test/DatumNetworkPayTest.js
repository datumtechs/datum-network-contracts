
let datumNetworkPay
let token1
let token2
let wlat
var DatumNetworkPay = artifacts.require("DatumNetworkPay");
var MyERC20 = artifacts.require("MyERC20");
var WLAT = artifacts.require("WLAT");
var carrier = '0x652B300310A00357F896B0C2D8fc8BA35c726453';

contract('DatumNetworkPay', (accounts) => {

  beforeEach(async () => {
    datumNetworkPay = await DatumNetworkPay.new();
    console.log('DatumNetworkPay:', datumNetworkPay.address);

    wlat = await WLAT.new();
    await datumNetworkPay.initialize(wlat.address);
    console.log("wlat:", wlat.address);
  
    token1 = await MyERC20.new('10000000000000000000000000000');
    console.log('token1:', token1.address);

    token2 = await MyERC20.new('10000000000000000000000000000');
    console.log('token1:', token2.address);
  })

  it('whitelist: test the whitelist operation', async () => {
    await datumNetworkPay.addWhitelist(accounts[1]);
    await datumNetworkPay.addWhitelist(accounts[2]);

    var addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    assert.strictEqual(addressArray.length, 2); 
    assert.strictEqual(addressArray[0], accounts[1]); 
    assert.strictEqual(addressArray[1], accounts[2]); 

    await datumNetworkPay.deleteWhitelist(accounts[2]);
    addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    assert.strictEqual(addressArray.length, 1); 
    assert.strictEqual(addressArray[0], accounts[1]); 

    await datumNetworkPay.addWhitelist(accounts[1]);
    addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    assert.strictEqual(addressArray.length, 1); 
    assert.strictEqual(addressArray[0], accounts[1]); 
  });

  it('whitelist: test the zero whitelist operation', async () => {
    await datumNetworkPay.addWhitelist(accounts[1]);

    var addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    assert.strictEqual(addressArray.length, 1);
    assert.strictEqual(addressArray[0], accounts[1]); 

    await datumNetworkPay.deleteWhitelist(accounts[1]);
    addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    assert.strictEqual(addressArray.length, 0); 

    await datumNetworkPay.addWhitelist(accounts[2], { from: accounts[1] });
    await datumNetworkPay.addWhitelist(accounts[1]);
    await datumNetworkPay.addWhitelist(accounts[2]);
    await datumNetworkPay.deleteWhitelist(accounts[2], { from: accounts[1] });
    addressArray = await datumNetworkPay.whitelist.call(accounts[1]);
    assert.strictEqual(addressArray.length, 0); 

    addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    assert.strictEqual(addressArray.length, 2);
    assert.strictEqual(addressArray[0], accounts[1]); 
    assert.strictEqual(addressArray[1], accounts[2]); 
  });

  it('events: should fire PrepayEvent and SettleEvent event successfully', async () => {
    var user = accounts[0];
    console.log('user address:', user);
    console.log('carrier address:', carrier);

    await datumNetworkPay.addWhitelist(carrier);
    var addressArray = await datumNetworkPay.whitelist.call(accounts[0]);
    console.log(addressArray);

    var balance = await token1.balanceOf.call(accounts[0]);
    console.log(BigInt(balance));

    await token1.approve(datumNetworkPay.address, '800000000000000000000000000');
    var allowance = await token1.allowance.call(accounts[0], datumNetworkPay.address);
    console.log(BigInt(allowance));

    balance = await token2.balanceOf.call(accounts[0]);
    console.log(BigInt(balance));

    await token2.approve(datumNetworkPay.address, '800000000000000000000000000');
    allowance = await token2.allowance.call(accounts[0], datumNetworkPay.address);
    console.log(BigInt(allowance));

    await wlat.deposit({ value: '800000000000000000' });
    balance = await wlat.balanceOf.call(accounts[0]);
    console.log(BigInt(balance));

    await wlat.approve(datumNetworkPay.address, '800000000000000000');
    allowance = await wlat.allowance.call(accounts[0], datumNetworkPay.address);
    console.log(BigInt(allowance));

    // var taskState = await datumNetworkPay.taskState.call(123456);
    // assert.strictEqual(taskState.toNumber(), -1);

    // var res = await datumNetworkPay.prepay(123456, accounts[0], 2, [token.address], [10], {from: accounts[1] });

    // console.log(res.logs);

    // const prepayEventLog = res.logs.find(
    //   element => element.event.match('PrepayEvent') &&
    //     element.address.match(datumNetworkPay.address)
    // );

    // assert.strictEqual(prepayEventLog.args.taskId.toString(), '123456');

    // assert.strictEqual(prepayEventLog.args.user, accounts[0]);

    // assert.strictEqual(prepayEventLog.args.userAgency, accounts[1]);

    // assert.strictEqual(prepayEventLog.args.fee.toString(), '2');

    // assert.strictEqual(prepayEventLog.args.tokenAddressList[0], token.address);

    // assert.strictEqual(prepayEventLog.args.tokenValueList[0].toString(), '10');

    // taskState = await datumNetworkPay.taskState.call(123456);
    // assert.strictEqual(taskState.toNumber(), 1);

    // var info = await datumNetworkPay.getTaskInfo.call(123456);
    // console.log(info);

    // assert.strictEqual(info['0'], accounts[0]);

    // assert.strictEqual(info['1'], accounts[1]);

    // assert.strictEqual(info['2'].toString(), '2');

    // assert.strictEqual(info['3'].length, 1); 

    // assert.strictEqual(info['3'][0], token.address);

    // assert.strictEqual(info['4'].length, 1); 

    // assert.strictEqual(info['4'][0].toString(), '10');
    
    // assert.strictEqual(info['5'].toNumber(), 1);

    // res = await datumNetworkPay.settle(123456, 1, {from: accounts[1] });

    // console.log(res.logs);

    // const settleEventLog = res.logs.find(
    //   element => element.event.match('SettleEvent') &&
    //     element.address.match(datumNetworkPay.address)
    // );

    // assert.strictEqual(settleEventLog.args.taskId.toString(), '123456');

    // assert.strictEqual(settleEventLog.args.user, accounts[0]);

    // assert.strictEqual(settleEventLog.args.userAgency, accounts[1]);

    // assert.strictEqual(settleEventLog.args.Agencyfee.toString(), '1');

    // assert.strictEqual(settleEventLog.args.refundOrAdd.toString(), '1');

    // assert.strictEqual(settleEventLog.args.tokenAddressList[0], token.address);

    // assert.strictEqual(settleEventLog.args.tokenValueList[0].toString(), '10');

    // taskState = await datumNetworkPay.taskState.call(123456);
    // assert.strictEqual(taskState.toNumber(), -1);

    // info = await datumNetworkPay.getTaskInfo.call(123456);
    // console.log(info);

    // const zeroAddress = '0x0000000000000000000000000000000000000000';

    // assert.strictEqual(info['0'], zeroAddress);

    // assert.strictEqual(info['1'], zeroAddress);

    // assert.strictEqual(info['2'].toString(), '0');

    // assert.strictEqual(info['3'].length, 1); 

    // assert.strictEqual(info['3'][0], zeroAddress);

    // assert.strictEqual(info['4'].length, 1); 

    // assert.strictEqual(info['4'][0].toString(), '0');
    
    // assert.strictEqual(info['5'].toNumber(), -1);
  });
  
});


