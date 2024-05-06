# Heroglyph Library
Library to build on top of Heroglyph

## Implementation

You contract need to have this function entry point. Be sure to verify that the caller is Heroglyph Relay with `onlyRelay`
```
function onValidatorTriggered(uint32 _lzEndpointSelected, uint256 _blockNumber, address _identityReceiver, uint128 _maxFeeCost) onlyRelay external;
```

All tickers are gas-limited by `HeroglyphRelay::gasPerTicker()`. At launch this will be 400,000 gas. Any function exceeding this amount will be reverted.

Once your contract is deployed and ready to be used. You will need to create a Ticker to allow validator to use it. 

## Cost / Fee
Heroglyph operates under a Fair Usage Policy. The fee charged increases proportionally with the gas used in your contract. If your logic is very lightweight, you may never incur a fee. The cost calculation is straightforward:

`(((GasAtBeginning - GasAtTheEnd) / 20_000) * nativeFeePerUnit);`

At launch, the `nativeFeePerUnit` is set to 0. However, this value may change over time. To verify the current cost, use the HeroglyphRelay contract.

Additionally, Heroglyph provides a free allocation of `35,000` gas, primarily to refund the execution costs associated with interacting back-and-forth with the Relay and your contract.

To repay HeroglyphRelay, simply send the eth directly to the contract.

**Note:** The relay will take 100% or your transfer, it doesn't verify if you send extra. so be sure to send the good amount.


# Security & Information 

### Repeat Attack
A graffiti can contain multiple tickers, meaning your contract can be called more than once from different sources (e.g., someone creating a cheap ticker and connect your contract to it).

Therefore, it's always advisable to protect your code if this behavior is not desired.
```
function onValidatorTriggered(uint32,uint256 _blockNumber,address,uint128) external override onlyAutomate
{
	if (_blockNumber <= latestMintedBlock) revert GhostBlock();
	latestMintedBlock = _blockNumber;
}
```

### Missing Blocks
Heroglyphs ensures that the block number will never be lower than the previously executed block, but it cannot guarantee that all valid blocks are caught.

### Delay & Off-chain data
Heroglyphs is not designed for chance games or RNG (Random Number Generation). Graffiti is public and easily accessible. Additionally, Heroglyphs maintains a 10-block lag.

### Hijacking
You don't permanently own your ticker; you can lose it if your deposit reaches zero, or if someone decides to buy it at your price. Either way, keep in mind that you can lose your ticker, which will require obtaining a new one and migrating the validators.

If your product offers significant advantages to the ecosystem, please contact the Heroglyphs team. We can create a Ticker Immune to those systems for a period of time.