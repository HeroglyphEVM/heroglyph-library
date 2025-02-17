
##  Implementation
> [!CAUTION]  
> Heroglyphs V1 is only supported on Arbitrum Chain

All your contract needs is to inherit the function `ITickerOperation::onValidatorTriggered`. Then, you connect your contract to your ticker and voila, you are hooked into the Heroglyph Protocol. The only thing missing is a validator using your ticker in their graffiti `#<TICKER_NAME>`.


```
import { TickerOperator } from "heroglyph-library/src/TickerOperator.sol";

contract MyTickerOperation is TickerOperation {

  /**
   * @notice onValidatorTriggered() Callback function when your ticker has been selected
   * @param _lzEndpointSelected // The selected layer zero endpoint target for this ticker
   * @param _blockNumber  // The number of the block minted
   * @param _identityReceiver // The Identity's receiver from the miner graffiti
   * @param _heroglyphFee // The fee to pay for the execution
   * @dev be sure to apply onlyRelay to this function
   * @dev TIP: Avoid using reverts; instead, use return statements, unless you need to
   * restore your contract to its
   * initial state.
   * @dev TIP:Keep in mind that a miner may utilize your ticker more than once in their
   * graffiti. To avoid any
   * repetition, consider utilizing blockNumber to track actions.
   */
    function onValidatorTriggered(
        uint32 _lzEndpointSelected,
        uint32 _blockNumber,
        address _identityReceiver,
        uint128 _heroglyphFee
    ) external override onlyRelay {
        //Repay Fee
        _repayHeroglyph(_heroglyphFee);
        
        //Add your logic
    }
}


```

## Fee

Presently, there is **no fee** for executing a ticker. That being said, there is a possibility that later on, heroglyph request each apps to pay a fixed fee for the execution.

### Pay the Fee

There are two approaches to pay the fee, either deposit the ETH directly into your contract, or use a GasPool relationship.

If you create a GasPool, it must uses the [IGasPool](https://github.com/HeroglyphEVM/heroglyph-library/blob/0d8c4785bd8a80d8ba4f188269b0bbaf276bec84/src/ITickerOperator.sol#L9) interface

```
/**
 * @title IGasPool
 * @notice If you have a community // service pool to pay all fee, it must have this interface integrated
 * @dev is the feePayer is not the contract address, it will fallback to calling IGasPool::payTo()
 */
interface IGasPool {
    function payTo(address _to, uint256 _amount) external;
}
```

## Layer Zero

There is a small fee to execute a LZ message, this fee must be paid by your protocol // contract, otherwise the lz message will revert.

## Hook into Heroglyph

To hook your contract, see [Tickers](https://docs.heroglyphs.com/heroglyphs/technical-zone/tickers)

## Security

### Repeat Attack

A graffiti can contain multiple tickers, meaning your contract can be called more than once (e.g., someone creating a cheap ticker and connect your contract to it, or simply has your ticker more than once).

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

Heroglyphs is not designed for chance games or RNG (Random Number Generation). You should also avoid "Time-based" distribution token.

Heroglyphs processes blocks only at the end of an epoch and handles five blocks every two minutes. So, if a block is created at the start of an epoch, it will usually take about 10 minutes for Heroglyphs to recognize it. If there are ten graffiti blocks in an epoch, it will take about four minutes to process all of them.

### Hijacking

You don't permanently own your ticker; you can lose it if your deposit reaches zero, or if someone decides to buy it at your price. Either way, keep in mind that you can lose your ticker, which will require obtaining a new one and migrating the validators.

If your product offers significant advantages to the ecosystem, please contact the Heroglyphs team. We can create a Ticker Immune to those systems for a period of time.