# ZapContract for GitCoin

## Objective
The objective of this repo is the (gitcoinZap Contract)[https://github.com/amateur-dev/gitcoin-defizap/blob/master/contracts/gitcoinZap.sol].
This contract is essentially helpful when the ultimate donor wants to donate Dai to more than one Grants

## Running instructions
The gitcoinZap Contract can be deployed directly, without going through openzeppelin.
For this purpose you could choose to deploy it through truffle, web3 or direclty through remix / myetherwallet too.
Should you choose to deploy this contract in an upgradable manner, you could use the openzeppelin cli

### Note:
If you deploy the contract directly, you must call the initialize function after deployment.  The initialize function needs a parameter which the DAI Contract Address: `0x6b175474e89094c44da98b954eedeac495271d0f`

Should you choose to adopt the openzeppelin's upgradable mechanism, you must call the intialize function in the proxy contract.  It will also be prudent to call the initalize function in the instance contract also.

## Flattened File
The contract has also been flattened and is available in the flatContracts Folder.

## How to work with it
To save unnecessary gas consumption, this contract does not do any math inside the contract (apart from a basic one).  Thus, this contract relies on the web-client to provide information in relation the grantees accounts and the amounts to be transferred to them

## TODO
To work with GitCoin to update the subscription mechanism to support the above.
