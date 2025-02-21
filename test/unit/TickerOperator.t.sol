// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "../base/BaseTest.t.sol";
import { TickerOperator, ITickerOperator } from "src/HeroglyphsV1/TickerOperator.sol";
import { IGasPool } from "src/IGasPool.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract TickerOperatorTest is BaseTest {
    TickerOperatorHarness private underTest;

    uint128 private constant FEE = 0.01e18;

    address private owner;
    address private mockRelay;
    address private feePayer;

    function setUp() public {
        owner = generateAddress("Owner");
        mockRelay = generateAddress("Mock Relay");
        feePayer = generateAddress("FeePayer");

        underTest = new TickerOperatorHarness(owner, mockRelay, feePayer);
    }

    function test_constructor_givenFeePayerZero_thenSetToSelf() external {
        underTest = new TickerOperatorHarness(owner, mockRelay, address(0));
        assertEq(underTest.getFeePayer(), address(underTest));
    }

    function test_constructor_thenSetups() external {
        underTest = new TickerOperatorHarness(owner, mockRelay, feePayer);

        assertEq(underTest.owner(), owner);
        assertEq(address(underTest.heroglyphRelay()), mockRelay);
        assertEq(underTest.getFeePayer(), feePayer);
    }

    function function_onlyRelay_asNonRelay_thenReverts() external {
        vm.expectRevert(ITickerOperator.NotHeroglyph.selector);
        underTest.exposed_onlyRelay();
    }

    function test_onlyRelay_asRelay_thenExecutes() external prankAs(mockRelay) {
        underTest.exposed_onlyRelay();
    }

    function test_repayHeroglyph_whenFeeZero_thenDoNothing() external {
        vm.mockCallRevert(feePayer, abi.encodeWithSelector(IGasPool.payTo.selector), "Should not be called");
        underTest.exposed_repayHeroglyph(0);
    }

    function test_repayHeroglyph_whenFeePayer_thenUseFeePayer() external {
        vm.mockCall(feePayer, abi.encodeWithSelector(IGasPool.payTo.selector), abi.encode(true));
        vm.expectCall(feePayer, abi.encodeWithSelector(IGasPool.payTo.selector, mockRelay, FEE));

        underTest.exposed_repayHeroglyph(FEE);
    }

    function test_repayHeroglyph_whenFeePayerIsSelf_thenRepays() external prankAs(owner) {
        underTest.updateFeePayer(address(underTest));

        vm.mockCall(feePayer, abi.encodeWithSelector(IGasPool.payTo.selector), abi.encode(false));
        vm.deal(address(underTest), FEE);

        underTest.exposed_repayHeroglyph(FEE);

        assertEq(mockRelay.balance, FEE);
        assertEq(address(underTest).balance, 0);
    }

    function test_repayHeroglyph_whenFailedToSendEth_thenReverts() external prankAs(owner) {
        underTest.updateFeePayer(address(underTest));

        vm.etch(mockRelay, type(FailOnEth).creationCode);

        vm.deal(address(underTest), FEE);

        vm.expectRevert(ITickerOperator.FailedToSendETH.selector);
        underTest.exposed_repayHeroglyph(FEE);
    }

    function test_askFeePayerToPay_whenFeePayerIsGasPool_thenReturnsTrue() external {
        address to = generateAddress();
        uint128 amount = 1.25e18;

        vm.mockCall(feePayer, abi.encodeWithSelector(IGasPool.payTo.selector), abi.encode(true));
        vm.expectCall(feePayer, abi.encodeWithSelector(IGasPool.payTo.selector, to, amount));

        assertTrue(underTest.exposed_askFeePayerToPay(to, amount));
    }

    function test_askFeePayerToPay_givenSelf_whenFeePayerIsSelfAndNotEnough_thenReturnsFalse()
        external
        prankAs(owner)
    {
        underTest.updateFeePayer(address(underTest));

        assertFalse(underTest.exposed_askFeePayerToPay(address(underTest), uint128(address(underTest).balance + 1)));
    }

    function test_askFeePayerToPay_whenFeePayerIsSelfAndHasNotEnough_thenReturnsFalse() external prankAs(owner) {
        underTest.updateFeePayer(address(underTest));

        address to = generateAddress();
        assertFalse(underTest.exposed_askFeePayerToPay(to, uint128(address(underTest).balance + 0.1e18)));
    }

    function test_askFeePayerToPay_givenSelf_whenFeePayerIsSelfAndHasEnough_thenReturnsTrue() external prankAs(owner) {
        uint128 amount = 1.25e18;
        vm.deal(address(underTest), amount);

        underTest.updateFeePayer(address(underTest));

        assertTrue(underTest.exposed_askFeePayerToPay(address(underTest), amount));
    }

    function test_askFeePayerToPay_whenFeePayerIsSelfAndHasEnough_thenReturnsTrueAndSends() external prankAs(owner) {
        underTest.updateFeePayer(address(underTest));

        address to = generateAddress();
        uint128 amount = 1.25e18;
        vm.deal(address(underTest), amount);

        assertTrue(underTest.exposed_askFeePayerToPay(to, amount));

        assertEq(to.balance, amount);
        assertEq(address(underTest).balance, 0);
    }

    function test_updateHeroglyphRelay_whenNotOwner_thenReverts() external prankAs(feePayer) {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, feePayer));
        underTest.updateHeroglyphRelay(address(0));
    }

    function test_updateHeroglyphRelay_givenAddressZero_thenReverts() external prankAs(owner) {
        address newRelay = generateAddress();

        expectExactEmit();
        emit ITickerOperator.HeroglyphRelayUpdated(newRelay);
        underTest.updateHeroglyphRelay(newRelay);

        assertEq(underTest.heroglyphRelay(), newRelay);
    }

    function test_updateFeePayer_whenNotOwner_thenReverts() external prankAs(feePayer) {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, feePayer));
        underTest.updateFeePayer(address(0));
    }

    function test_updateFeePayer_givenAddressZero_thenReverts() external prankAs(owner) {
        vm.expectRevert(ITickerOperator.FeePayerCannotBeZero.selector);
        underTest.updateFeePayer(address(0));
    }

    function test_updateFeePayer_thenUpdates() external prankAs(owner) {
        address newPayer = generateAddress();

        expectExactEmit();
        emit ITickerOperator.FeePayerUpdated(newPayer);
        underTest.updateFeePayer(newPayer);

        assertEq(underTest.getFeePayer(), newPayer);
    }
}

contract TickerOperatorHarness is TickerOperator {
    constructor(address _owner, address _heroglyph, address _feePayer) TickerOperator(_owner, _heroglyph, _feePayer) { }

    function onValidatorTriggered(
        uint32 _lzEndpointSelected,
        uint32 _blockNumber,
        address _identityReceiver,
        uint128 _maxFeeCost
    ) external override { }

    function exposed_onlyRelay() external onlyRelay { }

    function exposed_repayHeroglyph(uint128 _fee) external {
        _repayHeroglyph(_fee);
    }

    function exposed_askFeePayerToPay(address _to, uint128 _amount) external returns (bool) {
        return _askFeePayerToPay(_to, _amount);
    }
}

contract FailOnEth {
    receive() external payable {
        revert("No!");
    }
}
