
let tokenTemplate
let factory
let token
var ERC721Factory = artifacts.require("ERC721Factory");
var ERC721Template = artifacts.require("ERC721Template");

contract('ERC721Factory', (accounts) => {
  const tokenName = 'My ERC721 Coin';
  const tokenSymbol = 'NFT';
  const tokenCap = 100;
  const tokenProof = 'jatel';

  beforeEach(async () => {
    tokenTemplate = await ERC721Template;
    factory = await ERC721Factory.new(tokenTemplate.address);
    const res = await factory.deployERC721Contract(tokenName, tokenSymbol, tokenCap, tokenProof);
    const NFTContractCreatedLog = res.logs.find(
      element => element.event.match('NFTContractCreated') &&
        element.address.match(factory.address)
    );
    token = await ERC721Template.at(NFTContractCreatedLog.args.newTokenAddress);
  })

  it('events: should fire NFTContractCreated event successfully', async () => {
    const res = await factory.deployERC721Contract(tokenName, tokenSymbol, tokenCap, tokenProof);

    const NFTContractCreatedLog = res.logs.find(
      element => element.event.match('NFTContractCreated') &&
        element.address.match(factory.address)
    );

    assert.strictEqual(NFTContractCreatedLog.args.templateAddress, tokenTemplate.address);

    assert.strictEqual(NFTContractCreatedLog.args.admin, accounts[0]);

    assert.strictEqual(NFTContractCreatedLog.args.name.toString(), tokenName);

    assert.strictEqual(NFTContractCreatedLog.args.symbol.toString(), tokenSymbol);

    assert.strictEqual(NFTContractCreatedLog.args.tokenCap.toString(), '100');
    
    assert.strictEqual(NFTContractCreatedLog.args.proof.toString(), tokenProof);

  });

  it('creation: test correct setting of vanity information', async () => {
    const name = await token.name.call();
    assert.strictEqual(name, tokenName);

    const symbol = await token.symbol.call();
    assert.strictEqual(symbol, tokenSymbol);

    const admin = await token.admin.call();
    assert.strictEqual(admin, accounts[0]); 

    const cap = await token.cap.call();
    assert.strictEqual(cap.toNumber(), tokenCap)

    const proof = await token.proof.call();
    assert.strictEqual(proof, tokenProof); 
  });

  it('returns correct tokenURI', async () => {
    const tokenTerm1 = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm1, tokenUri1);
    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId1 = transferLog.args.tokenId;
    assert.strictEqual(tokenId1.toNumber(), 0);

    var uri = await token.tokenURI.call(tokenId1);
    assert.strictEqual(uri, tokenUri1);

    var character = await token.getCharacter.call(tokenId1);
    assert.strictEqual(character, tokenTerm1);

    const tokenTerm2 = "This is term for the token 2"
    const tokenUri2 = "This is data for the token 2";
    res = await token.createToken(tokenTerm2, tokenUri2);
    transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId2 = transferLog.args.tokenId;
    assert.strictEqual(tokenId2.toNumber(), 1);

    uri = await token.tokenURI.call(tokenId2);
    assert.strictEqual(uri, tokenUri2);

    character = await token.getCharacter.call(tokenId2);
    assert.strictEqual(character, tokenTerm2);
  });

  it('returns correct balanceOf', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    await token.createToken(tokenTerm, tokenUri1);

    var balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 1);

    await token.createToken(tokenTerm, tokenUri1);

    balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 2);
  });

  it('finds the correct owner of NFToken id', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    const tokenOwner = await token.ownerOf(tokenId);
    assert.strictEqual(tokenOwner, accounts[0]); 
  });

  it('correctly approves account', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.approve(accounts[1], tokenId);
    const approveAddress = await token.getApproved(tokenId);
    assert.strictEqual(approveAddress, accounts[1]); 
  });

  it('correctly cancels approval', async () => {
    const zeroAddress = '0x0000000000000000000000000000000000000000';
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.approve(accounts[1], tokenId);
    await token.approve(zeroAddress, tokenId);
    const approveAddress = await token.getApproved(tokenId);
    assert.strictEqual(approveAddress, zeroAddress); 
  });

  it('correctly transfers NFT from owner', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.transferFrom(accounts[0], accounts[1], tokenId);

    var balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 0);

    balance = await token.balanceOf.call(accounts[1]);
    assert.strictEqual(balance.toNumber(), 1);

    const tokenOwner = await token.ownerOf(tokenId);
    assert.strictEqual(tokenOwner, accounts[1]); 
  });

  it('correctly transfers NFT from approved address', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.approve(accounts[1], tokenId);
    await token.transferFrom(accounts[0], accounts[2], tokenId, { from: accounts[1] });

    var balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 0);

    balance = await token.balanceOf.call(accounts[2]);
    assert.strictEqual(balance.toNumber(), 1);

    const tokenOwner = await token.ownerOf(tokenId);
    assert.strictEqual(tokenOwner, accounts[2]);
  });

  it('correctly transfers NFT as operator', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.setApprovalForAll(accounts[1], true);

    await token.transferFrom(accounts[0], accounts[2], tokenId, { from: accounts[1] });

    var balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 0);

    balance = await token.balanceOf.call(accounts[2]);
    assert.strictEqual(balance.toNumber(), 1);

    const tokenOwner = await token.ownerOf(tokenId);
    assert.strictEqual(tokenOwner, accounts[2]);
  });

  it('correctly safe transfers NFT from owner', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.methods['safeTransferFrom(address,address,uint256)'](accounts[0], accounts[1], tokenId);

    var balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 0);

    balance = await token.balanceOf.call(accounts[1]);
    assert.strictEqual(balance.toNumber(), 1);

    const tokenOwner = await token.ownerOf(tokenId);
    assert.strictEqual(tokenOwner, accounts[1]);
  });

  it('correctly safe transfers NFT from owner to smart contract that can receive NFTs with data', async () => {
    const tokenTerm = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    var res = await token.createToken(tokenTerm, tokenUri1);

    var transferLog = res.logs.find(
      element => element.event.match('Transfer') &&
        element.address.match(token.address)
    );
    const tokenId = transferLog.args.tokenId;

    await token.methods['safeTransferFrom(address,address,uint256,bytes)'](accounts[0], accounts[1], tokenId, '0x01');

    var balance = await token.balanceOf.call(accounts[0]);
    assert.strictEqual(balance.toNumber(), 0);

    balance = await token.balanceOf.call(accounts[1]);
    assert.strictEqual(balance.toNumber(), 1);

    const tokenOwner = await token.ownerOf(tokenId);
    assert.strictEqual(tokenOwner, accounts[1]);
  });

  it('NFT enumerable interface', async () => {
    const tokenTerm1 = "This is term for the token 1"
    const tokenUri1 = "This is data for the token 1";
    const tokenTerm2 = "This is term for the token 2"
    const tokenUri2 = "This is data for the token 2";

    await token.createToken(tokenTerm1, tokenUri1);

    await token.createToken(tokenTerm2, tokenUri2);

    var oneTokenId = await token.tokenByIndex.call(0);
    assert.strictEqual(oneTokenId.toNumber(), 0);

    oneTokenId = await token.tokenOfOwnerByIndex.call(accounts[0], 0);
    assert.strictEqual(oneTokenId.toNumber(), 0);
  });
  
});

