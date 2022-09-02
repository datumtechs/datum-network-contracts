var Pct = artifacts.require("Pct");
let pctContract

contract('Pct', (accounts) => {
    beforeEach(async () => {

      pctContract = await Pct.at("0x4fD33BbF1cFd29e35739E0C434FC0a95e25B79A8");
      console.log('pct contract:', pctContract.address);

    })
  
    it('getPctInfo: get pct information', async () => {
  
        const info = await pctContract.getPctInfo.call(1000);
        console.log(info);

    });
    
  });
  