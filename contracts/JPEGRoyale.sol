// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

// ADD RENTRANCY IMPORT FOR RENTRANCY ATTACK 

contract JPEGRoyale is VRFConsumerBaseV2, AccessControl {

    ///////////////////// RAFFLE /////////////////////

    struct EntryPrices {
        uint128 numEntries;
        uint256 price;
    }

    mapping(uint256 => EntryPrices[5]) public entryPrices;

    // struct PlayerEntries {
    //     uint256 numEntries;
    //     address player;
    // }

    mapping(uint256 => mapping (address => uint256)) public entries;

    mapping(uint256 => uint256) public sellerPrice;

    struct Raffle {
        uint48 tokenId;
        address tokenAddress;
        address winner;
        address seller;
        uint256 startTime;
        uint256 duration;
    }

    Raffle[] public raffles;

    struct RaffleInfo {
        STATUS status;
        uint48 maxEntriesPerUser;
        uint256 fundsRaised;

    }

    RaffleInfo[] public raffleInfo;

    enum STATUS {
        CREATED,
        STARTED,
        ENDING, 
        ENDED
    }


    ///////////////////// CHAINLINK-VRF /////////////////////

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; 
        bool exists; 
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; 
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;

    uint256[] public requestIds;
    uint256 public lastRequestId;

    bytes32 keyHash;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    ///////////////////// ACCESS-CONTROL /////////////////////

    bytes32 public constant GAME_STARTER_ROLE = keccak256("GAME_STARTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    //////////////////////////////////////////

    constructor(
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        address[] memory _gameStarter,
        address[] memory _admin
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        s_subscriptionId = _subscriptionId;
        keyHash = _keyHash;

        for (uint i = 0; i < _gameStarter.length; i++) {
            _grantRole(GAME_STARTER_ROLE, _gameStarter[i]);
        }

        for (uint i = 0; i < _admin.length; i++) {
            _grantRole(ADMIN_ROLE, _admin[i]);
        }
    }

    function createRaffle(
        uint48 _tokenId, 
        address _tokenAddress, 
        address _seller,
        uint256 _duration, 
        EntryPrices[] calldata _entryPrices, 
        uint48 _maxEntriesPerUser
    ) public onlyRole(GAME_STARTER_ROLE) returns (uint256 raffleId) {
        require(_maxEntriesPerUser > 0, "maxEntriesPerUser is 0");
        require(_duration > 30 minutes, "duration < 30 minutes");
        require(_entryPrices.length > 0, "no entry prices");
        require(_seller != address(0), "seller is 0x0");

        Raffle memory raffle = Raffle({
            tokenId: _tokenId,
            tokenAddress: _tokenAddress,
            winner: address(0),
            seller: _seller,
            startTime: block.timestamp,
            duration: _duration
        });

        raffles.push(raffle);

        RaffleInfo memory info = RaffleInfo({
            status: STATUS.CREATED,
            maxEntriesPerUser: _maxEntriesPerUser,
            fundsRaised: 0
        });

        raffleInfo.push(info);

        for (uint8 i = 0; i < _entryPrices.length; i++) {
            require(_entryPrices[i].numEntries > 0, "number of entries is 0");
            require(_entryPrices[i].price >= 0, "price is negative");

            EntryPrices memory prices = EntryPrices({
                numEntries: _entryPrices[i].numEntries,
                price: _entryPrices[i].price
            });

            entryPrices[raffles.length - 1][i] = prices;
        }

        return raffles.length - 1;
    }

    function purchaseEntry(uint256 _raffleId, uint256 _numOfEntries) external payable {
        RaffleInfo storage info = raffleInfo[_raffleId];
        uint256 priceOfEntry = getEntryPrice(_raffleId, _numOfEntries);

        
        // info.fundsRaised =  info.fundsRaised + entryPrices[_raffleId][_id].price;
        // entries[_raffleId].push();
    }

    function getEntryPrice(uint256 _raffleId, uint256 _numEntries) public view returns (uint256 price) {
        EntryPrices[5] memory entryList = entryPrices[_raffleId];
        for (uint8 i = 0; i < 5; i++) {
            if (entryList[i].numEntries == _numEntries) {
                return entryList[i].price;
            }
        }
    }





    function setCallbackGasLimit(uint32 _callbackGasLimit) public onlyRole(ADMIN_ROLE) returns (uint32 newCallbackGasLimit) {
        callbackGasLimit = _callbackGasLimit;
        return callbackGasLimit;
    }

    function addGameStarterRole(address _newGameStarter) public onlyRole(ADMIN_ROLE) {
        _grantRole(GAME_STARTER_ROLE, _newGameStarter);
    }

    function requestRandomWords() external returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

}
