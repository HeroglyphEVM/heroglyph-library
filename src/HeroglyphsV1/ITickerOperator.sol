// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

interface ITickerOperator {
    error FailedToSendETH();
    error NotHeroglyph();
    error FeePayerCannotBeZero();

    event FeePayerUpdated(address indexed feePayer);
    event HeroglyphRelayUpdated(address relay);

    /**
     * @notice onValidatorTriggered() Callback function when your ticker has been selected
     * @param _lzEndpointSelected // The selected layer zero endpoint target for this ticker
     * @param _blockNumber  // The number of the block minted
     * @param _identityReceiver // The Identity's receiver from the miner graffiti
     * @param _heroglyphFee // The fee to pay for the execution
     * @dev be sure to apply onlyRelay to this function
     * @dev TIP: Avoid using reverts; instead, use return statements, unless you need to restore your contract to its
     * initial state.
     * @dev TIP:Keep in mind that a miner may utilize your ticker more than once in their graffiti. To avoid any
     * repetition, consider utilizing blockNumber to track actions.
     */
    function onValidatorTriggered(
        uint32 _lzEndpointSelected,
        uint32 _blockNumber,
        address _identityReceiver,
        uint128 _heroglyphFee
    ) external;
}
