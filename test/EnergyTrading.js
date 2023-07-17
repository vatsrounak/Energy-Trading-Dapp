const { expect } = require("chai");
const {ethers} = require("hardhat");


describe("EnergyTrading", function () {
  let energyTrading;
  let owner;
  let buyer;
  let seller;

  beforeEach(async function () {
    [owner, buyer, seller] = await ethers.getSigners();
    const EnergyTradingFactory = await ethers.getContractFactory("EnergyTrading");
    energyTrading = await EnergyTradingFactory.deploy();
    await energyTrading.deployed();
  });

  it("should register a new energy asset", async function () {
    const assetId = 1;
    const energyProduction = 100;

    await energyTrading.registerEnergyAsset(assetId, energyProduction);

    const asset = await energyTrading.getEnergyAssetDetails(assetId);

    expect(asset.owner).to.equal(owner.address);
    expect(asset.energyProduction).to.equal(energyProduction);
    expect(asset.availableForTrading).to.equal(true);
  });

  it("should initiate a trade transaction", async function () {
    const assetId = 1;
    const energyAmount = 50;
    const totalPrice = 100;

    await energyTrading.initiateTradeTransaction(assetId, seller.address, energyAmount, totalPrice, {
      value: totalPrice,
    });

    const transactionId = 1;
    const transaction = await energyTrading.getTradeTransactionDetails(transactionId);

    expect(transaction.assetId).to.equal(assetId);
    expect(transaction.buyer).to.equal(owner.address);
    expect(transaction.seller).to.equal(seller.address);
    expect(transaction.energyAmount).to.equal(energyAmount);
    expect(transaction.totalPrice).to.equal(totalPrice);
    expect(transaction.completed).to.equal(false);
    expect(transaction.energyDelivered).to.equal(false);
  });

  it("should complete a trade transaction", async function () {
    const transactionId = 1;

    await energyTrading.completeTradeTransaction(transactionId);

    const transaction = await energyTrading.getTradeTransactionDetails(transactionId);

    expect(transaction.completed).to.equal(true);
  });

  it("should confirm energy delivery", async function () {
    const transactionId = 1;

    await energyTrading.confirmEnergyDelivery(transactionId);

    const transaction = await energyTrading.getTradeTransactionDetails(transactionId);

    expect(transaction.energyDelivered).to.equal(true);

    const sellerDetails = await energyTrading.getParticipantDetails(seller.address);

    expect(sellerDetails.reputation).to.equal(1);

    const assetDetails = await energyTrading.getEnergyAssetDetails(transaction.assetId);

    expect(assetDetails.availableForTrading).to.equal(true);
  });
});
