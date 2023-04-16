// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

// Setting timer on games
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
// Pricing in USD instead of ETH (frontend usecase)
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// Only owner can do stuff
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
// VRF for picking winner
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
// Prevent reentrancy attacks
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// NFT stuff
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IRandomizer} from "./interfaces/IRandomizer.sol";

contract JPEGRoyal is
    AutomationCompatibleInterface,
    AccessControl,
    ReentrancyGuard,
    VRFConsumerBase
{
    //////////////////////////// PriceFeeds ////////////////////////////

    AggregatorV3Interface internal ethUsdPriceFeed;

    //////////////////////////// Randomizer ////////////////////////////

    /// @notice Randomizer.AI
    IRandomizer public immutable randomizer;

    /// @notice callback gas limit for VRF request
    uint32 public immutable callbackGasLimit;

    /// @notice number of confirmations for VRF request
    uint8 public immutable requestConfirmations;

    //////////////////////////// Raffle ////////////////////////////

    event RaffleCreated(
        uint256 indexed raffleId,
        address indexed nftAddress,
        uint256 indexed nftId
    );

    struct Raffle {
        address winner;
        address collateralAddress;
        uint256 collateralId; // Maybe make uint32/64/...
        uint256 randomNumber;
        uint256 startTime; // Necessary?
        uint256 endTime;
        uint256 minimumNumberOfEntries;
    }

    Raffle[] public raffles;

    //////////////////////////////////////////////////////////////

    // address of the wallet controlled by the platform that will receive the platform fee
    address payable public daoWalletAddress;

    uint256 immutable GAME_TIMER = 14400;

    constructor(
        address _priceFeedAddress,
        address _randomizer,
        uint32 _callbackGasLimit,
        uint8 _requestConfirmations,
        address _daoWalletAddress
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        randomizer = IRandomizer(_randomizer);
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;

        daoWalletAddress = _daoWalletAddress;
    }

    /// @param _minimumNumberOfEntries The minimum number of entries required for a raffle to finish.
    /// @param _collateralAddress The address of the NFT for the raffle.
    /// @param _collateralId The id of the NFT.
    /// @param _interval The number of seconds the raffle will be open for, used to compute endTime.
    function createRaffle(
        uint256 _minimumNumberOfEntries,
        address _collateralAddress,
        uint256 _collateralId,
        uint256 _interval
    ) {
        require(_minimumNumberOfEntries > 0, "minEntries is 0");
        require(_collateralAddress != address(0), "NFT is null");
        require(interval > 600, "Raffle time less than 10 minutes");

        currentTime = block.timestamp;

        Raffle memory raffle = Raffle({
            winner: address(0),
            collateralAddress: _collateralAddress,
            collateralId: _collateralId,
            randomNumber: 0,
            startTime: currentTime,
            endTime: currentTime + _interval,
            minimumNumberOfEntries: _minimumNumberOfEntries
        });

        raffles.push(raffle);

        emit RaffleCreated(
            raffles.length - 1,
            _collateralAddress,
            _collateralId
        );
    }
}
