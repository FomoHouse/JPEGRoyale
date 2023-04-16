// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Randomizer protocol interface
interface IRandomizer {
    function request(uint256 callbackGasLimit) external returns (uint256);

    function request(
        uint256 callbackGasLimit,
        uint256 confirmations
    ) external returns (uint256);

    function estimateFee(
        uint256 callbackGasLimit
    ) external view returns (uint256);

    function estimateFee(
        uint256 callbackGasLimit,
        uint256 confirmations
    ) external view returns (uint256);

    function clientDeposit(address _contract) external payable;
}
