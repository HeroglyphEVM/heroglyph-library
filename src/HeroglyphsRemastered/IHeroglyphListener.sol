// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

interface IHeroglyphListener {
    error FailedToSendETH();
    error NotHeroglyph();
    error FeePayerCannotBeZero();

    event FeePayerUpdated(address indexed feePayer);
    event HeroglyphRelayUpdated(address relay);

    /**
     * @notice onValidatorTriggered() Callback function when your ticker has been selected
     * @param _identityReceiver // The Identity's receiver from the miner graffiti
     * @param _blockNumber // The block number of the graffiti
     * @param _tickerId // The id of the ticker that triggered the execution
     * @param _validatorBalance // The balance of the validator
     * @param _heroglyphFee // The fee to pay for the execution
     * @dev be sure to apply onlyRelay to this function
     * @dev TIP: Avoid using reverts; instead, use return statements, unless you need to restore your contract to its
     * initial state.
     * @dev TIP:Keep in mind that a miner may utilize your ticker more than once in their graffiti. To avoid any
     * repetition, consider utilizing blockNumber to track actions.
     */
    function onValidatorTriggered(
        address _identityReceiver,
        uint32 _blockNumber,
        uint32 _tickerId,
        uint128 _validatorBalance,
        uint128 _heroglyphFee
    ) external;
}
