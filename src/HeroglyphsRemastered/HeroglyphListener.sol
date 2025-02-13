// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.28;

import { IHeroglyphListener } from "./IHeroglyphListener.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IGasPool } from "../IGasPool.sol";

/**
 * @title TickerOperator
 * @notice Template of what a Ticker Contract should have to execute successfully. This can be implemented in your if
 * needed
 */
abstract contract HeroglyphListener is IHeroglyphListener, Ownable {
    address public heroglyphRelay;
    address private feePayer;

    modifier onlyRelay() {
        require(msg.sender == address(heroglyphRelay), NotHeroglyph());
        _;
    }

    constructor(address _contractOwner, address _heroglyphRelay, address _feePayer) Ownable(_contractOwner) {
        if (_feePayer == address(0)) _feePayer = address(this);

        feePayer = _feePayer;
        heroglyphRelay = _heroglyphRelay;
    }

    /**
     * @notice _repayHeroglyph repay the HeroglyphRelay contract for executing your code
     * @dev it should be call at the end / near the end of your code. It uses gasLeft() to calculate the
     * cost of the fee.
     */
    function _repayHeroglyph(uint128 _feeToPay) internal virtual {
        if (_feeToPay == 0) return;
        require(_askFeePayerToPay(address(heroglyphRelay), _feeToPay), FailedToSendETH());
    }

    function _askFeePayerToPay(address _to, uint128 _amount) internal returns (bool success_) {
        if (feePayer != address(this)) {
            IGasPool(feePayer).payTo(_to, _amount);
            return true;
        }

        if (address(this).balance < _amount) return false;
        if (_to == address(this)) return true;

        (success_,) = _to.call{ value: _amount }("");
        return success_;
    }

    function updateHeroglyphRelay(address _relay) external onlyOwner {
        heroglyphRelay = _relay;
        emit HeroglyphRelayUpdated(_relay);
    }

    function updateFeePayer(address _feePayer) external onlyOwner {
        _updateFeePayer(_feePayer);
    }

    function _updateFeePayer(address _feePayer) internal virtual {
        require(_feePayer != address(0), FeePayerCannotBeZero());

        feePayer = _feePayer;
        emit FeePayerUpdated(_feePayer);
    }

    function getFeePayer() public view virtual returns (address) {
        return feePayer;
    }

    receive() external payable virtual { }
}
