exports.balanceOf = async (address) => web3.eth.getBalance(address);
exports.ether2wei = (n) => new web3.BigNumber(web3.toWei(n, 'ether'));
