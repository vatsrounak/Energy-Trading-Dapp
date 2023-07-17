// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract EnergyTrading {

    struct EnergyAsset {
        uint256 assetId;
        address owner;
        uint256 energyProduction;
        bool availableForTrading;
    }

    struct TradeTransaction {
        uint256 transactionId;
        uint256 assetId;
        address buyer;
        address seller;
        uint256 energyAmount;
        uint256 totalPrice;
        bool completed;
        bool energyDelivered;
    }

    struct Participant {
        address participantAddress;
        string name;
        string contactDetails;
        uint256 reputation;
    }

    mapping(uint256 => EnergyAsset) private energyAssets;
    mapping(uint256 => TradeTransaction) private tradeTransactions;
    mapping(address => Participant) private participants;

    uint256 private nextTransactionId;

    // Event to emit when a new energy asset is registered
    event EnergyAssetRegistered(uint256 assetId, address indexed owner);

    // Event to emit when a trade transaction is initiated
    event TradeTransactionInitiated(uint256 transactionId, address indexed buyer, address indexed seller, uint256 energyAmount, uint256 totalPrice);

    // Event to emit when a trade transaction is completed
    event TradeTransactionCompleted(uint256 transactionId, address indexed buyer, address indexed seller, uint256 energyAmount, uint256 totalPrice);

    // Function to register a new energy asset
    function registerEnergyAsset(uint256 _assetId, uint256 _energyProduction) public {
        require(energyAssets[_assetId].assetId == 0, "Asset with the same ID already exists");

        energyAssets[_assetId] = EnergyAsset(_assetId, msg.sender, _energyProduction, true);

        emit EnergyAssetRegistered(_assetId, msg.sender);
    }

    // Function to initiate a trade transaction
    function initiateTradeTransaction(uint256 _assetId, address _seller, uint256 _energyAmount, uint256 _totalPrice) public payable {
        require(energyAssets[_assetId].assetId != 0, "Asset does not exist");
        require(energyAssets[_assetId].availableForTrading, "Asset not available for trading");
        require(msg.value == _totalPrice, "Incorrect payment amount");

        energyAssets[_assetId].availableForTrading = false;

        nextTransactionId++;
        tradeTransactions[nextTransactionId] = TradeTransaction(nextTransactionId, _assetId, msg.sender, _seller, _energyAmount, _totalPrice, false, false);

        emit TradeTransactionInitiated(nextTransactionId, msg.sender, _seller, _energyAmount, _totalPrice);
    }

    // Function to complete a trade transaction
    function completeTradeTransaction(uint256 _transactionId) public {
        require(tradeTransactions[_transactionId].transactionId != 0, "Transaction does not exist");
        require(!tradeTransactions[_transactionId].completed, "Transaction already completed");
        require(tradeTransactions[_transactionId].buyer == msg.sender, "Only buyer can complete the transaction");

        tradeTransactions[_transactionId].completed = true;

        // Transfer payment to the seller
        payable(tradeTransactions[_transactionId].seller).transfer(tradeTransactions[_transactionId].totalPrice);

        emit TradeTransactionCompleted(_transactionId, tradeTransactions[_transactionId].buyer, tradeTransactions[_transactionId].seller, tradeTransactions[_transactionId].energyAmount, tradeTransactions[_transactionId].totalPrice);
    }

    // Function to confirm energy delivery by the buyer
    function confirmEnergyDelivery(uint256 _transactionId) public {
        require(tradeTransactions[_transactionId].transactionId != 0, "Transaction does not exist");
        require(tradeTransactions[_transactionId].completed, "Transaction not completed");
        require(tradeTransactions[_transactionId].seller == msg.sender, "Only seller can confirm energy delivery");

        tradeTransactions[_transactionId].energyDelivered = true;

        // Increase reputation of the seller
        participants[msg.sender].reputation++;

        // Make the asset available for trading again
        energyAssets[tradeTransactions[_transactionId].assetId].availableForTrading = true;
    }

    // Function to get the details of an energy asset
    function getEnergyAssetDetails(uint256 _assetId) public view returns (EnergyAsset memory) {
        return energyAssets[_assetId];
    }

    // Function to get the details of a trade transaction
    function getTradeTransactionDetails(uint256 _transactionId) public view returns (TradeTransaction memory) {
        return tradeTransactions[_transactionId];
    }

    // Function to get the details of a participant
    function getParticipantDetails(address _participantAddress) public view returns (Participant memory) {
        return participants[_participantAddress];
    }
}


