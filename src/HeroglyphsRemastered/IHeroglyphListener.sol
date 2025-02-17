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

    /**
     * @notice Get the name of the Listener Project
     * @return name_ The name of the Listener Project
     */
    function getName() external view returns (string memory name_);

    /**
     * @notice Get the description of the Listener Project
     * @return description_ The description of the Listener Project
     */
    function getDescription() external view returns (string memory description_);

    /**
     * @notice Get the website of the Listener Project
     * @return website_ The website of the Listener Project
     * @dev If the Listener requires configuration from the validator, then it should be linked to the config page.
     */
    function getWebsite() external view returns (string memory website_);

    /**
     * @notice Get if the validator needs to setup some parameters before using the Ticker
     * @return isSetupNeeded_ If the Ticker Project needs to be setup
     */
    function isSetupNeeded() external view returns (bool isSetupNeeded_);

    /**
     * @notice Get the reserved ticker id
     * @return tickerId_ The reserved ticker id
     * @dev This is Optional, leave it to 0 if not needed
     */
    function getReservedTicker() external view returns (uint256 tickerId_);

    /**
     * @notice Get the listener info
     * @return json_ The listener info in json format
     * {
     *  "name": "Listener Name",
     *  "description": "Contract Description",
     *  "website": "Contract Website",
     *  "deployer": "Deployer Address",
     *  "reservedTickerId": "Reserved Ticker Id -- If only a specific ticker works with this contract",
     *  "isSetupNeeded": "Is Setup is needed from the validator before using the contract"
     * }
     */
    function getListenerInfo() external view returns (string memory json_);
}
